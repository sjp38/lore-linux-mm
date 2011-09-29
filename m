Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 342189000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 10:32:34 -0400 (EDT)
Date: Thu, 29 Sep 2011 09:32:29 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slub Discard slab page only when node partials > minimum
 setting
In-Reply-To: <1317290032.4188.1223.camel@debian>
Message-ID: <alpine.DEB.2.00.1109290927590.9848@router.home>
References: <1315188460.31737.5.camel@debian>  <alpine.DEB.2.00.1109061914440.18646@router.home>  <1315357399.31737.49.camel@debian>  <alpine.DEB.2.00.1109062022100.20474@router.home>  <4E671E5C.7010405@cs.helsinki.fi>
 <6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>  <alpine.DEB.2.00.1109071003240.9406@router.home>  <1315442639.31737.224.camel@debian>  <alpine.DEB.2.00.1109081336320.14787@router.home>  <1315557944.31737.782.camel@debian>
 <1315902583.31737.848.camel@debian>  <CALmdxiMuF6Q0W4ZdvhK5c4fQs8wUjcVGWYGWBjJi7WOfLYX=Gw@mail.gmail.com>  <1316050363.8425.483.camel@debian>  <CALmdxiMrDNDvhAmi88-0-1KBdyTwExZPy3Fh9_5TxB+XhK7vjw@mail.gmail.com>  <1316052031.8425.491.camel@debian>
 <1316765880.4188.34.camel@debian>  <alpine.DEB.2.00.1109231500580.15559@router.home> <1317290032.4188.1223.camel@debian>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY="=-uEMFxVrfQBLAouPqmEbo"
Content-ID: <alpine.DEB.2.00.1109290927591.9848@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>"Huang, Ying" <ying.huang@intel.com>, Andi Kleen <ak@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--=-uEMFxVrfQBLAouPqmEbo
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1109290927592.9848@router.home>

On Thu, 29 Sep 2011, Alex,Shi wrote:

> > Is it really worth it? The higher the value the higher the potential
> > memory that is stuck in the per cpu partial pages?
>
> It is hard to find best balance. :)

Well then lets err on the side of smaller memory use for now.

> I am tested aim9/netperf, both of them was said related to memory
> allocation, but didn't find performance change with/without PCP. Seems
> only hackbench sensitive on this. As to aim9, whichever with ourself
> configuration, or with Mel Gorman's aim9 configuration from his mmtest,
> both of them has no clear performance change for PCP slub.

AIM9 tests are usually single threaded so I would not expect any
differences. Try AIM7? And concurrent netperfs?

The PCP patch helps only if there is node lock contention. Meaning
simultaneous allocations/frees from multiple processor from the same
cache.

> Checking the kernel function call graphic via perf record/perf report,
> slab function only be used much in hackbench benchmark.

Then the question arises if its worthwhile merging if it only affects this
benchmark.

> Above is what I did this week for PCP.
>
> BTW, I will take my one week holiday from tomorrow. e-mail access will
> be slow.

Have a nice holiday.
--=-uEMFxVrfQBLAouPqmEbo
Content-Type: TEXT/X-PATCH; NAME=patch-pcpnodump; CHARSET=UTF-8
Content-ID: <alpine.DEB.2.00.1109290927593.9848@router.home>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=patch-pcpnodump

diff --git a/mm/slub.c b/mm/slub.c

index 492beab..372f219 100644

--- a/mm/slub.c

+++ b/mm/slub.c

@@ -1613,7 +1613,7 @@ static void *get_partial_node(struct kmem_cache *s,

 	spin_lock(&n->list_lock);

 	list_for_each_entry_safe(page, page2, &n->partial, lru) {

 		void *t = acquire_slab(s, n, page, object == NULL);

-		int available;

+		int available = 1;

 

 		if (!t)

 			continue;

@@ -1623,12 +1623,14 @@ static void *get_partial_node(struct kmem_cache *s,

 			c->node = page_to_nid(page);

 			stat(s, ALLOC_FROM_PARTIAL);

 			object = t;

-			available =  page->objects - page->inuse;

 		} else {

 			page->freelist = t;

 			available = put_cpu_partial(s, page, 0);

+			if(!available)

+				add_partial(n, page, 0);

+				

 		}

-		if (kmem_cache_debug(s) || available > s->cpu_partial / 2)

+		if (kmem_cache_debug(s) || !available)

 			break;

 

 	}

@@ -2017,17 +2019,10 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)

 		if (oldpage) {

 			pobjects = oldpage->pobjects;

 			pages = oldpage->pages;

-			if (drain && pobjects > s->cpu_partial) {

-				unsigned long flags;

-				/*

-				 * partial array is full. Move the existing

-				 * set to the per node partial list.

-				 */

-				local_irq_save(flags);

-				unfreeze_partials(s);

-				local_irq_restore(flags);

+			if (pobjects > s->cpu_partial) {

 				pobjects = 0;

-				pages = 0;

+				page->frozen = 0;

+				break;

 			}

 		}

 

@@ -2039,7 +2034,10 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)

 		page->next = oldpage;

 

 	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);

-	stat(s, CPU_PARTIAL_FREE);

+

+	if(pobjects)

+		stat(s, CPU_PARTIAL_FREE);

+

 	return pobjects;

 }

 

@@ -2472,6 +2470,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,

 		new.inuse--;

 		if ((!new.inuse || !prior) && !was_frozen && !n) {

 

+

 			if (!kmem_cache_debug(s) && !prior)

 

 				/*

@@ -2482,7 +2481,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,

 

 			else { /* Needs to be taken off a list */

 

-	                        n = get_node(s, page_to_nid(page));

+				n = get_node(s, page_to_nid(page));

 				/*

 				 * Speculatively acquire the list_lock.

 				 * If the cmpxchg does not succeed then we may

@@ -2492,8 +2491,8 @@ static void __slab_free(struct kmem_cache *s, struct page *page,

 				 * other processors updating the list of slabs.

 				 */

 				spin_lock_irqsave(&n->list_lock, flags);

-

 			}

+

 		}

 		inuse = new.inuse;

 

@@ -2503,23 +2502,23 @@ static void __slab_free(struct kmem_cache *s, struct page *page,

 		"__slab_free"));

 

 	if (likely(!n)) {

-

-		/*

-		 * If we just froze the page then put it onto the

-		 * per cpu partial list.

-		 */

 		if (new.frozen && !was_frozen)

-			put_cpu_partial(s, page, 1);

+			if (!put_cpu_partial(s, page, 1)){

+				n = get_node(s, page_to_nid(page));

+				spin_lock_irqsave(&n->list_lock, flags);

+				goto get_lock;

+			}

 

 		/*

 		 * The list lock was not taken therefore no list

 		 * activity can be necessary.

 		 */

-                if (was_frozen)

-                        stat(s, FREE_FROZEN);

-                return;

-        }

+		if (was_frozen)

+			stat(s, FREE_FROZEN);

+		return;

+	}

 

+get_lock:

 	/*

 	 * was_frozen may have been set after we acquired the list_lock in

 	 * an earlier loop. So we need to check it here again.

@@ -2536,7 +2535,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,

 		 */

 		if (unlikely(!prior)) {

 			remove_full(s, page);

-			add_partial(n, page, 0);

+			add_partial(n, page, 1);

 			stat(s, FREE_ADD_PARTIAL);

 		}

 	}


--=-uEMFxVrfQBLAouPqmEbo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
