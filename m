Message-Id: <20080216004632.097559214@sgi.com>
References: <20080216004526.763643520@sgi.com>
Date: Fri, 15 Feb 2008 16:45:28 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 02/17] SLUB: Add defrag_ratio field and sysfs support.
Content-Disposition: inline; filename=0048-SLUB-Add-defrag_ratio-field-and-sysfs-support.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

The defrag_ratio is used to set the threshold at which defragmentation
should be run on a slabcache.

The allocation ratio is measured in the percentage of the available slots
allocated. The percentage will be lower for slabs that are more fragmented.

Add a defrag ratio field and set it to 30% by default. A limit of 30% specified
that less than 3 out of 10 available slots for objects are in use before
slab defragmeentation runs.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slub_def.h |    7 +++++++
 mm/slub.c                |   18 ++++++++++++++++++
 2 files changed, 25 insertions(+)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2008-02-15 15:22:22.064550321 -0800
+++ linux-2.6/include/linux/slub_def.h	2008-02-15 15:31:53.954427883 -0800
@@ -79,6 +79,13 @@ struct kmem_cache {
 	void (*ctor)(struct kmem_cache *, void *);
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
+	int defrag_ratio;	/*
+				 * objects/possible-objects limit. If we have
+				 * less that the specified percentage of
+				 * objects allocated then defrag passes
+				 * will start to occur during reclaim.
+				 */
+
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
 #ifdef CONFIG_SLUB_DEBUG
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-02-15 15:22:22.884553646 -0800
+++ linux-2.6/mm/slub.c	2008-02-15 15:31:53.958427919 -0800
@@ -2395,6 +2395,7 @@ static int kmem_cache_open(struct kmem_c
 		goto error;
 
 	s->refcount = 1;
+	s->defrag_ratio = 30;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 100;
 #endif
@@ -4084,6 +4085,22 @@ static ssize_t free_calls_show(struct km
 }
 SLAB_ATTR_RO(free_calls);
 
+static ssize_t defrag_ratio_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->defrag_ratio);
+}
+
+static ssize_t defrag_ratio_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	int n = simple_strtoul(buf, NULL, 10);
+
+	if (n < 100)
+		s->defrag_ratio = n;
+	return length;
+}
+SLAB_ATTR(defrag_ratio);
+
 #ifdef CONFIG_NUMA
 static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
 {
@@ -4184,6 +4201,7 @@ static struct attribute *slab_attrs[] = 
 	&shrink_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
+	&defrag_ratio_attr.attr,
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
