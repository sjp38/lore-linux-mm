Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 800BE6B0037
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:53:14 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so162734pdb.24
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 12:53:14 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id bf15si25932pdb.194.2014.07.22.12.53.13
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 12:53:13 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v8 05/22] Add vm_replace_mixed()
Date: Tue, 22 Jul 2014 15:47:53 -0400
Message-Id: <b1052af08b49965fd0e6b87b6733b89294c8cc1e.1406058387.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1406058387.git.matthew.r.wilcox@intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1406058387.git.matthew.r.wilcox@intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

vm_insert_mixed() will fail if there is already a valid PTE at that
location.  The DAX code would rather replace the previous value with
the new PTE.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/mm.h |  8 ++++++--
 mm/memory.c        | 34 +++++++++++++++++++++-------------
 2 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e04f531..8d1194c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1958,8 +1958,12 @@ int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
-int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn);
+int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn, bool replace);
+#define vm_insert_mixed(vma, addr, pfn)	\
+	__vm_insert_mixed(vma, addr, pfn, false)
+#define vm_replace_mixed(vma, addr, pfn)	\
+	__vm_insert_mixed(vma, addr, pfn, true)
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
 
diff --git a/mm/memory.c b/mm/memory.c
index 42bf429..cf06c97 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1476,7 +1476,7 @@ pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
  * pages reserved for the old functions anyway.
  */
 static int insert_page(struct vm_area_struct *vma, unsigned long addr,
-			struct page *page, pgprot_t prot)
+			struct page *page, pgprot_t prot, bool replace)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int retval;
@@ -1492,8 +1492,12 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 	if (!pte)
 		goto out;
 	retval = -EBUSY;
-	if (!pte_none(*pte))
-		goto out_unlock;
+	if (!pte_none(*pte)) {
+		if (!replace)
+			goto out_unlock;
+		VM_BUG_ON(!mutex_is_locked(&vma->vm_file->f_mapping->i_mmap_mutex));
+		zap_page_range_single(vma, addr, PAGE_SIZE, NULL);
+	}
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
@@ -1549,12 +1553,12 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 		BUG_ON(vma->vm_flags & VM_PFNMAP);
 		vma->vm_flags |= VM_MIXEDMAP;
 	}
-	return insert_page(vma, addr, page, vma->vm_page_prot);
+	return insert_page(vma, addr, page, vma->vm_page_prot, false);
 }
 EXPORT_SYMBOL(vm_insert_page);
 
 static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn, pgprot_t prot)
+			unsigned long pfn, pgprot_t prot, bool replace)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int retval;
@@ -1566,8 +1570,12 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	if (!pte)
 		goto out;
 	retval = -EBUSY;
-	if (!pte_none(*pte))
-		goto out_unlock;
+	if (!pte_none(*pte)) {
+		if (!replace)
+			goto out_unlock;
+		VM_BUG_ON(!mutex_is_locked(&vma->vm_file->f_mapping->i_mmap_mutex));
+		zap_page_range_single(vma, addr, PAGE_SIZE, NULL);
+	}
 
 	/* Ok, finally just insert the thing.. */
 	entry = pte_mkspecial(pfn_pte(pfn, prot));
@@ -1620,14 +1628,14 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	if (track_pfn_insert(vma, &pgprot, pfn))
 		return -EINVAL;
 
-	ret = insert_pfn(vma, addr, pfn, pgprot);
+	ret = insert_pfn(vma, addr, pfn, pgprot, false);
 
 	return ret;
 }
 EXPORT_SYMBOL(vm_insert_pfn);
 
-int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn)
+int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn, bool replace)
 {
 	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
 
@@ -1645,11 +1653,11 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 		struct page *page;
 
 		page = pfn_to_page(pfn);
-		return insert_page(vma, addr, page, vma->vm_page_prot);
+		return insert_page(vma, addr, page, vma->vm_page_prot, replace);
 	}
-	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
+	return insert_pfn(vma, addr, pfn, vma->vm_page_prot, replace);
 }
-EXPORT_SYMBOL(vm_insert_mixed);
+EXPORT_SYMBOL(__vm_insert_mixed);
 
 /*
  * maps a range of physical memory into the requested pages. the old
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
