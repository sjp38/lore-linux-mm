Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8470A6B0267
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:52:06 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id ot11so6108598pab.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:52:06 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id k67si7635215pfk.75.2016.04.11.21.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 21:52:05 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id c20so6244966pfc.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:52:05 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 11/11] mm/slab: lockless decision to grow cache
Date: Tue, 12 Apr 2016 13:51:06 +0900
Message-Id: <1460436666-20462-12-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

To check whther free objects exist or not precisely, we need to grab a
lock.  But, accuracy isn't that important because race window would be
even small and if there is too much free object, cache reaper would reap
it.  So, this patch makes the check for free object exisistence not to
hold a lock.  This will reduce lock contention in heavily allocation case.

Note that until now, n->shared can be freed during the processing by
writing slabinfo, but, with some trick in this patch, we can access it
freely within interrupt disabled period.

Below is the result of concurrent allocation/free in slab allocation
benchmark made by Christoph a long time ago.  I make the output simpler.
The number shows cycle count during alloc/free respectively so less is
better.

* Before
Kmalloc N*alloc N*free(32): Average=248/966
Kmalloc N*alloc N*free(64): Average=261/949
Kmalloc N*alloc N*free(128): Average=314/1016
Kmalloc N*alloc N*free(256): Average=741/1061
Kmalloc N*alloc N*free(512): Average=1246/1152
Kmalloc N*alloc N*free(1024): Average=2437/1259
Kmalloc N*alloc N*free(2048): Average=4980/1800
Kmalloc N*alloc N*free(4096): Average=9000/2078

* After
Kmalloc N*alloc N*free(32): Average=344/792
Kmalloc N*alloc N*free(64): Average=347/882
Kmalloc N*alloc N*free(128): Average=390/959
Kmalloc N*alloc N*free(256): Average=393/1067
Kmalloc N*alloc N*free(512): Average=683/1229
Kmalloc N*alloc N*free(1024): Average=1295/1325
Kmalloc N*alloc N*free(2048): Average=2513/1664
Kmalloc N*alloc N*free(4096): Average=4742/2172

It shows that allocation performance decreases for the object size up to
128 and it may be due to extra checks in cache_alloc_refill().  But, with
considering improvement of free performance, net result looks the same.
Result for other size class looks very promising, roughly, 50% performance
improvement.

v2: replace kick_all_cpus_sync() with synchronize_sched().

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index cf12fbd..13e74aa 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -952,6 +952,15 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
 	spin_unlock_irq(&n->list_lock);
 	slabs_destroy(cachep, &list);
 
+	/*
+	 * To protect lockless access to n->shared during irq disabled context.
+	 * If n->shared isn't NULL in irq disabled context, accessing to it is
+	 * guaranteed to be valid until irq is re-enabled, because it will be
+	 * freed after synchronize_sched().
+	 */
+	if (force_change)
+		synchronize_sched();
+
 fail:
 	kfree(old_shared);
 	kfree(new_shared);
@@ -2880,7 +2889,7 @@ static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
 {
 	int batchcount;
 	struct kmem_cache_node *n;
-	struct array_cache *ac;
+	struct array_cache *ac, *shared;
 	int node;
 	void *list = NULL;
 	struct page *page;
@@ -2901,11 +2910,16 @@ static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
 	n = get_node(cachep, node);
 
 	BUG_ON(ac->avail > 0 || !n);
+	shared = READ_ONCE(n->shared);
+	if (!n->free_objects && (!shared || !shared->avail))
+		goto direct_grow;
+
 	spin_lock(&n->list_lock);
+	shared = READ_ONCE(n->shared);
 
 	/* See if we can refill from the shared array */
-	if (n->shared && transfer_objects(ac, n->shared, batchcount)) {
-		n->shared->touched = 1;
+	if (shared && transfer_objects(ac, shared, batchcount)) {
+		shared->touched = 1;
 		goto alloc_done;
 	}
 
@@ -2927,6 +2941,7 @@ alloc_done:
 	spin_unlock(&n->list_lock);
 	fixup_objfreelist_debug(cachep, &list);
 
+direct_grow:
 	if (unlikely(!ac->avail)) {
 		/* Check if we can use obj in pfmemalloc slab */
 		if (sk_memalloc_socks()) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
