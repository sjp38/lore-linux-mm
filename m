Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 7AE146B003B
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 17:35:14 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 7/8] memory-hotplug: enable memory hotplug to handle hugepage
Date: Thu, 18 Jul 2013 17:34:31 -0400
Message-Id: <1374183272-10153-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Until now we can't offline memory blocks which contain hugepages because
a hugepage is considered as an unmovable page. But now with this patch
series, a hugepage has become movable, so by using hugepage migration we
can offline such memory blocks.

What's different from other users of hugepage migration is that we need
to decompose all the hugepages inside the target memory block into free
buddy pages after hugepage migration, because otherwise free hugepages
remaining in the memory block intervene the memory offlining.
For this reason we introduce new functions dissolve_free_huge_page() and
dissolve_free_huge_pages().

Other than that, what this patch does is straightforwardly to add hugepage
migration code, that is, adding hugepage code to the functions which scan
over pfn and collect hugepages to be migrated, and adding a hugepage
allocation function to alloc_migrate_target().

As for larger hugepages (1GB for x86_64), it's not easy to do hotremove
over them because it's larger than memory block. So we now simply leave
it to fail as it is.

ChangeLog v3:
 - revert introducing migrate_movable_pages (the function was opened)
 - add migratetype check in dequeue_huge_page_node to close the race
   between scan and allocation
 - make is_hugepage_movable use refcount to find active hugepages
   instead of running through hugepage_activelist
 - rename is_hugepage_movable to is_hugepage_active
 - add alignment check in dissolve_free_huge_pages
 - use round_up in calculating next scanning pfn
 - use isolate_huge_page

ChangeLog v2:
 - changed return value type of is_hugepage_movable() to bool
 - is_hugepage_movable() uses list_for_each_entry() instead of *_safe()
 - moved if(PageHuge) block before get_page_unless_zero() in do_migrate_range()
 - do_migrate_range() returns -EBUSY for hugepages larger than memory block
 - dissolve_free_huge_pages() calculates scan step and sets it to minimum
   hugepage size

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h |  6 +++++
 mm/hugetlb.c            | 67 +++++++++++++++++++++++++++++++++++++++++++++++--
 mm/memory_hotplug.c     | 42 +++++++++++++++++++++++++------
 mm/page_alloc.c         | 12 +++++++++
 mm/page_isolation.c     |  5 ++++
 5 files changed, 123 insertions(+), 9 deletions(-)

diff --git v3.11-rc1.orig/include/linux/hugetlb.h v3.11-rc1/include/linux/hugetlb.h
index 768ebbe..bb7651e 100644
--- v3.11-rc1.orig/include/linux/hugetlb.h
+++ v3.11-rc1/include/linux/hugetlb.h
@@ -69,6 +69,7 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
 bool isolate_huge_page(struct page *page, struct list_head *l);
 void putback_active_hugepage(struct page *page);
 void putback_active_hugepages(struct list_head *l);
+bool is_hugepage_active(struct page *page);
 void copy_huge_page(struct page *dst, struct page *src);
 
 #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
@@ -140,6 +141,7 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
 #define isolate_huge_page(p, l) false
 #define putback_active_hugepage(p)
 #define putback_active_hugepages(l)
+#define is_hugepage_active(x) false
 static inline void copy_huge_page(struct page *dst, struct page *src)
 {
 }
@@ -379,6 +381,9 @@ static inline pgoff_t basepage_index(struct page *page)
 	return __basepage_index(page);
 }
 
+extern void dissolve_free_huge_pages(unsigned long start_pfn,
+				     unsigned long end_pfn);
+
 #else	/* CONFIG_HUGETLB_PAGE */
 struct hstate {};
 #define alloc_huge_page_node(h, nid) NULL
@@ -405,6 +410,7 @@ static inline pgoff_t basepage_index(struct page *page)
 {
 	return page->index;
 }
+#define dissolve_free_huge_pages(s, e)
 #endif	/* CONFIG_HUGETLB_PAGE */
 
 #endif /* _LINUX_HUGETLB_H */
diff --git v3.11-rc1.orig/mm/hugetlb.c v3.11-rc1/mm/hugetlb.c
index fab29a1..9575e8a 100644
--- v3.11-rc1.orig/mm/hugetlb.c
+++ v3.11-rc1/mm/hugetlb.c
@@ -21,6 +21,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/page-isolation.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -518,9 +519,11 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
 
-	if (list_empty(&h->hugepage_freelists[nid]))
+	list_for_each_entry(page, &h->hugepage_freelists[nid], lru)
+		if (!is_migrate_isolate_page(page))
+			break;
+	if (&h->hugepage_freelists[nid] == &page->lru)
 		return NULL;
-	page = list_entry(h->hugepage_freelists[nid].next, struct page, lru);
 	list_move(&page->lru, &h->hugepage_activelist);
 	set_page_refcounted(page);
 	h->free_huge_pages--;
@@ -861,6 +864,44 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 	return ret;
 }
 
+/*
+ * Dissolve a given free hugepage into free buddy pages. This function does
+ * nothing for in-use (including surplus) hugepages.
+ */
+static void dissolve_free_huge_page(struct page *page)
+{
+	spin_lock(&hugetlb_lock);
+	if (PageHuge(page) && !page_count(page)) {
+		struct hstate *h = page_hstate(page);
+		int nid = page_to_nid(page);
+		list_del(&page->lru);
+		h->free_huge_pages--;
+		h->free_huge_pages_node[nid]--;
+		update_and_free_page(h, page);
+	}
+	spin_unlock(&hugetlb_lock);
+}
+
+/*
+ * Dissolve free hugepages in a given pfn range. Used by memory hotplug to
+ * make specified memory blocks removable from the system.
+ * Note that start_pfn should aligned with (minimum) hugepage size.
+ */
+void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned int order = 8 * sizeof(void *);
+	unsigned long pfn;
+	struct hstate *h;
+
+	/* Set scan step to minimum hugepage size */
+	for_each_hstate(h)
+		if (order > huge_page_order(h))
+			order = huge_page_order(h);
+	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
+	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
+		dissolve_free_huge_page(pfn_to_page(pfn));
+}
+
 static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 {
 	struct page *page;
@@ -3418,6 +3459,28 @@ static int is_hugepage_on_freelist(struct page *hpage)
 	return 0;
 }
 
+bool is_hugepage_active(struct page *page)
+{
+	VM_BUG_ON(!PageHuge(page));
+	/*
+	 * This function can be called for a tail page because the caller,
+	 * scan_movable_pages, scans through a given pfn-range which typically
+	 * covers one memory block. In systems using gigantic hugepage (1GB
+	 * for x86_64,) a hugepage is larger than a memory block, and we don't
+	 * support migrating such large hugepages for now, so return false
+	 * when called for tail pages.
+	 */
+	if (PageTail(page))
+		return false;
+	/*
+	 * Refcount of a hwpoisoned hugepages is 1, but they are not active,
+	 * so we should return false for them.
+	 */
+	if (unlikely(PageHWPoison(page)))
+		return false;
+	return page_count(page) > 0;
+}
+
 /*
  * This function is called from memory failure code.
  * Assume the caller holds page lock of the head page.
diff --git v3.11-rc1.orig/mm/memory_hotplug.c v3.11-rc1/mm/memory_hotplug.c
index ca1dd3a..31f08fa 100644
--- v3.11-rc1.orig/mm/memory_hotplug.c
+++ v3.11-rc1/mm/memory_hotplug.c
@@ -30,6 +30,7 @@
 #include <linux/mm_inline.h>
 #include <linux/firmware-map.h>
 #include <linux/stop_machine.h>
+#include <linux/hugetlb.h>
 
 #include <asm/tlbflush.h>
 
@@ -1208,10 +1209,12 @@ static int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
 }
 
 /*
- * Scanning pfn is much easier than scanning lru list.
- * Scan pfn from start to end and Find LRU page.
+ * Scan pfn range [start,end) to find movable/migratable pages (LRU pages
+ * and hugepages). We scan pfn because it's much easier than scanning over
+ * linked list. This function returns the pfn of the first found movable
+ * page if it's found, otherwise 0.
  */
-static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
+static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 {
 	unsigned long pfn;
 	struct page *page;
@@ -1220,6 +1223,13 @@ static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
 			page = pfn_to_page(pfn);
 			if (PageLRU(page))
 				return pfn;
+			if (PageHuge(page)) {
+				if (is_hugepage_active(page))
+					return pfn;
+				else
+					pfn = round_up(pfn + 1,
+						1 << compound_order(page)) - 1;
+			}
 		}
 	}
 	return 0;
@@ -1240,6 +1250,19 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
+
+		if (PageHuge(page)) {
+			struct page *head = compound_head(page);
+			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
+			if (compound_order(head) > PFN_SECTION_SHIFT) {
+				ret = -EBUSY;
+				break;
+			}
+			if (isolate_huge_page(page, &source))
+				move_pages -= 1 << compound_order(head);
+			continue;
+		}
+
 		if (!get_page_unless_zero(page))
 			continue;
 		/*
@@ -1272,7 +1295,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 	}
 	if (!list_empty(&source)) {
 		if (not_managed) {
-			putback_lru_pages(&source);
+			putback_movable_pages(&source);
 			goto out;
 		}
 
@@ -1283,7 +1306,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		ret = migrate_pages(&source, alloc_migrate_target, 0,
 					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
 		if (ret)
-			putback_lru_pages(&source);
+			putback_movable_pages(&source);
 	}
 out:
 	return ret;
@@ -1527,8 +1550,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		drain_all_pages();
 	}
 
-	pfn = scan_lru_pages(start_pfn, end_pfn);
-	if (pfn) { /* We have page on LRU */
+	pfn = scan_movable_pages(start_pfn, end_pfn);
+	if (pfn) { /* We have movable pages */
 		ret = do_migrate_range(pfn, end_pfn);
 		if (!ret) {
 			drain = 1;
@@ -1547,6 +1570,11 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	yield();
 	/* drain pcp pages, this is synchronous. */
 	drain_all_pages();
+	/*
+	 * dissolve free hugepages in the memory block before doing offlining
+	 * actually in order to make hugetlbfs's object counting consistent.
+	 */
+	dissolve_free_huge_pages(start_pfn, end_pfn);
 	/* check again */
 	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
 	if (offlined_pages < 0) {
diff --git v3.11-rc1.orig/mm/page_alloc.c v3.11-rc1/mm/page_alloc.c
index b100255..24fe228 100644
--- v3.11-rc1.orig/mm/page_alloc.c
+++ v3.11-rc1/mm/page_alloc.c
@@ -60,6 +60,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
+#include <linux/hugetlb.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -5928,6 +5929,17 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 			continue;
 
 		page = pfn_to_page(check);
+
+		/*
+		 * Hugepages are not in LRU lists, but they're movable.
+		 * We need not scan over tail pages bacause we don't
+		 * handle each tail page individually in migration.
+		 */
+		if (PageHuge(page)) {
+			iter = round_up(iter + 1, 1<<compound_order(page)) - 1;
+			continue;
+		}
+
 		/*
 		 * We can't use page_count without pin a page
 		 * because another CPU can free compound page.
diff --git v3.11-rc1.orig/mm/page_isolation.c v3.11-rc1/mm/page_isolation.c
index 383bdbb..cf48ef6 100644
--- v3.11-rc1.orig/mm/page_isolation.c
+++ v3.11-rc1/mm/page_isolation.c
@@ -6,6 +6,7 @@
 #include <linux/page-isolation.h>
 #include <linux/pageblock-flags.h>
 #include <linux/memory.h>
+#include <linux/hugetlb.h>
 #include "internal.h"
 
 int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
@@ -252,6 +253,10 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
 {
 	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
 
+	if (PageHuge(page))
+		return alloc_huge_page_node(page_hstate(compound_head(page)),
+					    numa_node_id());
+
 	if (PageHighMem(page))
 		gfp_mask |= __GFP_HIGHMEM;
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
