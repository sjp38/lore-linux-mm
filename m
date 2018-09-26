Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5BD38E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 02:52:23 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w18-v6so10276710plp.3
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 23:52:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7-v6sor609359pgt.392.2018.09.25.23.52.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 23:52:22 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCH] mm/slub: disallow obj's allocation on page with mismatched pfmemalloc purpose
Date: Wed, 26 Sep 2018 14:52:08 +0800
Message-Id: <1537944728-18036-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

new_slab_objects() always return c->page matching the required gfpflags,
but the current code is misleading and ___slab_alloc->deactivate_slab seems
to allow not-pfmemalloc purpose obj to be allocated from pfmemalloc-purpose
page. This patch re-organize the code to eliminate the confusion.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slub.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index a68c2ae..e152634 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2551,23 +2551,21 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 	}
 
 	freelist = new_slab_objects(s, gfpflags, node, &c);
-
 	if (unlikely(!freelist)) {
 		slab_out_of_memory(s, gfpflags, node);
 		return NULL;
 	}
 
+	VM_BUG_ON(!pfmemalloc_match(page, gfpflags));
 	page = c->page;
-	if (likely(!kmem_cache_debug(s) && pfmemalloc_match(page, gfpflags)))
+	if (likely(!kmem_cache_debug(s))
 		goto load_freelist;
 
 	/* Only entered in the debug case */
-	if (kmem_cache_debug(s) &&
-			!alloc_debug_processing(s, page, freelist, addr))
+	if (!alloc_debug_processing(s, page, freelist, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
-
-	deactivate_slab(s, page, get_freepointer(s, freelist), c);
-	return freelist;
+	else
+		goto load_freelist;
 }
 
 /*
-- 
2.7.4
