Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF576B0037
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 02:34:04 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p9Q6Y0o9029724
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:34:00 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz33.hot.corp.google.com with ESMTP id p9Q6XwBg007241
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:33:59 -0700
Received: by pzk36 with SMTP id 36so5126593pzk.7
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:33:58 -0700 (PDT)
Date: Tue, 25 Oct 2011 23:33:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <CAMbhsRQdrWRLkj7U-u2AZxM11mSUNj5_1K27g58cMBo1Js1Yeg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1110252327270.20273@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com> <20111025090956.GA10797@suse.de> <alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com> <CAMbhsRQ3y2SBwEfjiYgfxz2-h0fgn20mLBYgFuBwGqon0f-a8g@mail.gmail.com>
 <alpine.DEB.2.00.1110252244270.18661@chino.kir.corp.google.com> <alpine.DEB.2.00.1110252311030.20273@chino.kir.corp.google.com> <CAMbhsRS+-jn7d1bTd4F0_RB9860iWjOHLfOkDsqLfWEUbR3TYA@mail.gmail.com> <alpine.DEB.2.00.1110252322220.20273@chino.kir.corp.google.com>
 <CAMbhsRQdrWRLkj7U-u2AZxM11mSUNj5_1K27g58cMBo1Js1Yeg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, 25 Oct 2011, Colin Cross wrote:

> Makes sense.  What about this?  Official patch to follow.
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index fef8dc3..59cd4ff 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1786,6 +1786,13 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
>                 return 0;
> 
>         /*
> +        * If PM has disabled I/O, OOM is disabled and reclaim is unlikely
> +        * to make any progress.  To prevent a livelock, don't retry.
> +        */
> +       if (!(gfp_allowed_mask & __GFP_FS))
> +               return 0;
> +
> +       /*
>          * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
>          * means __GFP_NOFAIL, but that may not be true in other
>          * implementations.

Eek, this is precisely what we don't want and is functionally the same as 
what you initially proposed except it doesn't care about __GFP_NOFAIL.

You're trying to address a suspend issue where nothing on the system can 
logically make progress because __GFP_FS seriously restricts the ability 
of reclaim to do anything useful if it doesn't succeed the first time and 
kswapd isn't effective.  That's why I suggested a hook into 
pm_restrict_gfp_mask() to set a variable and then treat it exactly as 
__GFP_NORETRY in should_alloc_retry().

Consider if nobody is using suspend and they are allocating with GFP_NOFS.  
There's potentially a lot of candidates:

	$ grep -r GFP_NOFS * | wc -l
	1016

and now we've just introduced a regression where the allocation would 
eventually succeed because of either kswapd, a backing device that is no 
longer congested, or an allocation on another cpu in a context where 
direct reclaim can be more aggressive or the oom killer can at least free 
some memory.

So you definitely want to localize your change to only suspend and 
pm_restrict_gfp_mask() is a very easy way to do it.  So I'd suggest adding 
a static bool that can be tested in should_alloc_retry() and identify such 
situations and tag it as __read_mostly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
