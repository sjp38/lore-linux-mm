Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52DDF6B0324
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 22:12:45 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so126881941pgc.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 19:12:45 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 23si29455179pgb.38.2016.11.15.19.12.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 19:12:44 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v5 9/9] mm, THP, swap: Delay splitting THP during swap out
Date: Wed, 16 Nov 2016 11:10:57 +0800
Message-Id: <20161116031057.12977-10-ying.huang@intel.com>
In-Reply-To: <20161116031057.12977-1-ying.huang@intel.com>
References: <20161116031057.12977-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>

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

With the patchset, the swap out throughput improved 12.1% (from 1.12GB/s
to 1.25GB/s) in the vm-scalability swap-w-seq test case with 16
processes.  The test is done on a Xeon E5 v3 system.  The RAM simulated
PMEM (persistent memory) device is used as the swap device.  To test
sequential swapping out, the test case uses 16 processes sequentially
allocate and write to the anonymous pages until the RAM and part of the
swap device is used up.

The detailed compare result is as follow,

base             base+patchset
---------------- --------------------------
         %stddev     %change         %stddev
             \          |                \
   1118821 A+-  0%     +12.1%    1254241 A+-  1%  vmstat.swap.so
   2460636 A+-  1%     +10.6%    2720983 A+-  1%  vm-scalability.throughput
    308.79 A+-  1%      -7.9%     284.53 A+-  1%  vm-scalability.time.elapsed_time
      1639 A+-  4%    +232.3%       5446 A+-  1%  meminfo.SwapCached
      0.70 A+-  3%      +8.7%       0.77 A+-  5%  perf-stat.ipc
      9.82 A+-  8%     -31.6%       6.72 A+-  2%  perf-profile.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/swap_state.c | 65 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 62 insertions(+), 3 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 13fb1c5..2db8359 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -17,6 +17,7 @@
 #include <linux/blkdev.h>
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
+#include <linux/huge_mm.h>
 
 #include <asm/pgtable.h>
 
@@ -173,12 +174,53 @@ void __delete_from_swap_cache(struct page *page)
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
@@ -188,6 +230,18 @@ int add_to_swap(struct page *page, struct list_head *list)
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
@@ -305,7 +359,7 @@ struct page * lookup_swap_cache(swp_entry_t entry)
 
 	page = find_get_page(swap_address_space(entry), swp_offset(entry));
 
-	if (page) {
+	if (page && likely(!PageTransCompound(page))) {
 		INC_CACHE_INFO(find_success);
 		if (TestClearPageReadahead(page))
 			atomic_inc(&swapin_readahead_hits);
@@ -331,8 +385,13 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * that would confuse statistics.
 		 */
 		found_page = find_get_page(swapper_space, swp_offset(entry));
-		if (found_page)
+		if (found_page) {
+			if (unlikely(PageTransCompound(found_page))) {
+				put_page(found_page);
+				found_page = NULL;
+			}
 			break;
+		}
 
 		/*
 		 * Get a new page to read into from swap.
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
