Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id EF6186B0071
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 11:01:33 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id p10so5123994pdj.39
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 08:01:33 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id vz6si12332148pab.0.2014.11.27.08.01.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 27 Nov 2014 08:01:30 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFP00J52GMXI670@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 27 Nov 2014 16:04:10 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v8 03/12] x86_64: add KASan support
Date: Thu, 27 Nov 2014 19:00:47 +0300
Message-id: <1417104057-20335-4-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

This patch adds arch specific code for kernel address sanitizer.

16TB of virtual addressed used for shadow memory.
It's located in range [0xffffd90000000000 - 0xffffe90000000000]
which belongs to vmalloc area.

At early stage we map whole shadow region with zero page.
Latter, after pages mapped to direct mapping address range
we unmap zero pages from corresponding shadow (see kasan_map_shadow())
and allocate and map a real shadow memory reusing vmemmap_populate()
function.

Also replace __pa with __pa_nodebug before shadow initialized.
__pa with CONFIG_DEBUG_VIRTUAL=y make external function call (__phys_addr)
__phys_addr is instrumented, so __asan_load could be called before
shadow area initialized.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/Kconfig                  |   1 +
 arch/x86/boot/Makefile            |   2 +
 arch/x86/boot/compressed/Makefile |   2 +
 arch/x86/include/asm/kasan.h      |  27 ++++++++++
 arch/x86/kernel/Makefile          |   2 +
 arch/x86/kernel/dumpstack.c       |   5 +-
 arch/x86/kernel/head64.c          |   9 +++-
 arch/x86/kernel/head_64.S         |  28 ++++++++++
 arch/x86/kernel/setup.c           |   3 ++
 arch/x86/mm/Makefile              |   3 ++
 arch/x86/mm/kasan_init_64.c       | 108 ++++++++++++++++++++++++++++++++++++++
 arch/x86/realmode/Makefile        |   2 +-
 arch/x86/realmode/rm/Makefile     |   1 +
 arch/x86/vdso/Makefile            |   1 +
 lib/Kconfig.kasan                 |   2 +
 15 files changed, 192 insertions(+), 4 deletions(-)
 create mode 100644 arch/x86/include/asm/kasan.h
 create mode 100644 arch/x86/mm/kasan_init_64.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index da51602..f761193 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -84,6 +84,7 @@ config X86
 	select HAVE_CMPXCHG_LOCAL
 	select HAVE_CMPXCHG_DOUBLE
 	select HAVE_ARCH_KMEMCHECK
+	select HAVE_ARCH_KASAN if X86_64
 	select HAVE_USER_RETURN_NOTIFIER
 	select ARCH_BINFMT_ELF_RANDOMIZE_PIE
 	select HAVE_ARCH_JUMP_LABEL
diff --git a/arch/x86/boot/Makefile b/arch/x86/boot/Makefile
index 5b016e2..1ef2724 100644
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
index d999398..0bf4d9f 100644
--- a/arch/x86/boot/compressed/Makefile
+++ b/arch/x86/boot/compressed/Makefile
@@ -16,6 +16,8 @@
 #	(see scripts/Makefile.lib size_append)
 #	compressed vmlinux.bin.all + u32 size of vmlinux.bin.all
 
+KASAN_SANITIZE := n
+
 targets := vmlinux vmlinux.bin vmlinux.bin.gz vmlinux.bin.bz2 vmlinux.bin.lzma \
 	vmlinux.bin.xz vmlinux.bin.lzo vmlinux.bin.lz4
 
diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
new file mode 100644
index 0000000..47e0d42
--- /dev/null
+++ b/arch/x86/include/asm/kasan.h
@@ -0,0 +1,27 @@
+#ifndef _ASM_X86_KASAN_H
+#define _ASM_X86_KASAN_H
+
+#define KASAN_SHADOW_START	0xffffd90000000000UL
+#define KASAN_SHADOW_END	0xffffe90000000000UL
+
+#ifndef __ASSEMBLY__
+
+extern pte_t zero_pte[];
+extern pte_t zero_pmd[];
+extern pte_t zero_pud[];
+
+extern pte_t poisoned_pte[];
+extern pte_t poisoned_pmd[];
+extern pte_t poisoned_pud[];
+
+#ifdef CONFIG_KASAN
+void __init kasan_map_zero_shadow(pgd_t *pgd);
+void __init kasan_init(void);
+#else
+static inline void kasan_map_zero_shadow(pgd_t *pgd) { }
+static inline void kasan_init(void) { }
+#endif
+
+#endif
+
+#endif
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 5d4502c..74d3f3e 100644
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
index eda1a86..b9e4e50 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -27,6 +27,7 @@
 #include <asm/bios_ebda.h>
 #include <asm/bootparam_utils.h>
 #include <asm/microcode.h>
+#include <asm/kasan.h>
 
 /*
  * Manage page tables very early on.
@@ -46,7 +47,7 @@ static void __init reset_early_page_tables(void)
 
 	next_early_pgt = 0;
 
-	write_cr3(__pa(early_level4_pgt));
+	write_cr3(__pa_nodebug(early_level4_pgt));
 }
 
 /* Create a new PMD entry */
@@ -59,7 +60,7 @@ int __init early_make_pgtable(unsigned long address)
 	pmdval_t pmd, *pmd_p;
 
 	/* Invalid address or early pgt is done ?  */
-	if (physaddr >= MAXMEM || read_cr3() != __pa(early_level4_pgt))
+	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_level4_pgt))
 		return -1;
 
 again:
@@ -158,6 +159,8 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	/* Kill off the identity-map trampoline */
 	reset_early_page_tables();
 
+	kasan_map_zero_shadow(early_level4_pgt);
+
 	/* clear bss before set_intr_gate with early_idt_handler */
 	clear_bss();
 
@@ -179,6 +182,8 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	/* set init_level4_pgt kernel high mapping*/
 	init_level4_pgt[511] = early_level4_pgt[511];
 
+	kasan_map_zero_shadow(init_level4_pgt);
+
 	x86_64_start_reservations(real_mode_data);
 }
 
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index a468c0a..444105c 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -514,8 +514,36 @@ ENTRY(phys_base)
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
+
+NEXT_PAGE(poisoned_pte)
+	FILL(poisoned_page - __START_KERNEL_map + __PAGE_KERNEL_RO, 512)
+NEXT_PAGE(poisoned_pmd)
+	FILL(poisoned_pte - __START_KERNEL_map + __PAGE_KERNEL_RO, 512)
+NEXT_PAGE(poisoned_pud)
+	FILL(poisoned_pmd - __START_KERNEL_map + __PAGE_KERNEL_RO, 512)
+
+#undef FILL
+#endif
+
+
 #include "../../x86/xen/xen-head.S"
 	
 	__PAGE_ALIGNED_BSS
 NEXT_PAGE(empty_zero_page)
 	.skip PAGE_SIZE
+#ifdef CONFIG_KASAN
+NEXT_PAGE(poisoned_page)
+	.fill PAGE_SIZE,1,0xF9
+#endif
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index ab4734e..4912b74 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -89,6 +89,7 @@
 #include <asm/cacheflush.h>
 #include <asm/processor.h>
 #include <asm/bugs.h>
+#include <asm/kasan.h>
 
 #include <asm/vsyscall.h>
 #include <asm/cpu.h>
@@ -1176,6 +1177,8 @@ void __init setup_arch(char **cmdline_p)
 
 	x86_init.paging.pagetable_init();
 
+	kasan_init();
+
 	if (boot_cpu_data.cpuid_level >= 0) {
 		/* A CPU has %cr4 if and only if it has CPUID */
 		mmu_cr4_features = read_cr4();
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index ecfdc46..c4cc740 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -20,6 +20,9 @@ obj-$(CONFIG_HIGHMEM)		+= highmem_32.o
 
 obj-$(CONFIG_KMEMCHECK)		+= kmemcheck/
 
+KASAN_SANITIZE_kasan_init_$(BITS).o := n
+obj-$(CONFIG_KASAN)		+= kasan_init_$(BITS).o
+
 obj-$(CONFIG_MMIOTRACE)		+= mmiotrace.o
 mmiotrace-y			:= kmmio.o pf_in.o mmio-mod.o
 obj-$(CONFIG_MMIOTRACE_TEST)	+= testmmiotrace.o
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
new file mode 100644
index 0000000..995de9d
--- /dev/null
+++ b/arch/x86/mm/kasan_init_64.c
@@ -0,0 +1,108 @@
+#include <linux/bootmem.h>
+#include <linux/kasan.h>
+#include <linux/kdebug.h>
+#include <linux/mm.h>
+#include <linux/sched.h>
+#include <linux/vmalloc.h>
+
+#include <asm/tlbflush.h>
+
+extern pgd_t early_level4_pgt[PTRS_PER_PGD];
+extern struct range pfn_mapped[E820_X_MAX];
+
+struct vm_struct kasan_vm __initdata = {
+	.addr = (void *)KASAN_SHADOW_START,
+	.size = (16UL << 40),
+};
+
+
+static int __init map_range(struct range *range)
+{
+	unsigned long start = kasan_mem_to_shadow(
+		(unsigned long)pfn_to_kaddr(range->start));
+	unsigned long end = kasan_mem_to_shadow(
+		(unsigned long)pfn_to_kaddr(range->end));
+
+	/*
+	 * end + 1 here is intentional. We check several shadow bytes in advance
+	 * to slightly speed up fastpath. In some rare cases we could cross
+	 * boundary of mapped shadow, so we just map some more here.
+	 */
+	return vmemmap_populate(start, end + 1, NUMA_NO_NODE);
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
+	unsigned long end = kasan_mem_to_shadow(KASAN_SHADOW_START);
+
+	for (i = pgd_index(start); start < end; i++) {
+		pgd[i] = __pgd(__pa_nodebug(zero_pud) | __PAGE_KERNEL_RO);
+		start += PGDIR_SIZE;
+	}
+
+	start = end;
+	end = kasan_mem_to_shadow(KASAN_SHADOW_END);
+	for (i = pgd_index(start); start < end; i++) {
+		pgd[i] = __pgd(__pa_nodebug(poisoned_pud) | __PAGE_KERNEL_RO);
+		start += PGDIR_SIZE;
+	}
+
+	start = end;
+	end = KASAN_SHADOW_END;
+	for (i = pgd_index(start); start < end; i++) {
+		pgd[i] = __pgd(__pa_nodebug(zero_pud) | __PAGE_KERNEL_RO);
+		start += PGDIR_SIZE;
+	}
+
+}
+
+#ifdef CONFIG_KASAN_INLINE
+static int kasan_die_handler(struct notifier_block *self,
+			     unsigned long val,
+			     void *data)
+{
+	if (val == DIE_GPF) {
+		pr_emerg("CONFIG_KASAN_INLINE enabled\n");
+		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access\n");
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block kasan_die_notifier = {
+	.notifier_call = kasan_die_handler,
+};
+#endif
+
+void __init kasan_init(void)
+{
+	int i;
+
+#ifdef CONFIG_KASAN_INLINE
+	register_die_notifier(&kasan_die_notifier);
+#endif
+	vm_area_add_early(&kasan_vm);
+
+	memcpy(early_level4_pgt, init_level4_pgt, sizeof(early_level4_pgt));
+	load_cr3(early_level4_pgt);
+
+	clear_zero_shadow_mapping(kasan_mem_to_shadow(PAGE_OFFSET),
+				kasan_mem_to_shadow(PAGE_OFFSET + MAXMEM));
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
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 10341df..386cc8b 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -5,6 +5,7 @@ if HAVE_ARCH_KASAN
 
 config KASAN
 	bool "AddressSanitizer: runtime memory debugger"
+	depends on !MEMORY_HOTPLUG
 	help
 	  Enables address sanitizer - runtime memory debugger,
 	  designed to find out-of-bounds accesses and use-after-free bugs.
@@ -15,6 +16,7 @@ config KASAN
 
 config KASAN_SHADOW_OFFSET
 	hex
+	default 0xdfffe90000000000 if X86_64
 
 choice
 	prompt "Instrumentation type"
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
