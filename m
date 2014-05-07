Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E4BE66B0039
	for <linux-mm@kvack.org>; Wed,  7 May 2014 02:04:39 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id fa1so666295pad.20
        for <linux-mm@kvack.org>; Tue, 06 May 2014 23:04:39 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id pq7si13181625pac.317.2014.05.06.23.04.37
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 23:04:38 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 01/10] slab: add unlikely macro to help compiler
Date: Wed,  7 May 2014 15:06:11 +0900
Message-Id: <1399442780-28748-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

slab_should_failslab() is called on every allocation, so to optimize it
is reasonable. We normally don't allocate from kmem_cache. It is just
used when new kmem_cache is created, so it's very rare case. Therefore,
add unlikely macro to help compiler optimization.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 25317fd..1fede40 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2993,7 +2993,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 
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
