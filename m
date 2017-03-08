Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F03D6B03B1
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 02:26:55 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id o126so44720967pfb.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 23:26:55 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y70si2425223plh.168.2017.03.07.23.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 23:26:54 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v6 9/9] mm, THP, swap: Delay splitting THP during swap out
Date: Wed,  8 Mar 2017 15:26:13 +0800
Message-Id: <20170308072613.17634-10-ying.huang@intel.com>
In-Reply-To: <20170308072613.17634-1-ying.huang@intel.com>
References: <20170308072613.17634-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>

From: Huang Ying <ying.huang@intel.com>

In this patch, splitting huge page is delayed from almost the first step
of swapping out to after allocating the swap space for the
THP (Transparent Huge Page) and adding the THP into the swap cache.
This will reduce lock acquiring/releasing for the locks used for the
swap cache management.

This is the first step for the THP swap support.  The plan is to delay
splitting the THP step by step and avoid splitting the THP finally.

The advantages of the THP swap support include:

- Batch the swap operations for the THP to reduce lock
  acquiring/releasing, including allocating/freeing the swap space,
  adding/deleting to/from the swap cache, and writing/reading the swap
  space, etc.  This will help to improve the THP swap performance.

- The THP swap space read/write will be 2M sequential IO.  It is
  particularly helpful for the swap read, which usually are 4k random
  IO.  This will help to improve the THP swap performance too.

- It will help the memory fragmentation, especially when the THP is
  heavily used by the applications.  The 2M continuous pages will be
  free up after the THP swapping out.

- It will improve the THP utilization on the system with the swap
  turned on.  Because the speed for khugepaged to collapse the normal
  pages into the THP is quite slow.  After the THP is split during the
  swapping out, it will take quite long time for the normal pages to
  collapse back into the THP after being swapped in.  The high THP
  utilization helps the efficiency of the page based memory management
  too.

There are some concerns regarding THP swap in, mainly because possible
enlarged read/write IO size (for swap in/out) may put more overhead on
the storage device.  To deal with that, the THP swap in should be
turned on only when necessary.  For example, it can be selected via
"always/never/madvise" logic, to be turned on globally, turned off
globally, or turned on only for VMA with MADV_HUGEPAGE, etc.

With the patchset, the swap out throughput improves 14.9% (from about
3.77GB/s to about 4.34GB/s) in the vm-scalability swap-w-seq test case
with 8 processes.  The test is done on a Xeon E5 v3 system.  The swap
device used is a RAM simulated PMEM (persistent memory) device.  To
test the sequential swapping out, the test case creates 8 processes,
which sequentially allocate and write to the anonymous pages until the
RAM and part of the swap device is used up.

The detailed comparison result is as follow,

base             base+patchset
---------------- --------------------------
         %stddev     %change         %stddev
             \          |                \
   7043990 A+-  0%     +21.2%    8536807 A+-  0%  vm-scalability.throughput
    109.94 A+-  1%     -16.2%      92.09 A+-  0%  vm-scalability.time.elapsed_time
   3957091 A+-  0%     +14.9%    4547173 A+-  0%  vmstat.swap.so
     31.46 A+-  1%     -38.3%      19.42 A+-  0%  perf-stat.cache-miss-rate%
      1.04 A+-  1%     +22.2%       1.27 A+-  0%  perf-stat.ipc
      9.33 A+-  2%     -60.7%       3.67 A+-  1%  perf-profile.calltrace.cycles-pp.add_to_swap.shrink_page_list.shrink_inactive_list.shrink_node_memcg.shrink_node

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/swap_state.c | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 57 insertions(+), 3 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 387466fd114b..12e7a461cf4c 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -19,6 +19,7 @@
 #include <linux/migrate.h>
 #include <linux/vmalloc.h>
 #include <linux/swap_slots.h>
+#include <linux/huge_mm.h>
 
 #include <asm/pgtable.h>
 
@@ -183,12 +184,53 @@ void __delete_from_swap_cache(struct page *page)
 	ADD_CACHE_INFO(del_total, nr);
 }
 
+#ifdef CONFIG_THP_SWAP_CLUSTER
+int add_to_swap_trans_huge(struct page *page, struct list_head *list)
+{
+	swp_entry_t entry;
+	int ret = 0;
+
+	/* cannot split, which may be needed during swap in, skip it */
+	if (!can_split_huge_page(page, NULL))
+		return -EBUSY;
+	/* fallback to split huge page firstly if no PMD map */
+	if (!compound_mapcount(page))
+		return 0;
+	entry = get_huge_swap_page();
+	if (!entry.val)
+		return 0;
+	if (mem_cgroup_try_charge_swap(page, entry, HPAGE_PMD_NR)) {
+		__swapcache_free(entry, true);
+		return -EOVERFLOW;
+	}
+	ret = add_to_swap_cache(page, entry,
+				__GFP_HIGH | __GFP_NOMEMALLOC|__GFP_NOWARN);
+	/* -ENOMEM radix-tree allocation failure */
+	if (ret) {
+		__swapcache_free(entry, true);
+		return 0;
+	}
+	ret = split_huge_page_to_list(page, list);
+	if (ret) {
+		delete_from_swap_cache(page);
+		return -EBUSY;
+	}
+	return 1;
+}
+#else
+static inline int add_to_swap_trans_huge(struct page *page,
+					 struct list_head *list)
+{
+	return 0;
+}
+#endif
+
 /**
  * add_to_swap - allocate swap space for a page
  * @page: page we want to move to swap
  *
  * Allocate swap space for the page and add the page to the
- * swap cache.  Caller needs to hold the page lock. 
+ * swap cache.  Caller needs to hold the page lock.
  */
 int add_to_swap(struct page *page, struct list_head *list)
 {
@@ -198,6 +240,18 @@ int add_to_swap(struct page *page, struct list_head *list)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageUptodate(page), page);
 
+	if (unlikely(PageTransHuge(page))) {
+		err = add_to_swap_trans_huge(page, list);
+		switch (err) {
+		case 1:
+			return 1;
+		case 0:
+			/* fallback to split firstly if return 0 */
+			break;
+		default:
+			return 0;
+		}
+	}
 	entry = get_swap_page();
 	if (!entry.val)
 		return 0;
@@ -315,7 +369,7 @@ struct page * lookup_swap_cache(swp_entry_t entry)
 
 	page = find_get_page(swap_address_space(entry), swp_offset(entry));
 
-	if (page) {
+	if (page && likely(!PageTransCompound(page))) {
 		INC_CACHE_INFO(find_success);
 		if (TestClearPageReadahead(page))
 			atomic_inc(&swapin_readahead_hits);
@@ -536,7 +590,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 						gfp_mask, vma, addr);
 		if (!page)
 			continue;
-		if (offset != entry_offset)
+		if (offset != entry_offset && likely(!PageTransCompound(page)))
 			SetPageReadahead(page);
 		put_page(page);
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
