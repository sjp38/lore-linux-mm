Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 261906B004D
	for <linux-mm@kvack.org>; Sun, 22 Apr 2012 22:01:02 -0400 (EDT)
Date: Sun, 22 Apr 2012 22:00:54 -0400 (EDT)
Message-Id: <20120422.220054.1961736352806510855.davem@davemloft.net>
Subject: Re: Weirdness in __alloc_bootmem_node_high
From: David Miller <davem@davemloft.net>
In-Reply-To: <20120422200554.GA6385@merkur.ravnborg.org>
References: <20120420194309.GA3689@merkur.ravnborg.org>
	<20120422.152210.1520263792125579554.davem@davemloft.net>
	<20120422200554.GA6385@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sam@ravnborg.org
Cc: yinghai@kernel.org, tj@kernel.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org


So here is a sparc64 conversion to NO_BOOTMEM.

Critically, I had to fix __alloc_bootmem_node to do what it promised
to do.  Which is retry the allocation without the goal if doing so
with the goal fails.

Otherwise all bootmem allocations with goal set to
__pa(MAX_DMA_ADDRESS) fail on sparc64, because we set that to ~0 so
effectively all such allocations evaluate roughly to "goal=~0,
limit=~0" which can never succeed.

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index db4e821..3763302 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -109,6 +109,9 @@ config NEED_PER_CPU_EMBED_FIRST_CHUNK
 config NEED_PER_CPU_PAGE_FIRST_CHUNK
 	def_bool y if SPARC64
 
+config NO_BOOTMEM
+	def_bool y if SPARC64
+
 config MMU
 	bool
 	default y
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 21faaee..5b84559 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -741,7 +741,6 @@ static void __init find_ramdisk(unsigned long phys_base)
 struct node_mem_mask {
 	unsigned long mask;
 	unsigned long val;
-	unsigned long bootmem_paddr;
 };
 static struct node_mem_mask node_masks[MAX_NUMNODES];
 static int num_node_masks;
@@ -820,7 +819,7 @@ static u64 memblock_nid_range(u64 start, u64 end, int *nid)
  */
 static void __init allocate_node_data(int nid)
 {
-	unsigned long paddr, num_pages, start_pfn, end_pfn;
+	unsigned long paddr, start_pfn, end_pfn;
 	struct pglist_data *p;
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
@@ -832,7 +831,7 @@ static void __init allocate_node_data(int nid)
 	NODE_DATA(nid) = __va(paddr);
 	memset(NODE_DATA(nid), 0, sizeof(struct pglist_data));
 
-	NODE_DATA(nid)->bdata = &bootmem_node_data[nid];
+	NODE_DATA(nid)->node_id = nid;
 #endif
 
 	p = NODE_DATA(nid);
@@ -840,18 +839,6 @@ static void __init allocate_node_data(int nid)
 	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
 	p->node_start_pfn = start_pfn;
 	p->node_spanned_pages = end_pfn - start_pfn;
-
-	if (p->node_spanned_pages) {
-		num_pages = bootmem_bootmap_pages(p->node_spanned_pages);
-
-		paddr = memblock_alloc_try_nid(num_pages << PAGE_SHIFT, PAGE_SIZE, nid);
-		if (!paddr) {
-			prom_printf("Cannot allocate bootmap for nid[%d]\n",
-				  nid);
-			prom_halt();
-		}
-		node_masks[nid].bootmem_paddr = paddr;
-	}
 }
 
 static void init_node_masks_nonnuma(void)
@@ -1292,75 +1279,9 @@ static void __init bootmem_init_nonnuma(void)
 	node_set_online(0);
 }
 
-static void __init reserve_range_in_node(int nid, unsigned long start,
-					 unsigned long end)
-{
-	numadbg("    reserve_range_in_node(nid[%d],start[%lx],end[%lx]\n",
-		nid, start, end);
-	while (start < end) {
-		unsigned long this_end;
-		int n;
-
-		this_end = memblock_nid_range(start, end, &n);
-		if (n == nid) {
-			numadbg("      MATCH reserving range [%lx:%lx]\n",
-				start, this_end);
-			reserve_bootmem_node(NODE_DATA(nid), start,
-					     (this_end - start), BOOTMEM_DEFAULT);
-		} else
-			numadbg("      NO MATCH, advancing start to %lx\n",
-				this_end);
-
-		start = this_end;
-	}
-}
-
-static void __init trim_reserved_in_node(int nid)
-{
-	struct memblock_region *reg;
-
-	numadbg("  trim_reserved_in_node(%d)\n", nid);
-
-	for_each_memblock(reserved, reg)
-		reserve_range_in_node(nid, reg->base, reg->base + reg->size);
-}
-
-static void __init bootmem_init_one_node(int nid)
-{
-	struct pglist_data *p;
-
-	numadbg("bootmem_init_one_node(%d)\n", nid);
-
-	p = NODE_DATA(nid);
-
-	if (p->node_spanned_pages) {
-		unsigned long paddr = node_masks[nid].bootmem_paddr;
-		unsigned long end_pfn;
-
-		end_pfn = p->node_start_pfn + p->node_spanned_pages;
-
-		numadbg("  init_bootmem_node(%d, %lx, %lx, %lx)\n",
-			nid, paddr >> PAGE_SHIFT, p->node_start_pfn, end_pfn);
-
-		init_bootmem_node(p, paddr >> PAGE_SHIFT,
-				  p->node_start_pfn, end_pfn);
-
-		numadbg("  free_bootmem_with_active_regions(%d, %lx)\n",
-			nid, end_pfn);
-		free_bootmem_with_active_regions(nid, end_pfn);
-
-		trim_reserved_in_node(nid);
-
-		numadbg("  sparse_memory_present_with_active_regions(%d)\n",
-			nid);
-		sparse_memory_present_with_active_regions(nid);
-	}
-}
-
 static unsigned long __init bootmem_init(unsigned long phys_base)
 {
 	unsigned long end_pfn;
-	int nid;
 
 	end_pfn = memblock_end_of_DRAM() >> PAGE_SHIFT;
 	max_pfn = max_low_pfn = end_pfn;
@@ -1369,11 +1290,12 @@ static unsigned long __init bootmem_init(unsigned long phys_base)
 	if (bootmem_init_numa() < 0)
 		bootmem_init_nonnuma();
 
-	/* XXX cpu notifier XXX */
+	/* Dump memblock with node info. */
+	memblock_dump_all();
 
-	for_each_online_node(nid)
-		bootmem_init_one_node(nid);
+	/* XXX cpu notifier XXX */
 
+	sparse_memory_present_with_active_regions(MAX_NUMNODES);
 	sparse_init();
 
 	return end_pfn;
@@ -1973,6 +1895,7 @@ void __init mem_init(void)
 					free_all_bootmem_node(NODE_DATA(i));
 			}
 		}
+		totalram_pages += free_low_memory_core_early(MAX_NUMNODES);
 	}
 #else
 	totalram_pages = free_all_bootmem();
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 24f0fc1..e53bb8a 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -298,13 +298,19 @@ void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
+again:
 	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
 					 goal, -1ULL);
 	if (ptr)
 		return ptr;
 
-	return __alloc_memory_core_early(MAX_NUMNODES, size, align,
-					 goal, -1ULL);
+	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
+					goal, -1ULL);
+	if (!ptr && goal) {
+		goal = 0;
+		goto again;
+	}
+	return ptr;
 }
 
 void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
