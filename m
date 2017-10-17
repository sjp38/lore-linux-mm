Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1B46B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 18:30:05 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e195so3014721itc.20
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 15:30:05 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c130sor5512571iof.205.2017.10.17.15.30.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 15:30:04 -0700 (PDT)
Date: Tue, 17 Oct 2017 15:30:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, slab: only set __GFP_RECLAIMABLE once
Message-ID: <alpine.DEB.2.10.1710171527560.140898@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

SLAB_RECLAIM_ACCOUNT is a permanent attribute of a slab cache.  Set 
__GFP_RECLAIMABLE as part of its ->allocflags rather than check the cachep 
flag on every page allocation.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slab.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1409,8 +1409,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	int nr_pages;
 
 	flags |= cachep->allocflags;
-	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
-		flags |= __GFP_RECLAIMABLE;
 
 	page = __alloc_pages_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
 	if (!page) {
@@ -2143,6 +2141,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	cachep->allocflags = __GFP_COMP;
 	if (flags & SLAB_CACHE_DMA)
 		cachep->allocflags |= GFP_DMA;
+	if (flags & SLAB_RECLAIM_ACCOUNT)
+		cachep->allocflags |= __GFP_RECLAIMABLE;
 	cachep->size = size;
 	cachep->reciprocal_buffer_size = reciprocal_value(size);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
