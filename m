Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 786366B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:06:54 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id b126so71590668ite.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:06:54 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id iu4si5510808pac.93.2016.06.15.13.06.53
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:06:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased2 02/37]  mm-thp-make-swapin-readahead-under-down_read-of-mmap_sem-fix
Date: Wed, 15 Jun 2016 23:06:07 +0300
Message-Id: <1466021202-61880-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.cz>

Passing 'vma' to hugepage_vma_revlidate() is useless.  It doesn't make use
of it anyway.

Link: http://lkml.kernel.org/r/20160530095058.GA53044@black.fi.intel.com

Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/huge_memory.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 96dfe3f09bf6..7bb30e853335 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2384,10 +2384,9 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
  * value (scan code).
  */
 
-static int hugepage_vma_revalidate(struct mm_struct *mm,
-				   struct vm_area_struct *vma,
-				   unsigned long address)
+static int hugepage_vma_revalidate(struct mm_struct *mm, unsigned long address)
 {
+	struct vm_area_struct *vma;
 	unsigned long hstart, hend;
 
 	if (unlikely(khugepaged_test_exit(mm)))
@@ -2436,7 +2435,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		if (ret & VM_FAULT_RETRY) {
 			down_read(&mm->mmap_sem);
 			/* vma is no longer available, don't continue to swapin */
-			if (hugepage_vma_revalidate(mm, vma, address))
+			if (hugepage_vma_revalidate(mm, address))
 				return false;
 		}
 		if (ret & VM_FAULT_ERROR) {
@@ -2487,7 +2486,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	}
 
 	down_read(&mm->mmap_sem);
-	result = hugepage_vma_revalidate(mm, vma, address);
+	result = hugepage_vma_revalidate(mm, address);
 	if (result)
 		goto out;
 
@@ -2514,7 +2513,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * handled by the anon_vma lock + PG_lock.
 	 */
 	down_write(&mm->mmap_sem);
-	result = hugepage_vma_revalidate(mm, vma, address);
+	result = hugepage_vma_revalidate(mm, address);
 	if (result)
 		goto out;
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
