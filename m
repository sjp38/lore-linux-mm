Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E57BC6B0294
	for <linux-mm@kvack.org>; Tue,  8 May 2018 11:00:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z1so8773453pfh.3
        for <linux-mm@kvack.org>; Tue, 08 May 2018 08:00:02 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id y26-v6si13074947pgv.202.2018.05.08.08.00.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 08:00:01 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 5/8] x86/pkeys: Move vma_pkey() into asm/pkeys.h
Date: Wed,  9 May 2018 00:59:45 +1000
Message-Id: <20180508145948.9492-6-mpe@ellerman.id.au>
In-Reply-To: <20180508145948.9492-1-mpe@ellerman.id.au>
References: <20180508145948.9492-1-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com

Move the last remaining pkey helper, vma_pkey() into asm/pkeys.h

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 arch/x86/include/asm/mmu_context.h | 10 ----------
 arch/x86/include/asm/pkeys.h       |  8 ++++++++
 include/linux/pkeys.h              |  2 +-
 3 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 3d748bdf44a7..59e1fadef401 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -288,16 +288,6 @@ static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
 		mpx_notify_unmap(mm, vma, start, end);
 }
 
-#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
-static inline int vma_pkey(struct vm_area_struct *vma)
-{
-	unsigned long vma_pkey_mask = VM_PKEY_BIT0 | VM_PKEY_BIT1 |
-				      VM_PKEY_BIT2 | VM_PKEY_BIT3;
-
-	return (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
-}
-#endif
-
 /*
  * We only want to enforce protection keys on the current process
  * because we effectively have no access to PKRU for other
diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
index a0ba1ffda0df..0e5f749158e4 100644
--- a/arch/x86/include/asm/pkeys.h
+++ b/arch/x86/include/asm/pkeys.h
@@ -106,4 +106,12 @@ extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
 extern void copy_init_pkru_to_fpregs(void);
 
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	unsigned long vma_pkey_mask = VM_PKEY_BIT0 | VM_PKEY_BIT1 |
+				      VM_PKEY_BIT2 | VM_PKEY_BIT3;
+
+	return (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
+}
+
 #endif /*_ASM_X86_PKEYS_H */
diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
index aad54663763b..946cb773b79f 100644
--- a/include/linux/pkeys.h
+++ b/include/linux/pkeys.h
@@ -2,7 +2,7 @@
 #ifndef _LINUX_PKEYS_H
 #define _LINUX_PKEYS_H
 
-#include <linux/mm_types.h>
+#include <linux/mm.h>
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
 #include <asm/pkeys.h>
-- 
2.14.1
