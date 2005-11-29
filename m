Date: Tue, 29 Nov 2005 00:50:49 -0800
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: [patch 1/3] mm: NUMA slab -- add alien cache drain statistics 
Message-ID: <20051129085049.GA3573@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, manfred@colorfullife.com, clameter@engr.sgi.com, Alok Kataria <alokk@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

NUMA slab allocator frees remote objects to a local alien cache.
But if the local alien cache is full, the alien cache
is drained directly to the remote node.

This patch adds a statistics counter which is incremented everytime the 
local alien cache is full and we have to drain it to the remote nodes list3.

This will be useful when we can dynamically tune the alien cache limit.  
Currently, the alien cache limit is fixed at 12.

Signed-off-by: Alok N Kataria <alokk@calsoftinc.com>
Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
Signed-off-by: Shai Fultheim <shai@scalex86.org>

Index: linux-2.6.15-rc1/mm/slab.c
===================================================================
--- linux-2.6.15-rc1.orig/mm/slab.c	2005-11-17 15:37:26.000000000 -0800
+++ linux-2.6.15-rc1/mm/slab.c	2005-11-17 21:32:37.000000000 -0800
@@ -416,9 +416,11 @@
 	unsigned long		max_freeable;
 	unsigned long		node_allocs;
 	unsigned long		node_frees;
+	unsigned long		node_overflow;
 	atomic_t		allochit;
 	atomic_t		allocmiss;
 	atomic_t		freehit;
+
 	atomic_t		freemiss;
 #endif
 #if DEBUG
@@ -452,6 +454,7 @@
 #define	STATS_INC_ERR(x)	((x)->errors++)
 #define	STATS_INC_NODEALLOCS(x)	((x)->node_allocs++)
 #define	STATS_INC_NODEFREES(x)	((x)->node_frees++)
+#define STATS_INC_OVERFLOW(x)   ((x)->node_overflow++)
 #define	STATS_SET_FREEABLE(x, i) \
 				do { if ((x)->max_freeable < i) \
 					(x)->max_freeable = i; \
@@ -471,6 +474,7 @@
 #define	STATS_INC_ERR(x)	do { } while (0)
 #define	STATS_INC_NODEALLOCS(x)	do { } while (0)
 #define	STATS_INC_NODEFREES(x)	do { } while (0)
+#define STATS_INC_OVERFLOW(x)   do { } while (0)
 #define	STATS_SET_FREEABLE(x, i) \
 				do { } while (0)
 
@@ -2765,9 +2769,11 @@
 			if (l3->alien && l3->alien[nodeid]) {
 				alien = l3->alien[nodeid];
 				spin_lock(&alien->lock);
-				if (unlikely(alien->avail == alien->limit))
+				if (unlikely(alien->avail == alien->limit)) {
+					STATS_INC_OVERFLOW(cachep);
 					__drain_alien_cache(cachep,
 							alien, nodeid);
+				}
 				alien->entry[alien->avail++] = objp;
 				spin_unlock(&alien->lock);
 			} else {
@@ -3386,7 +3392,7 @@
 		seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
 #if STATS
 		seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped>"
-				" <error> <maxfreeable> <nodeallocs> <remotefrees>");
+				" <error> <maxfreeable> <nodeallocs> <remotefrees> <overflow>");
 		seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
 #endif
 		seq_putc(m, '\n');
@@ -3492,11 +3498,13 @@
 		unsigned long max_freeable = cachep->max_freeable;
 		unsigned long node_allocs = cachep->node_allocs;
 		unsigned long node_frees = cachep->node_frees;
+		unsigned long overflows = cachep->node_overflow;
 
 		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu \
-				%4lu %4lu %4lu %4lu",
+				%4lu %4lu %4lu %4lu %4lu",
 				allocs, high, grown, reaped, errors,
-				max_freeable, node_allocs, node_frees);
+				max_freeable, node_allocs, node_frees, 
+				overflows);
 	}
 	/* cpu stats */
 	{

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
