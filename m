Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B657F6B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 18:03:30 -0500 (EST)
Date: Mon, 14 Nov 2011 15:03:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Message-Id: <20111114150326.0ee60107.akpm@linux-foundation.org>
In-Reply-To: <20111114140421.GA27150@suse.de>
References: <20111114140421.GA27150@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Colin Cross <ccross@android.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, 14 Nov 2011 14:04:21 +0000
Mel Gorman <mgorman@suse.de> wrote:

> This patch seems to have gotten lost in the cracks and the discussion
> on alternatives that started here https://lkml.org/lkml/2011/10/25/24
> petered out without any alternative patches being posted. Lacking
> a viable alternative patch, I'm reposting this patch because AFAIK,
> this bug still exists.
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
> the storage device may be suspended.  Hence, this patch special cases
> the suspend case to fail the page allocation if reclaim cannot make
> progress. This might cause suspend to abort but that is better than
> a livelock.

Fair enough.

> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9dd443d..5402897 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -127,6 +127,20 @@ void pm_restrict_gfp_mask(void)
>  	saved_gfp_mask = gfp_allowed_mask;
>  	gfp_allowed_mask &= ~GFP_IOFS;
>  }
> +
> +static bool pm_suspending(void)
> +{
> +	if ((gfp_allowed_mask & GFP_IOFS) == GFP_IOFS)
> +		return false;
> +	return true;
> +}

This doesn't seem a terribly reliable way of detecting that PM has
disabled the storage devices (which is what we really want to know
here: kswapd got crippled).

I guess it's safe for now, because PM is the only caller who alters
gfp_allowed_mask (I assume).  But an explicit storage_is_unavaliable
global which is set and cleared at exactly the correct time is clearer,
more direct and future-safer, no?

> +#else
> +
> +static bool pm_suspending(void)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_PM_SLEEP */
>  
>  #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
> @@ -2214,6 +2228,14 @@ rebalance:
>  
>  			goto restart;
>  		}
> +
> +		/*
> +		 * Suspend converts GFP_KERNEL to __GFP_WAIT which can
> +		 * prevent reclaim making forward progress without
> +		 * invoking OOM. Bail if we are suspending
> +		 */
> +		if (pm_suspending())
> +			goto nopage;

The comment doesn't tell the whole story: it's important that kswapd
writeout was disabled?

--- a/mm/page_alloc.c~mm-avoid-livelock-on-__gfp_fs-allocations-fix
+++ a/mm/page_alloc.c
@@ -2263,9 +2263,10 @@ rebalance:
 		}
 
 		/*
-		 * Suspend converts GFP_KERNEL to __GFP_WAIT which can
-		 * prevent reclaim making forward progress without
-		 * invoking OOM. Bail if we are suspending
+		 * Suspend converts GFP_KERNEL to __GFP_WAIT which can prevent
+		 * reclaim making forward progress without invoking OOM.
+		 * Suspend also disables storage devices so kswapd cannot save
+		 * us.  Bail if we are suspending.
 		 */
 		if (pm_suspending())
 			goto nopage;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
