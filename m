Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB1482F71
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:15:39 -0500 (EST)
Received: by pacej9 with SMTP id ej9so78054544pac.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:15:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id we6si15424118pab.216.2015.12.03.17.15.38
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:15:38 -0800 (PST)
Subject: [PATCH 32/34] x86, pkeys: add pkey set/get syscalls
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:15:08 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011508.0275A2E4@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, linux-api@vger.kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This establishes two more system calls for protection key management:

	unsigned long pkey_get(int pkey);
	int pkey_set(int pkey, unsigned long access_rights);

The return value from pkey_get() and the 'access_rights' passed
to pkey_set() are the same format: a bitmask containing
PKEY_DENY_WRITE and/or PKEY_DENY_ACCESS, or nothing set at all.

These replace userspace's direct use of rdpkru/wrpkru.

With current hardware, the kernel can not enforce that it has
control over a given key.  But, this at least allows the kernel
to indicate to userspace that userspace does not control a given
protection key.

The kernel does _not_ enforce that this interface must be used for
changes to PKRU, even for keys it has not "allocated".

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-api@vger.kernel.org
---

 b/arch/x86/entry/syscalls/syscall_32.tbl |    2 +
 b/arch/x86/entry/syscalls/syscall_64.tbl |    2 +
 b/arch/x86/include/asm/mmu_context.h     |    2 +
 b/arch/x86/include/asm/pkeys.h           |    2 -
 b/arch/x86/kernel/fpu/xstate.c           |   55 +++++++++++++++++++++++++++++--
 b/include/linux/pkeys.h                  |    8 ++++
 b/mm/mprotect.c                          |   34 +++++++++++++++++++
 7 files changed, 102 insertions(+), 3 deletions(-)

diff -puN arch/x86/entry/syscalls/syscall_32.tbl~pkey-syscalls-set-get arch/x86/entry/syscalls/syscall_32.tbl
--- a/arch/x86/entry/syscalls/syscall_32.tbl~pkey-syscalls-set-get	2015-12-03 16:21:33.139012003 -0800
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2015-12-03 16:21:33.151012548 -0800
@@ -386,3 +386,5 @@
 377	i386	pkey_mprotect		sys_pkey_mprotect
 378	i386	pkey_alloc		sys_pkey_alloc
 379	i386	pkey_free		sys_pkey_free
+380	i386	pkey_get		sys_pkey_get
+381	i386	pkey_set		sys_pkey_set
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~pkey-syscalls-set-get arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~pkey-syscalls-set-get	2015-12-03 16:21:33.141012094 -0800
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2015-12-03 16:21:33.152012593 -0800
@@ -335,6 +335,8 @@
 326	common	pkey_mprotect		sys_pkey_mprotect
 327	common	pkey_alloc		sys_pkey_alloc
 328	common	pkey_free		sys_pkey_free
+329	common	pkey_get		sys_pkey_get
+330	common	pkey_set		sys_pkey_set
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff -puN arch/x86/include/asm/mmu_context.h~pkey-syscalls-set-get arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkey-syscalls-set-get	2015-12-03 16:21:33.142012139 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2015-12-03 16:21:33.152012593 -0800
@@ -340,5 +340,7 @@ static inline bool arch_pte_access_permi
 
 extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
+extern unsigned long arch_get_user_pkey_access(struct task_struct *tsk,
+		int pkey);
 
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff -puN arch/x86/include/asm/pkeys.h~pkey-syscalls-set-get arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkey-syscalls-set-get	2015-12-03 16:21:33.144012230 -0800
+++ b/arch/x86/include/asm/pkeys.h	2015-12-03 16:21:33.152012593 -0800
@@ -16,7 +16,7 @@
 } while (0)
 
 static inline
-bool mm_pkey_is_allocated(struct mm_struct *mm, unsigned long pkey)
+bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
 {
 	if (!arch_validate_pkey(pkey))
 		return true;
diff -puN arch/x86/kernel/fpu/xstate.c~pkey-syscalls-set-get arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pkey-syscalls-set-get	2015-12-03 16:21:33.145012275 -0800
+++ b/arch/x86/kernel/fpu/xstate.c	2015-12-03 16:21:33.153012638 -0800
@@ -687,7 +687,7 @@ void fpu__resume_cpu(void)
  *
  * Note: does not work for compacted buffers.
  */
-void *__raw_xsave_addr(struct xregs_state *xsave, int xstate_feature_mask)
+static void *__raw_xsave_addr(struct xregs_state *xsave, int xstate_feature_mask)
 {
 	int feature_nr = fls64(xstate_feature_mask) - 1;
 
@@ -862,6 +862,7 @@ out:
 
 #define NR_VALID_PKRU_BITS (CONFIG_NR_PROTECTION_KEYS * 2)
 #define PKRU_VALID_MASK (NR_VALID_PKRU_BITS - 1)
+#define PKRU_INIT_STATE	0
 
 /*
  * This will go out and modify the XSAVE buffer so that PKRU is
@@ -880,6 +881,9 @@ int arch_set_user_pkey_access(struct tas
 	int pkey_shift = (pkey * PKRU_BITS_PER_PKEY);
 	u32 new_pkru_bits = 0;
 
+	/* Only support manipulating current task for now */
+	if (tsk != current)
+		return -EINVAL;
 	if (!arch_validate_pkey(pkey))
 		return -EINVAL;
 	/*
@@ -907,7 +911,7 @@ int arch_set_user_pkey_access(struct tas
 	 * state.
 	 */
 	if (!old_pkru_state)
-		new_pkru_state.pkru = 0;
+		new_pkru_state.pkru = PKRU_INIT_STATE;
 	else
 		new_pkru_state.pkru = old_pkru_state->pkru;
 
@@ -932,4 +936,51 @@ int arch_set_user_pkey_access(struct tas
 
 	return 0;
 }
+
+/*
+ * Figures out what the rights are currently for 'pkey'.
+ * Converts from PKRU's format to the user-visible PKEY_DISABLE_*
+ * format.
+ */
+unsigned long arch_get_user_pkey_access(struct task_struct *tsk, int pkey)
+{
+	struct fpu *fpu = &current->thread.fpu;
+	u32 pkru_reg;
+	int ret = 0;
+
+	/* Only support manipulating current task for now */
+	if (tsk != current)
+		return -1;
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return -1;
+	/*
+	 * The contents of PKRU itself are invalid.  Consult the
+	 * task's XSAVE buffer for PKRU contents.  This is much
+	 * more expensive than reading PKRU directly, but should
+	 * be rare or impossible with eagerfpu mode.
+	 */
+	if (!fpu->fpregs_active) {
+		struct xregs_state *xsave = &fpu->state.xsave;
+		struct pkru_state *pkru_state =
+			get_xsave_addr(xsave, XFEATURE_MASK_PKRU);
+		/*
+		 * PKRU is in its init state and not present in
+		 * the buffer in a saved form.
+		 */
+		if (!pkru_state)
+			return PKRU_INIT_STATE;
+
+		return pkru_state->pkru;
+	}
+	/*
+	 * Consult the user register directly.
+	 */
+	pkru_reg = read_pkru();
+	if (!__pkru_allows_read(pkru_reg, pkey))
+		ret |= PKEY_DISABLE_ACCESS;
+	if (!__pkru_allows_write(pkru_reg, pkey))
+		ret |= PKEY_DISABLE_WRITE;
+
+	return ret;
+}
 #endif /* CONFIG_ARCH_HAS_PKEYS */
diff -puN include/linux/pkeys.h~pkey-syscalls-set-get include/linux/pkeys.h
--- a/include/linux/pkeys.h~pkey-syscalls-set-get	2015-12-03 16:21:33.147012366 -0800
+++ b/include/linux/pkeys.h	2015-12-03 16:21:33.153012638 -0800
@@ -43,6 +43,14 @@ static inline int mm_pkey_free(struct mm
 static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 			unsigned long init_val)
 {
+	return -EINVAL;
+}
+
+static inline
+unsigned long arch_get_user_pkey_access(struct task_struct *tsk, int pkey)
+{
+	if (pkey)
+		return -1;
 	return 0;
 }
 
diff -puN mm/mprotect.c~pkey-syscalls-set-get mm/mprotect.c
--- a/mm/mprotect.c~pkey-syscalls-set-get	2015-12-03 16:21:33.148012412 -0800
+++ b/mm/mprotect.c	2015-12-03 16:21:33.154012684 -0800
@@ -531,3 +531,37 @@ SYSCALL_DEFINE1(pkey_free, int, pkey)
 	 */
 	return ret;
 }
+
+SYSCALL_DEFINE1(pkey_get, int, pkey)
+{
+	unsigned long ret = 0;
+
+	down_write(&current->mm->mmap_sem);
+	if (!mm_pkey_is_allocated(current->mm, pkey))
+		ret = -EBADF;
+	up_write(&current->mm->mmap_sem);
+
+	if (ret)
+		return ret;
+
+	ret = arch_get_user_pkey_access(current, pkey);
+
+	return ret;
+}
+
+SYSCALL_DEFINE2(pkey_set, int, pkey, unsigned long, access_rights)
+{
+	unsigned long ret = 0;
+
+	down_write(&current->mm->mmap_sem);
+	if (!mm_pkey_is_allocated(current->mm, pkey))
+		ret = -EBADF;
+	up_write(&current->mm->mmap_sem);
+
+	if (ret)
+		return ret;
+
+	ret = arch_set_user_pkey_access(current, pkey, access_rights);
+
+	return ret;
+}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
