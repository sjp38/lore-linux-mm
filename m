Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC016B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 09:14:35 -0500 (EST)
Received: by ioc74 with SMTP id 74so81728524ioc.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 06:14:35 -0800 (PST)
Received: from m50-134.163.com (m50-134.163.com. [123.125.50.134])
        by mx.google.com with ESMTP id kk9si17797255igb.68.2015.12.03.06.14.33
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 06:14:34 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mm/slab.c: add a helper function get_first_slab
Date: Thu,  3 Dec 2015 22:13:28 +0800
Message-Id: <ca810706dcf5cb70ecd3602faa022fc0c9de2487.1449151885.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Add a new helper function get_first_slab() that get the first slab
from a kmem_cache_node.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/slab.c | 39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 925921e..2463b57 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2754,6 +2754,21 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 #define cache_free_debugcheck(x,objp,z) (objp)
 #endif
 
+static struct page *get_first_slab(struct kmem_cache_node *n)
+{
+	struct page *page;
+
+	page = list_first_entry_or_null(&n->slabs_partial,
+			struct page, lru);
+	if (!page) {
+		n->free_touched = 1;
+		page = list_first_entry_or_null(&n->slabs_free,
+				struct page, lru);
+	}
+
+	return page;
+}
+
 static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags,
 							bool force_refill)
 {
@@ -2791,15 +2806,9 @@ retry:
 	while (batchcount > 0) {
 		struct page *page;
 		/* Get slab alloc is to come from. */
-		page = list_first_entry_or_null(&n->slabs_partial,
-				struct page, lru);
-		if (!page) {
-			n->free_touched = 1;
-			page = list_first_entry_or_null(&n->slabs_free,
-					struct page, lru);
-			if (!page)
-				goto must_grow;
-		}
+		page = get_first_slab(n);
+		if (!page)
+			goto must_grow;
 
 		check_spinlock_acquired(cachep);
 
@@ -3095,15 +3104,9 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 retry:
 	check_irq_off();
 	spin_lock(&n->list_lock);
-	page = list_first_entry_or_null(&n->slabs_partial,
-			struct page, lru);
-	if (!page) {
-		n->free_touched = 1;
-		page = list_first_entry_or_null(&n->slabs_free,
-				struct page, lru);
-		if (!page)
-			goto must_grow;
-	}
+	page = get_first_slab(n);
+	if (!page)
+		goto must_grow;
 
 	check_spinlock_acquired_node(cachep, nodeid);
 
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
