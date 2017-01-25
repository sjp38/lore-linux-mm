Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3A46B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:06:05 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d123so34603648pfd.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:06:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h91si2964850pld.68.2017.01.25.15.06.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 15:06:03 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0PN3jp3053159
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:06:02 -0500
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2871dxr99a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:06:02 -0500
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 25 Jan 2017 16:06:01 -0700
Date: Wed, 25 Jan 2017 15:05:57 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
Reply-To: paulmck@linux.vnet.ibm.com
References: <20170118110731.GA15949@linux.vnet.ibm.com>
 <20170118111201.GB29472@bombadil.infradead.org>
 <20170118221737.GP5238@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1701181758030.27439@east.gentwo.org>
 <20170123004657.GT5238@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1701251045040.983@east.gentwo.org>
 <1485363887.5145.27.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170125200708.GG3989@linux.vnet.ibm.com>
 <1485384377.5145.77.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485384377.5145.77.camel@edumazet-glaptop3.roam.corp.google.com>
Message-Id: <20170125230556.GO3989@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, willy@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Wed, Jan 25, 2017 at 02:46:17PM -0800, Eric Dumazet wrote:
> On Wed, 2017-01-25 at 12:07 -0800, Paul E. McKenney wrote:
> > On Wed, Jan 25, 2017 at 09:04:47AM -0800, Eric Dumazet wrote:
> 
> > > 
> > > Not clear why we need to change this very fine name ?
> > > 
> > > SLAB_DESTROY_BY_RCU was only used by few of us, we know damn well what
> > > it means.
> > > 
> > > Consider we wont be able to change it in various web pages / archives /
> > > changelogs.
> > 
> > The reason I proposed this change is that I ran into some people last
> > week who had burned some months learning that this very fine flag
> > provides only type safety, not identity safety.
> > 
> > Other proposals?
> 
> Bung hunting requires scrapping git log, in particular in areas touching
> RCU (not exactly trivial stuff :) :) :) )
> 
> git log | grep SLAB_DESTROY_BY_RCU 
> 
> A Google search on SLAB_DESTROY_BY_RCU finds ~4600 results.
> 
> If we rename SLAB_DESTROY_BY_RCU by XXXXXXXX, someone trying to see
> prior patches or articles about XXXXXXXX mistakes will find nothing.
> 
> So please leave comments giving the old name ( SLAB_DESTROY_BY_RCU ) and
> save time for future hackers.

Good point!  How about the following diff against the old patch?

------------------------------------------------------------------------

diff --git a/Documentation/RCU/whatisRCU.txt b/Documentation/RCU/whatisRCU.txt
index 12374fa4cff1..91c912e86915 100644
--- a/Documentation/RCU/whatisRCU.txt
+++ b/Documentation/RCU/whatisRCU.txt
@@ -925,7 +925,8 @@ d.	Do you need RCU grace periods to complete even in the face
 
 e.	Is your workload too update-intensive for normal use of
 	RCU, but inappropriate for other synchronization mechanisms?
-	If so, consider SLAB_TYPESAFE_BY_RCU.  But please be careful!
+	If so, consider SLAB_TYPESAFE_BY_RCU (which was originally
+	named SLAB_DESTROY_BY_RCU).  But please be careful!
 
 f.	Do you need read-side critical sections that are respected
 	even though they are in the middle of the idle loop, during
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 708d5b1dc439..f57b6c7cd530 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -61,6 +61,8 @@
  *
  * rcu_read_lock before reading the address, then rcu_read_unlock after
  * taking the spinlock within the structure expected at that address.
+ *
+ * Note that SLAB_TYPESAFE_BY_RCU was originally named SLAB_DESTROY_BY_RCU.
  */
 #define SLAB_TYPESAFE_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
 #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */

------------------------------------------------------------------------

Any other "tombstone" comments needed?

The full patch is shown below for completeness.

							Thanx, Paul

------------------------------------------------------------------------

commit 55f619e5c322171698f0d5aecf5009391ac7e2db
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Wed Jan 18 02:53:44 2017 -0800

    mm: Rename SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU
    
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
    [ paulmck: Add "tombstone" comments as requested by Eric Dumazet. ]

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
index 3dd7fc662859..3871ca092aa6 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -4541,7 +4541,7 @@ i915_gem_load_init(struct drm_device *dev)
 	dev_priv->requests = KMEM_CACHE(drm_i915_gem_request,
 					SLAB_HWCACHE_ALIGN |
 					SLAB_RECLAIM_ACCOUNT |
-					SLAB_DESTROY_BY_RCU);
+					SLAB_TYPESAFE_BY_RCU);
 	if (!dev_priv->requests)
 		goto err_vmas;
 
diff --git a/drivers/gpu/drm/i915/i915_gem_request.h b/drivers/gpu/drm/i915/i915_gem_request.h
index d229f47d1028..50d1075c9dab 100644
--- a/drivers/gpu/drm/i915/i915_gem_request.h
+++ b/drivers/gpu/drm/i915/i915_gem_request.h
@@ -504,7 +504,7 @@ static inline struct drm_i915_gem_request *
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
index a097048ed1a3..8d0cbcc4c877 100644
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
index d51a7d23c358..236fc0dbef39 100644
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
index 084b12bad198..f57b6c7cd530 100644
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
index f0e867f58722..981b0cad8358 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -989,7 +989,7 @@ struct raw_hashinfo;
 struct module;
 
 /*
- * caches using SLAB_DESTROY_BY_RCU should let .next pointer from nulls nodes
+ * caches using SLAB_TYPESAFE_BY_RCU should let .next pointer from nulls nodes
  * un-modified. Special care is taken when initializing object to zero.
  */
 static inline void sk_prot_clear_nulls(struct sock *sk, int size)
diff --git a/kernel/fork.c b/kernel/fork.c
index 11c5c8ab827c..bed8eb2ac981 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1297,7 +1297,7 @@ void __cleanup_sighand(struct sighand_struct *sighand)
 	if (atomic_dec_and_test(&sighand->count)) {
 		signalfd_cleanup(sighand);
 		/*
-		 * sighand_cachep is SLAB_DESTROY_BY_RCU so we can free it
+		 * sighand_cachep is SLAB_TYPESAFE_BY_RCU so we can free it
 		 * without an RCU grace period, see __lock_task_sighand().
 		 */
 		kmem_cache_free(sighand_cachep, sighand);
@@ -2069,7 +2069,7 @@ void __init proc_caches_init(void)
 {
 	sighand_cachep = kmem_cache_create("sighand_cache",
 			sizeof(struct sighand_struct), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_DESTROY_BY_RCU|
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_TYPESAFE_BY_RCU|
 			SLAB_NOTRACK|SLAB_ACCOUNT, sighand_ctor);
 	signal_cachep = kmem_cache_create("signal_cache",
 			sizeof(struct signal_struct), 0,
diff --git a/kernel/signal.c b/kernel/signal.c
index ff046b73ff2d..48b252238059 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1232,7 +1232,7 @@ struct sighand_struct *__lock_task_sighand(struct task_struct *tsk,
 		}
 		/*
 		 * This sighand can be already freed and even reused, but
-		 * we rely on SLAB_DESTROY_BY_RCU and sighand_ctor() which
+		 * we rely on SLAB_TYPESAFE_BY_RCU and sighand_ctor() which
 		 * initializes ->siglock: this slab can't go away, it has
 		 * the same object type, ->siglock can't be reinitialized.
 		 *
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index b2a0cff2bb35..8f380e4e5cfe 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -402,7 +402,7 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 	*size += sizeof(struct kasan_alloc_meta);
 
 	/* Add free meta. */
-	if (cache->flags & SLAB_DESTROY_BY_RCU || cache->ctor ||
+	if (cache->flags & SLAB_TYPESAFE_BY_RCU || cache->ctor ||
 	    cache->object_size < sizeof(struct kasan_free_meta)) {
 		cache->kasan_info.free_meta_offset = *size;
 		*size += sizeof(struct kasan_free_meta);
@@ -550,7 +550,7 @@ static void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 	unsigned long rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
 
 	/* RCU slabs could be legally used after free within the RCU period */
-	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
+	if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
 		return;
 
 	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
@@ -561,7 +561,7 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
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
index 91619fd70939..c48e9c18c8ff 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -428,7 +428,7 @@ static void anon_vma_ctor(void *data)
 void __init anon_vma_init(void)
 {
 	anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
-			0, SLAB_DESTROY_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT,
+			0, SLAB_TYPESAFE_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT,
 			anon_vma_ctor);
 	anon_vma_chain_cachep = KMEM_CACHE(anon_vma_chain,
 			SLAB_PANIC|SLAB_ACCOUNT);
@@ -479,7 +479,7 @@ struct anon_vma *page_get_anon_vma(struct page *page)
 	 * If this page is still mapped, then its anon_vma cannot have been
 	 * freed.  But if it has been unmapped, we have no security against the
 	 * anon_vma structure being freed and reused (for another anon_vma:
-	 * SLAB_DESTROY_BY_RCU guarantees that - so the atomic_inc_not_zero()
+	 * SLAB_TYPESAFE_BY_RCU guarantees that - so the atomic_inc_not_zero()
 	 * above cannot corrupt).
 	 */
 	if (!page_mapped(page)) {
diff --git a/mm/slab.c b/mm/slab.c
index 29bc6c0dedd0..e835c652491e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1726,7 +1726,7 @@ static void slab_destroy(struct kmem_cache *cachep, struct page *page)
 
 	freelist = page->freelist;
 	slab_destroy_debugcheck(cachep, page);
-	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
+	if (unlikely(cachep->flags & SLAB_TYPESAFE_BY_RCU))
 		call_rcu(&page->rcu_head, kmem_rcu_free);
 	else
 		kmem_freepages(cachep, page);
@@ -1922,7 +1922,7 @@ static bool set_objfreelist_slab_cache(struct kmem_cache *cachep,
 
 	cachep->num = 0;
 
-	if (cachep->ctor || flags & SLAB_DESTROY_BY_RCU)
+	if (cachep->ctor || flags & SLAB_TYPESAFE_BY_RCU)
 		return false;
 
 	left = calculate_slab_order(cachep, size,
@@ -2028,7 +2028,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (size < 4096 || fls(size - 1) == fls(size-1 + REDZONE_ALIGN +
 						2 * sizeof(unsigned long long)))
 		flags |= SLAB_RED_ZONE | SLAB_STORE_USER;
-	if (!(flags & SLAB_DESTROY_BY_RCU))
+	if (!(flags & SLAB_TYPESAFE_BY_RCU))
 		flags |= SLAB_POISON;
 #endif
 #endif
diff --git a/mm/slab.h b/mm/slab.h
index de6579dc362c..a379979dacc1 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -120,7 +120,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 
 /* Legal flag mask for kmem_cache_create(), for various configurations */
 #define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | SLAB_PANIC | \
-			 SLAB_DESTROY_BY_RCU | SLAB_DEBUG_OBJECTS )
+			 SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS )
 
 #if defined(CONFIG_DEBUG_SLAB)
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
@@ -391,7 +391,7 @@ static inline size_t slab_ksize(const struct kmem_cache *s)
 	 * back there or track user information then we can
 	 * only use the space before that information.
 	 */
-	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
+	if (s->flags & (SLAB_TYPESAFE_BY_RCU | SLAB_STORE_USER))
 		return s->inuse;
 	/*
 	 * Else we can use all the padding etc for the allocation
diff --git a/mm/slab_common.c b/mm/slab_common.c
index ae323841adb1..296413c2bbcd 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -34,7 +34,7 @@ struct kmem_cache *kmem_cache;
  * Set of flags that will prevent slab merging
  */
 #define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
-		SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
+		SLAB_TRACE | SLAB_TYPESAFE_BY_RCU | SLAB_NOLEAKTRACE | \
 		SLAB_FAILSLAB | SLAB_KASAN)
 
 #define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | \
@@ -464,7 +464,7 @@ static int shutdown_cache(struct kmem_cache *s,
 	if (__kmem_cache_shutdown(s) != 0)
 		return -EBUSY;
 
-	if (s->flags & SLAB_DESTROY_BY_RCU)
+	if (s->flags & SLAB_TYPESAFE_BY_RCU)
 		*need_rcu_barrier = true;
 
 	list_move(&s->list, release);
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
index 067598a00849..c55da883d995 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1677,7 +1677,7 @@ static void rcu_free_slab(struct rcu_head *h)
 
 static void free_slab(struct kmem_cache *s, struct page *page)
 {
-	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU)) {
+	if (unlikely(s->flags & SLAB_TYPESAFE_BY_RCU)) {
 		struct rcu_head *head;
 
 		if (need_reserve_slab_rcu) {
@@ -2953,7 +2953,7 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
 	 * slab_free_freelist_hook() could have put the items into quarantine.
 	 * If so, no need to free them.
 	 */
-	if (s->flags & SLAB_KASAN && !(s->flags & SLAB_DESTROY_BY_RCU))
+	if (s->flags & SLAB_KASAN && !(s->flags & SLAB_TYPESAFE_BY_RCU))
 		return;
 	do_slab_free(s, page, head, tail, cnt, addr);
 }
@@ -3423,7 +3423,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	 * the slab may touch the object after free or before allocation
 	 * then we should never poison the object itself.
 	 */
-	if ((flags & SLAB_POISON) && !(flags & SLAB_DESTROY_BY_RCU) &&
+	if ((flags & SLAB_POISON) && !(flags & SLAB_TYPESAFE_BY_RCU) &&
 			!s->ctor)
 		s->flags |= __OBJECT_POISON;
 	else
@@ -3445,7 +3445,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	 */
 	s->inuse = size;
 
-	if (((flags & (SLAB_DESTROY_BY_RCU | SLAB_POISON)) ||
+	if (((flags & (SLAB_TYPESAFE_BY_RCU | SLAB_POISON)) ||
 		s->ctor)) {
 		/*
 		 * Relocate free pointer after the object if it is not
@@ -3527,7 +3527,7 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 	s->flags = kmem_cache_flags(s->size, flags, s->name, s->ctor);
 	s->reserved = 0;
 
-	if (need_reserve_slab_rcu && (s->flags & SLAB_DESTROY_BY_RCU))
+	if (need_reserve_slab_rcu && (s->flags & SLAB_TYPESAFE_BY_RCU))
 		s->reserved = sizeof(struct rcu_head);
 
 	if (!calculate_sizes(s, -1))
@@ -4978,7 +4978,7 @@ SLAB_ATTR_RO(cache_dma);
 
 static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", !!(s->flags & SLAB_DESTROY_BY_RCU));
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_TYPESAFE_BY_RCU));
 }
 SLAB_ATTR_RO(destroy_by_rcu);
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index d859a5c36e70..570ff0f03c05 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -951,7 +951,7 @@ static struct proto dccp_v4_prot = {
 	.orphan_count		= &dccp_orphan_count,
 	.max_header		= MAX_DCCP_HEADER,
 	.obj_size		= sizeof(struct dccp_sock),
-	.slab_flags		= SLAB_DESTROY_BY_RCU,
+	.slab_flags		= SLAB_TYPESAFE_BY_RCU,
 	.rsk_prot		= &dccp_request_sock_ops,
 	.twsk_prot		= &dccp_timewait_sock_ops,
 	.h.hashinfo		= &dccp_hashinfo,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index adfc790f7193..05418bb9416f 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1014,7 +1014,7 @@ static struct proto dccp_v6_prot = {
 	.orphan_count	   = &dccp_orphan_count,
 	.max_header	   = MAX_DCCP_HEADER,
 	.obj_size	   = sizeof(struct dccp6_sock),
-	.slab_flags	   = SLAB_DESTROY_BY_RCU,
+	.slab_flags	   = SLAB_TYPESAFE_BY_RCU,
 	.rsk_prot	   = &dccp6_request_sock_ops,
 	.twsk_prot	   = &dccp6_timewait_sock_ops,
 	.h.hashinfo	   = &dccp_hashinfo,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fe9da4fb96bf..3f622887126e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2394,7 +2394,7 @@ struct proto tcp_prot = {
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp_sock),
-	.slab_flags		= SLAB_DESTROY_BY_RCU,
+	.slab_flags		= SLAB_TYPESAFE_BY_RCU,
 	.twsk_prot		= &tcp_timewait_sock_ops,
 	.rsk_prot		= &tcp_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 73bc8fc68acd..7c8b6ad81c66 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1907,7 +1907,7 @@ struct proto tcpv6_prot = {
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp6_sock),
-	.slab_flags		= SLAB_DESTROY_BY_RCU,
+	.slab_flags		= SLAB_TYPESAFE_BY_RCU,
 	.twsk_prot		= &tcp6_timewait_sock_ops,
 	.rsk_prot		= &tcp6_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 5e9296382420..b596f90340e0 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -140,7 +140,7 @@ static struct proto llc_proto = {
 	.name	  = "LLC",
 	.owner	  = THIS_MODULE,
 	.obj_size = sizeof(struct llc_sock),
-	.slab_flags = SLAB_DESTROY_BY_RCU,
+	.slab_flags = SLAB_TYPESAFE_BY_RCU,
 };
 
 /**
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 3e821daf9dd4..ae70ba89d44f 100644
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
index d0e1e804ebd7..c984c4631369 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -325,7 +325,7 @@ static struct sock *llc_lookup_dgram(struct llc_sap *sap,
 again:
 	sk_nulls_for_each_rcu(rc, node, laddr_hb) {
 		if (llc_dgram_match(sap, laddr, rc)) {
-			/* Extra checks required by SLAB_DESTROY_BY_RCU */
+			/* Extra checks required by SLAB_TYPESAFE_BY_RCU */
 			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
 				goto again;
 			if (unlikely(llc_sk(rc)->sap != sap ||
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 3a073cd9fcf4..13b7e5159660 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -895,7 +895,7 @@ static unsigned int early_drop_list(struct net *net,
 			continue;
 
 		/* kill only if still in same netns -- might have moved due to
-		 * SLAB_DESTROY_BY_RCU rules.
+		 * SLAB_TYPESAFE_BY_RCU rules.
 		 *
 		 * We steal the timer reference.  If that fails timer has
 		 * already fired or someone else deleted it. Just drop ref
@@ -1052,7 +1052,7 @@ __nf_conntrack_alloc(struct net *net,
 
 	/*
 	 * Do not use kmem_cache_zalloc(), as this cache uses
-	 * SLAB_DESTROY_BY_RCU.
+	 * SLAB_TYPESAFE_BY_RCU.
 	 */
 	ct = kmem_cache_alloc(nf_conntrack_cachep, gfp);
 	if (ct == NULL)
@@ -1097,7 +1097,7 @@ void nf_conntrack_free(struct nf_conn *ct)
 	struct net *net = nf_ct_net(ct);
 
 	/* A freed object has refcnt == 0, that's
-	 * the golden rule for SLAB_DESTROY_BY_RCU
+	 * the golden rule for SLAB_TYPESAFE_BY_RCU
 	 */
 	NF_CT_ASSERT(atomic_read(&ct->ct_general.use) == 0);
 
@@ -1863,7 +1863,7 @@ int nf_conntrack_init_start(void)
 
 	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
 						sizeof(struct nf_conn), 0,
-						SLAB_DESTROY_BY_RCU | SLAB_HWCACHE_ALIGN, NULL);
+						SLAB_TYPESAFE_BY_RCU | SLAB_HWCACHE_ALIGN, NULL);
 	if (!nf_conntrack_cachep)
 		goto err_cachep;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
