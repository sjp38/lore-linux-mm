Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id E69AD800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:05:14 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id 131so2022964ykp.38
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:05:13 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id h7si4640502yha.89.2014.11.06.23.05.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 23:05:12 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v7 02/13] pagewalk: improve vma handling
Date: Fri, 7 Nov 2014 07:01:55 +0000
Message-ID: <1415343692-6314-3-git-send-email-n-horiguchi@ah.jp.nec.com>
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

Current implementation of page table walker has a fundamental problem
in vma handling, which started when we tried to handle vma(VM_HUGETLB).
Because it's done in pgd loop, considering vma boundary makes code
complicated and bug-prone.

>From the users viewpoint, some user checks some vma-related condition to
determine whether the user really does page walk over the vma.

In order to solve these, this patch moves vma check outside pgd loop and
introduce a new callback ->test_walk().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
ChangeLog v4:
- avoid walking over the regions where vma is NULL if pte_hole() is
  undefined
- use vma->vm_next instead of repeating find_vma()
- use min() in walk_page_range "outside vma" branch
- fix return value of walk_hugetlb_range()

ChangeLog v3:
- drop walk->skip control
---
 include/linux/mm.h |  15 +++-
 mm/pagewalk.c      | 203 ++++++++++++++++++++++++++++++-------------------=
----
 2 files changed, 129 insertions(+), 89 deletions(-)

diff --git mmotm-2014-11-05-16-01.orig/include/linux/mm.h mmotm-2014-11-05-=
16-01/include/linux/mm.h
index ba964aa0282a..25a4cf75b575 100644
--- mmotm-2014-11-05-16-01.orig/include/linux/mm.h
+++ mmotm-2014-11-05-16-01/include/linux/mm.h
@@ -1127,10 +1127,16 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_a=
rea_struct *start_vma,
  * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
  * @pte_hole: if set, called for each hole at all levels
  * @hugetlb_entry: if set, called for each hugetlb entry
- *		   *Caution*: The caller must hold mmap_sem() if @hugetlb_entry
- * 			      is used.
+ * @test_walk: caller specific callback function to determine whether
+ *             we walk over the current vma or not. A positive returned
+ *             value means "do page table walk over the current vma,"
+ *             and a negative one means "abort current page table walk
+ *             right now." 0 means "skip the current vma."
+ * @mm:        mm_struct representing the target process of page table wal=
k
+ * @vma:       vma currently walked (NULL if walking outside vmas)
+ * @private:   private data for callbacks' usage
  *
- * (see walk_page_range for more details)
+ * (see the comment on walk_page_range() for more details)
  */
 struct mm_walk {
 	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
@@ -1142,7 +1148,10 @@ struct mm_walk {
 	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
 			     unsigned long addr, unsigned long next,
 			     struct mm_walk *walk);
+	int (*test_walk)(unsigned long addr, unsigned long next,
+			struct mm_walk *walk);
 	struct mm_struct *mm;
+	struct vm_area_struct *vma;
 	void *private;
 };
=20
diff --git mmotm-2014-11-05-16-01.orig/mm/pagewalk.c mmotm-2014-11-05-16-01=
/mm/pagewalk.c
index 5d41393260c8..d9cc3caae802 100644
--- mmotm-2014-11-05-16-01.orig/mm/pagewalk.c
+++ mmotm-2014-11-05-16-01/mm/pagewalk.c
@@ -59,7 +59,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr,=
 unsigned long end,
 			continue;
=20
 		split_huge_page_pmd_mm(walk->mm, addr, pmd);
-		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
+		if (pmd_trans_unstable(pmd))
 			goto again;
 		err =3D walk_pte_range(pmd, addr, next, walk);
 		if (err)
@@ -95,6 +95,32 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr=
, unsigned long end,
 	return err;
 }
=20
+static int walk_pgd_range(unsigned long addr, unsigned long end,
+			  struct mm_walk *walk)
+{
+	pgd_t *pgd;
+	unsigned long next;
+	int err =3D 0;
+
+	pgd =3D pgd_offset(walk->mm, addr);
+	do {
+		next =3D pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd)) {
+			if (walk->pte_hole)
+				err =3D walk->pte_hole(addr, next, walk);
+			if (err)
+				break;
+			continue;
+		}
+		if (walk->pmd_entry || walk->pte_entry)
+			err =3D walk_pud_range(pgd, addr, next, walk);
+		if (err)
+			break;
+	} while (pgd++, addr =3D next, addr !=3D end);
+
+	return err;
+}
+
 #ifdef CONFIG_HUGETLB_PAGE
 static unsigned long hugetlb_entry_end(struct hstate *h, unsigned long add=
r,
 				       unsigned long end)
@@ -103,10 +129,10 @@ static unsigned long hugetlb_entry_end(struct hstate =
*h, unsigned long addr,
 	return boundary < end ? boundary : end;
 }
=20
-static int walk_hugetlb_range(struct vm_area_struct *vma,
-			      unsigned long addr, unsigned long end,
+static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 			      struct mm_walk *walk)
 {
+	struct vm_area_struct *vma =3D walk->vma;
 	struct hstate *h =3D hstate_vma(vma);
 	unsigned long next;
 	unsigned long hmask =3D huge_page_mask(h);
@@ -119,15 +145,14 @@ static int walk_hugetlb_range(struct vm_area_struct *=
vma,
 		if (pte && walk->hugetlb_entry)
 			err =3D walk->hugetlb_entry(pte, hmask, addr, next, walk);
 		if (err)
-			return err;
+			break;
 	} while (addr =3D next, addr !=3D end);
=20
-	return 0;
+	return err;
 }
=20
 #else /* CONFIG_HUGETLB_PAGE */
-static int walk_hugetlb_range(struct vm_area_struct *vma,
-			      unsigned long addr, unsigned long end,
+static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 			      struct mm_walk *walk)
 {
 	return 0;
@@ -135,109 +160,115 @@ static int walk_hugetlb_range(struct vm_area_struct=
 *vma,
=20
 #endif /* CONFIG_HUGETLB_PAGE */
=20
+/*
+ * Decide whether we really walk over the current vma on [@start, @end)
+ * or skip it via the returned value. Return 0 if we do walk over the
+ * current vma, and return 1 if we skip the vma. Negative values means
+ * error, where we abort the current walk.
+ *
+ * Default check (only VM_PFNMAP check for now) is used when the caller
+ * doesn't define test_walk() callback.
+ */
+static int walk_page_test(unsigned long start, unsigned long end,
+			struct mm_walk *walk)
+{
+	struct vm_area_struct *vma =3D walk->vma;
=20
+	if (walk->test_walk)
+		return walk->test_walk(start, end, walk);
+
+	/*
+	 * Do not walk over vma(VM_PFNMAP), because we have no valid struct
+	 * page backing a VM_PFNMAP range. See also commit a9ff785e4437.
+	 */
+	if (vma->vm_flags & VM_PFNMAP)
+		return 1;
+	return 0;
+}
+
+static int __walk_page_range(unsigned long start, unsigned long end,
+			struct mm_walk *walk)
+{
+	int err =3D 0;
+	struct vm_area_struct *vma =3D walk->vma;
+
+	if (vma && is_vm_hugetlb_page(vma)) {
+		if (walk->hugetlb_entry)
+			err =3D walk_hugetlb_range(start, end, walk);
+	} else
+		err =3D walk_pgd_range(start, end, walk);
+
+	return err;
+}
=20
 /**
- * walk_page_range - walk a memory map's page tables with a callback
- * @addr: starting address
- * @end: ending address
- * @walk: set of callbacks to invoke for each level of the tree
- *
- * Recursively walk the page table for the memory area in a VMA,
- * calling supplied callbacks. Callbacks are called in-order (first
- * PGD, first PUD, first PMD, first PTE, second PTE... second PMD,
- * etc.). If lower-level callbacks are omitted, walking depth is reduced.
+ * walk_page_range - walk page table with caller specific callbacks
  *
- * Each callback receives an entry pointer and the start and end of the
- * associated range, and a copy of the original mm_walk for access to
- * the ->private or ->mm fields.
+ * Recursively walk the page table tree of the process represented by @wal=
k->mm
+ * within the virtual address range [@start, @end). During walking, we can=
 do
+ * some caller-specific works for each entry, by setting up pmd_entry(),
+ * pte_entry(), and/or hugetlb_entry(). If you don't set up for some of th=
ese
+ * callbacks, the associated entries/pages are just ignored.
+ * The return values of these callbacks are commonly defined like below:
+ *  - 0  : succeeded to handle the current entry, and if you don't reach t=
he
+ *         end address yet, continue to walk.
+ *  - >0 : succeeded to handle the current entry, and return to the caller
+ *         with caller specific value.
+ *  - <0 : failed to handle the current entry, and return to the caller
+ *         with error code.
  *
- * Usually no locks are taken, but splitting transparent huge page may
- * take page table lock. And the bottom level iterator will map PTE
- * directories from highmem if necessary.
+ * Before starting to walk page table, some callers want to check whether
+ * they really want to walk over the current vma, typically by checking
+ * its vm_flags. walk_page_test() and @walk->test_walk() are used for this
+ * purpose.
  *
- * If any callback returns a non-zero value, the walk is aborted and
- * the return value is propagated back to the caller. Otherwise 0 is retur=
ned.
+ * struct mm_walk keeps current values of some common data like vma and pm=
d,
+ * which are useful for the access from callbacks. If you want to pass som=
e
+ * caller-specific data to callbacks, @walk->private should be helpful.
  *
- * walk->mm->mmap_sem must be held for at least read if walk->hugetlb_entr=
y
- * is !NULL.
+ * Locking:
+ *   Callers of walk_page_range() and walk_page_vma() should hold
+ *   @walk->mm->mmap_sem, because these function traverse vma list and/or
+ *   access to vma's data.
  */
-int walk_page_range(unsigned long addr, unsigned long end,
+int walk_page_range(unsigned long start, unsigned long end,
 		    struct mm_walk *walk)
 {
-	pgd_t *pgd;
-	unsigned long next;
 	int err =3D 0;
+	unsigned long next;
+	struct vm_area_struct *vma;
=20
-	if (addr >=3D end)
-		return err;
+	if (start >=3D end)
+		return -EINVAL;
=20
 	if (!walk->mm)
 		return -EINVAL;
=20
 	VM_BUG_ON_MM(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
=20
-	pgd =3D pgd_offset(walk->mm, addr);
+	vma =3D find_vma(walk->mm, start);
 	do {
-		struct vm_area_struct *vma =3D NULL;
+		if (!vma) { /* after the last vma */
+			walk->vma =3D NULL;
+			next =3D end;
+		} else if (start < vma->vm_start) { /* outside vma */
+			walk->vma =3D NULL;
+			next =3D min(end, vma->vm_start);
+		} else { /* inside vma */
+			walk->vma =3D vma;
+			next =3D min(end, vma->vm_end);
+			vma =3D vma->vm_next;
=20
-		next =3D pgd_addr_end(addr, end);
-
-		/*
-		 * This function was not intended to be vma based.
-		 * But there are vma special cases to be handled:
-		 * - hugetlb vma's
-		 * - VM_PFNMAP vma's
-		 */
-		vma =3D find_vma(walk->mm, addr);
-		if (vma) {
-			/*
-			 * There are no page structures backing a VM_PFNMAP
-			 * range, so do not allow split_huge_page_pmd().
-			 */
-			if ((vma->vm_start <=3D addr) &&
-			    (vma->vm_flags & VM_PFNMAP)) {
-				next =3D vma->vm_end;
-				pgd =3D pgd_offset(walk->mm, next);
+			err =3D walk_page_test(start, next, walk);
+			if (err > 0)
 				continue;
-			}
-			/*
-			 * Handle hugetlb vma individually because pagetable
-			 * walk for the hugetlb page is dependent on the
-			 * architecture and we can't handled it in the same
-			 * manner as non-huge pages.
-			 */
-			if (walk->hugetlb_entry && (vma->vm_start <=3D addr) &&
-			    is_vm_hugetlb_page(vma)) {
-				if (vma->vm_end < next)
-					next =3D vma->vm_end;
-				/*
-				 * Hugepage is very tightly coupled with vma,
-				 * so walk through hugetlb entries within a
-				 * given vma.
-				 */
-				err =3D walk_hugetlb_range(vma, addr, next, walk);
-				if (err)
-					break;
-				pgd =3D pgd_offset(walk->mm, next);
-				continue;
-			}
-		}
-
-		if (pgd_none_or_clear_bad(pgd)) {
-			if (walk->pte_hole)
-				err =3D walk->pte_hole(addr, next, walk);
-			if (err)
+			if (err < 0)
 				break;
-			pgd++;
-			continue;
 		}
-		if (walk->pmd_entry || walk->pte_entry)
-			err =3D walk_pud_range(pgd, addr, next, walk);
+		if (walk->vma || walk->pte_hole)
+			err =3D __walk_page_range(start, next, walk);
 		if (err)
 			break;
-		pgd++;
-	} while (addr =3D next, addr < end);
-
+	} while (start =3D next, start < end);
 	return err;
 }
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
