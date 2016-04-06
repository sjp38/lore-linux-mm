Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 410826B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 15:36:03 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fe3so38989790pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 12:36:03 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id 70si6454946pfo.28.2016.04.06.12.36.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 12:36:02 -0700 (PDT)
Received: by mail-pa0-x22a.google.com with SMTP id fe3so38989591pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 12:36:02 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [RFC v1] mm: SLAB freelist randomization
Date: Wed,  6 Apr 2016 12:35:48 -0700
Message-Id: <1459971348-81477-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: gthelen@google.com, keescook@chromium.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, labbott@fedoraproject.org, Thomas Garnier <thgarnie@google.com>

Provide an optional config (CONFIG_FREELIST_RANDOM) to randomize the
SLAB freelist. This security feature reduces the predictability of
the kernel slab allocator against heap overflows.

Randomized lists are pre-computed using a Fisher-Yates shuffle and
re-used on slab creation for performance.
---
Based on next-20160405
---
 init/Kconfig |   9 ++++
 mm/slab.c    | 155 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 164 insertions(+)

diff --git a/init/Kconfig b/init/Kconfig
index 0dfd09d..ee35418 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1742,6 +1742,15 @@ config SLOB
 
 endchoice
 
+config FREELIST_RANDOM
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
index b70aabf..6f0d7be 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1229,6 +1229,59 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
 	}
 }
 
+#ifdef CONFIG_FREELIST_RANDOM
+/*
+ * Master lists are pre-computed random lists
+ * Lists of different sizes are used to optimize performance on different
+ * SLAB object sizes per pages.
+ */
+static freelist_idx_t master_list_2[2];
+static freelist_idx_t master_list_4[4];
+static freelist_idx_t master_list_8[8];
+static freelist_idx_t master_list_16[16];
+static freelist_idx_t master_list_32[32];
+static freelist_idx_t master_list_64[64];
+static freelist_idx_t master_list_128[128];
+static freelist_idx_t master_list_256[256];
+static struct m_list {
+	size_t count;
+	freelist_idx_t *list;
+} master_lists[] = {
+	{ ARRAY_SIZE(master_list_2), master_list_2 },
+	{ ARRAY_SIZE(master_list_4), master_list_4 },
+	{ ARRAY_SIZE(master_list_8), master_list_8 },
+	{ ARRAY_SIZE(master_list_16), master_list_16 },
+	{ ARRAY_SIZE(master_list_32), master_list_32 },
+	{ ARRAY_SIZE(master_list_64), master_list_64 },
+	{ ARRAY_SIZE(master_list_128), master_list_128 },
+	{ ARRAY_SIZE(master_list_256), master_list_256 },
+};
+
+void __init freelist_random_init(void)
+{
+	unsigned int seed;
+	size_t z, i, rand;
+	struct rnd_state slab_rand;
+
+	get_random_bytes_arch(&seed, sizeof(seed));
+	prandom_seed_state(&slab_rand, seed);
+
+	for (z = 0; z < ARRAY_SIZE(master_lists); z++) {
+		for (i = 0; i < master_lists[z].count; i++)
+			master_lists[z].list[i] = i;
+
+		/* Fisher-Yates shuffle */
+		for (i = master_lists[z].count - 1; i > 0; i--) {
+			rand = prandom_u32_state(&slab_rand);
+			rand %= (i + 1);
+			swap(master_lists[z].list[i],
+				master_lists[z].list[rand]);
+		}
+	}
+}
+#endif /* CONFIG_FREELIST_RANDOM */
+
+
 /*
  * Initialisation.  Called after the page allocator have been initialised and
  * before smp_init().
@@ -1255,6 +1308,10 @@ void __init kmem_cache_init(void)
 	if (!slab_max_order_set && totalram_pages > (32 << 20) >> PAGE_SHIFT)
 		slab_max_order = SLAB_MAX_ORDER_HI;
 
+#ifdef CONFIG_FREELIST_RANDOM
+	freelist_random_init();
+#endif /* CONFIG_FREELIST_RANDOM */
+
 	/* Bootstrap is tricky, because several objects are allocated
 	 * from caches that do not exist yet:
 	 * 1) initialize the kmem_cache cache: it contains the struct
@@ -2442,6 +2499,98 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
 #endif
 }
 
+#ifdef CONFIG_FREELIST_RANDOM
+enum master_type {
+	match,
+	less,
+	more
+};
+
+struct random_mng {
+	unsigned int padding;
+	unsigned int pos;
+	unsigned int count;
+	struct m_list master_list;
+	unsigned int master_count;
+	enum master_type type;
+};
+
+static void random_mng_initialize(struct random_mng *mng, unsigned int count)
+{
+	unsigned int idx;
+	const unsigned int last_idx = ARRAY_SIZE(master_lists) - 1;
+
+	memset(mng, 0, sizeof(*mng));
+	mng->count = count;
+	mng->pos = 0;
+	/* count is >= 2 */
+	idx = ilog2(count) - 1;
+	if (idx >= last_idx)
+		idx = last_idx;
+	else if (roundup_pow_of_two(idx + 1) != count)
+		idx++;
+	mng->master_list = master_lists[idx];
+	if (mng->master_list.count == mng->count)
+		mng->type = match;
+	else if (mng->master_list.count > mng->count)
+		mng->type = more;
+	else
+		mng->type = less;
+}
+
+static freelist_idx_t get_next_entry(struct random_mng *mng)
+{
+	if (mng->type == less && mng->pos == mng->master_list.count) {
+		mng->padding += mng->pos;
+		mng->pos = 0;
+	}
+	BUG_ON(mng->pos >= mng->master_list.count);
+	return mng->master_list.list[mng->pos++];
+}
+
+static freelist_idx_t next_random_slot(struct random_mng *mng)
+{
+	freelist_idx_t cur, entry;
+
+	entry = get_next_entry(mng);
+
+	if (mng->type != match) {
+		while ((entry + mng->padding) >= mng->count)
+			entry = get_next_entry(mng);
+		cur = entry + mng->padding;
+		BUG_ON(cur >= mng->count);
+	} else {
+		cur = entry;
+	}
+
+	return cur;
+}
+
+static void shuffle_freelist(struct kmem_cache *cachep, struct page *page,
+			     unsigned int count)
+{
+	unsigned int i;
+	struct random_mng mng;
+
+	if (count < 2) {
+		for (i = 0; i < count; i++)
+			set_free_obj(page, i, i);
+		return;
+	}
+
+	/* Last chunk is used already in this case */
+	if (OBJFREELIST_SLAB(cachep))
+		count--;
+
+	random_mng_initialize(&mng, count);
+	for (i = 0; i < count; i++)
+		set_free_obj(page, i, next_random_slot(&mng));
+
+	if (OBJFREELIST_SLAB(cachep))
+		set_free_obj(page, i, i);
+}
+#endif /* CONFIG_FREELIST_RANDOM */
+
 static void cache_init_objs(struct kmem_cache *cachep,
 			    struct page *page)
 {
@@ -2464,8 +2613,14 @@ static void cache_init_objs(struct kmem_cache *cachep,
 			kasan_poison_object_data(cachep, objp);
 		}
 
+#ifndef CONFIG_FREELIST_RANDOM
 		set_free_obj(page, i, i);
+#endif /* CONFIG_FREELIST_RANDOM */
 	}
+
+#ifdef CONFIG_FREELIST_RANDOM
+	shuffle_freelist(cachep, page, cachep->num);
+#endif /* CONFIG_FREELIST_RANDOM */
 }
 
 static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
