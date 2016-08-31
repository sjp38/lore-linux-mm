Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 59CB26B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:17:25 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so95084414pab.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:17:25 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u190si358993pfb.43.2016.08.31.08.17.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 08:17:24 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v2] mm: Don't use radix tree writeback tags for pages in swap cache
References: <1472578089-5560-1-git-send-email-ying.huang@intel.com>
	<20160831091459.GY8119@techsingularity.net>
Date: Wed, 31 Aug 2016 08:17:24 -0700
In-Reply-To: <20160831091459.GY8119@techsingularity.net> (Mel Gorman's message
	of "Wed, 31 Aug 2016 10:14:59 +0100")
Message-ID: <87oa49m0hn.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

Mel Gorman <mgorman@techsingularity.net> writes:

> On Tue, Aug 30, 2016 at 10:28:09AM -0700, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> File pages use a set of radix tree tags (DIRTY, TOWRITE, WRITEBACK,
>> etc.) to accelerate finding the pages with a specific tag in the radix
>> tree during inode writeback.  But for anonymous pages in the swap
>> cache, there is no inode writeback.  So there is no need to find the
>> pages with some writeback tags in the radix tree.  It is not necessary
>> to touch radix tree writeback tags for pages in the swap cache.
>> 
>> Per Rik van Riel's suggestion, a new flag AS_NO_WRITEBACK_TAGS is
>> introduced for address spaces which don't need to update the writeback
>> tags.  The flag is set for swap caches.  It may be used for DAX file
>> systems, etc.
>> 
>> With this patch, the swap out bandwidth improved 22.3% (from ~1.2GB/s to
>> ~ 1.48GBps) in the vm-scalability swap-w-seq test case with 8 processes.
>> The test is done on a Xeon E5 v3 system.  The swap device used is a RAM
>> simulated PMEM (persistent memory) device.  The improvement comes from
>> the reduced contention on the swap cache radix tree lock.  To test
>> sequential swapping out, the test case uses 8 processes, which
>> sequentially allocate and write to the anonymous pages until RAM and
>> part of the swap device is used up.
>> 
>> Details of comparison is as follow,
>> 
>> base             base+patch
>> ---------------- --------------------------
>>          %stddev     %change         %stddev
>>              \          |                \
>>    2506952 A+-  2%     +28.1%    3212076 A+-  7%  vm-scalability.throughput
>>    1207402 A+-  7%     +22.3%    1476578 A+-  6%  vmstat.swap.so
>>      10.86 A+- 12%     -23.4%       8.31 A+- 16%  perf-profile.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list
>>      10.82 A+- 13%     -33.1%       7.24 A+- 14%  perf-profile.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_zone_memcg
>>      10.36 A+- 11%    -100.0%       0.00 A+- -1%  perf-profile.cycles-pp._raw_spin_lock_irqsave.__test_set_page_writeback.bdev_write_page.__swap_writepage.swap_writepage
>>      10.52 A+- 12%    -100.0%       0.00 A+- -1%  perf-profile.cycles-pp._raw_spin_lock_irqsave.test_clear_page_writeback.end_page_writeback.page_endio.pmem_rw_page
>> 
>
> I didn't see anything wrong with the patch but it's worth highlighting
> that this hunk means we are now out of GFP bits.

Sorry, I don't know whether I understand your words.  It is something
about,

__GFP_BITS_SHIFT == 26

So remainning bits in mapping_flags is 6.  And now the latest bit is
used for the flag introduced in the patch?

Best Regards,
Huang, Ying

>> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
>> index 66a1260..2f5a65dd 100644
>> --- a/include/linux/pagemap.h
>> +++ b/include/linux/pagemap.h
>> @@ -25,6 +25,8 @@ enum mapping_flags {
>>  	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>>  	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
>>  	AS_EXITING	= __GFP_BITS_SHIFT + 4, /* final truncate in progress */
>> +	/* writeback related tags are not used */
>> +	AS_NO_WRITEBACK_TAGS = __GFP_BITS_SHIFT + 5,
>>  };
>>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
