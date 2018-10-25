Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 47AB16B027B
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 05:45:32 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 87-v6so6029517pfq.8
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 02:45:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z31-v6sor2926595plb.35.2018.10.25.02.45.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 02:45:31 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 1/3] mm, slub: not retrieve cpu_slub again in new_slab_objects()
Date: Thu, 25 Oct 2018 17:44:35 +0800
Message-Id: <20181025094437.18951-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

In current code, the following context always meets:

  local_irq_save/disable()
    ___slab_alloc()
      new_slab_objects()
  local_irq_restore/enable()

This context ensures cpu will continue running until it finish this job
before yield its control, which means the cpu_slab retrieved in
new_slab_objects() is the same as passed in.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ce2b9e5cea77..11e49d95e0ac 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2402,10 +2402,9 @@ slab_out_of_memory(struct kmem_cache *s, gfp_t gfpflags, int nid)
 }
 
 static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
-			int node, struct kmem_cache_cpu **pc)
+			int node, struct kmem_cache_cpu *c)
 {
 	void *freelist;
-	struct kmem_cache_cpu *c = *pc;
 	struct page *page;
 
 	WARN_ON_ONCE(s->ctor && (flags & __GFP_ZERO));
@@ -2417,7 +2416,6 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 
 	page = new_slab(s, flags, node);
 	if (page) {
-		c = raw_cpu_ptr(s->cpu_slab);
 		if (c->page)
 			flush_slab(s, c);
 
@@ -2430,7 +2428,6 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 
 		stat(s, ALLOC_SLAB);
 		c->page = page;
-		*pc = c;
 	} else
 		freelist = NULL;
 
@@ -2567,7 +2564,7 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 		goto redo;
 	}
 
-	freelist = new_slab_objects(s, gfpflags, node, &c);
+	freelist = new_slab_objects(s, gfpflags, node, c);
 
 	if (unlikely(!freelist)) {
 		slab_out_of_memory(s, gfpflags, node);
-- 
2.15.1
