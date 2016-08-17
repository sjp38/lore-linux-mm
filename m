Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7526B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 20:58:51 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so176609406pad.2
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 17:58:51 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id b81si34734882pfb.21.2016.08.16.17.58.49
        for <linux-mm@kvack.org>;
        Tue, 16 Aug 2016 17:58:50 -0700 (PDT)
Date: Wed, 17 Aug 2016 09:59:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 00/11] THP swap: Delay splitting THP during swapping out
Message-ID: <20160817005905.GA5372@bbox>
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Huang,

On Tue, Aug 09, 2016 at 09:37:42AM -0700, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> This patchset is based on 8/4 head of mmotm/master.
> 
> This is the first step for Transparent Huge Page (THP) swap support.
> The plan is to delaying splitting THP step by step and avoid splitting
> THP finally during THP swapping out and swapping in.

What does it mean "delay splitting THP on swapping-in"?

> 
> The advantages of THP swap support are:
> 
> - Batch swap operations for THP to reduce lock acquiring/releasing,
>   including allocating/freeing swap space, adding/deleting to/from swap
>   cache, and writing/reading swap space, etc.
> 
> - THP swap space read/write will be 2M sequence IO.  It is particularly
>   helpful for swap read, which usually are 4k random IO.
> 
> - It will help memory fragmentation, especially when THP is heavily used
>   by the applications.  2M continuous pages will be free up after THP
>   swapping out.

Could we take the benefit for normal pages as well as THP page?
I think Tim and me discussed about that a few weeks ago.

Please search below topics.

[1] mm: Batch page reclamation under shink_page_list
[2] mm: Cleanup - Reorganize the shrink_page_list code into smaller functions

It's different with yours which focused on THP swapping while the suggestion
would be more general if we can do so it's worth to try it, I think.

Anyway, I hope [1/11] should be merged regardless of the patchset because
I believe anyone doesn't feel comfortable with cluser_info functions. ;-)

Thanks.

> 
> As the first step, in this patchset, the splitting huge page is
> delayed from almost the first step of swapping out to after allocating
> the swap space for THP and adding the THP into swap cache.  This will
> reduce lock acquiring/releasing for locks used for swap space and swap
> cache management.
> 
> With the patchset, the swap out bandwidth improved 12.1% in
> vm-scalability swap-w-seq test case with 16 processes on a Xeon E5 v3
> system.  To test sequence swap out, the test case uses 16 processes
> sequentially allocate and write to anonymous pages until RAM and part of
> the swap device is used up.
> 
> The detailed compare result is as follow,
> 
> base             base+patchset
> ---------------- -------------------------- 
>          %stddev     %change         %stddev
>              \          |                \  
>    1118821 +-  0%     +12.1%    1254241 +-  1%  vmstat.swap.so
>    2460636 +-  1%     +10.6%    2720983 +-  1%  vm-scalability.throughput
>     308.79 +-  1%      -7.9%     284.53 +-  1%  vm-scalability.time.elapsed_time
>       1639 +-  4%    +232.3%       5446 +-  1%  meminfo.SwapCached
>       0.70 +-  3%      +8.7%       0.77 +-  5%  perf-stat.ipc
>       9.82 +-  8%     -31.6%       6.72 +-  2%  perf-profile.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
