Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BEEC28E0008
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:11:00 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id u20so8688970pfa.1
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:11:00 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id s123si7078247pfb.274.2019.01.10.13.10.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:10:59 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v7 11/16] mm, x86: omit TLB flushing by default for XPFO page table modifications
Date: Thu, 10 Jan 2019 14:09:43 -0700
Message-Id: <4e51a5d4409b54116968b8c0501f6d82c4eb9cb5.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, "Vasileios P . Kemerlis" <vpk@cs.columbia.edu>, Juerg Haefliger <juerg.haefliger@canonical.com>, Tycho Andersen <tycho@docker.com>, Marco Benatto <marco.antonio.780@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Khalid Aziz <khalid.aziz@oracle.com>

From: Julian Stecklina <jsteckli@amazon.de>

XPFO carries a large performance overhead. In my tests, I saw >40%
overhead for compiling a Linux kernel with XPFO enabled. The
frequent TLB flushes that XPFO performs are the root cause of much
of this overhead.

TLB flushing is required for full paranoia mode where we don't want
TLB entries of physmap pages to stick around potentially
indefinitely. In reality, though, these TLB entries are going to be
evicted pretty rapidly even without explicit flushing. That means
omitting TLB flushes only marginally lowers the security benefits of
XPFO. For kernel compile, omitting TLB flushes pushes the overhead
below 3%.

Change the default in XPFO to not flush TLBs unless the user
explicitly requests to do so using a kernel parameter.

Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Cc: x86@kernel.org
Cc: kernel-hardening@lists.openwall.com
Cc: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>
Cc: Tycho Andersen <tycho@docker.com>
Cc: Marco Benatto <marco.antonio.780@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 mm/xpfo.c | 37 +++++++++++++++++++++++++++++--------
 1 file changed, 29 insertions(+), 8 deletions(-)

diff --git a/mm/xpfo.c b/mm/xpfo.c
index 25fba05d01bd..e80374b0c78e 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -36,6 +36,7 @@ struct xpfo {
 };
 
 DEFINE_STATIC_KEY_FALSE(xpfo_inited);
+DEFINE_STATIC_KEY_FALSE(xpfo_do_tlb_flush);
 
 static bool xpfo_disabled __initdata;
 
@@ -46,7 +47,15 @@ static int __init noxpfo_param(char *str)
 	return 0;
 }
 
+static int __init xpfotlbflush_param(char *str)
+{
+	static_branch_enable(&xpfo_do_tlb_flush);
+
+	return 0;
+}
+
 early_param("noxpfo", noxpfo_param);
+early_param("xpfotlbflush", xpfotlbflush_param);
 
 static bool __init need_xpfo(void)
 {
@@ -76,6 +85,13 @@ bool __init xpfo_enabled(void)
 }
 EXPORT_SYMBOL(xpfo_enabled);
 
+
+static void xpfo_cond_flush_kernel_tlb(struct page *page, int order)
+{
+	if (static_branch_unlikely(&xpfo_do_tlb_flush))
+		xpfo_flush_kernel_tlb(page, order);
+}
+
 static inline struct xpfo *lookup_xpfo(struct page *page)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
@@ -114,12 +130,17 @@ void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
 		     "xpfo: already mapped page being allocated\n");
 
 		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
-			/*
-			 * Tag the page as a user page and flush the TLB if it
-			 * was previously allocated to the kernel.
-			 */
-			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
-				flush_tlb = 1;
+			if (static_branch_unlikely(&xpfo_do_tlb_flush)) {
+				/*
+				 * Tag the page as a user page and flush the TLB if it
+				 * was previously allocated to the kernel.
+				 */
+				if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
+					flush_tlb = 1;
+			} else {
+				set_bit(XPFO_PAGE_USER, &xpfo->flags);
+			}
+
 		} else {
 			/* Tag the page as a non-user (kernel) page */
 			clear_bit(XPFO_PAGE_USER, &xpfo->flags);
@@ -127,7 +148,7 @@ void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
 	}
 
 	if (flush_tlb)
-		xpfo_flush_kernel_tlb(page, order);
+		xpfo_cond_flush_kernel_tlb(page, order);
 }
 
 void xpfo_free_pages(struct page *page, int order)
@@ -221,7 +242,7 @@ void xpfo_kunmap(void *kaddr, struct page *page)
 		     "xpfo: unmapping already unmapped page\n");
 		set_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
 		set_kpte(kaddr, page, __pgprot(0));
-		xpfo_flush_kernel_tlb(page, 0);
+		xpfo_cond_flush_kernel_tlb(page, 0);
 	}
 
 	spin_unlock(&xpfo->maplock);
-- 
2.17.1
