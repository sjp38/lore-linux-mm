Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id BC8A48308C
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 16:03:01 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id yy13so52111987pab.3
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:03:01 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id z3si22178503par.37.2016.02.12.13.02.46
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 13:02:46 -0800 (PST)
Subject: [PATCH 28/33] x86, pkeys: add arch_validate_pkey()
From: Dave Hansen <dave@sr71.net>
Date: Fri, 12 Feb 2016 13:02:32 -0800
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
In-Reply-To: <20160212210152.9CAD15B0@viggo.jf.intel.com>
Message-Id: <20160212210232.774EEAAB@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The syscall-level code is passed a protection key and need to
return an appropriate error code if the protection key is bogus.
We will be using this in subsequent patches.

Note that this also begins a series of arch-specific calls that
we need to expose in otherwise arch-independent code.  We create
a linux/pkeys.h header where we will put *all* the stubs for
these functions.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/Kconfig             |    1 +
 b/arch/x86/include/asm/pkeys.h |    6 ++++++
 b/include/linux/pkeys.h        |   25 +++++++++++++++++++++++++
 b/mm/Kconfig                   |    2 ++
 4 files changed, 34 insertions(+)

diff -puN /dev/null arch/x86/include/asm/pkeys.h
--- /dev/null	2015-12-10 15:28:13.322405854 -0800
+++ b/arch/x86/include/asm/pkeys.h	2016-02-12 10:44:26.560718780 -0800
@@ -0,0 +1,6 @@
+#ifndef _ASM_X86_PKEYS_H
+#define _ASM_X86_PKEYS_H
+
+#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? 16 : 1)
+
+#endif /*_ASM_X86_PKEYS_H */
diff -puN arch/x86/Kconfig~pkeys-71-arch_validate_pkey arch/x86/Kconfig
--- a/arch/x86/Kconfig~pkeys-71-arch_validate_pkey	2016-02-12 10:44:26.555718551 -0800
+++ b/arch/x86/Kconfig	2016-02-12 10:44:26.561718825 -0800
@@ -156,6 +156,7 @@ config X86
 	select X86_DEV_DMA_OPS			if X86_64
 	select X86_FEATURE_NAMES		if PROC_FS
 	select ARCH_USES_HIGH_VMA_FLAGS		if X86_INTEL_MEMORY_PROTECTION_KEYS
+	select ARCH_HAS_PKEYS			if X86_INTEL_MEMORY_PROTECTION_KEYS
 
 config INSTRUCTION_DECODER
 	def_bool y
diff -puN /dev/null include/linux/pkeys.h
--- /dev/null	2015-12-10 15:28:13.322405854 -0800
+++ b/include/linux/pkeys.h	2016-02-12 10:44:26.561718825 -0800
@@ -0,0 +1,25 @@
+#ifndef _LINUX_PKEYS_H
+#define _LINUX_PKEYS_H
+
+#include <linux/mm_types.h>
+#include <asm/mmu_context.h>
+
+#ifdef CONFIG_ARCH_HAS_PKEYS
+#include <asm/pkeys.h>
+#else /* ! CONFIG_ARCH_HAS_PKEYS */
+#define arch_max_pkey() (1)
+#endif /* ! CONFIG_ARCH_HAS_PKEYS */
+
+/*
+ * This is called from mprotect_pkey().
+ *
+ * Returns true if the protection keys is valid.
+ */
+static inline bool validate_pkey(int pkey)
+{
+	if (pkey < 0)
+		return false;
+	return (pkey < arch_max_pkey());
+}
+
+#endif /* _LINUX_PKEYS_H */
diff -puN mm/Kconfig~pkeys-71-arch_validate_pkey mm/Kconfig
--- a/mm/Kconfig~pkeys-71-arch_validate_pkey	2016-02-12 10:44:26.557718643 -0800
+++ b/mm/Kconfig	2016-02-12 10:44:26.562718871 -0800
@@ -672,3 +672,5 @@ config FRAME_VECTOR
 
 config ARCH_USES_HIGH_VMA_FLAGS
 	bool
+config ARCH_HAS_PKEYS
+	bool
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
