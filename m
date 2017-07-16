Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id D99D16B0650
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:58 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m54so57117750qtb.9
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:58 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id w32si11644198qtb.193.2017.07.15.20.58.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:58 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id q66so17063627qki.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:58 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 23/62] powerpc: implementation for arch_override_mprotect_pkey()
Date: Sat, 15 Jul 2017 20:56:25 -0700
Message-Id: <1500177424-13695-24-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

arch independent code calls arch_override_mprotect_pkey()
to return a pkey that best matches the requested protection.

This patch provides the implementation.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/mmu_context.h |    5 +++
 arch/powerpc/include/asm/pkeys.h       |   14 ++++++++-
 arch/powerpc/mm/pkeys.c                |   47 ++++++++++++++++++++++++++++++++
 3 files changed, 64 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 4705dab..7232484 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -185,6 +185,11 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 #ifndef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
 #define pkey_initialize()
 #define pkey_mm_init(mm)
+
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	return 0;
+}
 #endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
 
 #endif /* __KERNEL__ */
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index c92b049..94013af 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -29,6 +29,13 @@ static inline u64 pkey_to_vmflag_bits(u16 pkey)
 		((pkey & 0x10UL) ? VM_PKEY_BIT4 : 0x0UL));
 }
 
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	if (!pkey_inited)
+		return 0;
+	return (vma->vm_flags & ARCH_VM_PKEY_FLAGS) >> VM_PKEY_SHIFT;
+}
+
 #define arch_max_pkey()  32
 #define AMR_RD_BIT 0x1UL
 #define AMR_WR_BIT 0x2UL
@@ -138,11 +145,14 @@ static inline int execute_only_pkey(struct mm_struct *mm)
 	return __execute_only_pkey(mm);
 }
 
-
+extern int __arch_override_mprotect_pkey(struct vm_area_struct *vma,
+		int prot, int pkey);
 static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
 		int prot, int pkey)
 {
-	return 0;
+	if (!pkey_inited)
+		return 0;
+	return __arch_override_mprotect_pkey(vma, prot, pkey);
 }
 
 extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 34e8557..403f5ae 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -154,3 +154,50 @@ int __execute_only_pkey(struct mm_struct *mm)
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
+		int pkey)
+{
+	/*
+	 * Is this an mprotect_pkey() call?  If so, never
+	 * override the value that came from the user.
+	 */
+	if (pkey != -1)
+		return pkey;
+
+	/*
+	 * If the currently associated pkey is execute-only,
+	 * but the requested protection requires read or write,
+	 * move it back to the default pkey.
+	 */
+	if (vma_is_pkey_exec_only(vma) &&
+	    (prot & (PROT_READ|PROT_WRITE)))
+		return 0;
+
+	/*
+	 * the requested protection is execute-only. Hence
+	 * lets use a execute-only pkey.
+	 */
+	if (prot == PROT_EXEC) {
+		pkey = execute_only_pkey(vma->vm_mm);
+		if (pkey > 0)
+			return pkey;
+	}
+
+	/*
+	 * nothing to override.
+	 */
+	return vma_pkey(vma);
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
