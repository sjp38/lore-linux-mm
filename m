Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC226B0038
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:57:28 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so11561814pde.34
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:57:28 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id to9si4662117pbc.125.2014.02.13.22.57.26
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 22:57:27 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 5/9] slab: factor out initialization of arracy cache
Date: Fri, 14 Feb 2014 15:57:19 +0900
Message-Id: <1392361043-22420-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Factor out initialization of array cache to use it in following patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 551d503..90bfd79 100644
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
