Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 793F76B0257
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 09:08:43 -0500 (EST)
Received: by oixx65 with SMTP id x65so49068448oix.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 06:08:43 -0800 (PST)
Received: from m50-135.163.com (m50-135.163.com. [123.125.50.135])
        by mx.google.com with ESMTP id s74si7859484oie.136.2015.12.03.06.08.25
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 06:08:42 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH v2] mm/slab.c: use list_{empty_careful,last_entry} in drain_freelist
Date: Thu,  3 Dec 2015 22:07:46 +0800
Message-Id: <3ea815dc52bf1a2bb5e324d7398315597900be84.1449151365.git.geliangtang@163.com>
In-Reply-To: <alpine.DEB.2.20.1512021005120.28955@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To make the intention clearer, use list_empty_careful and list_last_entry
in drain_freelist().

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/slab.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 5d5aa3b..925921e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2362,7 +2362,6 @@ static void drain_cpu_caches(struct kmem_cache *cachep)
 static int drain_freelist(struct kmem_cache *cache,
 			struct kmem_cache_node *n, int tofree)
 {
-	struct list_head *p;
 	int nr_freed;
 	struct page *page;
 
@@ -2370,13 +2369,12 @@ static int drain_freelist(struct kmem_cache *cache,
 	while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
 
 		spin_lock_irq(&n->list_lock);
-		p = n->slabs_free.prev;
-		if (p == &n->slabs_free) {
+		if (list_empty_careful(&n->slabs_free)) {
 			spin_unlock_irq(&n->list_lock);
 			goto out;
 		}
 
-		page = list_entry(p, struct page, lru);
+		page = list_last_entry(&n->slabs_free, struct page, lru);
 #if DEBUG
 		BUG_ON(page->active);
 #endif
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
