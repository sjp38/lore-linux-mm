Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E82BF6B0263
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:51:52 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bx7so6045880pad.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:52 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id kk8si7885648pab.26.2016.04.11.21.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 21:51:52 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id e128so6194387pfe.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:52 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 07/11] mm/slab: racy access/modify the slab color
Date: Tue, 12 Apr 2016 13:51:02 +0900
Message-Id: <1460436666-20462-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Slab color isn't needed to be changed strictly.  Because locking for
changing slab color could cause more lock contention so this patch
implements racy access/modify the slab color.  This is a preparation step
to implement lockless allocation path when there is no free objects in the
kmem_cache.

Below is the result of concurrent allocation/free in slab allocation
benchmark made by Christoph a long time ago.  I make the output simpler.
The number shows cycle count during alloc/free respectively so less is
better.

* Before
Kmalloc N*alloc N*free(32): Average=365/806
Kmalloc N*alloc N*free(64): Average=452/690
Kmalloc N*alloc N*free(128): Average=736/886
Kmalloc N*alloc N*free(256): Average=1167/985
Kmalloc N*alloc N*free(512): Average=2088/1125
Kmalloc N*alloc N*free(1024): Average=4115/1184
Kmalloc N*alloc N*free(2048): Average=8451/1748
Kmalloc N*alloc N*free(4096): Average=16024/2048

* After
Kmalloc N*alloc N*free(32): Average=355/750
Kmalloc N*alloc N*free(64): Average=452/812
Kmalloc N*alloc N*free(128): Average=559/1070
Kmalloc N*alloc N*free(256): Average=1176/980
Kmalloc N*alloc N*free(512): Average=1939/1189
Kmalloc N*alloc N*free(1024): Average=3521/1278
Kmalloc N*alloc N*free(2048): Average=7152/1838
Kmalloc N*alloc N*free(4096): Average=13438/2013

It shows that contention is reduced for object size >= 1024 and
performance increases by roughly 15%.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 6e61461..a3422bc 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2561,20 +2561,7 @@ static int cache_grow(struct kmem_cache *cachep,
 	}
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
-	/* Take the node list lock to change the colour_next on this node */
 	check_irq_off();
-	n = get_node(cachep, nodeid);
-	spin_lock(&n->list_lock);
-
-	/* Get colour for the slab, and cal the next value. */
-	offset = n->colour_next;
-	n->colour_next++;
-	if (n->colour_next >= cachep->colour)
-		n->colour_next = 0;
-	spin_unlock(&n->list_lock);
-
-	offset *= cachep->colour_off;
-
 	if (gfpflags_allow_blocking(local_flags))
 		local_irq_enable();
 
@@ -2595,6 +2582,19 @@ static int cache_grow(struct kmem_cache *cachep,
 	if (!page)
 		goto failed;
 
+	n = get_node(cachep, nodeid);
+
+	/* Get colour for the slab, and cal the next value. */
+	n->colour_next++;
+	if (n->colour_next >= cachep->colour)
+		n->colour_next = 0;
+
+	offset = n->colour_next;
+	if (offset >= cachep->colour)
+		offset = 0;
+
+	offset *= cachep->colour_off;
+
 	/* Get slab management. */
 	freelist = alloc_slabmgmt(cachep, page, offset,
 			local_flags & ~GFP_CONSTRAINT_MASK, nodeid);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
