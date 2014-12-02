Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2F46B0070
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 03:33:12 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so12979764pab.12
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 00:33:11 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id gx7si32440176pac.213.2014.12.02.00.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 00:33:07 -0800 (PST)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id sB28X0iq025985
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 17:33:04 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v5 1/8] mm/hugetlb: reduce arch dependent code around
 follow_huge_*
Date: Tue, 2 Dec 2014 08:26:39 +0000
Message-ID: <1417508759-10848-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1417508759-10848-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1417508759-10848-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Currently we have many duplicates in definitions around follow_huge_addr(),
follow_huge_pmd(), and follow_huge_pud(), so this patch tries to remove the=
m.
The basic idea is to put the default implementation for these functions in
mm/hugetlb.c as weak symbols (regardless of CONFIG_ARCH_WANT_GENERAL_HUGETL=
B),
and to implement arch-specific code only when the arch needs it.

For follow_huge_addr(), only powerpc and ia64 have their own implementation=
,
and in all other architectures this function just returns ERR_PTR(-EINVAL).
So this patch sets returning ERR_PTR(-EINVAL) as default.

As for follow_huge_(pmd|pud)(), if (pmd|pud)_huge() is implemented to alway=
s
return 0 in your architecture (like in ia64 or sparc,) it's never called
(the callsite is optimized away) no matter how implemented it is.
So in such architectures, we don't need arch-specific implementation.

In some architecture (like mips, s390 and tile,) their current arch-specifi=
c
follow_huge_(pmd|pud)() are effectively identical with the common code,
so this patch lets these architecture use the common code.

One exception is metag, where pmd_huge() could return non-zero but it expec=
ts
follow_huge_pmd() to always return NULL. This means that we need arch-speci=
fic
implementation which returns NULL. This behavior looks strange to me (becau=
se
non-zero pmd_huge() implies that the architecture supports PMD-based hugepa=
ge,
so follow_huge_pmd() can/should return some relevant value,) but that's bey=
ond
this cleanup patch, so let's keep it.

Justification of non-trivial changes:
- in s390, follow_huge_pmd() checks !MACHINE_HAS_HPAGE at first, and this
  patch removes the check. This is OK because we can assume MACHINE_HAS_HPA=
GE
  is true when follow_huge_pmd() can be called (note that pmd_huge() has
  the same check and always returns 0 for !MACHINE_HAS_HPAGE.)
- in s390 and mips, we use HPAGE_MASK instead of PMD_MASK as done in common
  code. This patch forces these archs use PMD_MASK, but it's OK because
  they are identical in both archs.
  In s390, both of HPAGE_SHIFT and PMD_SHIFT are 20.
  In mips, HPAGE_SHIFT is defined as (PAGE_SHIFT + PAGE_SHIFT - 3) and
  PMD_SHIFT is define as (PAGE_SHIFT + PAGE_SHIFT + PTE_ORDER - 3), but
  PTE_ORDER is always 0, so these are identical.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Hugh Dickins <hughd@google.com>
Cc: James Hogan <james.hogan@imgtec.com>
---
 arch/arm/mm/hugetlbpage.c     |  6 ------
 arch/arm64/mm/hugetlbpage.c   |  6 ------
 arch/ia64/mm/hugetlbpage.c    |  6 ------
 arch/metag/mm/hugetlbpage.c   |  6 ------
 arch/mips/mm/hugetlbpage.c    | 18 ------------------
 arch/powerpc/mm/hugetlbpage.c |  8 ++++++++
 arch/s390/mm/hugetlbpage.c    | 20 --------------------
 arch/sh/mm/hugetlbpage.c      | 12 ------------
 arch/sparc/mm/hugetlbpage.c   | 12 ------------
 arch/tile/mm/hugetlbpage.c    | 28 ----------------------------
 arch/x86/mm/hugetlbpage.c     | 12 ------------
 mm/hugetlb.c                  | 30 +++++++++++++++---------------
 12 files changed, 23 insertions(+), 141 deletions(-)

diff --git mmotm-2014-11-26-15-45.orig/arch/arm/mm/hugetlbpage.c mmotm-2014=
-11-26-15-45/arch/arm/mm/hugetlbpage.c
index 66781bf34077..c72412415093 100644
--- mmotm-2014-11-26-15-45.orig/arch/arm/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/arm/mm/hugetlbpage.c
@@ -36,12 +36,6 @@
  * of type casting from pmd_t * to pte_t *.
  */
=20
-struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
-			      int write)
-{
-	return ERR_PTR(-EINVAL);
-}
-
 int pud_huge(pud_t pud)
 {
 	return 0;
diff --git mmotm-2014-11-26-15-45.orig/arch/arm64/mm/hugetlbpage.c mmotm-20=
14-11-26-15-45/arch/arm64/mm/hugetlbpage.c
index 023747bf4dd7..2de9d2e59d96 100644
--- mmotm-2014-11-26-15-45.orig/arch/arm64/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/arm64/mm/hugetlbpage.c
@@ -38,12 +38,6 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long=
 *addr, pte_t *ptep)
 }
 #endif
=20
-struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
-			      int write)
-{
-	return ERR_PTR(-EINVAL);
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	return !(pmd_val(pmd) & PMD_TABLE_BIT);
diff --git mmotm-2014-11-26-15-45.orig/arch/ia64/mm/hugetlbpage.c mmotm-201=
4-11-26-15-45/arch/ia64/mm/hugetlbpage.c
index 76069c18ee42..52b7604b5215 100644
--- mmotm-2014-11-26-15-45.orig/arch/ia64/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/ia64/mm/hugetlbpage.c
@@ -114,12 +114,6 @@ int pud_huge(pud_t pud)
 	return 0;
 }
=20
-struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd, i=
nt write)
-{
-	return NULL;
-}
-
 void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 			unsigned long addr, unsigned long end,
 			unsigned long floor, unsigned long ceiling)
diff --git mmotm-2014-11-26-15-45.orig/arch/metag/mm/hugetlbpage.c mmotm-20=
14-11-26-15-45/arch/metag/mm/hugetlbpage.c
index 3c32075d2945..7ca80ac42ed5 100644
--- mmotm-2014-11-26-15-45.orig/arch/metag/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/metag/mm/hugetlbpage.c
@@ -94,12 +94,6 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long=
 *addr, pte_t *ptep)
 	return 0;
 }
=20
-struct page *follow_huge_addr(struct mm_struct *mm,
-			      unsigned long address, int write)
-{
-	return ERR_PTR(-EINVAL);
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	return pmd_page_shift(pmd) > PAGE_SHIFT;
diff --git mmotm-2014-11-26-15-45.orig/arch/mips/mm/hugetlbpage.c mmotm-201=
4-11-26-15-45/arch/mips/mm/hugetlbpage.c
index 4ec8ee10d371..06e0f421b41b 100644
--- mmotm-2014-11-26-15-45.orig/arch/mips/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/mips/mm/hugetlbpage.c
@@ -68,12 +68,6 @@ int is_aligned_hugepage_range(unsigned long addr, unsign=
ed long len)
 	return 0;
 }
=20
-struct page *
-follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
-{
-	return ERR_PTR(-EINVAL);
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	return (pmd_val(pmd) & _PAGE_HUGE) !=3D 0;
@@ -83,15 +77,3 @@ int pud_huge(pud_t pud)
 {
 	return (pud_val(pud) & _PAGE_HUGE) !=3D 0;
 }
-
-struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
-{
-	struct page *page;
-
-	page =3D pte_page(*(pte_t *)pmd);
-	if (page)
-		page +=3D ((address & ~HPAGE_MASK) >> PAGE_SHIFT);
-	return page;
-}
diff --git mmotm-2014-11-26-15-45.orig/arch/powerpc/mm/hugetlbpage.c mmotm-=
2014-11-26-15-45/arch/powerpc/mm/hugetlbpage.c
index 7e70ae968e5f..9517a93a315c 100644
--- mmotm-2014-11-26-15-45.orig/arch/powerpc/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/powerpc/mm/hugetlbpage.c
@@ -706,6 +706,14 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long ad=
dress,
 	return NULL;
 }
=20
+struct page *
+follow_huge_pud(struct mm_struct *mm, unsigned long address,
+		pmd_t *pmd, int write)
+{
+	BUG();
+	return NULL;
+}
+
 static unsigned long hugepte_addr_end(unsigned long addr, unsigned long en=
d,
 				      unsigned long sz)
 {
diff --git mmotm-2014-11-26-15-45.orig/arch/s390/mm/hugetlbpage.c mmotm-201=
4-11-26-15-45/arch/s390/mm/hugetlbpage.c
index 389bc17934b7..348b3b9b6b59 100644
--- mmotm-2014-11-26-15-45.orig/arch/s390/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/s390/mm/hugetlbpage.c
@@ -192,12 +192,6 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned lo=
ng *addr, pte_t *ptep)
 	return 0;
 }
=20
-struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
-			      int write)
-{
-	return ERR_PTR(-EINVAL);
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	if (!MACHINE_HAS_HPAGE)
@@ -210,17 +204,3 @@ int pud_huge(pud_t pud)
 {
 	return 0;
 }
-
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmdp, int write)
-{
-	struct page *page;
-
-	if (!MACHINE_HAS_HPAGE)
-		return NULL;
-
-	page =3D pmd_page(*pmdp);
-	if (page)
-		page +=3D ((address & ~HPAGE_MASK) >> PAGE_SHIFT);
-	return page;
-}
diff --git mmotm-2014-11-26-15-45.orig/arch/sh/mm/hugetlbpage.c mmotm-2014-=
11-26-15-45/arch/sh/mm/hugetlbpage.c
index d7762349ea48..534bc978af8a 100644
--- mmotm-2014-11-26-15-45.orig/arch/sh/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/sh/mm/hugetlbpage.c
@@ -67,12 +67,6 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long=
 *addr, pte_t *ptep)
 	return 0;
 }
=20
-struct page *follow_huge_addr(struct mm_struct *mm,
-			      unsigned long address, int write)
-{
-	return ERR_PTR(-EINVAL);
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	return 0;
@@ -82,9 +76,3 @@ int pud_huge(pud_t pud)
 {
 	return 0;
 }
-
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
-{
-	return NULL;
-}
diff --git mmotm-2014-11-26-15-45.orig/arch/sparc/mm/hugetlbpage.c mmotm-20=
14-11-26-15-45/arch/sparc/mm/hugetlbpage.c
index d329537739c6..4242eab12e10 100644
--- mmotm-2014-11-26-15-45.orig/arch/sparc/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/sparc/mm/hugetlbpage.c
@@ -215,12 +215,6 @@ pte_t huge_ptep_get_and_clear(struct mm_struct *mm, un=
signed long addr,
 	return entry;
 }
=20
-struct page *follow_huge_addr(struct mm_struct *mm,
-			      unsigned long address, int write)
-{
-	return ERR_PTR(-EINVAL);
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	return 0;
@@ -230,9 +224,3 @@ int pud_huge(pud_t pud)
 {
 	return 0;
 }
-
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
-{
-	return NULL;
-}
diff --git mmotm-2014-11-26-15-45.orig/arch/tile/mm/hugetlbpage.c mmotm-201=
4-11-26-15-45/arch/tile/mm/hugetlbpage.c
index e514899e1100..8a00c7b7b862 100644
--- mmotm-2014-11-26-15-45.orig/arch/tile/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/tile/mm/hugetlbpage.c
@@ -150,12 +150,6 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned =
long addr)
 	return NULL;
 }
=20
-struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
-			      int write)
-{
-	return ERR_PTR(-EINVAL);
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	return !!(pmd_val(pmd) & _PAGE_HUGE_PAGE);
@@ -166,28 +160,6 @@ int pud_huge(pud_t pud)
 	return !!(pud_val(pud) & _PAGE_HUGE_PAGE);
 }
=20
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
-{
-	struct page *page;
-
-	page =3D pte_page(*(pte_t *)pmd);
-	if (page)
-		page +=3D ((address & ~PMD_MASK) >> PAGE_SHIFT);
-	return page;
-}
-
-struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
-			     pud_t *pud, int write)
-{
-	struct page *page;
-
-	page =3D pte_page(*(pte_t *)pud);
-	if (page)
-		page +=3D ((address & ~PUD_MASK) >> PAGE_SHIFT);
-	return page;
-}
-
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *pte=
p)
 {
 	return 0;
diff --git mmotm-2014-11-26-15-45.orig/arch/x86/mm/hugetlbpage.c mmotm-2014=
-11-26-15-45/arch/x86/mm/hugetlbpage.c
index 8b977ebf9388..03b8a7c11817 100644
--- mmotm-2014-11-26-15-45.orig/arch/x86/mm/hugetlbpage.c
+++ mmotm-2014-11-26-15-45/arch/x86/mm/hugetlbpage.c
@@ -52,20 +52,8 @@ int pud_huge(pud_t pud)
 	return 0;
 }
=20
-struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
-{
-	return NULL;
-}
 #else
=20
-struct page *
-follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
-{
-	return ERR_PTR(-EINVAL);
-}
-
 int pmd_huge(pmd_t pmd)
 {
 	return !!(pmd_val(pmd) & _PAGE_PSE);
diff --git mmotm-2014-11-26-15-45.orig/mm/hugetlb.c mmotm-2014-11-26-15-45/=
mm/hugetlb.c
index 85032de5e20f..6be4a690e554 100644
--- mmotm-2014-11-26-15-45.orig/mm/hugetlb.c
+++ mmotm-2014-11-26-15-45/mm/hugetlb.c
@@ -3660,7 +3660,20 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigne=
d long addr)
 	return (pte_t *) pmd;
 }
=20
-struct page *
+#endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
+
+/*
+ * These functions are overwritable if your architecture needs its own
+ * behavior.
+ */
+struct page * __weak
+follow_huge_addr(struct mm_struct *mm, unsigned long address,
+			      int write)
+{
+	return ERR_PTR(-EINVAL);
+}
+
+struct page * __weak
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd, int write)
 {
@@ -3672,7 +3685,7 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long a=
ddress,
 	return page;
 }
=20
-struct page *
+struct page * __weak
 follow_huge_pud(struct mm_struct *mm, unsigned long address,
 		pud_t *pud, int write)
 {
@@ -3684,19 +3697,6 @@ follow_huge_pud(struct mm_struct *mm, unsigned long =
address,
 	return page;
 }
=20
-#else /* !CONFIG_ARCH_WANT_GENERAL_HUGETLB */
-
-/* Can be overriden by architectures */
-struct page * __weak
-follow_huge_pud(struct mm_struct *mm, unsigned long address,
-	       pud_t *pud, int write)
-{
-	BUG();
-	return NULL;
-}
-
-#endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
-
 #ifdef CONFIG_MEMORY_FAILURE
=20
 /* Should be called in hugetlb_lock */
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
