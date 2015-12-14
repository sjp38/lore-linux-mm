Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B7C0B6B025D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:06:01 -0500 (EST)
Received: by pfbu66 with SMTP id u66so65611907pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:06:01 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hp4si10205537pad.113.2015.12.14.11.06.00
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:06:00 -0800 (PST)
Subject: [PATCH 09/32] x86, pkeys: store protection in high VMA flags
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:06:00 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190600.765EFEC9@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

vma->vm_flags is an 'unsigned long', so has space for 32 flags
on 32-bit architectures.  The high 32 bits are unused on 64-bit
platforms.  We've steered away from using the unused high VMA
bits for things because we would have difficulty supporting it
on 32-bit.

Protection Keys are not available in 32-bit mode, so there is
no concern about supporting this feature in 32-bit mode or on
32-bit CPUs.

This patch carves out 4 bits from the high half of
vma->vm_flags and allows architectures to set config option
to make them available.

Sparse complains about these constants unless we explicitly
call them "UL".

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/Kconfig   |    1 +
 b/include/linux/mm.h |   11 +++++++++++
 b/mm/Kconfig         |    3 +++
 3 files changed, 15 insertions(+)

diff -puN arch/x86/Kconfig~pkeys-06-eat-high-vma-flags arch/x86/Kconfig
--- a/arch/x86/Kconfig~pkeys-06-eat-high-vma-flags	2015-12-14 10:42:42.651796240 -0800
+++ b/arch/x86/Kconfig	2015-12-14 10:42:42.658796554 -0800
@@ -152,6 +152,7 @@ config X86
 	select VIRT_TO_BUS
 	select X86_DEV_DMA_OPS			if X86_64
 	select X86_FEATURE_NAMES		if PROC_FS
+	select ARCH_USES_HIGH_VMA_FLAGS		if X86_INTEL_MEMORY_PROTECTION_KEYS
 
 config INSTRUCTION_DECODER
 	def_bool y
diff -puN include/linux/mm.h~pkeys-06-eat-high-vma-flags include/linux/mm.h
--- a/include/linux/mm.h~pkeys-06-eat-high-vma-flags	2015-12-14 10:42:42.653796329 -0800
+++ b/include/linux/mm.h	2015-12-14 10:42:42.659796598 -0800
@@ -158,6 +158,17 @@ extern unsigned int kobjsize(const void
 #define VM_NOHUGEPAGE	0x40000000	/* MADV_NOHUGEPAGE marked this vma */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
 
+#ifdef CONFIG_ARCH_USES_HIGH_VMA_FLAGS
+#define VM_HIGH_ARCH_BIT_0	32	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_1	33	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
+#define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
+#define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
+#define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
+#endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
+
 #if defined(CONFIG_X86)
 # define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
 #elif defined(CONFIG_PPC)
diff -puN mm/Kconfig~pkeys-06-eat-high-vma-flags mm/Kconfig
--- a/mm/Kconfig~pkeys-06-eat-high-vma-flags	2015-12-14 10:42:42.654796374 -0800
+++ b/mm/Kconfig	2015-12-14 10:42:42.659796598 -0800
@@ -668,3 +668,6 @@ config ZONE_DEVICE
 
 config FRAME_VECTOR
 	bool
+
+config ARCH_USES_HIGH_VMA_FLAGS
+	bool
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
