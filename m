Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5632082F71
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:15:20 -0500 (EST)
Received: by pfdd184 with SMTP id d184so17264672pfd.3
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:15:20 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 85si15470461pfl.178.2015.12.03.17.14.59
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:14:59 -0800 (PST)
Subject: [PATCH 25/34] x86, pkeys: add arch_validate_pkey()
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:14:59 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011459.CEC0E764@viggo.jf.intel.com>
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
 b/arch/x86/include/asm/pkeys.h |   10 ++++++++++
 b/include/linux/pkeys.h        |   22 ++++++++++++++++++++++
 b/mm/Kconfig                   |    2 ++
 4 files changed, 35 insertions(+)

diff -puN /dev/null arch/x86/include/asm/pkeys.h
--- /dev/null	2015-07-13 14:24:11.435656502 -0700
+++ b/arch/x86/include/asm/pkeys.h	2015-12-03 16:21:29.710856533 -0800
@@ -0,0 +1,10 @@
+#ifndef _ASM_X86_PKEYS_H
+#define _ASM_X86_PKEYS_H
+
+#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ?      \
+				CONFIG_NR_PROTECTION_KEYS : 1)
+#define arch_validate_pkey(pkey) (((pkey) >= 0) && ((pkey) < arch_max_pkey()))
+
+#endif /*_ASM_X86_PKEYS_H */
+
+
diff -puN arch/x86/Kconfig~pkeys-15-arch_validate_peky arch/x86/Kconfig
--- a/arch/x86/Kconfig~pkeys-15-arch_validate_peky	2015-12-03 16:21:29.705856306 -0800
+++ b/arch/x86/Kconfig	2015-12-03 16:21:29.711856578 -0800
@@ -153,6 +153,7 @@ config X86
 	select X86_DEV_DMA_OPS			if X86_64
 	select X86_FEATURE_NAMES		if PROC_FS
 	select ARCH_USES_HIGH_VMA_FLAGS		if X86_INTEL_MEMORY_PROTECTION_KEYS
+	select ARCH_HAS_PKEYS			if X86_INTEL_MEMORY_PROTECTION_KEYS
 
 config INSTRUCTION_DECODER
 	def_bool y
diff -puN /dev/null include/linux/pkeys.h
--- /dev/null	2015-07-13 14:24:11.435656502 -0700
+++ b/include/linux/pkeys.h	2015-12-03 16:21:29.711856578 -0800
@@ -0,0 +1,22 @@
+#ifndef _LINUX_PKEYS_H
+#define _LINUX_PKEYS_H
+
+#include <linux/mm_types.h>
+#include <asm/mmu_context.h>
+
+#ifdef CONFIG_ARCH_HAS_PKEYS
+#include <asm/pkeys.h>
+#else /* ! CONFIG_ARCH_HAS_PKEYS */
+
+/*
+ * This is called from mprotect_pkey().
+ *
+ * Returns true if the protection keys is valid.
+ */
+static inline bool arch_validate_pkey(int key)
+{
+	return true;
+}
+#endif /* ! CONFIG_ARCH_HAS_PKEYS */
+
+#endif /* _LINUX_PKEYS_H */
diff -puN mm/Kconfig~pkeys-15-arch_validate_peky mm/Kconfig
--- a/mm/Kconfig~pkeys-15-arch_validate_peky	2015-12-03 16:21:29.707856396 -0800
+++ b/mm/Kconfig	2015-12-03 16:21:29.711856578 -0800
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
