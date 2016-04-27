Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id F18996B0253
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:21:38 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so81433426pad.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:21:38 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id m187si4996084pfb.197.2016.04.27.10.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 10:21:37 -0700 (PDT)
Received: by mail-pa0-x22d.google.com with SMTP id iv1so21751796pac.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:21:37 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH v5] mm: SLAB freelist randomization
Date: Wed, 27 Apr 2016 10:20:59 -0700
Message-Id: <1461777659-81290-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>
Cc: gthelen@google.com, labbott@fedoraproject.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Garnier <thgarnie@google.com>

Provides an optional config (CONFIG_SLAB_FREELIST_RANDOM) to randomize
the SLAB freelist. The list is randomized during initialization of a new
set of pages. The order on different freelist sizes is pre-computed at
boot for performance. Each kmem_cache has its own randomized
freelist. Before pre-computed lists are available freelists are
generated dynamically. This security feature reduces the predictability
of the kernel SLAB allocator against heap overflows rendering attacks
much less stable.

For example this attack against SLUB (also applicable against SLAB)
would be affected:
https://jon.oberheide.org/blog/2010/09/10/linux-kernel-can-slub-overflow/

Also, since v4.6 the freelist was moved at the end of the SLAB. It means
a controllable heap is opened to new attacks not yet publicly discussed.
A kernel heap overflow can be transformed to multiple use-after-free.
This feature makes this type of attack harder too.

To generate entropy, we use get_random_bytes_arch because 0 bits of
entropy is available in the boot stage. In the worse case this function
will fallback to the get_random_bytes sub API. We also generate a shift
random number to shift pre-computed freelist for each new set of pages.

The config option name is not specific to the SLAB as this approach will
be extended to other allocators like SLUB.

Performance results highlighted no major changes:

Hackbench (running 90 10 times):

Before average: 0.0698
After average: 0.0663 (-5.01%)

slab_test 1 run on boot. Difference only seen on the 2048 size test
being the worse case scenario covered by freelist randomization. New
slab pages are constantly being created on the 10000 allocations.
Variance should be mainly due to getting new pages every few
allocations.

Before:

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 99 cycles kfree -> 112 cycles
10000 times kmalloc(16) -> 109 cycles kfree -> 140 cycles
10000 times kmalloc(32) -> 129 cycles kfree -> 137 cycles
10000 times kmalloc(64) -> 141 cycles kfree -> 141 cycles
10000 times kmalloc(128) -> 152 cycles kfree -> 148 cycles
10000 times kmalloc(256) -> 195 cycles kfree -> 167 cycles
10000 times kmalloc(512) -> 257 cycles kfree -> 199 cycles
10000 times kmalloc(1024) -> 393 cycles kfree -> 251 cycles
10000 times kmalloc(2048) -> 649 cycles kfree -> 228 cycles
10000 times kmalloc(4096) -> 806 cycles kfree -> 370 cycles
10000 times kmalloc(8192) -> 814 cycles kfree -> 411 cycles
10000 times kmalloc(16384) -> 892 cycles kfree -> 455 cycles
2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 121 cycles
10000 times kmalloc(16)/kfree -> 121 cycles
10000 times kmalloc(32)/kfree -> 121 cycles
10000 times kmalloc(64)/kfree -> 121 cycles
10000 times kmalloc(128)/kfree -> 121 cycles
10000 times kmalloc(256)/kfree -> 119 cycles
10000 times kmalloc(512)/kfree -> 119 cycles
10000 times kmalloc(1024)/kfree -> 119 cycles
10000 times kmalloc(2048)/kfree -> 119 cycles
10000 times kmalloc(4096)/kfree -> 121 cycles
10000 times kmalloc(8192)/kfree -> 119 cycles
10000 times kmalloc(16384)/kfree -> 119 cycles

After:

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 130 cycles kfree -> 86 cycles
10000 times kmalloc(16) -> 118 cycles kfree -> 86 cycles
10000 times kmalloc(32) -> 121 cycles kfree -> 85 cycles
10000 times kmalloc(64) -> 176 cycles kfree -> 102 cycles
10000 times kmalloc(128) -> 178 cycles kfree -> 100 cycles
10000 times kmalloc(256) -> 205 cycles kfree -> 109 cycles
10000 times kmalloc(512) -> 262 cycles kfree -> 136 cycles
10000 times kmalloc(1024) -> 342 cycles kfree -> 157 cycles
10000 times kmalloc(2048) -> 701 cycles kfree -> 238 cycles
10000 times kmalloc(4096) -> 803 cycles kfree -> 364 cycles
10000 times kmalloc(8192) -> 835 cycles kfree -> 404 cycles
10000 times kmalloc(16384) -> 896 cycles kfree -> 441 cycles
2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 121 cycles
10000 times kmalloc(16)/kfree -> 121 cycles
10000 times kmalloc(32)/kfree -> 123 cycles
10000 times kmalloc(64)/kfree -> 142 cycles
10000 times kmalloc(128)/kfree -> 121 cycles
10000 times kmalloc(256)/kfree -> 119 cycles
10000 times kmalloc(512)/kfree -> 119 cycles
10000 times kmalloc(1024)/kfree -> 119 cycles
10000 times kmalloc(2048)/kfree -> 119 cycles
10000 times kmalloc(4096)/kfree -> 119 cycles
10000 times kmalloc(8192)/kfree -> 119 cycles
10000 times kmalloc(16384)/kfree -> 119 cycles

Signed-off-by: Thomas Garnier <thgarnie@google.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
Based on next-20160422
---
 include/linux/slab_def.h |   4 ++
 init/Kconfig             |   9 +++
 mm/slab.c                | 167 ++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 178 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 9edbbf3..8694f7a 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -80,6 +80,10 @@ struct kmem_cache {
 	struct kasan_cache kasan_info;
 #endif
 
+#ifdef CONFIG_SLAB_FREELIST_RANDOM
+	void *random_seq;
+#endif
+
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
diff --git a/init/Kconfig b/init/Kconfig
index 0c66640..ccd615a 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1742,6 +1742,15 @@ config SLOB
 
 endchoice
 
+config SLAB_FREELIST_RANDOM
+	default n
+	depends on SLAB
+	bool "SLAB freelist randomization"
+	help
+	  Randomizes the freelist order used on creating new SLABs. This
+	  security feature reduces the predictability of the kernel slab
+	  allocator against heap overflows.
+
 config SLUB_CPU_PARTIAL
 	default y
 	depends on SLUB && SMP
diff --git a/mm/slab.c b/mm/slab.c
index b82ee6b..e797388 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1230,6 +1230,61 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
 	}
 }
 
+#ifdef CONFIG_SLAB_FREELIST_RANDOM
+static void freelist_randomize(struct rnd_state *state, freelist_idx_t *list,
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
+static int cache_random_seq_create(struct kmem_cache *cachep)
+{
+	unsigned int seed, count = cachep->num;
+	struct rnd_state state;
+
+	if (count < 2)
+		return 0;
+
+	/* If it fails, we will just use the global lists */
+	cachep->random_seq = kcalloc(count, sizeof(freelist_idx_t), GFP_KERNEL);
+	if (!cachep->random_seq)
+		return -ENOMEM;
+
+	/* Get best entropy at this stage */
+	get_random_bytes_arch(&seed, sizeof(seed));
+	prandom_seed_state(&state, seed);
+
+	freelist_randomize(&state, cachep->random_seq, count);
+	return 0;
+}
+
+/* Destroy the per-cache random freelist sequence */
+static void cache_random_seq_destroy(struct kmem_cache *cachep)
+{
+	kfree(cachep->random_seq);
+	cachep->random_seq = NULL;
+}
+#else
+static inline int cache_random_seq_create(struct kmem_cache *cachep)
+{
+	return 0;
+}
+static inline void cache_random_seq_destroy(struct kmem_cache *cachep) { }
+#endif /* CONFIG_SLAB_FREELIST_RANDOM */
+
+
 /*
  * Initialisation.  Called after the page allocator have been initialised and
  * before smp_init().
@@ -2337,6 +2392,8 @@ void __kmem_cache_release(struct kmem_cache *cachep)
 	int i;
 	struct kmem_cache_node *n;
 
+	cache_random_seq_destroy(cachep);
+
 	free_percpu(cachep->cpu_cache);
 
 	/* NUMA: free the node structures */
@@ -2443,15 +2500,115 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
 #endif
 }
 
+#ifdef CONFIG_SLAB_FREELIST_RANDOM
+/* Hold information during a freelist initialization */
+union freelist_init_state {
+	struct {
+		unsigned int pos;
+		freelist_idx_t *list;
+		unsigned int count;
+		unsigned int rand;
+	};
+	struct rnd_state rnd_state;
+};
+
+/*
+ * Initialize the state based on the randomization methode available.
+ * return true if the pre-computed list is available, false otherwize.
+ */
+static bool freelist_state_initialize(union freelist_init_state *state,
+				struct kmem_cache *cachep,
+				unsigned int count)
+{
+	bool ret;
+	unsigned int rand;
+
+	/* Use best entropy available to define a random shift */
+	get_random_bytes_arch(&rand, sizeof(rand));
+
+	/* Use a random state if the pre-computed list is not available */
+	if (!cachep->random_seq) {
+		prandom_seed_state(&state->rnd_state, rand);
+		ret = false;
+	} else {
+		state->list = cachep->random_seq;
+		state->count = count;
+		state->pos = 0;
+		state->rand = rand;
+		ret = true;
+	}
+	return ret;
+}
+
+/* Get the next entry on the list and randomize it using a random shift */
+static freelist_idx_t next_random_slot(union freelist_init_state *state)
+{
+	return (state->list[state->pos++] + state->rand) % state->count;
+}
+
+/*
+ * Shuffle the freelist initialization state based on pre-computed lists.
+ * return true if the list was successfully shuffled, false otherwise.
+ */
+static bool shuffle_freelist(struct kmem_cache *cachep, struct page *page)
+{
+	unsigned int objfreelist = 0, i, count = cachep->num;
+	union freelist_init_state state;
+	bool precomputed;
+
+	if (count < 2)
+		return false;
+
+	precomputed = freelist_state_initialize(&state, cachep, count);
+
+	/* Take a random entry as the objfreelist */
+	if (OBJFREELIST_SLAB(cachep)) {
+		if (!precomputed)
+			objfreelist = count - 1;
+		else
+			objfreelist = next_random_slot(&state);
+		page->freelist = index_to_obj(cachep, page, objfreelist) +
+						obj_offset(cachep);
+		count--;
+	}
+
+	/*
+	 * On early boot, generate the list dynamically.
+	 * Later use a pre-computed list for speed.
+	 */
+	if (!precomputed) {
+		freelist_randomize(&state.rnd_state, page->freelist, count);
+	} else {
+		for (i = 0; i < count; i++)
+			set_free_obj(page, i, next_random_slot(&state));
+	}
+
+	if (OBJFREELIST_SLAB(cachep))
+		set_free_obj(page, cachep->num - 1, objfreelist);
+
+	return true;
+}
+#else
+static inline bool shuffle_freelist(struct kmem_cache *cachep,
+				struct page *page)
+{
+	return false;
+}
+#endif /* CONFIG_SLAB_FREELIST_RANDOM */
+
 static void cache_init_objs(struct kmem_cache *cachep,
 			    struct page *page)
 {
 	int i;
 	void *objp;
+	bool shuffled;
 
 	cache_init_objs_debug(cachep, page);
 
-	if (OBJFREELIST_SLAB(cachep)) {
+	/* Try to randomize the freelist if enabled */
+	shuffled = shuffle_freelist(cachep, page);
+
+	if (!shuffled && OBJFREELIST_SLAB(cachep)) {
 		page->freelist = index_to_obj(cachep, page, cachep->num - 1) +
 						obj_offset(cachep);
 	}
@@ -2465,7 +2622,8 @@ static void cache_init_objs(struct kmem_cache *cachep,
 			kasan_poison_object_data(cachep, objp);
 		}
 
-		set_free_obj(page, i, i);
+		if (!shuffled)
+			set_free_obj(page, i, i);
 	}
 }
 
@@ -3815,6 +3973,10 @@ static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
 	int shared = 0;
 	int batchcount = 0;
 
+	err = cache_random_seq_create(cachep);
+	if (err)
+		goto end;
+
 	if (!is_root_cache(cachep)) {
 		struct kmem_cache *root = memcg_root_cache(cachep);
 		limit = root->limit;
@@ -3868,6 +4030,7 @@ static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
 	batchcount = (limit + 1) / 2;
 skip_setup:
 	err = do_tune_cpucache(cachep, limit, batchcount, shared, gfp);
+end:
 	if (err)
 		pr_err("enable_cpucache failed for %s, error %d\n",
 		       cachep->name, -err);
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
