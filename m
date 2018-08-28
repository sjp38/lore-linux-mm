Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9D4D6B46E6
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:57:43 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id w18-v6so766476plp.3
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:57:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m5-v6si1241270pgt.361.2018.08.28.07.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 07:57:42 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 07/10] mm: Remove vm_insert_pfn
Date: Tue, 28 Aug 2018 07:57:25 -0700
Message-Id: <20180828145728.11873-8-willy@infradead.org>
In-Reply-To: <20180828145728.11873-1-willy@infradead.org>
References: <20180828145728.11873-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

All callers are now converted to vmf_insert_pfn so convert
vmf_insert_pfn() from being a compatibility wrapper around vm_insert_pfn()
to being a compatibility wrapper around vmf_insert_pfn_prot().

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/mm.h | 15 +------------
 mm/memory.c        | 54 +++++++++++++++++++++++++---------------------
 2 files changed, 30 insertions(+), 39 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1552c67c835e..bd5e2469b637 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2478,7 +2478,7 @@ struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
-int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot);
@@ -2501,19 +2501,6 @@ static inline vm_fault_t vmf_insert_page(struct vm_area_struct *vma,
 	return VM_FAULT_NOPAGE;
 }
 
-static inline vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma,
-			unsigned long addr, unsigned long pfn)
-{
-	int err = vm_insert_pfn(vma, addr, pfn);
-
-	if (err == -ENOMEM)
-		return VM_FAULT_OOM;
-	if (err < 0 && err != -EBUSY)
-		return VM_FAULT_SIGBUS;
-
-	return VM_FAULT_NOPAGE;
-}
-
 static inline vm_fault_t vmf_error(int err)
 {
 	if (err == -ENOMEM)
diff --git a/mm/memory.c b/mm/memory.c
index 8392a104a36d..d5ccbadd81c1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1849,30 +1849,6 @@ static int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 	return ret;
 }
 
-/**
- * vm_insert_pfn - insert single pfn into user vma
- * @vma: user vma to map to
- * @addr: target user address of this page
- * @pfn: source kernel pfn
- *
- * Similar to vm_insert_page, this allows drivers to insert individual pages
- * they've allocated into a user vma. Same comments apply.
- *
- * This function should only be called from a vm_ops->fault handler, and
- * in that case the handler should return NULL.
- *
- * vma cannot be a COW mapping.
- *
- * As this is called only for pages that do not currently exist, we
- * do not need to flush old virtual caches or the TLB.
- */
-int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn)
-{
-	return vm_insert_pfn_prot(vma, addr, pfn, vma->vm_page_prot);
-}
-EXPORT_SYMBOL(vm_insert_pfn);
-
 /**
  * vmf_insert_pfn_prot - insert single pfn into user vma with specified pgprot
  * @vma: user vma to map to
@@ -1885,9 +1861,10 @@ EXPORT_SYMBOL(vm_insert_pfn);
  *
  * This only makes sense for IO mappings, and it makes no sense for
  * COW mappings.  In general, using multiple vmas is preferable;
- * vm_insert_pfn_prot should only be used if using multiple VMAs is
+ * vmf_insert_pfn_prot should only be used if using multiple VMAs is
  * impractical.
  *
+ * Context: Process context.  May allocate using %GFP_KERNEL.
  * Return: vm_fault_t value.
  */
 vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
@@ -1904,6 +1881,33 @@ vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vmf_insert_pfn_prot);
 
+/**
+ * vmf_insert_pfn - insert single pfn into user vma
+ * @vma: user vma to map to
+ * @addr: target user address of this page
+ * @pfn: source kernel pfn
+ *
+ * Similar to vm_insert_page, this allows drivers to insert individual pages
+ * they've allocated into a user vma. Same comments apply.
+ *
+ * This function should only be called from a vm_ops->fault handler, and
+ * in that case the handler should return the result of this function.
+ *
+ * vma cannot be a COW mapping.
+ *
+ * As this is called only for pages that do not currently exist, we
+ * do not need to flush old virtual caches or the TLB.
+ *
+ * Context: Process context.  May allocate using %GFP_KERNEL.
+ * Return: vm_fault_t value.
+ */
+vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn)
+{
+	return vmf_insert_pfn_prot(vma, addr, pfn, vma->vm_page_prot);
+}
+EXPORT_SYMBOL(vmf_insert_pfn);
+
 static bool vm_mixed_ok(struct vm_area_struct *vma, pfn_t pfn)
 {
 	/* these checks mirror the abort conditions in vm_normal_page */
-- 
2.18.0
