Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 7AF606B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 11:34:27 -0500 (EST)
Date: Wed, 8 Feb 2012 16:34:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20120208163421.GL5938@suse.de>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
 <1328568978-17553-3-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1202071025050.30652@router.home>
 <20120208144506.GI5938@suse.de>
 <alpine.DEB.2.00.1202080907320.30248@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202080907320.30248@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Feb 08, 2012 at 09:14:32AM -0600, Christoph Lameter wrote:
> On Wed, 8 Feb 2012, Mel Gorman wrote:
> 
> > o struct kmem_cache_cpu could be left alone even though it's a small saving
> 
> Its multiplied by the number of caches and by the number of
> processors.
> 
> > o struct slab also be left alone
> > o struct array_cache could be left alone although I would point out that
> >   it would make no difference in size as touched is changed to a bool to
> >   fit pfmemalloc in
> 
> Both of these are performance critical structures in slab.
> 

Ok, I looked into what is necessary to replace these with checking a page
flag and the cost shifts quite a bit and ends up being more expensive.

Right now, I use array_cache to record if there are any pfmemalloc
objects in the free list at all. If there are not, no expensive checks
are made. For example, in __ac_put_obj(), I check ac->pfmemalloc to see
if an expensive check is required. Using a page flag, the same check
requires a lookup with virt_to_page(). This in turns uses a
pfn_to_page() which depending on the memory model can be very expensive.
No matter what, it's more expensive than a simple check and this is in
the slab free path.

It is more complicated in check_ac_pfmemalloc() too although the performance
impact is less because it is a slow path. If ac->pfmemalloc is false,
the check of each slabp can be avoided. Without it, all the slabps must
be checked unconditionally and each slabp that is checked must call
virt_to_page().

Overall, the memory savings of moving to a page flag are miniscule but
the performance cost is far higher because of the use of virt_to_page().

> > o It would still be necessary to do the object pointer tricks in slab.c
> 
> These trick are not done for slub. It seems that they are not necessary?
> 

In slub, it's sufficient to check kmem_cache_cpu to know whether the
objects in the list are pfmemalloc or not.

> > remain. However, the downside of requiring a page flag is very high. In
> > the event we increase the number of page flags - great, I'll use one but
> > right now I do not think the use of page flag is justified.
> 
> On 64 bit I think there is not much of an issue with another page flag.
> 

There isn't, but on 32 bit there is.

> Also consider that the slab allocators do not make full use of the other
> page flags. We could overload one of the existing flags. I removed
> slubs use of them last year. PG_active could be overloaded I think.
> 

Yeah, you're right on the button there. I did my checking assuming that
PG_active+PG_slab were safe to use. The following is an untested patch that
I probably got details wrong in but it illustrates where virt_to_page()
starts cropping up.

It was a good idea and thanks for thinking of it but unfortunately the
implementation would be more expensive than what I have currently.


diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e90a673..108f3ce 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -432,6 +432,35 @@ static inline int PageTransCompound(struct page *page)
 }
 #endif
 
+#ifdef CONFIG_NFS_SWAP
+static inline int PageSlabPfmemalloc(struct page *page)
+{
+	VM_BUG_ON(!PageSlab(page));
+	return PageActive(page);
+}
+
+static inline void SetPageSlabPfmemalloc(struct page *page)
+{
+	VM_BUG_ON(!PageSlab(page));
+	SetPageActive(page);
+}
+
+static inline void ClearPageSlabPfmemalloc(struct page *page)
+{
+	VM_BUG_ON(!PageSlab(page));
+	ClearPageActive(page);
+}
+#else
+static inline int PageSlabPfmemalloc(struct page *page)
+{
+	return 0;
+}
+
+static inline void SetPageSlabPfmemalloc(struct page *page)
+{
+}
+#endif
+
 #ifdef CONFIG_MMU
 #define __PG_MLOCKED		(1 << PG_mlocked)
 #else
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 1d9ae40..a32bcfd 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -46,7 +46,6 @@ struct kmem_cache_cpu {
 	struct page *page;	/* The slab from which we are allocating */
 	struct page *partial;	/* Partially allocated frozen slabs */
 	int node;		/* The node of the page (or -1 for debug) */
-	bool pfmemalloc;	/* Slab page had pfmemalloc set */
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
diff --git a/mm/slab.c b/mm/slab.c
index 268cd96..3012186 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -233,7 +233,6 @@ struct slab {
 			unsigned int inuse;	/* num of objs active in slab */
 			kmem_bufctl_t free;
 			unsigned short nodeid;
-			bool pfmemalloc;	/* Slab had pfmemalloc set */
 		};
 		struct slab_rcu __slab_cover_slab_rcu;
 	};
@@ -255,8 +254,7 @@ struct array_cache {
 	unsigned int avail;
 	unsigned int limit;
 	unsigned int batchcount;
-	bool touched;
-	bool pfmemalloc;
+	unsigned int touched;
 	spinlock_t lock;
 	void *entry[];	/*
 			 * Must have this definition in here for the proper
@@ -978,6 +976,13 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 	return nc;
 }
 
+static inline bool is_slab_pfmemalloc(struct slab *slabp)
+{
+	struct page *page = virt_to_page(slabp->s_mem);
+
+	return PageSlabPfmemalloc(page);
+}
+
 /* Clears ac->pfmemalloc if no slabs have pfmalloc set */
 static void check_ac_pfmemalloc(struct kmem_cache *cachep,
 						struct array_cache *ac)
@@ -985,22 +990,18 @@ static void check_ac_pfmemalloc(struct kmem_cache *cachep,
 	struct kmem_list3 *l3 = cachep->nodelists[numa_mem_id()];
 	struct slab *slabp;
 
-	if (!ac->pfmemalloc)
-		return;
-
 	list_for_each_entry(slabp, &l3->slabs_full, list)
-		if (slabp->pfmemalloc)
+		if (is_slab_pfmemalloc(slabp))
 			return;
 
 	list_for_each_entry(slabp, &l3->slabs_partial, list)
-		if (slabp->pfmemalloc)
+		if (is_slab_pfmemalloc(slabp))
 			return;
 
 	list_for_each_entry(slabp, &l3->slabs_free, list)
-		if (slabp->pfmemalloc)
+		if (is_slab_pfmemalloc(slabp))
 			return;
 
-	ac->pfmemalloc = false;
 }
 
 static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
@@ -1036,7 +1037,7 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		l3 = cachep->nodelists[numa_mem_id()];
 		if (!list_empty(&l3->slabs_free) && force_refill) {
 			struct slab *slabp = virt_to_slab(objp);
-			slabp->pfmemalloc = false;
+			ClearPageSlabPfmemalloc(virt_to_page(slabp->s_mem));
 			clear_obj_pfmemalloc(&objp);
 			check_ac_pfmemalloc(cachep, ac);
 			return objp;
@@ -1066,15 +1067,11 @@ static inline void *ac_get_obj(struct kmem_cache *cachep,
 static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
 								void *objp)
 {
-	struct slab *slabp;
+	struct page *page = virt_to_page(objp);
 
 	/* If there are pfmemalloc slabs, check if the object is part of one */
-	if (unlikely(ac->pfmemalloc)) {
-		slabp = virt_to_slab(objp);
-
-		if (slabp->pfmemalloc)
-			set_obj_pfmemalloc(&objp);
-	}
+	if (PageSlabPfmemalloc(page))
+		set_obj_pfmemalloc(&objp);
 
 	return objp;
 }
@@ -1906,9 +1903,13 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	else
 		add_zone_page_state(page_zone(page),
 			NR_SLAB_UNRECLAIMABLE, nr_pages);
-	for (i = 0; i < nr_pages; i++)
+	for (i = 0; i < nr_pages; i++) {
 		__SetPageSlab(page + i);
 
+		if (*pfmemalloc)
+			SetPageSlabPfmemalloc(page);
+	}
+
 	if (kmemcheck_enabled && !(cachep->flags & SLAB_NOTRACK)) {
 		kmemcheck_alloc_shadow(page, cachep->gfporder, flags, nodeid);
 
@@ -2888,7 +2889,6 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep, void *objp,
 	slabp->s_mem = objp + colour_off;
 	slabp->nodeid = nodeid;
 	slabp->free = 0;
-	slabp->pfmemalloc = false;
 	return slabp;
 }
 
@@ -3074,13 +3074,6 @@ static int cache_grow(struct kmem_cache *cachep,
 	if (!slabp)
 		goto opps1;
 
-	/* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
-	if (pfmemalloc) {
-		struct array_cache *ac = cpu_cache_get(cachep);
-		slabp->pfmemalloc = true;
-		ac->pfmemalloc = true;
-	}
-
 	slab_map_pages(cachep, slabp, objp);
 
 	cache_init_objs(cachep, slabp);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
