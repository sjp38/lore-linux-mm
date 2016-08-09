Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id E48146B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:17:58 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so30083477pab.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:17:58 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id z88si43307400pff.218.2016.08.09.09.17.57
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 09:17:58 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [RFC] mm: Don't use radix tree writeback tags for pages in swap cache
Date: Tue,  9 Aug 2016 09:17:23 -0700
Message-Id: <1470759443-9229-1-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

From: Huang Ying <ying.huang@intel.com>

File pages uses a set of radix tags (DIRTY, TOWRITE, WRITEBACK) to
accelerate finding the pages with the specific tag in the the radix tree
during writing back an inode.  But for anonymous pages in swap cache,
there are no inode based writeback.  So there is no need to find the
pages with some writeback tags in the radix tree.  It is no necessary to
touch radix tree writeback tags for pages in swap cache.

With this patch, the swap out bandwidth improved 22.3% in vm-scalability
swap-w-seq test case with 8 processes on a Xeon E5 v3 system, because of
reduced contention on swap cache radix tree lock.  To test sequence swap
out, the test case uses 8 processes sequentially allocate and write to
anonymous pages until RAM and part of the swap device is used up.

Details of comparison is as follow,

            base base+patch
---------------- --------------------------
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
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/page-writeback.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f4cd7d8..ebfecb7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2758,7 +2758,7 @@ int test_clear_page_writeback(struct page *page)
 	int ret;
 
 	lock_page_memcg(page);
-	if (mapping) {
+	if (mapping && !PageSwapCache(page)) {
 		struct inode *inode = mapping->host;
 		struct backing_dev_info *bdi = inode_to_bdi(inode);
 		unsigned long flags;
@@ -2801,7 +2801,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 	int ret;
 
 	lock_page_memcg(page);
-	if (mapping) {
+	if (mapping && !PageSwapCache(page)) {
 		struct inode *inode = mapping->host;
 		struct backing_dev_info *bdi = inode_to_bdi(inode);
 		unsigned long flags;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
