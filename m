Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 883D76B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 03:22:06 -0400 (EDT)
Received: by wgiu9 with SMTP id u9so34166263wgi.3
        for <linux-mm@kvack.org>; Thu, 07 May 2015 00:22:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ek7si1872326wjd.96.2015.05.07.00.22.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 May 2015 00:22:04 -0700 (PDT)
Date: Thu, 7 May 2015 08:21:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
Message-ID: <20150507072159.GK2462@suse.de>
References: <554415B1.2050702@hp.com>
 <20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
 <20150505104514.GC2462@suse.de>
 <20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
 <20150505221329.GE2462@suse.de>
 <20150505152549.037679566fad8c593df176ed@linux-foundation.org>
 <20150506071246.GF2462@suse.de>
 <20150506102220.GH2462@suse.de>
 <554A5655.6060108@hp.com>
 <554ACFE8.2050908@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <554ACFE8.2050908@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 06, 2015 at 10:37:28PM -0400, Waiman Long wrote:
> On 05/06/2015 01:58 PM, Waiman Long wrote:
> >On 05/06/2015 06:22 AM, Mel Gorman wrote:
> >>On Wed, May 06, 2015 at 08:12:46AM +0100, Mel Gorman wrote:
> >>>On Tue, May 05, 2015 at 03:25:49PM -0700, Andrew Morton wrote:
> >>>>On Tue, 5 May 2015 23:13:29 +0100 Mel Gorman<mgorman@suse.de>  wrote:
> >>>>
> >>>>>>Alternatively, the page allocator can go off and synchronously
> >>>>>>initialize some pageframes itself.  Keep doing that until the
> >>>>>>allocation attempt succeeds.
> >>>>>>
> >>>>>That was rejected during review of earlier attempts at
> >>>>>this feature on
> >>>>>the grounds that it impacted allocator fast paths.
> >>>>eh?  Changes are only needed on the allocation-attempt-failed path,
> >>>>which is slow-path.
> >>>We'd have to distinguish between falling back to other zones
> >>>because the
> >>>high zone is artifically exhausted and normal ALLOC_BATCH
> >>>exhaustion. We'd
> >>>also have to avoid falling back to remote nodes prematurely.
> >>>While I have
> >>>not tried an implementation, I expected they would need to be
> >>>in the fast
> >>>paths unless I used jump labels to get around it. I'm going to
> >>>try altering
> >>>when we initialise instead so that it happens earlier.
> >>>
> >>Which looks as follows. Waiman, a test on the 24TB machine would be
> >>appreciated again. This patch should be applied instead of "mm: meminit:
> >>Take into account that large system caches scale linearly with memory"
> >>
> >>---8<---
> >>mm: meminit: Finish initialisation of memory before basic setup
> >>
> >>Waiman Long reported that 24TB machines hit OOM during basic setup when
> >>struct page initialisation was deferred. One approach is to
> >>initialise memory
> >>on demand but it interferes with page allocator paths. This
> >>patch creates
> >>dedicated threads to initialise memory before basic setup. It
> >>then blocks
> >>on a rw_semaphore until completion as a wait_queue and counter
> >>is overkill.
> >>This may be slower to boot but it's simplier overall and also
> >>gets rid of a
> >>lot of section mangling which existed so kswapd could do the
> >>initialisation.
> >>
> >>Signed-off-by: Mel Gorman<mgorman@suse.de>
> >>
> >
> >This patch moves the deferred meminit from kswapd to its own
> >kernel threads started after smp_init(). However, the hash table
> >allocation was done earlier than that. It seems like it will still
> >run out of memory in the 24TB machine that I tested on.
> >
> >I will certainly try it out, but I doubt it will solve the problem
> >on its own.
> 
> It turns out that the two new patches did work on the 24-TB
> DragonHawk without the "mm: meminit: Take into account that large
> system caches scale linearly with memory" patch. The bootup time was
> 357s which was just a few seconds slower than the other bootup times
> that I sent you yesterday.
> 

Grand. This is what I expected because the previous failure was not the
hash tables, it was later allocations and the parallel initialisation
was early enough.

> BTW, do you want to change the following log message as kswapd will
> no longer be the one doing deferred meminit?
> 
>     kswapd 0 initialised 396098436 pages in 6024ms
> 

I will.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
