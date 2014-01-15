Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id A0D466B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 05:27:58 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so932537pdj.40
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 02:27:58 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m8si3291641pbq.149.2014.01.15.02.27.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 02:27:57 -0800 (PST)
Message-ID: <52D662A4.1080502@oracle.com>
Date: Wed, 15 Jan 2014 18:27:48 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [LSF/MM ATTEND] slab cache extension -- slab cache in fixed size
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

Hello,

I'd like to attend LSF/MM summit.  I'm mainly working in XFS, but also spent some
time in OCFS2 as well as Containers.

Now one of my wip project is to implement a compressed inode cache for XFS, which
is designed by Dave Chinner [1].

In short, this feature is intend to cache particular inodes in compressed form in
inode reclaims procedure (about 1.7k on sector size 512 by default, about 380 bytes
in compression through LZO), hence we can avoid read the inode off disk if it is
requested again.  In theory, this is similar to zswap/zram to some extent.

For the current design, I also managed to implement the "static slab" which could be
referred to the "fixed inode cache size" section in [1], since we want to prevent
the compressed inode cache from consuming excessive amounts of memory in some cases.

Now I have a rough/stupid idea to add an extension to the slab caches [2], that is
if the slab cache size is limited which could be determined in cache_grow(), the
shrinker would be triggered accordingly.  I'd like to learn/know if there are any
suggestions and similar requirements in other subsystems.


Thanks,
-Jeff


[1] http://xfs.org/index.php/Improving_inode_Caching#Compressed_Inode_Cache

[2] slab cache extension (proof of concept, can not be compiled)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 09bfffb..a68ae1d 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -10,6 +10,8 @@ struct kmem_cache {
 	unsigned int batchcount;
 	unsigned int limit;
 	unsigned int shared;
+	unsigned int cache_limit;
+	unsigned int cache_size;
 
 	unsigned int size;
 	u32 reciprocal_buffer_size;
diff --git a/mm/slab.c b/mm/slab.c
index eb043bf..e7bdc29 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2663,6 +2663,7 @@ static int cache_grow(struct kmem_cache *cachep,
 	size_t offset;
 	gfp_t local_flags;
 	struct kmem_cache_node *n;
+	int ret = 0;
 
 	/*
 	 * Be lazy and only check for valid flags here,  keeping it out of the
@@ -2700,8 +2701,19 @@ static int cache_grow(struct kmem_cache *cachep,
 	 * Get mem for the objs.  Attempt to allocate a physical page from
 	 * 'nodeid'.
 	 */
-	if (!page)
-		page = kmem_getpages(cachep, local_flags, nodeid);
+	if (!page) {
+		if (cachep->cache_limit == 0 ||
+			cachep->cache_size + 1<<cachep->gfporder <= cachep->cache_limit)
+			page = kmem_getpages(cachep, local_flags, nodeid);
+		else {
+			 /* TODO: do slab shrinker, maybe in workqueue, and then try
+			  * alloc object again.
+			  */
+			ret = 1;
+			goto failed;
+		}
+	}
+
 	if (!page)
 		goto failed;
 
@@ -2711,6 +2723,8 @@ static int cache_grow(struct kmem_cache *cachep,
 	if (!freelist)
 		goto opps1;
 
+	ret = 1;
+	cachep->cache_size += 1<<cachep->gfporder;
 	slab_map_pages(cachep, page, freelist);
 
 	cache_init_objs(cachep, page);
@@ -2725,13 +2739,13 @@ static int cache_grow(struct kmem_cache *cachep,
 	STATS_INC_GROWN(cachep);
 	n->free_objects += cachep->num;
 	spin_unlock(&n->list_lock);
-	return 1;
+	return ret;
 opps1:
 	kmem_freepages(cachep, page);
 failed:
 	if (local_flags & __GFP_WAIT)
 		local_irq_disable();
-	return 0;
+	return ret;
 }
 
 #if DEBUG
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 0b7bb39..12bac87 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -167,7 +167,8 @@ unsigned long calculate_alignment(unsigned long flags,
 
 struct kmem_cache *
 kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
-			size_t align, unsigned long flags, void (*ctor)(void *),
+			size_t align, unsigned long flags, unsigned long cache_limit,
+			void (*ctor)(void *), void (*shrinker)(void *),
 			struct kmem_cache *parent_cache)
 {
 	struct kmem_cache *s = NULL;
@@ -196,6 +197,7 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 		s->object_size = s->size = size;
 		s->align = calculate_alignment(flags, align, size);
 		s->ctor = ctor;
+		s->cache_limit = cache_limit;
 
 		if (memcg_register_cache(memcg, s, parent_cache)) {
 			kmem_cache_free(kmem_cache, s);
@@ -219,6 +221,9 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 			kfree(s->name);
 			kmem_cache_free(kmem_cache, s);
 		}
+
+		if (shrinker)
+			register_shrinker(shrinker);
 	} else
 		err = -ENOMEM;
 
@@ -247,7 +252,7 @@ struct kmem_cache *
 kmem_cache_create(const char *name, size_t size, size_t align,
 		  unsigned long flags, void (*ctor)(void *))
 {
-	return kmem_cache_create_memcg(NULL, name, size, align, flags, ctor, NULL);
+	return kmem_cache_create_memcg(NULL, name, size, align, flags, 0, ctor, NULL, NULL);
 }
 EXPORT_SYMBOL(kmem_cache_create);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
