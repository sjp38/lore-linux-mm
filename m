Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 234826B00AE
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 17:27:44 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so1682685pab.14
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 14:27:43 -0800 (PST)
Received: from psmtp.com ([74.125.245.153])
        by mx.google.com with SMTP id yg5si810954pbc.356.2013.11.12.14.27.41
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 14:27:42 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCHv2 2/4] arm: mm: Track lowmem in vmalloc
Date: Tue, 12 Nov 2013 14:27:30 -0800
Message-Id: <1384295252-31778-3-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1384295252-31778-1-git-send-email-lauraa@codeaurora.org>
References: <1384295252-31778-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: Kyungmin Park <kmpark@infradead.org>, Russell King <linux@arm.linux.org.uk>, Laura Abbott <lauraa@codeaurora.org>, Neeti Desai <neetid@codeaurora.org>

Rather than always keeping lowmem and vmalloc separate, we can
now allow the two to be mixed. This means that all lowmem areas
need to be explicitly tracked in vmalloc to avoid over allocating.
Additionally, adjust the vmalloc reserve to account for the fact
that there may be a hole in the middle consisting of vmalloc.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
Signed-off-by: Neeti Desai <neetid@codeaurora.org>
---
 arch/arm/Kconfig   |    3 +
 arch/arm/mm/init.c |  104 ++++++++++++++++++++++++++++++++++++----------------
 arch/arm/mm/mm.h   |    1 +
 arch/arm/mm/mmu.c  |   23 +++++++++++
 4 files changed, 99 insertions(+), 32 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 051fce4..1f36664 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -270,6 +270,9 @@ config GENERIC_BUG
 	def_bool y
 	depends on BUG
 
+config ARCH_TRACKS_VMALLOC
+	bool
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 15225d8..c9ca316 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -576,6 +576,46 @@ static void __init free_highpages(void)
 #endif
 }
 
+#define MLK(b, t) b, t, ((t) - (b)) >> 10
+#define MLM(b, t) b, t, ((t) - (b)) >> 20
+#define MLK_ROUNDUP(b, t) b, t, DIV_ROUND_UP(((t) - (b)), SZ_1K)
+
+#ifdef CONFIG_ENABLE_VMALLOC_SAVING
+void print_vmalloc_lowmem_info(void)
+{
+	int i;
+	void *va_start, *va_end;
+
+	printk(KERN_NOTICE
+		"	   vmalloc : 0x%08lx - 0x%08lx   (%4ld MB)\n",
+		MLM(VMALLOC_START, VMALLOC_END));
+
+	for (i = meminfo.nr_banks - 1; i >= 0; i--) {
+		if (!meminfo.bank[i].highmem) {
+			va_start = __va(meminfo.bank[i].start);
+			va_end = __va(meminfo.bank[i].start +
+						meminfo.bank[i].size);
+			printk(KERN_NOTICE
+			 "	    lowmem : 0x%08lx - 0x%08lx   (%4ld MB)\n",
+			MLM((unsigned long)va_start, (unsigned long)va_end));
+		}
+		if (i && ((meminfo.bank[i-1].start + meminfo.bank[i-1].size) !=
+			   meminfo.bank[i].start)) {
+			if (meminfo.bank[i-1].start + meminfo.bank[i-1].size
+				   <= MAX_HOLE_ADDRESS) {
+				va_start = __va(meminfo.bank[i-1].start
+						+ meminfo.bank[i-1].size);
+				va_end = __va(meminfo.bank[i].start);
+				printk(KERN_NOTICE
+				"	   vmalloc : 0x%08lx - 0x%08lx   (%4ld MB)\n",
+					   MLM((unsigned long)va_start,
+						   (unsigned long)va_end));
+			}
+		}
+	}
+}
+#endif
+
 /*
  * mem_init() marks the free areas in the mem_map and tells us how much
  * memory is free.  This is done after various parts of the system have
@@ -604,55 +644,52 @@ void __init mem_init(void)
 
 	mem_init_print_info(NULL);
 
-#define MLK(b, t) b, t, ((t) - (b)) >> 10
-#define MLM(b, t) b, t, ((t) - (b)) >> 20
-#define MLK_ROUNDUP(b, t) b, t, DIV_ROUND_UP(((t) - (b)), SZ_1K)
-
 	printk(KERN_NOTICE "Virtual kernel memory layout:\n"
 			"    vector  : 0x%08lx - 0x%08lx   (%4ld kB)\n"
 #ifdef CONFIG_HAVE_TCM
 			"    DTCM    : 0x%08lx - 0x%08lx   (%4ld kB)\n"
 			"    ITCM    : 0x%08lx - 0x%08lx   (%4ld kB)\n"
 #endif
-			"    fixmap  : 0x%08lx - 0x%08lx   (%4ld kB)\n"
-			"    vmalloc : 0x%08lx - 0x%08lx   (%4ld MB)\n"
-			"    lowmem  : 0x%08lx - 0x%08lx   (%4ld MB)\n"
-#ifdef CONFIG_HIGHMEM
-			"    pkmap   : 0x%08lx - 0x%08lx   (%4ld MB)\n"
-#endif
-#ifdef CONFIG_MODULES
-			"    modules : 0x%08lx - 0x%08lx   (%4ld MB)\n"
-#endif
-			"      .text : 0x%p" " - 0x%p" "   (%4d kB)\n"
-			"      .init : 0x%p" " - 0x%p" "   (%4d kB)\n"
-			"      .data : 0x%p" " - 0x%p" "   (%4d kB)\n"
-			"       .bss : 0x%p" " - 0x%p" "   (%4d kB)\n",
-
+			"    fixmap  : 0x%08lx - 0x%08lx   (%4ld kB)\n",
 			MLK(UL(CONFIG_VECTORS_BASE), UL(CONFIG_VECTORS_BASE) +
 				(PAGE_SIZE)),
 #ifdef CONFIG_HAVE_TCM
 			MLK(DTCM_OFFSET, (unsigned long) dtcm_end),
 			MLK(ITCM_OFFSET, (unsigned long) itcm_end),
 #endif
-			MLK(FIXADDR_START, FIXADDR_TOP),
-			MLM(VMALLOC_START, VMALLOC_END),
-			MLM(PAGE_OFFSET, (unsigned long)high_memory),
+			MLK(FIXADDR_START, FIXADDR_TOP));
+#ifdef CONFIG_ENABLE_VMALLOC_SAVING
+	print_vmalloc_lowmem_info();
+#else
+	printk(KERN_NOTICE
+		   "    vmalloc : 0x%08lx - 0x%08lx   (%4ld MB)\n"
+		   "    lowmem  : 0x%08lx - 0x%08lx   (%4ld MB)\n",
+		   MLM(VMALLOC_START, VMALLOC_END),
+		   MLM(PAGE_OFFSET, (unsigned long)high_memory));
+#endif
 #ifdef CONFIG_HIGHMEM
-			MLM(PKMAP_BASE, (PKMAP_BASE) + (LAST_PKMAP) *
+	printk(KERN_NOTICE
+		   "    pkmap   : 0x%08lx - 0x%08lx   (%4ld MB)\n"
+#endif
+#ifdef CONFIG_MODULES
+		   "    modules : 0x%08lx - 0x%08lx   (%4ld MB)\n"
+#endif
+		   "      .text : 0x%p" " - 0x%p" "   (%4d kB)\n"
+		   "      .init : 0x%p" " - 0x%p" "   (%4d kB)\n"
+		   "      .data : 0x%p" " - 0x%p" "   (%4d kB)\n"
+		   "       .bss : 0x%p" " - 0x%p" "   (%4d kB)\n",
+#ifdef CONFIG_HIGHMEM
+		   MLM(PKMAP_BASE, (PKMAP_BASE) + (LAST_PKMAP) *
 				(PAGE_SIZE)),
 #endif
 #ifdef CONFIG_MODULES
-			MLM(MODULES_VADDR, MODULES_END),
+		   MLM(MODULES_VADDR, MODULES_END),
 #endif
 
-			MLK_ROUNDUP(_text, _etext),
-			MLK_ROUNDUP(__init_begin, __init_end),
-			MLK_ROUNDUP(_sdata, _edata),
-			MLK_ROUNDUP(__bss_start, __bss_stop));
-
-#undef MLK
-#undef MLM
-#undef MLK_ROUNDUP
+		   MLK_ROUNDUP(_text, _etext),
+		   MLK_ROUNDUP(__init_begin, __init_end),
+		   MLK_ROUNDUP(_sdata, _edata),
+		   MLK_ROUNDUP(__bss_start, __bss_stop));
 
 	/*
 	 * Check boundaries twice: Some fundamental inconsistencies can
@@ -660,7 +697,7 @@ void __init mem_init(void)
 	 */
 #ifdef CONFIG_MMU
 	BUILD_BUG_ON(TASK_SIZE				> MODULES_VADDR);
-	BUG_ON(TASK_SIZE 				> MODULES_VADDR);
+	BUG_ON(TASK_SIZE				> MODULES_VADDR);
 #endif
 
 #ifdef CONFIG_HIGHMEM
@@ -679,6 +716,9 @@ void __init mem_init(void)
 	}
 }
 
+#undef MLK
+#undef MLM
+#undef MLK_ROUNDUP
 void free_initmem(void)
 {
 #ifdef CONFIG_HAVE_TCM
diff --git a/arch/arm/mm/mm.h b/arch/arm/mm/mm.h
index 27a3680..f484e52 100644
--- a/arch/arm/mm/mm.h
+++ b/arch/arm/mm/mm.h
@@ -85,6 +85,7 @@ extern phys_addr_t arm_dma_limit;
 #define arm_dma_limit ((phys_addr_t)~0)
 #endif
 
+#define MAX_HOLE_ADDRESS    (PHYS_OFFSET + 0x10000000)
 extern phys_addr_t arm_lowmem_limit;
 
 void __init bootmem_init(void);
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index b83ed88..ed2a4fa 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -1004,6 +1004,19 @@ void __init sanity_check_meminfo(void)
 	int i, j, highmem = 0;
 	phys_addr_t vmalloc_limit = __pa(vmalloc_min - 1) + 1;
 
+#ifdef CONFIG_ARCH_TRACKS_VMALLOC
+	unsigned long hole_start;
+	for (i = 0; i < (meminfo.nr_banks - 1); i++) {
+		hole_start = meminfo.bank[i].start + meminfo.bank[i].size;
+		if (hole_start != meminfo.bank[i+1].start) {
+			if (hole_start <= MAX_HOLE_ADDRESS) {
+				vmalloc_min = (void *) (vmalloc_min +
+				(meminfo.bank[i+1].start - hole_start));
+			}
+		}
+	}
+#endif
+
 	for (i = 0, j = 0; i < meminfo.nr_banks; i++) {
 		struct membank *bank = &meminfo.bank[j];
 		phys_addr_t size_limit;
@@ -1311,6 +1324,7 @@ static void __init map_lowmem(void)
 		phys_addr_t start = reg->base;
 		phys_addr_t end = start + reg->size;
 		struct map_desc map;
+		struct vm_struct *vm;
 
 		if (end > arm_lowmem_limit)
 			end = arm_lowmem_limit;
@@ -1323,6 +1337,15 @@ static void __init map_lowmem(void)
 		map.type = MT_MEMORY;
 
 		create_mapping(&map);
+
+#ifdef CONFIG_ARCH_TRACKS_VMALLOC
+		vm = early_alloc_aligned(sizeof(*vm), __alignof__(*vm));
+		vm->addr = (void *)map.virtual;
+		vm->size = end - start;
+		vm->flags = VM_LOWMEM;
+		vm->caller = map_lowmem;
+		vm_area_add_early(vm);
+#endif
 	}
 }
 
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
