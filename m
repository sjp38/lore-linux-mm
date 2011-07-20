Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CE5FA6B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 08:16:21 -0400 (EDT)
Subject: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 20 Jul 2011 16:16:12 +0400
Message-ID: <20110720121612.28888.38970.stgit@localhost6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

Order of sizeof(struct kmem_cache) can be bigger than PAGE_ALLOC_COSTLY_ORDER,
thus there is a good chance of unsuccessful allocation.
With __GFP_REPEAT buddy-allocator will reclaim/compact memory more aggressively.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/slab.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d96e223..53bddc8 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2304,7 +2304,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 		gfp = GFP_NOWAIT;
 
 	/* Get cache's description obj. */
-	cachep = kmem_cache_zalloc(&cache_cache, gfp);
+	cachep = kmem_cache_zalloc(&cache_cache, gfp | __GFP_REPEAT);
 	if (!cachep)
 		goto oops;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
