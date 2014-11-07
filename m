Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 10182800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:05:47 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id a13so12257550igq.11
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:05:46 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id ie20si952154igb.24.2014.11.06.23.05.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 23:05:45 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v7 13/13] mincore: apply page table walker on
 do_mincore()
Date: Fri, 7 Nov 2014 07:02:06 +0000
Message-ID: <1415343692-6314-14-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1415343692-6314-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1415343692-6314-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Feiner <pfeiner@google.com>, Jerome Marchand <jmarchan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch makes do_mincore() use walk_page_vma(), which reduces many lines
of code by using common page table walk code.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v5:
- fix buffer overflow

ChangeLog v4:
- remove redundant vma

ChangeLog v3:
- add NULL vma check in mincore_unmapped_range()
- don't use pte_entry()

ChangeLog v2:
- change type of args of callbacks to void *
- move definition of mincore_walk to the start of the function to fix compi=
ler
  warning
---
 mm/huge_memory.c |  20 -------
 mm/mincore.c     | 169 +++++++++++++++++++--------------------------------=
----
 2 files changed, 59 insertions(+), 130 deletions(-)

diff --git mmotm-2014-11-05-16-01.orig/mm/huge_memory.c mmotm-2014-11-05-16=
-01/mm/huge_memory.c
index ff1ecea8c0d7..a81a0b917068 100644
--- mmotm-2014-11-05-16-01.orig/mm/huge_memory.c
+++ mmotm-2014-11-05-16-01/mm/huge_memory.c
@@ -1422,26 +1422,6 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_a=
rea_struct *vma,
 	return ret;
 }
=20
-int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long addr, unsigned long end,
-		unsigned char *vec)
-{
-	spinlock_t *ptl;
-	int ret =3D 0;
-
-	if (__pmd_trans_huge_lock(pmd, vma, &ptl) =3D=3D 1) {
-		/*
-		 * All logical pages in the range are present
-		 * if backed by a huge page.
-		 */
-		spin_unlock(ptl);
-		memset(vec, 1, (end - addr) >> PAGE_SHIFT);
-		ret =3D 1;
-	}
-
-	return ret;
-}
-
 int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_v=
ma,
 		  unsigned long old_addr,
 		  unsigned long new_addr, unsigned long old_end,
diff --git mmotm-2014-11-05-16-01.orig/mm/mincore.c mmotm-2014-11-05-16-01/=
mm/mincore.c
index 725c80961048..0e548fbce19e 100644
--- mmotm-2014-11-05-16-01.orig/mm/mincore.c
+++ mmotm-2014-11-05-16-01/mm/mincore.c
@@ -19,38 +19,26 @@
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
=20
-static void mincore_hugetlb_page_range(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end,
-				unsigned char *vec)
+static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long =
addr,
+			unsigned long end, struct mm_walk *walk)
 {
+	int err =3D 0;
 #ifdef CONFIG_HUGETLB_PAGE
-	struct hstate *h;
+	unsigned char present;
+	unsigned char *vec =3D walk->private;
=20
-	h =3D hstate_vma(vma);
-	while (1) {
-		unsigned char present;
-		pte_t *ptep;
-		/*
-		 * Huge pages are always in RAM for now, but
-		 * theoretically it needs to be checked.
-		 */
-		ptep =3D huge_pte_offset(current->mm,
-				       addr & huge_page_mask(h));
-		present =3D ptep && !huge_pte_none(huge_ptep_get(ptep));
-		while (1) {
-			*vec =3D present;
-			vec++;
-			addr +=3D PAGE_SIZE;
-			if (addr =3D=3D end)
-				return;
-			/* check hugepage border */
-			if (!(addr & ~huge_page_mask(h)))
-				break;
-		}
-	}
+	/*
+	 * Hugepages under user process are always in RAM and never
+	 * swapped out, but theoretically it needs to be checked.
+	 */
+	present =3D pte && !huge_pte_none(huge_ptep_get(pte));
+	for (; addr !=3D end; vec++, addr +=3D PAGE_SIZE)
+		*vec =3D present;
+	walk->private =3D vec;
 #else
 	BUG();
 #endif
+	return err;
 }
=20
 /*
@@ -94,14 +82,15 @@ static unsigned char mincore_page(struct address_space =
*mapping, pgoff_t pgoff)
 	return present;
 }
=20
-static void mincore_unmapped_range(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end,
-				unsigned char *vec)
+static int mincore_unmapped_range(unsigned long addr, unsigned long end,
+				   struct mm_walk *walk)
 {
+	struct vm_area_struct *vma =3D walk->vma;
+	unsigned char *vec =3D walk->private;
 	unsigned long nr =3D (end - addr) >> PAGE_SHIFT;
 	int i;
=20
-	if (vma->vm_file) {
+	if (vma && vma->vm_file) {
 		pgoff_t pgoff;
=20
 		pgoff =3D linear_page_index(vma, addr);
@@ -111,25 +100,40 @@ static void mincore_unmapped_range(struct vm_area_str=
uct *vma,
 		for (i =3D 0; i < nr; i++)
 			vec[i] =3D 0;
 	}
+	walk->private +=3D nr;
+	return 0;
 }
=20
-static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-			unsigned long addr, unsigned long end,
-			unsigned char *vec)
+static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long=
 end,
+			struct mm_walk *walk)
 {
-	unsigned long next;
 	spinlock_t *ptl;
+	struct vm_area_struct *vma =3D walk->vma;
 	pte_t *ptep;
=20
-	ptep =3D pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	do {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) =3D=3D 1) {
+		memset(walk->private, 1, (end - addr) >> PAGE_SHIFT);
+		walk->private +=3D (end - addr) >> PAGE_SHIFT;
+		spin_unlock(ptl);
+		return 0;
+	}
+
+	if (pmd_trans_unstable(pmd)) {
+		mincore_unmapped_range(addr, end, walk);
+		return 0;
+	}
+
+	ptep =3D pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	for (; addr !=3D end; ptep++, addr +=3D PAGE_SIZE) {
 		pte_t pte =3D *ptep;
 		pgoff_t pgoff;
+		unsigned char *vec =3D walk->private;
=20
-		next =3D addr + PAGE_SIZE;
-		if (pte_none(pte))
-			mincore_unmapped_range(vma, addr, next, vec);
-		else if (pte_present(pte))
+		if (pte_none(pte)) {
+			mincore_unmapped_range(addr, addr + PAGE_SIZE, walk);
+			continue;
+		}
+		if (pte_present(pte))
 			*vec =3D 1;
 		else if (pte_file(pte)) {
 			pgoff =3D pte_to_pgoff(pte);
@@ -151,70 +155,11 @@ static void mincore_pte_range(struct vm_area_struct *=
vma, pmd_t *pmd,
 #endif
 			}
 		}
-		vec++;
-	} while (ptep++, addr =3D next, addr !=3D end);
+		walk->private++;
+	}
 	pte_unmap_unlock(ptep - 1, ptl);
-}
-
-static void mincore_pmd_range(struct vm_area_struct *vma, pud_t *pud,
-			unsigned long addr, unsigned long end,
-			unsigned char *vec)
-{
-	unsigned long next;
-	pmd_t *pmd;
-
-	pmd =3D pmd_offset(pud, addr);
-	do {
-		next =3D pmd_addr_end(addr, end);
-		if (pmd_trans_huge(*pmd)) {
-			if (mincore_huge_pmd(vma, pmd, addr, next, vec)) {
-				vec +=3D (next - addr) >> PAGE_SHIFT;
-				continue;
-			}
-			/* fall through */
-		}
-		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
-			mincore_unmapped_range(vma, addr, next, vec);
-		else
-			mincore_pte_range(vma, pmd, addr, next, vec);
-		vec +=3D (next - addr) >> PAGE_SHIFT;
-	} while (pmd++, addr =3D next, addr !=3D end);
-}
-
-static void mincore_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
-			unsigned long addr, unsigned long end,
-			unsigned char *vec)
-{
-	unsigned long next;
-	pud_t *pud;
-
-	pud =3D pud_offset(pgd, addr);
-	do {
-		next =3D pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			mincore_unmapped_range(vma, addr, next, vec);
-		else
-			mincore_pmd_range(vma, pud, addr, next, vec);
-		vec +=3D (next - addr) >> PAGE_SHIFT;
-	} while (pud++, addr =3D next, addr !=3D end);
-}
-
-static void mincore_page_range(struct vm_area_struct *vma,
-			unsigned long addr, unsigned long end,
-			unsigned char *vec)
-{
-	unsigned long next;
-	pgd_t *pgd;
-
-	pgd =3D pgd_offset(vma->vm_mm, addr);
-	do {
-		next =3D pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			mincore_unmapped_range(vma, addr, next, vec);
-		else
-			mincore_pud_range(vma, pgd, addr, next, vec);
-		vec +=3D (next - addr) >> PAGE_SHIFT;
-	} while (pgd++, addr =3D next, addr !=3D end);
+	cond_resched();
+	return 0;
 }
=20
 /*
@@ -226,18 +171,22 @@ static long do_mincore(unsigned long addr, unsigned l=
ong pages, unsigned char *v
 {
 	struct vm_area_struct *vma;
 	unsigned long end;
+	int err;
+	struct mm_walk mincore_walk =3D {
+		.pmd_entry =3D mincore_pte_range,
+		.pte_hole =3D mincore_unmapped_range,
+		.hugetlb_entry =3D mincore_hugetlb,
+		.private =3D vec,
+	};
=20
 	vma =3D find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
-
+	mincore_walk.mm =3D vma->vm_mm;
 	end =3D min(vma->vm_end, addr + (pages << PAGE_SHIFT));
-
-	if (is_vm_hugetlb_page(vma))
-		mincore_hugetlb_page_range(vma, addr, end, vec);
-	else
-		mincore_page_range(vma, addr, end, vec);
-
+	err =3D walk_page_range(addr, end, &mincore_walk);
+	if (err < 0)
+		return err;
 	return (end - addr) >> PAGE_SHIFT;
 }
=20
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
