Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3066B006E
	for <linux-mm@kvack.org>; Sun, 20 Nov 2011 18:23:03 -0500 (EST)
Received: by iaek3 with SMTP id k3so8675449iae.14
        for <linux-mm@kvack.org>; Sun, 20 Nov 2011 15:23:01 -0800 (PST)
Date: Sun, 20 Nov 2011 15:22:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc 04/18] slub: Use freelist instead of "object" in
 __slab_alloc
In-Reply-To: <20111111200727.668158433@linux.com>
Message-ID: <alpine.DEB.2.00.1111201521170.30815@chino.kir.corp.google.com>
References: <20111111200711.156817886@linux.com> <20111111200727.668158433@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Fri, 11 Nov 2011, Christoph Lameter wrote:

> The variable "object" really refers to a list of objects that we
> are handling. Since the lockless allocator path will depend on it
> we rename the variable now.
> 

Some of this needs to be folded into the earlier patch that introduces 
get_freelist() since this patch doesn't just rename a variable, it changes 
the variable type.

> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  mm/slub.c |   40 ++++++++++++++++++++++------------------
>  1 file changed, 22 insertions(+), 18 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2011-11-09 11:11:13.471490305 -0600
> +++ linux-2.6/mm/slub.c	2011-11-09 11:11:22.381541568 -0600
> @@ -2084,7 +2084,7 @@ slab_out_of_memory(struct kmem_cache *s,
>  static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
>  			int node, struct kmem_cache_cpu **pc)
>  {
> -	void *object;
> +	void *freelist;
>  	struct kmem_cache_cpu *c;
>  	struct page *page = new_slab(s, flags, node);
>  
> @@ -2097,16 +2097,16 @@ static inline void *new_slab_objects(str
>  		 * No other reference to the page yet so we can
>  		 * muck around with it freely without cmpxchg
>  		 */
> -		object = page->freelist;
> +		freelist = page->freelist;
>  		page->freelist = NULL;
>  
>  		stat(s, ALLOC_SLAB);
>  		c->page = page;
>  		*pc = c;
>  	} else
> -		object = NULL;
> +		freelist = NULL;
>  
> -	return object;
> +	return freelist;
>  }
>  
>  /*
> @@ -2159,7 +2159,7 @@ static inline void *get_freelist(struct
>  static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
>  			  unsigned long addr, struct kmem_cache_cpu *c)
>  {
> -	void **object;
> +	void *freelist;
>  	unsigned long flags;
>  
>  	local_irq_save(flags);
> @@ -2175,6 +2175,7 @@ static void *__slab_alloc(struct kmem_ca
>  	if (!c->page)
>  		goto new_slab;
>  redo:
> +
>  	if (unlikely(!node_match(c, node))) {
>  		stat(s, ALLOC_NODE_MISMATCH);
>  		deactivate_slab(s, c->page, c->freelist);

I don't think we need this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
