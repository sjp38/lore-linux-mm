Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF20F6B025F
	for <linux-mm@kvack.org>; Wed, 18 May 2016 13:56:54 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id yl2so78761117pac.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 10:56:54 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id uy10si13374593pac.210.2016.05.18.10.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 10:56:53 -0700 (PDT)
Received: by mail-pa0-x236.google.com with SMTP id qo8so20263608pab.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 10:56:53 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [RFC v1 2/2] mm: SLUB Freelist randomization
Date: Wed, 18 May 2016 10:56:15 -0700
Message-Id: <1463594175-111929-3-git-send-email-thgarnie@google.com>
In-Reply-To: <1463594175-111929-1-git-send-email-thgarnie@google.com>
References: <1463594175-111929-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Pranith Kumar <bobby.prani@gmail.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Woodhouse <David.Woodhouse@intel.com>, Thomas Garnier <thgarnie@google.com>, Petr Mladek <pmladek@suse.com>, Kees Cook <keescook@chromium.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, kernel-hardening@lists.openwall.com

Implements Freelist randomization for the SLUB allocator. It was
previous implemented for the SLAB allocator. Both use the same
configuration option (CONFIG_SLAB_FREELIST_RANDOM).

The list is randomized during initialization of a new set of pages. The
order on different freelist sizes is pre-computed at boot for
performance. Each kmem_cache has its own randomized freelist. This
security feature reduces the predictability of the kernel SLUB allocator
against heap overflows rendering attacks much less stable.

For example these attacks exploit the predictability of the heap:
 - Linux Kernel CAN SLUB overflow (https://goo.gl/oMNWkU)
 - Exploiting Linux Kernel Heap corruptions (http://goo.gl/EXLn95)

To generate entropy, we use get_random_bytes_arch because 0 bits of
entropy is available in the boot stage.  In the worse case this function
will fallback to the get_random_bytes sub API.

Performance results highlighted no major changes:

slab_test, before:

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 67 cycles kfree -> 101 cycles
10000 times kmalloc(16) -> 68 cycles kfree -> 109 cycles
10000 times kmalloc(32) -> 76 cycles kfree -> 119 cycles
10000 times kmalloc(64) -> 88 cycles kfree -> 114 cycles
10000 times kmalloc(128) -> 100 cycles kfree -> 122 cycles
10000 times kmalloc(256) -> 128 cycles kfree -> 149 cycles
10000 times kmalloc(512) -> 108 cycles kfree -> 152 cycles
10000 times kmalloc(1024) -> 112 cycles kfree -> 158 cycles
10000 times kmalloc(2048) -> 161 cycles kfree -> 208 cycles
10000 times kmalloc(4096) -> 231 cycles kfree -> 239 cycles
10000 times kmalloc(8192) -> 341 cycles kfree -> 270 cycles
10000 times kmalloc(16384) -> 481 cycles kfree -> 323 cycles
2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 90 cycles
10000 times kmalloc(16)/kfree -> 89 cycles
10000 times kmalloc(32)/kfree -> 88 cycles
10000 times kmalloc(64)/kfree -> 88 cycles
10000 times kmalloc(128)/kfree -> 94 cycles
10000 times kmalloc(256)/kfree -> 87 cycles
10000 times kmalloc(512)/kfree -> 91 cycles
10000 times kmalloc(1024)/kfree -> 90 cycles
10000 times kmalloc(2048)/kfree -> 90 cycles
10000 times kmalloc(4096)/kfree -> 90 cycles
10000 times kmalloc(8192)/kfree -> 90 cycles
10000 times kmalloc(16384)/kfree -> 642 cycles

After:

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 60 cycles kfree -> 74 cycles
10000 times kmalloc(16) -> 63 cycles kfree -> 78 cycles
10000 times kmalloc(32) -> 72 cycles kfree -> 85 cycles
10000 times kmalloc(64) -> 91 cycles kfree -> 99 cycles
10000 times kmalloc(128) -> 112 cycles kfree -> 109 cycles
10000 times kmalloc(256) -> 127 cycles kfree -> 120 cycles
10000 times kmalloc(512) -> 125 cycles kfree -> 121 cycles
10000 times kmalloc(1024) -> 128 cycles kfree -> 125 cycles
10000 times kmalloc(2048) -> 167 cycles kfree -> 141 cycles
10000 times kmalloc(4096) -> 249 cycles kfree -> 174 cycles
10000 times kmalloc(8192) -> 377 cycles kfree -> 225 cycles
10000 times kmalloc(16384) -> 459 cycles kfree -> 247 cycles
2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 72 cycles
10000 times kmalloc(16)/kfree -> 74 cycles
10000 times kmalloc(32)/kfree -> 71 cycles
10000 times kmalloc(64)/kfree -> 75 cycles
10000 times kmalloc(128)/kfree -> 71 cycles
10000 times kmalloc(256)/kfree -> 72 cycles
10000 times kmalloc(512)/kfree -> 72 cycles
10000 times kmalloc(1024)/kfree -> 73 cycles
10000 times kmalloc(2048)/kfree -> 73 cycles
10000 times kmalloc(4096)/kfree -> 72 cycles
10000 times kmalloc(8192)/kfree -> 72 cycles
10000 times kmalloc(16384)/kfree -> 546 cycles

Kernbench, before:

Average Optimal load -j 12 Run (std deviation):
Elapsed Time 101.873 (1.16069)
User Time 1045.22 (1.60447)
System Time 88.969 (0.559195)
Percent CPU 1112.9 (13.8279)
Context Switches 189140 (2282.15)
Sleeps 99008.6 (768.091)

After:

Average Optimal load -j 12 Run (std deviation):
Elapsed Time 102.47 (0.562732)
User Time 1045.3 (1.34263)
System Time 88.311 (0.342554)
Percent CPU 1105.8 (6.49444)
Context Switches 189081 (2355.78)
Sleeps 99231.5 (800.358)

Signed-off-by: Thomas Garnier <thgarnie@google.com>
---
Based on next-20160517
---
 include/linux/slub_def.h |   8 +++
 init/Kconfig             |   4 +-
 mm/slub.c                | 135 ++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 138 insertions(+), 9 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 665cd0c..22d487e 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -56,6 +56,9 @@ struct kmem_cache_order_objects {
 	unsigned long x;
 };
 
+/* Index used for freelist randomization */
+typedef unsigned int freelist_idx_t;
+
 /*
  * Slab cache management.
  */
@@ -99,6 +102,11 @@ struct kmem_cache {
 	 */
 	int remote_node_defrag_ratio;
 #endif
+
+#ifdef CONFIG_SLAB_FREELIST_RANDOM
+	freelist_idx_t *random_seq;
+#endif
+
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
diff --git a/init/Kconfig b/init/Kconfig
index 7b82f3f..4590629 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1784,10 +1784,10 @@ endchoice
 
 config SLAB_FREELIST_RANDOM
 	default n
-	depends on SLAB
+	depends on SLAB || SLUB
 	bool "SLAB freelist randomization"
 	help
-	  Randomizes the freelist order used on creating new SLABs. This
+	  Randomizes the freelist order used on creating new pages. This
 	  security feature reduces the predictability of the kernel slab
 	  allocator against heap overflows.
 
diff --git a/mm/slub.c b/mm/slub.c
index 538c858..d89780a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1405,6 +1405,111 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	return page;
 }
 
+#ifdef CONFIG_SLAB_FREELIST_RANDOM
+/* Pre-initialize the random sequence cache */
+static int init_cache_random_seq(struct kmem_cache *s)
+{
+	int err;
+	unsigned long i, count = oo_objects(s->oo);
+
+	err = cache_random_seq_create(s, count, GFP_KERNEL);
+	if (err) {
+		pr_err("SLUB: Unable to initialize free list for %s\n",
+			s->name);
+		return err;
+	}
+
+	/* Transform to an offset on the set of pages */
+	if (s->random_seq) {
+		for (i = 0; i < count; i++)
+			s->random_seq[i] *= s->size;
+	}
+	return 0;
+}
+
+/* Initialize each random sequence freelist per cache */
+static void __init init_freelist_randomization(void)
+{
+	struct kmem_cache *s;
+
+	mutex_lock(&slab_mutex);
+
+	list_for_each_entry(s, &slab_caches, list)
+		init_cache_random_seq(s);
+
+	mutex_unlock(&slab_mutex);
+}
+
+/* Get the next entry on the pre-computed freelist randomized */
+static void *next_freelist_entry(struct kmem_cache *s, struct page *page,
+				unsigned long *pos, void *start,
+				unsigned long page_limit,
+				unsigned long freelist_count)
+{
+	freelist_idx_t idx;
+
+	/*
+	 * If the target page allocation failed, the number of objects on the
+	 * page might be smaller than the usual size defined by the cache.
+	 */
+	do {
+		idx = s->random_seq[*pos];
+		*pos += 1;
+		if (*pos >= freelist_count)
+			*pos = 0;
+	} while (unlikely(idx >= page_limit));
+
+	return (char *)start + idx;
+}
+
+/* Shuffle the single linked freelist based on a random pre-computed sequence */
+static bool shuffle_freelist(struct kmem_cache *s, struct page *page)
+{
+	void *start;
+	void *cur;
+	void *next;
+	unsigned long idx, pos, page_limit, freelist_count;
+
+	if (page->objects < 2 || !s->random_seq)
+		return false;
+
+	/* Use best entropy available to define a random start */
+	freelist_count = oo_objects(s->oo);
+	get_random_bytes_arch(&pos, sizeof(pos));
+	pos %= freelist_count;
+
+	page_limit = page->objects * s->size;
+	start = fixup_red_left(s, page_address(page));
+
+	/* First entry is used as the base of the freelist */
+	cur = next_freelist_entry(s, page, &pos, start, page_limit,
+				freelist_count);
+	page->freelist = cur;
+
+	for (idx = 1; idx < page->objects; idx++) {
+		setup_object(s, page, cur);
+		next = next_freelist_entry(s, page, &pos, start, page_limit,
+			freelist_count);
+		set_freepointer(s, cur, next);
+		cur = next;
+	}
+	setup_object(s, page, cur);
+	set_freepointer(s, cur, NULL);
+
+	return true;
+}
+#else
+static inline int init_cache_random_seq(struct kmem_cache *s)
+{
+	return 0;
+}
+static inline void init_freelist_randomization(void) { }
+static inline bool shuffle_freelist(struct kmem_cache *s, struct page *page)
+{
+	return false;
+}
+#endif /* CONFIG_SLAB_FREELIST_RANDOM */
+
 static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
@@ -1412,6 +1517,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	gfp_t alloc_gfp;
 	void *start, *p;
 	int idx, order;
+	bool shuffle;
 
 	flags &= gfp_allowed_mask;
 
@@ -1473,15 +1579,19 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 
 	kasan_poison_slab(page);
 
-	for_each_object_idx(p, idx, s, start, page->objects) {
-		setup_object(s, page, p);
-		if (likely(idx < page->objects))
-			set_freepointer(s, p, p + s->size);
-		else
-			set_freepointer(s, p, NULL);
+	shuffle = shuffle_freelist(s, page);
+
+	if (!shuffle) {
+		for_each_object_idx(p, idx, s, start, page->objects) {
+			setup_object(s, page, p);
+			if (likely(idx < page->objects))
+				set_freepointer(s, p, p + s->size);
+			else
+				set_freepointer(s, p, NULL);
+		}
+		page->freelist = fixup_red_left(s, start);
 	}
 
-	page->freelist = fixup_red_left(s, start);
 	page->inuse = page->objects;
 	page->frozen = 1;
 
@@ -3207,6 +3317,7 @@ static void free_kmem_cache_nodes(struct kmem_cache *s)
 
 void __kmem_cache_release(struct kmem_cache *s)
 {
+	cache_random_seq_destroy(s);
 	free_percpu(s->cpu_slab);
 	free_kmem_cache_nodes(s);
 }
@@ -3431,6 +3542,13 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
+
+	/* Initialize the pre-computed randomized freelist if slab is up */
+	if (slab_state >= UP) {
+		if (init_cache_random_seq(s))
+			goto error;
+	}
+
 	if (!init_kmem_cache_nodes(s))
 		goto error;
 
@@ -3947,6 +4065,9 @@ void __init kmem_cache_init(void)
 	setup_kmalloc_cache_index_table();
 	create_kmalloc_caches(0);
 
+	/* Setup random freelists for each cache */
+	init_freelist_randomization();
+
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
 #endif
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
