Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 48ED7828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:17:48 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so44985689pab.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:48 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ym10si3547456pab.146.2016.01.29.10.17.25
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:17:25 -0800 (PST)
Subject: [PATCH 29/31] x86, pkeys: allow kernel to modify user pkey rights register
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:17:24 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181724.5DAA2942@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The Protection Key Rights for User memory (PKRU) is a 32-bit
user-accessible register.  It contains two bits for each
protection key: one to write-disable (WD) access to memory
covered by the key and another to access-disable (AD).

Userspace can read/write the register with the RDPKRU and WRPKRU
instructions.  But, the register is saved and restored with the
XSAVE family of instructions, which means we have to treat it
like a floating point register.

The kernel needs to write to the register if it wants to
implement execute-only memory or if it implements a system call
to change PKRU.

To do this, we need to create a 'pkru_state' buffer, read the old
contents in to it, modify it, and then tell the FPU code that
there is modified data in there so it can (possibly) move the
buffer back in to the registers.

This uses the fpu__xfeature_set_state() function that we defined
in the previous patch.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/include/asm/pgtable.h |    5 +-
 b/arch/x86/include/asm/pkeys.h   |    3 +
 b/arch/x86/kernel/fpu/xstate.c   |   74 +++++++++++++++++++++++++++++++++++++++
 b/include/linux/pkeys.h          |    5 ++
 4 files changed, 85 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/pgtable.h~pkeys-77-arch_set_user_pkey_access arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~pkeys-77-arch_set_user_pkey_access	2016-01-28 15:52:29.647829708 -0800
+++ b/arch/x86/include/asm/pgtable.h	2016-01-28 15:52:29.655830074 -0800
@@ -921,16 +921,17 @@ static inline pte_t pte_swp_clear_soft_d
 
 #define PKRU_AD_BIT 0x1
 #define PKRU_WD_BIT 0x2
+#define PKRU_BITS_PER_PKEY 2
 
 static inline bool __pkru_allows_read(u32 pkru, u16 pkey)
 {
-	int pkru_pkey_bits = pkey * 2;
+	int pkru_pkey_bits = pkey * PKRU_BITS_PER_PKEY;
 	return !(pkru & (PKRU_AD_BIT << pkru_pkey_bits));
 }
 
 static inline bool __pkru_allows_write(u32 pkru, u16 pkey)
 {
-	int pkru_pkey_bits = pkey * 2;
+	int pkru_pkey_bits = pkey * PKRU_BITS_PER_PKEY;
 	/*
 	 * Access-disable disables writes too so we need to check
 	 * both bits here.
diff -puN arch/x86/include/asm/pkeys.h~pkeys-77-arch_set_user_pkey_access arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkeys-77-arch_set_user_pkey_access	2016-01-28 15:52:29.649829799 -0800
+++ b/arch/x86/include/asm/pkeys.h	2016-01-28 15:52:29.656830120 -0800
@@ -3,4 +3,7 @@
 
 #define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? 16 : 1)
 
+extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val);
+
 #endif /*_ASM_X86_PKEYS_H */
diff -puN arch/x86/kernel/fpu/xstate.c~pkeys-77-arch_set_user_pkey_access arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-77-arch_set_user_pkey_access	2016-01-28 15:52:29.650829845 -0800
+++ b/arch/x86/kernel/fpu/xstate.c	2016-01-28 15:52:29.656830120 -0800
@@ -5,6 +5,7 @@
  */
 #include <linux/compat.h>
 #include <linux/cpu.h>
+#include <linux/pkeys.h>
 
 #include <asm/fpu/api.h>
 #include <asm/fpu/internal.h>
@@ -855,3 +856,76 @@ out:
 	 */
 	fpu__current_fpstate_write_end();
 }
+
+#define NR_VALID_PKRU_BITS (CONFIG_NR_PROTECTION_KEYS * 2)
+#define PKRU_VALID_MASK (NR_VALID_PKRU_BITS - 1)
+
+/*
+ * This will go out and modify the XSAVE buffer so that PKRU is
+ * set to a particular state for access to 'pkey'.
+ *
+ * PKRU state does affect kernel access to user memory.  We do
+ * not modfiy PKRU *itself* here, only the XSAVE state that will
+ * be restored in to PKRU when we return back to userspace.
+ */
+int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val)
+{
+	struct xregs_state *xsave = &tsk->thread.fpu.state.xsave;
+	struct pkru_state *old_pkru_state;
+	struct pkru_state new_pkru_state;
+	int pkey_shift = (pkey * PKRU_BITS_PER_PKEY);
+	u32 new_pkru_bits = 0;
+
+	if (!validate_pkey(pkey))
+		return -EINVAL;
+	/*
+	 * This check implies XSAVE support.  OSPKE only gets
+	 * set if we enable XSAVE and we enable PKU in XCR0.
+	 */
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return -EINVAL;
+
+	/* Set the bits we need in PKRU  */
+	if (init_val & PKEY_DISABLE_ACCESS)
+		new_pkru_bits |= PKRU_AD_BIT;
+	if (init_val & PKEY_DISABLE_WRITE)
+		new_pkru_bits |= PKRU_WD_BIT;
+
+	/* Shift the bits in to the correct place in PKRU for pkey. */
+	new_pkru_bits <<= pkey_shift;
+
+	/* Locate old copy of the state in the xsave buffer */
+	old_pkru_state = get_xsave_addr(xsave, XFEATURE_MASK_PKRU);
+
+	/*
+	 * When state is not in the buffer, it is in the init
+	 * state, set it manually.  Otherwise, copy out the old
+	 * state.
+	 */
+	if (!old_pkru_state)
+		new_pkru_state.pkru = 0;
+	else
+		new_pkru_state.pkru = old_pkru_state->pkru;
+
+	/* mask off any old bits in place */
+	new_pkru_state.pkru &= ~((PKRU_AD_BIT|PKRU_WD_BIT) << pkey_shift);
+	/* Set the newly-requested bits */
+	new_pkru_state.pkru |= new_pkru_bits;
+
+	/*
+	 * We could theoretically live without zeroing pkru.pad.
+	 * The current XSAVE feature state definition says that
+	 * only bytes 0->3 are used.  But we do not want to
+	 * chance leaking kernel stack out to userspace in case a
+	 * memcpy() of the whole xsave buffer was done.
+	 *
+	 * They're in the same cacheline anyway.
+	 */
+	new_pkru_state.pad = 0;
+
+	fpu__xfeature_set_state(XFEATURE_MASK_PKRU, &new_pkru_state,
+			sizeof(new_pkru_state));
+
+	return 0;
+}
diff -puN include/linux/pkeys.h~pkeys-77-arch_set_user_pkey_access include/linux/pkeys.h
--- a/include/linux/pkeys.h~pkeys-77-arch_set_user_pkey_access	2016-01-28 15:52:29.652829937 -0800
+++ b/include/linux/pkeys.h	2016-01-28 15:52:29.656830120 -0800
@@ -4,6 +4,11 @@
 #include <linux/mm_types.h>
 #include <asm/mmu_context.h>
 
+#define PKEY_DISABLE_ACCESS	0x1
+#define PKEY_DISABLE_WRITE	0x2
+#define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
+				 PKEY_DISABLE_WRITE)
+
 #ifdef CONFIG_ARCH_HAS_PKEYS
 #include <asm/pkeys.h>
 #else /* ! CONFIG_ARCH_HAS_PKEYS */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
