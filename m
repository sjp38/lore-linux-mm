Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id ED4466B025F
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:07:32 -0500 (EST)
Received: by wmuu63 with SMTP id u63so44724949wmu.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:07:32 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id u130si17819141wmb.100.2015.11.23.01.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 01:07:31 -0800 (PST)
Received: by wmww144 with SMTP id w144so86945421wmw.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:07:31 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v3 12/13] ARM: wire up UEFI init and runtime support
Date: Mon, 23 Nov 2015 10:06:32 +0100
Message-Id: <1448269593-20758-13-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

This adds support to the kernel proper for booting via UEFI. It shares
most of the code with arm64, so this patch mostly just wires it up for
use with ARM.

Note that this does not include the EFI stub, it is added in a subsequent
patch.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm/include/asm/efi.h         | 60 ++++++++++++++++++++
 arch/arm/include/asm/mmu_context.h |  2 +-
 arch/arm/kernel/Makefile           |  1 +
 arch/arm/kernel/efi.c              | 38 +++++++++++++
 arch/arm/kernel/setup.c            |  3 +
 drivers/firmware/efi/Makefile      |  1 +
 6 files changed, 104 insertions(+), 1 deletion(-)

diff --git a/arch/arm/include/asm/efi.h b/arch/arm/include/asm/efi.h
new file mode 100644
index 000000000000..c91e330616ad
--- /dev/null
+++ b/arch/arm/include/asm/efi.h
@@ -0,0 +1,60 @@
+/*
+ * Copyright (C) 2015 Linaro Ltd <ard.biesheuvel@linaro.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __ASM_ARM_EFI_H
+#define __ASM_ARM_EFI_H
+
+#include <asm/cacheflush.h>
+#include <asm/cachetype.h>
+#include <asm/early_ioremap.h>
+#include <asm/fixmap.h>
+#include <asm/highmem.h>
+#include <asm/mach/map.h>
+#include <asm/mmu_context.h>
+#include <asm/pgtable.h>
+
+#ifdef CONFIG_EFI
+void efi_init(void);
+
+int efi_create_mapping(struct mm_struct *mm, efi_memory_desc_t *md);
+
+#define efi_call_virt(f, ...)						\
+({									\
+	efi_##f##_t *__f;						\
+	efi_status_t __s;						\
+									\
+	efi_virtmap_load();						\
+	__f = efi.systab->runtime->f;					\
+	__s = __f(__VA_ARGS__);						\
+	efi_virtmap_unload();						\
+	__s;								\
+})
+
+#define __efi_call_virt(f, ...)						\
+({									\
+	efi_##f##_t *__f;						\
+									\
+	efi_virtmap_load();						\
+	__f = efi.systab->runtime->f;					\
+	__f(__VA_ARGS__);						\
+	efi_virtmap_unload();						\
+})
+
+static inline void efi_set_pgd(struct mm_struct *mm)
+{
+	check_and_switch_context(mm, NULL);
+}
+
+void efi_virtmap_load(void);
+void efi_virtmap_unload(void);
+
+#else
+#define efi_init()
+#endif /* CONFIG_EFI */
+
+#endif /* _ASM_ARM_EFI_H */
diff --git a/arch/arm/include/asm/mmu_context.h b/arch/arm/include/asm/mmu_context.h
index 9b32f76bb0dd..432ce8176498 100644
--- a/arch/arm/include/asm/mmu_context.h
+++ b/arch/arm/include/asm/mmu_context.h
@@ -26,7 +26,7 @@ void __check_vmalloc_seq(struct mm_struct *mm);
 #ifdef CONFIG_CPU_HAS_ASID
 
 void check_and_switch_context(struct mm_struct *mm, struct task_struct *tsk);
-#define init_new_context(tsk,mm)	({ atomic64_set(&mm->context.id, 0); 0; })
+#define init_new_context(tsk,mm)	({ atomic64_set(&(mm)->context.id, 0); 0; })
 
 #ifdef CONFIG_ARM_ERRATA_798181
 void a15_erratum_get_cpumask(int this_cpu, struct mm_struct *mm,
diff --git a/arch/arm/kernel/Makefile b/arch/arm/kernel/Makefile
index af9e59bf3831..c90f4a70d646 100644
--- a/arch/arm/kernel/Makefile
+++ b/arch/arm/kernel/Makefile
@@ -77,6 +77,7 @@ CFLAGS_pj4-cp0.o		:= -marm
 AFLAGS_iwmmxt.o			:= -Wa,-mcpu=iwmmxt
 obj-$(CONFIG_ARM_CPU_TOPOLOGY)  += topology.o
 obj-$(CONFIG_VDSO)		+= vdso.o
+obj-$(CONFIG_EFI)		+= efi.o
 
 ifneq ($(CONFIG_ARCH_EBSA110),y)
   obj-y		+= io.o
diff --git a/arch/arm/kernel/efi.c b/arch/arm/kernel/efi.c
new file mode 100644
index 000000000000..ff8a9d8acfac
--- /dev/null
+++ b/arch/arm/kernel/efi.c
@@ -0,0 +1,38 @@
+/*
+ * Copyright (C) 2015 Linaro Ltd <ard.biesheuvel@linaro.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/efi.h>
+#include <asm/efi.h>
+#include <asm/mach/map.h>
+#include <asm/mmu_context.h>
+
+int __init efi_create_mapping(struct mm_struct *mm, efi_memory_desc_t *md)
+{
+	struct map_desc desc = {
+		.virtual	= md->virt_addr,
+		.pfn		= __phys_to_pfn(md->phys_addr),
+		.length		= md->num_pages * EFI_PAGE_SIZE,
+	};
+
+	/*
+	 * Order is important here: memory regions may have all of the
+	 * bits below set (and usually do), so we check them in order of
+	 * preference.
+	 */
+	if (md->attribute & EFI_MEMORY_WB)
+		desc.type = MT_MEMORY_RWX;
+	else if (md->attribute & EFI_MEMORY_WT)
+		desc.type = MT_MEMORY_RWX_NONCACHED;
+	else if (md->attribute & EFI_MEMORY_WC)
+		desc.type = MT_DEVICE_WC;
+	else
+		desc.type = MT_DEVICE;
+
+	create_mapping_late(mm, &desc, true);
+	return 0;
+}
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 5df2bca57c42..b341b1c3b2fa 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -7,6 +7,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+#include <linux/efi.h>
 #include <linux/export.h>
 #include <linux/kernel.h>
 #include <linux/stddef.h>
@@ -37,6 +38,7 @@
 #include <asm/cp15.h>
 #include <asm/cpu.h>
 #include <asm/cputype.h>
+#include <asm/efi.h>
 #include <asm/elf.h>
 #include <asm/early_ioremap.h>
 #include <asm/fixmap.h>
@@ -966,6 +968,7 @@ void __init setup_arch(char **cmdline_p)
 	early_paging_init(mdesc);
 #endif
 	setup_dma_zone(mdesc);
+	efi_init();
 	sanity_check_meminfo();
 	arm_memblock_init(mdesc);
 
diff --git a/drivers/firmware/efi/Makefile b/drivers/firmware/efi/Makefile
index f292917b00e7..62e654f255f4 100644
--- a/drivers/firmware/efi/Makefile
+++ b/drivers/firmware/efi/Makefile
@@ -20,4 +20,5 @@ obj-$(CONFIG_EFI_STUB)			+= libstub/
 obj-$(CONFIG_EFI_FAKE_MEMMAP)		+= fake_mem.o
 
 arm-obj-$(CONFIG_EFI)			:= arm-init.o arm-runtime.o
+obj-$(CONFIG_ARM)			+= $(arm-obj-y)
 obj-$(CONFIG_ARM64)			+= $(arm-obj-y)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
