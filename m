Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id AB33F6B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 05:54:02 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so6895188pbb.14
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 02:54:02 -0700 (PDT)
Message-ID: <524A9B7F.7020904@cn.fujitsu.com>
Date: Tue, 01 Oct 2013 17:53:03 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH -mm 4/8] memblock: Make memblock_set_node() support different
 memblock_type
References: <524A991D.3050005@cn.fujitsu.com>
In-Reply-To: <524A991D.3050005@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, Rik van Riel <riel@redhat.com>, prarit@redhat.com, Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei.yes@gmail.com>

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
index 1cf9c5b..9bf3e57 100644
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
index 1f68d0e..ac4ea06 100644
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
index 10fa75b..b6f149f 100644
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
index bd26ce8..d8a9420 100644
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
