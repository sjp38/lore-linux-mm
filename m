Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 44DF66B0294
	for <linux-mm@kvack.org>; Tue,  8 May 2018 11:00:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g1so24634870pfh.19
        for <linux-mm@kvack.org>; Tue, 08 May 2018 08:00:02 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id k189-v6si19544273pgc.388.2018.05.08.08.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 08:00:01 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 4/8] mm/pkeys, powerpc, x86: Provide an empty vma_pkey() in linux/pkeys.h
Date: Wed,  9 May 2018 00:59:44 +1000
Message-Id: <20180508145948.9492-5-mpe@ellerman.id.au>
In-Reply-To: <20180508145948.9492-1-mpe@ellerman.id.au>
References: <20180508145948.9492-1-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com

Consolidate the pkey handling by providing a common empty definition
of vma_pkey() in pkeys.h when CONFIG_ARCH_HAS_PKEYS=n.

This also removes another entanglement of pkeys.h and
asm/mmu_context.h.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 arch/powerpc/include/asm/mmu_context.h | 5 -----
 arch/x86/include/asm/mmu_context.h     | 5 -----
 include/linux/pkeys.h                  | 5 +++++
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 1835ca1505d6..896efa559996 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -250,11 +250,6 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 #define thread_pkey_regs_restore(new_thread, old_thread)
 #define thread_pkey_regs_init(thread)
 
-static inline int vma_pkey(struct vm_area_struct *vma)
-{
-	return 0;
-}
-
 static inline u64 pte_to_hpte_pkey_bits(u64 pteflags)
 {
 	return 0x0UL;
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 57e3785d0d26..3d748bdf44a7 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -296,11 +296,6 @@ static inline int vma_pkey(struct vm_area_struct *vma)
 
 	return (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
 }
-#else
-static inline int vma_pkey(struct vm_area_struct *vma)
-{
-	return 0;
-}
 #endif
 
 /*
diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
index ed06e1a67bfa..aad54663763b 100644
--- a/include/linux/pkeys.h
+++ b/include/linux/pkeys.h
@@ -13,6 +13,11 @@
 #define PKEY_DEDICATED_EXECUTE_ONLY 0
 #define ARCH_VM_PKEY_FLAGS 0
 
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	return 0;
+}
+
 static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
 {
 	return (pkey == 0);
-- 
2.14.1
