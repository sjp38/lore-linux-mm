Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 26DE26B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 10:47:14 -0500 (EST)
Received: by oixx65 with SMTP id x65so26889536oix.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:47:14 -0800 (PST)
Received: from m50-135.163.com (m50-135.163.com. [123.125.50.135])
        by mx.google.com with ESMTP id xx7si3799076oec.47.2015.12.02.07.47.12
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 07:47:13 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 1/3] mm/slab: use list_first_entry_or_null()
Date: Wed,  2 Dec 2015 23:46:11 +0800
Message-Id: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Simplify the code with list_first_entry_or_null().

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/slab.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 4765c97..6bb0466 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2791,18 +2791,18 @@ retry:
 	}
 
 	while (batchcount > 0) {
-		struct list_head *entry;
 		struct page *page;
 		/* Get slab alloc is to come from. */
-		entry = n->slabs_partial.next;
-		if (entry == &n->slabs_partial) {
+		page = list_first_entry_or_null(&n->slabs_partial,
+				struct page, lru);
+		if (!page) {
 			n->free_touched = 1;
-			entry = n->slabs_free.next;
-			if (entry == &n->slabs_free)
+			page = list_first_entry_or_null(&n->slabs_free,
+					struct page, lru);
+			if (!page)
 				goto must_grow;
 		}
 
-		page = list_entry(entry, struct page, lru);
 		check_spinlock_acquired(cachep);
 
 		/*
@@ -3085,7 +3085,6 @@ retry:
 static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 				int nodeid)
 {
-	struct list_head *entry;
 	struct page *page;
 	struct kmem_cache_node *n;
 	void *obj;
@@ -3098,15 +3097,16 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 retry:
 	check_irq_off();
 	spin_lock(&n->list_lock);
-	entry = n->slabs_partial.next;
-	if (entry == &n->slabs_partial) {
+	page = list_first_entry_or_null(&n->slabs_partial,
+			struct page, lru);
+	if (!page) {
 		n->free_touched = 1;
-		entry = n->slabs_free.next;
-		if (entry == &n->slabs_free)
+		page = list_first_entry_or_null(&n->slabs_free,
+				struct page, lru);
+		if (!page)
 			goto must_grow;
 	}
 
-	page = list_entry(entry, struct page, lru);
 	check_spinlock_acquired_node(cachep, nodeid);
 
 	STATS_INC_NODEALLOCS(cachep);
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
