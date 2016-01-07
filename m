Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3F45C6B0008
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 09:03:56 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id e32so237753954qgf.3
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 06:03:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c191si86096950qhc.74.2016.01.07.06.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 06:03:55 -0800 (PST)
Subject: [PATCH 04/10] slab: use slab_pre_alloc_hook in SLAB allocator
 shared with SLUB
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 07 Jan 2016 15:03:53 +0100
Message-ID: <20160107140353.28907.45217.stgit@firesoul>
In-Reply-To: <20160107140253.28907.5469.stgit@firesoul>
References: <20160107140253.28907.5469.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Dedublicate code in SLAB allocator functions slab_alloc() and
slab_alloc_node() by using the slab_pre_alloc_hook() call, which
is now shared between SLUB and SLAB.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.c |   18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d5b29e7bee81..17fd6268ad41 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3140,15 +3140,10 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	void *ptr;
 	int slab_node = numa_mem_id();
 
-	flags &= gfp_allowed_mask;
-
-	lockdep_trace_alloc(flags);
-
-	if (should_failslab(cachep, flags))
+	cachep = slab_pre_alloc_hook(cachep, flags);
+	if (!cachep)
 		return NULL;
 
-	cachep = memcg_kmem_get_cache(cachep, flags);
-
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
 
@@ -3228,15 +3223,10 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	unsigned long save_flags;
 	void *objp;
 
-	flags &= gfp_allowed_mask;
-
-	lockdep_trace_alloc(flags);
-
-	if (should_failslab(cachep, flags))
+	cachep = slab_pre_alloc_hook(cachep, flags);
+	if (!cachep)
 		return NULL;
 
-	cachep = memcg_kmem_get_cache(cachep, flags);
-
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
 	objp = __do_cache_alloc(cachep, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
