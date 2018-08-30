Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F47C6B50F2
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 06:43:27 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q12-v6so4858954pgp.6
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 03:43:27 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id b19-v6si7014816pfb.89.2018.08.30.03.43.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 03:43:26 -0700 (PDT)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] mm/slub.c: Switch to bitmap_zalloc()
Date: Thu, 30 Aug 2018 13:43:01 +0300
Message-Id: <20180830104301.61649-1-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Switch to bitmap_zalloc() to show clearly what we are allocating.
Besides that it returns pointer of bitmap type instead of opaque void *.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 mm/slub.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ce2b9e5cea77..8d85a38425fd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3622,9 +3622,7 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 #ifdef CONFIG_SLUB_DEBUG
 	void *addr = page_address(page);
 	void *p;
-	unsigned long *map = kcalloc(BITS_TO_LONGS(page->objects),
-				     sizeof(long),
-				     GFP_ATOMIC);
+	unsigned long *map = bitmap_zalloc(page->objects, GFP_ATOMIC);
 	if (!map)
 		return;
 	slab_err(s, page, text, s->name);
@@ -3639,7 +3637,7 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 		}
 	}
 	slab_unlock(page);
-	kfree(map);
+	bitmap_free(map);
 #endif
 }
 
@@ -4412,10 +4410,8 @@ static long validate_slab_cache(struct kmem_cache *s)
 {
 	int node;
 	unsigned long count = 0;
-	unsigned long *map = kmalloc_array(BITS_TO_LONGS(oo_objects(s->max)),
-					   sizeof(unsigned long),
-					   GFP_KERNEL);
 	struct kmem_cache_node *n;
+	unsigned long *map = bitmap_alloc(oo_objects(s->max), GFP_KERNEL);
 
 	if (!map)
 		return -ENOMEM;
@@ -4423,7 +4419,7 @@ static long validate_slab_cache(struct kmem_cache *s)
 	flush_all(s);
 	for_each_kmem_cache_node(s, node, n)
 		count += validate_slab_node(s, n, map);
-	kfree(map);
+	bitmap_free(map);
 	return count;
 }
 /*
@@ -4574,14 +4570,12 @@ static int list_locations(struct kmem_cache *s, char *buf,
 	unsigned long i;
 	struct loc_track t = { 0, 0, NULL };
 	int node;
-	unsigned long *map = kmalloc_array(BITS_TO_LONGS(oo_objects(s->max)),
-					   sizeof(unsigned long),
-					   GFP_KERNEL);
 	struct kmem_cache_node *n;
+	unsigned long *map = bitmap_alloc(oo_objects(s->max), GFP_KERNEL);
 
 	if (!map || !alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
 				     GFP_KERNEL)) {
-		kfree(map);
+		bitmap_free(map);
 		return sprintf(buf, "Out of memory\n");
 	}
 	/* Push back cpu slabs */
@@ -4647,7 +4641,7 @@ static int list_locations(struct kmem_cache *s, char *buf,
 	}
 
 	free_loc_track(&t);
-	kfree(map);
+	bitmap_free(map);
 	if (!t.count)
 		len += sprintf(buf, "No data\n");
 	return len;
-- 
2.18.0
