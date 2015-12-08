Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id CE74B6B025F
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 11:19:44 -0500 (EST)
Received: by qgcc31 with SMTP id c31so23243423qgc.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 08:19:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x66si4068166qhx.17.2015.12.08.08.19.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 08:19:10 -0800 (PST)
Subject: [RFC PATCH V2 9/9] slab: annotate code to generate more compact asm
 code
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 08 Dec 2015 17:19:08 +0100
Message-ID: <20151208161908.21945.177.stgit@firesoul>
In-Reply-To: <20151208161751.21945.53936.stgit@firesoul>
References: <20151208161751.21945.53936.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

Premature optimizations for CONFIG_NUMA case...
---
 mm/slab.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 72c7958b4075..6d79fc5668c4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3185,7 +3185,7 @@ __do_cache_alloc(struct kmem_cache *cache, gfp_t flags)
 {
 	void *objp;
 
-	if (current->mempolicy || cpuset_do_slab_mem_spread()) {
+	if (unlikely(current->mempolicy || cpuset_do_slab_mem_spread())) {
 		objp = alternate_node_alloc(cache, flags);
 		if (objp)
 			goto out;
@@ -3196,7 +3196,7 @@ __do_cache_alloc(struct kmem_cache *cache, gfp_t flags)
 	 * We may just have run out of memory on the local node.
 	 * ____cache_alloc_node() knows how to locate memory on other nodes
 	 */
-	if (!objp)
+	if (unlikely(!objp))
 		objp = ____cache_alloc_node(cache, flags, numa_mem_id());
 
   out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
