Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CA4DA6B00F9
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:04:32 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B849282C53E
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:06:23 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id t5ARF5zUNV9B for <linux-mm@kvack.org>;
	Fri, 18 Sep 2009 17:06:23 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id ACF6C82C540
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:06:18 -0400 (EDT)
Date: Fri, 18 Sep 2009 17:01:14 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/3] slqb: Treat pages freed on a memoryless node as
 local node
In-Reply-To: <1253302451-27740-3-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0909181657280.9490@V090114053VZO-1>
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie> <1253302451-27740-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Sep 2009, Mel Gorman wrote:

> --- a/mm/slqb.c
> +++ b/mm/slqb.c
> @@ -1726,6 +1726,7 @@ static __always_inline void __slab_free(struct kmem_cache *s,
>  	struct kmem_cache_cpu *c;
>  	struct kmem_cache_list *l;
>  	int thiscpu = smp_processor_id();
> +	int thisnode = numa_node_id();

thisnode must be the first reachable node with usable RAM. Not the current
node. cpu 0 may be on node 0 but there is no memory on 0. Instead
allocations fall back to node 2 (depends on policy effective as well. The
round robin meory policy default on bootup may result in allocations from
different nodes as well).

>  	c = get_cpu_slab(s, thiscpu);
>  	l = &c->list;
> @@ -1733,12 +1734,14 @@ static __always_inline void __slab_free(struct kmem_cache *s,
>  	slqb_stat_inc(l, FREE);
>
>  	if (!NUMA_BUILD || !slab_numa(s) ||
> -			likely(slqb_page_to_nid(page) == numa_node_id())) {
> +			likely(slqb_page_to_nid(page) == numa_node_id() ||
> +			!node_state(thisnode, N_HIGH_MEMORY))) {

Same here.

Note that page_to_nid can yield surprising results if you are trying to
allocate from a node that has no memory and you get some fallback node.

SLAB for some time had a bug that caused list corruption because of this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
