Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 31D5A83093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 15:27:41 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vd14so92789483pab.3
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 12:27:41 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t14si16860443pfk.155.2016.08.25.12.27.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 12:27:40 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH] mm: Don't use radix tree writeback tags for pages in swap cache
Date: Thu, 25 Aug 2016 12:27:10 -0700
Message-Id: <1472153230-14766-1-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, "Huang, Ying" <ying.huang@intel.com>

File pages use a set of radix tags (DIRTY, TOWRITE, WRITEBACK, etc.) to
accelerate finding the pages with a specific tag in the radix tree
during inode writeback.  But for anonymous pages in the swap cache,
there is no inode writeback.  So there is no need to find the
pages with some writeback tags in the radix tree.  It is not necessary
to touch radix tree writeback tags for pages in the swap cache.

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
   1207402 A+-  7%     +22.3%    1476578 A+-  6%  vmstat.swap.so
   2506952 A+-  2%     +28.1%    3212076 A+-  7%  vm-scalability.throughput
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
 mm/page-writeback.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 82e7252..599d2f9 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2728,7 +2728,8 @@ int test_clear_page_writeback(struct page *page)
 	int ret;
 
 	lock_page_memcg(page);
-	if (mapping) {
+	/* Pages in swap cache don't use writeback tags */
+	if (mapping && !PageSwapCache(page)) {
 		struct inode *inode = mapping->host;
 		struct backing_dev_info *bdi = inode_to_bdi(inode);
 		unsigned long flags;
@@ -2771,7 +2772,8 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 	int ret;
 
 	lock_page_memcg(page);
-	if (mapping) {
+	/* Pages in swap cache don't use writeback tags */
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
