Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id F303A6B02FD
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:12:27 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o3so10429101qto.15
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:27 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id p65si25996qkc.231.2017.06.27.03.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 03:12:26 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id 16so3246583qkg.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:26 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v4 06/17] powerpc: Implementation for sys_mprotect_pkey() system call
Date: Tue, 27 Jun 2017 03:11:48 -0700
Message-Id: <1498558319-32466-7-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

This system call, associates the pkey with vma corresponding to
the given address range.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/mman.h        |  8 ++-
 arch/powerpc/include/asm/pkeys.h       | 17 ++++++-
 arch/powerpc/include/asm/systbl.h      |  1 +
 arch/powerpc/include/asm/unistd.h      |  4 +-
 arch/powerpc/include/uapi/asm/unistd.h |  1 +
 arch/powerpc/mm/pkeys.c                | 93 +++++++++++++++++++++++++++++++++-
 6 files changed, 117 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mman.h
index 30922f6..067eec2 100644
--- a/arch/powerpc/include/asm/mman.h
+++ b/arch/powerpc/include/asm/mman.h
@@ -13,6 +13,7 @@
 
 #include <asm/cputable.h>
 #include <linux/mm.h>
+#include <linux/pkeys.h>
 #include <asm/cpu_has_feature.h>
 
 /*
@@ -22,7 +23,12 @@
 static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot,
 		unsigned long pkey)
 {
-	return (prot & PROT_SAO) ? VM_SAO : 0;
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	return (((prot & PROT_SAO) ? VM_SAO : 0) |
+			pkey_to_vmflag_bits(pkey));
+#else
+	return ((prot & PROT_SAO) ? VM_SAO : 0);
+#endif
 }
 #define arch_calc_vm_prot_bits(prot, pkey) arch_calc_vm_prot_bits(prot, pkey)
 
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 7bc8746..41bf5d4 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -14,6 +14,15 @@
 			VM_PKEY_BIT3 | \
 			VM_PKEY_BIT4)
 
+static inline unsigned long  pkey_to_vmflag_bits(int pkey)
+{
+	return (((pkey & 0x1UL) ? VM_PKEY_BIT0 : 0x0UL) |
+		((pkey & 0x2UL) ? VM_PKEY_BIT1 : 0x0UL) |
+		((pkey & 0x4UL) ? VM_PKEY_BIT2 : 0x0UL) |
+		((pkey & 0x8UL) ? VM_PKEY_BIT3 : 0x0UL) |
+		((pkey & 0x10UL) ? VM_PKEY_BIT4 : 0x0UL));
+}
+
 /*
  * Bits are in BE format.
  * NOTE: key 31, 1, 0 are not used.
@@ -42,6 +51,12 @@
 #define mm_set_pkey_is_reserved(mm, pkey) (PKEY_INITIAL_ALLOCAION & \
 					pkeybit_mask(pkey))
 
+
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	return (vma->vm_flags & ARCH_VM_PKEY_FLAGS) >> VM_PKEY_SHIFT;
+}
+
 static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
 {
 	/* a reserved key is never considered as 'explicitly allocated' */
@@ -114,7 +129,7 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 	return __arch_set_user_pkey_access(tsk, pkey, init_val);
 }
 
-static inline pkey_mm_init(struct mm_struct *mm)
+static inline void pkey_mm_init(struct mm_struct *mm)
 {
 	mm_pkey_allocation_map(mm) = PKEY_INITIAL_ALLOCAION;
 	/* -1 means unallocated or invalid */
diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index 22dd776..b33b551 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -390,3 +390,4 @@
 SYSCALL(statx)
 SYSCALL(pkey_alloc)
 SYSCALL(pkey_free)
+SYSCALL(pkey_mprotect)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index e0273bc..daf1ba9 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -12,12 +12,10 @@
 #include <uapi/asm/unistd.h>
 
 
-#define NR_syscalls		386
+#define NR_syscalls		387
 
 #define __NR__exit __NR_exit
 
-#define __IGNORE_pkey_mprotect
-
 #ifndef __ASSEMBLY__
 
 #include <linux/types.h>
diff --git a/arch/powerpc/include/uapi/asm/unistd.h b/arch/powerpc/include/uapi/asm/unistd.h
index 7993a07..71ae45e 100644
--- a/arch/powerpc/include/uapi/asm/unistd.h
+++ b/arch/powerpc/include/uapi/asm/unistd.h
@@ -396,5 +396,6 @@
 #define __NR_statx		383
 #define __NR_pkey_alloc		384
 #define __NR_pkey_free		385
+#define __NR_pkey_mprotect	386
 
 #endif /* _UAPI_ASM_POWERPC_UNISTD_H_ */
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index b97366e..11a32b3 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -15,6 +15,17 @@
 #include <linux/pkeys.h>                /* PKEY_*                       */
 #include <uapi/asm-generic/mman-common.h>
 
+#define pkeyshift(pkey) ((arch_max_pkey()-pkey-1) * AMR_BITS_PER_PKEY)
+
+static inline bool pkey_allows_readwrite(int pkey)
+{
+	int pkey_shift = pkeyshift(pkey);
+
+	if (!(read_uamor() & (0x3UL << pkey_shift)))
+		return true;
+
+	return !(read_amr() & ((AMR_AD_BIT|AMR_WD_BIT) << pkey_shift));
+}
 
 /*
  * set the access right in AMR IAMR and UAMOR register
@@ -68,7 +79,60 @@ int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 
 int __execute_only_pkey(struct mm_struct *mm)
 {
-	return -1;
+	bool need_to_set_mm_pkey = false;
+	int execute_only_pkey = mm->context.execute_only_pkey;
+	int ret;
+
+	/* Do we need to assign a pkey for mm's execute-only maps? */
+	if (execute_only_pkey == -1) {
+		/* Go allocate one to use, which might fail */
+		execute_only_pkey = mm_pkey_alloc(mm);
+		if (execute_only_pkey < 0)
+			return -1;
+		need_to_set_mm_pkey = true;
+	}
+
+	/*
+	 * We do not want to go through the relatively costly
+	 * dance to set AMR if we do not need to.  Check it
+	 * first and assume that if the execute-only pkey is
+	 * readwrite-disabled than we do not have to set it
+	 * ourselves.
+	 */
+	if (!need_to_set_mm_pkey &&
+	    !pkey_allows_readwrite(execute_only_pkey))
+		return execute_only_pkey;
+
+	/*
+	 * Set up AMR so that it denies access for everything
+	 * other than execution.
+	 */
+	ret = __arch_set_user_pkey_access(current, execute_only_pkey,
+			(PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
+	/*
+	 * If the AMR-set operation failed somehow, just return
+	 * 0 and effectively disable execute-only support.
+	 */
+	if (ret) {
+		mm_set_pkey_free(mm, execute_only_pkey);
+		return -1;
+	}
+
+	/* We got one, store it and use it from here on out */
+	if (need_to_set_mm_pkey)
+		mm->context.execute_only_pkey = execute_only_pkey;
+	return execute_only_pkey;
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
 }
 
 /*
@@ -84,5 +148,30 @@ int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot,
 	if (pkey != -1)
 		return pkey;
 
-	return 0;
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
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
