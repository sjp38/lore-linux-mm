Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: slablru for 2.5.32-mm1
Date: Mon, 2 Sep 2002 15:09:52 -0400
References: <200208261809.45568.tomlins@cam.org> <200209021100.47508.tomlins@cam.org> <3D73AF73.C8FE455@zip.com.au>
In-Reply-To: <3D73AF73.C8FE455@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209021509.52216.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 2, 2002 02:35 pm, Andrew Morton wrote:
> Ed Tomlinson wrote:
> > On September 2, 2002 01:26 am, Andrew Morton wrote:
> > > Ed, this code can be sped up a bit, I think.  We can make
> > > kmem_count_page() return a boolean back to shrink_cache(), telling it
> > > whether it needs to call kmem_do_prunes() at all.  Often, there won't
> > > be any work to do in there, and taking that semaphore can be quite
> > > costly.
> > >
> > > The code as-is will even run kmem_do_prunes() when we're examining
> > > ZONE_HIGHMEM, which certainly won't have any slab pages.  This boolean
> > > will fix that too.
> >
> > How about this?  I have modified things so we only try for the sem if
> > there is work to do.  It also always uses a down_trylock - if we cannot
> > do the prune now later is ok too...
>
> well...   Using a global like that is a bit un-linuxy.  (bitops
> are only defined on longs, btw...

ah.  learn something every day.

> How about this one?  It does both:  tells the caller whether or
> not to perform the shrink, and defers the pruning until we
> have at least a page's worth of objects to be pruned.

I thought about doing something like your patch.  I wanted to avoid
semi-magic numbers (why a page worth of objects?  why not two or
three...).  I would rather see something like my patch, maybe coded
in a more stylish way, used.  If we want to get bigger batch I would
move the kmem_do_prunes up into try_to_free_pages.  This way the
code is simpler, vmscan changes for slablru are smaller, and nothing 
magic is involved.

> Also, make sure that only the CPU which was responsible for
> the transition-past-threshold is told to do some pruning.  Reduces
> the possibility of two CPUs running the prune.

With my code it is possible two cpus could prune but very unlikely.

> Also, when we make the sweep across the to-be-pruned caches, only
> prune the ones which are over threshold.

If the kmem_do_prunes is moved to try_to_free_pages its not quite as
hot a call.  Since it now never waits (with my patch) doubt if it is going
to show up as something that needs tuning...

How about this?  What does it show if you breakpoint it?   How would
you make it prettier linux wise?  (compiled, untested)

Ed

-----
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.531   -> 1.534  
#	         mm/vmscan.c	1.98    -> 1.99   
#	           mm/slab.c	1.28    -> 1.31   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/09/02	ed@oscar.et.ca	1.532
# optimization.  lets only take the sem if we have work to do.
# --------------------------------------------
# 02/09/02	ed@oscar.et.ca	1.533
# more optimizations and a correction
# --------------------------------------------
# 02/09/02	ed@oscar.et.ca	1.534
# more optimizing
# --------------------------------------------
#
diff -Nru a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c	Mon Sep  2 15:05:01 2002
+++ b/mm/slab.c	Mon Sep  2 15:05:01 2002
@@ -403,6 +403,9 @@
 /* Place maintainer for reaping. */
 static kmem_cache_t *clock_searchp = &cache_cache;
 
+static long pruner_flag;
+#define	PRUNE_GATE	0
+
 #define cache_chain (cache_cache.next)
 
 #ifdef CONFIG_SMP
@@ -427,6 +430,8 @@
 	spin_lock_irq(&cachep->spinlock);
 	if (cachep->pruner != NULL) {
 		cachep->count += slabp->inuse;
+		if (cachep->count)
+			set_bit(PRUNE_GATE, &pruner_flag);
 		ret = !slabp->inuse;
 	} else 
 		ret = !ref && !slabp->inuse;
@@ -441,11 +446,13 @@
 	struct list_head *p;
 	int nr;
 
-        if (gfp_mask & __GFP_WAIT)
-                down(&cache_chain_sem);
-        else
-                if (down_trylock(&cache_chain_sem))
-                        return 0;
+	if (!test_and_clear_bit(PRUNE_GATE, &pruner_flag))
+		return 0;
+
+	if (down_trylock(&cache_chain_sem)) {
+		set_bit(PRUNE_GATE, &pruner_flag);
+		return 0;
+	}
 
         list_for_each(p,&cache_chain) {
                 kmem_cache_t *cachep = list_entry(p, kmem_cache_t, next);
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Mon Sep  2 15:05:01 2002
+++ b/mm/vmscan.c	Mon Sep  2 15:05:01 2002
@@ -510,8 +510,6 @@
 	max_scan = zone->nr_inactive / priority;
 	nr_pages = shrink_cache(nr_pages, zone,
 				gfp_mask, priority, max_scan);
-	kmem_do_prunes(gfp_mask);
-
 	if (nr_pages <= 0)
 		return 0;
 
@@ -549,6 +547,8 @@
 	int nr_pages = SWAP_CLUSTER_MAX;
 
 	KERNEL_STAT_INC(pageoutrun);
+
+	kmem_do_prunes(gfp_mask);
 
 	do {
 		nr_pages = shrink_caches(classzone, priority,

-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
