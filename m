Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id BB16E6B0074
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 22:14:37 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 21/23] thp: wait_split_huge_page(): serialize over i_mmap_mutex too
Date: Sun,  4 Aug 2013 05:17:23 +0300
Message-Id: <1375582645-29274-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to have huge pages backed by files, so we need to modify
wait_split_huge_page() to support that.

We have two options for:
 - check whether the page anon or not and serialize only over required
   lock;
 - always serialize over both locks;

Current implementation, in fact, guarantees that *all* pages on the vma
is not splitting, not only the pages pmd is pointing on.

For now I prefer the second option since it's the safest: we provide the
same level of guarantees.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h | 15 ++++++++++++---
 mm/huge_memory.c        |  4 ++--
 mm/memory.c             |  4 ++--
 3 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 9a0a114..186f4f2 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -111,11 +111,20 @@ extern void __split_huge_page_pmd(struct vm_area_struct *vma,
 			__split_huge_page_pmd(__vma, __address,		\
 					____pmd);			\
 	}  while (0)
-#define wait_split_huge_page(__anon_vma, __pmd)				\
+#define wait_split_huge_page(__vma, __pmd)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
-		anon_vma_lock_write(__anon_vma);			\
-		anon_vma_unlock_write(__anon_vma);			\
+		struct address_space *__mapping = (__vma)->vm_file ?	\
+				(__vma)->vm_file->f_mapping : NULL;	\
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
index d7c6830..9af643d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -911,7 +911,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		spin_unlock(&dst_mm->page_table_lock);
 		pte_free(dst_mm, pgtable);
 
-		wait_split_huge_page(vma->anon_vma, src_pmd); /* src_vma */
+		wait_split_huge_page(vma, src_pmd); /* src_vma */
 		goto out;
 	}
 	src_page = pmd_page(pmd);
@@ -1493,7 +1493,7 @@ int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
 	if (likely(pmd_trans_huge(*pmd))) {
 		if (unlikely(pmd_trans_splitting(*pmd))) {
 			spin_unlock(&vma->vm_mm->page_table_lock);
-			wait_split_huge_page(vma->anon_vma, pmd);
+			wait_split_huge_page(vma, pmd);
 			return -1;
 		} else {
 			/* Thp mapped by 'pmd' is stable, so we can
diff --git a/mm/memory.c b/mm/memory.c
index 7d35f90..ea74ab1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -609,7 +609,7 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (new)
 		pte_free(mm, new);
 	if (wait_split_huge_page)
-		wait_split_huge_page(vma->anon_vma, pmd);
+		wait_split_huge_page(vma, pmd);
 	return 0;
 }
 
@@ -1522,7 +1522,7 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 		if (likely(pmd_trans_huge(*pmd))) {
 			if (unlikely(pmd_trans_splitting(*pmd))) {
 				spin_unlock(&mm->page_table_lock);
-				wait_split_huge_page(vma->anon_vma, pmd);
+				wait_split_huge_page(vma, pmd);
 			} else {
 				page = follow_trans_huge_pmd(vma, address,
 							     pmd, flags);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
