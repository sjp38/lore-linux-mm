Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C082D9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 05:49:05 -0400 (EDT)
Subject: Re: [PATCH] slub Discard slab page only when node partials >
 minimum setting
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <alpine.DEB.2.00.1109231500580.15559@router.home>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
	 <1315357399.31737.49.camel@debian>
	 <alpine.DEB.2.00.1109062022100.20474@router.home>
	 <4E671E5C.7010405@cs.helsinki.fi>
	 <6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>
	 <alpine.DEB.2.00.1109071003240.9406@router.home>
	 <1315442639.31737.224.camel@debian>
	 <alpine.DEB.2.00.1109081336320.14787@router.home>
	 <1315557944.31737.782.camel@debian> <1315902583.31737.848.camel@debian>
	 <CALmdxiMuF6Q0W4ZdvhK5c4fQs8wUjcVGWYGWBjJi7WOfLYX=Gw@mail.gmail.com>
	 <1316050363.8425.483.camel@debian>
	 <CALmdxiMrDNDvhAmi88-0-1KBdyTwExZPy3Fh9_5TxB+XhK7vjw@mail.gmail.com>
	 <1316052031.8425.491.camel@debian> <1316765880.4188.34.camel@debian>
	 <alpine.DEB.2.00.1109231500580.15559@router.home>
Content-Type: multipart/mixed; boundary="=-uEMFxVrfQBLAouPqmEbo"
Date: Thu, 29 Sep 2011 17:53:52 +0800
Message-ID: <1317290032.4188.1223.camel@debian>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>"Huang, Ying" <ying.huang@intel.com>, Andi Kleen <ak@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


--=-uEMFxVrfQBLAouPqmEbo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Sat, 2011-09-24 at 04:02 +0800, Christoph Lameter wrote:
> On Fri, 23 Sep 2011, Alex,Shi wrote:
> 
> > Just did a little bit work on this. I tested hackbench with difference
> > cpu_partial values. The value set in kmem_cache_open(), tried 1/2, 2
> > times, 8 times, 32 times and 128 times original value. Seems the 8 times
> > value has a slight better performance on almost of my machines,
> > nhm-ex/nhm-ep/wsm-ep.
> 
> Is it really worth it? The higher the value the higher the potential
> memory that is stuck in the per cpu partial pages?

It is hard to find best balance. :) 
> 
> > It needs to do far more test on this tunning. I am going to seek more
> > benchmarks next week. and try tune on different cpu_partial size and
> > code path.
> 
> Thanks for all your efforts.

I am tested aim9/netperf, both of them was said related to memory
allocation, but didn't find performance change with/without PCP. Seems
only hackbench sensitive on this. As to aim9, whichever with ourself
configuration, or with Mel Gorman's aim9 configuration from his mmtest,
both of them has no clear performance change for PCP slub. 

Checking the kernel function call graphic via perf record/perf report,
slab function only be used much in hackbench benchmark. 

I also tried different code path
1, remove the s->cpu_partial limitation, performance drop 30% on
"hackbench 100 process 2000"

2, don't dump cpu partial into node partial, on the contrary, don't fill
cpu partial if it's larger than s->cpu_partial. but no positive
performance change for this, and seems a little bit low on 4 sockets
machines. 

3, don't dump cpu partial into node partial, and only fill cpu partial
in allocation when cpu partial is less then s->cpu_partial. insert free
slab into node partial in __slab_free() directly. No clear performance
change for this.  BTW, actually, this purpose won't reduce the node
partial lock times. 

My experiment patch for new code path 2,3, need to disable VM_BUG_ON
since frozen has a short time incoherence. and may left empty slabs
after slab free. so it just a experiment patch. The attachment is for
code path 2. 

Above is what I did this week for PCP. 

BTW, I will take my one week holiday from tomorrow. e-mail access will
be slow. 


--=-uEMFxVrfQBLAouPqmEbo
Content-Disposition: attachment; filename="patch-pcpnodump"
Content-Type: text/x-patch; name="patch-pcpnodump"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

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
