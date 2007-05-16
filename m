Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705161235490.10660@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
	 <20070514161224.GC11115@waste.org>
	 <Pine.LNX.4.64.0705140927470.10801@schroedinger.engr.sgi.com>
	 <1179164453.2942.26.camel@lappy>
	 <Pine.LNX.4.64.0705141051170.11251@schroedinger.engr.sgi.com>
	 <1179170912.2942.37.camel@lappy> <1179250036.7173.7.camel@twins>
	 <Pine.LNX.4.64.0705151457060.3155@schroedinger.engr.sgi.com>
	 <1179298771.7173.16.camel@twins>
	 <Pine.LNX.4.64.0705161139540.10265@schroedinger.engr.sgi.com>
	 <1179343521.2912.20.camel@lappy>
	 <Pine.LNX.4.64.0705161235490.10660@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 16 May 2007 22:18:58 +0200
Message-Id: <1179346738.2912.39.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-16 at 12:53 -0700, Christoph Lameter wrote:
> On Wed, 16 May 2007, Peter Zijlstra wrote:
> 
> > If this 4k cpu system ever gets to touch the new lock it is in way
> > deeper problems than a bouncing cache-line.
> 
> So its no use on NUMA?

It is, its just that we're swapping very heavily at that point, a
bouncing cache-line will not significantly slow down the box compared to
waiting for block IO, will it?

> > Please look at it more carefully.
> > 
> > We differentiate pages allocated at the level where GFP_ATOMIC starts to
> > fail. By not updating the percpu slabs those are retried every time,
> > except for ALLOC_NO_WATERMARKS allocations; those are served from the
> > ->reserve_slab.
> > 
> > Once a regular slab allocation succeeds again, the ->reserve_slab is
> > cleaned up and never again looked at it until we're in distress again.
> 
> A single slab? This may only give you a a single object in an extreme 
> case. Are you sure that this solution is generic enough?

Well, single as in a single active; it gets spilled into the full list
and a new one is instanciated if more is needed.

> The problem here is that you may spinlock and take out the slab for one 
> cpu but then (AFAICT) other cpus can still not get their high priority 
> allocs satisfied. Some comments follow.

All cpus are redirected to ->reserve_slab when the regular allocations
start to fail.

> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > ---
> >  include/linux/slub_def.h |    2 +
> >  mm/slub.c                |   85 ++++++++++++++++++++++++++++++++++++++++++-----
> >  2 files changed, 78 insertions(+), 9 deletions(-)
> > 
> > Index: linux-2.6-git/include/linux/slub_def.h
> > ===================================================================
> > --- linux-2.6-git.orig/include/linux/slub_def.h
> > +++ linux-2.6-git/include/linux/slub_def.h
> > @@ -46,6 +46,8 @@ struct kmem_cache {
> >  	struct list_head list;	/* List of slab caches */
> >  	struct kobject kobj;	/* For sysfs */
> >  
> > +	struct page *reserve_slab;
> > +
> >  #ifdef CONFIG_NUMA
> >  	int defrag_ratio;
> >  	struct kmem_cache_node *node[MAX_NUMNODES];
> > Index: linux-2.6-git/mm/slub.c
> > ===================================================================
> > --- linux-2.6-git.orig/mm/slub.c
> > +++ linux-2.6-git/mm/slub.c
> > @@ -20,11 +20,13 @@
> >  #include <linux/mempolicy.h>
> >  #include <linux/ctype.h>
> >  #include <linux/kallsyms.h>
> > +#include "internal.h"
> >  
> >  /*
> >   * Lock order:
> > - *   1. slab_lock(page)
> > - *   2. slab->list_lock
> > + *   1. reserve_lock
> > + *   2. slab_lock(page)
> > + *   3. node->list_lock
> >   *
> >   *   The slab_lock protects operations on the object of a particular
> >   *   slab and its metadata in the page struct. If the slab lock
> > @@ -259,6 +261,8 @@ static int sysfs_slab_alias(struct kmem_
> >  static void sysfs_slab_remove(struct kmem_cache *s) {}
> >  #endif
> >  
> > +static DEFINE_SPINLOCK(reserve_lock);
> > +
> >  /********************************************************************
> >   * 			Core slab cache functions
> >   *******************************************************************/
> > @@ -1007,7 +1011,7 @@ static void setup_object(struct kmem_cac
> >  		s->ctor(object, s, 0);
> >  }
> >  
> > -static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
> > +static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, int *rank)
> >  {
> >  	struct page *page;
> >  	struct kmem_cache_node *n;
> > @@ -1025,6 +1029,7 @@ static struct page *new_slab(struct kmem
> >  	if (!page)
> >  		goto out;
> >  
> > +	*rank = page->rank;
> >  	n = get_node(s, page_to_nid(page));
> >  	if (n)
> >  		atomic_long_inc(&n->nr_slabs);
> > @@ -1311,7 +1316,7 @@ static void unfreeze_slab(struct kmem_ca
> >  /*
> >   * Remove the cpu slab
> >   */
> > -static void deactivate_slab(struct kmem_cache *s, struct page *page, int cpu)
> > +static void __deactivate_slab(struct kmem_cache *s, struct page *page)
> >  {
> >  	/*
> >  	 * Merge cpu freelist into freelist. Typically we get here
> > @@ -1330,10 +1335,15 @@ static void deactivate_slab(struct kmem_
> >  		page->freelist = object;
> >  		page->inuse--;
> >  	}
> > -	s->cpu_slab[cpu] = NULL;
> >  	unfreeze_slab(s, page);
> >  }
> 
> So you want to spill back the lockless_freelist without deactivating the 
> slab? Why are you using the lockless_freelist at all? If you do not use it 
> then you can call unfreeze_slab. No need for this split.

Ah, quite right. I do indeed not use the lockless_freelist.

> > @@ -1395,6 +1405,7 @@ static void *__slab_alloc(struct kmem_ca
> >  {
> >  	void **object;
> >  	int cpu = smp_processor_id();
> > +	int rank = 0;
> >  
> >  	if (!page)
> >  		goto new_slab;
> > @@ -1424,10 +1435,26 @@ new_slab:
> >  	if (page) {
> >  		s->cpu_slab[cpu] = page;
> >  		goto load_freelist;
> > -	}
> > +	} else if (unlikely(gfp_to_alloc_flags(gfpflags) & ALLOC_NO_WATERMARKS))
> > +		goto try_reserve;
> 
> Ok so we are trying to allocate a slab and do not get one thus -> 
> try_reserve. 

Right, so the cpu-slab is NULL, and we need a new slab.

> But this is only working if we are using the slab after
> explicitly flushing the cpuslabs. Otherwise the slab may be full and we
> get to alloc_slab.

/me fails to parse.

When we need a new_slab: 
 - we try the partial lists,
 - we try the reserve (if ALLOC_NO_WATERMARKS)
   otherwise alloc_slab

> >  
> > -	page = new_slab(s, gfpflags, node);
> > -	if (page) {
> 
> > +alloc_slab:
> > +	page = new_slab(s, gfpflags, node, &rank);
> > +	if (page && rank) {
> 
> Huh? You mean !page?

No, no, we did get a page, and it was !ALLOC_NO_WATERMARK hard to get
it. 

> > +		if (unlikely(s->reserve_slab)) {
> > +			struct page *reserve;
> > +
> > +			spin_lock(&reserve_lock);
> > +			reserve = s->reserve_slab;
> > +			s->reserve_slab = NULL;
> > +			spin_unlock(&reserve_lock);
> > +
> > +			if (reserve) {
> > +				slab_lock(reserve);
> > +				__deactivate_slab(s, reserve);
> > +				putback_slab(s, reserve);
> 
> Remove the above two lines (they are wrong regardless) and simply make 
> this the cpu slab.

It need not be the same node; the reserve_slab is node agnostic.
So here the free page watermarks are good again, and we can forget all
about the ->reserve_slab. We just push it on the free/partial lists and
forget about it.

But like you said above: unfreeze_slab() should be good, since I don't
use the lockless_freelist.

> > +			}
> > +		}
> >  		cpu = smp_processor_id();
> >  		if (s->cpu_slab[cpu]) {
> >  			/*
> > @@ -1455,6 +1482,18 @@ new_slab:
> >  		SetSlabFrozen(page);
> >  		s->cpu_slab[cpu] = page;
> >  		goto load_freelist;
> > +	} else if (page) {
> > +		spin_lock(&reserve_lock);
> > +		if (s->reserve_slab) {
> > +			discard_slab(s, page);
> > +			page = s->reserve_slab;
> > +		}
> > +		slab_lock(page);
> > +		SetPageActive(page);
> > +		s->reserve_slab = page;
> > +		spin_unlock(&reserve_lock);
> > +
> > +		goto got_reserve;

So this is when we get a page and it was ALLOC_NO_WATERMARKS hard to get
it. Instead of updating the cpu_slab we leave that unset, so that
subsequent allocations will try to allocate a slab again thereby testing
the current free pages limit (and not gobble up the reserve).

> >  	}
> >  	return NULL;
> >  debug:
> > @@ -1470,6 +1509,31 @@ debug:
> >  	page->freelist = object[page->offset];
> >  	slab_unlock(page);
> >  	return object;
> > +
> > +try_reserve:
> > +	spin_lock(&reserve_lock);
> > +	page = s->reserve_slab;
> > +	if (!page) {
> > +		spin_unlock(&reserve_lock);
> > +		goto alloc_slab;
> > +	}
> > +
> > +	slab_lock(page);
> > +	if (!page->freelist) {
> > +		s->reserve_slab = NULL;
> > +		spin_unlock(&reserve_lock);
> > +		__deactivate_slab(s, page);
> replace with unfreeze slab.
> 
> > +		putback_slab(s, page);
> 
> Putting back the slab twice.

__deactivete_slab() doesn't do putback_slab, and now I see that whole
function isn't there anymore. unfreeze_slab() it is.

> > +		goto alloc_slab;
> > +	}
> > +	spin_unlock(&reserve_lock);
> > +
> > +got_reserve:
> > +	object = page->freelist;
> > +	page->inuse++;
> > +	page->freelist = object[page->offset];
> > +	slab_unlock(page);
> > +	return object;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
