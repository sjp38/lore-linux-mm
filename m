Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 4CA706B0036
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 10:32:17 -0400 (EDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 3/6] mm: munlock: batch non-THP page isolation and munlock+putback using pagevec
Date: Mon,  5 Aug 2013 16:32:02 +0200
Message-Id: <1375713125-18163-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
References: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: joern@logfs.org
Cc: mgorman@suse.de, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

Currently, munlock_vma_range() calls munlock_vma_page on each page in a loop,
which results in repeated taking and releasing of the lru_lock spinlock for
isolating pages one by one. This patch batches the munlock operations using
an on-stack pagevec, so that isolation is done under single lru_lock. For THP
pages, the old behavior is preserved as they might be split while putting them
into the pagevec. After this patch, a 9% speedup was measured for munlocking
a 56GB large memory area with THP disabled.

A new function __munlock_pagevec() is introduced that takes a pagevec and:
1) It clears PageMlocked and isolates all pages under lru_lock. Zone page stats
can be also updated using the variant which assumes disabled interrupts.
2) It finishes the munlock and lru putback on all pages under their lock_page.
Note that previously, lock_page covered also the PageMlocked clearing and page
isolation, but it is not needed for those operations.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mlock.c | 197 ++++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 157 insertions(+), 40 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index b85f1e8..08689b6 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -11,6 +11,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/pagemap.h>
+#include <linux/pagevec.h>
 #include <linux/mempolicy.h>
 #include <linux/syscalls.h>
 #include <linux/sched.h>
@@ -18,6 +19,8 @@
 #include <linux/rmap.h>
 #include <linux/mmzone.h>
 #include <linux/hugetlb.h>
+#include <linux/memcontrol.h>
+#include <linux/mm_inline.h>
 
 #include "internal.h"
 
@@ -87,6 +90,47 @@ void mlock_vma_page(struct page *page)
 	}
 }
 
+/*
+ * Finish munlock after successful page isolation
+ *
+ * Page must be locked. This is a wrapper for try_to_munlock()
+ * and putback_lru_page() with munlock accounting.
+ */
+static void __munlock_isolated_page(struct page *page)
+{
+	int ret = SWAP_AGAIN;
+
+	/*
+	 * Optimization: if the page was mapped just once, that's our mapping
+	 * and we don't need to check all the other vmas.
+	 */
+	if (page_mapcount(page) > 1)
+		ret = try_to_munlock(page);
+
+	/* Did try_to_unlock() succeed or punt? */
+	if (ret != SWAP_MLOCK)
+		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
+
+	putback_lru_page(page);
+}
+
+/*
+ * Accounting for page isolation fail during munlock
+ *
+ * Performs accounting when page isolation fails in munlock. There is nothing
+ * else to do because it means some other task has already removed the page
+ * from the LRU. putback_lru_page() will take care of removing the page from
+ * the unevictable list, if necessary. vmscan [page_referenced()] will move
+ * the page back to the unevictable list if some other vma has it mlocked.
+ */
+static void __munlock_isolation_failed(struct page *page)
+{
+	if (PageUnevictable(page))
+		count_vm_event(UNEVICTABLE_PGSTRANDED);
+	else
+		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
+}
+
 /**
  * munlock_vma_page - munlock a vma page
  * @page - page to be unlocked
@@ -112,37 +156,10 @@ unsigned int munlock_vma_page(struct page *page)
 		unsigned int nr_pages = hpage_nr_pages(page);
 		mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
 		page_mask = nr_pages - 1;
-		if (!isolate_lru_page(page)) {
-			int ret = SWAP_AGAIN;
-
-			/*
-			 * Optimization: if the page was mapped just once,
-			 * that's our mapping and we don't need to check all the
-			 * other vmas.
-			 */
-			if (page_mapcount(page) > 1)
-				ret = try_to_munlock(page);
-			/*
-			 * did try_to_unlock() succeed or punt?
-			 */
-			if (ret != SWAP_MLOCK)
-				count_vm_event(UNEVICTABLE_PGMUNLOCKED);
-
-			putback_lru_page(page);
-		} else {
-			/*
-			 * Some other task has removed the page from the LRU.
-			 * putback_lru_page() will take care of removing the
-			 * page from the unevictable list, if necessary.
-			 * vmscan [page_referenced()] will move the page back
-			 * to the unevictable list if some other vma has it
-			 * mlocked.
-			 */
-			if (PageUnevictable(page))
-				count_vm_event(UNEVICTABLE_PGSTRANDED);
-			else
-				count_vm_event(UNEVICTABLE_PGMUNLOCKED);
-		}
+		if (!isolate_lru_page(page))
+			__munlock_isolated_page(page);
+		else
+			__munlock_isolation_failed(page);
 	}
 
 	return page_mask;
@@ -210,6 +227,74 @@ static int __mlock_posix_error_return(long retval)
 }
 
 /*
+ * Munlock a batch of pages from the same zone
+ *
+ * The work is split to two main phases. First phase clears the Mlocked flag
+ * and attempts to isolate the pages, all under a single zone lru lock.
+ * The second phase finishes the munlock only for pages where isolation
+ * succeeded.
+ */
+static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
+{
+	int i;
+	int nr = pagevec_count(pvec);
+
+	/* Phase 1: page isolation */
+	spin_lock_irq(&zone->lru_lock);
+	for (i = 0; i < nr; i++) {
+		struct page *page = pvec->pages[i];
+
+		if (TestClearPageMlocked(page)) {
+			struct lruvec *lruvec;
+			int lru;
+
+			/* we have disabled interrupts */
+			__mod_zone_page_state(zone, NR_MLOCK, -1);
+
+			switch (__isolate_lru_page(page,
+						ISOLATE_UNEVICTABLE)) {
+			case 0:
+				lruvec = mem_cgroup_page_lruvec(page, zone);
+				lru = page_lru(page);
+				del_page_from_lru_list(page, lruvec, lru);
+				break;
+
+			case -EINVAL:
+				__munlock_isolation_failed(page);
+				goto skip_munlock;
+
+			default:
+				BUG();
+			}
+		} else {
+skip_munlock:
+			/*
+			 * We won't be munlocking this page in the next phase
+			 * but we still need to release the follow_page_mask()
+			 * pin.
+			 */
+			pvec->pages[i] = NULL;
+			put_page(page);
+		}
+	}
+	spin_unlock_irq(&zone->lru_lock);
+
+	/* Phase 2: page munlock and putback */
+	for (i = 0; i < nr; i++) {
+		struct page *page = pvec->pages[i];
+
+		if (unlikely(!page))
+			continue;
+
+		lock_page(page);
+		__munlock_isolated_page(page);
+		unlock_page(page);
+		put_page(page); /* pin from follow_page_mask() */
+	}
+	pagevec_reinit(pvec);
+}
+
+/*
  * munlock_vma_pages_range() - munlock all pages in the vma range.'
  * @vma - vma containing range to be munlock()ed.
  * @start - start address in @vma of the range
@@ -230,11 +315,16 @@ static int __mlock_posix_error_return(long retval)
 void munlock_vma_pages_range(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
+	struct pagevec pvec;
+	struct zone *zone = NULL;
+
+	pagevec_init(&pvec, 0);
 	vma->vm_flags &= ~VM_LOCKED;
 
 	while (start < end) {
 		struct page *page;
 		unsigned int page_mask, page_increm;
+		struct zone *pagezone;
 
 		/*
 		 * Although FOLL_DUMP is intended for get_dump_page(),
@@ -246,20 +336,47 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		page = follow_page_mask(vma, start, FOLL_GET | FOLL_DUMP,
 					&page_mask);
 		if (page && !IS_ERR(page)) {
-			lock_page(page);
-			/*
-			 * Any THP page found by follow_page_mask() may have
-			 * gotten split before reaching munlock_vma_page(),
-			 * so we need to recompute the page_mask here.
-			 */
-			page_mask = munlock_vma_page(page);
-			unlock_page(page);
-			put_page(page);
+			pagezone = page_zone(page);
+			/* The whole pagevec must be in the same zone */
+			if (pagezone != zone) {
+				if (pagevec_count(&pvec))
+					__munlock_pagevec(&pvec, zone);
+				zone = pagezone;
+			}
+			if (PageTransHuge(page)) {
+				/*
+				 * THP pages are not handled by pagevec due
+				 * to their possible split (see below).
+				 */
+				if (pagevec_count(&pvec))
+					__munlock_pagevec(&pvec, zone);
+				lock_page(page);
+				/*
+				 * Any THP page found by follow_page_mask() may
+				 * have gotten split before reaching
+				 * munlock_vma_page(), so we need to recompute
+				 * the page_mask here.
+				 */
+				page_mask = munlock_vma_page(page);
+				unlock_page(page);
+				put_page(page); /* follow_page_mask() */
+			} else {
+				/*
+				 * Non-huge pages are handled in batches
+				 * via pagevec. The pin from
+				 * follow_page_mask() prevents them from
+				 * collapsing by THP.
+				 */
+				if (pagevec_add(&pvec, page) == 0)
+					__munlock_pagevec(&pvec, zone);
+			}
 		}
 		page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
 		start += page_increm * PAGE_SIZE;
 		cond_resched();
 	}
+	if (pagevec_count(&pvec))
+		__munlock_pagevec(&pvec, zone);
 }
 
 /*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
