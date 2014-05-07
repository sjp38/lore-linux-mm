Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id BE53F6B0039
	for <linux-mm@kvack.org>; Wed,  7 May 2014 02:04:40 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so665054pab.19
        for <linux-mm@kvack.org>; Tue, 06 May 2014 23:04:40 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id yb4si1280267pbb.231.2014.05.06.23.04.37
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 23:04:38 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 05/10] slab: factor out initialization of arracy cache
Date: Wed,  7 May 2014 15:06:15 +0900
Message-Id: <1399442780-28748-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Factor out initialization of array cache to use it in following patch.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 7647728..755fb57 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -741,13 +741,8 @@ static void start_cpu_timer(int cpu)
 	}
 }
 
-static struct array_cache *alloc_arraycache(int node, int entries,
-					    int batchcount, gfp_t gfp)
+static void init_arraycache(struct array_cache *ac, int limit, int batch)
 {
-	int memsize = sizeof(void *) * entries + sizeof(struct array_cache);
-	struct array_cache *nc = NULL;
-
-	nc = kmalloc_node(memsize, gfp, node);
 	/*
 	 * The array_cache structures contain pointers to free object.
 	 * However, when such objects are allocated or transferred to another
@@ -755,15 +750,25 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 	 * valid references during a kmemleak scan. Therefore, kmemleak must
 	 * not scan such objects.
 	 */
-	kmemleak_no_scan(nc);
-	if (nc) {
-		nc->avail = 0;
-		nc->limit = entries;
-		nc->batchcount = batchcount;
-		nc->touched = 0;
-		spin_lock_init(&nc->lock);
+	kmemleak_no_scan(ac);
+	if (ac) {
+		ac->avail = 0;
+		ac->limit = limit;
+		ac->batchcount = batch;
+		ac->touched = 0;
+		spin_lock_init(&ac->lock);
 	}
-	return nc;
+}
+
+static struct array_cache *alloc_arraycache(int node, int entries,
+					    int batchcount, gfp_t gfp)
+{
+	int memsize = sizeof(void *) * entries + sizeof(struct array_cache);
+	struct array_cache *ac = NULL;
+
+	ac = kmalloc_node(memsize, gfp, node);
+	init_arraycache(ac, entries, batchcount);
+	return ac;
 }
 
 static inline bool is_slab_pfmemalloc(struct page *page)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
