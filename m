Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id BE2CE6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 16:28:06 -0400 (EDT)
Date: Mon, 05 Aug 2013 16:27:45 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1375734465-scgr8g4z-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1375302249-scfvftrh-mutt-n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 9/8] hugetlb: add pmd_huge_support() to migrate only pmd-based
 hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch is motivated by the discussion with Aneesh about "extend
hugepage migration" patchset.
  http://thread.gmane.org/gmane.linux.kernel.mm/103933/focus=104391
I'll append this to the patchset in the next post, but before that
I want this patch to be reviewed (I don't want to repeat posting the
whole set for just minor changes.)

Any comments?

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Mon, 5 Aug 2013 13:33:02 -0400
Subject: [PATCH] hugetlb: add pmd_huge_support() to migrate only pmd-based
 hugepage

Currently hugepage migration works well only for pmd-based hugepages,
because core routines of hugepage migration use pmd specific internal
functions like huge_pte_offset(). So we should not enable the migration
of other levels of hugepages until we are ready for it.

Some users of hugepage migration (mbind, move_pages, and migrate_pages)
do page table walk and check pud/pmd_huge() there, so they are safe.
But the other users (softoffline and memory hotremove) don't do this,
so they can try to migrate unexpected types of hugepages.

To prevent this, we introduce an architecture dependent check of whether
hugepage are implemented on a pmd basis or not. It returns 0 if pmd_huge()
returns always 0, and 1 otherwise.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/arm/mm/hugetlbpage.c     |  5 +++++
 arch/arm64/mm/hugetlbpage.c   |  5 +++++
 arch/ia64/mm/hugetlbpage.c    |  5 +++++
 arch/metag/mm/hugetlbpage.c   |  5 +++++
 arch/mips/mm/hugetlbpage.c    |  5 +++++
 arch/powerpc/mm/hugetlbpage.c | 10 ++++++++++
 arch/s390/mm/hugetlbpage.c    |  5 +++++
 arch/sh/mm/hugetlbpage.c      |  5 +++++
 arch/sparc/mm/hugetlbpage.c   |  5 +++++
 arch/tile/mm/hugetlbpage.c    |  5 +++++
 arch/x86/mm/hugetlbpage.c     |  8 ++++++++
 include/linux/hugetlb.h       |  2 ++
 mm/migrate.c                  | 11 +++++++++++
 13 files changed, 76 insertions(+)

diff --git a/arch/arm/mm/hugetlbpage.c b/arch/arm/mm/hugetlbpage.c
index 3d1e4a2..3f3b6a7 100644
--- a/arch/arm/mm/hugetlbpage.c
+++ b/arch/arm/mm/hugetlbpage.c
@@ -99,3 +99,8 @@ int pmd_huge(pmd_t pmd)
 {
 	return pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT);
 }
+
+int pmd_huge_support(void)
+{
+	return 1;
+}
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 2fc8258..5e9aec3 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -54,6 +54,11 @@ int pud_huge(pud_t pud)
 	return !(pud_val(pud) & PUD_TABLE_BIT);
 }
 
+int pmd_huge_support(void)
+{
+	return 1;
+}
+
 static __init int setup_hugepagesz(char *opt)
 {
 	unsigned long ps = memparse(opt, &opt);
diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
index 76069c1..68232db 100644
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -114,6 +114,11 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
+int pmd_huge_support(void)
+{
+	return 0;
+}
+
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd, int write)
 {
diff --git a/arch/metag/mm/hugetlbpage.c b/arch/metag/mm/hugetlbpage.c
index 3c52fa6..0424315 100644
--- a/arch/metag/mm/hugetlbpage.c
+++ b/arch/metag/mm/hugetlbpage.c
@@ -110,6 +110,11 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
+int pmd_huge_support(void)
+{
+	return 1;
+}
+
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmd, int write)
 {
diff --git a/arch/mips/mm/hugetlbpage.c b/arch/mips/mm/hugetlbpage.c
index a7fee0d..01fda44 100644
--- a/arch/mips/mm/hugetlbpage.c
+++ b/arch/mips/mm/hugetlbpage.c
@@ -85,6 +85,11 @@ int pud_huge(pud_t pud)
 	return (pud_val(pud) & _PAGE_HUGE) != 0;
 }
 
+int pmd_huge_support(void)
+{
+	return 1;
+}
+
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd, int write)
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 834ca8e..d67db4b 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -86,6 +86,11 @@ int pgd_huge(pgd_t pgd)
 	 */
 	return ((pgd_val(pgd) & 0x3) != 0x0);
 }
+
+int pmd_huge_support(void)
+{
+	return 1;
+}
 #else
 int pmd_huge(pmd_t pmd)
 {
@@ -101,6 +106,11 @@ int pgd_huge(pgd_t pgd)
 {
 	return 0;
 }
+
+int pmd_huge_support(void)
+{
+	return 0;
+}
 #endif
 
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index 121089d..951ee25 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -117,6 +117,11 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
+int pmd_huge_support(void)
+{
+	return 1;
+}
+
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmdp, int write)
 {
diff --git a/arch/sh/mm/hugetlbpage.c b/arch/sh/mm/hugetlbpage.c
index d776234..0d676a4 100644
--- a/arch/sh/mm/hugetlbpage.c
+++ b/arch/sh/mm/hugetlbpage.c
@@ -83,6 +83,11 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
+int pmd_huge_support(void)
+{
+	return 0;
+}
+
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmd, int write)
 {
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index d2b5944..9639964 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -234,6 +234,11 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
+int pmd_huge_support(void)
+{
+	return 0;
+}
+
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmd, int write)
 {
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index 650ccff..0ac3599 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -198,6 +198,11 @@ int pud_huge(pud_t pud)
 	return !!(pud_val(pud) & _PAGE_HUGE_PAGE);
 }
 
+int pmd_huge_support(void)
+{
+	return 1;
+}
+
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmd, int write)
 {
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 7e73e8c..9d980d8 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -59,6 +59,10 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 	return NULL;
 }
 
+int pmd_huge_support(void)
+{
+	return 0;
+}
 #else
 
 struct page *
@@ -77,6 +81,10 @@ int pud_huge(pud_t pud)
 	return !!(pud_val(pud) & _PAGE_PSE);
 }
 
+int pmd_huge_support(void)
+{
+	return 1;
+}
 #endif
 
 /* x86_64 also uses this file */
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 2e02c4e..115b553 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -94,6 +94,7 @@ struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
 				pud_t *pud, int write);
 int pmd_huge(pmd_t pmd);
 int pud_huge(pud_t pmd);
+int pmd_huge_support(void);
 unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot);
 
@@ -128,6 +129,7 @@ static inline void hugetlb_show_meminfo(void)
 #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
 #define pmd_huge(x)	0
 #define pud_huge(x)	0
+#define pmd_huge_support()	0
 #define is_hugepage_only_range(mm, addr, len)	0
 #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
 #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
diff --git a/mm/migrate.c b/mm/migrate.c
index d313737..7082e30 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -949,6 +949,17 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	struct page *new_hpage = get_new_page(hpage, private, &result);
 	struct anon_vma *anon_vma = NULL;
 
+	/*
+	 * This restriction ensures that only pmd-based hugepages can migrate,
+	 * because migration of other types of hugepages are not completely
+	 * implemented nor tested. Some callers of hugepage migration like
+	 * soft offline and memory hotremove don't walk through page tables
+	 * before kicking migration, so we need this check to prevent hugepage
+	 * migration in the architectures with non-pmd-based hugepage.
+	 */
+	if (!pmd_huge_support())
+		return -ENOSYS;
+
 	if (!new_hpage)
 		return -ENOMEM;
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
