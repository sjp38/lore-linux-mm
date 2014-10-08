Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5342A900014
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 09:26:03 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kx10so8979817pab.23
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 06:26:03 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id y5si3204222pdc.219.2014.10.08.06.26.01
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 06:26:02 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v1 4/7] mm: Add a pmd_fault handler
Date: Wed,  8 Oct 2014 09:25:26 -0400
Message-Id: <1412774729-23956-5-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.krenel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Allow non-anonymous VMAs to provide huge pages in response to a page fault.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/mm.h |  2 ++
 mm/memory.c        | 15 +++++++++++----
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d0de9fa..c0b4f74 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -229,6 +229,8 @@ struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
+	int (*pmd_fault)(struct vm_area_struct *, unsigned long address,
+						pmd_t *, unsigned int flags);
 	void (*map_pages)(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 	/* notification that a previously read-only page is about to become
diff --git a/mm/memory.c b/mm/memory.c
index 993be2b..ec51b0f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3238,6 +3238,16 @@ out:
 	return 0;
 }
 
+static int create_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pmd_t *pmd, unsigned int flags)
+{
+	if (!vma->vm_ops)
+		return do_huge_pmd_anonymous_page(mm, vma, address, pmd, flags);
+	if (vma->vm_ops->pmd_fault)
+		return vma->vm_ops->pmd_fault(vma, address, pmd, flags);
+	return VM_FAULT_FALLBACK;
+}
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -3335,10 +3345,7 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!pmd)
 		return VM_FAULT_OOM;
 	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
-		int ret = VM_FAULT_FALLBACK;
-		if (!vma->vm_ops)
-			ret = do_huge_pmd_anonymous_page(mm, vma, address,
-					pmd, flags);
+		int ret = create_huge_pmd(mm, vma, address, pmd, flags);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
 	} else {
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
