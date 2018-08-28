Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD7836B46E2
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:57:40 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id n17-v6so1052476pff.17
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:57:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z5-v6si1216249plo.130.2018.08.28.07.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 07:57:39 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 03/10] mm: Introduce vmf_insert_pfn_prot
Date: Tue, 28 Aug 2018 07:57:21 -0700
Message-Id: <20180828145728.11873-4-willy@infradead.org>
In-Reply-To: <20180828145728.11873-1-willy@infradead.org>
References: <20180828145728.11873-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Like vm_insert_pfn_prot(), but returns a vm_fault_t instead of an errno.
Also unexport vm_insert_pfn_prot as it has no modular users.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/mm.h |  2 ++
 mm/memory.c        | 47 ++++++++++++++++++++++++++++++----------------
 2 files changed, 33 insertions(+), 16 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ce1b24376d72..e8bc1a16d44c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2482,6 +2482,8 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot);
+vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn, pgprot_t pgprot);
 vm_fault_t vmf_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn);
 vm_fault_t vmf_insert_mixed_mkwrite(struct vm_area_struct *vma,
diff --git a/mm/memory.c b/mm/memory.c
index f0b123a94426..8c116c0f64d8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1843,21 +1843,6 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_pfn);
 
-/**
- * vm_insert_pfn_prot - insert single pfn into user vma with specified pgprot
- * @vma: user vma to map to
- * @addr: target user address of this page
- * @pfn: source kernel pfn
- * @pgprot: pgprot flags for the inserted page
- *
- * This is exactly like vm_insert_pfn, except that it allows drivers to
- * to override pgprot on a per-page basis.
- *
- * This only makes sense for IO mappings, and it makes no sense for
- * cow mappings.  In general, using multiple vmas is preferable;
- * vm_insert_pfn_prot should only be used if using multiple VMAs is
- * impractical.
- */
 int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot)
 {
@@ -1887,7 +1872,37 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 
 	return ret;
 }
-EXPORT_SYMBOL(vm_insert_pfn_prot);
+
+/**
+ * vmf_insert_pfn_prot - insert single pfn into user vma with specified pgprot
+ * @vma: user vma to map to
+ * @addr: target user address of this page
+ * @pfn: source kernel pfn
+ * @pgprot: pgprot flags for the inserted page
+ *
+ * This is exactly like vmf_insert_pfn(), except that it allows drivers to
+ * to override pgprot on a per-page basis.
+ *
+ * This only makes sense for IO mappings, and it makes no sense for
+ * COW mappings.  In general, using multiple vmas is preferable;
+ * vm_insert_pfn_prot should only be used if using multiple VMAs is
+ * impractical.
+ *
+ * Return: vm_fault_t value.
+ */
+vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn, pgprot_t pgprot)
+{
+	int err = vm_insert_pfn_prot(vma, addr, pfn, pgprot);
+
+	if (err == -ENOMEM)
+		return VM_FAULT_OOM;
+	if (err < 0 && err != -EBUSY)
+		return VM_FAULT_SIGBUS;
+
+	return VM_FAULT_NOPAGE;
+}
+EXPORT_SYMBOL(vmf_insert_pfn_prot);
 
 static bool vm_mixed_ok(struct vm_area_struct *vma, pfn_t pfn)
 {
-- 
2.18.0
