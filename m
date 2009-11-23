Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EB85A6B0083
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 15:01:18 -0500 (EST)
Subject: Re: lockdep complaints in slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1259005814.15619.14.camel@penberg-laptop>
References: <20091118181202.GA12180@linux.vnet.ibm.com>
	 <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <1258709153.11284.429.camel@laptop>
	 <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com>
	 <1258714328.11284.522.camel@laptop>  <4B067816.6070304@cs.helsinki.fi>
	 <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop>
	 <alpine.DEB.2.00.0911231329560.5617@router.home>
	 <1259005814.15619.14.camel@penberg-laptop>
Date: Mon, 23 Nov 2009 22:01:15 +0200
Message-Id: <1259006475.15619.16.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, mpm@selenic.com, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-23 at 21:50 +0200, Pekka Enberg wrote:
> On Mon, 23 Nov 2009, Pekka Enberg wrote:
> > > That turns out to be _very_ hard. How about something like the following
> > > untested patch which delays slab_destroy() while we're under nc->lock.
> 
> On Mon, 2009-11-23 at 13:30 -0600, Christoph Lameter wrote:
> > Code changes to deal with a diagnostic issue?
> 
> OK, fair enough. If I suffer permanent brain damage from staring at the
> SLAB code for too long, I hope you and Matt will chip in to pay for my
> medication.
> 
> I think I was looking at the wrong thing here. The problem is in
> cache_free_alien() so the comment in slab_destroy() isn't relevant.
> Looking at init_lock_keys() we already do special lockdep annotations
> but there's a catch (as explained in a comment on top of
> on_slab_alc_key):
> 
>  * We set lock class for alien array caches which are up during init.
>  * The lock annotation will be lost if all cpus of a node goes down and
>  * then comes back up during hotplug
> 
> Paul said he was running CPU hotplug so maybe that explains the problem?

Maybe something like this untested patch fixes the issue...

			Pekka

diff --git a/mm/slab.c b/mm/slab.c
index 7dfa481..84de47e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -604,6 +604,26 @@ static struct kmem_cache cache_cache = {
 
 #define BAD_ALIEN_MAGIC 0x01020304ul
 
+/*
+ * chicken and egg problem: delay the per-cpu array allocation
+ * until the general caches are up.
+ */
+static enum {
+	NONE,
+	PARTIAL_AC,
+	PARTIAL_L3,
+	EARLY,
+	FULL
+} g_cpucache_up;
+
+/*
+ * used by boot code to determine if it can use slab based allocator
+ */
+int slab_is_available(void)
+{
+	return g_cpucache_up >= EARLY;
+}
+
 #ifdef CONFIG_LOCKDEP
 
 /*
@@ -620,40 +640,52 @@ static struct kmem_cache cache_cache = {
 static struct lock_class_key on_slab_l3_key;
 static struct lock_class_key on_slab_alc_key;
 
-static inline void init_lock_keys(void)
-
+static void init_node_lock_keys(int q)
 {
-	int q;
 	struct cache_sizes *s = malloc_sizes;
 
-	while (s->cs_size != ULONG_MAX) {
-		for_each_node(q) {
-			struct array_cache **alc;
-			int r;
-			struct kmem_list3 *l3 = s->cs_cachep->nodelists[q];
-			if (!l3 || OFF_SLAB(s->cs_cachep))
-				continue;
-			lockdep_set_class(&l3->list_lock, &on_slab_l3_key);
-			alc = l3->alien;
-			/*
-			 * FIXME: This check for BAD_ALIEN_MAGIC
-			 * should go away when common slab code is taught to
-			 * work even without alien caches.
-			 * Currently, non NUMA code returns BAD_ALIEN_MAGIC
-			 * for alloc_alien_cache,
-			 */
-			if (!alc || (unsigned long)alc == BAD_ALIEN_MAGIC)
-				continue;
-			for_each_node(r) {
-				if (alc[r])
-					lockdep_set_class(&alc[r]->lock,
-					     &on_slab_alc_key);
-			}
+	if (g_cpucache_up != FULL)
+		return;
+
+	for (s = malloc_sizes; s->cs_size != ULONG_MAX; s++) {
+		struct array_cache **alc;
+		struct kmem_list3 *l3;
+		int r;
+
+		l3 = s->cs_cachep->nodelists[q];
+		if (!l3 || OFF_SLAB(s->cs_cachep))
+			return;
+		lockdep_set_class(&l3->list_lock, &on_slab_l3_key);
+		alc = l3->alien;
+		/*
+		 * FIXME: This check for BAD_ALIEN_MAGIC
+		 * should go away when common slab code is taught to
+		 * work even without alien caches.
+		 * Currently, non NUMA code returns BAD_ALIEN_MAGIC
+		 * for alloc_alien_cache,
+		 */
+		if (!alc || (unsigned long)alc == BAD_ALIEN_MAGIC)
+			return;
+		for_each_node(r) {
+			if (alc[r])
+				lockdep_set_class(&alc[r]->lock,
+					&on_slab_alc_key);
 		}
-		s++;
 	}
 }
+
+static inline void init_lock_keys(void)
+{
+	int node;
+
+	for_each_node(node)
+		init_node_lock_keys(node);
+}
 #else
+static void init_node_lock_keys(int q)
+{
+}
+
 static inline void init_lock_keys(void)
 {
 }
@@ -665,26 +697,6 @@ static inline void init_lock_keys(void)
 static DEFINE_MUTEX(cache_chain_mutex);
 static struct list_head cache_chain;
 
-/*
- * chicken and egg problem: delay the per-cpu array allocation
- * until the general caches are up.
- */
-static enum {
-	NONE,
-	PARTIAL_AC,
-	PARTIAL_L3,
-	EARLY,
-	FULL
-} g_cpucache_up;
-
-/*
- * used by boot code to determine if it can use slab based allocator
- */
-int slab_is_available(void)
-{
-	return g_cpucache_up >= EARLY;
-}
-
 static DEFINE_PER_CPU(struct delayed_work, reap_work);
 
 static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
@@ -1254,6 +1266,8 @@ static int __cpuinit cpuup_prepare(long cpu)
 		kfree(shared);
 		free_alien_cache(alien);
 	}
+	init_node_lock_keys(node);
+
 	return 0;
 bad:
 	cpuup_canceled(cpu);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
