Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 492E16B031D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 10:45:56 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 128so124503633oih.1
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 07:45:56 -0700 (PDT)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id s56si8380632otd.221.2016.11.04.07.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 07:45:55 -0700 (PDT)
From: Juerg Haefliger <juerg.haefliger@hpe.com>
Subject: [RFC PATCH v3 2/2] xpfo: Only put previous userspace pages into the hot cache
Date: Fri,  4 Nov 2016 15:45:34 +0100
Message-Id: <20161104144534.14790-3-juerg.haefliger@hpe.com>
In-Reply-To: <20161104144534.14790-1-juerg.haefliger@hpe.com>
References: <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-1-juerg.haefliger@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu, juerg.haefliger@hpe.com

Allocating a page to userspace that was previously allocated to the
kernel requires an expensive TLB shootdown. To minimize this, we only
put non-kernel pages into the hot cache to favor their allocation.

Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>
---
 include/linux/xpfo.h | 2 ++
 mm/page_alloc.c      | 8 +++++++-
 mm/xpfo.c            | 8 ++++++++
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 77187578ca33..077d1cfadfa2 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -24,6 +24,7 @@ extern void xpfo_alloc_page(struct page *page, int order, gfp_t gfp);
 extern void xpfo_free_page(struct page *page, int order);
 
 extern bool xpfo_page_is_unmapped(struct page *page);
+extern bool xpfo_page_is_kernel(struct page *page);
 
 #else /* !CONFIG_XPFO */
 
@@ -33,6 +34,7 @@ static inline void xpfo_alloc_page(struct page *page, int order, gfp_t gfp) { }
 static inline void xpfo_free_page(struct page *page, int order) { }
 
 static inline bool xpfo_page_is_unmapped(struct page *page) { return false; }
+static inline bool xpfo_page_is_kernel(struct page *page) { return false; }
 
 #endif /* CONFIG_XPFO */
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 100e80e008e2..09ef4f7cfd14 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2440,7 +2440,13 @@ void free_hot_cold_page(struct page *page, bool cold)
 	}
 
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
-	if (!cold)
+	/*
+	 * XPFO: Allocating a page to userspace that was previously allocated
+	 * to the kernel requires an expensive TLB shootdown. To minimize this,
+	 * we only put non-kernel pages into the hot cache to favor their
+	 * allocation.
+	 */
+	if (!cold && !xpfo_page_is_kernel(page))
 		list_add(&page->lru, &pcp->lists[migratetype]);
 	else
 		list_add_tail(&page->lru, &pcp->lists[migratetype]);
diff --git a/mm/xpfo.c b/mm/xpfo.c
index 8e3a6a694b6a..0e447e38008a 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -204,3 +204,11 @@ inline bool xpfo_page_is_unmapped(struct page *page)
 	return test_bit(PAGE_EXT_XPFO_UNMAPPED, &lookup_page_ext(page)->flags);
 }
 EXPORT_SYMBOL(xpfo_page_is_unmapped);
+
+inline bool xpfo_page_is_kernel(struct page *page)
+{
+	if (!static_branch_unlikely(&xpfo_inited))
+		return false;
+
+	return test_bit(PAGE_EXT_XPFO_KERNEL, &lookup_page_ext(page)->flags);
+}
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
