Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41DF98E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 06:16:40 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id z16so5838921wrt.5
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 03:16:40 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id 68si10912801wra.172.2019.01.12.03.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Jan 2019 03:16:38 -0800 (PST)
Message-Id: <0c8b246b2b3b60dc0d642a4e33f635e1699dc739.1547289808.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1547289808.git.christophe.leroy@c-s.fr>
References: <cover.1547289808.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 2/3] powerpc/32: Move early_init() in a separate file
Date: Sat, 12 Jan 2019 11:16:37 +0000 (UTC)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org

In preparation of KASAN, move early_init() into a separate
file in order to allow deactivation of KASAN for that function.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/Makefile   |  2 +-
 arch/powerpc/kernel/early_32.c | 35 +++++++++++++++++++++++++++++++++++
 arch/powerpc/kernel/setup_32.c | 26 --------------------------
 3 files changed, 36 insertions(+), 27 deletions(-)
 create mode 100644 arch/powerpc/kernel/early_32.c

diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index cb7f0bb9ee71..879b36602748 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -93,7 +93,7 @@ extra-y				+= vmlinux.lds
 
 obj-$(CONFIG_RELOCATABLE)	+= reloc_$(BITS).o
 
-obj-$(CONFIG_PPC32)		+= entry_32.o setup_32.o
+obj-$(CONFIG_PPC32)		+= entry_32.o setup_32.o early_32.o
 obj-$(CONFIG_PPC64)		+= dma-iommu.o iommu.o
 obj-$(CONFIG_KGDB)		+= kgdb.o
 obj-$(CONFIG_BOOTX_TEXT)	+= btext.o
diff --git a/arch/powerpc/kernel/early_32.c b/arch/powerpc/kernel/early_32.c
new file mode 100644
index 000000000000..b3e40d6d651c
--- /dev/null
+++ b/arch/powerpc/kernel/early_32.c
@@ -0,0 +1,35 @@
+// SPDX-License-Identifier: GPL-2.0
+
+/*
+ * Early init before relocation
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <asm/setup.h>
+#include <asm/sections.h>
+
+/*
+ * We're called here very early in the boot.
+ *
+ * Note that the kernel may be running at an address which is different
+ * from the address that it was linked at, so we must use RELOC/PTRRELOC
+ * to access static data (including strings).  -- paulus
+ */
+notrace unsigned long __init early_init(unsigned long dt_ptr)
+{
+	unsigned long offset = reloc_offset();
+
+	/* First zero the BSS */
+	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
+
+	/*
+	 * Identify the CPU type and fix up code sections
+	 * that depend on which cpu we have.
+	 */
+	identify_cpu(offset, mfspr(SPRN_PVR));
+
+	apply_feature_fixups();
+
+	return KERNELBASE + offset;
+}
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 5e761eb16a6d..b46a9a33225b 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -63,32 +63,6 @@ EXPORT_SYMBOL(DMA_MODE_READ);
 EXPORT_SYMBOL(DMA_MODE_WRITE);
 
 /*
- * We're called here very early in the boot.
- *
- * Note that the kernel may be running at an address which is different
- * from the address that it was linked at, so we must use RELOC/PTRRELOC
- * to access static data (including strings).  -- paulus
- */
-notrace unsigned long __init early_init(unsigned long dt_ptr)
-{
-	unsigned long offset = reloc_offset();
-
-	/* First zero the BSS */
-	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
-
-	/*
-	 * Identify the CPU type and fix up code sections
-	 * that depend on which cpu we have.
-	 */
-	identify_cpu(offset, mfspr(SPRN_PVR));
-
-	apply_feature_fixups();
-
-	return KERNELBASE + offset;
-}
-
-
-/*
  * This is run before start_kernel(), the kernel has been relocated
  * and we are running with enough of the MMU enabled to have our
  * proper kernel virtual addresses
-- 
2.13.3
