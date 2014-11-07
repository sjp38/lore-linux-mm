Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 55734800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:05:40 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id t59so2165066yho.13
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:05:40 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id u130si8452226yke.40.2014.11.06.23.05.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 23:05:39 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v7 11/13] mempolicy: apply page table walker on
 queue_pages_range()
Date: Fri, 7 Nov 2014 07:02:03 +0000
Message-ID: <1415343692-6314-12-git-send-email-n-horiguchi@ah.jp.nec.com>
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

queue_pages_range() does page table walking in its own way now, but there
is some code duplicate. This patch applies page table walker to reduce
lines of code.

queue_pages_range() has to do some precheck to determine whether we really
walk over the vma or just skip it. Now we have test_walk() callback in
mm_walk for this purpose, so we can do this replacement cleanly.
queue_pages_test_walk() depends on not only the current vma but also the
previous one, so queue_pages->prev is introduced to remember it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v4:
- rebase to v3.16-rc3, where the return value of queue_pages_range()
  becomes 0 in success instead of the first found vma, and use -EFAILT
  instead of ERR_PTR() in failure.
---
 mm/mempolicy.c | 228 +++++++++++++++++++++++------------------------------=
----
 1 file changed, 92 insertions(+), 136 deletions(-)

diff --git mmotm-2014-11-05-16-01.orig/mm/mempolicy.c mmotm-2014-11-05-16-0=
1/mm/mempolicy.c
index e58725aff7e9..2c7c4e296386 100644
--- mmotm-2014-11-05-16-01.orig/mm/mempolicy.c
+++ mmotm-2014-11-05-16-01/mm/mempolicy.c
@@ -477,24 +477,34 @@ static const struct mempolicy_operations mpol_ops[MPO=
L_MAX] =3D {
 static void migrate_page_add(struct page *page, struct list_head *pagelist=
,
 				unsigned long flags);
=20
+struct queue_pages {
+	struct list_head *pagelist;
+	unsigned long flags;
+	nodemask_t *nmask;
+	struct vm_area_struct *prev;
+};
+
 /*
  * Scan through pages checking if pages follow certain conditions,
  * and move them to the pagelist if they do.
  */
-static int queue_pages_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
+static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
+			unsigned long end, struct mm_walk *walk)
 {
-	pte_t *orig_pte;
+	struct vm_area_struct *vma =3D walk->vma;
+	struct page *page;
+	struct queue_pages *qp =3D walk->private;
+	unsigned long flags =3D qp->flags;
+	int nid;
 	pte_t *pte;
 	spinlock_t *ptl;
=20
-	orig_pte =3D pte =3D pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	do {
-		struct page *page;
-		int nid;
+	split_huge_page_pmd(vma, addr, pmd);
+	if (pmd_trans_unstable(pmd))
+		return 0;
=20
+	pte =3D pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	for (; addr !=3D end; pte++, addr +=3D PAGE_SIZE) {
 		if (!pte_present(*pte))
 			continue;
 		page =3D vm_normal_page(vma, addr, *pte);
@@ -507,114 +517,46 @@ static int queue_pages_pte_range(struct vm_area_stru=
ct *vma, pmd_t *pmd,
 		if (PageReserved(page))
 			continue;
 		nid =3D page_to_nid(page);
-		if (node_isset(nid, *nodes) =3D=3D !!(flags & MPOL_MF_INVERT))
+		if (node_isset(nid, *qp->nmask) =3D=3D !!(flags & MPOL_MF_INVERT))
 			continue;
=20
 		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
-			migrate_page_add(page, private, flags);
-		else
-			break;
-	} while (pte++, addr +=3D PAGE_SIZE, addr !=3D end);
-	pte_unmap_unlock(orig_pte, ptl);
-	return addr !=3D end;
+			migrate_page_add(page, qp->pagelist, flags);
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+	return 0;
 }
=20
-static void queue_pages_hugetlb_pmd_range(struct vm_area_struct *vma,
-		pmd_t *pmd, const nodemask_t *nodes, unsigned long flags,
-				    void *private)
+static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
+			       unsigned long addr, unsigned long end,
+			       struct mm_walk *walk)
 {
 #ifdef CONFIG_HUGETLB_PAGE
+	struct queue_pages *qp =3D walk->private;
+	unsigned long flags =3D qp->flags;
 	int nid;
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t entry;
=20
-	ptl =3D huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
-	entry =3D huge_ptep_get((pte_t *)pmd);
+	ptl =3D huge_pte_lock(hstate_vma(walk->vma), walk->mm, pte);
+	entry =3D huge_ptep_get(pte);
 	if (!pte_present(entry))
 		goto unlock;
 	page =3D pte_page(entry);
 	nid =3D page_to_nid(page);
-	if (node_isset(nid, *nodes) =3D=3D !!(flags & MPOL_MF_INVERT))
+	if (node_isset(nid, *qp->nmask) =3D=3D !!(flags & MPOL_MF_INVERT))
 		goto unlock;
 	/* With MPOL_MF_MOVE, we migrate only unshared hugepage. */
 	if (flags & (MPOL_MF_MOVE_ALL) ||
 	    (flags & MPOL_MF_MOVE && page_mapcount(page) =3D=3D 1))
-		isolate_huge_page(page, private);
+		isolate_huge_page(page, qp->pagelist);
 unlock:
 	spin_unlock(ptl);
 #else
 	BUG();
 #endif
-}
-
-static inline int queue_pages_pmd_range(struct vm_area_struct *vma, pud_t =
*pud,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd =3D pmd_offset(pud, addr);
-	do {
-		next =3D pmd_addr_end(addr, end);
-		if (!pmd_present(*pmd))
-			continue;
-		if (pmd_huge(*pmd) && is_vm_hugetlb_page(vma)) {
-			queue_pages_hugetlb_pmd_range(vma, pmd, nodes,
-						flags, private);
-			continue;
-		}
-		split_huge_page_pmd(vma, addr, pmd);
-		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
-			continue;
-		if (queue_pages_pte_range(vma, pmd, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pmd++, addr =3D next, addr !=3D end);
-	return 0;
-}
-
-static inline int queue_pages_pud_range(struct vm_area_struct *vma, pgd_t =
*pgd,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud =3D pud_offset(pgd, addr);
-	do {
-		next =3D pud_addr_end(addr, end);
-		if (pud_huge(*pud) && is_vm_hugetlb_page(vma))
-			continue;
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		if (queue_pages_pmd_range(vma, pud, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pud++, addr =3D next, addr !=3D end);
-	return 0;
-}
-
-static inline int queue_pages_pgd_range(struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end,
-		const nodemask_t *nodes, unsigned long flags,
-		void *private)
-{
-	pgd_t *pgd;
-	unsigned long next;
-
-	pgd =3D pgd_offset(vma->vm_mm, addr);
-	do {
-		next =3D pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		if (queue_pages_pud_range(vma, pgd, addr, next, nodes,
-				    flags, private))
-			return -EIO;
-	} while (pgd++, addr =3D next, addr !=3D end);
 	return 0;
 }
=20
@@ -647,6 +589,46 @@ static unsigned long change_prot_numa(struct vm_area_s=
truct *vma,
 }
 #endif /* CONFIG_NUMA_BALANCING */
=20
+static int queue_pages_test_walk(unsigned long start, unsigned long end,
+				struct mm_walk *walk)
+{
+	struct vm_area_struct *vma =3D walk->vma;
+	struct queue_pages *qp =3D walk->private;
+	unsigned long endvma =3D vma->vm_end;
+	unsigned long flags =3D qp->flags;
+
+	if (endvma > end)
+		endvma =3D end;
+	if (vma->vm_start > start)
+		start =3D vma->vm_start;
+
+	if (!(flags & MPOL_MF_DISCONTIG_OK)) {
+		if (!vma->vm_next && vma->vm_end < end)
+			return -EFAULT;
+		if (qp->prev && qp->prev->vm_end < vma->vm_start)
+			return -EFAULT;
+	}
+
+	qp->prev =3D vma;
+
+	if (vma->vm_flags & VM_PFNMAP)
+		return 1;
+
+	if (flags & MPOL_MF_LAZY) {
+		/* Similar to task_numa_work, skip inaccessible VMAs */
+		if (vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
+			change_prot_numa(vma, start, endvma);
+		return 1;
+	}
+
+	if ((flags & MPOL_MF_STRICT) ||
+	    ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
+	     vma_migratable(vma)))
+		/* queue pages from current vma */
+		return 0;
+	return 1;
+}
+
 /*
  * Walk through page tables and collect pages to be migrated.
  *
@@ -656,50 +638,24 @@ static unsigned long change_prot_numa(struct vm_area_=
struct *vma,
  */
 static int
 queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long=
 end,
-		const nodemask_t *nodes, unsigned long flags, void *private)
-{
-	int err =3D 0;
-	struct vm_area_struct *vma, *prev;
-
-	vma =3D find_vma(mm, start);
-	if (!vma)
-		return -EFAULT;
-	prev =3D NULL;
-	for (; vma && vma->vm_start < end; vma =3D vma->vm_next) {
-		unsigned long endvma =3D vma->vm_end;
-
-		if (endvma > end)
-			endvma =3D end;
-		if (vma->vm_start > start)
-			start =3D vma->vm_start;
-
-		if (!(flags & MPOL_MF_DISCONTIG_OK)) {
-			if (!vma->vm_next && vma->vm_end < end)
-				return -EFAULT;
-			if (prev && prev->vm_end < vma->vm_start)
-				return -EFAULT;
-		}
-
-		if (flags & MPOL_MF_LAZY) {
-			/* Similar to task_numa_work, skip inaccessible VMAs */
-			if (vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
-				change_prot_numa(vma, start, endvma);
-			goto next;
-		}
-
-		if ((flags & MPOL_MF_STRICT) ||
-		     ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
-		      vma_migratable(vma))) {
-
-			err =3D queue_pages_pgd_range(vma, start, endvma, nodes,
-						flags, private);
-			if (err)
-				break;
-		}
-next:
-		prev =3D vma;
-	}
-	return err;
+		nodemask_t *nodes, unsigned long flags,
+		struct list_head *pagelist)
+{
+	struct queue_pages qp =3D {
+		.pagelist =3D pagelist,
+		.flags =3D flags,
+		.nmask =3D nodes,
+		.prev =3D NULL,
+	};
+	struct mm_walk queue_pages_walk =3D {
+		.hugetlb_entry =3D queue_pages_hugetlb,
+		.pmd_entry =3D queue_pages_pte_range,
+		.test_walk =3D queue_pages_test_walk,
+		.mm =3D mm,
+		.private =3D &qp,
+	};
+
+	return walk_page_range(start, end, &queue_pages_walk);
 }
=20
 /*
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
