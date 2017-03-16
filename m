Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 646A2831CC
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:28:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so96445800pgc.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:28:11 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g24si3998877pfd.250.2017.03.16.08.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:28:10 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/7] mm: Drop arch_pte_access_permitted() mmu hook
Date: Thu, 16 Mar 2017 18:26:49 +0300
Message-Id: <20170316152655.37789-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
References: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The only arch that defines it to something meaningful is x86.
But x86 doesn't use generic GUP_fast() implementation -- the only place
where the hook is called.

Let's drop it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/powerpc/include/asm/mmu_context.h   | 6 ------
 arch/s390/include/asm/mmu_context.h      | 6 ------
 arch/um/include/asm/mmu_context.h        | 6 ------
 arch/unicore32/include/asm/mmu_context.h | 6 ------
 arch/x86/include/asm/mmu_context.h       | 4 ----
 include/asm-generic/mm_hooks.h           | 6 ------
 mm/gup.c                                 | 3 ---
 7 files changed, 37 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index b9e3f0aca261..ecf9885ab660 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -163,11 +163,5 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	/* by default, allow everything */
 	return true;
 }
-
-static inline bool arch_pte_access_permitted(pte_t pte, bool write)
-{
-	/* by default, allow everything */
-	return true;
-}
 #endif /* __KERNEL__ */
 #endif /* __ASM_POWERPC_MMU_CONTEXT_H */
diff --git a/arch/s390/include/asm/mmu_context.h b/arch/s390/include/asm/mmu_context.h
index 6e31d87fb669..fa2bf69be182 100644
--- a/arch/s390/include/asm/mmu_context.h
+++ b/arch/s390/include/asm/mmu_context.h
@@ -156,10 +156,4 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	/* by default, allow everything */
 	return true;
 }
-
-static inline bool arch_pte_access_permitted(pte_t pte, bool write)
-{
-	/* by default, allow everything */
-	return true;
-}
 #endif /* __S390_MMU_CONTEXT_H */
diff --git a/arch/um/include/asm/mmu_context.h b/arch/um/include/asm/mmu_context.h
index 94ac2739918c..b668e351fd6c 100644
--- a/arch/um/include/asm/mmu_context.h
+++ b/arch/um/include/asm/mmu_context.h
@@ -37,12 +37,6 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	return true;
 }
 
-static inline bool arch_pte_access_permitted(pte_t pte, bool write)
-{
-	/* by default, allow everything */
-	return true;
-}
-
 /*
  * end asm-generic/mm_hooks.h functions
  */
diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
index 62dfc644c908..59b06b48f27d 100644
--- a/arch/unicore32/include/asm/mmu_context.h
+++ b/arch/unicore32/include/asm/mmu_context.h
@@ -103,10 +103,4 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	/* by default, allow everything */
 	return true;
 }
-
-static inline bool arch_pte_access_permitted(pte_t pte, bool write)
-{
-	/* by default, allow everything */
-	return true;
-}
 #endif
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 306c7e12af55..68b329d77b3a 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -268,8 +268,4 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	return __pkru_allows_pkey(vma_pkey(vma), write);
 }
 
-static inline bool arch_pte_access_permitted(pte_t pte, bool write)
-{
-	return __pkru_allows_pkey(pte_flags_pkey(pte_flags(pte)), write);
-}
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff --git a/include/asm-generic/mm_hooks.h b/include/asm-generic/mm_hooks.h
index cc5d9a1405df..41e5b6784b97 100644
--- a/include/asm-generic/mm_hooks.h
+++ b/include/asm-generic/mm_hooks.h
@@ -32,10 +32,4 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	/* by default, allow everything */
 	return true;
 }
-
-static inline bool arch_pte_access_permitted(pte_t pte, bool write)
-{
-	/* by default, allow everything */
-	return true;
-}
 #endif	/* _ASM_GENERIC_MM_HOOKS_H */
diff --git a/mm/gup.c b/mm/gup.c
index 04aa405350dc..3f2338ba3402 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1216,9 +1216,6 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			pte_protnone(pte) || (write && !pte_write(pte)))
 			goto pte_unmap;
 
-		if (!arch_pte_access_permitted(pte, write))
-			goto pte_unmap;
-
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
 		head = compound_head(page);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
