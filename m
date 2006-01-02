Received: from 203.199.144.195 ([203.199.144.195]) by calsoftinc.com for <linux-mm@kvack.org>; Mon, 2 Jan 2006 07:30:35 -0800
Date: Mon, 2 Jan 2006 20:57:12 +0530 (IST)
From: Alok Kataria <alokk@calsoftinc.com>
Subject: Re: [patch 3/3] mm: NUMA slab -- minor optimizations
Message-ID: <Pine.LNX.4.63.0601022052040.19592@pravin.s>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@engr.sgi.com
Cc: manfred@colorfullife.com, kiran@scalemp.com, akpm@osdl.org, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Wed, 2005-12-28 at 02:05, Christoph Lameter wrote:
On Tue, 27 Dec 2005, Manfred Spraul wrote:
> 
> > Isn't that a bug? What prevents an interrupt from occuring after the
> > spin_lock() and then causing a deadlock on cachep->spinlock?
> 
> Right. cache_grow() may be called when doing slab allocations in an 
> interrupt and it takes the lock in order to modify colour_next. 
> 
Yes you are right. 
Looking at the cache_grow code again i think we can do 
away with the cachep->spinlock in this code path.

The colour_next variable can be made per node to give better cache 
colouring effect.

Then this minor optimizations patch should be alright.

Comments ?

Thanks & Regards,
Alok.


--
The colour_next which is used to calculate the offset of the object in the
slab descriptor, is incremented whenever we add a slab to any of the list3
for a particular cache. This is done now for every list3 to give better 
(per node) cache colouring effect.
This also reduces thrashing on the cache_cache structure.

Signed-off-by: Alok N Kataria <alokk@calsoftinc.com>

Index: linux-2.6.15-rc7/mm/slab.c
===================================================================
--- linux-2.6.15-rc7.orig/mm/slab.c	2005-12-24 15:47:48.000000000 -0800
+++ linux-2.6.15-rc7/mm/slab.c	2006-01-02 07:00:36.000000000 -0800
@@ -293,6 +293,7 @@ struct kmem_list3 {
 	unsigned long	next_reap;
 	int		free_touched;
 	unsigned int 	free_limit;
+	unsigned int    colour_next;            /* cache colouring */
 	spinlock_t      list_lock;
 	struct array_cache	*shared;	/* shared per node */
 	struct array_cache	**alien;	/* on other nodes */
@@ -344,6 +345,7 @@ static inline void kmem_list3_init(struc
 	INIT_LIST_HEAD(&parent->slabs_free);
 	parent->shared = NULL;
 	parent->alien = NULL;
+	parent->colour_next = 0;
 	spin_lock_init(&parent->list_lock);
 	parent->free_objects = 0;
 	parent->free_touched = 0;
@@ -390,7 +392,6 @@ struct kmem_cache {
 
 	size_t			colour;		/* cache colouring range */
 	unsigned int		colour_off;	/* colour offset */
-	unsigned int		colour_next;	/* cache colouring */
 	kmem_cache_t		*slabp_cache;
 	unsigned int		slab_size;
 	unsigned int		dflags;		/* dynamic flags */
@@ -1060,7 +1061,6 @@ void __init kmem_cache_init(void)
 		BUG();
 
 	cache_cache.colour = left_over/cache_cache.colour_off;
-	cache_cache.colour_next = 0;
 	cache_cache.slab_size = ALIGN(cache_cache.num*sizeof(kmem_bufctl_t) +
 				sizeof(struct slab), cache_line_size());
 
@@ -2187,16 +2187,17 @@ static int cache_grow(kmem_cache_t *cach
 
 	/* About to mess with non-constant members - lock. */
 	check_irq_off();
-	spin_lock(&cachep->spinlock);
+	l3 = cachep->nodelists[nodeid];
+	spin_lock(&l3->list_lock);
 
 	/* Get colour for the slab, and cal the next value. */
-	offset = cachep->colour_next;
-	cachep->colour_next++;
-	if (cachep->colour_next >= cachep->colour)
-		cachep->colour_next = 0;
-	offset *= cachep->colour_off;
+	offset = l3->colour_next;
+	l3->colour_next++;
+	if (l3->colour_next >= cachep->colour)
+		l3->colour_next = 0;
+	spin_unlock(&l3->list_lock);
 
-	spin_unlock(&cachep->spinlock);
+	offset *= cachep->colour_off;
 
 	check_irq_off();
 	if (local_flags & __GFP_WAIT)
@@ -2228,7 +2229,6 @@ static int cache_grow(kmem_cache_t *cach
 	if (local_flags & __GFP_WAIT)
 		local_irq_disable();
 	check_irq_off();
-	l3 = cachep->nodelists[nodeid];
 	spin_lock(&l3->list_lock);
 
 	/* Make slab active. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
