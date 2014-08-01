Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id AA3AE6B003B
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 15:21:17 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id j15so4324364qaq.25
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 12:21:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 17si17217711qgb.86.2014.08.01.12.21.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Aug 2014 12:21:17 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v6 08/13] numa_maps: remove numa_maps->vma
Date: Fri,  1 Aug 2014 15:20:44 -0400
Message-Id: <1406920849-25908-9-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1406920849-25908-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1406920849-25908-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

pagewalk.c can handle vma in itself, so we don't have to pass vma via
walk->private. And show_numa_map() walks pages on vma basis, so using
walk_page_vma() is preferable.

ChangeLog v4:
- remove redundant vma

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git mmotm-2014-07-30-15-57.orig/fs/proc/task_mmu.c mmotm-2014-07-30-15-57/fs/proc/task_mmu.c
index 8b1eb1617445..084d750f6177 100644
--- mmotm-2014-07-30-15-57.orig/fs/proc/task_mmu.c
+++ mmotm-2014-07-30-15-57/fs/proc/task_mmu.c
@@ -1238,7 +1238,6 @@ const struct file_operations proc_pagemap_operations = {
 #ifdef CONFIG_NUMA
 
 struct numa_maps {
-	struct vm_area_struct *vma;
 	unsigned long pages;
 	unsigned long anon;
 	unsigned long active;
@@ -1307,18 +1306,17 @@ static struct page *can_gather_numa_stats(pte_t pte, struct vm_area_struct *vma,
 static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 		unsigned long end, struct mm_walk *walk)
 {
-	struct numa_maps *md;
+	struct numa_maps *md = walk->private;
+	struct vm_area_struct *vma = walk->vma;
 	spinlock_t *ptl;
 	pte_t *orig_pte;
 	pte_t *pte;
 
-	md = walk->private;
-
-	if (pmd_trans_huge_lock(pmd, md->vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
-		page = can_gather_numa_stats(huge_pte, md->vma, addr);
+		page = can_gather_numa_stats(huge_pte, vma, addr);
 		if (page)
 			gather_stats(page, md, pte_dirty(huge_pte),
 				     HPAGE_PMD_SIZE/PAGE_SIZE);
@@ -1330,7 +1328,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 		return 0;
 	orig_pte = pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	do {
-		struct page *page = can_gather_numa_stats(*pte, md->vma, addr);
+		struct page *page = can_gather_numa_stats(*pte, vma, addr);
 		if (!page)
 			continue;
 		gather_stats(page, md, pte_dirty(*pte), 1);
@@ -1378,7 +1376,12 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	struct file *file = vma->vm_file;
 	struct task_struct *task = proc_priv->task;
 	struct mm_struct *mm = vma->vm_mm;
-	struct mm_walk walk = {};
+	struct mm_walk walk = {
+		.hugetlb_entry = gather_hugetlb_stats,
+		.pmd_entry = gather_pte_stats,
+		.private = md,
+		.mm = mm,
+	};
 	struct mempolicy *pol;
 	char buffer[64];
 	int nid;
@@ -1389,13 +1392,6 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	/* Ensure we start with an empty set of numa_maps statistics. */
 	memset(md, 0, sizeof(*md));
 
-	md->vma = vma;
-
-	walk.hugetlb_entry = gather_hugetlb_stats;
-	walk.pmd_entry = gather_pte_stats;
-	walk.private = md;
-	walk.mm = mm;
-
 	pol = get_vma_policy(task, vma, vma->vm_start);
 	mpol_to_str(buffer, sizeof(buffer), pol);
 	mpol_cond_put(pol);
@@ -1425,7 +1421,8 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	if (is_vm_hugetlb_page(vma))
 		seq_printf(m, " huge");
 
-	walk_page_range(vma->vm_start, vma->vm_end, &walk);
+	/* mmap_sem is held by m_start */
+	walk_page_vma(vma, &walk);
 
 	if (!md->pages)
 		goto out;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
