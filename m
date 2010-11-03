Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D937A8D0017
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:34 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 63 of 66] fix anon memory statistics with transparent hugepages
Message-Id: <63f97c307774c2f2ec4b.1288798118@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:38 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Rik van Riel <riel@redhat.com>

Count each transparent hugepage as HPAGE_PMD_NR pages in the LRU
statistics, so the Active(anon) and Inactive(anon) statistics in
/proc/meminfo are correct.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -128,11 +128,19 @@ static inline int PageTransCompound(stru
 {
 	return PageCompound(page);
 }
+static inline int hpage_nr_pages(struct page *page)
+{
+	if (unlikely(PageTransHuge(page)))
+		return HPAGE_PMD_NR;
+	return 1;
+}
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUG(); 0; })
 #define HPAGE_PMD_SIZE ({ BUG(); 0; })
 
+#define hpage_nr_pages(x) 1
+
 #define transparent_hugepage_enabled(__vma) 0
 
 #define transparent_hugepage_flags 0UL
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -1,6 +1,8 @@
 #ifndef LINUX_MM_INLINE_H
 #define LINUX_MM_INLINE_H
 
+#include <linux/huge_mm.h>
+
 /**
  * page_is_file_cache - should the page be on a file LRU or anon LRU?
  * @page: the page to test
@@ -24,7 +26,7 @@ __add_page_to_lru_list(struct zone *zone
 		       struct list_head *head)
 {
 	list_add(&page->lru, head);
-	__inc_zone_state(zone, NR_LRU_BASE + l);
+	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
 	mem_cgroup_add_lru_list(page, l);
 }
 
@@ -38,7 +40,7 @@ static inline void
 del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
 	list_del(&page->lru);
-	__dec_zone_state(zone, NR_LRU_BASE + l);
+	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
 	mem_cgroup_del_lru_list(page, l);
 }
 
@@ -73,7 +75,7 @@ del_page_from_lru(struct zone *zone, str
 			l += LRU_ACTIVE;
 		}
 	}
-	__dec_zone_state(zone, NR_LRU_BASE + l);
+	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
 	mem_cgroup_del_lru_list(page, l);
 }
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1139,6 +1139,7 @@ static void __split_huge_page_refcount(s
 	int i;
 	unsigned long head_index = page->index;
 	struct zone *zone = page_zone(page);
+	int zonestat;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
@@ -1203,6 +1204,15 @@ static void __split_huge_page_refcount(s
 	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
 
+	/*
+	 * A hugepage counts for HPAGE_PMD_NR pages on the LRU statistics,
+	 * so adjust those appropriately if this page is on the LRU.
+	 */
+	if (PageLRU(page)) {
+		zonestat = NR_LRU_BASE + page_lru(page);
+		__mod_zone_page_state(zone, zonestat, -(HPAGE_PMD_NR-1));
+	}
+
 	ClearPageCompound(page);
 	compound_unlock(page);
 	spin_unlock_irq(&zone->lru_lock);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1083,7 +1083,7 @@ unsigned long mem_cgroup_isolate_pages(u
 		case 0:
 			list_move(&page->lru, dst);
 			mem_cgroup_del_lru(page);
-			nr_taken++;
+			nr_taken += hpage_nr_pages(page);
 			break;
 		case -EBUSY:
 			/* we don't affect global LRU but rotate in our LRU */
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1028,7 +1028,7 @@ static unsigned long isolate_lru_pages(u
 		case 0:
 			list_move(&page->lru, dst);
 			mem_cgroup_del_lru(page);
-			nr_taken++;
+			nr_taken += hpage_nr_pages(page);
 			break;
 
 		case -EBUSY:
@@ -1086,7 +1086,7 @@ static unsigned long isolate_lru_pages(u
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				list_move(&cursor_page->lru, dst);
 				mem_cgroup_del_lru(cursor_page);
-				nr_taken++;
+				nr_taken += hpage_nr_pages(page);
 				nr_lumpy_taken++;
 				if (PageDirty(cursor_page))
 					nr_lumpy_dirty++;
@@ -1141,14 +1141,15 @@ static unsigned long clear_active_flags(
 	struct page *page;
 
 	list_for_each_entry(page, page_list, lru) {
+		int numpages = hpage_nr_pages(page);
 		lru = page_lru_base_type(page);
 		if (PageActive(page)) {
 			lru += LRU_ACTIVE;
 			ClearPageActive(page);
-			nr_active++;
+			nr_active += numpages;
 		}
 		if (count)
-			count[lru]++;
+			count[lru] += numpages;
 	}
 
 	return nr_active;
@@ -1466,7 +1467,7 @@ static void move_active_pages_to_lru(str
 
 		list_move(&page->lru, &zone->lru[lru].list);
 		mem_cgroup_add_lru_list(page, lru);
-		pgmoved++;
+		pgmoved += hpage_nr_pages(page);
 
 		if (!pagevec_add(&pvec, page) || list_empty(list)) {
 			spin_unlock_irq(&zone->lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
