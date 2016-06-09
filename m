Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6A9828E5
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 20:01:41 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id q18so33774523igr.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 17:01:41 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id c2si4017304pas.175.2016.06.08.17.01.38
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 17:01:38 -0700 (PDT)
Subject: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
From: Dave Hansen <dave@sr71.net>
Date: Wed, 08 Jun 2016 17:01:31 -0700
References: <20160609000117.71AC7623@viggo.jf.intel.com>
In-Reply-To: <20160609000117.71AC7623@viggo.jf.intel.com>
Message-Id: <20160609000131.DE661E3B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

This establishes two more system calls for protection key management:

	unsigned long pkey_get(int pkey);
	int pkey_set(int pkey, unsigned long access_rights);

The return value from pkey_get() and the 'access_rights' passed
to pkey_set() are the same format: a bitmask containing
PKEY_DENY_WRITE and/or PKEY_DENY_ACCESS, or nothing set at all.

These can replace userspace's direct use of the new rdpkru/wrpkru
instructions.

With current hardware, the kernel can not enforce that it has
control over a given key.  But, this at least allows the kernel
to indicate to userspace that userspace does not control a given
protection key.  This makes it more likely that situations like
using a pkey after sys_pkey_free() can be detected.

The kernel does _not_ enforce that this interface must be used for
changes to PKRU, whether or not a key has been "allocated".

This syscall interface could also theoretically be replaced with a
pair of vsyscalls.  The vsyscalls would just call WRPKRU/RDPKRU
directly in situations where they are drop-in equivalents for
what the kernel would be doing.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-api@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
---

 b/arch/x86/entry/syscalls/syscall_32.tbl |    2 +
 b/arch/x86/entry/syscalls/syscall_64.tbl |    2 +
 b/arch/x86/include/asm/pkeys.h           |    4 +-
 b/arch/x86/kernel/fpu/xstate.c           |   55 +++++++++++++++++++++++++++++--
 b/include/linux/pkeys.h                  |    8 ++++
 b/mm/mprotect.c                          |   41 +++++++++++++++++++++++
 6 files changed, 109 insertions(+), 3 deletions(-)

diff -puN arch/x86/entry/syscalls/syscall_32.tbl~pkeys-118-syscalls-set-get arch/x86/entry/syscalls/syscall_32.tbl
--- a/arch/x86/entry/syscalls/syscall_32.tbl~pkeys-118-syscalls-set-get	2016-06-08 16:26:35.894970089 -0700
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2016-06-08 16:26:35.906970634 -0700
@@ -389,3 +389,5 @@
 380	i386	pkey_mprotect		sys_pkey_mprotect
 381	i386	pkey_alloc		sys_pkey_alloc
 382	i386	pkey_free		sys_pkey_free
+383	i386	pkey_get		sys_pkey_get
+384	i386	pkey_set		sys_pkey_set
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~pkeys-118-syscalls-set-get arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~pkeys-118-syscalls-set-get	2016-06-08 16:26:35.896970180 -0700
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2016-06-08 16:26:35.906970634 -0700
@@ -338,6 +338,8 @@
 329	common	pkey_mprotect		sys_pkey_mprotect
 330	common	pkey_alloc		sys_pkey_alloc
 331	common	pkey_free		sys_pkey_free
+332	common	pkey_get		sys_pkey_get
+333	common	pkey_set		sys_pkey_set
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff -puN arch/x86/include/asm/pkeys.h~pkeys-118-syscalls-set-get arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkeys-118-syscalls-set-get	2016-06-08 16:26:35.898970271 -0700
+++ b/arch/x86/include/asm/pkeys.h	2016-06-08 16:26:35.908970724 -0700
@@ -56,7 +56,7 @@ static inline bool validate_pkey(int pke
 }
 
 static inline
-bool mm_pkey_is_allocated(struct mm_struct *mm, unsigned long pkey)
+bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
 {
 	if (!validate_pkey(pkey))
 		return true;
@@ -107,4 +107,6 @@ extern int arch_set_user_pkey_access(str
 extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
 
+extern unsigned long arch_get_user_pkey_access(struct task_struct *tsk,
+		int pkey);
 #endif /*_ASM_X86_PKEYS_H */
diff -puN arch/x86/kernel/fpu/xstate.c~pkeys-118-syscalls-set-get arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-118-syscalls-set-get	2016-06-08 16:26:35.899970316 -0700
+++ b/arch/x86/kernel/fpu/xstate.c	2016-06-08 16:26:35.908970724 -0700
@@ -690,7 +690,7 @@ void fpu__resume_cpu(void)
  *
  * Note: does not work for compacted buffers.
  */
-void *__raw_xsave_addr(struct xregs_state *xsave, int xstate_feature_mask)
+static void *__raw_xsave_addr(struct xregs_state *xsave, int xstate_feature_mask)
 {
 	int feature_nr = fls64(xstate_feature_mask) - 1;
 
@@ -864,6 +864,7 @@ out:
 
 #define NR_VALID_PKRU_BITS (CONFIG_NR_PROTECTION_KEYS * 2)
 #define PKRU_VALID_MASK (NR_VALID_PKRU_BITS - 1)
+#define PKRU_INIT_STATE	0
 
 /*
  * This will go out and modify the XSAVE buffer so that PKRU is
@@ -882,6 +883,9 @@ int __arch_set_user_pkey_access(struct t
 	int pkey_shift = (pkey * PKRU_BITS_PER_PKEY);
 	u32 new_pkru_bits = 0;
 
+	/* Only support manipulating current task for now */
+	if (tsk != current)
+		return -EINVAL;
 	/*
 	 * This check implies XSAVE support.  OSPKE only gets
 	 * set if we enable XSAVE and we enable PKU in XCR0.
@@ -907,7 +911,7 @@ int __arch_set_user_pkey_access(struct t
 	 * state.
 	 */
 	if (!old_pkru_state)
-		new_pkru_state.pkru = 0;
+		new_pkru_state.pkru = PKRU_INIT_STATE;
 	else
 		new_pkru_state.pkru = old_pkru_state->pkru;
 
@@ -945,4 +949,51 @@ int arch_set_user_pkey_access(struct tas
 		return -EINVAL;
 	return __arch_set_user_pkey_access(tsk, pkey, init_val);
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
+	if (!cpu_feature_enabled(X86_FEATURE_OSPKE))
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
diff -puN include/linux/pkeys.h~pkeys-118-syscalls-set-get include/linux/pkeys.h
--- a/include/linux/pkeys.h~pkeys-118-syscalls-set-get	2016-06-08 16:26:35.901970407 -0700
+++ b/include/linux/pkeys.h	2016-06-08 16:26:35.909970770 -0700
@@ -44,6 +44,14 @@ static inline int mm_pkey_free(struct mm
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
 
diff -puN mm/mprotect.c~pkeys-118-syscalls-set-get mm/mprotect.c
--- a/mm/mprotect.c~pkeys-118-syscalls-set-get	2016-06-08 16:26:35.903970497 -0700
+++ b/mm/mprotect.c	2016-06-08 16:26:35.909970770 -0700
@@ -537,3 +537,44 @@ SYSCALL_DEFINE1(pkey_free, int, pkey)
 	 */
 	return ret;
 }
+
+SYSCALL_DEFINE2(pkey_get, int, pkey, unsigned long, flags)
+{
+	unsigned long ret = 0;
+
+	if (flags)
+		return -EINVAL;
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
+SYSCALL_DEFINE3(pkey_set, int, pkey, unsigned long, access_rights,
+		unsigned long, flags)
+{
+	unsigned long ret = 0;
+
+	if (flags)
+		return -EINVAL;
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
