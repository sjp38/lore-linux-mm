Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id B3A066B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 13:00:29 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id pp5so31672006pac.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 10:00:29 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id o78si43461477pfi.291.2016.08.09.10.00.28
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 10:00:28 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [RFC] mm: Don't use radix tree writeback tags for pages in swap cache
References: <1470759443-9229-1-git-send-email-ying.huang@intel.com>
	<57AA061B.2050002@intel.com>
Date: Tue, 09 Aug 2016 10:00:28 -0700
In-Reply-To: <57AA061B.2050002@intel.com> (Dave Hansen's message of "Tue, 9
	Aug 2016 09:34:35 -0700")
Message-ID: <87oa51513n.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

Hi, Dave,

Dave Hansen <dave.hansen@intel.com> writes:

> On 08/09/2016 09:17 AM, Huang, Ying wrote:
>> File pages uses a set of radix tags (DIRTY, TOWRITE, WRITEBACK) to
>> accelerate finding the pages with the specific tag in the the radix tree
>> during writing back an inode.  But for anonymous pages in swap cache,
>> there are no inode based writeback.  So there is no need to find the
>> pages with some writeback tags in the radix tree.  It is no necessary to
>> touch radix tree writeback tags for pages in swap cache.
>
> Seems simple enough.  Do we do any of this unnecessary work for the
> other radix tree tags?  If so, maybe we should just fix this once and
> for all.  Could we, for instance, WARN_ONCE() in radix_tree_tag_set() if
> it sees a swap mapping get handed in there?

Good idea!  I will do that and try to catch other places if any.

> In any case, I think the new !PageSwapCache(page) check either needs
> commenting, or a common helper for the two sites that you can comment.

Sure.  I will add that.

>> With this patch, the swap out bandwidth improved 22.3% in vm-scalability
>> swap-w-seq test case with 8 processes on a Xeon E5 v3 system, because of
>> reduced contention on swap cache radix tree lock.  To test sequence swap
>> out, the test case uses 8 processes sequentially allocate and write to
>> anonymous pages until RAM and part of the swap device is used up.
>
> What was the swap device here, btw?  What is the actual bandwidth
> increase you are seeing?  Is it 1MB/s -> 1.223MB/s? :)

The swap device here is a DRAM simulated persistent memory block device
(pmem).

   1207402 A+-  7%     +22.3%    1476578 A+-  6%  vmstat.swap.so

The actual bandwidth increase is from 1.21GB/s -> 1.48 GB/s.  This is
lower than that of NVMe disk, so the bottleneck is in swap subsystem
instead of block subsystem and device.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
