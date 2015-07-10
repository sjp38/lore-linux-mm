Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7FBCD9003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 16:29:36 -0400 (EDT)
Received: by padck2 with SMTP id ck2so8908385pad.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:29:36 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id dx5si4577642pbc.22.2015.07.10.13.29.35
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 13:29:35 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 04/10] mm: Add a pmd_fault handler
Date: Fri, 10 Jul 2015 16:29:19 -0400
Message-Id: <1436560165-8943-5-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Allow non-anonymous VMAs to provide huge pages in response to a page fault.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/mm.h |  2 ++
 mm/memory.c        | 30 ++++++++++++++++++++++++------
 2 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2e872f9..00473e4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -246,6 +246,8 @@ struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
+	int (*pmd_fault)(struct vm_area_struct *, unsigned long address,
+						pmd_t *, unsigned int flags);
 	void (*map_pages)(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 	/* notification that a previously read-only page is about to become
diff --git a/mm/memory.c b/mm/memory.c
index a84fbb7..32007d6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3209,6 +3209,27 @@ out:
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
+static int wp_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pmd_t *pmd, pmd_t orig_pmd,
+			unsigned int flags)
+{
+	if (!vma->vm_ops)
+		return do_huge_pmd_wp_page(mm, vma, address, pmd, orig_pmd);
+	if (vma->vm_ops->pmd_fault)
+		return vma->vm_ops->pmd_fault(vma, address, pmd, flags);
+	return VM_FAULT_FALLBACK;
+}
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -3312,10 +3333,7 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -3339,8 +3357,8 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 							     orig_pmd, pmd);
 
 			if (dirty && !pmd_write(orig_pmd)) {
-				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
-							  orig_pmd);
+				ret = wp_huge_pmd(mm, vma, address, pmd,
+							orig_pmd, flags);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
 			} else {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
