Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AB9336B01AF
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 04:55:07 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o588t0dJ006403
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 01:55:02 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by hpaq2.eem.corp.google.com with ESMTP id o588subr029909
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 01:54:59 -0700
Received: by pwj1 with SMTP id 1so2366013pwj.13
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 01:54:56 -0700 (PDT)
Date: Tue, 8 Jun 2010 01:54:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V2 SLEB 05/14] SLUB: is_kmalloc_cache
In-Reply-To: <20100521211539.878341791@quilx.com>
Message-ID: <alpine.DEB.2.00.1006080152060.15571@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com> <20100521211539.878341791@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 2010, Christoph Lameter wrote:

> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-05-12 14:46:58.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-05-12 14:49:37.000000000 -0500
> @@ -312,6 +312,11 @@ static inline int oo_objects(struct kmem
>  	return x.x & OO_MASK;
>  }
>  
> +static int is_kmalloc_cache(struct kmem_cache *s)
> +{
> +	return (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches);
> +}
> +
>  #ifdef CONFIG_SLUB_DEBUG
>  /*
>   * Debug settings:
> @@ -2076,7 +2081,7 @@ static DEFINE_PER_CPU(struct kmem_cache_
>  
>  static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
>  {
> -	if (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches)
> +	if (is_kmalloc_cache(s))
>  		/*
>  		 * Boot time creation of the kmalloc array. Use static per cpu data
>  		 * since the per cpu allocator is not available yet.
> @@ -2158,8 +2163,7 @@ static int init_kmem_cache_nodes(struct 
>  	int node;
>  	int local_node;
>  
> -	if (slab_state >= UP && (s < kmalloc_caches ||
> -			s >= kmalloc_caches + KMALLOC_CACHES))
> +	if (slab_state >= UP && !is_kmalloc_cache(s))
>  		local_node = page_to_nid(virt_to_page(s));
>  	else
>  		local_node = 0;

Looks good, how about extending it to dma_kmalloc_cache() as well?
---
diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2641,13 +2641,12 @@ static noinline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
 	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
 			 (unsigned int)realsize);
 
-	s = NULL;
 	for (i = 0; i < KMALLOC_CACHES; i++)
 		if (!kmalloc_caches[i].size)
 			break;
 
-	BUG_ON(i >= KMALLOC_CACHES);
 	s = kmalloc_caches + i;
+	BUG_ON(!is_kmalloc_cache(s));
 
 	/*
 	 * Must defer sysfs creation to a workqueue because we don't know

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
