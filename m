Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id A74D86B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 03:12:13 -0500 (EST)
Received: by mail-lf0-f41.google.com with SMTP id l143so48797811lfe.2
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 00:12:13 -0800 (PST)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTP id mk3si6043727lbc.28.2016.02.19.00.12.12
        for <linux-mm@kvack.org>;
        Fri, 19 Feb 2016 00:12:12 -0800 (PST)
From: Rabin Vincent <rabin.vincent@axis.com>
Subject: [PATCH 1/2] mm: cma: split out in_cma check to separate function
Date: Fri, 19 Feb 2016 09:12:03 +0100
Message-Id: <1455869524-13874-1-git-send-email-rabin.vincent@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk
Cc: mina86@mina86.com, akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>

Split out the logic in cma_release() which checks if the page is in the
contiguous area to a new function which can be called separately.  ARM
will use this.

Signed-off-by: Rabin Vincent <rabin.vincent@axis.com>
---
 include/linux/cma.h | 12 ++++++++++++
 mm/cma.c            | 27 +++++++++++++++++++--------
 2 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index 29f9e77..6e7fd2d 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -27,5 +27,17 @@ extern int cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 					unsigned int order_per_bit,
 					struct cma **res_cma);
 extern struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align);
+
 extern bool cma_release(struct cma *cma, const struct page *pages, unsigned int count);
+#ifdef CONFIG_CMA
+extern bool in_cma(struct cma *cma, const struct page *pages,
+		   unsigned int count);
+#else
+static inline bool in_cma(struct cma *cma, const struct page *pages,
+			  unsigned int count)
+{
+	return false;
+}
+#endif
+
 #endif
diff --git a/mm/cma.c b/mm/cma.c
index ea506eb..55cda16 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -426,6 +426,23 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
 	return page;
 }
 
+bool in_cma(struct cma *cma, const struct page *pages, unsigned int count)
+{
+	unsigned long pfn;
+
+	if (!cma || !pages)
+		return false;
+
+	pfn = page_to_pfn(pages);
+
+	if (pfn < cma->base_pfn || pfn >= cma->base_pfn + cma->count)
+		return false;
+
+	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
+
+	return true;
+}
+
 /**
  * cma_release() - release allocated pages
  * @cma:   Contiguous memory region for which the allocation is performed.
@@ -440,18 +457,12 @@ bool cma_release(struct cma *cma, const struct page *pages, unsigned int count)
 {
 	unsigned long pfn;
 
-	if (!cma || !pages)
-		return false;
-
 	pr_debug("%s(page %p)\n", __func__, (void *)pages);
 
-	pfn = page_to_pfn(pages);
-
-	if (pfn < cma->base_pfn || pfn >= cma->base_pfn + cma->count)
+	if (!in_cma(cma, pages, count))
 		return false;
 
-	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
-
+	pfn = page_to_pfn(pages);
 	free_contig_range(pfn, count);
 	cma_clear_bitmap(cma, pfn, count);
 	trace_cma_release(pfn, pages, count);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
