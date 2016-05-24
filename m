Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 930906B025E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 17:15:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 77so52070391pfz.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 14:15:48 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id ey9si7172374pab.123.2016.05.24.14.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 14:15:46 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id b124so10676140pfb.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 14:15:46 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [RFC v2 1/2] mm: Reorganize SLAB freelist randomization
Date: Tue, 24 May 2016 14:15:22 -0700
Message-Id: <1464124523-43051-2-git-send-email-thgarnie@google.com>
In-Reply-To: <1464124523-43051-1-git-send-email-thgarnie@google.com>
References: <1464124523-43051-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Pranith Kumar <bobby.prani@gmail.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Woodhouse <David.Woodhouse@intel.com>, Thomas Garnier <thgarnie@google.com>, Petr Mladek <pmladek@suse.com>, Kees Cook <keescook@chromium.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, kernel-hardening@lists.openwall.com

This commit reorganizes the previous SLAB freelist randomization to
prepare for the SLUB implementation. It moves functions that will be
shared to slab_common. It also move the definition of freelist_idx_t in
the slab_def header so a similar type can be used for all common
functions. The entropy functions are changed to align with the SLUB
implementation, now using get_random_* functions.

Signed-off-by: Thomas Garnier <thgarnie@google.com>
---
Based on 0e01df100b6bf22a1de61b66657502a6454153c5
---
 include/linux/slab_def.h | 11 +++++++-
 mm/slab.c                | 68 ++----------------------------------------------
 mm/slab.h                | 16 ++++++++++++
 mm/slab_common.c         | 48 ++++++++++++++++++++++++++++++++++
 4 files changed, 76 insertions(+), 67 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 8694f7a..e05a871 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -3,6 +3,15 @@
 
 #include <linux/reciprocal_div.h>
 
+#define FREELIST_BYTE_INDEX (((PAGE_SIZE >> BITS_PER_BYTE) \
+				<= SLAB_OBJ_MIN_SIZE) ? 1 : 0)
+
+#if FREELIST_BYTE_INDEX
+typedef unsigned char freelist_idx_t;
+#else
+typedef unsigned short freelist_idx_t;
+#endif
+
 /*
  * Definitions unique to the original Linux SLAB allocator.
  */
@@ -81,7 +90,7 @@ struct kmem_cache {
 #endif
 
 #ifdef CONFIG_SLAB_FREELIST_RANDOM
-	void *random_seq;
+	freelist_idx_t *random_seq;
 #endif
 
 	struct kmem_cache_node *node[MAX_NUMNODES];
diff --git a/mm/slab.c b/mm/slab.c
index cc8bbc1..8e32562 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -157,15 +157,6 @@
 #define ARCH_KMALLOC_FLAGS SLAB_HWCACHE_ALIGN
 #endif
 
-#define FREELIST_BYTE_INDEX (((PAGE_SIZE >> BITS_PER_BYTE) \
-				<= SLAB_OBJ_MIN_SIZE) ? 1 : 0)
-
-#if FREELIST_BYTE_INDEX
-typedef unsigned char freelist_idx_t;
-#else
-typedef unsigned short freelist_idx_t;
-#endif
-
 #define SLAB_OBJ_MAX_NUM ((1 << sizeof(freelist_idx_t) * BITS_PER_BYTE) - 1)
 
 /*
@@ -1236,61 +1227,6 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
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
@@ -2554,7 +2490,7 @@ static bool freelist_state_initialize(union freelist_init_state *state,
 	unsigned int rand;
 
 	/* Use best entropy available to define a random shift */
-	get_random_bytes_arch(&rand, sizeof(rand));
+	rand = get_random_int();
 
 	/* Use a random state if the pre-computed list is not available */
 	if (!cachep->random_seq) {
@@ -3979,7 +3915,7 @@ static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
 	int shared = 0;
 	int batchcount = 0;
 
-	err = cache_random_seq_create(cachep, gfp);
+	err = cache_random_seq_create(cachep, cachep->num, gfp);
 	if (err)
 		goto end;
 
diff --git a/mm/slab.h b/mm/slab.h
index dedb1a9..2c33bf3 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -42,6 +42,7 @@ struct kmem_cache {
 #include <linux/kmemcheck.h>
 #include <linux/kasan.h>
 #include <linux/kmemleak.h>
+#include <linux/random.h>
 
 /*
  * State of the slab allocator.
@@ -464,4 +465,19 @@ int memcg_slab_show(struct seq_file *m, void *p);
 
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
 
+#ifdef CONFIG_SLAB_FREELIST_RANDOM
+void freelist_randomize(struct rnd_state *state, freelist_idx_t *list,
+			size_t count);
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
index a65dad7..657ecf1 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1142,6 +1142,54 @@ int memcg_slab_show(struct seq_file *m, void *p)
 }
 #endif
 
+#ifdef CONFIG_SLAB_FREELIST_RANDOM
+/* Randomize a generic freelist */
+void freelist_randomize(struct rnd_state *state, freelist_idx_t *list,
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
+	if (count < 2)
+		return 0;
+
+	/* If it fails, we will just use the global lists */
+	cachep->random_seq = kcalloc(count, sizeof(freelist_idx_t), gfp);
+	if (!cachep->random_seq)
+		return -ENOMEM;
+
+	/* Get best entropy at this stage */
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
