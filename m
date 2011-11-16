Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 299CA6B002D
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 16:39:07 -0500 (EST)
Received: by iaek3 with SMTP id k3so1647830iae.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 13:39:05 -0800 (PST)
Date: Wed, 16 Nov 2011 13:39:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <20111116095244.GM27150@suse.de>
Message-ID: <alpine.DEB.2.00.1111161332330.16596@chino.kir.corp.google.com>
References: <20111114140421.GA27150@suse.de> <alpine.DEB.2.00.1111151332160.26232@chino.kir.corp.google.com> <20111116095244.GM27150@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Colin Cross <ccross@android.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, 16 Nov 2011, Mel Gorman wrote:

> Good point. I agree that it would be more consistent although
> there is still the risk of infinite looping with __GFP_NOFAIL if
> storage devices are disabled.
> 

Yeah, that's always been possible even regardless of the state of storage 
devices.  If a task has access to memory reserves via TIF_MEMDIE, 
__alloc_pages_high_priority() will just loop indefinitely anyway for these 
allocations.  While users of __GFP_NOFAIL accept that it won't return NULL 
as long as they have __GFP_WAIT (which they all do), then they should also 
accept the fact that it may never return at all.

> Colin reported elsewhere in this thread that "the particular allocation
> that usually causes the problem is the pgd_alloc for page tables when
> re-enabling the 2nd cpu during resume". On X86, those allocations are using
> the flags
> 
> GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
> 
> so they should not be trapped in an infinite loop due to __GFP_NOFAIL.
> On ARM, they use GFP_KERNEL so should also be ok.
> 

The __GFP_REPEAT is concerning because there's a high liklihood that 
!__GFP_FS as a result of suspend will never cause enough pages to be 
reclaimed so the necessary threshold will be reached to exit from its own 
self-induced infinite loop.  So if we go forward with failing allocations 
attempted without __GFP_IO and __GFP_FS that are !__GFP_NOFAIL, then we 
should also add that __GFP_REPEAT is a no-op without __GFP_IO or __GFP_FS.

> David, is this what you meant? This patch includes all the
> documentation-related updates that were discussed in this thread as well
> as updated the check in mm/swapfile.c for hibernation.
> 
> ==== CUT HERE ====
> mm: avoid livelock on !__GFP_FS allocations v2
> 
> Changelog since V1
>   o Move PM check to should_alloc_retry (David Rientjes)
>   o Add some additional documentation
> 
> Colin Cross reported;
> 
>   Under the following conditions, __alloc_pages_slowpath can loop forever:
>   gfp_mask & __GFP_WAIT is true
>   gfp_mask & __GFP_FS is false
>   reclaim and compaction make no progress
>   order <= PAGE_ALLOC_COSTLY_ORDER
> 
>   These conditions happen very often during suspend and resume,
>   when pm_restrict_gfp_mask() effectively converts all GFP_KERNEL
>   allocations into __GFP_WAIT.
> 
>   The oom killer is not run because gfp_mask & __GFP_FS is false,
>   but should_alloc_retry will always return true when order is less
>   than PAGE_ALLOC_COSTLY_ORDER.
> 
> In his fix, he avoided retrying the allocation if reclaim made no
> progress and __GFP_FS was not set. The problem is that this would
> result in GFP_NOIO allocations failing that previously succeeded
> which would be very unfortunate.
> 
> The big difference between GFP_NOIO and suspend converting GFP_KERNEL
> to behave like GFP_NOIO is that normally flushers will be cleaning
> pages and kswapd reclaims pages allowing GFP_NOIO to succeed after
> a short delay. The same does not necessarily apply during suspend as
> the storage device may be suspended.
> 
> This patch special cases the suspend case to fail the page allocation
> if reclaim cannot make progress and adds some documentation on how
> gfp_allowed_mask is currently used. Failing allocations like this
> may cause suspend to abort but that is better than a livelock.
> 
> [mgorman@suse.de: Rework fix to be suspend specific]
> [rientjes@google.com: Move suspended device check to should_alloc_retry]
> Reported-by: Colin Cross <ccross@android.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

Thanks Mel!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
