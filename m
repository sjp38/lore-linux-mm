Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 961726B0038
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 14:36:13 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q107so1247618qgd.19
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:36:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l5si4680092qaz.38.2014.07.11.11.36.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 11:36:11 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v5 04/13] smaps: remove mem_size_stats->vma and use walk_page_vma()
Date: Fri, 11 Jul 2014 14:35:40 -0400
Message-Id: <1405103749-23506-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1405103749-23506-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1405103749-23506-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

pagewalk.c can handle vma in itself, so we don't have to pass vma via
walk->private. And show_smap() walks pages on vma basis, so using
walk_page_vma() is preferable.

ChangeLog v4:
- remove redundant vma

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git mmotm-2014-07-09-17-08.orig/fs/proc/task_mmu.c mmotm-2014-07-09-17-08/fs/proc/task_mmu.c
index 5a33c7efade1..2c3a501c0dc7 100644
--- mmotm-2014-07-09-17-08.orig/fs/proc/task_mmu.c
+++ mmotm-2014-07-09-17-08/fs/proc/task_mmu.c
@@ -424,7 +424,6 @@ const struct file_operations proc_tid_maps_operations = {
 
 #ifdef CONFIG_PROC_PAGE_MONITOR
 struct mem_size_stats {
-	struct vm_area_struct *vma;
 	unsigned long resident;
 	unsigned long shared_clean;
 	unsigned long shared_dirty;
@@ -443,7 +442,7 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 		unsigned long ptent_size, struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
-	struct vm_area_struct *vma = mss->vma;
+	struct vm_area_struct *vma = walk->vma;
 	pgoff_t pgoff = linear_page_index(vma, addr);
 	struct page *page = NULL;
 	int mapcount;
@@ -495,7 +494,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			   struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
-	struct vm_area_struct *vma = mss->vma;
+	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
 
@@ -588,10 +587,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 	};
 
 	memset(&mss, 0, sizeof mss);
-	mss.vma = vma;
 	/* mmap_sem is held in m_start */
-	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
-		walk_page_range(vma->vm_start, vma->vm_end, &smaps_walk);
+	walk_page_vma(vma, &smaps_walk);
 
 	show_map_vma(m, vma, is_pid);
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
