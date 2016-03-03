Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D00076B0264
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 11:53:04 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fy10so17590844pac.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:53:04 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xg10si5517714pab.141.2016.03.03.08.52.39
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 08:52:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 15/29] thp: handle file pages in mremap()
Date: Thu,  3 Mar 2016 19:52:05 +0300
Message-Id: <1457023939-98083-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index 3fa0a467df66..88fa7ab1a8ce 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -192,17 +192,27 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
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
