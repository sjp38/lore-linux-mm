Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E124A83093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 15:44:28 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e63so4130125ith.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 12:44:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c84si19963202iod.42.2016.08.25.12.44.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 12:44:21 -0700 (PDT)
Message-ID: <1472154243.2751.44.camel@redhat.com>
Subject: Re: [PATCH] mm: Don't use radix tree writeback tags for pages in
 swap cache
From: Rik van Riel <riel@redhat.com>
Date: Thu, 25 Aug 2016 15:44:03 -0400
In-Reply-To: <1472153230-14766-1-git-send-email-ying.huang@intel.com>
References: <1472153230-14766-1-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

On Thu, 2016-08-25 at 12:27 -0700, Huang, Ying wrote:
> File pages use a set of radix tags (DIRTY, TOWRITE, WRITEBACK, etc.)
> to
> accelerate finding the pages with a specific tag in the radix tree
> during inode writeback.A A But for anonymous pages in the swap cache,
> there is no inode writeback.A A So there is no need to find the
> pages with some writeback tags in the radix tree.A A It is not
> necessary
> to touch radix tree writeback tags for pages in the swap cache.
> 
> With this patch, the swap out bandwidth improved 22.3% (from ~1.2GB/s
> to
> ~ 1.48GBps) in the vm-scalability swap-w-seq test case with 8
> processes.
> The test is done on a Xeon E5 v3 system.A A The swap device used is a
> RAM
> simulated PMEM (persistent memory) device.A A The improvement comes
> from
> the reduced contention on the swap cache radix tree lock.A A To test
> sequential swapping out, the test case uses 8 processes, which
> sequentially allocate and write to the anonymous pages until RAM and
> part of the swap device is used up.
> 
> Details of comparison is as follow,
> 
> baseA A A A A A A A A A A A A base+patch
> ---------------- --------------------------
> A A A A A A A A A %stddevA A A A A %changeA A A A A A A A A %stddev
> A A A A A A A A A A A A A \A A A A A A A A A A |A A A A A A A A A A A A A A A A \
> A A A 1207402 A+-A A 7%A A A A A +22.3%A A A A 1476578 A+-A A 6%A A vmstat.swap.so
> A A A 2506952 A+-A A 2%A A A A A +28.1%A A A A 3212076 A+-A A 7%A A vm-
> scalability.throughput
> A A A A A 10.86 A+- 12%A A A A A -23.4%A A A A A A A 8.31 A+- 16%A A perf-profile.cycles-
> pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_sw
> ap.shrink_page_list
> A A A A A 10.82 A+- 13%A A A A A -33.1%A A A A A A A 7.24 A+- 14%A A perf-profile.cycles-
> pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_in
> active_list.shrink_zone_memcg
> A A A A A 10.36 A+- 11%A A A A -100.0%A A A A A A A 0.00 A+- -1%A A perf-profile.cycles-
> pp._raw_spin_lock_irqsave.__test_set_page_writeback.bdev_write_page._
> _swap_writepage.swap_writepage
> A A A A A 10.52 A+- 12%A A A A -100.0%A A A A A A A 0.00 A+- -1%A A perf-profile.cycles-
> pp._raw_spin_lock_irqsave.test_clear_page_writeback.end_page_writebac
> k.page_endio.pmem_rw_page
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
> A mm/page-writeback.c | 6 ++++--
> A 1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 82e7252..599d2f9 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2728,7 +2728,8 @@ int test_clear_page_writeback(struct page
> *page)
> A 	int ret;
> A 
> A 	lock_page_memcg(page);
> -	if (mapping) {
> +	/* Pages in swap cache don't use writeback tags */
> +	if (mapping && !PageSwapCache(page)) {

I wonder if that should be a mapping_uses_tags(mapping)
macro or similar, and a per-mapping flag?

I suspect there will be another case coming up soon
where we have a page cache radix tree, but no need
for dirty/writeback/... tags.

That use case would be DAX filesystems, where we do
use a struct page, but that struct page points at
persistent storage, and the tags are not necessary.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
