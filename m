Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id D1C096B0071
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:28:27 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so19283718pdj.39
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:28:27 -0800 (PST)
Received: from song.cn.fujitsu.com ([222.73.24.84])
        by mx.google.com with ESMTP id xa2si49714850pab.316.2013.12.02.18.28.24
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 18:28:26 -0800 (PST)
Message-ID: <529D4127.8030106@cn.fujitsu.com>
Date: Tue, 03 Dec 2013 10:25:43 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH RESEND part2 v2 4/8] memblock: Make memblock_set_node() support
 different memblock_type
References: <529D3FC0.6000403@cn.fujitsu.com>
In-Reply-To: <529D3FC0.6000403@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/metag/mm/init.c      |    3 ++-
 arch/metag/mm/numa.c      |    3 ++-
 arch/microblaze/mm/init.c |    3 ++-
 arch/powerpc/mm/mem.c     |    2 +-
 arch/powerpc/mm/numa.c    |    8 +++++---
 arch/sh/kernel/setup.c    |    4 ++--
 arch/sparc/mm/init_64.c   |    5 +++--
 arch/x86/mm/init_32.c     |    2 +-
 arch/x86/mm/init_64.c     |    2 +-
 arch/x86/mm/numa.c        |    6 ++++--
 include/linux/memblock.h  |    3 ++-
 mm/memblock.c             |    6 +++---
 12 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/arch/metag/mm/init.c b/arch/metag/mm/init.c
index 1239195..d94a58f 100644
--- a/arch/metag/mm/init.c
+++ b/arch/metag/mm/init.c
@@ -205,7 +205,8 @@ static void __init do_init_bootmem(void)
 		start_pfn = memblock_region_memory_base_pfn(reg);
 		end_pfn = memblock_region_memory_end_pfn(reg);
 		memblock_set_node(PFN_PHYS(start_pfn),
-				  PFN_PHYS(end_pfn - start_pfn), 0);
+				  PFN_PHYS(end_pfn - start_pfn),
+				  &memblock.memory, 0);
 	}
 
 	/* All of system RAM sits in node 0 for the non-NUMA case */
diff --git a/arch/metag/mm/numa.c b/arch/metag/mm/numa.c
index 9ae578c..229407f 100644
--- a/arch/metag/mm/numa.c
+++ b/arch/metag/mm/numa.c
@@ -42,7 +42,8 @@ void __init setup_bootmem_node(int nid, unsigned long start, unsigned long end)
 	memblock_add(start, end - start);
 
 	memblock_set_node(PFN_PHYS(start_pfn),
-			  PFN_PHYS(end_pfn - start_pfn), nid);
+			  PFN_PHYS(end_pfn - start_pfn),
+			  &memblock.memory, nid);
 
 	/* Node-local pgdat */
 	pgdat_paddr = memblock_alloc_base(sizeof(struct pglist_data),
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 74c7bcc..89077d3 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -192,7 +192,8 @@ void __init setup_memory(void)
 		start_pfn = memblock_region_memory_base_pfn(reg);
 		end_pfn = memblock_region_memory_end_pfn(reg);
 		memblock_set_node(start_pfn << PAGE_SHIFT,
-					(end_pfn - start_pfn) << PAGE_SHIFT, 0);
+				  (end_pfn - start_pfn) << PAGE_SHIFT,
+				  &memblock.memory, 0);
 	}
 
 	/* free bootmem is whole main memory */
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 3fa93dc..231b785 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -209,7 +209,7 @@ void __init do_init_bootmem(void)
 	/* Place all memblock_regions in the same node and merge contiguous
 	 * memblock_regions
 	 */
-	memblock_set_node(0, (phys_addr_t)ULLONG_MAX, 0);
+	memblock_set_node(0, (phys_addr_t)ULLONG_MAX, &memblock_memory, 0);
 
 	/* Add all physical memory to the bootmem map, mark each area
 	 * present.
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index c916127..f82f2ea 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -670,7 +670,8 @@ static void __init parse_drconf_memory(struct device_node *memory)
 			node_set_online(nid);
 			sz = numa_enforce_memory_limit(base, size);
 			if (sz)
-				memblock_set_node(base, sz, nid);
+				memblock_set_node(base, sz,
+						  &memblock.memory, nid);
 		} while (--ranges);
 	}
 }
@@ -760,7 +761,7 @@ new_range:
 				continue;
 		}
 
-		memblock_set_node(start, size, nid);
+		memblock_set_node(start, size, &memblock.memory, nid);
 
 		if (--ranges)
 			goto new_range;
@@ -797,7 +798,8 @@ static void __init setup_nonnuma(void)
 
 		fake_numa_create_new_node(end_pfn, &nid);
 		memblock_set_node(PFN_PHYS(start_pfn),
-				  PFN_PHYS(end_pfn - start_pfn), nid);
+				  PFN_PHYS(end_pfn - start_pfn),
+				  &memblock.memory, nid);
 		node_set_online(nid);
 	}
 }
diff --git a/arch/sh/kernel/setup.c b/arch/sh/kernel/setup.c
index 1cf90e9..de19cfa 100644
--- a/arch/sh/kernel/setup.c
+++ b/arch/sh/kernel/setup.c
@@ -230,8 +230,8 @@ void __init __add_active_range(unsigned int nid, unsigned long start_pfn,
 	pmb_bolt_mapping((unsigned long)__va(start), start, end - start,
 			 PAGE_KERNEL);
 
-	memblock_set_node(PFN_PHYS(start_pfn),
-			  PFN_PHYS(end_pfn - start_pfn), nid);
+	memblock_set_node(PFN_PHYS(start_pfn), PFN_PHYS(end_pfn - start_pfn),
+			  &memblock.memory, nid);
 }
 
 void __init __weak plat_early_device_setup(void)
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index ed82eda..31beb53 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -1021,7 +1021,8 @@ static void __init add_node_ranges(void)
 				"start[%lx] end[%lx]\n",
 				nid, start, this_end);
 
-			memblock_set_node(start, this_end - start, nid);
+			memblock_set_node(start, this_end - start,
+					  &memblock.memory, nid);
 			start = this_end;
 		}
 	}
@@ -1325,7 +1326,7 @@ static void __init bootmem_init_nonnuma(void)
 	       (top_of_ram - total_ram) >> 20);
 
 	init_node_masks_nonnuma();
-	memblock_set_node(0, (phys_addr_t)ULLONG_MAX, 0);
+	memblock_set_node(0, (phys_addr_t)ULLONG_MAX, &memblock.memory, 0);
 	allocate_node_data(0);
 	node_set_online(0);
 }
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 4287f1f..d9685b6 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -665,7 +665,7 @@ void __init initmem_init(void)
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE - 1) + 1;
 #endif
 
-	memblock_set_node(0, (phys_addr_t)ULLONG_MAX, 0);
+	memblock_set_node(0, (phys_addr_t)ULLONG_MAX, &memblock.memory, 0);
 	sparse_memory_present_with_active_regions(0);
 
 #ifdef CONFIG_FLATMEM
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 104d56a..f35c66c 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -643,7 +643,7 @@ kernel_physical_mapping_init(unsigned long start,
 #ifndef CONFIG_NUMA
 void __init initmem_init(void)
 {
-	memblock_set_node(0, (phys_addr_t)ULLONG_MAX, 0);
+	memblock_set_node(0, (phys_addr_t)ULLONG_MAX, &memblock.memory, 0);
 }
 #endif
 
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index e17db5d..ab69e1d 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -492,7 +492,8 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 
 	for (i = 0; i < mi->nr_blks; i++) {
 		struct numa_memblk *mb = &mi->blk[i];
-		memblock_set_node(mb->start, mb->end - mb->start, mb->nid);
+		memblock_set_node(mb->start, mb->end - mb->start,
+				  &memblock.memory, mb->nid);
 	}
 
 	/*
@@ -566,7 +567,8 @@ static int __init numa_init(int (*init_func)(void))
 	nodes_clear(node_possible_map);
 	nodes_clear(node_online_map);
 	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
-	WARN_ON(memblock_set_node(0, ULLONG_MAX, MAX_NUMNODES));
+	WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.memory,
+				  MAX_NUMNODES));
 	numa_reset_distance();
 
 	ret = init_func();
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index b788faa..97480d3 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -140,7 +140,8 @@ static inline void memblock_clear_region_flags(struct memblock_region *r,
 }
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-int memblock_set_node(phys_addr_t base, phys_addr_t size, int nid);
+int memblock_set_node(phys_addr_t base, phys_addr_t size,
+		      struct memblock_type *type, int nid);
 
 static inline void memblock_set_region_node(struct memblock_region *r, int nid)
 {
diff --git a/mm/memblock.c b/mm/memblock.c
index 5bea331..7de9c76 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -910,18 +910,18 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
  * memblock_set_node - set node ID on memblock regions
  * @base: base of area to set node ID for
  * @size: size of area to set node ID for
+ * @type: memblock type to set node ID for
  * @nid: node ID to set
  *
- * Set the nid of memblock memory regions in [@base,@base+@size) to @nid.
+ * Set the nid of memblock @type regions in [@base,@base+@size) to @nid.
  * Regions which cross the area boundaries are split as necessary.
  *
  * RETURNS:
  * 0 on success, -errno on failure.
  */
 int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
-				      int nid)
+				      struct memblock_type *type, int nid)
 {
-	struct memblock_type *type = &memblock.memory;
 	int start_rgn, end_rgn;
 	int i, ret;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
