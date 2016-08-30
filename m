Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15F9F6B025E
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 13:28:38 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so49213567pab.1
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 10:28:38 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id wv6si46048454pab.263.2016.08.30.10.28.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Aug 2016 10:28:36 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v2] mm: Don't use radix tree writeback tags for pages in swap cache
Date: Tue, 30 Aug 2016 10:28:09 -0700
Message-Id: <1472578089-5560-1-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

From: Huang Ying <ying.huang@intel.com>

File pages use a set of radix tree tags (DIRTY, TOWRITE, WRITEBACK,
etc.) to accelerate finding the pages with a specific tag in the radix
tree during inode writeback.  But for anonymous pages in the swap
cache, there is no inode writeback.  So there is no need to find the
pages with some writeback tags in the radix tree.  It is not necessary
to touch radix tree writeback tags for pages in the swap cache.

Per Rik van Riel's suggestion, a new flag AS_NO_WRITEBACK_TAGS is
introduced for address spaces which don't need to update the writeback
tags.  The flag is set for swap caches.  It may be used for DAX file
systems, etc.

With this patch, the swap out bandwidth improved 22.3% (from ~1.2GB/s to
~ 1.48GBps) in the vm-scalability swap-w-seq test case with 8 processes.
The test is done on a Xeon E5 v3 system.  The swap device used is a RAM
simulated PMEM (persistent memory) device.  The improvement comes from
the reduced contention on the swap cache radix tree lock.  To test
sequential swapping out, the test case uses 8 processes, which
sequentially allocate and write to the anonymous pages until RAM and
part of the swap device is used up.

Details of comparison is as follow,

base             base+patch
---------------- --------------------------
         %stddev     %change         %stddev
             \          |                \
   2506952 A+-  2%     +28.1%    3212076 A+-  7%  vm-scalability.throughput
   1207402 A+-  7%     +22.3%    1476578 A+-  6%  vmstat.swap.so
     10.86 A+- 12%     -23.4%       8.31 A+- 16%  perf-profile.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list
     10.82 A+- 13%     -33.1%       7.24 A+- 14%  perf-profile.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_zone_memcg
     10.36 A+- 11%    -100.0%       0.00 A+- -1%  perf-profile.cycles-pp._raw_spin_lock_irqsave.__test_set_page_writeback.bdev_write_page.__swap_writepage.swap_writepage
     10.52 A+- 12%    -100.0%       0.00 A+- -1%  perf-profile.cycles-pp._raw_spin_lock_irqsave.test_clear_page_writeback.end_page_writeback.page_endio.pmem_rw_page

Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Tejun Heo <tj@kernel.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/pagemap.h | 12 ++++++++++++
 mm/page-writeback.c     |  4 ++--
 mm/swap_state.c         |  2 ++
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 66a1260..2f5a65dd 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -25,6 +25,8 @@ enum mapping_flags {
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
 	AS_EXITING	= __GFP_BITS_SHIFT + 4, /* final truncate in progress */
+	/* writeback related tags are not used */
+	AS_NO_WRITEBACK_TAGS = __GFP_BITS_SHIFT + 5,
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -64,6 +66,16 @@ static inline int mapping_exiting(struct address_space *mapping)
 	return test_bit(AS_EXITING, &mapping->flags);
 }
 
+static inline void mapping_set_no_writeback_tags(struct address_space *mapping)
+{
+	set_bit(AS_NO_WRITEBACK_TAGS, &mapping->flags);
+}
+
+static inline int mapping_use_writeback_tags(struct address_space *mapping)
+{
+	return !test_bit(AS_NO_WRITEBACK_TAGS, &mapping->flags);
+}
+
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
 	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 82e7252..67b7c8b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2728,7 +2728,7 @@ int test_clear_page_writeback(struct page *page)
 	int ret;
 
 	lock_page_memcg(page);
-	if (mapping) {
+	if (mapping && mapping_use_writeback_tags(mapping)) {
 		struct inode *inode = mapping->host;
 		struct backing_dev_info *bdi = inode_to_bdi(inode);
 		unsigned long flags;
@@ -2771,7 +2771,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 	int ret;
 
 	lock_page_memcg(page);
-	if (mapping) {
+	if (mapping && mapping_use_writeback_tags(mapping)) {
 		struct inode *inode = mapping->host;
 		struct backing_dev_info *bdi = inode_to_bdi(inode);
 		unsigned long flags;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index c8310a3..268b819 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -37,6 +37,8 @@ struct address_space swapper_spaces[MAX_SWAPFILES] = {
 		.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
 		.i_mmap_writable = ATOMIC_INIT(0),
 		.a_ops		= &swap_aops,
+		/* swap cache doesn't use writeback related tags */
+		.flags		= 1 << AS_NO_WRITEBACK_TAGS,
 	}
 };
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
