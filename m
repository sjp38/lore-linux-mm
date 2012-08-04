Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id DA5B06B0044
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 02:08:32 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so1631081vbk.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 23:08:31 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 4 Aug 2012 14:08:31 +0800
Message-ID: <CAJd=RBC9HhKh5Q0-yXi3W0x3guXJPFz4BNsniyOFmp0TjBdFqg@mail.gmail.com>
Subject: [patch v2] hugetlb: correct page offset index for sharing pmd
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

The computation of page offset index is incorrect to be used in scanning
prio tree, as huge page offset is required, and is fixed with well
defined routine.

Changes from v1
	o s/linear_page_index/linear_hugepage_index/ for clearer code
	o hp_idx variable added for less change


Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/arch/x86/mm/hugetlbpage.c	Fri Aug  3 20:34:58 2012
+++ b/arch/x86/mm/hugetlbpage.c	Fri Aug  3 20:40:16 2012
@@ -62,6 +62,7 @@ static void huge_pmd_share(struct mm_str
 {
 	struct vm_area_struct *vma = find_vma(mm, addr);
 	struct address_space *mapping = vma->vm_file->f_mapping;
+	pgoff_t hp_idx;
 	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
 			vma->vm_pgoff;
 	struct prio_tree_iter iter;
@@ -72,8 +73,10 @@ static void huge_pmd_share(struct mm_str
 	if (!vma_shareable(vma, addr))
 		return;

+	hp_idx = linear_hugepage_index(vma, addr);
+
 	mutex_lock(&mapping->i_mmap_mutex);
-	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
+	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, hp_idx, hp_idx) {
 		if (svma == vma)
 			continue;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
