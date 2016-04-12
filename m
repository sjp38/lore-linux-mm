Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id EE1A56B0253
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:51:31 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id zm5so6127211pac.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:31 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id f63si7631796pfj.137.2016.04.11.21.51.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 21:51:31 -0700 (PDT)
Received: by mail-pa0-x22d.google.com with SMTP id bx7so6040240pad.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:31 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 01/11] mm/slab: fix the theoretical race by holding proper lock
Date: Tue, 12 Apr 2016 13:50:56 +0900
Message-Id: <1460436666-20462-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

While processing concurrent allocation, SLAB could be contended a lot
because it did a lots of work with holding a lock.  This patchset try to
reduce the number of critical section to reduce lock contention.  Major
changes are lockless decision to allocate more slab and lockless cpu cache
refill from the newly allocated slab.

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
Kmalloc N*alloc N*free(32): Average=344/792
Kmalloc N*alloc N*free(64): Average=347/882
Kmalloc N*alloc N*free(128): Average=390/959
Kmalloc N*alloc N*free(256): Average=393/1067
Kmalloc N*alloc N*free(512): Average=683/1229
Kmalloc N*alloc N*free(1024): Average=1295/1325
Kmalloc N*alloc N*free(2048): Average=2513/1664
Kmalloc N*alloc N*free(4096): Average=4742/2172

It shows that performance improves greatly (roughly more than 50%) for the
object class whose size is more than 128 bytes.

This patch (of 11):

If we don't hold neither the slab_mutex nor the node lock, node's shared
array cache could be freed and re-populated. If __kmem_cache_shrink() is
called at the same time, it will call drain_array() with n->shared without
holding node lock so problem can happen. This patch fix the situation by
holding the node lock before trying to drain the shared array.

In addition, add a debug check to confirm that n->shared access race
doesn't exist.

v2:
o Hold the node lock instead of holding the slab_mutex (per Christoph)
o Add a debug check rather than adding code comment (per Nikolay)

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 68 ++++++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 45 insertions(+), 23 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a53a0f6..d8746c0 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2173,6 +2173,11 @@ static void check_irq_on(void)
 	BUG_ON(irqs_disabled());
 }
 
+static void check_mutex_acquired(void)
+{
+	BUG_ON(!mutex_is_locked(&slab_mutex));
+}
+
 static void check_spinlock_acquired(struct kmem_cache *cachep)
 {
 #ifdef CONFIG_SMP
@@ -2192,13 +2197,27 @@ static void check_spinlock_acquired_node(struct kmem_cache *cachep, int node)
 #else
 #define check_irq_off()	do { } while(0)
 #define check_irq_on()	do { } while(0)
+#define check_mutex_acquired()	do { } while(0)
 #define check_spinlock_acquired(x) do { } while(0)
 #define check_spinlock_acquired_node(x, y) do { } while(0)
 #endif
 
-static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
-			struct array_cache *ac,
-			int force, int node);
+static void drain_array_locked(struct kmem_cache *cachep, struct array_cache *ac,
+				int node, bool free_all, struct list_head *list)
+{
+	int tofree;
+
+	if (!ac || !ac->avail)
+		return;
+
+	tofree = free_all ? ac->avail : (ac->limit + 4) / 5;
+	if (tofree > ac->avail)
+		tofree = (ac->avail + 1) / 2;
+
+	free_block(cachep, ac->entry, tofree, node, list);
+	ac->avail -= tofree;
+	memmove(ac->entry, &(ac->entry[tofree]), sizeof(void *) * ac->avail);
+}
 
 static void do_drain(void *arg)
 {
@@ -2222,6 +2241,7 @@ static void drain_cpu_caches(struct kmem_cache *cachep)
 {
 	struct kmem_cache_node *n;
 	int node;
+	LIST_HEAD(list);
 
 	on_each_cpu(do_drain, cachep, 1);
 	check_irq_on();
@@ -2229,8 +2249,13 @@ static void drain_cpu_caches(struct kmem_cache *cachep)
 		if (n->alien)
 			drain_alien_cache(cachep, n->alien);
 
-	for_each_kmem_cache_node(cachep, node, n)
-		drain_array(cachep, n, n->shared, 1, node);
+	for_each_kmem_cache_node(cachep, node, n) {
+		spin_lock_irq(&n->list_lock);
+		drain_array_locked(cachep, n->shared, node, true, &list);
+		spin_unlock_irq(&n->list_lock);
+
+		slabs_destroy(cachep, &list);
+	}
 }
 
 /*
@@ -3873,29 +3898,26 @@ skip_setup:
  * if drain_array() is used on the shared array.
  */
 static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
-			 struct array_cache *ac, int force, int node)
+			 struct array_cache *ac, int node)
 {
 	LIST_HEAD(list);
-	int tofree;
+
+	/* ac from n->shared can be freed if we don't hold the slab_mutex. */
+	check_mutex_acquired();
 
 	if (!ac || !ac->avail)
 		return;
-	if (ac->touched && !force) {
+
+	if (ac->touched) {
 		ac->touched = 0;
-	} else {
-		spin_lock_irq(&n->list_lock);
-		if (ac->avail) {
-			tofree = force ? ac->avail : (ac->limit + 4) / 5;
-			if (tofree > ac->avail)
-				tofree = (ac->avail + 1) / 2;
-			free_block(cachep, ac->entry, tofree, node, &list);
-			ac->avail -= tofree;
-			memmove(ac->entry, &(ac->entry[tofree]),
-				sizeof(void *) * ac->avail);
-		}
-		spin_unlock_irq(&n->list_lock);
-		slabs_destroy(cachep, &list);
+		return;
 	}
+
+	spin_lock_irq(&n->list_lock);
+	drain_array_locked(cachep, ac, node, false, &list);
+	spin_unlock_irq(&n->list_lock);
+
+	slabs_destroy(cachep, &list);
 }
 
 /**
@@ -3933,7 +3955,7 @@ static void cache_reap(struct work_struct *w)
 
 		reap_alien(searchp, n);
 
-		drain_array(searchp, n, cpu_cache_get(searchp), 0, node);
+		drain_array(searchp, n, cpu_cache_get(searchp), node);
 
 		/*
 		 * These are racy checks but it does not matter
@@ -3944,7 +3966,7 @@ static void cache_reap(struct work_struct *w)
 
 		n->next_reap = jiffies + REAPTIMEOUT_NODE;
 
-		drain_array(searchp, n, n->shared, 0, node);
+		drain_array(searchp, n, n->shared, node);
 
 		if (n->free_touched)
 			n->free_touched = 0;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
