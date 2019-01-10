Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E67F08E0008
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:10:37 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id v72so7060575pgb.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:10:37 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w15si3508564plk.357.2019.01.10.13.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:10:36 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v7 08/16] arm64/mm: disable section/contiguous mappings if XPFO is enabled
Date: Thu, 10 Jan 2019 14:09:40 -0700
Message-Id: <3dfdd42afe1749d4f82816f967532643de3a5024.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Tycho Andersen <tycho@docker.com>, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Khalid Aziz <khalid.aziz@oracle.com>

From: Tycho Andersen <tycho@docker.com>

XPFO doesn't support section/contiguous mappings yet, so let's disable it
if XPFO is turned on.

Thanks to Laura Abbot for the simplification from v5, and Mark Rutland for
pointing out we need NO_CONT_MAPPINGS too.

CC: linux-arm-kernel@lists.infradead.org
Signed-off-by: Tycho Andersen <tycho@docker.com>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 arch/arm64/mm/mmu.c  | 2 +-
 include/linux/xpfo.h | 4 ++++
 mm/xpfo.c            | 6 ++++++
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index d1d6601b385d..f4dd27073006 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -451,7 +451,7 @@ static void __init map_mem(pgd_t *pgdp)
 	struct memblock_region *reg;
 	int flags = 0;
 
-	if (debug_pagealloc_enabled())
+	if (debug_pagealloc_enabled() || xpfo_enabled())
 		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
 
 	/*
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 2682a00ebbcb..0c26836a24e1 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -46,6 +46,8 @@ void xpfo_temp_map(const void *addr, size_t size, void **mapping,
 void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
 		     size_t mapping_len);
 
+bool xpfo_enabled(void);
+
 #else /* !CONFIG_XPFO */
 
 static inline void xpfo_kmap(void *kaddr, struct page *page) { }
@@ -68,6 +70,8 @@ static inline void xpfo_temp_unmap(const void *addr, size_t size,
 }
 
 
+static inline bool xpfo_enabled(void) { return false; }
+
 #endif /* CONFIG_XPFO */
 
 #endif /* _LINUX_XPFO_H */
diff --git a/mm/xpfo.c b/mm/xpfo.c
index f79075bf7d65..25fba05d01bd 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -70,6 +70,12 @@ struct page_ext_operations page_xpfo_ops = {
 	.init = init_xpfo,
 };
 
+bool __init xpfo_enabled(void)
+{
+	return !xpfo_disabled;
+}
+EXPORT_SYMBOL(xpfo_enabled);
+
 static inline struct xpfo *lookup_xpfo(struct page *page)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
-- 
2.17.1
