Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A047C6B02E1
	for <linux-mm@kvack.org>; Sat,  6 May 2017 23:12:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b67so36999542pfk.0
        for <linux-mm@kvack.org>; Sat, 06 May 2017 20:12:40 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 7si5929896pgc.393.2017.05.06.20.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 May 2017 20:12:39 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id v14so5443647pfd.3
        for <linux-mm@kvack.org>; Sat, 06 May 2017 20:12:39 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/2] mm/slub: reset cpu_slab's pointer in deactivate_slab()
Date: Sun,  7 May 2017 11:12:15 +0800
Message-Id: <20170507031215.3130-2-richard.weiyang@gmail.com>
In-Reply-To: <20170507031215.3130-1-richard.weiyang@gmail.com>
References: <20170507031215.3130-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

Each time a slab is deactivated, the page and freelist pointer should be
reset.

This patch just merges these two options into deactivate_slab().

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 83332f19d226..9e4e682243a1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1993,7 +1993,7 @@ static void init_kmem_cache_cpus(struct kmem_cache *s)
  * Remove the cpu slab
  */
 static void deactivate_slab(struct kmem_cache *s, struct page *page,
-				void *freelist)
+				void *freelist, struct kmem_cache_cpu *c)
 {
 	enum slab_modes { M_NONE, M_PARTIAL, M_FULL, M_FREE };
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
@@ -2132,6 +2132,9 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 		discard_slab(s, page);
 		stat(s, FREE_SLAB);
 	}
+
+	c->page = NULL;
+	c->freelist = NULL;
 }
 
 /*
@@ -2266,11 +2269,9 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
 	stat(s, CPUSLAB_FLUSH);
-	deactivate_slab(s, c->page, c->freelist);
+	deactivate_slab(s, c->page, c->freelist, c);
 
 	c->tid = next_tid(c->tid);
-	c->page = NULL;
-	c->freelist = NULL;
 }
 
 /*
@@ -2521,9 +2522,7 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 
 		if (unlikely(!node_match(page, searchnode))) {
 			stat(s, ALLOC_NODE_MISMATCH);
-			deactivate_slab(s, page, c->freelist);
-			c->page = NULL;
-			c->freelist = NULL;
+			deactivate_slab(s, page, c->freelist, c);
 			goto new_slab;
 		}
 	}
@@ -2534,9 +2533,7 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 	 * information when the page leaves the per-cpu allocator
 	 */
 	if (unlikely(!pfmemalloc_match(page, gfpflags))) {
-		deactivate_slab(s, page, c->freelist);
-		c->page = NULL;
-		c->freelist = NULL;
+		deactivate_slab(s, page, c->freelist, c);
 		goto new_slab;
 	}
 
@@ -2591,9 +2588,7 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 			!alloc_debug_processing(s, page, freelist, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
-	deactivate_slab(s, page, get_freepointer(s, freelist));
-	c->page = NULL;
-	c->freelist = NULL;
+	deactivate_slab(s, page, get_freepointer(s, freelist), c);
 	return freelist;
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
