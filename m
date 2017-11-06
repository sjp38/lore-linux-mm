Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC238280246
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:58:56 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id p1so6531041qtg.18
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:58:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x35sor8111948qte.88.2017.11.06.00.58.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:58:56 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 13/51] powerpc: implementation for arch_override_mprotect_pkey()
Date: Mon,  6 Nov 2017 00:57:05 -0800
Message-Id: <1509958663-18737-14-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

arch independent code calls arch_override_mprotect_pkey()
to return a pkey that best matches the requested protection.

This patch provides the implementation.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/mmu_context.h |    5 ++++
 arch/powerpc/include/asm/pkeys.h       |   21 +++++++++++++++++-
 arch/powerpc/mm/pkeys.c                |   36 ++++++++++++++++++++++++++++++++
 3 files changed, 61 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 4eccc2f..a83d540 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -149,6 +149,11 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 #define thread_pkey_regs_save(thread)
 #define thread_pkey_regs_restore(new_thread, old_thread)
 #define thread_pkey_regs_init(thread)
+
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	return 0;
+}
 #endif /* CONFIG_PPC_MEM_KEYS */
 
 #endif /* __KERNEL__ */
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 1bd41ef..441bbf3 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -52,6 +52,13 @@ static inline u64 pkey_to_vmflag_bits(u16 pkey)
 	return (((u64)pkey << VM_PKEY_SHIFT) & ARCH_VM_PKEY_FLAGS);
 }
 
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	if (static_branch_likely(&pkey_disabled))
+		return 0;
+	return (vma->vm_flags & ARCH_VM_PKEY_FLAGS) >> VM_PKEY_SHIFT;
+}
+
 #define arch_max_pkey() pkeys_total
 
 #define pkey_alloc_mask(pkey) (0x1 << pkey)
@@ -148,10 +155,22 @@ static inline int execute_only_pkey(struct mm_struct *mm)
 	return __execute_only_pkey(mm);
 }
 
+extern int __arch_override_mprotect_pkey(struct vm_area_struct *vma,
+					 int prot, int pkey);
 static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
 					      int prot, int pkey)
 {
-	return 0;
+	if (static_branch_likely(&pkey_disabled))
+		return 0;
+
+	/*
+	 * Is this an mprotect_pkey() call? If so, never override the value that
+	 * came from the user.
+	 */
+	if (pkey != -1)
+		return pkey;
+
+	return __arch_override_mprotect_pkey(vma, prot, pkey);
 }
 
 extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 4d704ea..f1c6195 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -311,3 +311,39 @@ int __execute_only_pkey(struct mm_struct *mm)
 		mm->context.execute_only_pkey = execute_only_pkey;
 	return execute_only_pkey;
 }
+
+static inline bool vma_is_pkey_exec_only(struct vm_area_struct *vma)
+{
+	/* Do this check first since the vm_flags should be hot */
+	if ((vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC)) != VM_EXEC)
+		return false;
+
+	return (vma_pkey(vma) == vma->vm_mm->context.execute_only_pkey);
+}
+
+/*
+ * This should only be called for *plain* mprotect calls.
+ */
+int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot,
+				  int pkey)
+{
+	/*
+	 * If the currently associated pkey is execute-only, but the requested
+	 * protection requires read or write, move it back to the default pkey.
+	 */
+	if (vma_is_pkey_exec_only(vma) && (prot & (PROT_READ | PROT_WRITE)))
+		return 0;
+
+	/*
+	 * The requested protection is execute-only. Hence let's use an
+	 * execute-only pkey.
+	 */
+	if (prot == PROT_EXEC) {
+		pkey = execute_only_pkey(vma->vm_mm);
+		if (pkey > 0)
+			return pkey;
+	}
+
+	/* Nothing to override. */
+	return vma_pkey(vma);
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
