Date: Wed, 23 Jan 2008 10:50:44 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: crash in kmem_cache_init
Message-ID: <20080123105044.GD21455@csn.ul.ie>
References: <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com> <20080117211511.GA25320@aepfle.de> <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com> <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com> <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie> <20080122214505.GA15674@aepfle.de> <Pine.LNX.4.64.0801221417480.1912@schroedinger.engr.sgi.com> <20080123075821.GA17713@aepfle.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080123075821.GA17713@aepfle.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olaf Hering <olaf@aepfle.de>
Cc: Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On (23/01/08 08:58), Olaf Hering didst pronounce:
> On Tue, Jan 22, Christoph Lameter wrote:
> 
> > > 0xc0000000000fe018 is in setup_cpu_cache (/home/olaf/kernel/git/linux-2.6-numa/mm/slab.c:2111).
> > > 2106                                    BUG_ON(!cachep->nodelists[node]);
> > > 2107                                    kmem_list3_init(cachep->nodelists[node]);
> > > 2108                            }
> > > 2109                    }
> > > 2110            }
> > 
> > if (cachep->nodelists[numa_node_id()])
> > 	return;
> 
> Does not help.
> 

Sorry this is dragging out. Can you post the full dmesg with loglevel=8 of the
following patch against 2.6.24-rc8 please? It contains the debug information
that helped me figure out what was going wrong on the PPC64 machine here,
the revert and the !l3 checks (i.e. the two patches that made machines I
have access to work). Thanks

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc8-clean/mm/slab.c linux-2.6.24-rc8-015_debug_slab/mm/slab.c
--- linux-2.6.24-rc8-clean/mm/slab.c	2008-01-16 04:22:48.000000000 +0000
+++ linux-2.6.24-rc8-015_debug_slab/mm/slab.c	2008-01-23 10:44:36.000000000 +0000
@@ -348,6 +348,7 @@ static int slab_early_init = 1;
 
 static void kmem_list3_init(struct kmem_list3 *parent)
 {
+	printk(" o kmem_list3_init\n");
 	INIT_LIST_HEAD(&parent->slabs_full);
 	INIT_LIST_HEAD(&parent->slabs_partial);
 	INIT_LIST_HEAD(&parent->slabs_free);
@@ -1236,6 +1237,7 @@ static int __cpuinit cpuup_prepare(long 
 	 * kmem_list3 and not this cpu's kmem_list3
 	 */
 
+	printk("cpuup_prepare %ld\n", cpu);
 	list_for_each_entry(cachep, &cache_chain, next) {
 		/*
 		 * Set up the size64 kmemlist for cpu before we can
@@ -1243,6 +1245,7 @@ static int __cpuinit cpuup_prepare(long 
 		 * node has not already allocated this
 		 */
 		if (!cachep->nodelists[node]) {
+			printk(" o allocing %s %d\n", cachep->name, node);
 			l3 = kmalloc_node(memsize, GFP_KERNEL, node);
 			if (!l3)
 				goto bad;
@@ -1256,6 +1259,7 @@ static int __cpuinit cpuup_prepare(long 
 			 * protection here.
 			 */
 			cachep->nodelists[node] = l3;
+			printk(" o l3 setup\n");
 		}
 
 		spin_lock_irq(&cachep->nodelists[node]->list_lock);
@@ -1320,6 +1324,7 @@ static int __cpuinit cpuup_prepare(long 
 	}
 	return 0;
 bad:
+	printk(" o bad\n");
 	cpuup_canceled(cpu);
 	return -ENOMEM;
 }
@@ -1405,6 +1410,7 @@ static void init_list(struct kmem_cache 
 	spin_lock_init(&ptr->list_lock);
 
 	MAKE_ALL_LISTS(cachep, ptr, nodeid);
+	printk("init_list RESETTING %s node %d\n", cachep->name, nodeid);
 	cachep->nodelists[nodeid] = ptr;
 	local_irq_enable();
 }
@@ -1427,10 +1433,23 @@ void __init kmem_cache_init(void)
 		numa_platform = 0;
 	}
 
+	printk("Online nodes\n");
+	for_each_online_node(node)
+		printk("o %d\n", node);
+	printk("Nodes with regular memory\n");
+	for_each_node_state(node, N_NORMAL_MEMORY)
+		printk("o %d\n", node);
+	printk("Current running CPU %d is associated with node %d\n",
+		smp_processor_id(),
+		cpu_to_node(smp_processor_id()));
+	printk("Current node is %d\n",
+		numa_node_id());
+
 	for (i = 0; i < NUM_INIT_LISTS; i++) {
 		kmem_list3_init(&initkmem_list3[i]);
 		if (i < MAX_NUMNODES)
 			cache_cache.nodelists[i] = NULL;
+		printk("kmem_cache_init Setting %s NULL %d\n", cache_cache.name, i);
 	}
 
 	/*
@@ -1468,6 +1487,8 @@ void __init kmem_cache_init(void)
 	cache_cache.colour_off = cache_line_size();
 	cache_cache.array[smp_processor_id()] = &initarray_cache.cache;
 	cache_cache.nodelists[node] = &initkmem_list3[CACHE_CACHE];
+	printk("kmem_cache_init Setting %s NULL %d\n", cache_cache.name, node);
+	printk("kmem_cache_init Setting %s initkmem_list3 %d\n", cache_cache.name, node);
 
 	/*
 	 * struct kmem_cache size depends on nr_node_ids, which
@@ -1590,7 +1611,7 @@ void __init kmem_cache_init(void)
 		/* Replace the static kmem_list3 structures for the boot cpu */
 		init_list(&cache_cache, &initkmem_list3[CACHE_CACHE], node);
 
-		for_each_node_state(nid, N_NORMAL_MEMORY) {
+		for_each_online_node(nid) {
 			init_list(malloc_sizes[INDEX_AC].cs_cachep,
 				  &initkmem_list3[SIZE_AC + nid], nid);
 
@@ -1968,11 +1989,13 @@ static void __init set_up_list3s(struct 
 {
 	int node;
 
-	for_each_node_state(node, N_NORMAL_MEMORY) {
+	printk("set_up_list3s %s index %d\n", cachep->name, index);
+	for_each_online_node(node) {
 		cachep->nodelists[node] = &initkmem_list3[index + node];
 		cachep->nodelists[node]->next_reap = jiffies +
 		    REAPTIMEOUT_LIST3 +
 		    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
+		printk("set_up_list3s %s index %d\n", cachep->name, index);
 	}
 }
 
@@ -2099,11 +2122,13 @@ static int __init_refok setup_cpu_cache(
 			g_cpucache_up = PARTIAL_L3;
 		} else {
 			int node;
-			for_each_node_state(node, N_NORMAL_MEMORY) {
+			printk("setup_cpu_cache %s\n", cachep->name);
+			for_each_online_node(node) {
 				cachep->nodelists[node] =
 				    kmalloc_node(sizeof(struct kmem_list3),
 						GFP_KERNEL, node);
 				BUG_ON(!cachep->nodelists[node]);
+				printk(" o allocated node %d\n", node);
 				kmem_list3_init(cachep->nodelists[node]);
 			}
 		}
@@ -2775,6 +2800,11 @@ static int cache_grow(struct kmem_cache 
 	/* Take the l3 list lock to change the colour_next on this node */
 	check_irq_off();
 	l3 = cachep->nodelists[nodeid];
+	if (!l3) {
+		nodeid = numa_node_id();
+		l3 = cachep->nodelists[nodeid];
+	}
+	BUG_ON(!l3);
 	spin_lock(&l3->list_lock);
 
 	/* Get colour for the slab, and cal the next value. */
@@ -3317,6 +3347,10 @@ static void *____cache_alloc_node(struct
 	int x;
 
 	l3 = cachep->nodelists[nodeid];
+	if (!l3) {
+		nodeid = numa_node_id();
+		l3 = cachep->nodelists[nodeid];
+	}
 	BUG_ON(!l3);
 
 retry:
@@ -3815,8 +3849,10 @@ static int alloc_kmemlist(struct kmem_ca
 	struct array_cache *new_shared;
 	struct array_cache **new_alien = NULL;
 
-	for_each_node_state(node, N_NORMAL_MEMORY) {
+	printk("alloc_kmemlist %s\n", cachep->name);
+	for_each_online_node(node) {
 
+		printk(" o node %d\n", node);
                 if (use_alien_caches) {
                         new_alien = alloc_alien_cache(node, cachep->limit);
                         if (!new_alien)
@@ -3837,6 +3873,7 @@ static int alloc_kmemlist(struct kmem_ca
 		l3 = cachep->nodelists[node];
 		if (l3) {
 			struct array_cache *shared = l3->shared;
+			printk(" o l3 exists\n");
 
 			spin_lock_irq(&l3->list_lock);
 
@@ -3856,10 +3893,12 @@ static int alloc_kmemlist(struct kmem_ca
 			free_alien_cache(new_alien);
 			continue;
 		}
+		printk(" o allocing l3\n");
 		l3 = kmalloc_node(sizeof(struct kmem_list3), GFP_KERNEL, node);
 		if (!l3) {
 			free_alien_cache(new_alien);
 			kfree(new_shared);
+			printk(" o allocing l3 failed\n");
 			goto fail;
 		}
 
@@ -3871,6 +3910,7 @@ static int alloc_kmemlist(struct kmem_ca
 		l3->free_limit = (1 + nr_cpus_node(node)) *
 					cachep->batchcount + cachep->num;
 		cachep->nodelists[node] = l3;
+		printk(" o setting node %d 0x%lX\n", node, (unsigned long)l3);
 	}
 	return 0;
 
@@ -3886,6 +3926,7 @@ fail:
 				free_alien_cache(l3->alien);
 				kfree(l3);
 				cachep->nodelists[node] = NULL;
+				printk(" o setting node %d FAIL NULL\n", node);
 			}
 			node--;
 		}

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
