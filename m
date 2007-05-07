Date: Mon, 7 May 2007 14:50:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Support concurrent local and remote frees and allocs on a slab.
Message-Id: <20070507145030.9b7f41bd.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705042025520.29006@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705042025520.29006@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007 20:28:41 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> About 5-10% performance gain on netperf.
> 
> [Maybe put this patch at the end of the merge queue? Works fine here but
> this is a significant change that may impact stability]
> 
> What we do is use the last free field in the page struct (the private
> field that was freed up through the compound page flag rework) to setup a
> separate per cpu freelist. From that one we can allocate without taking the
> slab lock because we checkout the complete list of free objects when we
> first touch the slab and then mark the slab as completely allocated.
> If we have a cpu_freelist then we can also free to that list if we run on
> that processor without taking the slab lock.
> 
> This allows even concurrent allocations and frees on the same slab using
> two mutually exclusive freelists. Allocs and frees from the processor
> owning the per cpu slab will bypass the slab lock using the cpu_freelist.
> Remove frees will use the slab lock to synchronize and use the freelist
> for marking items as free. So local allocs and frees may run concurrently
> with remote frees without synchronization.
> 
> If the allocator is running out of its per cpu freelist then it will consult
> the per slab freelist (which requires the slab lock) and reload the
> cpu_freelist if there are objects that were remotely freed.
> 

I must say that I'm getting increasingly foggy about what the slub data
structures are.  That was my problem with slab, too: it's hard to get a
picture in one's head.

Is there some way in which we can communicate this better?  It is quite
central to maintainability.

> 
> ---
>  include/linux/mm_types.h |    5 ++-
>  mm/slub.c                |   67 ++++++++++++++++++++++++++++++++++++++---------
>  2 files changed, 59 insertions(+), 13 deletions(-)
> 
> Index: slub/include/linux/mm_types.h
> ===================================================================
> --- slub.orig/include/linux/mm_types.h	2007-05-04 20:09:26.000000000 -0700
> +++ slub/include/linux/mm_types.h	2007-05-04 20:09:33.000000000 -0700
> @@ -50,9 +50,12 @@ struct page {
>  	    spinlock_t ptl;
>  #endif
>  	    struct {			/* SLUB uses */
> -		struct page *first_page;	/* Compound pages */
> +	    	void **cpu_freelist;		/* Per cpu freelist */
>  		struct kmem_cache *slab;	/* Pointer to slab */
>  	    };
> +	    struct {
> +		struct page *first_page;	/* Compound pages */
> +	    };
>  	};

This change implies that "first_page" is no longer a "SLUB use".  Is that
true?

I'm a bit surprised that slub didn't already have a per-cpu freelist of
objects?

Each cache has this "cpu_slab" thing, which is not documented anywhere
afaict.  What does it do, and how does this change enhance it?

(I'm not really asking for a reply-by-email, btw.  This is more a "this is
what people will wonder when they read your code.  Please ensure tha the
answers are there for them" thing.)

>  	union {
>  		pgoff_t index;		/* Our offset within mapping. */
> Index: slub/mm/slub.c
> ===================================================================
> --- slub.orig/mm/slub.c	2007-05-04 20:09:26.000000000 -0700
> +++ slub/mm/slub.c	2007-05-04 20:14:04.000000000 -0700
> @@ -81,10 +81,13 @@
>   * PageActive 		The slab is used as a cpu cache. Allocations
>   * 			may be performed from the slab. The slab is not
>   * 			on any slab list and cannot be moved onto one.
> + * 			The cpu slab may have a cpu_freelist in order
> + * 			to optimize allocations and frees on a particular
> + * 			cpu.
>   *
>   * PageError		Slab requires special handling due to debug
>   * 			options set. This moves	slab handling out of
> - * 			the fast path.
> + * 			the fast path and disables cpu_freelists.
>   */
>  
>  /*
> @@ -857,6 +860,7 @@ static struct page *new_slab(struct kmem
>  	set_freepointer(s, last, NULL);
>  
>  	page->freelist = start;
> +	page->cpu_freelist = NULL;
>  	page->inuse = 0;
>  out:
>  	if (flags & __GFP_WAIT)
> @@ -1121,6 +1125,23 @@ static void putback_slab(struct kmem_cac
>   */
>  static void deactivate_slab(struct kmem_cache *s, struct page *page, int cpu)
>  {
> +	/*
> +	 * Merge cpu freelist into freelist. Typically we get here
> +	 * because both freelists are empty. So this is unlikely
> +	 * to occur.
> +	 */
> +	while (unlikely(page->cpu_freelist)) {
> +		void **object;
> +
> +		/* Retrieve object from cpu_freelist */
> +		object = page->cpu_freelist;
> +		page->cpu_freelist = page->cpu_freelist[page->offset];
> +
> +		/* And put onto the regular freelist */
> +		object[page->offset] = page->freelist;
> +		page->freelist = object;
> +		page->inuse--;
> +	}

page.offset doesn't appear to be documented anywhere?

So what is pointed at by page->cpu_freelist?  It appears to point at an
array of pointers to recently-used objects.  But where does the storage for
that array come from?  All a bit mysterious.

btw, does this code, in slab_alloc()

	if (unlikely(node != -1 && page_to_nid(page) != node)) {
							
get appropriately optimised away on non-NUMA?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
