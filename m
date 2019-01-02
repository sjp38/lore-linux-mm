Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22BC58E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 11:09:11 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id c84so37671857qkb.13
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 08:09:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17sor27399959qvl.33.2019.01.02.08.09.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 08:09:10 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH] kmemleak: survive in a low-memory situation
Date: Wed,  2 Jan 2019 11:08:49 -0500
Message-Id: <20190102160849.11480-1-cai@lca.pw>
In-Reply-To: <0b2ecfe8-b98b-755c-5b5d-00a09a0d9e57@lca.pw>
References: <0b2ecfe8-b98b-755c-5b5d-00a09a0d9e57@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

Kmemleak could quickly fail to allocate an object structure and then
disable itself in a low-memory situation. For example, running a mmap()
workload triggering swapping and OOM [1].

First, it unnecessarily attempt to allocate even though the tracking
object is NULL in kmem_cache_alloc(). For example,

alloc_io
  bio_alloc_bioset
    mempool_alloc
      mempool_alloc_slab
        kmem_cache_alloc
          slab_alloc_node
            __slab_alloc <-- could return NULL
            slab_post_alloc_hook
              kmemleak_alloc_recursive

Second, kmemleak allocation could fail even though the trackig object is
succeeded. Hence, it could still try to start a direct reclaim if it is
not executed in an atomic context (spinlock, irq-handler etc), or a
high-priority allocation in an atomic context as a last-ditch effort.

[1]
https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/oom/oom01.c

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/kmemleak.c | 10 ++++++++++
 mm/slab.h     | 17 +++++++++--------
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f9d9dc250428..9e1aa3b7df75 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -576,6 +576,16 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	struct rb_node **link, *rb_parent;
 
 	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
+#ifdef CONFIG_PREEMPT_COUNT
+	if (!object) {
+		/* last-ditch effort in a low-memory situation */
+		if (irqs_disabled() || is_idle_task(current) || in_atomic())
+			gfp = GFP_ATOMIC;
+		else
+			gfp = gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
+		object = kmem_cache_alloc(object_cache, gfp);
+	}
+#endif
 	if (!object) {
 		pr_warn("Cannot allocate a kmemleak_object structure\n");
 		kmemleak_disable();
diff --git a/mm/slab.h b/mm/slab.h
index 4190c24ef0e9..51a9a942cc56 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -435,15 +435,16 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
 {
 	size_t i;
 
-	flags &= gfp_allowed_mask;
-	for (i = 0; i < size; i++) {
-		void *object = p[i];
-
-		kmemleak_alloc_recursive(object, s->object_size, 1,
-					 s->flags, flags);
-		p[i] = kasan_slab_alloc(s, object, flags);
+	if (*p) {
+		flags &= gfp_allowed_mask;
+		for (i = 0; i < size; i++) {
+			void *object = p[i];
+
+			kmemleak_alloc_recursive(object, s->object_size, 1,
+						 s->flags, flags);
+			p[i] = kasan_slab_alloc(s, object, flags);
+		}
 	}
-
 	if (memcg_kmem_enabled())
 		memcg_kmem_put_cache(s);
 }
-- 
2.17.2 (Apple Git-113)
