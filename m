Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0507E6B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:23:11 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id c10so30675267pfc.2
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:23:10 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id wq13si12900630pac.86.2016.02.11.06.22.43
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:22:43 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 16/28] thp: handle file pages in mremap()
Date: Thu, 11 Feb 2016 17:21:44 +0300
Message-Id: <1455200516-132137-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We need to mirror logic in move_ptes() wrt need_rmap_locks to get proper
serialization file THP.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mremap.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 8eeba02fc991..b43027a25982 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -193,17 +193,27 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 			break;
 		if (pmd_trans_huge(*old_pmd)) {
 			if (extent == HPAGE_PMD_SIZE) {
+				struct address_space *mapping = NULL;
+				struct anon_vma *anon_vma = NULL;
 				bool moved;
-				VM_BUG_ON_VMA(vma->vm_file || !vma->anon_vma,
-					      vma);
 				/* See comment in move_ptes() */
-				if (need_rmap_locks)
-					anon_vma_lock_write(vma->anon_vma);
+				if (need_rmap_locks) {
+					if (vma->vm_file) {
+						mapping = vma->vm_file->f_mapping;
+						i_mmap_lock_write(mapping);
+					}
+					if (vma->anon_vma) {
+						anon_vma = vma->anon_vma;
+						anon_vma_lock_write(anon_vma);
+					}
+				}
 				moved = move_huge_pmd(vma, new_vma, old_addr,
 						    new_addr, old_end,
 						    old_pmd, new_pmd);
-				if (need_rmap_locks)
-					anon_vma_unlock_write(vma->anon_vma);
+				if (anon_vma)
+					anon_vma_unlock_write(anon_vma);
+				if (mapping)
+					i_mmap_unlock_write(mapping);
 				if (moved) {
 					need_flush = true;
 					continue;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
