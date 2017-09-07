Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8A406B02F7
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 13:37:08 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f64so266059itf.4
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 10:37:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 74sor107357ioq.139.2017.09.07.10.37.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Sep 2017 10:37:07 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [PATCH v6 04/11] swiotlb: Map the buffer if it was unmapped by XPFO
Date: Thu,  7 Sep 2017 11:36:02 -0600
Message-Id: <20170907173609.22696-5-tycho@docker.com>
In-Reply-To: <20170907173609.22696-1-tycho@docker.com>
References: <20170907173609.22696-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tycho Andersen <tycho@docker.com>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

v6: * guard against lookup_xpfo() returning NULL

CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
---
 include/linux/xpfo.h |  4 ++++
 lib/swiotlb.c        |  3 ++-
 mm/xpfo.c            | 15 +++++++++++++++
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 442c58ee930e..04590d1dcefa 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -30,6 +30,8 @@ void xpfo_kunmap(void *kaddr, struct page *page);
 void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp);
 void xpfo_free_pages(struct page *page, int order);
 
+bool xpfo_page_is_unmapped(struct page *page);
+
 #else /* !CONFIG_XPFO */
 
 static inline void xpfo_kmap(void *kaddr, struct page *page) { }
@@ -37,6 +39,8 @@ static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
 static inline void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp) { }
 static inline void xpfo_free_pages(struct page *page, int order) { }
 
+static inline bool xpfo_page_is_unmapped(struct page *page) { return false; }
+
 #endif /* CONFIG_XPFO */
 
 #endif /* _LINUX_XPFO_H */
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index a8d74a733a38..d4fee5ca2d9e 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -420,8 +420,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
 {
 	unsigned long pfn = PFN_DOWN(orig_addr);
 	unsigned char *vaddr = phys_to_virt(tlb_addr);
+	struct page *page = pfn_to_page(pfn);
 
-	if (PageHighMem(pfn_to_page(pfn))) {
+	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
 		/* The buffer does not have a mapping.  Map it in and copy */
 		unsigned int offset = orig_addr & ~PAGE_MASK;
 		char *buffer;
diff --git a/mm/xpfo.c b/mm/xpfo.c
index bff24afcaa2e..cdbcbac582d5 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -220,3 +220,18 @@ void xpfo_kunmap(void *kaddr, struct page *page)
 	spin_unlock(&xpfo->maplock);
 }
 EXPORT_SYMBOL(xpfo_kunmap);
+
+bool xpfo_page_is_unmapped(struct page *page)
+{
+	struct xpfo *xpfo;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return false;
+
+	xpfo = lookup_xpfo(page);
+	if (unlikely(!xpfo) && !xpfo->inited)
+		return false;
+
+	return test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+}
+EXPORT_SYMBOL(xpfo_page_is_unmapped);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
