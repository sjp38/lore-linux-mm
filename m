Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id CA93A6B025F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:54:31 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id c20so126231476pfc.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:54:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id fl1si4297320pab.223.2016.04.11.08.54.26
        for <linux-mm@kvack.org>;
        Mon, 11 Apr 2016 08:54:26 -0700 (PDT)
Subject: [PATCH 2/8] mm: implement new pkey_mprotect() system call
From: Dave Hansen <dave@sr71.net>
Date: Mon, 11 Apr 2016 08:54:25 -0700
References: <20160411155422.A2B8FD0C@viggo.jf.intel.com>
In-Reply-To: <20160411155422.A2B8FD0C@viggo.jf.intel.com>
Message-Id: <20160411155425.83CE1037@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, linux-api@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org


From: Dave Hansen <dave.hansen@linux.intel.com>

pkey_mprotect() is just like mprotect, except it also takes a
protection key as an argument.  On systems that do not support
protection keys, it still works, but requires that key=0.
Otherwise it does exactly what mprotect does.

I expect it to get used like this, if you want to guarantee that
any mapping you create can *never* be accessed without the right
protection keys set up.

	int real_prot = PROT_READ|PROT_WRITE;
	pkey = pkey_alloc(0, PKEY_DENY_ACCESS);
	ptr = mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
	ret = pkey_mprotect(ptr, PAGE_SIZE, real_prot, pkey);

This way, there is *no* window where the mapping is accessible
since it was always either PROT_NONE or had a protection key set.

We settled on 'unsigned long' for the type of the key here.  We
only need 4 bits on x86 today, but I figured that other
architectures might need some more space.

Semantically, we have a bit of a problem if we combine this
syscall with our previously-introduced execute-only support:
What do we do when we mix execute-only pkey use with
pkey_mprotect() use?  For instance:

	pkey_mprotect(ptr, PAGE_SIZE, PROT_WRITE, 6); // set pkey=6
	mprotect(ptr, PAGE_SIZE, PROT_EXEC);  // set pkey=X_ONLY_PKEY?
	mprotect(ptr, PAGE_SIZE, PROT_WRITE); // is pkey=6 again?

To solve that, we make the plain-mprotect()-initiated execute-only
support only apply to VMAs that have the default protection key (0)
set on them.

Proposed semantics:
1. protection key 0 is special and represents the default,
   unassigned protection key.  It is always allocated.
2. mprotect() never affects a mapping's pkey_mprotect()-assigned
   protection key. A protection key of 0 (even if set explicitly)
   represents an unassigned protection key.
   2a. mprotect(PROT_EXEC) on a mapping with an assigned protection
       key may or may not result in a mapping with execute-only
       properties.  pkey_mprotect() plus pkey_set() on all threads
       should be used to _guarantee_ execute-only semantics.
3. mprotect(PROT_EXEC) may result in an "execute-only" mapping. The
   kernel will internally attempt to allocate and dedicate a
   protection key for the purpose of execute-only mappings.  This
   may not be possible in cases where there are no free protection
   keys available.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-api@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
---

 b/arch/x86/include/asm/mmu_context.h |   15 ++++++++++-----
 b/arch/x86/include/asm/pkeys.h       |   11 +++++++++--
 b/arch/x86/kernel/fpu/xstate.c       |   15 ++++++++++++++-
 b/arch/x86/mm/pkeys.c                |    2 +-
 b/mm/mprotect.c                      |   27 +++++++++++++++++++++++----
 5 files changed, 57 insertions(+), 13 deletions(-)

diff -puN arch/x86/include/asm/mmu_context.h~pkeys-110-syscalls-mprotect_pkey arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-110-syscalls-mprotect_pkey	2016-04-11 08:38:40.875250853 -0700
+++ b/arch/x86/include/asm/mmu_context.h	2016-04-11 08:38:40.885251305 -0700
@@ -4,6 +4,7 @@
 #include <asm/desc.h>
 #include <linux/atomic.h>
 #include <linux/mm_types.h>
+#include <linux/pkeys.h>
 
 #include <trace/events/tlb.h>
 
@@ -286,16 +287,20 @@ static inline void arch_unmap(struct mm_
 		mpx_notify_unmap(mm, vma, start, end);
 }
 
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 static inline int vma_pkey(struct vm_area_struct *vma)
 {
-	u16 pkey = 0;
-#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 	unsigned long vma_pkey_mask = VM_PKEY_BIT0 | VM_PKEY_BIT1 |
 				      VM_PKEY_BIT2 | VM_PKEY_BIT3;
-	pkey = (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
-#endif
-	return pkey;
+
+	return (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
+}
+#else
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	return 0;
 }
+#endif
 
 static inline bool __pkru_allows_pkey(u16 pkey, bool write)
 {
diff -puN arch/x86/include/asm/pkeys.h~pkeys-110-syscalls-mprotect_pkey arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkeys-110-syscalls-mprotect_pkey	2016-04-11 08:38:40.877250943 -0700
+++ b/arch/x86/include/asm/pkeys.h	2016-04-11 08:38:40.885251305 -0700
@@ -1,7 +1,12 @@
 #ifndef _ASM_X86_PKEYS_H
 #define _ASM_X86_PKEYS_H
 
-#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? 16 : 1)
+#define PKEY_DEDICATED_EXECUTE_ONLY 15
+/*
+ * Consider the PKEY_DEDICATED_EXECUTE_ONLY key unavailable.
+ */
+#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? \
+		PKEY_DEDICATED_EXECUTE_ONLY : 1)
 
 extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
@@ -10,7 +15,6 @@ extern int arch_set_user_pkey_access(str
  * Try to dedicate one of the protection keys to be used as an
  * execute-only protection key.
  */
-#define PKEY_DEDICATED_EXECUTE_ONLY 15
 extern int __execute_only_pkey(struct mm_struct *mm);
 static inline int execute_only_pkey(struct mm_struct *mm)
 {
@@ -31,4 +35,7 @@ static inline int arch_override_mprotect
 	return __arch_override_mprotect_pkey(vma, prot, pkey);
 }
 
+extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val);
+
 #endif /*_ASM_X86_PKEYS_H */
diff -puN arch/x86/kernel/fpu/xstate.c~pkeys-110-syscalls-mprotect_pkey arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-110-syscalls-mprotect_pkey	2016-04-11 08:38:40.878250989 -0700
+++ b/arch/x86/kernel/fpu/xstate.c	2016-04-11 08:38:40.886251351 -0700
@@ -871,7 +871,7 @@ out:
  * not modfiy PKRU *itself* here, only the XSAVE state that will
  * be restored in to PKRU when we return back to userspace.
  */
-int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val)
 {
 	struct xregs_state *xsave = &tsk->thread.fpu.state.xsave;
@@ -930,3 +930,16 @@ int arch_set_user_pkey_access(struct tas
 
 	return 0;
 }
+
+/*
+ * When setting a userspace-provided value, we need to ensure
+ * that it is valid.  The __ version can get used by
+ * kernel-internal uses like the execute-only support.
+ */
+int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val)
+{
+	if (!validate_pkey(pkey))
+		return -EINVAL;
+	return __arch_set_user_pkey_access(tsk, pkey, init_val);
+}
diff -puN arch/x86/mm/pkeys.c~pkeys-110-syscalls-mprotect_pkey arch/x86/mm/pkeys.c
--- a/arch/x86/mm/pkeys.c~pkeys-110-syscalls-mprotect_pkey	2016-04-11 08:38:40.880251079 -0700
+++ b/arch/x86/mm/pkeys.c	2016-04-11 08:38:40.886251351 -0700
@@ -38,7 +38,7 @@ int __execute_only_pkey(struct mm_struct
 		return PKEY_DEDICATED_EXECUTE_ONLY;
 	}
 	preempt_enable();
-	ret = arch_set_user_pkey_access(current, PKEY_DEDICATED_EXECUTE_ONLY,
+	ret = __arch_set_user_pkey_access(current, PKEY_DEDICATED_EXECUTE_ONLY,
 			PKEY_DISABLE_ACCESS);
 	/*
 	 * If the PKRU-set operation failed somehow, just return
diff -puN mm/mprotect.c~pkeys-110-syscalls-mprotect_pkey mm/mprotect.c
--- a/mm/mprotect.c~pkeys-110-syscalls-mprotect_pkey	2016-04-11 08:38:40.881251124 -0700
+++ b/mm/mprotect.c	2016-04-11 08:38:40.886251351 -0700
@@ -352,8 +352,11 @@ fail:
 	return error;
 }
 
-SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
-		unsigned long, prot)
+/*
+ * pkey==-1 when doing a legacy mprotect()
+ */
+static int do_mprotect_pkey(unsigned long start, size_t len,
+		unsigned long prot, int pkey)
 {
 	unsigned long nstart, end, tmp, reqprot;
 	struct vm_area_struct *vma, *prev;
@@ -408,7 +411,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 
 	for (nstart = start ; ; ) {
 		unsigned long newflags;
-		int pkey = arch_override_mprotect_pkey(vma, prot, -1);
+		int vma_pkey;
 
 		/* Here we know that vma->vm_start <= nstart < vma->vm_end. */
 
@@ -416,7 +419,8 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 		if (rier && (vma->vm_flags & VM_MAYEXEC))
 			prot |= PROT_EXEC;
 
-		newflags = calc_vm_prot_bits(prot, pkey);
+		vma_pkey = arch_override_mprotect_pkey(vma, prot, pkey);
+		newflags = calc_vm_prot_bits(prot, vma_pkey);
 		newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
 
 		/* newflags >> 4 shift VM_MAY% in place of VM_% */
@@ -453,3 +457,18 @@ out:
 	up_write(&current->mm->mmap_sem);
 	return error;
 }
+
+SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
+		unsigned long, prot)
+{
+	return do_mprotect_pkey(start, len, prot, -1);
+}
+
+SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
+		unsigned long, prot, int, pkey)
+{
+	if (!validate_pkey(pkey))
+		return -EINVAL;
+
+	return do_mprotect_pkey(start, len, prot, pkey);
+}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
