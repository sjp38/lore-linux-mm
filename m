Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2CA6B0069
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 16:40:47 -0500 (EST)
Received: by ggnq1 with SMTP id q1so5672926ggn.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 13:40:45 -0800 (PST)
Date: Tue, 15 Nov 2011 13:40:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <20111114140421.GA27150@suse.de>
Message-ID: <alpine.DEB.2.00.1111151332160.26232@chino.kir.corp.google.com>
References: <20111114140421.GA27150@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Colin Cross <ccross@android.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, 14 Nov 2011, Mel Gorman wrote:

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
> +
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
>  	}
>  
>  	/* Check if we should retry the allocation */

This allows all __GFP_NOFAIL allocations to fail while 
pm_restrict_gfp_mask() is in effect, so I disagree with this unless it is 
moved into the should_alloc_retry() logic.  If you pass did_some_progress 
into that function and then moved the check for __GFP_NOFAIL right under 
the check for __GFP_NORETRY and checked for pm_suspending() there (and 
before the check for PAGE_ALLOC_COSTLY_ORDER) then it would allow the 
infinite loop for __GFP_NOFAIL which is required if __GFP_WAIT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
