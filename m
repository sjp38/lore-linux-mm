Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id B55496B02CD
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 15:47:46 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so285131431pad.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 12:47:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 27si40595546pfn.124.2016.08.29.12.47.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 12:47:45 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm: Don't use radix tree writeback tags for pages in swap cache
References: <1472153230-14766-1-git-send-email-ying.huang@intel.com>
	<1472154243.2751.44.camel@redhat.com>
Date: Mon, 29 Aug 2016 12:47:45 -0700
In-Reply-To: <1472154243.2751.44.camel@redhat.com> (Rik van Riel's message of
	"Thu, 25 Aug 2016 15:44:03 -0400")
Message-ID: <87shtnxspq.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

Hi, Rik,

Thanks for comments!

Rik van Riel <riel@redhat.com> writes:
> On Thu, 2016-08-25 at 12:27 -0700, Huang, Ying wrote:
>> File pages use a set of radix tags (DIRTY, TOWRITE, WRITEBACK, etc.)
>> to
>> accelerate finding the pages with a specific tag in the radix tree
>> during inode writeback.A A But for anonymous pages in the swap cache,
>> there is no inode writeback.A A So there is no need to find the
>> pages with some writeback tags in the radix tree.A A It is not
>> necessary
>> to touch radix tree writeback tags for pages in the swap cache.
>> 
>> With this patch, the swap out bandwidth improved 22.3% (from ~1.2GB/s
>> to
>> ~ 1.48GBps) in the vm-scalability swap-w-seq test case with 8
>> processes.
>> The test is done on a Xeon E5 v3 system.A A The swap device used is a
>> RAM
>> simulated PMEM (persistent memory) device.A A The improvement comes
>> from
>> the reduced contention on the swap cache radix tree lock.A A To test
>> sequential swapping out, the test case uses 8 processes, which
>> sequentially allocate and write to the anonymous pages until RAM and
>> part of the swap device is used up.
>> 
>> Details of comparison is as follow,
>> 
>> baseA A A A A A A A A A A A A base+patch
>> ---------------- --------------------------
>> A A A A A A A A A %stddevA A A A A %changeA A A A A A A A A %stddev
>> A A A A A A A A A A A A A \A A A A A A A A A A |A A A A A A A A A A A A A A A A \
>> A A A 1207402 A+-A A 7%A A A A A +22.3%A A A A 1476578 A+-A A 6%A A vmstat.swap.so
>> A A A 2506952 A+-A A 2%A A A A A +28.1%A A A A 3212076 A+-A A 7%A A vm-
>> scalability.throughput
>> A A A A A 10.86 A+- 12%A A A A A -23.4%A A A A A A A 8.31 A+- 16%A A perf-profile.cycles-
>> pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_sw
>> ap.shrink_page_list
>> A A A A A 10.82 A+- 13%A A A A A -33.1%A A A A A A A 7.24 A+- 14%A A perf-profile.cycles-
>> pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_in
>> active_list.shrink_zone_memcg
>> A A A A A 10.36 A+- 11%A A A A -100.0%A A A A A A A 0.00 A+- -1%A A perf-profile.cycles-
>> pp._raw_spin_lock_irqsave.__test_set_page_writeback.bdev_write_page._
>> _swap_writepage.swap_writepage
>> A A A A A 10.52 A+- 12%A A A A -100.0%A A A A A A A 0.00 A+- -1%A A perf-profile.cycles-
>> pp._raw_spin_lock_irqsave.test_clear_page_writeback.end_page_writebac
>> k.page_endio.pmem_rw_page
>> 
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Shaohua Li <shli@kernel.org>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> Cc: Dave Hansen <dave.hansen@intel.com>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> ---
>> A mm/page-writeback.c | 6 ++++--
>> A 1 file changed, 4 insertions(+), 2 deletions(-)
>> 
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 82e7252..599d2f9 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -2728,7 +2728,8 @@ int test_clear_page_writeback(struct page
>> *page)
>> A 	int ret;
>> A 
>> A 	lock_page_memcg(page);
>> -	if (mapping) {
>> +	/* Pages in swap cache don't use writeback tags */
>> +	if (mapping && !PageSwapCache(page)) {
>
> I wonder if that should be a mapping_uses_tags(mapping)
> macro or similar, and a per-mapping flag?
>
> I suspect there will be another case coming up soon
> where we have a page cache radix tree, but no need
> for dirty/writeback/... tags.
>
> That use case would be DAX filesystems, where we do
> use a struct page, but that struct page points at
> persistent storage, and the tags are not necessary.

Asked Dan and Ross for DAX usage of writeback tags.  The DAX uses these
tags to flush the cache, etc.

>From Dan:

"
DAX uses them to track PMEM ranges that have taken a write fault so
that we can flush/write-back those dirty ranges at fsync()/msync()
time.
"

But I still think that it may be a good idea to use some function or
flags for this.  Because it is more flexible and readable.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
