Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8029D6B46E4
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:57:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q67-v6so1286013pgq.9
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:57:42 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n64-v6si1289213pgn.247.2018.08.28.07.57.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 07:57:41 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 05/10] mm: Make vm_insert_pfn_prot static
Date: Tue, 28 Aug 2018 07:57:23 -0700
Message-Id: <20180828145728.11873-6-willy@infradead.org>
In-Reply-To: <20180828145728.11873-1-willy@infradead.org>
References: <20180828145728.11873-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now this is no longer used outside mm/memory.c, make it static.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/mm.h |  2 --
 mm/memory.c        | 50 +++++++++++++++++++++++-----------------------
 2 files changed, 25 insertions(+), 27 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e8bc1a16d44c..1552c67c835e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2480,8 +2480,6 @@ int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
-int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn, pgprot_t pgprot);
 vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot);
 vm_fault_t vmf_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
diff --git a/mm/memory.c b/mm/memory.c
index 8c116c0f64d8..8392a104a36d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1819,31 +1819,7 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	return retval;
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
-int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
+static int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot)
 {
 	int ret;
@@ -1873,6 +1849,30 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 	return ret;
 }
 
+/**
+ * vm_insert_pfn - insert single pfn into user vma
+ * @vma: user vma to map to
+ * @addr: target user address of this page
+ * @pfn: source kernel pfn
+ *
+ * Similar to vm_insert_page, this allows drivers to insert individual pages
+ * they've allocated into a user vma. Same comments apply.
+ *
+ * This function should only be called from a vm_ops->fault handler, and
+ * in that case the handler should return NULL.
+ *
+ * vma cannot be a COW mapping.
+ *
+ * As this is called only for pages that do not currently exist, we
+ * do not need to flush old virtual caches or the TLB.
+ */
+int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn)
+{
+	return vm_insert_pfn_prot(vma, addr, pfn, vma->vm_page_prot);
+}
+EXPORT_SYMBOL(vm_insert_pfn);
+
 /**
  * vmf_insert_pfn_prot - insert single pfn into user vma with specified pgprot
  * @vma: user vma to map to
-- 
2.18.0
