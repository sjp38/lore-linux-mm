Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 38F4D6B026A
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:51:41 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id fe3so41654922pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:51:41 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qn9si7245269pab.159.2016.04.06.15.51.31
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 11/30] thp: handle file pages in mremap()
Date: Thu,  7 Apr 2016 01:51:01 +0300
Message-Id: <1459983080-106718-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
