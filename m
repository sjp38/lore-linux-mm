Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 502D56B005A
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 09:08:32 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH] mm/sl[aou]b: Shrink __kmem_cache_create() parameter lists fix
Date: Wed, 19 Sep 2012 16:08:21 +0300
Message-Id: <1348060101-32288-1-git-send-email-haggaie@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Haggai Eran <haggaie@mellanox.com>

Fixes compilation with CONFIG_DEBUG_PAGEALLOC, which was broken when the align
parameter was removed.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
I encountered a problem compiling linux-next today with the
CONFIG_DEBUG_PAGEALLOC configuration option. This patch solves the problem
by reading the align parameter from the cachep struct, as the original patch
does in other occurences.

 mm/slab.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a23b70f..749c7a9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2477,9 +2477,10 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 			size += BYTES_PER_WORD;
 	}
 #if FORCED_DEBUG && defined(CONFIG_DEBUG_PAGEALLOC)
-	if (size >= malloc_sizes[INDEX_L3 + 1].cs_size
-	    && cachep->object_size > cache_line_size() && ALIGN(size, align) < PAGE_SIZE) {
-		cachep->obj_offset += PAGE_SIZE - ALIGN(size, align);
+	if (size >= malloc_sizes[INDEX_L3 + 1].cs_size &&
+	    cachep->object_size > cache_line_size() &&
+	    ALIGN(size, cachep->align) < PAGE_SIZE) {
+		cachep->obj_offset += PAGE_SIZE - ALIGN(size, cachep->align);
 		size = PAGE_SIZE;
 	}
 #endif
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
