Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 601B76B0271
	for <linux-mm@kvack.org>; Fri,  4 May 2018 14:33:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b64so17978026pfl.13
        for <linux-mm@kvack.org>; Fri, 04 May 2018 11:33:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b5-v6si16824272plm.202.2018.05.04.11.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 11:33:27 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 14/17] slab,slub: Remove rcu_head size checks
Date: Fri,  4 May 2018 11:33:15 -0700
Message-Id: <20180504183318.14415-15-willy@infradead.org>
In-Reply-To: <20180504183318.14415-1-willy@infradead.org>
References: <20180504183318.14415-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

rcu_head may now grow larger than list_head without affecting slab or
slub.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Christoph Lameter <cl@linux.com>
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
index 57a20f995220..8e2407f69855 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1681,17 +1681,9 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
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
@@ -1699,19 +1691,7 @@ static void rcu_free_slab(struct rcu_head *h)
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
@@ -3578,9 +3558,6 @@ static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
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
