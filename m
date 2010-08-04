Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9B41366002F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 23:34:14 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o743YAUg007800
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 20:34:11 -0700
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by kpbe15.cbf.corp.google.com with ESMTP id o743Y9qR013033
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 20:34:09 -0700
Received: by pzk30 with SMTP id 30so1966735pzk.1
        for <linux-mm@kvack.org>; Tue, 03 Aug 2010 20:34:09 -0700 (PDT)
Date: Tue, 3 Aug 2010 20:34:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q3 03/23] slub: Use a constant for a unspecified node.
In-Reply-To: <20100804024525.562559967@linux.com>
Message-ID: <alpine.DEB.2.00.1008032029380.23490@chino.kir.corp.google.com>
References: <20100804024514.139976032@linux.com> <20100804024525.562559967@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, Christoph Lameter wrote:

> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-07-26 12:57:52.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-07-26 12:57:59.000000000 -0500
> @@ -1073,7 +1073,7 @@ static inline struct page *alloc_slab_pa
>  
>  	flags |= __GFP_NOTRACK;
>  
> -	if (node == -1)
> +	if (node == NUMA_NO_NODE)
>  		return alloc_pages(flags, order);
>  	else
>  		return alloc_pages_exact_node(node, flags, order);
> @@ -1387,7 +1387,7 @@ static struct page *get_any_partial(stru
>  static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
>  {
>  	struct page *page;
> -	int searchnode = (node == -1) ? numa_node_id() : node;
> +	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
>  
>  	page = get_partial_node(get_node(s, searchnode));
>  	if (page || (flags & __GFP_THISNODE) || node != -1)

This has a merge conflict with 2.6.35 since it has this:

	page = get_partial_node(get_node(s, searchnode));
	if (page || (flags & __GFP_THISNODE))
		return page;

	return get_any_partial(s, flags);

so what happened to the dropped check for returning get_any_partial() when 
node != -1?  I added the check for benchmarking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
