Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 7BDB66B0074
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:26:57 -0400 (EDT)
Date: Tue, 02 Oct 2012 18:26:55 -0400 (EDT)
Message-Id: <20121002.182655.1230531655546341426.davem@davemloft.net>
Subject: [PATCH 4/8] sparc64: Document PGD and PMD layout.
From: David Miller <davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org


We're going to be messing around with the PMD interpretation and
layout for the sake of transparent huge pages, so we better clearly
document what we're starting with.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/include/asm/pgtable_64.h |   16 ++++++++++++----
 arch/sparc/include/asm/tsb.h        |    8 ++++----
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 27293a3..e77f363 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -63,6 +63,14 @@
 #error Page table parameters do not cover virtual address space properly.
 #endif
 
+/* PMDs point to PTE tables which are 4K aligned.  */
+#define PMD_PADDR	_AC(0xfffffffe,UL)
+#define PMD_PADDR_SHIFT	_AC(11,UL)
+
+/* PGDs point to PMD tables which are 8K aligned.  */
+#define PGD_PADDR	_AC(0xfffffffc,UL)
+#define PGD_PADDR_SHIFT	_AC(11,UL)
+
 #ifndef __ASSEMBLY__
 
 #include <linux/sched.h>
@@ -601,14 +609,14 @@ static inline unsigned long pte_special(pte_t pte)
 }
 
 #define pmd_set(pmdp, ptep)	\
-	(pmd_val(*(pmdp)) = (__pa((unsigned long) (ptep)) >> 11UL))
+	(pmd_val(*(pmdp)) = (__pa((unsigned long) (ptep)) >> PMD_PADDR_SHIFT))
 #define pud_set(pudp, pmdp)	\
-	(pud_val(*(pudp)) = (__pa((unsigned long) (pmdp)) >> 11UL))
+	(pud_val(*(pudp)) = (__pa((unsigned long) (pmdp)) >> PGD_PADDR_SHIFT))
 #define __pmd_page(pmd)		\
-	((unsigned long) __va((((unsigned long)pmd_val(pmd))<<11UL)))
+	((unsigned long) __va((((unsigned long)pmd_val(pmd))<<PMD_PADDR_SHIFT)))
 #define pmd_page(pmd) 			virt_to_page((void *)__pmd_page(pmd))
 #define pud_page_vaddr(pud)		\
-	((unsigned long) __va((((unsigned long)pud_val(pud))<<11UL)))
+	((unsigned long) __va((((unsigned long)pud_val(pud))<<PGD_PADDR_SHIFT)))
 #define pud_page(pud) 			virt_to_page((void *)pud_page_vaddr(pud))
 #define pmd_none(pmd)			(!pmd_val(pmd))
 #define pmd_bad(pmd)			(0)
diff --git a/arch/sparc/include/asm/tsb.h b/arch/sparc/include/asm/tsb.h
index 6435924..ef8cd1a 100644
--- a/arch/sparc/include/asm/tsb.h
+++ b/arch/sparc/include/asm/tsb.h
@@ -147,13 +147,13 @@ extern struct tsb_phys_patch_entry __tsb_phys_patch, __tsb_phys_patch_end;
 	brz,pn		REG1, FAIL_LABEL; \
 	 sllx		VADDR, 64 - (PMD_SHIFT + PMD_BITS), REG2; \
 	srlx		REG2, 64 - PAGE_SHIFT, REG2; \
-	sllx		REG1, 11, REG1; \
+	sllx		REG1, PGD_PADDR_SHIFT, REG1; \
 	andn		REG2, 0x3, REG2; \
 	lduwa		[REG1 + REG2] ASI_PHYS_USE_EC, REG1; \
 	brz,pn		REG1, FAIL_LABEL; \
 	 sllx		VADDR, 64 - PMD_SHIFT, REG2; \
 	srlx		REG2, 64 - (PAGE_SHIFT - 1), REG2; \
-	sllx		REG1, 11, REG1; \
+	sllx		REG1, PMD_PADDR_SHIFT, REG1; \
 	andn		REG2, 0x7, REG2; \
 	add		REG1, REG2, REG1;
 
@@ -172,13 +172,13 @@ extern struct tsb_phys_patch_entry __tsb_phys_patch, __tsb_phys_patch_end;
 	brz,pn		REG1, FAIL_LABEL; \
 	 sllx		VADDR, 64 - (PMD_SHIFT + PMD_BITS), REG2; \
 	srlx		REG2, 64 - PAGE_SHIFT, REG2; \
-	sllx		REG1, 11, REG1; \
+	sllx		REG1, PGD_PADDR_SHIFT, REG1; \
 	andn		REG2, 0x3, REG2; \
 	lduwa		[REG1 + REG2] ASI_PHYS_USE_EC, REG1; \
 	brz,pn		REG1, FAIL_LABEL; \
 	 sllx		VADDR, 64 - PMD_SHIFT, REG2; \
 	srlx		REG2, 64 - (PAGE_SHIFT - 1), REG2; \
-	sllx		REG1, 11, REG1; \
+	sllx		REG1, PMD_PADDR_SHIFT, REG1; \
 	andn		REG2, 0x7, REG2; \
 	add		REG1, REG2, REG1;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
