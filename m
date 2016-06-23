Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id E4FA96B025E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:37:08 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ao6so142745883pac.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:37:08 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id 21si188278pfp.63.2016.06.23.06.37.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 06:37:08 -0700 (PDT)
From: <zhouxianrong@huawei.com>
Subject: [PATCH] ksm: set anon_vma of first rmap_item of ksm page to page's anon_vma other than vma's anon_vma
Date: Thu, 23 Jun 2016 21:33:54 +0800
Message-ID: <1466688834-127613-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, zhouchengming1@huawei.com, geliangtang@163.com, zhouxianrong@huawei.com, linux-kernel@vger.kernel.org, zhouxiyu@huawei.com, wanghaijun5@huawei.com

From: z00281421 <z00281421@notesmail.huawei.com>

set anon_vma of first rmap_item of ksm page to page's anon_vma
other than vma's anon_vma so that we can lookup all the forked
vma of kpage via reserve map. thus we can try_to_unmap ksm page
completely and reclaim or migrate the ksm page successfully and
need not to merg other forked vma addresses of ksm page with
building a rmap_item for it ever after.

a forked more mapcount ksm page with partially merged vma addresses and
a ksm page mapped into non-VM_MERGEABLE vma due to setting MADV_MERGEABLE
on one of the forked vma can be unmapped completely by try_to_unmap.

Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
---
 mm/ksm.c |   19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 4786b41..6bacc08 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -971,11 +971,13 @@ out:
  * @page: the PageAnon page that we want to replace with kpage
  * @kpage: the PageKsm page that we want to map instead of page,
  *         or NULL the first time when we want to use page as kpage.
+ * @anon_vma: output the anon_vma of page used as kpage
  *
  * This function returns 0 if the pages were merged, -EFAULT otherwise.
  */
 static int try_to_merge_one_page(struct vm_area_struct *vma,
-				 struct page *page, struct page *kpage)
+				 struct page *page, struct page *kpage,
+				 struct anon_vma **anon_vma)
 {
 	pte_t orig_pte = __pte(0);
 	int err = -EFAULT;
@@ -1015,6 +1017,8 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 			 * PageAnon+anon_vma to PageKsm+NULL stable_node:
 			 * stable_tree_insert() will update stable_node.
 			 */
+			if (anon_vma != NULL)
+				*anon_vma = page_anon_vma(page);
 			set_page_stable_node(page, NULL);
 			mark_page_accessed(page);
 			/*
@@ -1055,6 +1059,7 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 {
 	struct mm_struct *mm = rmap_item->mm;
 	struct vm_area_struct *vma;
+	struct anon_vma *anon_vma = NULL;
 	int err = -EFAULT;
 
 	down_read(&mm->mmap_sem);
@@ -1062,7 +1067,7 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	if (!vma)
 		goto out;
 
-	err = try_to_merge_one_page(vma, page, kpage);
+	err = try_to_merge_one_page(vma, page, kpage, &anon_vma);
 	if (err)
 		goto out;
 
@@ -1070,7 +1075,10 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	remove_rmap_item_from_tree(rmap_item);
 
 	/* Must get reference to anon_vma while still holding mmap_sem */
-	rmap_item->anon_vma = vma->anon_vma;
+	if (anon_vma != NULL)
+		rmap_item->anon_vma = anon_vma;
+	else
+		rmap_item->anon_vma = vma->anon_vma;
 	get_anon_vma(vma->anon_vma);
 out:
 	up_read(&mm->mmap_sem);
@@ -1435,6 +1443,11 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 
 	remove_rmap_item_from_tree(rmap_item);
 
+	if (kpage == page) {
+		put_page(kpage);
+		return;
+	}
+
 	if (kpage) {
 		err = try_to_merge_with_ksm_page(rmap_item, page, kpage);
 		if (!err) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
