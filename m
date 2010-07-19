Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8AD9A6B02A3
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 16:26:47 -0400 (EDT)
In-Reply-To: <4C46FD67.8070808@redhat.com>
References: <4C46FD67.8070808@redhat.com>
From: Andreas Gruenbacher <agruen@suse.de>
Date: Mon, 19 Jul 2010 18:19:41 +0200
Subject: [PATCH 1/2] mbcache: Remove unused features
Message-Id: <20100721202636.B94F83C539AA@imap.suse.de>
Sender: owner-linux-mm@kvack.org
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Eric Sandeen <sandeen@redhat.com>, hch@infradead.org, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors <kernel-janitors@vger.kernel.org>, Wang Sheng-Hui <crosslonelyover@gmail.com>
List-ID: <linux-mm.kvack.org>

The mbcache code was written to support a variable number of indexes,
but all the existing users use exactly one index.  Simplify to code to
support only that case.

There are also no users of the cache entry free operation, and none of
the users keep extra data in cache entries.  Remove those features as
well.

Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
---
 fs/ext2/xattr.c         |   12 ++--
 fs/ext3/xattr.c         |   12 ++--
 fs/ext4/xattr.c         |   12 ++--
 fs/mbcache.c            |  141 +++++++++++++---------------------------------
 include/linux/mbcache.h |   20 ++-----
 5 files changed, 60 insertions(+), 137 deletions(-)

diff --git a/fs/ext2/xattr.c b/fs/ext2/xattr.c
index 7c39157..af59915 100644
--- a/fs/ext2/xattr.c
+++ b/fs/ext2/xattr.c
@@ -838,7 +838,7 @@ ext2_xattr_cache_insert(struct buffer_head *bh)
 	ce = mb_cache_entry_alloc(ext2_xattr_cache, GFP_NOFS);
 	if (!ce)
 		return -ENOMEM;
-	error = mb_cache_entry_insert(ce, bh->b_bdev, bh->b_blocknr, &hash);
+	error = mb_cache_entry_insert(ce, bh->b_bdev, bh->b_blocknr, hash);
 	if (error) {
 		mb_cache_entry_free(ce);
 		if (error == -EBUSY) {
@@ -912,8 +912,8 @@ ext2_xattr_cache_find(struct inode *inode, struct ext2_xattr_header *header)
 		return NULL;  /* never share */
 	ea_idebug(inode, "looking for cached blocks [%x]", (int)hash);
 again:
-	ce = mb_cache_entry_find_first(ext2_xattr_cache, 0,
-				       inode->i_sb->s_bdev, hash);
+	ce = mb_cache_entry_find_first(ext2_xattr_cache, inode->i_sb->s_bdev,
+				       hash);
 	while (ce) {
 		struct buffer_head *bh;
 
@@ -945,7 +945,7 @@ again:
 			unlock_buffer(bh);
 			brelse(bh);
 		}
-		ce = mb_cache_entry_find_next(ce, 0, inode->i_sb->s_bdev, hash);
+		ce = mb_cache_entry_find_next(ce, inode->i_sb->s_bdev, hash);
 	}
 	return NULL;
 }
@@ -1021,9 +1021,7 @@ static void ext2_xattr_rehash(struct ext2_xattr_header *header,
 int __init
 init_ext2_xattr(void)
 {
-	ext2_xattr_cache = mb_cache_create("ext2_xattr", NULL,
-		sizeof(struct mb_cache_entry) +
-		sizeof(((struct mb_cache_entry *) 0)->e_indexes[0]), 1, 6);
+	ext2_xattr_cache = mb_cache_create("ext2_xattr", 6);
 	if (!ext2_xattr_cache)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/ext3/xattr.c b/fs/ext3/xattr.c
index 71fb8d6..e69dc6d 100644
--- a/fs/ext3/xattr.c
+++ b/fs/ext3/xattr.c
@@ -1139,7 +1139,7 @@ ext3_xattr_cache_insert(struct buffer_head *bh)
 		ea_bdebug(bh, "out of memory");
 		return;
 	}
-	error = mb_cache_entry_insert(ce, bh->b_bdev, bh->b_blocknr, &hash);
+	error = mb_cache_entry_insert(ce, bh->b_bdev, bh->b_blocknr, hash);
 	if (error) {
 		mb_cache_entry_free(ce);
 		if (error == -EBUSY) {
@@ -1211,8 +1211,8 @@ ext3_xattr_cache_find(struct inode *inode, struct ext3_xattr_header *header,
 		return NULL;  /* never share */
 	ea_idebug(inode, "looking for cached blocks [%x]", (int)hash);
 again:
-	ce = mb_cache_entry_find_first(ext3_xattr_cache, 0,
-				       inode->i_sb->s_bdev, hash);
+	ce = mb_cache_entry_find_first(ext3_xattr_cache, inode->i_sb->s_bdev,
+				       hash);
 	while (ce) {
 		struct buffer_head *bh;
 
@@ -1237,7 +1237,7 @@ again:
 			return bh;
 		}
 		brelse(bh);
-		ce = mb_cache_entry_find_next(ce, 0, inode->i_sb->s_bdev, hash);
+		ce = mb_cache_entry_find_next(ce, inode->i_sb->s_bdev, hash);
 	}
 	return NULL;
 }
@@ -1313,9 +1313,7 @@ static void ext3_xattr_rehash(struct ext3_xattr_header *header,
 int __init
 init_ext3_xattr(void)
 {
-	ext3_xattr_cache = mb_cache_create("ext3_xattr", NULL,
-		sizeof(struct mb_cache_entry) +
-		sizeof(((struct mb_cache_entry *) 0)->e_indexes[0]), 1, 6);
+	ext3_xattr_cache = mb_cache_create("ext3_xattr", 6);
 	if (!ext3_xattr_cache)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/ext4/xattr.c b/fs/ext4/xattr.c
index 0433800..1c93198 100644
--- a/fs/ext4/xattr.c
+++ b/fs/ext4/xattr.c
@@ -1418,7 +1418,7 @@ ext4_xattr_cache_insert(struct buffer_head *bh)
 		ea_bdebug(bh, "out of memory");
 		return;
 	}
-	error = mb_cache_entry_insert(ce, bh->b_bdev, bh->b_blocknr, &hash);
+	error = mb_cache_entry_insert(ce, bh->b_bdev, bh->b_blocknr, hash);
 	if (error) {
 		mb_cache_entry_free(ce);
 		if (error == -EBUSY) {
@@ -1490,8 +1490,8 @@ ext4_xattr_cache_find(struct inode *inode, struct ext4_xattr_header *header,
 		return NULL;  /* never share */
 	ea_idebug(inode, "looking for cached blocks [%x]", (int)hash);
 again:
-	ce = mb_cache_entry_find_first(ext4_xattr_cache, 0,
-				       inode->i_sb->s_bdev, hash);
+	ce = mb_cache_entry_find_first(ext4_xattr_cache, inode->i_sb->s_bdev,
+				       hash);
 	while (ce) {
 		struct buffer_head *bh;
 
@@ -1515,7 +1515,7 @@ again:
 			return bh;
 		}
 		brelse(bh);
-		ce = mb_cache_entry_find_next(ce, 0, inode->i_sb->s_bdev, hash);
+		ce = mb_cache_entry_find_next(ce, inode->i_sb->s_bdev, hash);
 	}
 	return NULL;
 }
@@ -1591,9 +1591,7 @@ static void ext4_xattr_rehash(struct ext4_xattr_header *header,
 int __init
 init_ext4_xattr(void)
 {
-	ext4_xattr_cache = mb_cache_create("ext4_xattr", NULL,
-		sizeof(struct mb_cache_entry) +
-		sizeof(((struct mb_cache_entry *) 0)->e_indexes[0]), 1, 6);
+	ext4_xattr_cache = mb_cache_create("ext4_xattr", 6);
 	if (!ext4_xattr_cache)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/mbcache.c b/fs/mbcache.c
index e28f21b..8a2cbd8 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -79,15 +79,11 @@ EXPORT_SYMBOL(mb_cache_entry_find_next);
 struct mb_cache {
 	struct list_head		c_cache_list;
 	const char			*c_name;
-	struct mb_cache_op		c_op;
 	atomic_t			c_entry_count;
 	int				c_bucket_bits;
-#ifndef MB_CACHE_INDEXES_COUNT
-	int				c_indexes_count;
-#endif
-	struct kmem_cache			*c_entry_cache;
+	struct kmem_cache		*c_entry_cache;
 	struct list_head		*c_block_hash;
-	struct list_head		*c_indexes_hash[0];
+	struct list_head		*c_index_hash;
 };
 
 
@@ -101,16 +97,6 @@ static LIST_HEAD(mb_cache_list);
 static LIST_HEAD(mb_cache_lru_list);
 static DEFINE_SPINLOCK(mb_cache_spinlock);
 
-static inline int
-mb_cache_indexes(struct mb_cache *cache)
-{
-#ifdef MB_CACHE_INDEXES_COUNT
-	return MB_CACHE_INDEXES_COUNT;
-#else
-	return cache->c_indexes_count;
-#endif
-}
-
 /*
  * What the mbcache registers as to get shrunk dynamically.
  */
@@ -132,12 +118,9 @@ __mb_cache_entry_is_hashed(struct mb_cache_entry *ce)
 static void
 __mb_cache_entry_unhash(struct mb_cache_entry *ce)
 {
-	int n;
-
 	if (__mb_cache_entry_is_hashed(ce)) {
 		list_del_init(&ce->e_block_list);
-		for (n=0; n<mb_cache_indexes(ce->e_cache); n++)
-			list_del(&ce->e_indexes[n].o_list);
+		list_del(&ce->e_index.o_list);
 	}
 }
 
@@ -148,16 +131,8 @@ __mb_cache_entry_forget(struct mb_cache_entry *ce, gfp_t gfp_mask)
 	struct mb_cache *cache = ce->e_cache;
 
 	mb_assert(!(ce->e_used || ce->e_queued));
-	if (cache->c_op.free && cache->c_op.free(ce, gfp_mask)) {
-		/* free failed -- put back on the lru list
-		   for freeing later. */
-		spin_lock(&mb_cache_spinlock);
-		list_add(&ce->e_lru_list, &mb_cache_lru_list);
-		spin_unlock(&mb_cache_spinlock);
-	} else {
-		kmem_cache_free(cache->c_entry_cache, ce);
-		atomic_dec(&cache->c_entry_count);
-	}
+	kmem_cache_free(cache->c_entry_cache, ce);
+	atomic_dec(&cache->c_entry_count);
 }
 
 
@@ -243,72 +218,49 @@ out:
  * memory was available.
  *
  * @name: name of the cache (informal)
- * @cache_op: contains the callback called when freeing a cache entry
- * @entry_size: The size of a cache entry, including
- *              struct mb_cache_entry
- * @indexes_count: number of additional indexes in the cache. Must equal
- *                 MB_CACHE_INDEXES_COUNT if the number of indexes is
- *                 hardwired.
  * @bucket_bits: log2(number of hash buckets)
  */
 struct mb_cache *
-mb_cache_create(const char *name, struct mb_cache_op *cache_op,
-		size_t entry_size, int indexes_count, int bucket_bits)
+mb_cache_create(const char *name, int bucket_bits)
 {
-	int m=0, n, bucket_count = 1 << bucket_bits;
+	int n, bucket_count = 1 << bucket_bits;
 	struct mb_cache *cache = NULL;
 
-	if(entry_size < sizeof(struct mb_cache_entry) +
-	   indexes_count * sizeof(((struct mb_cache_entry *) 0)->e_indexes[0]))
-		return NULL;
-
-	cache = kmalloc(sizeof(struct mb_cache) +
-	                indexes_count * sizeof(struct list_head), GFP_KERNEL);
+	cache = kmalloc(sizeof(struct mb_cache), GFP_KERNEL);
 	if (!cache)
-		goto fail;
+		return NULL;
 	cache->c_name = name;
-	cache->c_op.free = NULL;
-	if (cache_op)
-		cache->c_op.free = cache_op->free;
 	atomic_set(&cache->c_entry_count, 0);
 	cache->c_bucket_bits = bucket_bits;
-#ifdef MB_CACHE_INDEXES_COUNT
-	mb_assert(indexes_count == MB_CACHE_INDEXES_COUNT);
-#else
-	cache->c_indexes_count = indexes_count;
-#endif
 	cache->c_block_hash = kmalloc(bucket_count * sizeof(struct list_head),
 	                              GFP_KERNEL);
 	if (!cache->c_block_hash)
 		goto fail;
 	for (n=0; n<bucket_count; n++)
 		INIT_LIST_HEAD(&cache->c_block_hash[n]);
-	for (m=0; m<indexes_count; m++) {
-		cache->c_indexes_hash[m] = kmalloc(bucket_count *
-		                                 sizeof(struct list_head),
-		                                 GFP_KERNEL);
-		if (!cache->c_indexes_hash[m])
-			goto fail;
-		for (n=0; n<bucket_count; n++)
-			INIT_LIST_HEAD(&cache->c_indexes_hash[m][n]);
-	}
-	cache->c_entry_cache = kmem_cache_create(name, entry_size, 0,
+	cache->c_index_hash = kmalloc(bucket_count * sizeof(struct list_head),
+				      GFP_KERNEL);
+	if (!cache->c_index_hash)
+		goto fail;
+	for (n=0; n<bucket_count; n++)
+		INIT_LIST_HEAD(&cache->c_index_hash[n]);
+	cache->c_entry_cache = kmem_cache_create(name,
+		sizeof(struct mb_cache_entry), 0,
 		SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD, NULL);
 	if (!cache->c_entry_cache)
-		goto fail;
+		goto fail2;
 
 	spin_lock(&mb_cache_spinlock);
 	list_add(&cache->c_cache_list, &mb_cache_list);
 	spin_unlock(&mb_cache_spinlock);
 	return cache;
 
+fail2:
+	kfree(cache->c_index_hash);
+
 fail:
-	if (cache) {
-		while (--m >= 0)
-			kfree(cache->c_indexes_hash[m]);
-		kfree(cache->c_block_hash);
-		kfree(cache);
-	}
+	kfree(cache->c_block_hash);
+	kfree(cache);
 	return NULL;
 }
 
@@ -357,7 +309,6 @@ mb_cache_destroy(struct mb_cache *cache)
 {
 	LIST_HEAD(free_list);
 	struct list_head *l, *ltmp;
-	int n;
 
 	spin_lock(&mb_cache_spinlock);
 	list_for_each_safe(l, ltmp, &mb_cache_lru_list) {
@@ -384,8 +335,7 @@ mb_cache_destroy(struct mb_cache *cache)
 
 	kmem_cache_destroy(cache->c_entry_cache);
 
-	for (n=0; n < mb_cache_indexes(cache); n++)
-		kfree(cache->c_indexes_hash[n]);
+	kfree(cache->c_index_hash);
 	kfree(cache->c_block_hash);
 	kfree(cache);
 }
@@ -429,17 +379,16 @@ mb_cache_entry_alloc(struct mb_cache *cache, gfp_t gfp_flags)
  *
  * @bdev: device the cache entry belongs to
  * @block: block number
- * @keys: array of additional keys. There must be indexes_count entries
- *        in the array (as specified when creating the cache).
+ * @key: lookup key
  */
 int
 mb_cache_entry_insert(struct mb_cache_entry *ce, struct block_device *bdev,
-		      sector_t block, unsigned int keys[])
+		      sector_t block, unsigned int key)
 {
 	struct mb_cache *cache = ce->e_cache;
 	unsigned int bucket;
 	struct list_head *l;
-	int error = -EBUSY, n;
+	int error = -EBUSY;
 
 	bucket = hash_long((unsigned long)bdev + (block & 0xffffffff), 
 			   cache->c_bucket_bits);
@@ -454,12 +403,9 @@ mb_cache_entry_insert(struct mb_cache_entry *ce, struct block_device *bdev,
 	ce->e_bdev = bdev;
 	ce->e_block = block;
 	list_add(&ce->e_block_list, &cache->c_block_hash[bucket]);
-	for (n=0; n<mb_cache_indexes(cache); n++) {
-		ce->e_indexes[n].o_key = keys[n];
-		bucket = hash_long(keys[n], cache->c_bucket_bits);
-		list_add(&ce->e_indexes[n].o_list,
-			 &cache->c_indexes_hash[n][bucket]);
-	}
+	ce->e_index.o_key = key;
+	bucket = hash_long(key, cache->c_bucket_bits);
+	list_add(&ce->e_index.o_list, &cache->c_index_hash[bucket]);
 	error = 0;
 out:
 	spin_unlock(&mb_cache_spinlock);
@@ -555,13 +501,12 @@ cleanup:
 
 static struct mb_cache_entry *
 __mb_cache_entry_find(struct list_head *l, struct list_head *head,
-		      int index, struct block_device *bdev, unsigned int key)
+		      struct block_device *bdev, unsigned int key)
 {
 	while (l != head) {
 		struct mb_cache_entry *ce =
-			list_entry(l, struct mb_cache_entry,
-			           e_indexes[index].o_list);
-		if (ce->e_bdev == bdev && ce->e_indexes[index].o_key == key) {
+			list_entry(l, struct mb_cache_entry, e_index.o_list);
+		if (ce->e_bdev == bdev && ce->e_index.o_key == key) {
 			DEFINE_WAIT(wait);
 
 			if (!list_empty(&ce->e_lru_list))
@@ -603,23 +548,20 @@ __mb_cache_entry_find(struct list_head *l, struct list_head *head,
  * returned cache entry is locked for shared access ("multiple readers").
  *
  * @cache: the cache to search
- * @index: the number of the additonal index to search (0<=index<indexes_count)
  * @bdev: the device the cache entry should belong to
  * @key: the key in the index
  */
 struct mb_cache_entry *
-mb_cache_entry_find_first(struct mb_cache *cache, int index,
-			  struct block_device *bdev, unsigned int key)
+mb_cache_entry_find_first(struct mb_cache *cache, struct block_device *bdev,
+			  unsigned int key)
 {
 	unsigned int bucket = hash_long(key, cache->c_bucket_bits);
 	struct list_head *l;
 	struct mb_cache_entry *ce;
 
-	mb_assert(index < mb_cache_indexes(cache));
 	spin_lock(&mb_cache_spinlock);
-	l = cache->c_indexes_hash[index][bucket].next;
-	ce = __mb_cache_entry_find(l, &cache->c_indexes_hash[index][bucket],
-	                           index, bdev, key);
+	l = cache->c_index_hash[bucket].next;
+	ce = __mb_cache_entry_find(l, &cache->c_index_hash[bucket], bdev, key);
 	spin_unlock(&mb_cache_spinlock);
 	return ce;
 }
@@ -640,12 +582,11 @@ mb_cache_entry_find_first(struct mb_cache *cache, int index,
  * }
  *
  * @prev: The previous match
- * @index: the number of the additonal index to search (0<=index<indexes_count)
  * @bdev: the device the cache entry should belong to
  * @key: the key in the index
  */
 struct mb_cache_entry *
-mb_cache_entry_find_next(struct mb_cache_entry *prev, int index,
+mb_cache_entry_find_next(struct mb_cache_entry *prev,
 			 struct block_device *bdev, unsigned int key)
 {
 	struct mb_cache *cache = prev->e_cache;
@@ -653,11 +594,9 @@ mb_cache_entry_find_next(struct mb_cache_entry *prev, int index,
 	struct list_head *l;
 	struct mb_cache_entry *ce;
 
-	mb_assert(index < mb_cache_indexes(cache));
 	spin_lock(&mb_cache_spinlock);
-	l = prev->e_indexes[index].o_list.next;
-	ce = __mb_cache_entry_find(l, &cache->c_indexes_hash[index][bucket],
-	                           index, bdev, key);
+	l = prev->e_index.o_list.next;
+	ce = __mb_cache_entry_find(l, &cache->c_index_hash[bucket], bdev, key);
 	__mb_cache_entry_release_unlock(prev);
 	return ce;
 }
diff --git a/include/linux/mbcache.h b/include/linux/mbcache.h
index a09b84e..54cbbac 100644
--- a/include/linux/mbcache.h
+++ b/include/linux/mbcache.h
@@ -4,9 +4,6 @@
   (C) 2001 by Andreas Gruenbacher, <a.gruenbacher@computer.org>
 */
 
-/* Hardwire the number of additional indexes */
-#define MB_CACHE_INDEXES_COUNT 1
-
 struct mb_cache_entry {
 	struct list_head		e_lru_list;
 	struct mb_cache			*e_cache;
@@ -18,17 +15,12 @@ struct mb_cache_entry {
 	struct {
 		struct list_head	o_list;
 		unsigned int		o_key;
-	} e_indexes[0];
-};
-
-struct mb_cache_op {
-	int (*free)(struct mb_cache_entry *, gfp_t);
+	} e_index;
 };
 
 /* Functions on caches */
 
-struct mb_cache * mb_cache_create(const char *, struct mb_cache_op *, size_t,
-				  int, int);
+struct mb_cache *mb_cache_create(const char *, int);
 void mb_cache_shrink(struct block_device *);
 void mb_cache_destroy(struct mb_cache *);
 
@@ -36,17 +28,15 @@ void mb_cache_destroy(struct mb_cache *);
 
 struct mb_cache_entry *mb_cache_entry_alloc(struct mb_cache *, gfp_t);
 int mb_cache_entry_insert(struct mb_cache_entry *, struct block_device *,
-			  sector_t, unsigned int[]);
+			  sector_t, unsigned int);
 void mb_cache_entry_release(struct mb_cache_entry *);
 void mb_cache_entry_free(struct mb_cache_entry *);
 struct mb_cache_entry *mb_cache_entry_get(struct mb_cache *,
 					  struct block_device *,
 					  sector_t);
-#if !defined(MB_CACHE_INDEXES_COUNT) || (MB_CACHE_INDEXES_COUNT > 0)
-struct mb_cache_entry *mb_cache_entry_find_first(struct mb_cache *cache, int,
+struct mb_cache_entry *mb_cache_entry_find_first(struct mb_cache *cache,
 						 struct block_device *, 
 						 unsigned int);
-struct mb_cache_entry *mb_cache_entry_find_next(struct mb_cache_entry *, int,
+struct mb_cache_entry *mb_cache_entry_find_next(struct mb_cache_entry *,
 						struct block_device *, 
 						unsigned int);
-#endif
-- 
1.7.2.rc3.57.g77b5b


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
