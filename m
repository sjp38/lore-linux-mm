Date: Tue, 29 Nov 2005 00:54:56 -0800
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 3/3] mm: NUMA slab -- minor optimizations
Message-ID: <20051129085456.GC3573@localhost.localdomain>
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

Patch adds some minor optimizations:
1. Keeps on chip interrupts enabled for a bit longer while draining cpu
caches
2. Calls numa_node_id once in cache_reap

Signed-off-by: Alok N Kataria <alokk@calsoftinc.com>
Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
Signed-off-by: Shai Fultheim <shai@scalex86.org>

Index: linux-2.6.15-rc1/mm/slab.c
===================================================================
--- linux-2.6.15-rc1.orig/mm/slab.c	2005-11-17 21:32:43.000000000 -0800
+++ linux-2.6.15-rc1/mm/slab.c	2005-11-17 21:32:50.000000000 -0800
@@ -1914,18 +1914,18 @@
 
 	smp_call_function_all_cpus(do_drain, cachep);
 	check_irq_on();
-	spin_lock_irq(&cachep->spinlock);
+	spin_lock(&cachep->spinlock);
 	for_each_online_node(node)  {
 		l3 = cachep->nodelists[node];
 		if (l3) {
-			spin_lock(&l3->list_lock);
+			spin_lock_irq(&l3->list_lock);
 			drain_array_locked(cachep, l3->shared, 1, node);
-			spin_unlock(&l3->list_lock);
+			spin_unlock_irq(&l3->list_lock);
 			if (l3->alien)
 				drain_alien_cache(cachep, l3);
 		}
 	}
-	spin_unlock_irq(&cachep->spinlock);
+	spin_unlock(&cachep->spinlock);
 }
 
 static int __node_shrink(kmem_cache_t *cachep, int node)
@@ -3304,7 +3304,7 @@
 	list_for_each(walk, &cache_chain) {
 		kmem_cache_t *searchp;
 		struct list_head* p;
-		int tofree;
+		int tofree, nodeid;
 		struct slab *slabp;
 
 		searchp = list_entry(walk, kmem_cache_t, next);
@@ -3314,13 +3314,14 @@
 
 		check_irq_on();
 
-		l3 = searchp->nodelists[numa_node_id()];
+		nodeid = numa_node_id();
+		l3 = searchp->nodelists[nodeid];
 		if (l3->alien)
 			drain_alien_cache(searchp, l3);
 		spin_lock_irq(&l3->list_lock);
 
 		drain_array_locked(searchp, ac_data(searchp), 0,
-				numa_node_id());
+				nodeid);
 
 		if (time_after(l3->next_reap, jiffies))
 			goto next_unlock;
@@ -3329,7 +3330,7 @@
 
 		if (l3->shared)
 			drain_array_locked(searchp, l3->shared, 0,
-				numa_node_id());
+				nodeid);
 
 		if (l3->free_touched) {
 			l3->free_touched = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
