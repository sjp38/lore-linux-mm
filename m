Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C11A46B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 01:43:39 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id o7so79413028oif.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 22:43:39 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id o197si1644498ith.75.2016.09.08.22.43.38
        for <linux-mm@kvack.org>;
        Thu, 08 Sep 2016 22:43:38 -0700 (PDT)
Date: Fri, 9 Sep 2016 14:43:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
Message-ID: <20160909054336.GA2114@bbox>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Hi Huang,

On Wed, Sep 07, 2016 at 09:45:59AM -0700, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> This patchset is to optimize the performance of Transparent Huge Page
> (THP) swap.
> 
> Hi, Andrew, could you help me to check whether the overall design is
> reasonable?
> 
> Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
> swap part of the patchset?  Especially [01/10], [04/10], [05/10],
> [06/10], [07/10], [10/10].
> 
> Hi, Andrea and Kirill, could you help me to review the THP part of the
> patchset?  Especially [02/10], [03/10], [09/10] and [10/10].
> 
> Hi, Johannes, Michal and Vladimir, I am not very confident about the
> memory cgroup part, especially [02/10] and [03/10].  Could you help me
> to review it?
> 
> And for all, Any comment is welcome!
> 
> 
> Recently, the performance of the storage devices improved so fast that
> we cannot saturate the disk bandwidth when do page swap out even on a
> high-end server machine.  Because the performance of the storage
> device improved faster than that of CPU.  And it seems that the trend
> will not change in the near future.  On the other hand, the THP
> becomes more and more popular because of increased memory size.  So it
> becomes necessary to optimize THP swap performance.
> 
> The advantages of the THP swap support include:
> 
> - Batch the swap operations for the THP to reduce lock
>   acquiring/releasing, including allocating/freeing the swap space,
>   adding/deleting to/from the swap cache, and writing/reading the swap
>   space, etc.  This will help improve the performance of the THP swap.
> 
> - The THP swap space read/write will be 2M sequential IO.  It is
>   particularly helpful for the swap read, which usually are 4k random
>   IO.  This will improve the performance of the THP swap too.
> 
> - It will help the memory fragmentation, especially when the THP is
>   heavily used by the applications.  The 2M continuous pages will be
>   free up after THP swapping out.

I just read patchset right now and still doubt why the all changes
should be coupled with THP tightly. Many parts(e.g., you introduced
or modifying existing functions for making them THP specific) could
just take page_list and the number of pages then would handle them
without THP awareness.

For example, if the nr_pages is larger than SWAPFILE_CLUSTER, we
can try to allocate new cluster. With that, we could allocate new
clusters to meet nr_pages requested or bail out if we fail to allocate
and fallback to 0-order page swapout. With that, swap layer could
support multiple order-0 pages by batch.

IMO, I really want to land Tim Chen's batching swapout work first.
With Tim Chen's work, I expect we can make better refactoring
for batching swap before adding more confuse to the swap layer.
(I expect it would share several pieces of code for or would be base
for batching allocation of swapcache, swapslot)

After that, we could enhance swap for big contiguous batching
like THP and finally we might make it be aware of THP specific to
enhance further.

A thing I remember you aruged: you want to swapin 512 pages
all at once unconditionally. It's really worth to discuss if
your design is going for the way.
I doubt it's generally good idea. Because, currently, we try to
swap in swapped out pages in THP page with conservative approach
but your direction is going to opposite way.

[mm, thp: convert from optimistic swapin collapsing to conservative]

I think general approach(i.e., less effective than targeting
implement for your own specific goal but less hacky and better job
for many cases) is to rely/improve on the swap readahead.
If most of subpages of a THP page are really workingset, swap readahead
could work well.

Yeah, it's fairly vague feedback so sorry if I miss something clear.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
