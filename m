Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1C8F6B0026
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a21so1393402pfo.8
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e66-v6si358070plb.499.2018.04.18.11.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:25 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 13/14] slab,slub: Remove rcu_head size checks
Date: Wed, 18 Apr 2018 11:49:11 -0700
Message-Id: <20180418184912.2851-14-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

rcu_head may now grow larger than list_head without affecting slab or
slub.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/slab.c |  2 --
 mm/slub.c | 27 ++-------------------------
 2 files changed, 2 insertions(+), 27 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index e387a17d6d56..e6ab1327db25 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1235,8 +1235,6 @@ void __init kmem_cache_init(void)
 {
 	int i;
 
-	BUILD_BUG_ON(sizeof(((struct page *)NULL)->lru) <
-					sizeof(struct rcu_head));
 	kmem_cache = &kmem_cache_boot;
 
 	if (!IS_ENABLED(CONFIG_NUMA) || num_possible_nodes() == 1)
diff --git a/mm/slub.c b/mm/slub.c
index f2f64568b25e..8af8ce91062a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1691,17 +1691,9 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	__free_pages(page, order);
 }
 
-#define need_reserve_slab_rcu						\
-	(sizeof(((struct page *)NULL)->lru) < sizeof(struct rcu_head))
-
 static void rcu_free_slab(struct rcu_head *h)
 {
-	struct page *page;
-
-	if (need_reserve_slab_rcu)
-		page = virt_to_head_page(h);
-	else
-		page = container_of((struct list_head *)h, struct page, lru);
+	struct page *page = container_of(h, struct page, rcu_head);
 
 	__free_slab(page->slab_cache, page);
 }
@@ -1709,19 +1701,7 @@ static void rcu_free_slab(struct rcu_head *h)
 static void free_slab(struct kmem_cache *s, struct page *page)
 {
 	if (unlikely(s->flags & SLAB_TYPESAFE_BY_RCU)) {
-		struct rcu_head *head;
-
-		if (need_reserve_slab_rcu) {
-			int order = compound_order(page);
-			int offset = (PAGE_SIZE << order) - s->reserved;
-
-			VM_BUG_ON(s->reserved != sizeof(*head));
-			head = page_address(page) + offset;
-		} else {
-			head = &page->rcu_head;
-		}
-
-		call_rcu(head, rcu_free_slab);
+		call_rcu(&page->rcu_head, rcu_free_slab);
 	} else
 		__free_slab(s, page);
 }
@@ -3588,9 +3568,6 @@ static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
 	s->random = get_random_long();
 #endif
 
-	if (need_reserve_slab_rcu && (s->flags & SLAB_TYPESAFE_BY_RCU))
-		s->reserved = sizeof(struct rcu_head);
-
 	if (!calculate_sizes(s, -1))
 		goto error;
 	if (disable_higher_order_debug) {
-- 
2.17.0
