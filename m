Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B04006B025C
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:18:29 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so182216166pac.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:29 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id fw7si13639182pbd.82.2015.09.28.12.18.21
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:21 -0700 (PDT)
Subject: [PATCH 08/25] x86, pkeys: store protection in high VMA flags
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:20 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191820.FB09CAD8@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


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
---

 b/arch/x86/Kconfig   |    1 +
 b/include/linux/mm.h |    7 +++++++
 b/mm/Kconfig         |    3 +++
 3 files changed, 11 insertions(+)

diff -puN arch/x86/Kconfig~pkeys-07-eat-high-vma-flags arch/x86/Kconfig
--- a/arch/x86/Kconfig~pkeys-07-eat-high-vma-flags	2015-09-28 11:39:44.493116671 -0700
+++ b/arch/x86/Kconfig	2015-09-28 11:39:44.500116990 -0700
@@ -152,6 +152,7 @@ config X86
 	select VIRT_TO_BUS
 	select X86_DEV_DMA_OPS			if X86_64
 	select X86_FEATURE_NAMES		if PROC_FS
+	select ARCH_USES_HIGH_VMA_FLAGS		if X86_INTEL_MEMORY_PROTECTION_KEYS
 
 config INSTRUCTION_DECODER
 	def_bool y
diff -puN include/linux/mm.h~pkeys-07-eat-high-vma-flags include/linux/mm.h
--- a/include/linux/mm.h~pkeys-07-eat-high-vma-flags	2015-09-28 11:39:44.495116762 -0700
+++ b/include/linux/mm.h	2015-09-28 11:39:44.501117035 -0700
@@ -157,6 +157,13 @@ extern unsigned int kobjsize(const void
 #define VM_NOHUGEPAGE	0x40000000	/* MADV_NOHUGEPAGE marked this vma */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
 
+#ifdef CONFIG_ARCH_USES_HIGH_VMA_FLAGS
+#define VM_HIGH_ARCH_0  0x100000000UL	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_1  0x200000000UL	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_2  0x400000000UL	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_3  0x800000000UL	/* bit only usable on 64-bit architectures */
+#endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
+
 #if defined(CONFIG_X86)
 # define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
 #elif defined(CONFIG_PPC)
diff -puN mm/Kconfig~pkeys-07-eat-high-vma-flags mm/Kconfig
--- a/mm/Kconfig~pkeys-07-eat-high-vma-flags	2015-09-28 11:39:44.497116853 -0700
+++ b/mm/Kconfig	2015-09-28 11:39:44.502117081 -0700
@@ -680,3 +680,6 @@ config ZONE_DEVICE
 
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
