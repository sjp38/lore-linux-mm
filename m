Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B65FF8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:10:33 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t2so8661081pfj.15
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:10:33 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b89si9544153pfj.207.2019.01.10.13.10.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:10:32 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v7 04/16] swiotlb: Map the buffer if it was unmapped by XPFO
Date: Thu, 10 Jan 2019 14:09:36 -0700
Message-Id: <98f9b9be522d694d5a52640dd1dfbdd14ca6f8e5.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tycho Andersen <tycho@docker.com>, Khalid Aziz <khalid.aziz@oracle.com>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

v6: * guard against lookup_xpfo() returning NULL

CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 include/linux/xpfo.h |  4 ++++
 kernel/dma/swiotlb.c |  3 ++-
 mm/xpfo.c            | 15 +++++++++++++++
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index a39259ce0174..e38b823f44e3 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -35,6 +35,8 @@ void xpfo_kunmap(void *kaddr, struct page *page);
 void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp);
 void xpfo_free_pages(struct page *page, int order);
 
+bool xpfo_page_is_unmapped(struct page *page);
+
 #else /* !CONFIG_XPFO */
 
 static inline void xpfo_kmap(void *kaddr, struct page *page) { }
@@ -42,6 +44,8 @@ static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
 static inline void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp) { }
 static inline void xpfo_free_pages(struct page *page, int order) { }
 
+static inline bool xpfo_page_is_unmapped(struct page *page) { return false; }
+
 #endif /* CONFIG_XPFO */
 
 #endif /* _LINUX_XPFO_H */
diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index 045930e32c0e..820a54b57491 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -396,8 +396,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
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
2.17.1
