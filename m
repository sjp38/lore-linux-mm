Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7570C6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 04:22:33 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id uq10so5227832igb.0
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 01:22:33 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ce7si26112061pad.113.2014.07.01.01.22.31
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 01:22:32 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 1/9] slab: add unlikely macro to help compiler
Date: Tue,  1 Jul 2014 17:27:30 +0900
Message-Id: <1404203258-8923-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

slab_should_failslab() is called on every allocation, so to optimize it
is reasonable. We normally don't allocate from kmem_cache. It is just
used when new kmem_cache is created, so it's very rare case. Therefore,
add unlikely macro to help compiler optimization.

Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 179272f..f8a0ed1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3067,7 +3067,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 
 static bool slab_should_failslab(struct kmem_cache *cachep, gfp_t flags)
 {
-	if (cachep == kmem_cache)
+	if (unlikely(cachep == kmem_cache))
 		return false;
 
 	return should_failslab(cachep->object_size, flags, cachep->flags);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
