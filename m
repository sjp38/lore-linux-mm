Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id EE07B6B0012
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:02:04 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id o62so298075630oif.3
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:02:04 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x66si10256902oif.123.2016.01.06.16.01.42
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:42 -0800 (PST)
Subject: [PATCH 26/31] x86, pkeys: add arch_validate_pkey()
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:41 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000141.DC5BF73E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The syscall-level code is passed a protection key and need to
return an appropriate error code if the protection key is bogus.
We will be using this in subsequent patches.

Note that this also begins a series of arch-specific calls that
we need to expose in otherwise arch-independent code.  We create
a linux/pkeys.h header where we will put *all* the stubs for
these functions.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/Kconfig             |    1 +
 b/arch/x86/include/asm/pkeys.h |    6 ++++++
 b/include/linux/pkeys.h        |   25 +++++++++++++++++++++++++
 b/mm/Kconfig                   |    2 ++
 4 files changed, 34 insertions(+)

diff -puN /dev/null arch/x86/include/asm/pkeys.h
--- /dev/null	2015-12-10 15:28:13.322405854 -0800
+++ b/arch/x86/include/asm/pkeys.h	2016-01-06 15:50:14.531558199 -0800
@@ -0,0 +1,6 @@
+#ifndef _ASM_X86_PKEYS_H
+#define _ASM_X86_PKEYS_H
+
+#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? 16 : 1)
+
+#endif /*_ASM_X86_PKEYS_H */
diff -puN arch/x86/Kconfig~pkeys-71-arch_validate_pkey arch/x86/Kconfig
--- a/arch/x86/Kconfig~pkeys-71-arch_validate_pkey	2016-01-06 15:50:14.526557973 -0800
+++ b/arch/x86/Kconfig	2016-01-06 15:50:14.532558243 -0800
@@ -153,6 +153,7 @@ config X86
 	select X86_DEV_DMA_OPS			if X86_64
 	select X86_FEATURE_NAMES		if PROC_FS
 	select ARCH_USES_HIGH_VMA_FLAGS		if X86_INTEL_MEMORY_PROTECTION_KEYS
+	select ARCH_HAS_PKEYS			if X86_INTEL_MEMORY_PROTECTION_KEYS
 
 config INSTRUCTION_DECODER
 	def_bool y
diff -puN /dev/null include/linux/pkeys.h
--- /dev/null	2015-12-10 15:28:13.322405854 -0800
+++ b/include/linux/pkeys.h	2016-01-06 15:50:14.532558243 -0800
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
--- a/mm/Kconfig~pkeys-71-arch_validate_pkey	2016-01-06 15:50:14.528558063 -0800
+++ b/mm/Kconfig	2016-01-06 15:50:14.532558243 -0800
@@ -671,3 +671,5 @@ config FRAME_VECTOR
 
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
