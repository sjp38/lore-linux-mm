Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40A096B0260
	for <linux-mm@kvack.org>; Thu, 26 May 2016 16:37:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b124so162159445pfb.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 13:37:37 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id qz3si22792107pab.228.2016.05.26.13.37.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 13:37:35 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id y69so34114240pfb.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 13:37:35 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH v1 1/2] mm: Reorganize SLAB freelist randomization
Date: Thu, 26 May 2016 13:37:10 -0700
Message-Id: <1464295031-26375-2-git-send-email-thgarnie@google.com>
In-Reply-To: <1464295031-26375-1-git-send-email-thgarnie@google.com>
References: <1464295031-26375-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Pranith Kumar <bobby.prani@gmail.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Woodhouse <David.Woodhouse@intel.com>, Thomas Garnier <thgarnie@google.com>, Petr Mladek <pmladek@suse.com>, Kees Cook <keescook@chromium.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, kernel-hardening@lists.openwall.com

This commit reorganizes the previous SLAB freelist randomization to
prepare for the SLUB implementation. It moves functions that will be
shared to slab_common.

The entropy functions are changed to align with the SLUB implementation,
now using get_random_(int|long) functions. These functions were chosen
because they provide a bit more entropy early on boot and better
performance when specific arch instructions are not available.

Signed-off-by: Thomas Garnier <thgarnie@google.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
Based on next-20160526
---
 include/linux/slab_def.h |  2 +-
 mm/slab.c                | 80 ++++++++++++------------------------------------
 mm/slab.h                | 14 +++++++++
 mm/slab_common.c         | 47 ++++++++++++++++++++++++++++
 4 files changed, 82 insertions(+), 61 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 8694f7a..339ba02 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -81,7 +81,7 @@ struct kmem_cache {
 #endif
 
 #ifdef CONFIG_SLAB_FREELIST_RANDOM
-	void *random_seq;
+	unsigned int *random_seq;
 #endif
 
 	struct kmem_cache_node *node[MAX_NUMNODES];
diff --git a/mm/slab.c b/mm/slab.c
index cc8bbc1..763096a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1236,61 +1236,6 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
 	}
 }
 
-#ifdef CONFIG_SLAB_FREELIST_RANDOM
-static void freelist_randomize(struct rnd_state *state, freelist_idx_t *list,
-			size_t count)
-{
-	size_t i;
-	unsigned int rand;
-
-	for (i = 0; i < count; i++)
-		list[i] = i;
-
-	/* Fisher-Yates shuffle */
-	for (i = count - 1; i > 0; i--) {
-		rand = prandom_u32_state(state);
-		rand %= (i + 1);
-		swap(list[i], list[rand]);
-	}
-}
-
-/* Create a random sequence per cache */
-static int cache_random_seq_create(struct kmem_cache *cachep, gfp_t gfp)
-{
-	unsigned int seed, count = cachep->num;
-	struct rnd_state state;
-
-	if (count < 2)
-		return 0;
-
-	/* If it fails, we will just use the global lists */
-	cachep->random_seq = kcalloc(count, sizeof(freelist_idx_t), gfp);
-	if (!cachep->random_seq)
-		return -ENOMEM;
-
-	/* Get best entropy at this stage */
-	get_random_bytes_arch(&seed, sizeof(seed));
-	prandom_seed_state(&state, seed);
-
-	freelist_randomize(&state, cachep->random_seq, count);
-	return 0;
-}
-
-/* Destroy the per-cache random freelist sequence */
-static void cache_random_seq_destroy(struct kmem_cache *cachep)
-{
-	kfree(cachep->random_seq);
-	cachep->random_seq = NULL;
-}
-#else
-static inline int cache_random_seq_create(struct kmem_cache *cachep, gfp_t gfp)
-{
-	return 0;
-}
-static inline void cache_random_seq_destroy(struct kmem_cache *cachep) { }
-#endif /* CONFIG_SLAB_FREELIST_RANDOM */
-
-
 /*
  * Initialisation.  Called after the page allocator have been initialised and
  * before smp_init().
@@ -2535,7 +2480,7 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
 union freelist_init_state {
 	struct {
 		unsigned int pos;
-		freelist_idx_t *list;
+		unsigned int *list;
 		unsigned int count;
 		unsigned int rand;
 	};
@@ -2554,7 +2499,7 @@ static bool freelist_state_initialize(union freelist_init_state *state,
 	unsigned int rand;
 
 	/* Use best entropy available to define a random shift */
-	get_random_bytes_arch(&rand, sizeof(rand));
+	rand = get_random_int();
 
 	/* Use a random state if the pre-computed list is not available */
 	if (!cachep->random_seq) {
@@ -2576,13 +2521,20 @@ static freelist_idx_t next_random_slot(union freelist_init_state *state)
 	return (state->list[state->pos++] + state->rand) % state->count;
 }
 
+/* Swap two freelist entries */
+static void swap_free_obj(struct page *page, unsigned int a, unsigned int b)
+{
+	swap(((freelist_idx_t *)page->freelist)[a],
+		((freelist_idx_t *)page->freelist)[b]);
+}
+
 /*
  * Shuffle the freelist initialization state based on pre-computed lists.
  * return true if the list was successfully shuffled, false otherwise.
  */
 static bool shuffle_freelist(struct kmem_cache *cachep, struct page *page)
 {
-	unsigned int objfreelist = 0, i, count = cachep->num;
+	unsigned int objfreelist = 0, i, rand, count = cachep->num;
 	union freelist_init_state state;
 	bool precomputed;
 
@@ -2607,7 +2559,15 @@ static bool shuffle_freelist(struct kmem_cache *cachep, struct page *page)
 	 * Later use a pre-computed list for speed.
 	 */
 	if (!precomputed) {
-		freelist_randomize(&state.rnd_state, page->freelist, count);
+		for (i = 0; i < count; i++)
+			set_free_obj(page, i, i);
+
+		/* Fisher-Yates shuffle */
+		for (i = count - 1; i > 0; i--) {
+			rand = prandom_u32_state(&state.rnd_state);
+			rand %= (i + 1);
+			swap_free_obj(page, i, rand);
+		}
 	} else {
 		for (i = 0; i < count; i++)
 			set_free_obj(page, i, next_random_slot(&state));
@@ -3979,7 +3939,7 @@ static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
 	int shared = 0;
 	int batchcount = 0;
 
-	err = cache_random_seq_create(cachep, gfp);
+	err = cache_random_seq_create(cachep, cachep->num, gfp);
 	if (err)
 		goto end;
 
diff --git a/mm/slab.h b/mm/slab.h
index dedb1a9..5fa8b8f 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -42,6 +42,7 @@ struct kmem_cache {
 #include <linux/kmemcheck.h>
 #include <linux/kasan.h>
 #include <linux/kmemleak.h>
+#include <linux/random.h>
 
 /*
  * State of the slab allocator.
@@ -464,4 +465,17 @@ int memcg_slab_show(struct seq_file *m, void *p);
 
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
 
+#ifdef CONFIG_SLAB_FREELIST_RANDOM
+int cache_random_seq_create(struct kmem_cache *cachep, unsigned int count,
+			gfp_t gfp);
+void cache_random_seq_destroy(struct kmem_cache *cachep);
+#else
+static inline int cache_random_seq_create(struct kmem_cache *cachep,
+					unsigned int count, gfp_t gfp)
+{
+	return 0;
+}
+static inline void cache_random_seq_destroy(struct kmem_cache *cachep) { }
+#endif /* CONFIG_SLAB_FREELIST_RANDOM */
+
 #endif /* MM_SLAB_H */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index a65dad7..eb1789b 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1142,6 +1142,53 @@ int memcg_slab_show(struct seq_file *m, void *p)
 }
 #endif
 
+#ifdef CONFIG_SLAB_FREELIST_RANDOM
+/* Randomize a generic freelist */
+static void freelist_randomize(struct rnd_state *state, unsigned int *list,
+			size_t count)
+{
+	size_t i;
+	unsigned int rand;
+
+	for (i = 0; i < count; i++)
+		list[i] = i;
+
+	/* Fisher-Yates shuffle */
+	for (i = count - 1; i > 0; i--) {
+		rand = prandom_u32_state(state);
+		rand %= (i + 1);
+		swap(list[i], list[rand]);
+	}
+}
+
+/* Create a random sequence per cache */
+int cache_random_seq_create(struct kmem_cache *cachep, unsigned int count,
+				    gfp_t gfp)
+{
+	struct rnd_state state;
+
+	if (count < 2 || cachep->random_seq)
+		return 0;
+
+	cachep->random_seq = kcalloc(count, sizeof(unsigned int), gfp);
+	if (!cachep->random_seq)
+		return -ENOMEM;
+
+	/* Get best entropy at this stage of boot */
+	prandom_seed_state(&state, get_random_long());
+
+	freelist_randomize(&state, cachep->random_seq, count);
+	return 0;
+}
+
+/* Destroy the per-cache random freelist sequence */
+void cache_random_seq_destroy(struct kmem_cache *cachep)
+{
+	kfree(cachep->random_seq);
+	cachep->random_seq = NULL;
+}
+#endif /* CONFIG_SLAB_FREELIST_RANDOM */
+
 /*
  * slabinfo_op - iterator that generates /proc/slabinfo
  *
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
