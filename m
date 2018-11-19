Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 499B16B1A3D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:48:45 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 143so17846355pgc.3
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:48:45 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id v189si38253742pgb.398.2018.11.19.05.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 05:48:44 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v3 RESEND 2/2] mm/page_alloc: use a single function to free page
Date: Mon, 19 Nov 2018 21:48:34 +0800
Message-Id: <20181119134834.17765-3-aaron.lu@intel.com>
In-Reply-To: <20181119134834.17765-1-aaron.lu@intel.com>
References: <20181119134834.17765-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?q?Pawe=C5=82=20Staszewski?= <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Ian Kumlien <ian.kumlien@gmail.com>

There are multiple places of freeing a page, they all do the same
things so a common function can be used to reduce code duplicate.

It also avoids bug fixed in one function but left in another.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/page_alloc.c | 37 ++++++++++++++-----------------------
 1 file changed, 14 insertions(+), 23 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8f8c6b33b637..93cc8e686eca 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4547,16 +4547,19 @@ unsigned long get_zeroed_page(gfp_t gfp_mask)
 }
 EXPORT_SYMBOL(get_zeroed_page);
 
-void __free_pages(struct page *page, unsigned int order)
+static inline void free_the_page(struct page *page, unsigned int order)
 {
-	if (put_page_testzero(page)) {
-		if (order == 0)
-			free_unref_page(page);
-		else
-			__free_pages_ok(page, order);
-	}
+	if (order == 0)
+		free_unref_page(page);
+	else
+		__free_pages_ok(page, order);
 }
 
+void __free_pages(struct page *page, unsigned int order)
+{
+	if (put_page_testzero(page))
+		free_the_page(page, order);
+}
 EXPORT_SYMBOL(__free_pages);
 
 void free_pages(unsigned long addr, unsigned int order)
@@ -4605,14 +4608,8 @@ void __page_frag_cache_drain(struct page *page, unsigned int count)
 {
 	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
 
-	if (page_ref_sub_and_test(page, count)) {
-		unsigned int order = compound_order(page);
-
-		if (order == 0)
-			free_unref_page(page);
-		else
-			__free_pages_ok(page, order);
-	}
+	if (page_ref_sub_and_test(page, count))
+		free_the_page(page, compound_order(page));
 }
 EXPORT_SYMBOL(__page_frag_cache_drain);
 
@@ -4677,14 +4674,8 @@ void page_frag_free(void *addr)
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
+	if (unlikely(put_page_testzero(page)))
+		free_the_page(page, compound_order(page));
 }
 EXPORT_SYMBOL(page_frag_free);
 
-- 
2.17.2
