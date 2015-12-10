Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id EDCA76B025F
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 20:25:33 -0500 (EST)
Received: by pfu207 with SMTP id 207so38855515pfu.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 17:25:33 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id h4si11582917pat.195.2015.12.09.17.25.30
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 17:25:30 -0800 (PST)
Subject: [PATCH] [RFC] x86, pkeys: execute-only support
From: Dave Hansen <dave@sr71.net>
Date: Wed, 09 Dec 2015 17:25:30 -0800
Message-Id: <20151210012530.D42746E9@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-mm@kvack.org, keescook@google.com, luto@amacapital.net


This patch is on top of the base protection keys support which
can be found here:

	http://git.kernel.org/cgit/linux/kernel/git/daveh/x86-pkeys.git/log/?h=pkeys-v014

Protection keys provide new page-based protection in hardware.
But, they have an interesting attribute: they only affect data
accesses and never affect instruction fetches.  That means that
if we set up some memory which is set as "access-disabled" via
protection keys, we can still execute from it.

This patch uses protection keys to set up mappings to do just that.
If a user calls:

	mmap(..., PROT_EXEC);
or
	mprotect(ptr, sz, PROT_EXEC);

(note PROT_EXEC-only without PROT_READ/WRITE), the kernel will
notice this, and set a special protection key on the memory.  It
also sets the appropriate bits in the Protection Keys User Rights
(PKRU) register so that the memory becomes unreadable and
unwritable.

I haven't found any userspace that does this today.

The security provided by this approach is not comprehensive.  The
PKRU register which controls access permissions is a normal
user register writable from unprivileged userspace.  An attacker
who can execute the 'wrpkru' instruction can easily disable the
protection provided by this feature.

The protection key that is used for execute-only support is
permanently dedicated in a process.  Even if all of the
execute-only mappings go away, the key stays allocated.  This
could be fixed, but it will involve a reference count or a walk
of all of the VMAs.

This code is still a bit rough, doesn't compile with a wide range
of config options, etc...  But it gives a rough idea about how
complicated the feature is.  It's surprisingly reasonable.

Semantically, we have a bit of a problem:  What do we do when we mix
execute-only pkey use with mprotect_pkey() use?

	mprotect_pkey(ptr, PAGE_SIZE, PROT_WRITE, 6); // set pkey=6
	mprotect(ptr, PAGE_SIZE, PROT_EXEC);  // set pkey=X_ONLY_PKEY?
	mprotect(ptr, PAGE_SIZE, PROT_WRITE); // is pkey=6 again?

To solve that, we make the plain-mprotect()-initiated execute-only
support only apply to VMAs that have the default protection key (0)
set on them.

Proposed semantics:
1. protection key 0 is special and represents the default,
   unassigned protection key.  It is always allocated.
2. mprotect() never affects a mapping's mprotect_pkey()-assigned
   protection key. A protection key of 0 (even if set explicitly)
   represents an unassigned protection key.
   2a. mprotect(PROT_EXEC) on a mapping with an assigned protection
       key may or may not result in a mapping with execute-only
       properties.  mprotect_pkey() plus pkey_set() on all threads
       should be used to _guarantee_ execute-only semantics.
3. mprotect(PROT_EXEC) may result in an "execute-only" mapping. The
   kernel will internally attempt to allocate and dedicate a
   protection key for the purpose of execute-only mappings.

Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: keescook@google.com
Cc: luto@amacapital.net

---

 b/arch/x86/include/asm/mmu.h         |    1 
 b/arch/x86/include/asm/mmu_context.h |    1 
 b/arch/x86/include/asm/pkeys.h       |   41 +++++++++++++++-
 b/arch/x86/mm/fault.c                |   87 +++++++++++++++++++++++++++++++++++
 b/mm/mmap.c                          |    9 +++
 b/mm/mprotect.c                      |   10 +---
 6 files changed, 139 insertions(+), 10 deletions(-)

diff -puN mm/mprotect.c~pkeys-xonly mm/mprotect.c
--- a/mm/mprotect.c~pkeys-xonly	2015-12-09 10:10:05.748245134 -0800
+++ b/mm/mprotect.c	2015-12-09 17:17:24.369220977 -0800
@@ -428,14 +428,10 @@ static int do_mprotect_pkey(unsigned lon
 
 		/* Here we know that vma->vm_start <= nstart < vma->vm_end. */
 
-		/*
-		 * If this is a vanilla, non-pkey mprotect, inherit the
-		 * pkey from the VMA we are working on.
-		 */
 		if (plain_mprotect)
-			newflags = calc_vm_prot_bits(prot, vma_pkey(vma));
-		else
-			newflags = calc_vm_prot_bits(prot, pkey);
+			pkey = arch_override_mprotect_pkey(vma, prot, pkey);
+
+		newflags = calc_vm_prot_bits(prot, pkey);
 		newflags |= (vma->vm_flags & ~mask_off_old_flags);
 
 		/* newflags >> 4 shift VM_MAY% in place of VM_% */
diff -puN mm/mmap.c~pkeys-xonly mm/mmap.c
--- a/mm/mmap.c~pkeys-xonly	2015-12-09 10:10:05.751245269 -0800
+++ b/mm/mmap.c	2015-12-09 15:44:47.587158696 -0800
@@ -1266,6 +1266,7 @@ unsigned long do_mmap(struct file *file,
 			unsigned long pgoff, unsigned long *populate)
 {
 	struct mm_struct *mm = current->mm;
+	int pkey = 0;
 
 	*populate = 0;
 
@@ -1305,11 +1306,17 @@ unsigned long do_mmap(struct file *file,
 	if (offset_in_page(addr))
 		return addr;
 
+	if (prot == PROT_EXEC) {
+		pkey = execute_only_pkey(mm);
+		if (pkey < 0)
+			pkey = 0;
+	}
+
 	/* Do simple checking here so the lower-level routines won't have
 	 * to. we assume access permissions have been handled by the open
 	 * of the memory object, so we don't do any here.
 	 */
-	vm_flags |= calc_vm_prot_bits(prot, 0) | calc_vm_flag_bits(flags) |
+	vm_flags |= calc_vm_prot_bits(prot, pkey) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
 	if (flags & MAP_LOCKED)
diff -puN arch/x86/include/asm/mmu_context.h~pkeys-xonly arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-xonly	2015-12-09 14:36:46.584880750 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2015-12-09 14:43:35.241305837 -0800
@@ -111,6 +111,7 @@ static inline int init_new_context(struc
 #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 	/* pkey 0 is the default and always allocated */
 	mm->context.pkey_allocation_map = 0x1;
+	mm->context.execute_only_pkey = -1;
 #endif
 	init_new_context_ldt(tsk, mm);
 
diff -puN arch/x86/include/asm/mmu.h~pkeys-xonly arch/x86/include/asm/mmu.h
--- a/arch/x86/include/asm/mmu.h~pkeys-xonly	2015-12-09 14:37:00.713517736 -0800
+++ b/arch/x86/include/asm/mmu.h	2015-12-09 14:37:54.050922461 -0800
@@ -28,6 +28,7 @@ typedef struct {
 	 * use it or not.  protected by mmap_sem.
 	 */
 	u16 pkey_allocation_map;
+	s16 execute_only_pkey;
 #endif
 } mm_context_t;
 
diff -puN arch/x86/include/asm/pkeys.h~pkeys-xonly arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkeys-xonly	2015-12-09 14:43:40.270532601 -0800
+++ b/arch/x86/include/asm/pkeys.h	2015-12-09 16:46:20.445024694 -0800
@@ -30,14 +30,25 @@ bool mm_pkey_is_allocated(struct mm_stru
 {
 	if (!validate_pkey(pkey))
 		return true;
+	if (pkey == mm->context.execute_only_pkey)
+		return true;
 
 	return mm_pkey_allocation_map(mm) & (1 << pkey);
 }
 
+static inline int all_pkeys_mask(struct mm_struct *mm)
+{
+	int mask = ((1 << arch_max_pkey()) - 1);
+
+	if (mm->context.execute_only_pkey != -1)
+		mask &= ~(1 << mm->context.execute_only_pkey);
+
+	return mask;
+}
+
 static inline
 int mm_pkey_alloc(struct mm_struct *mm)
 {
-	int all_pkeys_mask = ((1 << arch_max_pkey()) - 1);
 	int ret;
 
 	/*
@@ -45,7 +56,7 @@ int mm_pkey_alloc(struct mm_struct *mm)
 	 * because ffz() behavior is undefined if there are no
 	 * zeros.
 	 */
-	if (mm_pkey_allocation_map(mm) == all_pkeys_mask)
+	if (mm_pkey_allocation_map(mm) == all_pkeys_mask(mm))
 		return -1;
 
 	ret = ffz(mm_pkey_allocation_map(mm));
@@ -64,6 +75,8 @@ int mm_pkey_free(struct mm_struct *mm, i
 	 */
 	if (!pkey || !validate_pkey(pkey))
 		return -EINVAL;
+	if (pkey == mm->context.execute_only_pkey)
+		return -EINVAL;
 	if (!mm_pkey_is_allocated(mm, pkey))
 		return -EINVAL;
 
@@ -72,6 +85,30 @@ int mm_pkey_free(struct mm_struct *mm, i
 	return 0;
 }
 
+/*
+ * Try to dedicate one of the protection keys to be used as an
+ * execute-only protection key.
+ */
+extern int __execute_only_pkey(struct mm_struct *mm);
+static inline int execute_only_pkey(struct mm_struct *mm)
+{
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return -1;
+
+	return __execute_only_pkey(mm);
+}
+
+extern int __arch_override_mprotect_pkey(struct vm_area_struct *vma,
+		int prot, int pkey);
+static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
+		int prot, int pkey)
+{
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return -1;
+
+	return __arch_override_mprotect_pkey(vma, prot, pkey);
+}
+
 #endif /*_ASM_X86_PKEYS_H */
 
 
diff -puN arch/x86/mm/fault.c~pkeys-xonly arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-xonly	2015-12-09 15:02:50.469400624 -0800
+++ b/arch/x86/mm/fault.c	2015-12-09 17:20:23.792300335 -0800
@@ -14,6 +14,7 @@
 #include <linux/prefetch.h>		/* prefetchw			*/
 #include <linux/context_tracking.h>	/* exception_enter(), ...	*/
 #include <linux/uaccess.h>		/* faulthandler_disabled()	*/
+#include <uapi/asm-generic/mman-common.h>
 
 #include <asm/cpufeature.h>		/* boot_cpu_has, ...		*/
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
@@ -1108,6 +1109,16 @@ access_error(unsigned long error_code, s
 	 */
 	if (error_code & PF_PK)
 		return 1;
+
+	if (!(error_code & PF_INSTR)) {
+		/*
+		 * Assume all accesses require either read or execute
+		 * permissions.  This is not an instruction access, so
+		 * it requires read permissions.
+		 */
+		if (!(vma->vm_flags & VM_READ))
+			return 1;
+	}
 	/*
 	 * Make sure to check the VMA so that we do not perform
 	 * faults just to hit a PF_PK as soon as we fill in a
@@ -1447,3 +1458,79 @@ trace_do_page_fault(struct pt_regs *regs
 }
 NOKPROBE_SYMBOL(trace_do_page_fault);
 #endif /* CONFIG_TRACING */
+
+int __execute_only_pkey(struct mm_struct *mm)
+{
+	unsigned long access_rights = PKEY_DISABLE_ACCESS;
+	int new_execute_only_pkey;
+	int ret;
+
+	/* Do we have one assigned already? */
+	if (mm->context.execute_only_pkey != -1)
+       		return mm->context.execute_only_pkey;
+
+	/* We need to go allocate one to use, which might fail */
+	new_execute_only_pkey = mm_pkey_alloc(mm);
+	if (!validate_pkey(new_execute_only_pkey))
+		return -1;
+	/*
+	 * Set up PKRU so that it denies access for everything
+	 * other than execution
+	 */
+	ret = arch_set_user_pkey_access(current, new_execute_only_pkey,
+			access_rights);
+	if (ret) {
+		mm_set_pkey_free(mm, new_execute_only_pkey);
+		return -1;
+	}
+
+	/* We got one, store it and use it from here on out */
+	mm->context.execute_only_pkey = new_execute_only_pkey;
+	return new_execute_only_pkey;
+}
+
+static inline bool vma_is_pkey_exec_only(struct vm_area_struct *vma)
+{
+	/* Do this check first since the vm_flags should be hot */
+	if ((vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC)) != VM_EXEC)
+		return false;
+	if (vma_pkey(vma) != vma->vm_mm->context.execute_only_pkey)
+		return false;
+
+	return true;
+}
+
+/*
+ * This is only called for *plain* mprotect calls.
+ */
+int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot, int pkey)
+{
+	WARN_ONCE(pkey != -1, "override attempted for non-default protection key");
+
+	/*
+	 * Look for a protection-key-drive execute-only mapping
+	 * which is now being given permissions that are not
+	 * execute-only.  Move it back to the default pkey.
+	 */
+	if (vma_is_pkey_exec_only(vma) &&
+	    (prot & (PROT_READ|PROT_WRITE))) {
+		return 0;
+	}
+	/*
+	 * The mapping is execute-only.  Go try to get the
+	 * execute-only protection key.  If we fail to do that,
+	 * fall through as if we do not have execute-only
+	 * support.
+	 */
+	if (prot == PROT_EXEC) {
+		pkey = execute_only_pkey(vma->vm_mm);
+		if (pkey > 0)
+			return pkey;
+	}
+	/*
+	 * This is a vanilla, non-pkey mprotect (or we failed to
+	 * setup execute-only), inherit the pkey from the VMA we
+	 * are working on.
+	 */
+	return vma_pkey(vma);
+}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
