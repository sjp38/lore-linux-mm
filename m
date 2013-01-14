Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 314E46B0068
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 01:06:06 -0500 (EST)
From: Liu Bo <bo.li.liu@oracle.com>
Subject: [PATCH] mm/slab: add a leak decoder callback
Date: Mon, 14 Jan 2013 14:03:39 +0800
Message-Id: <1358143419-13074-1-git-send-email-bo.li.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, Zach Brown <zab@zabbo.net>

This adds a leak decoder callback so that kmem_cache_destroy()
can use to generate debugging output for the allocated objects.

Callers like btrfs are using their own leak tracking which will
manage allocated objects in a list(or something else), this does
indeed the same thing as what slab does.  So adding a callback
for leak tracking can avoid this as well as runtime overhead.

Signed-off-by: Liu Bo <bo.li.liu@oracle.com>
---
The idea is from Zach Brown <zab@zabbo.net>.

 fs/btrfs/extent_io.c     |   24 ++++++++++++++++++++++++
 fs/btrfs/extent_map.c    |   12 ++++++++++++
 include/linux/slab.h     |    1 +
 include/linux/slab_def.h |    1 +
 include/linux/slub_def.h |    1 +
 mm/slab_common.c         |    1 +
 mm/slub.c                |    5 +++++
 7 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index bcc8dff..4954f3d 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -63,6 +63,26 @@ tree_fs_info(struct extent_io_tree *tree)
 	return btrfs_sb(tree->mapping->host->i_sb);
 }
 
+static void extent_state_leak_decoder(void *object)
+{
+	struct extent_state *state = object;
+
+	printk(KERN_ERR "btrfs state leak: start %llu end %llu "
+	       "state %lu in tree %p refs %d\n",
+	       (unsigned long long)state->start,
+	       (unsigned long long)state->end,
+	       state->state, state->tree, atomic_read(&state->refs));
+}
+
+static void extent_buffer_leak_decoder(void *object)
+{
+	struct extent_buffer *eb = object;
+
+	printk(KERN_ERR "btrfs buffer leak start %llu len %lu "
+	       "refs %d\n", (unsigned long long)eb->start,
+	       eb->len, atomic_read(&eb->refs));
+}
+
 int __init extent_io_init(void)
 {
 	extent_state_cache = kmem_cache_create("btrfs_extent_state",
@@ -71,11 +91,15 @@ int __init extent_io_init(void)
 	if (!extent_state_cache)
 		return -ENOMEM;
 
+	extent_state_cache->decoder = extent_state_leak_decoder;
+
 	extent_buffer_cache = kmem_cache_create("btrfs_extent_buffer",
 			sizeof(struct extent_buffer), 0,
 			SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD, NULL);
 	if (!extent_buffer_cache)
 		goto free_state_cache;
+
+	extent_buffer_cache->decoder = extent_buffer_leak_decoder;
 	return 0;
 
 free_state_cache:
diff --git a/fs/btrfs/extent_map.c b/fs/btrfs/extent_map.c
index 80370d6..d598a8d 100644
--- a/fs/btrfs/extent_map.c
+++ b/fs/btrfs/extent_map.c
@@ -16,6 +16,16 @@ static LIST_HEAD(emaps);
 static DEFINE_SPINLOCK(map_leak_lock);
 #endif
 
+static void extent_map_leak_decoder(void *object)
+{
+	struct extent_map *em = object;
+
+	printk(KERN_ERR "btrfs ext map leak: start %llu len %llu block %llu "
+	       "flags %lu refs %d in tree %d compress %d\n",
+	       em->start, em->len, em->block_start, em->flags,
+	       atomic_read(&em->refs), em->in_tree, (int)em->compress_type);
+}
+
 int __init extent_map_init(void)
 {
 	extent_map_cache = kmem_cache_create("btrfs_extent_map",
@@ -23,6 +33,8 @@ int __init extent_map_init(void)
 			SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD, NULL);
 	if (!extent_map_cache)
 		return -ENOMEM;
+
+	extent_map_cache->decoder = extent_map_leak_decoder;
 	return 0;
 }
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 5d168d7..89a9efd 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -114,6 +114,7 @@ struct kmem_cache {
 	const char *name;	/* Slab name for sysfs */
 	int refcount;		/* Use counter */
 	void (*ctor)(void *);	/* Called on object slot creation */
+	void (*decoder)(void *);/* Called on object slot leak detection */
 	struct list_head list;	/* List of all slab caches on the system */
 };
 #endif
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 8bb6e0e..7ca8309 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -48,6 +48,7 @@ struct kmem_cache {
 
 	/* constructor func */
 	void (*ctor)(void *obj);
+	void (*decoder)(void *obj);
 
 /* 4) cache creation/removal */
 	const char *name;
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 9db4825..fc18af7 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -93,6 +93,7 @@ struct kmem_cache {
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *);
+	void (*decoder)(void *);
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	int reserved;		/* Reserved bytes at the end of slabs */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3f3cd97..39a0fb2 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -193,6 +193,7 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 		s->object_size = s->size = size;
 		s->align = calculate_alignment(flags, align, size);
 		s->ctor = ctor;
+		s->decoder = NULL;
 
 		if (memcg_register_cache(memcg, s, parent_cache)) {
 			kmem_cache_free(kmem_cache, s);
diff --git a/mm/slub.c b/mm/slub.c
index ba2ca53..0496a2b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3098,6 +3098,8 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 	for_each_object(p, s, addr, page->objects) {
 
 		if (!test_bit(slab_index(p, s, addr), map)) {
+			if (unlikely(s->decoder))
+				s->decoder(p);
 			printk(KERN_ERR "INFO: Object 0x%p @offset=%tu\n",
 							p, p - addr);
 			print_tracking(s, p);
@@ -3787,6 +3789,9 @@ static int slab_unmergeable(struct kmem_cache *s)
 	if (s->ctor)
 		return 1;
 
+	if (s->decoder)
+		return 1;
+
 	/*
 	 * We may have set a slab to be unmergeable during bootstrap.
 	 */
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
