Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 4F6636B00CA
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:28 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 21/34] thp: wait_split_huge_page(): serialize over i_mmap_mutex too
Date: Fri,  5 Apr 2013 14:59:45 +0300
Message-Id: <1365163198-29726-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Since we're going to have huge pages backed by files,
wait_split_huge_page() has to serialize not only over anon_vma_lock,
but over i_mmap_mutex too.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |   15 ++++++++++++---
 mm/huge_memory.c        |    4 ++--
 mm/memory.c             |    4 ++--
 3 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a54939c..b53e295 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -113,11 +113,20 @@ extern void __split_huge_page_pmd(struct vm_area_struct *vma,
 			__split_huge_page_pmd(__vma, __address,		\
 					____pmd);			\
 	}  while (0)
-#define wait_split_huge_page(__anon_vma, __pmd)				\
+#define wait_split_huge_page(__vma, __pmd)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
-		anon_vma_lock_write(__anon_vma);			\
-		anon_vma_unlock_write(__anon_vma);			\
+		struct address_space *__mapping =			\
+					vma->vm_file->f_mapping;	\
+		struct anon_vma *__anon_vma = (__vma)->anon_vma;	\
+		if (__mapping)						\
+			mutex_lock(&__mapping->i_mmap_mutex);		\
+		if (__anon_vma) {					\
+			anon_vma_lock_write(__anon_vma);		\
+			anon_vma_unlock_write(__anon_vma);		\
+		}							\
+		if (__mapping)						\
+			mutex_unlock(&__mapping->i_mmap_mutex);		\
 		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
 		       pmd_trans_huge(*____pmd));			\
 	} while (0)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ac0dc80..7c48f58 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -907,7 +907,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		spin_unlock(&dst_mm->page_table_lock);
 		pte_free(dst_mm, pgtable);
 
-		wait_split_huge_page(vma->anon_vma, src_pmd); /* src_vma */
+		wait_split_huge_page(vma, src_pmd); /* src_vma */
 		goto out;
 	}
 	src_page = pmd_page(pmd);
@@ -1480,7 +1480,7 @@ int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
 	if (likely(pmd_trans_huge(*pmd))) {
 		if (unlikely(pmd_trans_splitting(*pmd))) {
 			spin_unlock(&vma->vm_mm->page_table_lock);
-			wait_split_huge_page(vma->anon_vma, pmd);
+			wait_split_huge_page(vma, pmd);
 			return -1;
 		} else {
 			/* Thp mapped by 'pmd' is stable, so we can
diff --git a/mm/memory.c b/mm/memory.c
index 9da540f..2895f0e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -619,7 +619,7 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (new)
 		pte_free(mm, new);
 	if (wait_split_huge_page)
-		wait_split_huge_page(vma->anon_vma, pmd);
+		wait_split_huge_page(vma, pmd);
 	return 0;
 }
 
@@ -1529,7 +1529,7 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 		if (likely(pmd_trans_huge(*pmd))) {
 			if (unlikely(pmd_trans_splitting(*pmd))) {
 				spin_unlock(&mm->page_table_lock);
-				wait_split_huge_page(vma->anon_vma, pmd);
+				wait_split_huge_page(vma, pmd);
 			} else {
 				page = follow_trans_huge_pmd(vma, address,
 							     pmd, flags);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
