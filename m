Date: Wed, 23 Jan 2008 08:58:21 +0100
From: Olaf Hering <olaf@aepfle.de>
Subject: Re: crash in kmem_cache_init
Message-ID: <20080123075821.GA17713@aepfle.de>
References: <20080117181222.GA24411@aepfle.de> <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com> <20080117211511.GA25320@aepfle.de> <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com> <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com> <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie> <20080122214505.GA15674@aepfle.de> <Pine.LNX.4.64.0801221417480.1912@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801221417480.1912@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 22, Christoph Lameter wrote:

> > 0xc0000000000fe018 is in setup_cpu_cache (/home/olaf/kernel/git/linux-2.6-numa/mm/slab.c:2111).
> > 2106                                    BUG_ON(!cachep->nodelists[node]);
> > 2107                                    kmem_list3_init(cachep->nodelists[node]);
> > 2108                            }
> > 2109                    }
> > 2110            }
> 
> if (cachep->nodelists[numa_node_id()])
> 	return;

Does not help.


Linux version 2.6.24-rc8-ppc64 (olaf@lingonberry) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #48 SMP Wed Jan 23 08:54:23 CET 2008
[boot]0012 Setup Arch
EEH: PCI Enhanced I/O Error Handling Enabled
PPC64 nvram contains 8192 bytes
Zone PFN ranges:
  DMA             0 ->   892928
  Normal     892928 ->   892928
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    1:        0 ->   892928
Could not find start_pfn for node 0
[boot]0015 Setup Done
Built 2 zonelists in Node order, mobility grouping on.  Total pages: 880720
Policy zone: DMA
Kernel command line: debug xmon=on panic=1  
[boot]0020 XICS Init
xics: no ISA interrupt controller
[boot]0021 XICS Done
PID hash table entries: 4096 (order: 12, 32768 bytes)
time_init: decrementer frequency = 275.070000 MHz
time_init: processor frequency   = 2197.800000 MHz
clocksource: timebase mult[e8ab05] shift[22] registered
clockevent: decrementer mult[466a] shift[16] cpu[0]
Console: colour dummy device 80x25
console handover: boot [udbg-1] -> real [hvc0]
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
freeing bootmem node 1
Memory: 3496632k/3571712k available (6188k kernel code, 75080k reserved, 1324k data, 1220k bss, 304k init)
Kernel panic - not syncing: kmem_cache_create(): failed to create slab `size-32(DMA)'

Rebooting in 1 seconds..

---
 mm/slab.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1590,7 +1590,7 @@ void __init kmem_cache_init(void)
 		/* Replace the static kmem_list3 structures for the boot cpu */
 		init_list(&cache_cache, &initkmem_list3[CACHE_CACHE], node);
 
-		for_each_node_state(nid, N_NORMAL_MEMORY) {
+		for_each_online_node(nid) {
 			init_list(malloc_sizes[INDEX_AC].cs_cachep,
 				  &initkmem_list3[SIZE_AC + nid], nid);
 
@@ -1968,7 +1968,7 @@ static void __init set_up_list3s(struct 
 {
 	int node;
 
-	for_each_node_state(node, N_NORMAL_MEMORY) {
+	for_each_online_node(node) {
 		cachep->nodelists[node] = &initkmem_list3[index + node];
 		cachep->nodelists[node]->next_reap = jiffies +
 		    REAPTIMEOUT_LIST3 +
@@ -2108,6 +2108,8 @@ static int __init_refok setup_cpu_cache(
 			}
 		}
 	}
+	if (!cachep->nodelists[numa_node_id()])
+		return -ENODEV;
 	cachep->nodelists[numa_node_id()]->next_reap =
 			jiffies + REAPTIMEOUT_LIST3 +
 			((unsigned long)cachep) % REAPTIMEOUT_LIST3;
@@ -2775,6 +2777,11 @@ static int cache_grow(struct kmem_cache 
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
@@ -3317,6 +3324,10 @@ static void *____cache_alloc_node(struct
 	int x;
 
 	l3 = cachep->nodelists[nodeid];
+	if (!l3) {
+		nodeid = numa_node_id();
+		l3 = cachep->nodelists[nodeid];
+	}
 	BUG_ON(!l3);
 
 retry:
@@ -3815,7 +3826,7 @@ static int alloc_kmemlist(struct kmem_ca
 	struct array_cache *new_shared;
 	struct array_cache **new_alien = NULL;
 
-	for_each_node_state(node, N_NORMAL_MEMORY) {
+	for_each_online_node(node) {
 
                 if (use_alien_caches) {
                         new_alien = alloc_alien_cache(node, cachep->limit);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
