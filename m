Date: Tue, 22 Jan 2008 22:50:47 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: crash in kmem_cache_init
Message-ID: <20080122225046.GA866@csn.ul.ie>
References: <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com> <20080117211511.GA25320@aepfle.de> <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com> <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com> <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie> <Pine.LNX.4.64.0801221203340.27950@schroedinger.engr.sgi.com> <20080122212654.GB15567@csn.ul.ie> <Pine.LNX.4.64.0801221330390.1652@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801221330390.1652@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Olaf Hering <olaf@aepfle.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

On (22/01/08 13:34), Christoph Lameter didst pronounce:
> On Tue, 22 Jan 2008, Mel Gorman wrote:
> 
> > > After you reverted the slab memoryless node patch there should be per node 
> > > structures created for node 0 unless the node is marked offline. Is it? If 
> > > so then you are booting a cpu that is associated with an offline node. 
> > > 
> > 
> > I'll roll a patch that prints out the online states before startup and
> > see what it looks like.
> 
> Ok. Great.
> 

The dmesg output is below.


> > 
> > > > Can you see a better solution than this?
> > > 
> > > Well this means that bootstrap will work by introducing foreign objects 
> > > into the per cpu queue (should only hold per cpu objects). They will 
> > > later be consumed and then the queues will contain the right objects so 
> > > the effect of the patch is minimal.
> > > 
> > 
> > By minimal, do you mean that you expect it to break in some other
> > respect later or minimal as in "this is bad but should not have no
> > adverse impact".
> 
> Should not have any adverse impact after the objects from the cpu queue 
> have been consumed. If the cache_reaper tries to shift objects back 
> from the per cpu queue into slabs then BUG_ONs may be triggered. Make sure 
> you run the tests with full debugging please.
> 

I am not running a full range of tests at the moment. Just getting boot
first. I'll queue up a range of tests to run with DEBUG on now but it'll
be the morning before I have the results.

> > Whatever this was a problem fixed in the past or not, it's broken again now
> > :( . It's possible that there is a __GFP_THISNODE that can be dropped early
> > at boot-time that would also fix this problem in a way that doesn't
> > affect runtime (like altering cache_grow in my patch does).
> 
> The dropping of GFP_THISNODE has the same effect as your patch. 

The dropping of it totally? If so, this patch might fix a boot but it'll
potentially be a performance regression on NUMA machines that only have
nodes with memory, right?

> Objects from another node get into the per cpu queue. And on free we 
> assume that per cpu queue objects are from the local node. If debug is on 
> then we check that with BUG_ONs.
> 

The interesting parts of the dmesg output are

Online nodes
o 0
o 2
Nodes with regular memory
o 2
Current running CPU 0 is associated with node 0
Current node is 0

So node 2 has regular memory but it's trying to use node 0 at a glance.
I've attached the patch I used against 2.6.24-rc8. It includes the revert.

Here is the full output


Please wait, loading kernel...
   Elf64 kernel loaded...
Loading ramdisk...
ramdisk loaded at 02400000, size: 1192 Kbytes
OF stdout device is: /vdevice/vty@30000000
Hypertas detected, assuming LPAR !
command line: ro console=hvc0 autobench_args: root=/dev/sda6 ABAT:1201041303 loglevel=8 
memory layout at init:
  alloc_bottom : 000000000252a000
  alloc_top    : 0000000008000000
  alloc_top_hi : 0000000100000000
  rmo_top      : 0000000008000000
  ram_top      : 0000000100000000
Looking for displays
instantiating rtas at 0x00000000077d9000 ... done
0000000000000000 : boot cpu     0000000000000000
0000000000000002 : starting cpu hw idx 0000000000000002... done
copying OF device tree ...
Building dt strings...
Building dt structure...
Device tree strings 0x000000000262b000 -> 0x000000000262c1d3
Device tree struct  0x000000000262d000 -> 0x0000000002635000
Calling quiesce ...
returning from prom_init
Partition configured for 4 cpus.
Starting Linux PPC64 #1 SMP Tue Jan 22 17:15:48 EST 2008
-----------------------------------------------------
ppc64_pft_size                = 0x1a
physicalMemorySize            = 0x100000000
htab_hash_mask                = 0x7ffff
-----------------------------------------------------
Linux version 2.6.24-rc8-autokern1 (root@gekko-lp3.ltc.austin.ibm.com) (gcc version 3.4.6 20060404 (Red Hat 3.4.6-3)) #1 SMP Tue Jan 22 17:15:48 EST 2008
[boot]0012 Setup Arch
EEH: PCI Enhanced I/O Error Handling Enabled
PPC64 nvram contains 7168 bytes
Zone PFN ranges:
  DMA             0 ->  1048576
  Normal    1048576 ->  1048576
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    2:        0 ->  1048576
Could not find start_pfn for node 0
[boot]0015 Setup Done
Built 2 zonelists in Node order, mobility grouping on.  Total pages: 1034240
Policy zone: DMA
Kernel command line: ro console=hvc0 autobench_args: root=/dev/sda6 ABAT:1201041303 loglevel=8 
[boot]0020 XICS Init
xics: no ISA interrupt controller
[boot]0021 XICS Done
PID hash table entries: 4096 (order: 12, 32768 bytes)
time_init: decrementer frequency = 238.059000 MHz
time_init: processor frequency   = 1904.472000 MHz
clocksource: timebase mult[10cd746] shift[22] registered
clockevent: decrementer mult[3cf1] shift[16] cpu[0]
Console: colour dummy device 80x25
console handover: boot [udbg0] -> real [hvc0]
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
freeing bootmem node 2
Memory: 4105560k/4194304k available (5004k kernel code, 88744k reserved, 876k data, 559k bss, 272k init)
Online nodes
o 0
o 2
Nodes with regular memory
o 2
Current running CPU 0 is associated with node 0
Current node is 0
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 0
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 1
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 2
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 3
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 4
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 5
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 6
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 7
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 8
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 9
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 10
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 11
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 12
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 13
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 14
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 15
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 16
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 17
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 18
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 19
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 20
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 21
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 22
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 23
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 24
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 25
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 26
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 27
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 28
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 29
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 30
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 31
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 32
kmem_cache_init Setting kmem_cache initkmem_list3 0
Unable to handle kernel paging request for data at address 0x00000040
Faulting instruction address: 0xc0000000003c8c00
cpu 0x0: Vector: 300 (Data Access) at [c0000000005c3840]
    pc: c0000000003c8c00: __lock_text_start+0x20/0x88
    lr: c0000000000dadec: .cache_grow+0x7c/0x338
    sp: c0000000005c3ac0
   msr: 8000000000009032
   dar: 40
 dsisr: 40000000
  current = 0xc000000000500f10
  paca    = 0xc000000000501b80
    pid   = 0, comm = swapper
enter ? for help
[c0000000005c3b40] c0000000000dadec .cache_grow+0x7c/0x338
[c0000000005c3c00] c0000000000db54c .fallback_alloc+0x1c0/0x224
[c0000000005c3cb0] c0000000000db958 .kmem_cache_alloc+0xe0/0x14c
[c0000000005c3d50] c0000000000dcccc .kmem_cache_create+0x230/0x4cc
[c0000000005c3e30] c0000000004c05f4 .kmem_cache_init+0x310/0x640
[c0000000005c3ee0] c00000000049f8d8 .start_kernel+0x304/0x3fc
[c0000000005c3f90] c000000000008594 .start_here_common+0x54/0xc0
0:mon>

--sdtB3X0nJg68CQEu
Content-Type: text/x-diff; charset=iso-8859-15
Content-Disposition: attachment; filename="debug-slab-with-revert.diff"

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc8-clean/mm/slab.c linux-2.6.24-rc8-005-debug-slab/mm/slab.c
--- linux-2.6.24-rc8-clean/mm/slab.c	2008-01-16 04:22:48.000000000 +0000
+++ linux-2.6.24-rc8-005-debug-slab/mm/slab.c	2008-01-22 21:36:50.000000000 +0000
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
@@ -3815,8 +3840,10 @@ static int alloc_kmemlist(struct kmem_ca
 	struct array_cache *new_shared;
 	struct array_cache **new_alien = NULL;
 
-	for_each_node_state(node, N_NORMAL_MEMORY) {
+	printk("alloc_kmemlist %s\n", cachep->name);
+	for_each_online_node(node) {
 
+		printk(" o node %d\n", node);
                 if (use_alien_caches) {
                         new_alien = alloc_alien_cache(node, cachep->limit);
                         if (!new_alien)
@@ -3837,6 +3864,7 @@ static int alloc_kmemlist(struct kmem_ca
 		l3 = cachep->nodelists[node];
 		if (l3) {
 			struct array_cache *shared = l3->shared;
+			printk(" o l3 exists\n");
 
 			spin_lock_irq(&l3->list_lock);
 
@@ -3856,10 +3884,12 @@ static int alloc_kmemlist(struct kmem_ca
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
 
@@ -3871,6 +3901,7 @@ static int alloc_kmemlist(struct kmem_ca
 		l3->free_limit = (1 + nr_cpus_node(node)) *
 					cachep->batchcount + cachep->num;
 		cachep->nodelists[node] = l3;
+		printk(" o setting node %d 0x%lX\n", node, (unsigned long)l3);
 	}
 	return 0;
 
@@ -3886,6 +3917,7 @@ fail:
 				free_alien_cache(l3->alien);
 				kfree(l3);
 				cachep->nodelists[node] = NULL;
+				printk(" o setting node %d FAIL NULL\n", node);
 			}
 			node--;
 		}

--sdtB3X0nJg68CQEu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
