Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6D50280255
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 13:11:57 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fl2so27385991pad.7
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:11:57 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0134.outbound.protection.outlook.com. [104.47.1.134])
        by mx.google.com with ESMTPS id b190si8872791pfa.34.2016.10.27.10.11.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 10:11:56 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 7/8] mm: kill arch_mremap
Date: Thu, 27 Oct 2016 20:09:47 +0300
Message-ID: <20161027170948.8279-8-dsafonov@virtuozzo.com>
In-Reply-To: <20161027170948.8279-1-dsafonov@virtuozzo.com>
References: <20161027170948.8279-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

This reverts commit 4abad2ca4a4d ("mm: new arch_remap() hook") and
commit 2ae416b142b6 ("mm: new mm hook framework").
It also keeps the same functionality of mremapping vDSO blob with
introducing vm_special_mapping mremap op for powerpc.
The same way it's being handled on x86.

Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/alpha/include/asm/Kbuild            |  1 -
 arch/arc/include/asm/Kbuild              |  1 -
 arch/arm/include/asm/Kbuild              |  1 -
 arch/arm64/include/asm/Kbuild            |  1 -
 arch/avr32/include/asm/Kbuild            |  1 -
 arch/blackfin/include/asm/Kbuild         |  1 -
 arch/c6x/include/asm/Kbuild              |  1 -
 arch/cris/include/asm/Kbuild             |  1 -
 arch/frv/include/asm/Kbuild              |  1 -
 arch/h8300/include/asm/Kbuild            |  1 -
 arch/hexagon/include/asm/Kbuild          |  1 -
 arch/ia64/include/asm/Kbuild             |  1 -
 arch/m32r/include/asm/Kbuild             |  1 -
 arch/m68k/include/asm/Kbuild             |  1 -
 arch/metag/include/asm/Kbuild            |  1 -
 arch/microblaze/include/asm/Kbuild       |  1 -
 arch/mips/include/asm/Kbuild             |  1 -
 arch/mn10300/include/asm/Kbuild          |  1 -
 arch/nios2/include/asm/Kbuild            |  1 -
 arch/openrisc/include/asm/Kbuild         |  1 -
 arch/parisc/include/asm/Kbuild           |  1 -
 arch/powerpc/include/asm/mm-arch-hooks.h | 28 ----------------------------
 arch/powerpc/kernel/vdso.c               | 25 +++++++++++++++++++++++++
 arch/powerpc/kernel/vdso_common.c        |  1 +
 arch/s390/include/asm/Kbuild             |  1 -
 arch/score/include/asm/Kbuild            |  1 -
 arch/sh/include/asm/Kbuild               |  1 -
 arch/sparc/include/asm/Kbuild            |  1 -
 arch/tile/include/asm/Kbuild             |  1 -
 arch/um/include/asm/Kbuild               |  1 -
 arch/unicore32/include/asm/Kbuild        |  1 -
 arch/x86/include/asm/Kbuild              |  1 -
 arch/xtensa/include/asm/Kbuild           |  1 -
 include/asm-generic/mm-arch-hooks.h      | 16 ----------------
 include/linux/mm-arch-hooks.h            | 25 -------------------------
 mm/mremap.c                              |  4 ----
 36 files changed, 26 insertions(+), 103 deletions(-)
 delete mode 100644 arch/powerpc/include/asm/mm-arch-hooks.h
 delete mode 100644 include/asm-generic/mm-arch-hooks.h
 delete mode 100644 include/linux/mm-arch-hooks.h

diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index bf8475ce85ee..0a5e0ec2842b 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -6,7 +6,6 @@ generic-y += exec.h
 generic-y += export.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index c332604606dd..e6059a808463 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -22,7 +22,6 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += msi.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index 0745538b26d3..44b717cb4a55 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -15,7 +15,6 @@ generic-y += irq_regs.h
 generic-y += kdebug.h
 generic-y += local.h
 generic-y += local64.h
-generic-y += mm-arch-hooks.h
 generic-y += msgbuf.h
 generic-y += msi.h
 generic-y += param.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index 44e1d7f10add..a42a1367aea4 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -20,7 +20,6 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += msi.h
diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index 241b9b9729d8..519810d0d5e1 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -12,7 +12,6 @@ generic-y += irq_work.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += param.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index 91d49c0a3118..c80181e4454f 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -21,7 +21,6 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += mutex.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index 64465e7e2245..1b9cbed76cdd 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -27,7 +27,6 @@ generic-y += kdebug.h
 generic-y += kmap_types.h
 generic-y += local.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += mmu.h
 generic-y += mmu_context.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 1778805f6380..8e98d039780c 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -24,7 +24,6 @@ generic-y += linkage.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += module.h
 generic-y += msgbuf.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 1fa084cf1a43..2c987dc05af4 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -4,7 +4,6 @@ generic-y += cputime.h
 generic-y += exec.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
diff --git a/arch/h8300/include/asm/Kbuild b/arch/h8300/include/asm/Kbuild
index 373cb23301e3..2a63a32366f0 100644
--- a/arch/h8300/include/asm/Kbuild
+++ b/arch/h8300/include/asm/Kbuild
@@ -33,7 +33,6 @@ generic-y += linkage.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += mmu.h
 generic-y += mmu_context.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index db8ddabc6bd2..0988816dded0 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -28,7 +28,6 @@ generic-y += kmap_types.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += pci.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 502a91d8dbbd..dc05773e1f11 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -4,7 +4,6 @@ generic-y += exec.h
 generic-y += irq_work.h
 generic-y += kvm_para.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += vtime.h
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index 860e440611c9..f09a5fdb3b77 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -5,7 +5,6 @@ generic-y += exec.h
 generic-y += irq_work.h
 generic-y += kvm_para.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += module.h
 generic-y += preempt.h
 generic-y += sections.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index eb85bd9c6180..1555bc189c7d 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -18,7 +18,6 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += mutex.h
 generic-y += percpu.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index 29acb89daaaa..611c0df2be39 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -25,7 +25,6 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += msgbuf.h
 generic-y += mutex.h
 generic-y += param.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index b0ae88c9fed9..cefeabae24cc 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -6,7 +6,6 @@ generic-y += device.h
 generic-y += exec.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += syscalls.h
 generic-y += trace_clock.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 9740066cc631..f0ce0ae0a358 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -8,7 +8,6 @@ generic-y += emergency-restart.h
 generic-y += irq_work.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mutex.h
 generic-y += parport.h
 generic-y += percpu.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index 1c8dd0f5cd5d..27cbc0267b9c 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -5,7 +5,6 @@ generic-y += cputime.h
 generic-y += exec.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
diff --git a/arch/nios2/include/asm/Kbuild b/arch/nios2/include/asm/Kbuild
index d63330e88379..e22478929719 100644
--- a/arch/nios2/include/asm/Kbuild
+++ b/arch/nios2/include/asm/Kbuild
@@ -30,7 +30,6 @@ generic-y += kmap_types.h
 generic-y += kvm_para.h
 generic-y += local.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += module.h
 generic-y += msgbuf.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index 2832f031fb11..2a2e39b8109a 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -36,7 +36,6 @@ generic-y += kmap_types.h
 generic-y += kvm_para.h
 generic-y += local.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += module.h
 generic-y += msgbuf.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index f9b3a81aefcd..12b341d04f88 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -15,7 +15,6 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mutex.h
 generic-y += param.h
 generic-y += percpu.h
diff --git a/arch/powerpc/include/asm/mm-arch-hooks.h b/arch/powerpc/include/asm/mm-arch-hooks.h
deleted file mode 100644
index f2a2da895897..000000000000
--- a/arch/powerpc/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,28 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_POWERPC_MM_ARCH_HOOKS_H
-#define _ASM_POWERPC_MM_ARCH_HOOKS_H
-
-static inline void arch_remap(struct mm_struct *mm,
-			      unsigned long old_start, unsigned long old_end,
-			      unsigned long new_start, unsigned long new_end)
-{
-	/*
-	 * mremap() doesn't allow moving multiple vmas so we can limit the
-	 * check to old_start == vdso_base.
-	 */
-	if (old_start == mm->context.vdso_base)
-		mm->context.vdso_base = new_start;
-}
-#define arch_remap arch_remap
-
-#endif /* _ASM_POWERPC_MM_ARCH_HOOKS_H */
diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 9ee3fd65c6e9..431bdf7ec68e 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -143,6 +143,31 @@ struct lib64_elfinfo
 	unsigned long	text;
 };
 
+static int vdso_mremap(const struct vm_special_mapping *sm,
+		struct vm_area_struct *new_vma)
+{
+	unsigned long new_size = new_vma->vm_end - new_vma->vm_start;
+	unsigned long vdso_pages;
+
+	if (is_32bit_task())
+		vdso_pages = vdso32_pages;
+#ifdef CONFIG_PPC64
+	else
+		vdso_pages = vdso64_pages;
+#endif
+
+	/* Do not allow partial remap, +1 is for vDSO data page */
+	if (new_size != (vdso_pages + 1) << PAGE_SHIFT)
+		return -EINVAL;
+
+	if (WARN_ON_ONCE(current->mm != new_vma->vm_mm))
+		return -EFAULT;
+
+	current->mm->context.vdso_base = new_vma->vm_start;
+
+	return 0;
+}
+
 static int map_vdso(struct vm_special_mapping *vsm, unsigned long vdso_pages,
 		unsigned long vdso_base)
 {
diff --git a/arch/powerpc/kernel/vdso_common.c b/arch/powerpc/kernel/vdso_common.c
index 047f6b8b230f..11fdf3e8acc7 100644
--- a/arch/powerpc/kernel/vdso_common.c
+++ b/arch/powerpc/kernel/vdso_common.c
@@ -225,6 +225,7 @@ static __init void init_vdso_pagelist(void)
 
 	vdso_mapping.pages = vdso_pagelist;
 	vdso_mapping.name = "[vdso]";
+	vdso_mapping.mremap = vdso_mremap;
 }
 
 #undef find_section
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 20f196b82a6e..c1ef8252cc20 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -4,7 +4,6 @@ generic-y += clkdev.h
 generic-y += export.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index a05218ff3fe4..ff19975beb33 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -7,7 +7,6 @@ generic-y += clkdev.h
 generic-y += cputime.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index 751c3373a92c..7d1fb2c7fcba 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -17,7 +17,6 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += param.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index cfc918067f80..0867d5ab7f87 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -13,7 +13,6 @@ generic-y += linkage.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += module.h
 generic-y += mutex.h
 generic-y += preempt.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index ba35c41c71ff..40d22b4a01f9 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -19,7 +19,6 @@ generic-y += irq_regs.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += msgbuf.h
 generic-y += mutex.h
 generic-y += param.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index 904f3ebf4220..33c1d3e0caad 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -16,7 +16,6 @@ generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mutex.h
 generic-y += param.h
 generic-y += pci.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 256c45b3ae34..932070cd754a 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -26,7 +26,6 @@ generic-y += kdebug.h
 generic-y += kmap_types.h
 generic-y += local.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += module.h
 generic-y += msgbuf.h
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index 2cfed174e3c9..51b3d95f05e9 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -15,4 +15,3 @@ generic-y += cputime.h
 generic-y += dma-contiguous.h
 generic-y += early_ioremap.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 28cf4c5d65ef..bdade9995e36 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -18,7 +18,6 @@ generic-y += linkage.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += mm-arch-hooks.h
 generic-y += percpu.h
 generic-y += preempt.h
 generic-y += resource.h
diff --git a/include/asm-generic/mm-arch-hooks.h b/include/asm-generic/mm-arch-hooks.h
deleted file mode 100644
index 5ff0e5193f85..000000000000
--- a/include/asm-generic/mm-arch-hooks.h
+++ /dev/null
@@ -1,16 +0,0 @@
-/*
- * Architecture specific mm hooks
- */
-
-#ifndef _ASM_GENERIC_MM_ARCH_HOOKS_H
-#define _ASM_GENERIC_MM_ARCH_HOOKS_H
-
-/*
- * This file should be included through arch/../include/asm/Kbuild for
- * the architecture which doesn't need specific mm hooks.
- *
- * In that case, the generic hooks defined in include/linux/mm-arch-hooks.h
- * are used.
- */
-
-#endif /* _ASM_GENERIC_MM_ARCH_HOOKS_H */
diff --git a/include/linux/mm-arch-hooks.h b/include/linux/mm-arch-hooks.h
deleted file mode 100644
index 4efc3f56e6df..000000000000
--- a/include/linux/mm-arch-hooks.h
+++ /dev/null
@@ -1,25 +0,0 @@
-/*
- * Generic mm no-op hooks.
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-#ifndef _LINUX_MM_ARCH_HOOKS_H
-#define _LINUX_MM_ARCH_HOOKS_H
-
-#include <asm/mm-arch-hooks.h>
-
-#ifndef arch_remap
-static inline void arch_remap(struct mm_struct *mm,
-			      unsigned long old_start, unsigned long old_end,
-			      unsigned long new_start, unsigned long new_end)
-{
-}
-#define arch_remap arch_remap
-#endif
-
-#endif /* _LINUX_MM_ARCH_HOOKS_H */
diff --git a/mm/mremap.c b/mm/mremap.c
index da22ad2a5678..5f1504c6cc77 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -21,7 +21,6 @@
 #include <linux/syscalls.h>
 #include <linux/mmu_notifier.h>
 #include <linux/uaccess.h>
-#include <linux/mm-arch-hooks.h>
 
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
@@ -292,9 +291,6 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		old_len = new_len;
 		old_addr = new_addr;
 		new_addr = err;
-	} else {
-		arch_remap(mm, old_addr, old_addr + old_len,
-			   new_addr, new_addr + new_len);
 	}
 
 	/* Conceal VM_ACCOUNT so old reservation is not undone */
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
