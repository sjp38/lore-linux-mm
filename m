Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D089490010B
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:16:53 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p4GLGpwv016058
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:16:51 -0700
Received: from pwi16 (pwi16.prod.google.com [10.241.219.16])
	by kpbe13.cbf.corp.google.com with ESMTP id p4GLGnf8020439
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:16:49 -0700
Received: by pwi16 with SMTP id 16so3378110pwi.35
        for <linux-mm@kvack.org>; Mon, 16 May 2011 14:16:49 -0700 (PDT)
Date: Mon, 16 May 2011 14:16:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] mm: slub: Do not take expensive steps for SLUBs
 speculative high-order allocations
In-Reply-To: <1305295404-12129-4-git-send-email-mgorman@suse.de>
Message-ID: <alpine.DEB.2.00.1105161411440.4353@chino.kir.corp.google.com>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de> <1305295404-12129-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, 13 May 2011, Mel Gorman wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9f8a97b..057f1e2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1972,6 +1972,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  {
>  	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
>  	const gfp_t wait = gfp_mask & __GFP_WAIT;
> +	const gfp_t can_wake_kswapd = !(gfp_mask & __GFP_NO_KSWAPD);
>  
>  	/* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch. */
>  	BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t) ALLOC_HIGH);
> @@ -1984,7 +1985,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  	 */
>  	alloc_flags |= (__force int) (gfp_mask & __GFP_HIGH);
>  
> -	if (!wait) {
> +	if (!wait && can_wake_kswapd) {
>  		/*
>  		 * Not worth trying to allocate harder for
>  		 * __GFP_NOMEMALLOC even if it can't schedule.
> diff --git a/mm/slub.c b/mm/slub.c
> index 98c358d..c5797ab 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1170,7 +1170,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	 * Let the initial higher-order allocation fail under memory pressure
>  	 * so we fall-back to the minimum order allocation.
>  	 */
> -	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY | __GFP_NO_KSWAPD) & ~__GFP_NOFAIL;
> +	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NO_KSWAPD) &
> +			~(__GFP_NOFAIL | __GFP_WAIT | __GFP_REPEAT);
>  
>  	page = alloc_slab_page(alloc_gfp, node, oo);
>  	if (unlikely(!page)) {

It's unnecessary to clear __GFP_REPEAT, these !__GFP_NOFAIL allocations 
will immediately fail.

alloc_gfp would probably benefit from having a comment about why 
__GFP_WAIT should be masked off here: that we don't want to do compaction 
or direct reclaim or retry the allocation more than once (so both 
__GFP_NORETRY and __GFP_REPEAT are no-ops).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
