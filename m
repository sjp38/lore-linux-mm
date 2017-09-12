Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 345D86B0261
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 11:40:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q75so21152480pfl.1
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 08:40:00 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h9si7942823pgc.40.2017.09.12.08.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 08:39:58 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 08/11] sparc64: update pmdp_invalidate to return old pmd value
Date: Tue, 12 Sep 2017 18:39:38 +0300
Message-Id: <20170912153941.47012-9-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170912153941.47012-1-kirill.shutemov@linux.intel.com>
References: <20170912153941.47012-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <nitin.m.gupta@oracle.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

It's required to avoid loosing dirty and accessed bits.

Signed-off-by: Nitin Gupta <nitin.m.gupta@oracle.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/sparc/include/asm/pgtable_64.h |  2 +-
 arch/sparc/mm/tlb.c                 | 23 ++++++++++++++++++-----
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 4fefe3762083..83b06c98bb94 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -979,7 +979,7 @@ void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
 			  pmd_t *pmd);
 
 #define __HAVE_ARCH_PMDP_INVALIDATE
-extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
+extern pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 			    pmd_t *pmdp);
 
 #define __HAVE_ARCH_PGTABLE_DEPOSIT
diff --git a/arch/sparc/mm/tlb.c b/arch/sparc/mm/tlb.c
index ee8066c3d96c..d36c65fc55cf 100644
--- a/arch/sparc/mm/tlb.c
+++ b/arch/sparc/mm/tlb.c
@@ -218,17 +218,28 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 	}
 }
 
+static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmdp, pmd_t pmd)
+{
+	pmd_t old;
+
+	{
+		old = *pmdp;
+	} while (cmpxchg64(&pmdp->pmd, old.pmd, pmd.pmd) != old.pmd);
+
+	return old;
+}
+
 /*
  * This routine is only called when splitting a THP
  */
-void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
+pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 		     pmd_t *pmdp)
 {
-	pmd_t entry = *pmdp;
-
-	pmd_val(entry) &= ~_PAGE_VALID;
+	pmd_t old, entry;
 
-	set_pmd_at(vma->vm_mm, address, pmdp, entry);
+	entry = __pmd(pmd_val(*pmdp) & ~_PAGE_VALID);
+	old = pmdp_establish(vma, address, pmdp, entry);
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 
 	/*
@@ -239,6 +250,8 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 	if ((pmd_val(entry) & _PAGE_PMD_HUGE) &&
 	    !is_huge_zero_page(pmd_page(entry)))
 		(vma->vm_mm)->context.thp_pte_count--;
+
+	return old;
 }
 
 void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
