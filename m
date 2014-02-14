Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 057F16B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:57:26 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so11534883pdj.40
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:57:26 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id cb2si1827616pbb.244.2014.02.13.22.57.25
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 22:57:26 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/9] slab: add unlikely macro to help compiler
Date: Fri, 14 Feb 2014 15:57:15 +0900
Message-Id: <1392361043-22420-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

slab_should_failslab() is called on every allocation, so to optimize it
is reasonable. We normally don't allocate from kmem_cache. It is just
used when new kmem_cache is created, so it's very rare case. Therefore,
add unlikely macro to help compiler optimization.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 8347d80..5906f8f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3009,7 +3009,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 
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
