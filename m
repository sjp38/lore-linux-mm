Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f47.google.com (mail-vn0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id BE03D6B0032
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 03:39:23 -0400 (EDT)
Received: by vnbg190 with SMTP id g190so448282vnb.8
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 00:39:23 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id f2si112205obw.49.2015.04.14.00.39.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Apr 2015 00:39:23 -0700 (PDT)
Message-ID: <552CC328.9050402@huawei.com>
Date: Tue, 14 Apr 2015 15:35:04 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/hugetlb: reduce arch dependent code about huge_pmd_unshare
References: <1428996566-86763-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1428996566-86763-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux@arm.linux.org.uk, catalin.marinas@arm.com, tony.luck@intel.com, james.hogan@imgtec.com, ralf@linux-mips.org, benh@kernel.crashing.org, schwidefsky@de.ibm.com, cmetcalf@ezchip.com, David Rientjes <rientjes@google.com>, James.Yang@freescale.com, aneesh.kumar@linux.vnet.ibm.com

Currently we have many duplicates in definitions of huge_pmd_unshare.
In all architectures this function just returns 0 when
CONFIG_ARCH_WANT_HUGE_PMD_SHARE is N.

This patch put the default implementation in mm/hugetlb.c and lets
these architecture use the common code.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 arch/arm/mm/hugetlbpage.c     | 5 -----
 arch/arm64/mm/hugetlbpage.c   | 7 -------
 arch/ia64/mm/hugetlbpage.c    | 5 -----
 arch/metag/mm/hugetlbpage.c   | 5 -----
 arch/mips/mm/hugetlbpage.c    | 5 -----
 arch/powerpc/mm/hugetlbpage.c | 5 -----
 arch/s390/mm/hugetlbpage.c    | 5 -----
 arch/sh/mm/hugetlbpage.c      | 5 -----
 arch/sparc/mm/hugetlbpage.c   | 5 -----
 arch/tile/mm/hugetlbpage.c    | 5 -----
 mm/hugetlb.c                  | 5 +++++
 11 files changed, 5 insertions(+), 52 deletions(-)

diff --git a/arch/arm/mm/hugetlbpage.c b/arch/arm/mm/hugetlbpage.c
index c724124..fcafb52 100644
--- a/arch/arm/mm/hugetlbpage.c
+++ b/arch/arm/mm/hugetlbpage.c
@@ -41,11 +41,6 @@ int pud_huge(pud_t pud)
 	return 0;
 }

-int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
-{
-	return 0;
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	return pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT);
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 2de9d2e..cccc4af 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -31,13 +31,6 @@
 #include <asm/tlbflush.h>
 #include <asm/pgalloc.h>

-#ifndef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
-int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
-{
-	return 0;
-}
-#endif
-
 int pmd_huge(pmd_t pmd)
 {
 	return !(pmd_val(pmd) & PMD_TABLE_BIT);
diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
index 52b7604..f50d4b3 100644
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -65,11 +65,6 @@ huge_pte_offset (struct mm_struct *mm, unsigned long addr)
 	return pte;
 }

-int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
-{
-	return 0;
-}
-
 #define mk_pte_huge(entry) { pte_val(entry) |= _PAGE_P; }

 /*
diff --git a/arch/metag/mm/hugetlbpage.c b/arch/metag/mm/hugetlbpage.c
index 7ca80ac..53f0f6c 100644
--- a/arch/metag/mm/hugetlbpage.c
+++ b/arch/metag/mm/hugetlbpage.c
@@ -89,11 +89,6 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 	return pte;
 }

-int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
-{
-	return 0;
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	return pmd_page_shift(pmd) > PAGE_SHIFT;
diff --git a/arch/mips/mm/hugetlbpage.c b/arch/mips/mm/hugetlbpage.c
index 06e0f42..74aa6f6 100644
--- a/arch/mips/mm/hugetlbpage.c
+++ b/arch/mips/mm/hugetlbpage.c
@@ -51,11 +51,6 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 	return (pte_t *) pmd;
 }

-int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
-{
-	return 0;
-}
-
 /*
  * This function checks for proper alignment of input addr and len parameters.
  */
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 7e408bf..dde6ff5 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -439,11 +439,6 @@ int alloc_bootmem_huge_page(struct hstate *hstate)
 }
 #endif

-int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
-{
-	return 0;
-}
-
 #ifdef CONFIG_PPC_FSL_BOOK3E
 #define HUGEPD_FREELIST_SIZE \
 	((PAGE_SIZE - sizeof(struct hugepd_freelist)) / sizeof(pte_t))
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index 210ffed..fa6e1bc 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -187,11 +187,6 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 	return (pte_t *) pmdp;
 }

-int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
-{
-	return 0;
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	if (!MACHINE_HAS_HPAGE)
diff --git a/arch/sh/mm/hugetlbpage.c b/arch/sh/mm/hugetlbpage.c
index 534bc97..6385f60 100644
--- a/arch/sh/mm/hugetlbpage.c
+++ b/arch/sh/mm/hugetlbpage.c
@@ -62,11 +62,6 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 	return pte;
 }

-int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
-{
-	return 0;
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	return 0;
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 4242eab..131eaf4 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -172,11 +172,6 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 	return pte;
 }

-int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
-{
-	return 0;
-}
-
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t entry)
 {
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index 8416240..c034dc3 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -160,11 +160,6 @@ int pud_huge(pud_t pud)
 	return !!(pud_val(pud) & _PAGE_HUGE_PAGE);
 }

-int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
-{
-	return 0;
-}
-
 #ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
 static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 		unsigned long addr, unsigned long len,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c41b2a0..df677142 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3659,6 +3659,11 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 {
 	return NULL;
 }
+
+int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
 #define want_pmd_share()	(0)
 #endif /* CONFIG_ARCH_WANT_HUGE_PMD_SHARE */

-- 
1.9.1


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
