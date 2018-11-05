Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 059A46B000C
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 03:58:28 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b3-v6so9413364plr.17
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 00:58:27 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 16si17376912pgh.58.2018.11.05.00.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 00:58:26 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH 2/2] mm/page_alloc: use a single function to free page
Date: Mon,  5 Nov 2018 16:58:20 +0800
Message-Id: <20181105085820.6341-2-aaron.lu@intel.com>
In-Reply-To: <20181105085820.6341-1-aaron.lu@intel.com>
References: <20181105085820.6341-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?q?Pawe=C5=82=20Staszewski?= <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>

We have multiple places of freeing a page, most of them doing similar
things and a common function can be used to reduce code duplicate.

It also avoids bug fixed in one function and left in another.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/page_alloc.c | 37 +++++++++++++++++--------------------
 1 file changed, 17 insertions(+), 20 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 91a9a6af41a2..2b330296e92a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4425,9 +4425,17 @@ unsigned long get_zeroed_page(gfp_t gfp_mask)
 }
 EXPORT_SYMBOL(get_zeroed_page);
 
-void __free_pages(struct page *page, unsigned int order)
+/*
+ * Free a page by reducing its ref count by @nr.
+ * If its refcount reaches 0, then according to its order:
+ * order0: send to PCP;
+ * high order: directly send to Buddy.
+ */
+static inline void free_the_page(struct page *page, unsigned int order, int nr)
 {
-	if (put_page_testzero(page)) {
+	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
+
+	if (page_ref_sub_and_test(page, nr)) {
 		if (order == 0)
 			free_unref_page(page);
 		else
@@ -4435,6 +4443,11 @@ void __free_pages(struct page *page, unsigned int order)
 	}
 }
 
+void __free_pages(struct page *page, unsigned int order)
+{
+	free_the_page(page, order, 1);
+}
+
 EXPORT_SYMBOL(__free_pages);
 
 void free_pages(unsigned long addr, unsigned int order)
@@ -4481,16 +4494,7 @@ static struct page *__page_frag_cache_refill(struct page_frag_cache *nc,
 
 void __page_frag_cache_drain(struct page *page, unsigned int count)
 {
-	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
-
-	if (page_ref_sub_and_test(page, count)) {
-		unsigned int order = compound_order(page);
-
-		if (order == 0)
-			free_unref_page(page);
-		else
-			__free_pages_ok(page, order);
-	}
+	free_the_page(page, compound_order(page), count);
 }
 EXPORT_SYMBOL(__page_frag_cache_drain);
 
@@ -4555,14 +4559,7 @@ void page_frag_free(void *addr)
 {
 	struct page *page = virt_to_head_page(addr);
 
-	if (unlikely(put_page_testzero(page))) {
-		unsigned int order = compound_order(page);
-
-		if (order == 0)
-			free_unref_page(page);
-		else
-			__free_pages_ok(page, order);
-	}
+	free_the_page(page, compound_order(page), 1);
 }
 EXPORT_SYMBOL(page_frag_free);
 
-- 
2.17.2
