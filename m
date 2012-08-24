Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 28A546B0068
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:07:09 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so4071582pbb.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 09:07:08 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/2] slub: rename cpu_partial to max_cpu_object
Date: Sat, 25 Aug 2012 01:05:02 +0900
Message-Id: <1345824303-30292-1-git-send-email-js1304@gmail.com>
In-Reply-To: <Yes>
References: <Yes>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux-foundation.org>

cpu_partial of kmem_cache struct is a bit awkward.

It means the maximum number of objects kept in the per cpu slab
and cpu partial lists of a processor. However, current name
seems to represent objects kept in the cpu partial lists only.
So, this patch renames it.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index df448ad..9130e6b 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -84,7 +84,7 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int object_size;	/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
-	int cpu_partial;	/* Number of per cpu partial objects to keep around */
+	int max_cpu_object;	/* Number of per cpu objects to keep around */
 	struct kmem_cache_order_objects oo;
 
 	/* Allocation and freeing of slabs */
diff --git a/mm/slub.c b/mm/slub.c
index c67bd0a..d597530 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1565,7 +1565,7 @@ static void *get_partial_node(struct kmem_cache *s,
 			available = put_cpu_partial(s, page, 0);
 			stat(s, CPU_PARTIAL_NODE);
 		}
-		if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
+		if (kmem_cache_debug(s) || available > s->max_cpu_object / 2)
 			break;
 
 	}
@@ -1953,7 +1953,7 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 		if (oldpage) {
 			pobjects = oldpage->pobjects;
 			pages = oldpage->pages;
-			if (drain && pobjects > s->cpu_partial) {
+			if (drain && pobjects > s->max_cpu_object) {
 				unsigned long flags;
 				/*
 				 * partial array is full. Move the existing
@@ -3073,8 +3073,8 @@ static int kmem_cache_open(struct kmem_cache *s,
 	set_min_partial(s, ilog2(s->size) / 2);
 
 	/*
-	 * cpu_partial determined the maximum number of objects kept in the
-	 * per cpu partial lists of a processor.
+	 * max_cpu_object determined the maximum number of objects kept in the
+	 * per cpu slab and cpu partial lists of a processor.
 	 *
 	 * Per cpu partial lists mainly contain slabs that just have one
 	 * object freed. If they are used for allocation then they can be
@@ -3085,20 +3085,20 @@ static int kmem_cache_open(struct kmem_cache *s,
 	 *
 	 * A) The number of objects from per cpu partial slabs dumped to the
 	 *    per node list when we reach the limit.
-	 * B) The number of objects in cpu partial slabs to extract from the
-	 *    per node list when we run out of per cpu objects. We only fetch 50%
-	 *    to keep some capacity around for frees.
+	 * B) The number of objects in cpu slab and cpu partial lists to
+	 *    extract from the per node list when we run out of per cpu objects.
+	 *    We only fetch 50% to keep some capacity around for frees.
 	 */
 	if (kmem_cache_debug(s))
-		s->cpu_partial = 0;
+		s->max_cpu_object = 0;
 	else if (s->size >= PAGE_SIZE)
-		s->cpu_partial = 2;
+		s->max_cpu_object = 2;
 	else if (s->size >= 1024)
-		s->cpu_partial = 6;
+		s->max_cpu_object = 6;
 	else if (s->size >= 256)
-		s->cpu_partial = 13;
+		s->max_cpu_object = 13;
 	else
-		s->cpu_partial = 30;
+		s->max_cpu_object = 30;
 
 	s->refcount = 1;
 #ifdef CONFIG_NUMA
@@ -4677,12 +4677,12 @@ static ssize_t min_partial_store(struct kmem_cache *s, const char *buf,
 }
 SLAB_ATTR(min_partial);
 
-static ssize_t cpu_partial_show(struct kmem_cache *s, char *buf)
+static ssize_t max_cpu_object_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%u\n", s->cpu_partial);
+	return sprintf(buf, "%u\n", s->max_cpu_object);
 }
 
-static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
+static ssize_t max_cpu_object_store(struct kmem_cache *s, const char *buf,
 				 size_t length)
 {
 	unsigned long objects;
@@ -4694,11 +4694,11 @@ static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
 	if (objects && kmem_cache_debug(s))
 		return -EINVAL;
 
-	s->cpu_partial = objects;
+	s->max_cpu_object = objects;
 	flush_all(s);
 	return length;
 }
-SLAB_ATTR(cpu_partial);
+SLAB_ATTR(max_cpu_object);
 
 static ssize_t ctor_show(struct kmem_cache *s, char *buf)
 {
@@ -5103,7 +5103,7 @@ static struct attribute *slab_attrs[] = {
 	&objs_per_slab_attr.attr,
 	&order_attr.attr,
 	&min_partial_attr.attr,
-	&cpu_partial_attr.attr,
+	&max_cpu_object_attr.attr,
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
 	&partial_attr.attr,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
