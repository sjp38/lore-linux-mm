Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7256C800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:04:44 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id rd18so4595110iec.21
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:04:44 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id k5si912553igx.57.2014.11.06.23.04.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 23:04:43 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v7 04/13] smaps: remove mem_size_stats->vma and use
 walk_page_vma()
Date: Fri, 7 Nov 2014 07:01:56 +0000
Message-ID: <1415343692-6314-5-git-send-email-n-horiguchi@ah.jp.nec.com>
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

pagewalk.c can handle vma in itself, so we don't have to pass vma via
walk->private. And show_smap() walks pages on vma basis, so using
walk_page_vma() is preferable.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git mmotm-2014-11-05-16-01.orig/fs/proc/task_mmu.c mmotm-2014-11-05-=
16-01/fs/proc/task_mmu.c
index 2ab200d429be..c1b937095625 100644
--- mmotm-2014-11-05-16-01.orig/fs/proc/task_mmu.c
+++ mmotm-2014-11-05-16-01/fs/proc/task_mmu.c
@@ -433,7 +433,6 @@ const struct file_operations proc_tid_maps_operations =
=3D {
=20
 #ifdef CONFIG_PROC_PAGE_MONITOR
 struct mem_size_stats {
-	struct vm_area_struct *vma;
 	unsigned long resident;
 	unsigned long shared_clean;
 	unsigned long shared_dirty;
@@ -480,7 +479,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned long a=
ddr,
 		struct mm_walk *walk)
 {
 	struct mem_size_stats *mss =3D walk->private;
-	struct vm_area_struct *vma =3D mss->vma;
+	struct vm_area_struct *vma =3D walk->vma;
 	pgoff_t pgoff =3D linear_page_index(vma, addr);
 	struct page *page =3D NULL;
=20
@@ -512,7 +511,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long a=
ddr,
 		struct mm_walk *walk)
 {
 	struct mem_size_stats *mss =3D walk->private;
-	struct vm_area_struct *vma =3D mss->vma;
+	struct vm_area_struct *vma =3D walk->vma;
 	struct page *page;
=20
 	/* FOLL_DUMP will return -EFAULT on huge zero page */
@@ -533,8 +532,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long a=
ddr,
 static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long e=
nd,
 			   struct mm_walk *walk)
 {
-	struct mem_size_stats *mss =3D walk->private;
-	struct vm_area_struct *vma =3D mss->vma;
+	struct vm_area_struct *vma =3D walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
=20
@@ -624,10 +622,8 @@ static int show_smap(struct seq_file *m, void *v, int =
is_pid)
 	};
=20
 	memset(&mss, 0, sizeof mss);
-	mss.vma =3D vma;
 	/* mmap_sem is held in m_start */
-	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
-		walk_page_range(vma->vm_start, vma->vm_end, &smaps_walk);
+	walk_page_vma(vma, &smaps_walk);
=20
 	show_map_vma(m, vma, is_pid);
=20
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
