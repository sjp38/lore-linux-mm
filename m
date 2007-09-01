From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 04/26] SLUB: Add defrag_ratio field and sysfs support.
Date: Fri, 31 Aug 2007 18:41:11 -0700
Message-ID: <20070901014220.222604174@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0004-slab_defrag_add_defrag_ratio.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

The defrag_ratio is used to set the threshold when a slabcache should be
defragmented.

The allocation ratio is measured in a percentage of the available slots.
The percentage will be lower for slabs that are more fragmented.

Add a defrag ratio field and set it to 30% by default. A limit of 30%
that less than 3 out of 10 available slots for objects are in use.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slub_def.h |    7 +++++++
 mm/slub.c                |   18 ++++++++++++++++++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 5912b58..291881d 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -52,6 +52,13 @@ struct kmem_cache {
 	void (*ctor)(void *, struct kmem_cache *, unsigned long);
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
diff --git a/mm/slub.c b/mm/slub.c
index e63aba5..f95a760 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2200,6 +2200,7 @@ static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
 		goto error;
 
 	s->refcount = 1;
+	s->defrag_ratio = 30;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 100;
 #endif
@@ -3717,6 +3718,22 @@ static ssize_t free_calls_show(struct kmem_cache *s, char *buf)
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
@@ -3759,6 +3776,7 @@ static struct attribute * slab_attrs[] = {
 	&shrink_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
+	&defrag_ratio_attr.attr,
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif
-- 
1.5.2.4

-- 
