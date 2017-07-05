Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E00F26B03EB
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:23:20 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k14so516877qkl.11
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:20 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id v123si23551qkc.115.2017.07.05.14.23.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:23:20 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id m54so195597qtb.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:19 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 21/38] powerpc: implementation for arch_override_mprotect_pkey()
Date: Wed,  5 Jul 2017 14:21:58 -0700
Message-Id: <1499289735-14220-22-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

arch independent code calls arch_override_mprotect_pkey()
to return a pkey that best matches the requested protection.

This patch provides the implementation.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/pkeys.h |   10 ++++++-
 arch/powerpc/mm/pkeys.c          |   47 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index f148e84..20846c2 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -13,6 +13,11 @@ static inline u64 pkey_to_vmflag_bits(u16 pkey)
 		((pkey & 0x10UL) ? VM_PKEY_BIT4 : 0x0UL));
 }
 
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	return (vma->vm_flags & ARCH_VM_PKEY_FLAGS) >> VM_PKEY_SHIFT;
+}
+
 #define arch_max_pkey()  32
 #define AMR_AD_BIT 0x1UL
 #define AMR_WD_BIT 0x2UL
@@ -102,11 +107,12 @@ static inline int execute_only_pkey(struct mm_struct *mm)
 	return __execute_only_pkey(mm);
 }
 
-
+extern int __arch_override_mprotect_pkey(struct vm_area_struct *vma,
+		int prot, int pkey);
 static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
 		int prot, int pkey)
 {
-	return 0;
+	return __arch_override_mprotect_pkey(vma, prot, pkey);
 }
 
 extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 6c90317..c60a045 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -123,3 +123,50 @@ int __execute_only_pkey(struct mm_struct *mm)
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
