Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 11450800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:05:08 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id rp18so4640786iec.37
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:05:07 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id s8si13613892icp.24.2014.11.06.23.05.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 23:05:06 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v7 08/13] numa_maps: remove numa_maps->vma
Date: Fri, 7 Nov 2014 07:02:00 +0000
Message-ID: <1415343692-6314-9-git-send-email-n-horiguchi@ah.jp.nec.com>
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
walk->private. And show_numa_map() walks pages on vma basis, so using
walk_page_vma() is preferable.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git mmotm-2014-11-05-16-01.orig/fs/proc/task_mmu.c mmotm-2014-11-05-=
16-01/fs/proc/task_mmu.c
index bddae83fbf39..e7d86b97598b 100644
--- mmotm-2014-11-05-16-01.orig/fs/proc/task_mmu.c
+++ mmotm-2014-11-05-16-01/fs/proc/task_mmu.c
@@ -1290,7 +1290,6 @@ const struct file_operations proc_pagemap_operations =
=3D {
 #ifdef CONFIG_NUMA
=20
 struct numa_maps {
-	struct vm_area_struct *vma;
 	unsigned long pages;
 	unsigned long anon;
 	unsigned long active;
@@ -1359,18 +1358,17 @@ static struct page *can_gather_numa_stats(pte_t pte=
, struct vm_area_struct *vma,
 static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 		unsigned long end, struct mm_walk *walk)
 {
-	struct numa_maps *md;
+	struct numa_maps *md =3D walk->private;
+	struct vm_area_struct *vma =3D walk->vma;
 	spinlock_t *ptl;
 	pte_t *orig_pte;
 	pte_t *pte;
=20
-	md =3D walk->private;
-
-	if (pmd_trans_huge_lock(pmd, md->vma, &ptl) =3D=3D 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) =3D=3D 1) {
 		pte_t huge_pte =3D *(pte_t *)pmd;
 		struct page *page;
=20
-		page =3D can_gather_numa_stats(huge_pte, md->vma, addr);
+		page =3D can_gather_numa_stats(huge_pte, vma, addr);
 		if (page)
 			gather_stats(page, md, pte_dirty(huge_pte),
 				     HPAGE_PMD_SIZE/PAGE_SIZE);
@@ -1382,7 +1380,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long=
 addr,
 		return 0;
 	orig_pte =3D pte =3D pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	do {
-		struct page *page =3D can_gather_numa_stats(*pte, md->vma, addr);
+		struct page *page =3D can_gather_numa_stats(*pte, vma, addr);
 		if (!page)
 			continue;
 		gather_stats(page, md, pte_dirty(*pte), 1);
@@ -1429,7 +1427,12 @@ static int show_numa_map(struct seq_file *m, void *v=
, int is_pid)
 	struct numa_maps *md =3D &numa_priv->md;
 	struct file *file =3D vma->vm_file;
 	struct mm_struct *mm =3D vma->vm_mm;
-	struct mm_walk walk =3D {};
+	struct mm_walk walk =3D {
+		.hugetlb_entry =3D gather_hugetlb_stats,
+		.pmd_entry =3D gather_pte_stats,
+		.private =3D md,
+		.mm =3D mm,
+	};
 	struct mempolicy *pol;
 	char buffer[64];
 	int nid;
@@ -1440,13 +1443,6 @@ static int show_numa_map(struct seq_file *m, void *v=
, int is_pid)
 	/* Ensure we start with an empty set of numa_maps statistics. */
 	memset(md, 0, sizeof(*md));
=20
-	md->vma =3D vma;
-
-	walk.hugetlb_entry =3D gather_hugetlb_stats;
-	walk.pmd_entry =3D gather_pte_stats;
-	walk.private =3D md;
-	walk.mm =3D mm;
-
 	pol =3D __get_vma_policy(vma, vma->vm_start);
 	if (pol) {
 		mpol_to_str(buffer, sizeof(buffer), pol);
@@ -1480,7 +1476,8 @@ static int show_numa_map(struct seq_file *m, void *v,=
 int is_pid)
 	if (is_vm_hugetlb_page(vma))
 		seq_puts(m, " huge");
=20
-	walk_page_range(vma->vm_start, vma->vm_end, &walk);
+	/* mmap_sem is held by m_start */
+	walk_page_vma(vma, &walk);
=20
 	if (!md->pages)
 		goto out;
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
