Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A35176B03A3
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 19:29:07 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q189so99086877pgq.17
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 16:29:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s21si12605802pgg.375.2017.04.17.16.29.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 16:29:06 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3HNSgWY142801
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 19:29:05 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29w4j9dqv8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 19:29:05 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 17 Apr 2017 19:29:04 -0400
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH v2 tip/core/rcu 01/11] mm: Rename SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU
Date: Mon, 17 Apr 2017 16:28:48 -0700
In-Reply-To: <20170417232714.GA19013@linux.vnet.ibm.com>
References: <20170417232714.GA19013@linux.vnet.ibm.com>
Message-Id: <1492471738-1377-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, bobby.prani@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

A group of Linux kernel hackers reported chasing a bug that resulted
from their assumption that SLAB_DESTROY_BY_RCU provided an existence
guarantee, that is, that no block from such a slab would be reallocated
during an RCU read-side critical section.  Of course, that is not the
case.  Instead, SLAB_DESTROY_BY_RCU only prevents freeing of an entire
slab of blocks.

However, there is a phrase for this, namely "type safety".  This commit
therefore renames SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU in order
to avoid future instances of this sort of confusion.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <linux-mm@kvack.org>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
[ paulmck: Add comments mentioning the old name, as requested by Eric
  Dumazet, in order to help people familiar with the old name find
  the new one. ]
---
 Documentation/RCU/00-INDEX                      |  2 +-
 Documentation/RCU/rculist_nulls.txt             |  6 +++---
 Documentation/RCU/whatisRCU.txt                 |  3 ++-
 drivers/gpu/drm/i915/i915_gem.c                 |  2 +-
 drivers/gpu/drm/i915/i915_gem_request.h         |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c |  2 +-
 fs/jbd2/journal.c                               |  2 +-
 fs/signalfd.c                                   |  2 +-
 include/linux/dma-fence.h                       |  4 ++--
 include/linux/slab.h                            |  6 ++++--
 include/net/sock.h                              |  2 +-
 kernel/fork.c                                   |  4 ++--
 kernel/signal.c                                 |  2 +-
 mm/kasan/kasan.c                                |  6 +++---
 mm/kmemcheck.c                                  |  2 +-
 mm/rmap.c                                       |  4 ++--
 mm/slab.c                                       |  6 +++---
 mm/slab.h                                       |  4 ++--
 mm/slab_common.c                                |  6 +++---
 mm/slob.c                                       |  6 +++---
 mm/slub.c                                       | 12 ++++++------
 net/dccp/ipv4.c                                 |  2 +-
 net/dccp/ipv6.c                                 |  2 +-
 net/ipv4/tcp_ipv4.c                             |  2 +-
 net/ipv6/tcp_ipv6.c                             |  2 +-
 net/llc/af_llc.c                                |  2 +-
 net/llc/llc_conn.c                              |  4 ++--
 net/llc/llc_sap.c                               |  2 +-
 net/netfilter/nf_conntrack_core.c               |  8 ++++----
 net/smc/af_smc.c                                |  2 +-
 30 files changed, 57 insertions(+), 54 deletions(-)

diff --git a/Documentation/RCU/00-INDEX b/Documentation/RCU/00-INDEX
index f773a264ae02..1672573b037a 100644
--- a/Documentation/RCU/00-INDEX
+++ b/Documentation/RCU/00-INDEX
@@ -17,7 +17,7 @@ rcu_dereference.txt
 rcubarrier.txt
 	- RCU and Unloadable Modules
 rculist_nulls.txt
-	- RCU list primitives for use with SLAB_DESTROY_BY_RCU
+	- RCU list primitives for use with SLAB_TYPESAFE_BY_RCU
 rcuref.txt
 	- Reference-count design for elements of lists/arrays protected by RCU
 rcu.txt
diff --git a/Documentation/RCU/rculist_nulls.txt b/Documentation/RCU/rculist_nulls.txt
index 18f9651ff23d..8151f0195f76 100644
--- a/Documentation/RCU/rculist_nulls.txt
+++ b/Documentation/RCU/rculist_nulls.txt
@@ -1,5 +1,5 @@
 Using hlist_nulls to protect read-mostly linked lists and
-objects using SLAB_DESTROY_BY_RCU allocations.
+objects using SLAB_TYPESAFE_BY_RCU allocations.
 
 Please read the basics in Documentation/RCU/listRCU.txt
 
@@ -7,7 +7,7 @@ Using special makers (called 'nulls') is a convenient way
 to solve following problem :
 
 A typical RCU linked list managing objects which are
-allocated with SLAB_DESTROY_BY_RCU kmem_cache can
+allocated with SLAB_TYPESAFE_BY_RCU kmem_cache can
 use following algos :
 
 1) Lookup algo
@@ -96,7 +96,7 @@ unlock_chain(); // typically a spin_unlock()
 3) Remove algo
 --------------
 Nothing special here, we can use a standard RCU hlist deletion.
-But thanks to SLAB_DESTROY_BY_RCU, beware a deleted object can be reused
+But thanks to SLAB_TYPESAFE_BY_RCU, beware a deleted object can be reused
 very very fast (before the end of RCU grace period)
 
 if (put_last_reference_on(obj) {
diff --git a/Documentation/RCU/whatisRCU.txt b/Documentation/RCU/whatisRCU.txt
index 5cbd8b2395b8..91c912e86915 100644
--- a/Documentation/RCU/whatisRCU.txt
+++ b/Documentation/RCU/whatisRCU.txt
@@ -925,7 +925,8 @@ d.	Do you need RCU grace periods to complete even in the face
 
 e.	Is your workload too update-intensive for normal use of
 	RCU, but inappropriate for other synchronization mechanisms?
-	If so, consider SLAB_DESTROY_BY_RCU.  But please be careful!
+	If so, consider SLAB_TYPESAFE_BY_RCU (which was originally
+	named SLAB_DESTROY_BY_RCU).  But please be careful!
 
 f.	Do you need read-side critical sections that are respected
 	even though they are in the middle of the idle loop, during
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 6908123162d1..3b668895ac24 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -4552,7 +4552,7 @@ i915_gem_load_init(struct drm_i915_private *dev_priv)
 	dev_priv->requests = KMEM_CACHE(drm_i915_gem_request,
 					SLAB_HWCACHE_ALIGN |
 					SLAB_RECLAIM_ACCOUNT |
-					SLAB_DESTROY_BY_RCU);
+					SLAB_TYPESAFE_BY_RCU);
 	if (!dev_priv->requests)
 		goto err_vmas;
 
diff --git a/drivers/gpu/drm/i915/i915_gem_request.h b/drivers/gpu/drm/i915/i915_gem_request.h
index ea511f06efaf..9ee2750e1dde 100644
--- a/drivers/gpu/drm/i915/i915_gem_request.h
+++ b/drivers/gpu/drm/i915/i915_gem_request.h
@@ -493,7 +493,7 @@ static inline struct drm_i915_gem_request *
 __i915_gem_active_get_rcu(const struct i915_gem_active *active)
 {
 	/* Performing a lockless retrieval of the active request is super
-	 * tricky. SLAB_DESTROY_BY_RCU merely guarantees that the backing
+	 * tricky. SLAB_TYPESAFE_BY_RCU merely guarantees that the backing
 	 * slab of request objects will not be freed whilst we hold the
 	 * RCU read lock. It does not guarantee that the request itself
 	 * will not be freed and then *reused*. Viz,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 12647af5a336..e7fb47e84a93 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -1071,7 +1071,7 @@ int ldlm_init(void)
 	ldlm_lock_slab = kmem_cache_create("ldlm_locks",
 					   sizeof(struct ldlm_lock), 0,
 					   SLAB_HWCACHE_ALIGN |
-					   SLAB_DESTROY_BY_RCU, NULL);
+					   SLAB_TYPESAFE_BY_RCU, NULL);
 	if (!ldlm_lock_slab) {
 		kmem_cache_destroy(ldlm_resource_slab);
 		return -ENOMEM;
diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index a1a359bfcc9c..7f8f962454e5 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -2340,7 +2340,7 @@ static int jbd2_journal_init_journal_head_cache(void)
 	jbd2_journal_head_cache = kmem_cache_create("jbd2_journal_head",
 				sizeof(struct journal_head),
 				0,		/* offset */
-				SLAB_TEMPORARY | SLAB_DESTROY_BY_RCU,
+				SLAB_TEMPORARY | SLAB_TYPESAFE_BY_RCU,
 				NULL);		/* ctor */
 	retval = 0;
 	if (!jbd2_journal_head_cache) {
diff --git a/fs/signalfd.c b/fs/signalfd.c
index 270221fcef42..7e3d71109f51 100644
--- a/fs/signalfd.c
+++ b/fs/signalfd.c
@@ -38,7 +38,7 @@ void signalfd_cleanup(struct sighand_struct *sighand)
 	/*
 	 * The lockless check can race with remove_wait_queue() in progress,
 	 * but in this case its caller should run under rcu_read_lock() and
-	 * sighand_cachep is SLAB_DESTROY_BY_RCU, we can safely return.
+	 * sighand_cachep is SLAB_TYPESAFE_BY_RCU, we can safely return.
 	 */
 	if (likely(!waitqueue_active(wqh)))
 		return;
diff --git a/include/linux/dma-fence.h b/include/linux/dma-fence.h
index 6048fa404e57..a5195a7d6f77 100644
--- a/include/linux/dma-fence.h
+++ b/include/linux/dma-fence.h
@@ -229,7 +229,7 @@ static inline struct dma_fence *dma_fence_get_rcu(struct dma_fence *fence)
  *
  * Function returns NULL if no refcount could be obtained, or the fence.
  * This function handles acquiring a reference to a fence that may be
- * reallocated within the RCU grace period (such as with SLAB_DESTROY_BY_RCU),
+ * reallocated within the RCU grace period (such as with SLAB_TYPESAFE_BY_RCU),
  * so long as the caller is using RCU on the pointer to the fence.
  *
  * An alternative mechanism is to employ a seqlock to protect a bunch of
@@ -257,7 +257,7 @@ dma_fence_get_rcu_safe(struct dma_fence * __rcu *fencep)
 		 * have successfully acquire a reference to it. If it no
 		 * longer matches, we are holding a reference to some other
 		 * reallocated pointer. This is possible if the allocator
-		 * is using a freelist like SLAB_DESTROY_BY_RCU where the
+		 * is using a freelist like SLAB_TYPESAFE_BY_RCU where the
 		 * fence remains valid for the RCU grace period, but it
 		 * may be reallocated. When using such allocators, we are
 		 * responsible for ensuring the reference we get is to
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 3c37a8c51921..04a7f7993e67 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -28,7 +28,7 @@
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
 /*
- * SLAB_DESTROY_BY_RCU - **WARNING** READ THIS!
+ * SLAB_TYPESAFE_BY_RCU - **WARNING** READ THIS!
  *
  * This delays freeing the SLAB page by a grace period, it does _NOT_
  * delay object freeing. This means that if you do kmem_cache_free()
@@ -61,8 +61,10 @@
  *
  * rcu_read_lock before reading the address, then rcu_read_unlock after
  * taking the spinlock within the structure expected at that address.
+ *
+ * Note that SLAB_TYPESAFE_BY_RCU was originally named SLAB_DESTROY_BY_RCU.
  */
-#define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
+#define SLAB_TYPESAFE_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
 #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
 #define SLAB_TRACE		0x00200000UL	/* Trace allocations and frees */
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 5e5997654db6..59cdccaa30e7 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -993,7 +993,7 @@ struct smc_hashinfo;
 struct module;
 
 /*
- * caches using SLAB_DESTROY_BY_RCU should let .next pointer from nulls nodes
+ * caches using SLAB_TYPESAFE_BY_RCU should let .next pointer from nulls nodes
  * un-modified. Special care is taken when initializing object to zero.
  */
 static inline void sk_prot_clear_nulls(struct sock *sk, int size)
diff --git a/kernel/fork.c b/kernel/fork.c
index 6c463c80e93d..9330ce24f1bb 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1313,7 +1313,7 @@ void __cleanup_sighand(struct sighand_struct *sighand)
 	if (atomic_dec_and_test(&sighand->count)) {
 		signalfd_cleanup(sighand);
 		/*
-		 * sighand_cachep is SLAB_DESTROY_BY_RCU so we can free it
+		 * sighand_cachep is SLAB_TYPESAFE_BY_RCU so we can free it
 		 * without an RCU grace period, see __lock_task_sighand().
 		 */
 		kmem_cache_free(sighand_cachep, sighand);
@@ -2144,7 +2144,7 @@ void __init proc_caches_init(void)
 {
 	sighand_cachep = kmem_cache_create("sighand_cache",
 			sizeof(struct sighand_struct), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_DESTROY_BY_RCU|
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_TYPESAFE_BY_RCU|
 			SLAB_NOTRACK|SLAB_ACCOUNT, sighand_ctor);
 	signal_cachep = kmem_cache_create("signal_cache",
 			sizeof(struct signal_struct), 0,
diff --git a/kernel/signal.c b/kernel/signal.c
index 7e59ebc2c25e..6df5f72158e4 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1237,7 +1237,7 @@ struct sighand_struct *__lock_task_sighand(struct task_struct *tsk,
 		}
 		/*
 		 * This sighand can be already freed and even reused, but
-		 * we rely on SLAB_DESTROY_BY_RCU and sighand_ctor() which
+		 * we rely on SLAB_TYPESAFE_BY_RCU and sighand_ctor() which
 		 * initializes ->siglock: this slab can't go away, it has
 		 * the same object type, ->siglock can't be reinitialized.
 		 *
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 98b27195e38b..4b20061102f6 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -413,7 +413,7 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 	*size += sizeof(struct kasan_alloc_meta);
 
 	/* Add free meta. */
-	if (cache->flags & SLAB_DESTROY_BY_RCU || cache->ctor ||
+	if (cache->flags & SLAB_TYPESAFE_BY_RCU || cache->ctor ||
 	    cache->object_size < sizeof(struct kasan_free_meta)) {
 		cache->kasan_info.free_meta_offset = *size;
 		*size += sizeof(struct kasan_free_meta);
@@ -561,7 +561,7 @@ static void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 	unsigned long rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
 
 	/* RCU slabs could be legally used after free within the RCU period */
-	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
+	if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
 		return;
 
 	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
@@ -572,7 +572,7 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 	s8 shadow_byte;
 
 	/* RCU slabs could be legally used after free within the RCU period */
-	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
+	if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
 		return false;
 
 	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
diff --git a/mm/kmemcheck.c b/mm/kmemcheck.c
index 5bf191756a4a..2d5959c5f7c5 100644
--- a/mm/kmemcheck.c
+++ b/mm/kmemcheck.c
@@ -95,7 +95,7 @@ void kmemcheck_slab_alloc(struct kmem_cache *s, gfp_t gfpflags, void *object,
 void kmemcheck_slab_free(struct kmem_cache *s, void *object, size_t size)
 {
 	/* TODO: RCU freeing is unsupported for now; hide false positives. */
-	if (!s->ctor && !(s->flags & SLAB_DESTROY_BY_RCU))
+	if (!s->ctor && !(s->flags & SLAB_TYPESAFE_BY_RCU))
 		kmemcheck_mark_freed(object, size);
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 49ed681ccc7b..8ffd59df8a3f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -430,7 +430,7 @@ static void anon_vma_ctor(void *data)
 void __init anon_vma_init(void)
 {
 	anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
-			0, SLAB_DESTROY_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT,
+			0, SLAB_TYPESAFE_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT,
 			anon_vma_ctor);
 	anon_vma_chain_cachep = KMEM_CACHE(anon_vma_chain,
 			SLAB_PANIC|SLAB_ACCOUNT);
@@ -481,7 +481,7 @@ struct anon_vma *page_get_anon_vma(struct page *page)
 	 * If this page is still mapped, then its anon_vma cannot have been
 	 * freed.  But if it has been unmapped, we have no security against the
 	 * anon_vma structure being freed and reused (for another anon_vma:
-	 * SLAB_DESTROY_BY_RCU guarantees that - so the atomic_inc_not_zero()
+	 * SLAB_TYPESAFE_BY_RCU guarantees that - so the atomic_inc_not_zero()
 	 * above cannot corrupt).
 	 */
 	if (!page_mapped(page)) {
diff --git a/mm/slab.c b/mm/slab.c
index 807d86c76908..93c827864862 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1728,7 +1728,7 @@ static void slab_destroy(struct kmem_cache *cachep, struct page *page)
 
 	freelist = page->freelist;
 	slab_destroy_debugcheck(cachep, page);
-	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
+	if (unlikely(cachep->flags & SLAB_TYPESAFE_BY_RCU))
 		call_rcu(&page->rcu_head, kmem_rcu_free);
 	else
 		kmem_freepages(cachep, page);
@@ -1924,7 +1924,7 @@ static bool set_objfreelist_slab_cache(struct kmem_cache *cachep,
 
 	cachep->num = 0;
 
-	if (cachep->ctor || flags & SLAB_DESTROY_BY_RCU)
+	if (cachep->ctor || flags & SLAB_TYPESAFE_BY_RCU)
 		return false;
 
 	left = calculate_slab_order(cachep, size,
@@ -2030,7 +2030,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (size < 4096 || fls(size - 1) == fls(size-1 + REDZONE_ALIGN +
 						2 * sizeof(unsigned long long)))
 		flags |= SLAB_RED_ZONE | SLAB_STORE_USER;
-	if (!(flags & SLAB_DESTROY_BY_RCU))
+	if (!(flags & SLAB_TYPESAFE_BY_RCU))
 		flags |= SLAB_POISON;
 #endif
 #endif
diff --git a/mm/slab.h b/mm/slab.h
index 65e7c3fcac72..9cfcf099709c 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -126,7 +126,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 
 /* Legal flag mask for kmem_cache_create(), for various configurations */
 #define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | SLAB_PANIC | \
-			 SLAB_DESTROY_BY_RCU | SLAB_DEBUG_OBJECTS )
+			 SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS )
 
 #if defined(CONFIG_DEBUG_SLAB)
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
@@ -415,7 +415,7 @@ static inline size_t slab_ksize(const struct kmem_cache *s)
 	 * back there or track user information then we can
 	 * only use the space before that information.
 	 */
-	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
+	if (s->flags & (SLAB_TYPESAFE_BY_RCU | SLAB_STORE_USER))
 		return s->inuse;
 	/*
 	 * Else we can use all the padding etc for the allocation
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 09d0e849b07f..01a0fe2eb332 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -39,7 +39,7 @@ static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
  * Set of flags that will prevent slab merging
  */
 #define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
-		SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
+		SLAB_TRACE | SLAB_TYPESAFE_BY_RCU | SLAB_NOLEAKTRACE | \
 		SLAB_FAILSLAB | SLAB_KASAN)
 
 #define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | \
@@ -500,7 +500,7 @@ static void slab_caches_to_rcu_destroy_workfn(struct work_struct *work)
 	struct kmem_cache *s, *s2;
 
 	/*
-	 * On destruction, SLAB_DESTROY_BY_RCU kmem_caches are put on the
+	 * On destruction, SLAB_TYPESAFE_BY_RCU kmem_caches are put on the
 	 * @slab_caches_to_rcu_destroy list.  The slab pages are freed
 	 * through RCU and and the associated kmem_cache are dereferenced
 	 * while freeing the pages, so the kmem_caches should be freed only
@@ -537,7 +537,7 @@ static int shutdown_cache(struct kmem_cache *s)
 	memcg_unlink_cache(s);
 	list_del(&s->list);
 
-	if (s->flags & SLAB_DESTROY_BY_RCU) {
+	if (s->flags & SLAB_TYPESAFE_BY_RCU) {
 		list_add_tail(&s->list, &slab_caches_to_rcu_destroy);
 		schedule_work(&slab_caches_to_rcu_destroy_work);
 	} else {
diff --git a/mm/slob.c b/mm/slob.c
index eac04d4357ec..1bae78d71096 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -126,7 +126,7 @@ static inline void clear_slob_page_free(struct page *sp)
 
 /*
  * struct slob_rcu is inserted at the tail of allocated slob blocks, which
- * were created with a SLAB_DESTROY_BY_RCU slab. slob_rcu is used to free
+ * were created with a SLAB_TYPESAFE_BY_RCU slab. slob_rcu is used to free
  * the block using call_rcu.
  */
 struct slob_rcu {
@@ -524,7 +524,7 @@ EXPORT_SYMBOL(ksize);
 
 int __kmem_cache_create(struct kmem_cache *c, unsigned long flags)
 {
-	if (flags & SLAB_DESTROY_BY_RCU) {
+	if (flags & SLAB_TYPESAFE_BY_RCU) {
 		/* leave room for rcu footer at the end of object */
 		c->size += sizeof(struct slob_rcu);
 	}
@@ -598,7 +598,7 @@ static void kmem_rcu_free(struct rcu_head *head)
 void kmem_cache_free(struct kmem_cache *c, void *b)
 {
 	kmemleak_free_recursive(b, c->flags);
-	if (unlikely(c->flags & SLAB_DESTROY_BY_RCU)) {
+	if (unlikely(c->flags & SLAB_TYPESAFE_BY_RCU)) {
 		struct slob_rcu *slob_rcu;
 		slob_rcu = b + (c->size - sizeof(struct slob_rcu));
 		slob_rcu->size = c->size;
diff --git a/mm/slub.c b/mm/slub.c
index 7f4bc7027ed5..57e5156f02be 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1687,7 +1687,7 @@ static void rcu_free_slab(struct rcu_head *h)
 
 static void free_slab(struct kmem_cache *s, struct page *page)
 {
-	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU)) {
+	if (unlikely(s->flags & SLAB_TYPESAFE_BY_RCU)) {
 		struct rcu_head *head;
 
 		if (need_reserve_slab_rcu) {
@@ -2963,7 +2963,7 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
 	 * slab_free_freelist_hook() could have put the items into quarantine.
 	 * If so, no need to free them.
 	 */
-	if (s->flags & SLAB_KASAN && !(s->flags & SLAB_DESTROY_BY_RCU))
+	if (s->flags & SLAB_KASAN && !(s->flags & SLAB_TYPESAFE_BY_RCU))
 		return;
 	do_slab_free(s, page, head, tail, cnt, addr);
 }
@@ -3433,7 +3433,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	 * the slab may touch the object after free or before allocation
 	 * then we should never poison the object itself.
 	 */
-	if ((flags & SLAB_POISON) && !(flags & SLAB_DESTROY_BY_RCU) &&
+	if ((flags & SLAB_POISON) && !(flags & SLAB_TYPESAFE_BY_RCU) &&
 			!s->ctor)
 		s->flags |= __OBJECT_POISON;
 	else
@@ -3455,7 +3455,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	 */
 	s->inuse = size;
 
-	if (((flags & (SLAB_DESTROY_BY_RCU | SLAB_POISON)) ||
+	if (((flags & (SLAB_TYPESAFE_BY_RCU | SLAB_POISON)) ||
 		s->ctor)) {
 		/*
 		 * Relocate free pointer after the object if it is not
@@ -3537,7 +3537,7 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 	s->flags = kmem_cache_flags(s->size, flags, s->name, s->ctor);
 	s->reserved = 0;
 
-	if (need_reserve_slab_rcu && (s->flags & SLAB_DESTROY_BY_RCU))
+	if (need_reserve_slab_rcu && (s->flags & SLAB_TYPESAFE_BY_RCU))
 		s->reserved = sizeof(struct rcu_head);
 
 	if (!calculate_sizes(s, -1))
@@ -5042,7 +5042,7 @@ SLAB_ATTR_RO(cache_dma);
 
 static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", !!(s->flags & SLAB_DESTROY_BY_RCU));
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_TYPESAFE_BY_RCU));
 }
 SLAB_ATTR_RO(destroy_by_rcu);
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 409d0cfd3447..90210a0e3888 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -950,7 +950,7 @@ static struct proto dccp_v4_prot = {
 	.orphan_count		= &dccp_orphan_count,
 	.max_header		= MAX_DCCP_HEADER,
 	.obj_size		= sizeof(struct dccp_sock),
-	.slab_flags		= SLAB_DESTROY_BY_RCU,
+	.slab_flags		= SLAB_TYPESAFE_BY_RCU,
 	.rsk_prot		= &dccp_request_sock_ops,
 	.twsk_prot		= &dccp_timewait_sock_ops,
 	.h.hashinfo		= &dccp_hashinfo,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 233b57367758..b4019a5e4551 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1012,7 +1012,7 @@ static struct proto dccp_v6_prot = {
 	.orphan_count	   = &dccp_orphan_count,
 	.max_header	   = MAX_DCCP_HEADER,
 	.obj_size	   = sizeof(struct dccp6_sock),
-	.slab_flags	   = SLAB_DESTROY_BY_RCU,
+	.slab_flags	   = SLAB_TYPESAFE_BY_RCU,
 	.rsk_prot	   = &dccp6_request_sock_ops,
 	.twsk_prot	   = &dccp6_timewait_sock_ops,
 	.h.hashinfo	   = &dccp_hashinfo,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9a89b8deafae..82c89abeb989 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2398,7 +2398,7 @@ struct proto tcp_prot = {
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp_sock),
-	.slab_flags		= SLAB_DESTROY_BY_RCU,
+	.slab_flags		= SLAB_TYPESAFE_BY_RCU,
 	.twsk_prot		= &tcp_timewait_sock_ops,
 	.rsk_prot		= &tcp_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 60a5295a7de6..bdbc4327ebee 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1919,7 +1919,7 @@ struct proto tcpv6_prot = {
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp6_sock),
-	.slab_flags		= SLAB_DESTROY_BY_RCU,
+	.slab_flags		= SLAB_TYPESAFE_BY_RCU,
 	.twsk_prot		= &tcp6_timewait_sock_ops,
 	.rsk_prot		= &tcp6_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 06186d608a27..d096ca563054 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -142,7 +142,7 @@ static struct proto llc_proto = {
 	.name	  = "LLC",
 	.owner	  = THIS_MODULE,
 	.obj_size = sizeof(struct llc_sock),
-	.slab_flags = SLAB_DESTROY_BY_RCU,
+	.slab_flags = SLAB_TYPESAFE_BY_RCU,
 };
 
 /**
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 8bc5a1bd2d45..9b02c13d258b 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -506,7 +506,7 @@ static struct sock *__llc_lookup_established(struct llc_sap *sap,
 again:
 	sk_nulls_for_each_rcu(rc, node, laddr_hb) {
 		if (llc_estab_match(sap, daddr, laddr, rc)) {
-			/* Extra checks required by SLAB_DESTROY_BY_RCU */
+			/* Extra checks required by SLAB_TYPESAFE_BY_RCU */
 			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
 				goto again;
 			if (unlikely(llc_sk(rc)->sap != sap ||
@@ -565,7 +565,7 @@ static struct sock *__llc_lookup_listener(struct llc_sap *sap,
 again:
 	sk_nulls_for_each_rcu(rc, node, laddr_hb) {
 		if (llc_listener_match(sap, laddr, rc)) {
-			/* Extra checks required by SLAB_DESTROY_BY_RCU */
+			/* Extra checks required by SLAB_TYPESAFE_BY_RCU */
 			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
 				goto again;
 			if (unlikely(llc_sk(rc)->sap != sap ||
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 5404d0d195cc..63b6ab056370 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -328,7 +328,7 @@ static struct sock *llc_lookup_dgram(struct llc_sap *sap,
 again:
 	sk_nulls_for_each_rcu(rc, node, laddr_hb) {
 		if (llc_dgram_match(sap, laddr, rc)) {
-			/* Extra checks required by SLAB_DESTROY_BY_RCU */
+			/* Extra checks required by SLAB_TYPESAFE_BY_RCU */
 			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
 				goto again;
 			if (unlikely(llc_sk(rc)->sap != sap ||
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 071b97fcbefb..fdcdac7916b2 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -914,7 +914,7 @@ static unsigned int early_drop_list(struct net *net,
 			continue;
 
 		/* kill only if still in same netns -- might have moved due to
-		 * SLAB_DESTROY_BY_RCU rules.
+		 * SLAB_TYPESAFE_BY_RCU rules.
 		 *
 		 * We steal the timer reference.  If that fails timer has
 		 * already fired or someone else deleted it. Just drop ref
@@ -1069,7 +1069,7 @@ __nf_conntrack_alloc(struct net *net,
 
 	/*
 	 * Do not use kmem_cache_zalloc(), as this cache uses
-	 * SLAB_DESTROY_BY_RCU.
+	 * SLAB_TYPESAFE_BY_RCU.
 	 */
 	ct = kmem_cache_alloc(nf_conntrack_cachep, gfp);
 	if (ct == NULL)
@@ -1114,7 +1114,7 @@ void nf_conntrack_free(struct nf_conn *ct)
 	struct net *net = nf_ct_net(ct);
 
 	/* A freed object has refcnt == 0, that's
-	 * the golden rule for SLAB_DESTROY_BY_RCU
+	 * the golden rule for SLAB_TYPESAFE_BY_RCU
 	 */
 	NF_CT_ASSERT(atomic_read(&ct->ct_general.use) == 0);
 
@@ -1878,7 +1878,7 @@ int nf_conntrack_init_start(void)
 	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
 						sizeof(struct nf_conn),
 						NFCT_INFOMASK + 1,
-						SLAB_DESTROY_BY_RCU | SLAB_HWCACHE_ALIGN, NULL);
+						SLAB_TYPESAFE_BY_RCU | SLAB_HWCACHE_ALIGN, NULL);
 	if (!nf_conntrack_cachep)
 		goto err_cachep;
 
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 85837ab90e89..d34bbd6d8f38 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -101,7 +101,7 @@ struct proto smc_proto = {
 	.unhash		= smc_unhash_sk,
 	.obj_size	= sizeof(struct smc_sock),
 	.h.smc_hash	= &smc_v4_hashinfo,
-	.slab_flags	= SLAB_DESTROY_BY_RCU,
+	.slab_flags	= SLAB_TYPESAFE_BY_RCU,
 };
 EXPORT_SYMBOL_GPL(smc_proto);
 
-- 
2.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
