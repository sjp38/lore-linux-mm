Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 162CE6B02F2
	for <linux-mm@kvack.org>; Tue,  2 May 2017 10:45:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e64so50647577pfd.3
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:45:49 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id m19si12144005pgk.353.2017.05.02.07.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 07:45:48 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id v14so33553049pfd.3
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:45:48 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH V2 3/3] mm/slub: wrap kmem_cache->cpu_partial in config CONFIG_SLUB_CPU_PARTIAL
Date: Tue,  2 May 2017 22:45:33 +0800
Message-Id: <20170502144533.10729-4-richard.weiyang@gmail.com>
In-Reply-To: <20170502144533.10729-1-richard.weiyang@gmail.com>
References: <20170502144533.10729-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

kmem_cache->cpu_partial is just used when CONFIG_SLUB_CPU_PARTIAL is set,
so wrap it with config CONFIG_SLUB_CPU_PARTIAL will save some space
on 32bit arch.

This patch wrap kmem_cache->cpu_partial in config CONFIG_SLUB_CPU_PARTIAL
and wrap its sysfs too.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

---
v2: define slub_cpu_partial() to make code more elegant
---
 include/linux/slub_def.h | 13 +++++++++
 mm/slub.c                | 69 ++++++++++++++++++++++++++----------------------
 2 files changed, 51 insertions(+), 31 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index f882a34bb9aa..d808e8e6293b 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -86,7 +86,9 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int object_size;	/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	int cpu_partial;	/* Number of per cpu partial objects to keep around */
+#endif
 	struct kmem_cache_order_objects oo;
 
 	/* Allocation and freeing of slabs */
@@ -130,6 +132,17 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
+#ifdef CONFIG_SLUB_CPU_PARTIAL
+#define slub_cpu_partial(s)		((s)->cpu_partial)
+#define slub_set_cpu_partial(s, n)		\
+({						\
+	slub_cpu_partial(s) = (n);		\
+})
+#else
+#define slub_cpu_partial(s)		(0)
+#define slub_set_cpu_partial(s, n)
+#endif // CONFIG_SLUB_CPU_PARTIAL
+
 #ifdef CONFIG_SYSFS
 #define SLAB_SUPPORTS_SYSFS
 void sysfs_slab_release(struct kmem_cache *);
diff --git a/mm/slub.c b/mm/slub.c
index ae6166533261..795112b65c61 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1829,7 +1829,7 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 			stat(s, CPU_PARTIAL_NODE);
 		}
 		if (!kmem_cache_has_cpu_partial(s)
-			|| available > s->cpu_partial / 2)
+			|| available > slub_cpu_partial(s) / 2)
 			break;
 
 	}
@@ -3410,6 +3410,39 @@ static void set_min_partial(struct kmem_cache *s, unsigned long min)
 	s->min_partial = min;
 }
 
+static void set_cpu_partial(struct kmem_cache *s)
+{
+#ifdef CONFIG_SLUB_CPU_PARTIAL
+	/*
+	 * cpu_partial determined the maximum number of objects kept in the
+	 * per cpu partial lists of a processor.
+	 *
+	 * Per cpu partial lists mainly contain slabs that just have one
+	 * object freed. If they are used for allocation then they can be
+	 * filled up again with minimal effort. The slab will never hit the
+	 * per node partial lists and therefore no locking will be required.
+	 *
+	 * This setting also determines
+	 *
+	 * A) The number of objects from per cpu partial slabs dumped to the
+	 *    per node list when we reach the limit.
+	 * B) The number of objects in cpu partial slabs to extract from the
+	 *    per node list when we run out of per cpu objects. We only fetch
+	 *    50% to keep some capacity around for frees.
+	 */
+	if (!kmem_cache_has_cpu_partial(s))
+		s->cpu_partial = 0;
+	else if (s->size >= PAGE_SIZE)
+		s->cpu_partial = 2;
+	else if (s->size >= 1024)
+		s->cpu_partial = 6;
+	else if (s->size >= 256)
+		s->cpu_partial = 13;
+	else
+		s->cpu_partial = 30;
+#endif
+}
+
 /*
  * calculate_sizes() determines the order and the distribution of data within
  * a slab object.
@@ -3568,33 +3601,7 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 	 */
 	set_min_partial(s, ilog2(s->size) / 2);
 
-	/*
-	 * cpu_partial determined the maximum number of objects kept in the
-	 * per cpu partial lists of a processor.
-	 *
-	 * Per cpu partial lists mainly contain slabs that just have one
-	 * object freed. If they are used for allocation then they can be
-	 * filled up again with minimal effort. The slab will never hit the
-	 * per node partial lists and therefore no locking will be required.
-	 *
-	 * This setting also determines
-	 *
-	 * A) The number of objects from per cpu partial slabs dumped to the
-	 *    per node list when we reach the limit.
-	 * B) The number of objects in cpu partial slabs to extract from the
-	 *    per node list when we run out of per cpu objects. We only fetch
-	 *    50% to keep some capacity around for frees.
-	 */
-	if (!kmem_cache_has_cpu_partial(s))
-		s->cpu_partial = 0;
-	else if (s->size >= PAGE_SIZE)
-		s->cpu_partial = 2;
-	else if (s->size >= 1024)
-		s->cpu_partial = 6;
-	else if (s->size >= 256)
-		s->cpu_partial = 13;
-	else
-		s->cpu_partial = 30;
+	set_cpu_partial(s);
 
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
@@ -3981,7 +3988,7 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
 	 * Disable empty slabs caching. Used to avoid pinning offline
 	 * memory cgroups by kmem pages that can be freed.
 	 */
-	s->cpu_partial = 0;
+	slub_set_cpu_partial(s, 0);
 	s->min_partial = 0;
 
 	/*
@@ -4921,7 +4928,7 @@ SLAB_ATTR(min_partial);
 
 static ssize_t cpu_partial_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%u\n", s->cpu_partial);
+	return sprintf(buf, "%u\n", slub_cpu_partial(s));
 }
 
 static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
@@ -4936,7 +4943,7 @@ static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
 	if (objects && !kmem_cache_has_cpu_partial(s))
 		return -EINVAL;
 
-	s->cpu_partial = objects;
+	slub_set_cpu_partial(s, objects);
 	flush_all(s);
 	return length;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
