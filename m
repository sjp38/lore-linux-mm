Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6072B6B02F3
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 07:32:14 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j23so33899918pgn.19
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 04:32:14 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id b69si11629617pfl.158.2017.04.30.04.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 04:32:13 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id v1so12200286pgv.3
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 04:32:13 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 3/3] mm/slub: wrap kmem_cache->cpu_partial in config CONFIG_SLUB_CPU_PARTIAL
Date: Sun, 30 Apr 2017 19:31:52 +0800
Message-Id: <20170430113152.6590-4-richard.weiyang@gmail.com>
In-Reply-To: <20170430113152.6590-1-richard.weiyang@gmail.com>
References: <20170430113152.6590-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

kmem_cache->cpu_partial is just used when CONFIG_SLUB_CPU_PARTIAL is set,
so wrap it with config CONFIG_SLUB_CPU_PARTIAL will save some space
on 32bit arch.

This patch wrap kmem_cache->cpu_partial in config CONFIG_SLUB_CPU_PARTIAL
and wrap its sysfs too.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/slub_def.h |  2 ++
 mm/slub.c                | 72 +++++++++++++++++++++++++++++-------------------
 2 files changed, 46 insertions(+), 28 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 0debd8df1a7d..477ab99800ed 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -69,7 +69,9 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int object_size;	/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	int cpu_partial;	/* Number of per cpu partial objects to keep around */
+#endif
 	struct kmem_cache_order_objects oo;
 
 	/* Allocation and freeing of slabs */
diff --git a/mm/slub.c b/mm/slub.c
index fde499b6dad8..94978f27882a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1829,7 +1829,10 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 			stat(s, CPU_PARTIAL_NODE);
 		}
 		if (!kmem_cache_has_cpu_partial(s)
-			|| available > s->cpu_partial / 2)
+#ifdef CONFIG_SLUB_CPU_PARTIAL
+			|| available > s->cpu_partial / 2
+#endif
+			)
 			break;
 
 	}
@@ -3418,6 +3421,39 @@ static void set_min_partial(struct kmem_cache *s, unsigned long min)
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
@@ -3576,33 +3612,7 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
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
@@ -3989,7 +3999,9 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
 	 * Disable empty slabs caching. Used to avoid pinning offline
 	 * memory cgroups by kmem pages that can be freed.
 	 */
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	s->cpu_partial = 0;
+#endif
 	s->min_partial = 0;
 
 	/*
@@ -4929,6 +4941,7 @@ static ssize_t min_partial_store(struct kmem_cache *s, const char *buf,
 }
 SLAB_ATTR(min_partial);
 
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 static ssize_t cpu_partial_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%u\n", s->cpu_partial);
@@ -4951,6 +4964,7 @@ static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
 	return length;
 }
 SLAB_ATTR(cpu_partial);
+#endif
 
 static ssize_t ctor_show(struct kmem_cache *s, char *buf)
 {
@@ -5363,7 +5377,9 @@ static struct attribute *slab_attrs[] = {
 	&objs_per_slab_attr.attr,
 	&order_attr.attr,
 	&min_partial_attr.attr,
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	&cpu_partial_attr.attr,
+#endif
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
 	&partial_attr.attr,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
