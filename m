Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 7D0A86B0037
	for <linux-mm@kvack.org>; Thu, 23 May 2013 13:08:17 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id hi5so2224493wib.2
        for <linux-mm@kvack.org>; Thu, 23 May 2013 10:08:16 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH 03/11] mm: hugetlb: Copy general hugetlb code from x86 to mm.
Date: Thu, 23 May 2013 18:07:50 +0100
Message-Id: <1369328878-11706-4-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, patches@linaro.org, Steve Capper <steve.capper@linaro.org>

The huge_pte_alloc, huge_pte_offset and follow_huge_p[mu]d
functions in x86/mm/hugetlbpage.c do not rely on any architecture
specific knowledge other than the fact that pmds and puds can be
treated as huge ptes.

To allow other architectures to use this code (and reduce the need
for code duplication), this patch copies these functions into mm,
replaces the use of pud_large with pud_huge and provides a config
flag to activate them:
CONFIG_ARCH_WANT_GENERAL_HUGETLB

If CONFIG_ARCH_WANT_HUGE_PMD_SHARE is also active then the
huge_pmd_share code will be called by huge_pte_alloc (othewise we
call pmd_alloc and skip the sharing code).

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 mm/hugetlb.c | 97 ++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 88 insertions(+), 9 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b0bfb29..6321726 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2931,15 +2931,6 @@ out_mutex:
 	return ret;
 }
 
-/* Can be overriden by architectures */
-__attribute__((weak)) struct page *
-follow_huge_pud(struct mm_struct *mm, unsigned long address,
-	       pud_t *pud, int write)
-{
-	BUG();
-	return NULL;
-}
-
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 struct page **pages, struct vm_area_struct **vmas,
 			 unsigned long *position, unsigned long *nr_pages,
@@ -3289,8 +3280,96 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
 	*addr = ALIGN(*addr, HPAGE_SIZE * PTRS_PER_PTE) - HPAGE_SIZE;
 	return 1;
 }
+#define want_pmd_share()	(1)
+#else /* !CONFIG_ARCH_WANT_HUGE_PMD_SHARE */
+pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
+{
+	return NULL;
+}
+#define want_pmd_share()	(0)
 #endif /* CONFIG_ARCH_WANT_HUGE_PMD_SHARE */
 
+#ifdef CONFIG_ARCH_WANT_GENERAL_HUGETLB
+pte_t *huge_pte_alloc(struct mm_struct *mm,
+			unsigned long addr, unsigned long sz)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pte_t *pte = NULL;
+
+	pgd = pgd_offset(mm, addr);
+	pud = pud_alloc(mm, pgd, addr);
+	if (pud) {
+		if (sz == PUD_SIZE) {
+			pte = (pte_t *)pud;
+		} else {
+			BUG_ON(sz != PMD_SIZE);
+			if (want_pmd_share() && pud_none(*pud))
+				pte = huge_pmd_share(mm, addr, pud);
+			else
+				pte = (pte_t *)pmd_alloc(mm, pud, addr);
+		}
+	}
+	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
+
+	return pte;
+}
+
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd = NULL;
+
+	pgd = pgd_offset(mm, addr);
+	if (pgd_present(*pgd)) {
+		pud = pud_offset(pgd, addr);
+		if (pud_present(*pud)) {
+			if (pud_huge(*pud))
+				return (pte_t *)pud;
+			pmd = pmd_offset(pud, addr);
+		}
+	}
+	return (pte_t *) pmd;
+}
+
+struct page *
+follow_huge_pmd(struct mm_struct *mm, unsigned long address,
+		pmd_t *pmd, int write)
+{
+	struct page *page;
+
+	page = pte_page(*(pte_t *)pmd);
+	if (page)
+		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
+	return page;
+}
+
+struct page *
+follow_huge_pud(struct mm_struct *mm, unsigned long address,
+		pud_t *pud, int write)
+{
+	struct page *page;
+
+	page = pte_page(*(pte_t *)pud);
+	if (page)
+		page += ((address & ~PUD_MASK) >> PAGE_SHIFT);
+	return page;
+}
+
+#else /* !CONFIG_ARCH_WANT_GENERAL_HUGETLB */
+
+/* Can be overriden by architectures */
+__attribute__((weak)) struct page *
+follow_huge_pud(struct mm_struct *mm, unsigned long address,
+	       pud_t *pud, int write)
+{
+	BUG();
+	return NULL;
+}
+
+#endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
+
 #ifdef CONFIG_MEMORY_FAILURE
 
 /* Should be called in hugetlb_lock */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
