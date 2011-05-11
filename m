Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AB5416B0023
	for <linux-mm@kvack.org>; Wed, 11 May 2011 16:38:49 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p4BKcluI029905
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:38:48 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by kpbe17.cbf.corp.google.com with ESMTP id p4BKcUHM008436
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:38:46 -0700
Received: by pxi10 with SMTP id 10so717330pxi.36
        for <linux-mm@kvack.org>; Wed, 11 May 2011 13:38:46 -0700 (PDT)
Date: Wed, 11 May 2011 13:38:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm: slub: Do not take expensive steps for SLUBs
 speculative high-order allocations
In-Reply-To: <1305127773-10570-3-git-send-email-mgorman@suse.de>
Message-ID: <alpine.DEB.2.00.1105111312020.9346@chino.kir.corp.google.com>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de> <1305127773-10570-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, 11 May 2011, Mel Gorman wrote:

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
> index 98c358d..1071723 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1170,7 +1170,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	 * Let the initial higher-order allocation fail under memory pressure
>  	 * so we fall-back to the minimum order allocation.
>  	 */
> -	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY | __GFP_NO_KSWAPD) & ~__GFP_NOFAIL;
> +	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY | __GFP_NO_KSWAPD) &
> +			~(__GFP_NOFAIL | __GFP_WAIT);

__GFP_NORETRY is a no-op without __GFP_WAIT.

>  
>  	page = alloc_slab_page(alloc_gfp, node, oo);
>  	if (unlikely(!page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
