Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 33C61900011
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:11 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 21/22] x86, mm: Make init_mem_mapping be able to be called several times
Date: Thu, 13 Jun 2013 21:03:08 +0800
Message-Id: <1371128589-8953-22-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Jacob Shin <jacob.shin@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

From: Yinghai Lu <yinghai@kernel.org>

Prepare to put page table on local nodes.

Move calling of init_mem_mapping() to early_initmem_init().

Rework alloc_low_pages to allocate page table in following order:
	BRK, local node, low range

Still only load_cr3 one time, otherwise we would break xen 64bit again.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Jacob Shin <jacob.shin@amd.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/include/asm/pgtable.h |    2 +-
 arch/x86/kernel/setup.c        |    1 -
 arch/x86/mm/init.c             |  100 +++++++++++++++++++++++++---------------
 arch/x86/mm/numa.c             |   24 ++++++++++
 4 files changed, 88 insertions(+), 39 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 1e67223..868687c 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -621,7 +621,7 @@ static inline int pgd_none(pgd_t pgd)
 #ifndef __ASSEMBLY__
 
 extern int direct_gbpages;
-void init_mem_mapping(void);
+void init_mem_mapping(unsigned long begin, unsigned long end);
 void early_alloc_pgt_buf(void);
 
 /* local pte updates need not use xchg for locking */
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index fd0d5be..9ccbd60 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1132,7 +1132,6 @@ void __init setup_arch(char **cmdline_p)
 	acpi_boot_table_init();
 	early_acpi_boot_init();
 	early_initmem_init();
-	init_mem_mapping();
 	memblock.current_limit = get_max_mapped();
 	early_trap_pf_init();
 
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 5f38e72..9ff71ff 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -24,7 +24,10 @@ static unsigned long __initdata pgt_buf_start;
 static unsigned long __initdata pgt_buf_end;
 static unsigned long __initdata pgt_buf_top;
 
-static unsigned long min_pfn_mapped;
+static unsigned long low_min_pfn_mapped;
+static unsigned long low_max_pfn_mapped;
+static unsigned long local_min_pfn_mapped;
+static unsigned long local_max_pfn_mapped;
 
 static bool __initdata can_use_brk_pgt = true;
 
@@ -52,10 +55,17 @@ __ref void *alloc_low_pages(unsigned int num)
 
 	if ((pgt_buf_end + num) > pgt_buf_top || !can_use_brk_pgt) {
 		unsigned long ret;
-		if (min_pfn_mapped >= max_pfn_mapped)
-			panic("alloc_low_page: ran out of memory");
-		ret = memblock_find_in_range(min_pfn_mapped << PAGE_SHIFT,
-					max_pfn_mapped << PAGE_SHIFT,
+		if (local_min_pfn_mapped >= local_max_pfn_mapped) {
+			if (low_min_pfn_mapped >= low_max_pfn_mapped)
+				panic("alloc_low_page: ran out of memory");
+			ret = memblock_find_in_range(
+					low_min_pfn_mapped << PAGE_SHIFT,
+					low_max_pfn_mapped << PAGE_SHIFT,
+					PAGE_SIZE * num , PAGE_SIZE);
+		} else
+			ret = memblock_find_in_range(
+					local_min_pfn_mapped << PAGE_SHIFT,
+					local_max_pfn_mapped << PAGE_SHIFT,
 					PAGE_SIZE * num , PAGE_SIZE);
 		if (!ret)
 			panic("alloc_low_page: can not alloc memory");
@@ -412,67 +422,88 @@ static unsigned long __init get_new_step_size(unsigned long step_size)
 	return  step_size;
 }
 
-void __init init_mem_mapping(void)
+void __init init_mem_mapping(unsigned long begin, unsigned long end)
 {
-	unsigned long end, real_end, start, last_start;
+	unsigned long real_end, start, last_start;
 	unsigned long step_size;
 	unsigned long addr;
 	unsigned long mapped_ram_size = 0;
 	unsigned long new_mapped_ram_size;
+	bool is_low = false;
+
+	if (!begin) {
+		probe_page_size_mask();
+		/* the ISA range is always mapped regardless of memory holes */
+		init_memory_mapping(0, ISA_END_ADDRESS);
+		begin = ISA_END_ADDRESS;
+		is_low = true;
+	}
 
-	probe_page_size_mask();
-
-#ifdef CONFIG_X86_64
-	end = max_pfn << PAGE_SHIFT;
-#else
-	end = max_low_pfn << PAGE_SHIFT;
-#endif
-
-	/* the ISA range is always mapped regardless of memory holes */
-	init_memory_mapping(0, ISA_END_ADDRESS);
+	if (begin >= end)
+		return;
 
 	/* xen has big range in reserved near end of ram, skip it at first.*/
-	addr = memblock_find_in_range(ISA_END_ADDRESS, end, PMD_SIZE, PMD_SIZE);
+	addr = memblock_find_in_range(begin, end, PMD_SIZE, PMD_SIZE);
 	real_end = addr + PMD_SIZE;
 
 	/* step_size need to be small so pgt_buf from BRK could cover it */
 	step_size = PMD_SIZE;
-	max_pfn_mapped = 0; /* will get exact value next */
-	min_pfn_mapped = real_end >> PAGE_SHIFT;
+	local_max_pfn_mapped = begin >> PAGE_SHIFT;
+	local_min_pfn_mapped = real_end >> PAGE_SHIFT;
 	last_start = start = real_end;
 
 	/*
-	 * We start from the top (end of memory) and go to the bottom.
-	 * The memblock_find_in_range() gets us a block of RAM from the
-	 * end of RAM in [min_pfn_mapped, max_pfn_mapped) used as new pages
-	 * for page table.
+	 * alloc_low_pages() will allocate pagetable pages in the following
+	 * order:
+	 *	BRK, local node, low range
+	 *
+	 * That means it will first use up all the BRK memory, then try to get
+	 * us a block of RAM from [local_min_pfn_mapped, local_max_pfn_mapped)
+	 * used as new pagetable pages. If no memory on the local node has
+	 * been mapped, it will allocate memory from
+	 * [low_min_pfn_mapped, low_max_pfn_mapped).
 	 */
-	while (last_start > ISA_END_ADDRESS) {
+	while (last_start > begin) {
 		if (last_start > step_size) {
 			start = round_down(last_start - 1, step_size);
-			if (start < ISA_END_ADDRESS)
-				start = ISA_END_ADDRESS;
+			if (start < begin)
+				start = begin;
 		} else
-			start = ISA_END_ADDRESS;
+			start = begin;
 		new_mapped_ram_size = init_range_memory_mapping(start,
 							last_start);
+		if ((last_start >> PAGE_SHIFT) > local_max_pfn_mapped)
+			local_max_pfn_mapped = last_start >> PAGE_SHIFT;
+		local_min_pfn_mapped = start >> PAGE_SHIFT;
 		last_start = start;
-		min_pfn_mapped = last_start >> PAGE_SHIFT;
 		/* only increase step_size after big range get mapped */
 		if (new_mapped_ram_size > mapped_ram_size)
 			step_size = get_new_step_size(step_size);
 		mapped_ram_size += new_mapped_ram_size;
 	}
 
-	if (real_end < end)
+	if (real_end < end) {
 		init_range_memory_mapping(real_end, end);
+		if ((end >> PAGE_SHIFT) > local_max_pfn_mapped)
+			local_max_pfn_mapped = end >> PAGE_SHIFT;
+	}
 
+	if (is_low) {
+		low_min_pfn_mapped = local_min_pfn_mapped;
+		low_max_pfn_mapped = local_max_pfn_mapped;
+	}
+}
+
+#ifndef CONFIG_NUMA
+void __init early_initmem_init(void)
+{
 #ifdef CONFIG_X86_64
-	if (max_pfn > max_low_pfn) {
-		/* can we preseve max_low_pfn ?*/
+	init_mem_mapping(0, max_pfn << PAGE_SHIFT);
+	if (max_pfn > max_low_pfn)
 		max_low_pfn = max_pfn;
 	}
 #else
+	init_mem_mapping(0, max_low_pfn << PAGE_SHIFT);
 	early_ioremap_page_table_range_init();
 #endif
 
@@ -481,11 +512,6 @@ void __init init_mem_mapping(void)
 
 	early_memtest(0, max_pfn_mapped << PAGE_SHIFT);
 }
-
-#ifndef CONFIG_NUMA
-void __init early_initmem_init(void)
-{
-}
 #endif
 
 /*
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 7d76936..9b18ee8 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -17,8 +17,10 @@
 #include <asm/dma.h>
 #include <asm/acpi.h>
 #include <asm/amd_nb.h>
+#include <asm/tlbflush.h>
 
 #include "numa_internal.h"
+#include "mm_internal.h"
 
 int __initdata numa_off;
 nodemask_t numa_nodes_parsed __initdata;
@@ -665,9 +667,31 @@ static void __init early_x86_numa_init(void)
 	numa_init(dummy_numa_init);
 }
 
+#ifdef CONFIG_X86_64
+static void __init early_x86_numa_init_mapping(void)
+{
+	init_mem_mapping(0, max_pfn << PAGE_SHIFT);
+	if (max_pfn > max_low_pfn)
+		max_low_pfn = max_pfn;
+}
+#else
+static void __init early_x86_numa_init_mapping(void)
+{
+	init_mem_mapping(0, max_low_pfn << PAGE_SHIFT);
+	early_ioremap_page_table_range_init();
+}
+#endif
+
 void __init early_initmem_init(void)
 {
 	early_x86_numa_init();
+
+	early_x86_numa_init_mapping();
+
+	load_cr3(swapper_pg_dir);
+	__flush_tlb_all();
+
+	early_memtest(0, max_pfn_mapped<<PAGE_SHIFT);
 }
 
 void __init x86_numa_init(void)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
