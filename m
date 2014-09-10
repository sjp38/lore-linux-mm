Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 495FC6B0038
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:38:29 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id ft15so9230899pdb.18
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:38:29 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id w10si28193512pas.64.2014.09.10.07.38.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 10 Sep 2014 07:38:28 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NBO004JKWSTSG90@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 10 Sep 2014 15:41:17 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH v2 02/10] x86_64: add KASan support
Date: Wed, 10 Sep 2014 18:31:19 +0400
Message-id: <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

This patch add arch specific code for kernel address sanitizer.

16TB of virtual addressed used for shadow memory.
It's located in range [0xffff800000000000 - 0xffff900000000000]
Therefore PAGE_OFFSET has to be changed from 0xffff880000000000
to 0xffff900000000000.

At early stage we map whole shadow region with zero page.
Latter, after pages mapped to direct mapping address range
we unmap zero pages from corresponding shadow (see kasan_map_shadow())
and allocate and map a real shadow memory reusing vmemmap_populate()
function.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

---

It would be nice to not have different PAGE_OFFSET with and without CONFIG_KASAN.
We have big enough hole between vmemmap and esp fixup stacks.
So how about moving all direct mapping, vmalloc and vmemmap 8TB up without
hiding it under CONFIG_KASAN?
---
 arch/x86/Kconfig                     |  1 +
 arch/x86/boot/Makefile               |  2 ++
 arch/x86/boot/compressed/Makefile    |  2 ++
 arch/x86/include/asm/kasan.h         | 20 ++++++++++++
 arch/x86/include/asm/page_64_types.h |  4 +++
 arch/x86/include/asm/pgtable.h       |  7 ++++-
 arch/x86/kernel/Makefile             |  2 ++
 arch/x86/kernel/dumpstack.c          |  5 ++-
 arch/x86/kernel/head64.c             |  6 ++++
 arch/x86/kernel/head_64.S            | 16 ++++++++++
 arch/x86/mm/Makefile                 |  3 ++
 arch/x86/mm/init.c                   |  3 ++
 arch/x86/mm/kasan_init_64.c          | 59 ++++++++++++++++++++++++++++++++++++
 arch/x86/realmode/Makefile           |  2 +-
 arch/x86/realmode/rm/Makefile        |  1 +
 arch/x86/vdso/Makefile               |  1 +
 include/linux/kasan.h                |  3 ++
 lib/Kconfig.kasan                    |  1 +
 18 files changed, 135 insertions(+), 3 deletions(-)
 create mode 100644 arch/x86/include/asm/kasan.h
 create mode 100644 arch/x86/mm/kasan_init_64.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 5b1b180..3b8770e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -135,6 +135,7 @@ config X86
 	select HAVE_ACPI_APEI if ACPI
 	select HAVE_ACPI_APEI_NMI if ACPI
 	select ACPI_LEGACY_TABLES_LOOKUP if ACPI
+	select HAVE_ARCH_KASAN if X86_64 && !XEN
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/arch/x86/boot/Makefile b/arch/x86/boot/Makefile
index dbe8dd2..9204cc0 100644
--- a/arch/x86/boot/Makefile
+++ b/arch/x86/boot/Makefile
@@ -14,6 +14,8 @@
 # Set it to -DSVGA_MODE=NORMAL_VGA if you just want the EGA/VGA mode.
 # The number is the same as you would ordinarily press at bootup.
 
+KASAN_SANITIZE := n
+
 SVGA_MODE	:= -DSVGA_MODE=NORMAL_VGA
 
 targets		:= vmlinux.bin setup.bin setup.elf bzImage
diff --git a/arch/x86/boot/compressed/Makefile b/arch/x86/boot/compressed/Makefile
index 7a801a3..8e5b9b3 100644
--- a/arch/x86/boot/compressed/Makefile
+++ b/arch/x86/boot/compressed/Makefile
@@ -4,6 +4,8 @@
 # create a compressed vmlinux image from the original vmlinux
 #
 
+KASAN_SANITIZE := n
+
 targets := vmlinux vmlinux.bin vmlinux.bin.gz vmlinux.bin.bz2 vmlinux.bin.lzma \
 	vmlinux.bin.xz vmlinux.bin.lzo vmlinux.bin.lz4
 
diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
new file mode 100644
index 0000000..bff6a1a
--- /dev/null
+++ b/arch/x86/include/asm/kasan.h
@@ -0,0 +1,20 @@
+#ifndef _ASM_X86_KASAN_H
+#define _ASM_X86_KASAN_H
+
+#define KASAN_SHADOW_START	0xffff800000000000UL
+#define KASAN_SHADOW_END	0xffff900000000000UL
+
+#ifndef __ASSEMBLY__
+extern pte_t zero_pte[];
+extern pte_t zero_pmd[];
+extern pte_t zero_pud[];
+
+#ifdef CONFIG_KASAN
+void __init kasan_map_zero_shadow(pgd_t *pgd);
+#else
+static inline void kasan_map_zero_shadow(pgd_t *pgd) { }
+#endif
+
+#endif
+
+#endif
diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index 6782051..ed98909 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -30,7 +30,11 @@
  * hypervisor to fit.  Choosing 16 slots here is arbitrary, but it's
  * what Xen requires.
  */
+#ifdef CONFIG_KASAN
+#define __PAGE_OFFSET           _AC(0xffff900000000000, UL)
+#else
 #define __PAGE_OFFSET           _AC(0xffff880000000000, UL)
+#endif
 
 #define __START_KERNEL_map	_AC(0xffffffff80000000, UL)
 
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index aa97a07..295263e 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -671,9 +671,14 @@ static inline int pgd_none(pgd_t pgd)
  */
 #define pgd_offset_k(address) pgd_offset(&init_mm, (address))
 
-
+#ifndef CONFIG_KASAN
 #define KERNEL_PGD_BOUNDARY	pgd_index(PAGE_OFFSET)
 #define KERNEL_PGD_PTRS		(PTRS_PER_PGD - KERNEL_PGD_BOUNDARY)
+#else
+#include <asm/kasan.h>
+#define KERNEL_PGD_BOUNDARY	pgd_index(KASAN_SHADOW_START)
+#define KERNEL_PGD_PTRS		(PTRS_PER_PGD - KERNEL_PGD_BOUNDARY)
+#endif
 
 #ifndef __ASSEMBLY__
 
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index ada2e2d..4c59d7f 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -16,6 +16,8 @@ CFLAGS_REMOVE_ftrace.o = -pg
 CFLAGS_REMOVE_early_printk.o = -pg
 endif
 
+KASAN_SANITIZE_head$(BITS).o := n
+
 CFLAGS_irq.o := -I$(src)/../include/asm/trace
 
 obj-y			:= process_$(BITS).o signal.o entry_$(BITS).o
diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
index b74ebc7..cf3df1d 100644
--- a/arch/x86/kernel/dumpstack.c
+++ b/arch/x86/kernel/dumpstack.c
@@ -265,7 +265,10 @@ int __die(const char *str, struct pt_regs *regs, long err)
 	printk("SMP ");
 #endif
 #ifdef CONFIG_DEBUG_PAGEALLOC
-	printk("DEBUG_PAGEALLOC");
+	printk("DEBUG_PAGEALLOC ");
+#endif
+#ifdef CONFIG_KASAN
+	printk("KASAN");
 #endif
 	printk("\n");
 	if (notify_die(DIE_OOPS, str, regs, err,
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index eda1a86..9d97e3a 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -27,6 +27,7 @@
 #include <asm/bios_ebda.h>
 #include <asm/bootparam_utils.h>
 #include <asm/microcode.h>
+#include <asm/kasan.h>
 
 /*
  * Manage page tables very early on.
@@ -158,6 +159,9 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	/* Kill off the identity-map trampoline */
 	reset_early_page_tables();
 
+	kasan_map_zero_shadow(early_level4_pgt);
+	write_cr3(__pa(early_level4_pgt));
+
 	/* clear bss before set_intr_gate with early_idt_handler */
 	clear_bss();
 
@@ -179,6 +183,8 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	/* set init_level4_pgt kernel high mapping*/
 	init_level4_pgt[511] = early_level4_pgt[511];
 
+	kasan_map_zero_shadow(init_level4_pgt);
+
 	x86_64_start_reservations(real_mode_data);
 }
 
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index a468c0a..6be3af7 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -514,6 +514,22 @@ ENTRY(phys_base)
 	/* This must match the first entry in level2_kernel_pgt */
 	.quad   0x0000000000000000
 
+#ifdef CONFIG_KASAN
+#define FILL(VAL, COUNT)				\
+	.rept (COUNT) ;					\
+	.quad	(VAL) ;					\
+	.endr
+
+NEXT_PAGE(zero_pte)
+	FILL(empty_zero_page - __START_KERNEL_map + __PAGE_KERNEL_RO, 512)
+NEXT_PAGE(zero_pmd)
+	FILL(zero_pte - __START_KERNEL_map + __PAGE_KERNEL_RO, 512)
+NEXT_PAGE(zero_pud)
+	FILL(zero_pmd - __START_KERNEL_map + __PAGE_KERNEL_RO, 512)
+#undef FILL
+#endif
+
+
 #include "../../x86/xen/xen-head.S"
 	
 	__PAGE_ALIGNED_BSS
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 6a19ad9..b6c5168 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -8,6 +8,8 @@ CFLAGS_setup_nx.o		:= $(nostackp)
 
 CFLAGS_fault.o := -I$(src)/../include/asm/trace
 
+KASAN_SANITIZE_kasan_init_$(BITS).o := n
+
 obj-$(CONFIG_X86_PAT)		+= pat_rbtree.o
 obj-$(CONFIG_SMP)		+= tlb.o
 
@@ -30,3 +32,4 @@ obj-$(CONFIG_ACPI_NUMA)		+= srat.o
 obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
 
 obj-$(CONFIG_MEMTEST)		+= memtest.o
+obj-$(CONFIG_KASAN)		+= kasan_init_$(BITS).o
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 66dba36..ef017a7 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -4,6 +4,7 @@
 #include <linux/swap.h>
 #include <linux/memblock.h>
 #include <linux/bootmem.h>	/* for max_low_pfn */
+#include <linux/kasan.h>
 
 #include <asm/cacheflush.h>
 #include <asm/e820.h>
@@ -685,5 +686,7 @@ void __init zone_sizes_init(void)
 #endif
 
 	free_area_init_nodes(max_zone_pfns);
+
+	kasan_map_shadow();
 }
 
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
new file mode 100644
index 0000000..1efda37
--- /dev/null
+++ b/arch/x86/mm/kasan_init_64.c
@@ -0,0 +1,59 @@
+#include <linux/mm.h>
+#include <linux/bootmem.h>
+#include <linux/sched.h>
+#include <linux/kasan.h>
+
+#include <asm/tlbflush.h>
+
+extern pgd_t early_level4_pgt[PTRS_PER_PGD];
+extern struct range pfn_mapped[E820_X_MAX];
+
+static int __init map_range(struct range *range)
+{
+	int ret;
+	unsigned long start = kasan_mem_to_shadow(pfn_to_kaddr(range->start));
+	unsigned long end = kasan_mem_to_shadow(pfn_to_kaddr(range->end));
+
+	ret = vmemmap_populate(start, end, NUMA_NO_NODE);
+
+	return ret;
+}
+
+static void __init clear_zero_shadow_mapping(unsigned long start,
+					unsigned long end)
+{
+	for (; start < end; start += PGDIR_SIZE)
+		pgd_clear(pgd_offset_k(start));
+}
+
+void __init kasan_map_zero_shadow(pgd_t *pgd)
+{
+	int i;
+	unsigned long start = KASAN_SHADOW_START;
+	unsigned long end = KASAN_SHADOW_END;
+
+	for (i = pgd_index(start); start < end; i++) {
+		pgd[i] = __pgd(__pa(zero_pud) | __PAGE_KERNEL_RO);
+		start += PGDIR_SIZE;
+	}
+}
+
+void __init kasan_map_shadow(void)
+{
+	int i;
+
+	memcpy(early_level4_pgt, init_level4_pgt, 4096);
+	load_cr3(early_level4_pgt);
+
+	clear_zero_shadow_mapping(kasan_mem_to_shadow(PAGE_OFFSET),
+				kasan_mem_to_shadow(0xffffc80000000000UL));
+
+	for (i = 0; i < E820_X_MAX; i++) {
+		if (pfn_mapped[i].end == 0)
+			break;
+
+		if (map_range(&pfn_mapped[i]))
+			panic("kasan: unable to allocate shadow!");
+	}
+	load_cr3(init_level4_pgt);
+}
diff --git a/arch/x86/realmode/Makefile b/arch/x86/realmode/Makefile
index 94f7fbe..e02c2c6 100644
--- a/arch/x86/realmode/Makefile
+++ b/arch/x86/realmode/Makefile
@@ -6,7 +6,7 @@
 # for more details.
 #
 #
-
+KASAN_SANITIZE := n
 subdir- := rm
 
 obj-y += init.o
diff --git a/arch/x86/realmode/rm/Makefile b/arch/x86/realmode/rm/Makefile
index 7c0d7be..2730d77 100644
--- a/arch/x86/realmode/rm/Makefile
+++ b/arch/x86/realmode/rm/Makefile
@@ -6,6 +6,7 @@
 # for more details.
 #
 #
+KASAN_SANITIZE := n
 
 always := realmode.bin realmode.relocs
 
diff --git a/arch/x86/vdso/Makefile b/arch/x86/vdso/Makefile
index 5a4affe..2aacd7c 100644
--- a/arch/x86/vdso/Makefile
+++ b/arch/x86/vdso/Makefile
@@ -3,6 +3,7 @@
 #
 
 KBUILD_CFLAGS += $(DISABLE_LTO)
+KASAN_SANITIZE := n
 
 VDSO64-$(CONFIG_X86_64)		:= y
 VDSOX32-$(CONFIG_X86_X32_ABI)	:= y
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 6055f64..f957ee9 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -29,6 +29,7 @@ static inline void kasan_disable_local(void)
 }
 
 void kasan_unpoison_shadow(const void *address, size_t size);
+void kasan_map_shadow(void);
 
 #else /* CONFIG_KASAN */
 
@@ -37,6 +38,8 @@ static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
 static inline void kasan_enable_local(void) {}
 static inline void kasan_disable_local(void) {}
 
+static inline void kasan_map_shadow(void) {}
+
 #endif /* CONFIG_KASAN */
 
 #endif /* LINUX_KASAN_H */
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 22fec2d..156d3e6 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -5,6 +5,7 @@ if HAVE_ARCH_KASAN
 
 config KASAN
 	bool "AddressSanitizer: dynamic memory error detector"
+	depends on !MEMORY_HOTPLUG
 	default n
 	help
 	  Enables address sanitizer - dynamic memory error detector,
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
