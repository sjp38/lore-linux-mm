Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE86800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:05:01 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f10so2122057yha.7
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:05:01 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id n10si8484683yhn.0.2014.11.06.23.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 23:05:00 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v7 06/13] pagemap: use walk->vma instead of calling
 find_vma()
Date: Fri, 7 Nov 2014 07:01:58 +0000
Message-ID: <1415343692-6314-7-git-send-email-n-horiguchi@ah.jp.nec.com>
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

Page table walker has the information of the current vma in mm_walk,
so we don't have to call find_vma() in each pagemap_(pte|hugetlb)_range()
call any longer. Currently pagemap_pte_range() does vma loop itself, so
this patch reduces many lines of code.

NULL-vma check is omitted because we assume that we never run these
callbacks on any address outside vma. And even if it were broken, NULL
pointer dereference would be detected, so we can get enough information
for debugging.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v7:
- remove while-loop in pagemap_pte_range() (thanks to Peter Feiner)
- remove Kirill's Ack because this patch has non-minor change since v6
---
 fs/proc/task_mmu.c | 68 +++++++++++++-------------------------------------=
----
 1 file changed, 16 insertions(+), 52 deletions(-)

diff --git mmotm-2014-11-05-16-01.orig/fs/proc/task_mmu.c mmotm-2014-11-05-=
16-01/fs/proc/task_mmu.c
index 9aaab24677ae..f997734d2b4b 100644
--- mmotm-2014-11-05-16-01.orig/fs/proc/task_mmu.c
+++ mmotm-2014-11-05-16-01/fs/proc/task_mmu.c
@@ -1054,15 +1054,13 @@ static inline void thp_pmd_to_pagemap_entry(pagemap=
_entry_t *pme, struct pagemap
 static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long=
 end,
 			     struct mm_walk *walk)
 {
-	struct vm_area_struct *vma;
+	struct vm_area_struct *vma =3D walk->vma;
 	struct pagemapread *pm =3D walk->private;
 	spinlock_t *ptl;
 	pte_t *pte;
 	int err =3D 0;
=20
-	/* find the first VMA at or above 'addr' */
-	vma =3D find_vma(walk->mm, addr);
-	if (vma && pmd_trans_huge_lock(pmd, vma, &ptl) =3D=3D 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) =3D=3D 1) {
 		int pmd_flags2;
=20
 		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
@@ -1088,50 +1086,19 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned l=
ong addr, unsigned long end,
 	if (pmd_trans_unstable(pmd))
 		return 0;
=20
-	while (1) {
-		/* End of address space hole, which we mark as non-present. */
-		unsigned long hole_end;
-
-		if (vma)
-			hole_end =3D min(end, vma->vm_start);
-		else
-			hole_end =3D end;
-
-		for (; addr < hole_end; addr +=3D PAGE_SIZE) {
-			pagemap_entry_t pme =3D make_pme(PM_NOT_PRESENT(pm->v2));
-
-			err =3D add_to_pagemap(addr, &pme, pm);
-			if (err)
-				return err;
-		}
-
-		if (!vma || vma->vm_start >=3D end)
-			break;
-		/*
-		 * We can't possibly be in a hugetlb VMA. In general,
-		 * for a mm_walk with a pmd_entry and a hugetlb_entry,
-		 * the pmd_entry can only be called on addresses in a
-		 * hugetlb if the walk starts in a non-hugetlb VMA and
-		 * spans a hugepage VMA. Since pagemap_read walks are
-		 * PMD-sized and PMD-aligned, this will never be true.
-		 */
-		BUG_ON(is_vm_hugetlb_page(vma));
-
-		/* Addresses in the VMA. */
-		for (; addr < min(end, vma->vm_end); addr +=3D PAGE_SIZE) {
-			pagemap_entry_t pme;
-			pte =3D pte_offset_map(pmd, addr);
-			pte_to_pagemap_entry(&pme, pm, vma, addr, *pte);
-			pte_unmap(pte);
-			err =3D add_to_pagemap(addr, &pme, pm);
-			if (err)
-				return err;
-		}
-
-		if (addr =3D=3D end)
-			break;
+	/*
+	 * We can assume that @vma always points to a valid one and @end never
+	 * goes beyond vma->vm_end.
+	 */
+	for (; addr < end; addr +=3D PAGE_SIZE) {
+		pagemap_entry_t pme;
=20
-		vma =3D find_vma(walk->mm, addr);
+		pte =3D pte_offset_map(pmd, addr);
+		pte_to_pagemap_entry(&pme, pm, vma, addr, *pte);
+		pte_unmap(pte);
+		err =3D add_to_pagemap(addr, &pme, pm);
+		if (err)
+			return err;
 	}
=20
 	cond_resched();
@@ -1158,15 +1125,12 @@ static int pagemap_hugetlb_range(pte_t *pte, unsign=
ed long hmask,
 				 struct mm_walk *walk)
 {
 	struct pagemapread *pm =3D walk->private;
-	struct vm_area_struct *vma;
+	struct vm_area_struct *vma =3D walk->vma;
 	int err =3D 0;
 	int flags2;
 	pagemap_entry_t pme;
=20
-	vma =3D find_vma(walk->mm, addr);
-	WARN_ON_ONCE(!vma);
-
-	if (vma && (vma->vm_flags & VM_SOFTDIRTY))
+	if (vma->vm_flags & VM_SOFTDIRTY)
 		flags2 =3D __PM_SOFT_DIRTY;
 	else
 		flags2 =3D 0;
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
