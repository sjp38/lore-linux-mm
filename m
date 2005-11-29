Date: Tue, 29 Nov 2005 00:53:18 -0800
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 2/3] mm: NUMA slab -- node local memory for off slab slab descriptors
Message-ID: <20051129085318.GB3573@localhost.localdomain>
References: <20051129085049.GA3573@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051129085049.GA3573@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, manfred@colorfullife.com, clameter@engr.sgi.com, Alok Kataria <alokk@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

Off slab slab management is currently not allocated from node local
memory.  This patch fixes that.

Signed-off-by: Alok N Kataria <alokk@calsoftinc.com>
Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
Signed-off-by: Shai Fultheim <shai@scalex86.org>

Index: linux-2.6.15-rc1/mm/slab.c
===================================================================
--- linux-2.6.15-rc1.orig/mm/slab.c	2005-11-17 21:32:37.000000000 -0800
+++ linux-2.6.15-rc1/mm/slab.c	2005-11-17 21:32:43.000000000 -0800
@@ -2062,13 +2062,13 @@
 
 /* Get the memory for a slab management obj. */
 static struct slab* alloc_slabmgmt(kmem_cache_t *cachep, void *objp,
-			int colour_off, gfp_t local_flags)
+			int colour_off, gfp_t local_flags, int nodeid)
 {
 	struct slab *slabp;
 	
 	if (OFF_SLAB(cachep)) {
 		/* Slab management obj is off-slab. */
-		slabp = kmem_cache_alloc(cachep->slabp_cache, local_flags);
+		slabp = kmem_cache_alloc_node(cachep->slabp_cache, local_flags, nodeid);
 		if (!slabp)
 			return NULL;
 	} else {
@@ -2078,6 +2078,7 @@
 	slabp->inuse = 0;
 	slabp->colouroff = colour_off;
 	slabp->s_mem = objp+colour_off;
+	slabp->nodeid = nodeid;
 
 	return slabp;
 }
@@ -2221,10 +2222,9 @@
 		goto failed;
 
 	/* Get slab management. */
-	if (!(slabp = alloc_slabmgmt(cachep, objp, offset, local_flags)))
+	if (!(slabp = alloc_slabmgmt(cachep, objp, offset, local_flags, nodeid)))
 		goto opps1;
 
-	slabp->nodeid = nodeid;
 	set_slab_attr(cachep, slabp, objp);
 
 	cache_init_objs(cachep, slabp, ctor_flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
