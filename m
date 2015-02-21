Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id D88D06B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:25:23 -0500 (EST)
Received: by paceu11 with SMTP id eu11so12894176pac.10
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:25:23 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id p10si3429551pdr.140.2015.02.20.20.25.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:25:22 -0800 (PST)
Received: by pabkx10 with SMTP id kx10so12995197pab.0
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:25:22 -0800 (PST)
Date: Fri, 20 Feb 2015 20:25:20 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 21/24] huge tmpfs: fix Mlocked meminfo, tracking huge and
 unhuge mlocks
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202023570.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Up to this point, the huge tmpfs effort hasn't looked at or touched
mm/mlock.c at all, and it was surprising that regular tests did not
therefore crash machines.

/proc/meminfo's Mlocked count has been whatever happens to be shown
if we do nothing extra: a hugely mapped and mlocked team page would
count as 4kB instead of the 2MB you'd expect; or at least until the
previous (Unevictable) patch, which now requires lruvec locking for
hpage_nr_pages() on a team page (locking not given it in mlock.c),
and varies the amount returned by hpage_nr_pages().

It would be easy to correct the 4kB or variable amount to 2MB
by using an alternative to hpage_nr_pages() here.  And it would be
fairly easy to maintain an entirely independent HugelyMlocked count,
such that Mlocked+HugelyMlocked might amount to (almost) twice RAM
size.  But is that what observers of Mlocked want?  Probably not.

So we need a huge pmd mlock to count as 2MB, but discount 4kB for
each page within it that is already mlocked by pte somewhere, in
this or another process; and a small pte mlock to count usually as
4kB, but 0 if the team head is already mlocked by pmd somewhere.

Can this be done by maintaining extra counts per team?  I did
intend so, but (a) space in team_usage is limited, and (b) mlock
and munlock already involve slow LRU switching, so might as well
keep 4kB and 2MB in synch manually; but most significantly (c) the
trylocking around which mlock (and restoration of mlock in munlock)
is currently designed, makes it hard to work out just when a count
does need to be incremented.

The hard-won solution looks much simpler than I thought possible,
but an odd interface in its current implementation.  Not so much
needed changing, mainly just clear_page_mlock(), mlock_vma_page()
munlock_vma_page() and try_to_"unmap"_one().  The big difference
from before, is that a team head page might be being mlocked as a
4kB page or as a 2MB page, and the called functions cannot tell:
so now need an nr_pages argument.  But odd because the PageTeam
case immediately converts that to an iteration count, whereas
the anon THP case keeps it as the weight for a single iteration.
Not very nice, but will do for now: it was so hard to get here,
I'm very reluctant to pull it apart in a hurry.

The TEAM_HUGELY_MLOCKED flag in team_usage does not play a large part,
just optimizes out the overhead in a couple of cases: we don't want to
make yet another pass down the team, whenever a team is last unmapped,
just to handle the unlikely mlocked-then-truncated case; and we don't
want munlocking one of many parallel huge mlocks to check every page.

Notes in passing:  Wouldn't mlock and munlock be better off using
proper anon_vma and i_mmap_rwsem locking, instead of the current page
and mmap_sem trylocking?  And if try_to_munlock() was crying out for
its own rmap walk before, instead of abusing try_to_unuse(), now it
is screaming for it.  But I haven't the time for such cleanups now,
and may be mistaken.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/pageteam.h |   38 +++++++
 mm/huge_memory.c         |    6 +
 mm/internal.h            |   25 +++--
 mm/mlock.c               |  181 ++++++++++++++++++++++---------------
 mm/rmap.c                |   34 ++++--
 5 files changed, 193 insertions(+), 91 deletions(-)

--- thpfs.orig/include/linux/pageteam.h	2015-02-20 19:35:04.303871947 -0800
+++ thpfs/include/linux/pageteam.h	2015-02-20 19:35:09.991858941 -0800
@@ -36,8 +36,14 @@ static inline struct page *team_head(str
  */
 #define TEAM_LRU_WEIGHT_ONE	1L
 #define TEAM_LRU_WEIGHT_MASK	((1L << (HPAGE_PMD_ORDER + 1)) - 1)
+/*
+ * Single bit to indicate whether team is hugely mlocked (like PageMlocked).
+ * Then another bit reserved for experiments with other team flags.
+ */
+#define TEAM_HUGELY_MLOCKED	(1L << (HPAGE_PMD_ORDER + 1))
+#define TEAM_RESERVED_FLAG	(1L << (HPAGE_PMD_ORDER + 2))
 
-#define TEAM_HIGH_COUNTER	(1L << (HPAGE_PMD_ORDER + 1))
+#define TEAM_HIGH_COUNTER	(1L << (HPAGE_PMD_ORDER + 3))
 /*
  * Count how many pages of team are instantiated, as it is built up.
  */
@@ -97,6 +103,36 @@ static inline void clear_lru_weight(stru
 	atomic_long_set(&page->team_usage, 0);
 }
 
+static inline bool team_hugely_mlocked(struct page *head)
+{
+	VM_BUG_ON_PAGE(head != team_head(head), head);
+	return atomic_long_read(&head->team_usage) & TEAM_HUGELY_MLOCKED;
+}
+
+static inline void set_hugely_mlocked(struct page *head)
+{
+	long team_usage;
+
+	VM_BUG_ON_PAGE(head != team_head(head), head);
+	team_usage = atomic_long_read(&head->team_usage);
+	while (!(team_usage & TEAM_HUGELY_MLOCKED)) {
+		team_usage = atomic_long_cmpxchg(&head->team_usage,
+				team_usage, team_usage | TEAM_HUGELY_MLOCKED);
+	}
+}
+
+static inline void clear_hugely_mlocked(struct page *head)
+{
+	long team_usage;
+
+	VM_BUG_ON_PAGE(head != team_head(head), head);
+	team_usage = atomic_long_read(&head->team_usage);
+	while (team_usage & TEAM_HUGELY_MLOCKED) {
+		team_usage = atomic_long_cmpxchg(&head->team_usage,
+				team_usage, team_usage & ~TEAM_HUGELY_MLOCKED);
+	}
+}
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 int map_team_by_pmd(struct vm_area_struct *vma,
 			unsigned long addr, pmd_t *pmd, struct page *page);
--- thpfs.orig/mm/huge_memory.c	2015-02-20 19:34:48.083909034 -0800
+++ thpfs/mm/huge_memory.c	2015-02-20 19:35:09.991858941 -0800
@@ -1264,7 +1264,7 @@ struct page *follow_trans_huge_pmd(struc
 		if (page->mapping && trylock_page(page)) {
 			lru_add_drain();
 			if (page->mapping)
-				mlock_vma_page(page);
+				mlock_vma_pages(page, HPAGE_PMD_NR);
 			unlock_page(page);
 		}
 	}
@@ -1435,6 +1435,10 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 				MM_ANONPAGES : MM_FILEPAGES, -HPAGE_PMD_NR);
 			atomic_long_dec(&tlb->mm->nr_ptes);
 			spin_unlock(ptl);
+			if (!PageAnon(page) &&
+			    !team_hugely_mapped(page) &&
+			    team_hugely_mlocked(page))
+				clear_pages_mlock(page, HPAGE_PMD_NR);
 			tlb_remove_page(tlb, page);
 		}
 		pte_free(tlb->mm, pgtable);
--- thpfs.orig/mm/internal.h	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/internal.h	2015-02-20 19:35:09.991858941 -0800
@@ -230,8 +230,16 @@ static inline void munlock_vma_pages_all
 /*
  * must be called with vma's mmap_sem held for read or write, and page locked.
  */
-extern void mlock_vma_page(struct page *page);
-extern unsigned int munlock_vma_page(struct page *page);
+extern void mlock_vma_pages(struct page *page, int nr_pages);
+static inline void mlock_vma_page(struct page *page)
+{
+	mlock_vma_pages(page, 1);
+}
+extern int munlock_vma_pages(struct page *page, int nr_pages);
+static inline void munlock_vma_page(struct page *page)
+{
+	munlock_vma_pages(page, 1);
+}
 
 /*
  * Clear the page's PageMlocked().  This can be useful in a situation where
@@ -242,7 +250,11 @@ extern unsigned int munlock_vma_page(str
  * If called for a page that is still mapped by mlocked vmas, all we do
  * is revert to lazy LRU behaviour -- semantics are not broken.
  */
-extern void clear_page_mlock(struct page *page);
+extern void clear_pages_mlock(struct page *page, int nr_pages);
+static inline void clear_page_mlock(struct page *page)
+{
+	clear_pages_mlock(page, 1);
+}
 
 /*
  * mlock_migrate_page - called only from migrate_page_copy() to
@@ -268,12 +280,7 @@ extern pmd_t maybe_pmd_mkwrite(pmd_t pmd
 extern unsigned long vma_address(struct page *page,
 				 struct vm_area_struct *vma);
 #endif
-#else /* !CONFIG_MMU */
-static inline void clear_page_mlock(struct page *page) { }
-static inline void mlock_vma_page(struct page *page) { }
-static inline void mlock_migrate_page(struct page *new, struct page *old) { }
-
-#endif /* !CONFIG_MMU */
+#endif /* CONFIG_MMU */
 
 /*
  * Return the mem_map entry representing the 'offset' subpage within
--- thpfs.orig/mm/mlock.c	2014-12-07 14:21:05.000000000 -0800
+++ thpfs/mm/mlock.c	2015-02-20 19:35:09.991858941 -0800
@@ -11,6 +11,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/pagemap.h>
+#include <linux/pageteam.h>
 #include <linux/pagevec.h>
 #include <linux/mempolicy.h>
 #include <linux/syscalls.h>
@@ -51,40 +52,70 @@ EXPORT_SYMBOL(can_do_mlock);
  * (see mm/rmap.c).
  */
 
-/*
- *  LRU accounting for clear_page_mlock()
+/**
+ * clear_pages_mlock - clear mlock from a page or pages
+ * @page - page to be unlocked
+ * @nr_pages - usually 1, but HPAGE_PMD_NR if pmd mapping is zapped.
+ *
+ * Clear the page's PageMlocked().  This can be useful in a situation where
+ * we want to unconditionally remove a page from the pagecache -- e.g.,
+ * on truncation or freeing.
+ *
+ * It is legal to call this function for any page, mlocked or not.
+ * If called for a page that is still mapped by mlocked vmas, all we do
+ * is revert to lazy LRU behaviour -- semantics are not broken.
  */
-void clear_page_mlock(struct page *page)
+void clear_pages_mlock(struct page *page, int nr_pages)
 {
-	if (!TestClearPageMlocked(page))
-		return;
+	struct zone *zone = page_zone(page);
+	struct page *endpage = page + 1;
 
-	mod_zone_page_state(page_zone(page), NR_MLOCK,
-			    -hpage_nr_pages(page));
-	count_vm_event(UNEVICTABLE_PGCLEARED);
-	if (!isolate_lru_page(page)) {
-		putback_lru_page(page);
-	} else {
-		/*
-		 * We lost the race. the page already moved to evictable list.
-		 */
-		if (PageUnevictable(page))
+	if (nr_pages > 1 && PageTeam(page) && !PageAnon(page)) {
+		clear_hugely_mlocked(page);	/* page is team head */
+		endpage = page + nr_pages;
+		nr_pages = 1;
+	}
+
+	for (; page < endpage; page++) {
+		if (page_mapped(page))
+			continue;
+		if (!TestClearPageMlocked(page))
+			continue;
+		mod_zone_page_state(zone, NR_MLOCK, -nr_pages);
+		count_vm_event(UNEVICTABLE_PGCLEARED);
+		if (!isolate_lru_page(page))
+			putback_lru_page(page);
+		else if (PageUnevictable(page))
 			count_vm_event(UNEVICTABLE_PGSTRANDED);
 	}
 }
 
-/*
- * Mark page as mlocked if not already.
+/**
+ * mlock_vma_pages - mlock a vma page or pages
+ * @page - page to be unlocked
+ * @nr_pages - usually 1, but HPAGE_PMD_NR if pmd mapping is mlocked.
+ *
+ * Mark pages as mlocked if not already.
  * If page on LRU, isolate and putback to move to unevictable list.
  */
-void mlock_vma_page(struct page *page)
+void mlock_vma_pages(struct page *page, int nr_pages)
 {
+	struct zone *zone = page_zone(page);
+	struct page *endpage = page + 1;
+
 	/* Serialize with page migration */
-	BUG_ON(!PageLocked(page));
+	VM_BUG_ON_PAGE(!PageLocked(page) && !PageTeam(page), page);
+
+	if (nr_pages > 1 && PageTeam(page) && !PageAnon(page)) {
+		set_hugely_mlocked(page);	/* page is team head */
+		endpage = page + nr_pages;
+		nr_pages = 1;
+	}
 
-	if (!TestSetPageMlocked(page)) {
-		mod_zone_page_state(page_zone(page), NR_MLOCK,
-				    hpage_nr_pages(page));
+	for (; page < endpage; page++) {
+		if (TestSetPageMlocked(page))
+			continue;
+		mod_zone_page_state(zone, NR_MLOCK, nr_pages);
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 		if (!isolate_lru_page(page))
 			putback_lru_page(page);
@@ -108,6 +139,18 @@ static bool __munlock_isolate_lru_page(s
 		return true;
 	}
 
+	/*
+	 * Perform accounting when page isolation fails in munlock.
+	 * There is nothing else to do because it means some other task has
+	 * already removed the page from the LRU. putback_lru_page() will take
+	 * care of removing the page from the unevictable list, if necessary.
+	 * vmscan [page_referenced()] will move the page back to the
+	 * unevictable list if some other vma has it mlocked.
+	 */
+	if (PageUnevictable(page))
+		__count_vm_event(UNEVICTABLE_PGSTRANDED);
+	else
+		__count_vm_event(UNEVICTABLE_PGMUNLOCKED);
 	return false;
 }
 
@@ -125,7 +168,7 @@ static void __munlock_isolated_page(stru
 	 * Optimization: if the page was mapped just once, that's our mapping
 	 * and we don't need to check all the other vmas.
 	 */
-	if (page_mapcount(page) > 1)
+	if (page_mapcount(page) > 1 || PageTeam(page))
 		ret = try_to_munlock(page);
 
 	/* Did try_to_unlock() succeed or punt? */
@@ -135,29 +178,12 @@ static void __munlock_isolated_page(stru
 	putback_lru_page(page);
 }
 
-/*
- * Accounting for page isolation fail during munlock
- *
- * Performs accounting when page isolation fails in munlock. There is nothing
- * else to do because it means some other task has already removed the page
- * from the LRU. putback_lru_page() will take care of removing the page from
- * the unevictable list, if necessary. vmscan [page_referenced()] will move
- * the page back to the unevictable list if some other vma has it mlocked.
- */
-static void __munlock_isolation_failed(struct page *page)
-{
-	if (PageUnevictable(page))
-		__count_vm_event(UNEVICTABLE_PGSTRANDED);
-	else
-		__count_vm_event(UNEVICTABLE_PGMUNLOCKED);
-}
-
 /**
- * munlock_vma_page - munlock a vma page
- * @page - page to be unlocked, either a normal page or THP page head
+ * munlock_vma_pages - munlock a vma page or pages
+ * @page - page to be unlocked
+ * @nr_pages - usually 1, but HPAGE_PMD_NR if pmd mapping is munlocked
  *
- * returns the size of the page as a page mask (0 for normal page,
- *         HPAGE_PMD_NR - 1 for THP head page)
+ * returns the size of the page (usually 1, but HPAGE_PMD_NR for huge page)
  *
  * called from munlock()/munmap() path with page supposedly on the LRU.
  * When we munlock a page, because the vma where we found the page is being
@@ -170,39 +196,55 @@ static void __munlock_isolation_failed(s
  * can't isolate the page, we leave it for putback_lru_page() and vmscan
  * [page_referenced()/try_to_unmap()] to deal with.
  */
-unsigned int munlock_vma_page(struct page *page)
+int munlock_vma_pages(struct page *page, int nr_pages)
 {
-	unsigned int nr_pages;
 	struct zone *zone = page_zone(page);
+	struct page *endpage = page + 1;
+	struct page *head = NULL;
+	int ret = nr_pages;
+	bool isolated;
 
 	/* For try_to_munlock() and to serialize with page migration */
-	BUG_ON(!PageLocked(page));
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+
+	if (nr_pages > 1 && PageTeam(page) && !PageAnon(page)) {
+		head = page;
+		clear_hugely_mlocked(page);	/* page is team head */
+		endpage = page + nr_pages;
+		nr_pages = 1;
+	}
 
 	/*
-	 * Serialize with any parallel __split_huge_page_refcount() which
-	 * might otherwise copy PageMlocked to part of the tail pages before
+	 * Serialize THP with any parallel __split_huge_page_refcount() which
+	 * might otherwise copy PageMlocked to some of the tail pages before
 	 * we clear it in the head page. It also stabilizes hpage_nr_pages().
 	 */
 	spin_lock_irq(&zone->lru_lock);
+	if (PageAnon(page))
+		ret = nr_pages = hpage_nr_pages(page);
 
-	nr_pages = hpage_nr_pages(page);
-	if (!TestClearPageMlocked(page))
-		goto unlock_out;
-
-	__mod_zone_page_state(zone, NR_MLOCK, -nr_pages);
+	for (; page < endpage; page++) {
+		if (!TestClearPageMlocked(page))
+			continue;
 
-	if (__munlock_isolate_lru_page(page, true)) {
+		__mod_zone_page_state(zone, NR_MLOCK, -nr_pages);
+		isolated = __munlock_isolate_lru_page(page, true);
 		spin_unlock_irq(&zone->lru_lock);
-		__munlock_isolated_page(page);
-		goto out;
-	}
-	__munlock_isolation_failed(page);
+		if (isolated)
+			__munlock_isolated_page(page);
 
-unlock_out:
+		/*
+		 * If try_to_munlock() found the huge page to be still
+		 * mlocked, don't waste more time munlocking and rmap
+		 * walking and re-mlocking each of the team's pages.
+		 */
+		if (!head || team_hugely_mlocked(head))
+			goto out;
+		spin_lock_irq(&zone->lru_lock);
+	}
 	spin_unlock_irq(&zone->lru_lock);
-
 out:
-	return nr_pages - 1;
+	return ret;
 }
 
 /**
@@ -351,8 +393,6 @@ static void __munlock_pagevec(struct pag
 			 */
 			if (__munlock_isolate_lru_page(page, false))
 				continue;
-			else
-				__munlock_isolation_failed(page);
 		}
 
 		/*
@@ -500,15 +540,18 @@ void munlock_vma_pages_range(struct vm_a
 				&page_mask);
 
 		if (page && !IS_ERR(page)) {
-			if (PageTransHuge(page)) {
+			if (PageTransHuge(page) || PageTeam(page)) {
 				lock_page(page);
 				/*
 				 * Any THP page found by follow_page_mask() may
-				 * have gotten split before reaching
-				 * munlock_vma_page(), so we need to recompute
-				 * the page_mask here.
+				 * be split before reaching munlock_vma_pages()
+				 * so we need to recompute the page_mask here.
 				 */
-				page_mask = munlock_vma_page(page);
+				if (page_mask &&
+				    !PageTeam(page) && !PageHead(page))
+					page_mask = 0;
+				page_mask = munlock_vma_pages(page,
+							page_mask + 1) - 1;
 				unlock_page(page);
 				put_page(page); /* follow_page_mask() */
 			} else {
--- thpfs.orig/mm/rmap.c	2015-02-20 19:34:37.851932430 -0800
+++ thpfs/mm/rmap.c	2015-02-20 19:35:09.995858933 -0800
@@ -1161,6 +1161,8 @@ out:
  */
 void page_remove_rmap(struct page *page)
 {
+	int nr_pages;
+
 	if (!PageAnon(page)) {
 		page_remove_file_rmap(page);
 		return;
@@ -1179,14 +1181,16 @@ void page_remove_rmap(struct page *page)
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	if (PageTransHuge(page))
+	nr_pages = 1;
+	if (PageTransHuge(page)) {
 		__dec_zone_page_state(page, NR_ANON_HUGEPAGES);
+		nr_pages = hpage_nr_pages(page);
+	}
 
-	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
-			      -hpage_nr_pages(page));
+	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr_pages);
 
 	if (unlikely(PageMlocked(page)))
-		clear_page_mlock(page);
+		clear_pages_mlock(page, nr_pages);
 
 	/*
 	 * It would be tidy to reset the PageAnon mapping here,
@@ -1214,6 +1218,7 @@ static int try_to_unmap_one(struct page
 	pte_t pteval;
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
+	int mlock_pages = 1;
 	enum ttu_flags flags = (enum ttu_flags)arg;
 
 	if (unlikely(PageHuge(page))) {
@@ -1241,8 +1246,13 @@ again:
 		return ret;
 
 	if (pmd_trans_huge(pmdval)) {
-		if (pmd_page(pmdval) != page)
-			return ret;
+		if (pmd_page(pmdval) != page) {
+			if (!PageTeam(page) || !(flags & TTU_MUNLOCK))
+				return ret;
+			page = team_head(page);
+			if (pmd_page(pmdval) != page)
+				return ret;
+		}
 
 		ptl = pmd_lock(mm, pmd);
 		if (!pmd_same(*pmd, pmdval)) {
@@ -1251,8 +1261,10 @@ again:
 		}
 
 		if (!(flags & TTU_IGNORE_MLOCK)) {
-			if (vma->vm_flags & VM_LOCKED)
+			if (vma->vm_flags & VM_LOCKED) {
+				mlock_pages = HPAGE_PMD_NR;
 				goto out_mlock;
+			}
 			if (flags & TTU_MUNLOCK)
 				goto out_unmap;
 		}
@@ -1403,7 +1415,7 @@ out_mlock:
 	 */
 	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
 		if (vma->vm_flags & VM_LOCKED) {
-			mlock_vma_page(page);
+			mlock_vma_pages(page, mlock_pages);
 			ret = SWAP_MLOCK;
 		}
 		up_read(&vma->vm_mm->mmap_sem);
@@ -1706,7 +1718,6 @@ int try_to_munlock(struct page *page)
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
 		.arg = (void *)TTU_MUNLOCK,
-		.done = page_not_mapped,
 		/*
 		 * We don't bother to try to find the munlocked page in
 		 * nonlinears. It's costly. Instead, later, page reclaim logic
@@ -1717,7 +1728,8 @@ int try_to_munlock(struct page *page)
 
 	};
 
-	VM_BUG_ON_PAGE(!PageLocked(page) || PageLRU(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(page) && !PageTeam(page), page);
+	VM_BUG_ON_PAGE(PageLRU(page), page);
 
 	ret = rmap_walk(page, &rwc);
 	return ret;
@@ -1823,7 +1835,7 @@ static int rmap_walk_file(struct page *p
 	 * structure at mapping cannot be freed and reused yet,
 	 * so we can safely take mapping->i_mmap_rwsem.
 	 */
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(page) && !PageTeam(page), page);
 
 	if (!mapping)
 		return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
