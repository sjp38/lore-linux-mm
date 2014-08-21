Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 08C086B0037
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 04:09:27 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so13161639pdi.6
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 01:09:27 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id tx9si35430764pab.20.2014.08.21.01.09.25
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 01:09:26 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 4/5] mm/slab: noinline __ac_put_obj()
Date: Thu, 21 Aug 2014 17:09:21 +0900
Message-Id: <1408608562-20339-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Our intention of __ac_put_obj() is that it doesn't affect anything if
sk_memalloc_socks() is disabled. But, because __ac_put_obj() is too small,
compiler inline it to ac_put_obj() and affect code size of free path.
This patch add noinline keyword for __ac_put_obj() not to distrupt normal
free path at all.

<Before>
nm -S slab-orig.o |
	grep -e "t cache_alloc_refill" -e "T kfree" -e "T kmem_cache_free"

0000000000001e80 00000000000002f5 t cache_alloc_refill
0000000000001230 0000000000000258 T kfree
0000000000000690 000000000000024c T kmem_cache_free

<After>
nm -S slab-patched.o |
	grep -e "t cache_alloc_refill" -e "T kfree" -e "T kmem_cache_free"

0000000000001e00 00000000000002e5 t cache_alloc_refill
00000000000011e0 0000000000000228 T kfree
0000000000000670 0000000000000216 T kmem_cache_free

cache_alloc_refill: 0x2f5->0x2e5
kfree: 0x256->0x228
kmem_cache_free: 0x24c->0x216

code size of each function is reduced slightly.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d364e3f..c9f137f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -785,8 +785,8 @@ static inline void *ac_get_obj(struct kmem_cache *cachep,
 	return objp;
 }
 
-static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
-								void *objp)
+static noinline void *__ac_put_obj(struct kmem_cache *cachep,
+			struct array_cache *ac, void *objp)
 {
 	if (unlikely(pfmemalloc_active)) {
 		/* Some pfmemalloc slabs exist, check if this is one */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
