Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 1AAA76B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 07:50:24 -0500 (EST)
Date: Thu, 9 Feb 2012 12:50:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20120209125018.GN5938@suse.de>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
 <1328568978-17553-3-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1202071025050.30652@router.home>
 <20120208144506.GI5938@suse.de>
 <alpine.DEB.2.00.1202080907320.30248@router.home>
 <20120208163421.GL5938@suse.de>
 <alpine.DEB.2.00.1202081338210.32060@router.home>
 <20120208212323.GM5938@suse.de>
 <alpine.DEB.2.00.1202081557540.5970@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202081557540.5970@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Feb 08, 2012 at 04:13:15PM -0600, Christoph Lameter wrote:
> On Wed, 8 Feb 2012, Mel Gorman wrote:
> 
> > On Wed, Feb 08, 2012 at 01:49:05PM -0600, Christoph Lameter wrote:
> > > On Wed, 8 Feb 2012, Mel Gorman wrote:
> > >
> > > > Ok, I looked into what is necessary to replace these with checking a page
> > > > flag and the cost shifts quite a bit and ends up being more expensive.
> > >
> > > That is only true if you go the slab route.
> >
> > Well, yes but both slab and slub have to be supported. I see no reason
> > why I would choose to make this a slab-only or slub-only feature. Slob is
> > not supported because it's not expected that a platform using slob is also
> > going to use network-based swap.
> 
> I think so far the patches in particular to slab.c are pretty significant
> in impact.
> 

Ok, I am working on a solution that does not affect any of the existing
slab structures. Between that and the fact we check if there are any
memalloc_socks after patch 12, the impact for normal systems is an additional
branch in ac_get_obj() and ac_put_obj()

> > > Slab suffers from not having
> > > the page struct pointer readily available. The changes are likely already
> > > impacting slab performance without the virt_to_page patch.
> > >
> >
> > The performance impact only comes into play when swap is on a network
> > device and pfmemalloc reserves are in use. The rest of the time the check
> > on ac avoids all the cost and there is a micro-optimisation later to avoid
> > calling a function (patch 12).
> 
> We have been down this road too many times. Logic is added to critical
> paths and memory structures grow. This is not free. And for NBD swap
> support? Pretty exotic use case.
> 

NFS support is the real target. NBD is the logical starting point and
NFS needs the same support.

> > Ok, are you asking that I use the page flag for slub and leave kmem_cache_cpu
> > alone in the slub case? I can certainly check it out if that's what you
> > are asking for.
> 
> No I am not asking for something. Still thinking about the best way to
> address the issues. I think we can easily come up with a minimally
> invasive patch for slub. Not sure about slab at this point. I think we
> could avoid most of the new fields but this requires some tinkering. I
> have a day @ home tomorrow which hopefully gives me a chance to
> put some focus on this issue.
>

I think we can avoid adding any additional fields but array_cache needs
a new read-mostly global. Also, when network storage is in use and under
memory pressure, it might be slower as we will have lost granularity on
what slabs are using pfmemalloc. That is an acceptable compromise as it
moves the cost to users of network-based swap instead of normal usage.
 
> > I did come up with a way: the necessary information is in ac and slabp
> > on slab :/ . There are not exactly many ways that the information can
> > be recorded.
> 
> Wish we had something that would not involve increasing the number of
> fields in these slab structures.
> 

This is what I currently have. It's untested but builds. It reverts the
structures back to the way they were and uses page flags instead.

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e90a673..f96fa87 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -432,6 +432,28 @@ static inline int PageTransCompound(struct page *page)
 }
 #endif
 
+/*
+ * If network-based swap is enabled, sl*b must keep track of whether pages
+ * were allocated from pfmemalloc reserves.
+ */
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
index 268cd96..783a92e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -155,6 +155,12 @@
 #define ARCH_KMALLOC_FLAGS SLAB_HWCACHE_ALIGN
 #endif
 
+/*
+ * true if a page was allocated from pfmemalloc reserves for network-based
+ * swap
+ */
+static bool pfmemalloc_active;
+
 /* Legal flag mask for kmem_cache_create(). */
 #if DEBUG
 # define CREATE_MASK	(SLAB_RED_ZONE | \
@@ -233,7 +239,6 @@ struct slab {
 			unsigned int inuse;	/* num of objs active in slab */
 			kmem_bufctl_t free;
 			unsigned short nodeid;
-			bool pfmemalloc;	/* Slab had pfmemalloc set */
 		};
 		struct slab_rcu __slab_cover_slab_rcu;
 	};
@@ -255,8 +260,7 @@ struct array_cache {
 	unsigned int avail;
 	unsigned int limit;
 	unsigned int batchcount;
-	bool touched;
-	bool pfmemalloc;
+	unsigned int touched;
 	spinlock_t lock;
 	void *entry[];	/*
 			 * Must have this definition in here for the proper
@@ -978,6 +982,13 @@ static struct array_cache *alloc_arraycache(int node, int entries,
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
@@ -985,22 +996,22 @@ static void check_ac_pfmemalloc(struct kmem_cache *cachep,
 	struct kmem_list3 *l3 = cachep->nodelists[numa_mem_id()];
 	struct slab *slabp;
 
-	if (!ac->pfmemalloc)
+	if (!pfmemalloc_active)
 		return;
 
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
+	pfmemalloc_active = false;
 }
 
 static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
@@ -1036,7 +1047,7 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		l3 = cachep->nodelists[numa_mem_id()];
 		if (!list_empty(&l3->slabs_free) && force_refill) {
 			struct slab *slabp = virt_to_slab(objp);
-			slabp->pfmemalloc = false;
+			ClearPageSlabPfmemalloc(virt_to_page(slabp->s_mem));
 			clear_obj_pfmemalloc(&objp);
 			check_ac_pfmemalloc(cachep, ac);
 			return objp;
@@ -1066,13 +1077,10 @@ static inline void *ac_get_obj(struct kmem_cache *cachep,
 static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
 								void *objp)
 {
-	struct slab *slabp;
-
-	/* If there are pfmemalloc slabs, check if the object is part of one */
-	if (unlikely(ac->pfmemalloc)) {
-		slabp = virt_to_slab(objp);
-
-		if (slabp->pfmemalloc)
+	if (unlikely(pfmemalloc_active)) {
+		/* Some pfmemalloc slabs exist, check if this is one */
+		struct page *page = virt_to_page(objp);
+		if (PageSlabPfmemalloc(page))
 			set_obj_pfmemalloc(&objp);
 	}
 
@@ -1906,9 +1914,13 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid,
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
 
@@ -2888,7 +2900,6 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep, void *objp,
 	slabp->s_mem = objp + colour_off;
 	slabp->nodeid = nodeid;
 	slabp->free = 0;
-	slabp->pfmemalloc = false;
 	return slabp;
 }
 
@@ -3075,11 +3086,8 @@ static int cache_grow(struct kmem_cache *cachep,
 		goto opps1;
 
 	/* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
-	if (pfmemalloc) {
-		struct array_cache *ac = cpu_cache_get(cachep);
-		slabp->pfmemalloc = true;
-		ac->pfmemalloc = true;
-	}
+	if (unlikely(pfmemalloc))
+		pfmemalloc_active = pfmemalloc;
 
 	slab_map_pages(cachep, slabp, objp);
 
diff --git a/mm/slub.c b/mm/slub.c
index ea04994..f9b0f35 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2126,7 +2126,8 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 		stat(s, ALLOC_SLAB);
 		c->node = page_to_nid(page);
 		c->page = page;
-		c->pfmemalloc = pfmemalloc;
+		if (pfmemalloc)
+			SetPageSlabPfmemalloc(page);
 		*pc = c;
 	} else
 		object = NULL;
@@ -2136,7 +2137,7 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 
 static inline bool pfmemalloc_match(struct kmem_cache_cpu *c, gfp_t gfpflags)
 {
-	if (unlikely(c->pfmemalloc))
+	if (unlikely(PageSlabPfmemalloc(c->page)))
 		return gfp_pfmemalloc_allowed(gfpflags);
 
 	return true;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
