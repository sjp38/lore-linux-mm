Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91968828EA
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 19:18:40 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so620029496pac.3
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 16:18:40 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id o75si39267318pfj.22.2016.08.08.16.18.32
        for <linux-mm@kvack.org>;
        Mon, 08 Aug 2016 16:18:32 -0700 (PDT)
Subject: [PATCH 08/10] x86, pkeys: default to a restrictive init PKRU
From: Dave Hansen <dave@sr71.net>
Date: Mon, 08 Aug 2016 16:18:32 -0700
References: <20160808231820.F7A9C4D8@viggo.jf.intel.com>
In-Reply-To: <20160808231820.F7A9C4D8@viggo.jf.intel.com>
Message-Id: <20160808231832.D5CF5D2B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, luto@kernel.org, mgorman@techsingularity.net, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, arnd@arndb.de


From: Dave Hansen <dave.hansen@linux.intel.com>

PKRU is the register that lets you disallow writes or all access
to a given protection key.

The XSAVE hardware defines an "init state" of 0 for PKRU: its
most permissive state, allowing access/writes to everything.
Since we start off all new processes with the init state, we
start all processes off with the most permissive possible PKRU.

This is unfortunate.  If a thread is clone()'d [1] before a
program has time to set PKRU to a restrictive value, that thread
will be able to write to all data, no matter what pkey is set on
it.  This weakens any integrity guarantees that we want pkeys to
provide.

To fix this, we define a very restrictive PKRU to override the
XSAVE-provided value when we create a new FPU context[2].  We
choose a value that only allows access to pkey 0, which is as
restrictive as we can practically make it.

This does not cause any practical problems with applications
using protection keys because we require them to specify initial
permissions for each key when it is allocated, which override the
restrictive default.

In the end, this ensures that threads which do not know how to
manage their own pkey rights can not do damage to data which is
pkey-protected.

1. I would have thought this was a pretty contrived scenario,
   except that I heard a bug report from an MPX user who was
   creating threads in some very early code before main().  It
   may be crazy, but folks evidently _do_ it.
2. New FPU contexts are created at exeve()-time, and in a few
   obscure places when we have to recover from invalid FPU state,
   such as at sigreturn time.  New processes() via fork() and new
   threads via clone() inherit the parent's PKRU values.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: mgorman@techsingularity.net
---

 b/Documentation/kernel-parameters.txt |    5 ++++
 b/arch/x86/include/asm/pkeys.h        |    1 
 b/arch/x86/kernel/fpu/core.c          |    4 +++
 b/arch/x86/mm/pkeys.c                 |   38 ++++++++++++++++++++++++++++++++++
 b/include/linux/pkeys.h               |    4 +++
 5 files changed, 52 insertions(+)

diff -puN arch/x86/include/asm/pkeys.h~pkeys-140-restrictive-init-pkru arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkeys-140-restrictive-init-pkru	2016-08-08 16:15:12.928138130 -0700
+++ b/arch/x86/include/asm/pkeys.h	2016-08-08 16:15:12.938138585 -0700
@@ -100,5 +100,6 @@ extern int arch_set_user_pkey_access(str
 		unsigned long init_val);
 extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
+extern void copy_init_pkru_to_fpregs(void);
 
 #endif /*_ASM_X86_PKEYS_H */
diff -puN arch/x86/kernel/fpu/core.c~pkeys-140-restrictive-init-pkru arch/x86/kernel/fpu/core.c
--- a/arch/x86/kernel/fpu/core.c~pkeys-140-restrictive-init-pkru	2016-08-08 16:15:12.929138175 -0700
+++ b/arch/x86/kernel/fpu/core.c	2016-08-08 16:15:12.939138630 -0700
@@ -12,6 +12,7 @@
 #include <asm/traps.h>
 
 #include <linux/hardirq.h>
+#include <linux/pkeys.h>
 
 #define CREATE_TRACE_POINTS
 #include <asm/trace/fpu.h>
@@ -505,6 +506,9 @@ static inline void copy_init_fpstate_to_
 		copy_kernel_to_fxregs(&init_fpstate.fxsave);
 	else
 		copy_kernel_to_fregs(&init_fpstate.fsave);
+
+	if (boot_cpu_has(X86_FEATURE_OSPKE))
+		copy_init_pkru_to_fpregs();
 }
 
 /*
diff -puN arch/x86/mm/pkeys.c~pkeys-140-restrictive-init-pkru arch/x86/mm/pkeys.c
--- a/arch/x86/mm/pkeys.c~pkeys-140-restrictive-init-pkru	2016-08-08 16:15:12.932138312 -0700
+++ b/arch/x86/mm/pkeys.c	2016-08-08 16:15:12.940138675 -0700
@@ -121,3 +121,41 @@ int __arch_override_mprotect_pkey(struct
 	 */
 	return vma_pkey(vma);
 }
+
+#define PKRU_AD_KEY(pkey)	(PKRU_AD_BIT << ((pkey) * PKRU_BITS_PER_PKEY))
+
+/*
+ * Make the default PKRU value (at execve() time) as restrictive
+ * as possible.  This ensures that any threads clone()'d early
+ * in the process's lifetime will not accidentally get access
+ * to data which is pkey-protected later on.
+ */
+u32 init_pkru_value = PKRU_AD_KEY( 1) | PKRU_AD_KEY( 2) | PKRU_AD_KEY( 3) |
+		      PKRU_AD_KEY( 4) | PKRU_AD_KEY( 5) | PKRU_AD_KEY( 6) |
+		      PKRU_AD_KEY( 7) | PKRU_AD_KEY( 8) | PKRU_AD_KEY( 9) |
+		      PKRU_AD_KEY(10) | PKRU_AD_KEY(11) | PKRU_AD_KEY(12) |
+		      PKRU_AD_KEY(13) | PKRU_AD_KEY(14) | PKRU_AD_KEY(15);
+
+/*
+ * Called from the FPU code when creating a fresh set of FPU
+ * registers.  This is called from a very specific context where
+ * we know the FPU regstiers are safe for use and we can use PKRU
+ * directly.  The fact that PKRU is only available when we are
+ * using eagerfpu mode makes this possible.
+ */
+void copy_init_pkru_to_fpregs(void)
+{
+	u32 init_pkru_value_snapshot = READ_ONCE(init_pkru_value);
+	/*
+	 * Any write to PKRU takes it out of the XSAVE 'init
+	 * state' which increases context switch cost.  Avoid
+	 * writing 0 when PKRU was already 0.
+	 */
+	if (!init_pkru_value_snapshot && !read_pkru())
+		return;
+	/*
+	 * Override the PKRU state that came from 'init_fpstate'
+	 * with the baseline from the process.
+	 */
+	write_pkru(init_pkru_value_snapshot);
+}
diff -puN Documentation/kernel-parameters.txt~pkeys-140-restrictive-init-pkru Documentation/kernel-parameters.txt
--- a/Documentation/kernel-parameters.txt~pkeys-140-restrictive-init-pkru	2016-08-08 16:15:12.934138403 -0700
+++ b/Documentation/kernel-parameters.txt	2016-08-08 16:15:12.941138721 -0700
@@ -1643,6 +1643,11 @@ bytes respectively. Such letter suffixes
 
 	initrd=		[BOOT] Specify the location of the initial ramdisk
 
+	init_pkru=	[x86] Specify the default memory protection keys rights
+			register contents for all processes.  0x55555554 by
+			default (disallow access to all but pkey 0).  Can
+			override in debugfs after boot.
+
 	inport.irq=	[HW] Inport (ATI XL and Microsoft) busmouse driver
 			Format: <irq>
 
diff -puN include/linux/pkeys.h~pkeys-140-restrictive-init-pkru include/linux/pkeys.h
--- a/include/linux/pkeys.h~pkeys-140-restrictive-init-pkru	2016-08-08 16:15:12.935138448 -0700
+++ b/include/linux/pkeys.h	2016-08-08 16:15:12.941138721 -0700
@@ -35,6 +35,10 @@ static inline int arch_set_user_pkey_acc
 	return 0;
 }
 
+static inline void copy_init_pkru_to_fpregs(void)
+{
+}
+
 #endif /* ! CONFIG_ARCH_HAS_PKEYS */
 
 #endif /* _LINUX_PKEYS_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
