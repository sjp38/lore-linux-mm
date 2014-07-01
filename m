Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA7F6B0039
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 04:22:34 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so9712089pde.34
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 01:22:34 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id vc5si22331685pbc.241.2014.07.01.01.22.32
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 01:22:33 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 4/9] slab: factor out initialization of arracy cache
Date: Tue,  1 Jul 2014 17:27:33 +0900
Message-Id: <1404203258-8923-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Factor out initialization of array cache to use it in following patch.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |   33 +++++++++++++++++++--------------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 59b9a4c..00b6bbc 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -791,13 +791,8 @@ static void start_cpu_timer(int cpu)
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
@@ -805,15 +800,25 @@ static struct array_cache *alloc_arraycache(int node, int entries,
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
