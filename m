Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 881FD6B0037
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 01:57:49 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [REPOST PATCH 4/4] slab: make more slab management structure off the slab
Date: Fri,  6 Sep 2013 14:57:47 +0900
Message-Id: <1378447067-19832-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, the size of the freelist for the slab management diminish,
so that the on-slab management structure can waste large space
if the object of the slab is large.

Consider a 128 byte sized slab. If on-slab is used, 31 objects can be
in the slab. The size of the freelist for this case would be 31 bytes
so that 97 bytes, that is, more than 75% of object size, are wasted.

In a 64 byte sized slab case, no space is wasted if we use on-slab.
So set off-slab determining constraint to 128 bytes.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index bd366e5..d01a2f0 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2277,7 +2277,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 * it too early on. Always use on-slab management when
 	 * SLAB_NOLEAKTRACE to avoid recursive calls into kmemleak)
 	 */
-	if ((size >= (PAGE_SIZE >> 3)) && !slab_early_init &&
+	if ((size >= (PAGE_SIZE >> 5)) && !slab_early_init &&
 	    !(flags & SLAB_NOLEAKTRACE))
 		/*
 		 * Size is large, assume best to place the slab management obj
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
