Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id D4431800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:04:55 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id h3so4879795igd.13
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:04:55 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id a21si12944078ioj.80.2014.11.06.23.04.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 23:04:55 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v7 05/13] clear_refs: remove clear_refs_private->vma and
 introduce clear_refs_test_walk()
Date: Fri, 7 Nov 2014 07:01:57 +0000
Message-ID: <1415343692-6314-6-git-send-email-n-horiguchi@ah.jp.nec.com>
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

clear_refs_write() has some prechecks to determine if we really walk over
a given vma. Now we have a test_walk() callback to filter vmas, so let's
utilize it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
ChangeLog v5:
- remove unused vma

ChangeLog v4:
- use walk_page_range instead of walk_page_vma with for loop
---
 fs/proc/task_mmu.c | 46 ++++++++++++++++++++++------------------------
 1 file changed, 22 insertions(+), 24 deletions(-)

diff --git mmotm-2014-11-05-16-01.orig/fs/proc/task_mmu.c mmotm-2014-11-05-=
16-01/fs/proc/task_mmu.c
index c1b937095625..9aaab24677ae 100644
--- mmotm-2014-11-05-16-01.orig/fs/proc/task_mmu.c
+++ mmotm-2014-11-05-16-01/fs/proc/task_mmu.c
@@ -741,7 +741,6 @@ enum clear_refs_types {
 };
=20
 struct clear_refs_private {
-	struct vm_area_struct *vma;
 	enum clear_refs_types type;
 };
=20
@@ -774,7 +773,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned lo=
ng addr,
 				unsigned long end, struct mm_walk *walk)
 {
 	struct clear_refs_private *cp =3D walk->private;
-	struct vm_area_struct *vma =3D cp->vma;
+	struct vm_area_struct *vma =3D walk->vma;
 	pte_t *pte, ptent;
 	spinlock_t *ptl;
 	struct page *page;
@@ -808,6 +807,25 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned l=
ong addr,
 	return 0;
 }
=20
+static int clear_refs_test_walk(unsigned long start, unsigned long end,
+				struct mm_walk *walk)
+{
+	struct clear_refs_private *cp =3D walk->private;
+	struct vm_area_struct *vma =3D walk->vma;
+
+	/*
+	 * Writing 1 to /proc/pid/clear_refs affects all pages.
+	 * Writing 2 to /proc/pid/clear_refs only affects anonymous pages.
+	 * Writing 3 to /proc/pid/clear_refs only affects file mapped pages.
+	 * Writing 4 to /proc/pid/clear_refs affects all pages.
+	 */
+	if (cp->type =3D=3D CLEAR_REFS_ANON && vma->vm_file)
+		return 1;
+	if (cp->type =3D=3D CLEAR_REFS_MAPPED && !vma->vm_file)
+		return 1;
+	return 0;
+}
+
 static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				size_t count, loff_t *ppos)
 {
@@ -848,6 +866,7 @@ static ssize_t clear_refs_write(struct file *file, cons=
t char __user *buf,
 		};
 		struct mm_walk clear_refs_walk =3D {
 			.pmd_entry =3D clear_refs_pte_range,
+			.test_walk =3D clear_refs_test_walk,
 			.mm =3D mm,
 			.private =3D &cp,
 		};
@@ -867,28 +886,7 @@ static ssize_t clear_refs_write(struct file *file, con=
st char __user *buf,
 			}
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
 		}
-		for (vma =3D mm->mmap; vma; vma =3D vma->vm_next) {
-			cp.vma =3D vma;
-			if (is_vm_hugetlb_page(vma))
-				continue;
-			/*
-			 * Writing 1 to /proc/pid/clear_refs affects all pages.
-			 *
-			 * Writing 2 to /proc/pid/clear_refs only affects
-			 * Anonymous pages.
-			 *
-			 * Writing 3 to /proc/pid/clear_refs only affects file
-			 * mapped pages.
-			 *
-			 * Writing 4 to /proc/pid/clear_refs affects all pages.
-			 */
-			if (type =3D=3D CLEAR_REFS_ANON && vma->vm_file)
-				continue;
-			if (type =3D=3D CLEAR_REFS_MAPPED && !vma->vm_file)
-				continue;
-			walk_page_range(vma->vm_start, vma->vm_end,
-					&clear_refs_walk);
-		}
+		walk_page_range(0, ~0UL, &clear_refs_walk);
 		if (type =3D=3D CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
 		flush_tlb_mm(mm);
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
