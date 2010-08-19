Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B82E86B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 17:21:21 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o7JLLNDt023071
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 14:21:24 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by kpbe16.cbf.corp.google.com with ESMTP id o7JLKXXQ022974
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 14:21:22 -0700
Received: by pzk4 with SMTP id 4so1296426pzk.35
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 14:21:22 -0700 (PDT)
Date: Thu, 19 Aug 2010 14:21:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup3 4/6] slub: Dynamically size kmalloc cache
 allocations
In-Reply-To: <20100819203438.745611155@linux.com>
Message-ID: <alpine.DEB.2.00.1008191405230.18994@chino.kir.corp.google.com>
References: <20100819203324.549566024@linux.com> <20100819203438.745611155@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, Christoph Lameter wrote:

> @@ -2940,46 +2951,113 @@ static int slab_memory_callback(struct n
>   *			Basic setup of slabs
>   *******************************************************************/
>  
> +/*
> + * Used for early kmem_cache structures that were allocated using
> + * the page allocator
> + */
> +
> +static void __init kmem_cache_bootstrap_fixup(struct kmem_cache *s)
> +{
> +	int node;
> +
> +	list_add(&s->list, &slab_caches);

Since sysfs_slab_add() has been removed for kmem_cache and kmem_cache_node 
here, they apparently don't need the __SYSFS_ADD_DEFERRED flag even though 
we're waiting for the sysfs initcall since there's nothing that checks for 
it.  That bit can be removed, the last users of it were the dynamic DMA 
cache support that was dropped in patch 2.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
