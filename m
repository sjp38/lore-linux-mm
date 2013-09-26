Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6056B0039
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 10:16:45 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so1186108pbc.35
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:16:45 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so1215714pdj.18
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:16:40 -0700 (PDT)
Message-Id: <20130926141624.741370709@kernel.org>
Date: Thu, 26 Sep 2013 22:14:32 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [RFC 4/4] cleancache: SSD backed cleancache backend
References: <20130926141428.392345308@kernel.org>
Content-Disposition: inline; filename=cleancache-backend-ssd.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, dan.magenheimer@oracle.com

This is a cleancache backend which caches page to disk, usually a SSD. The
usage model is similar like Windows readyboost. Eg, user plugs a USB drive,
and we use the USB drive to cache clean pages to reduce IO to hard disks.

The storage algorithm is quite simple so far. We just store pages in disk
sequentially. If there is no space left, just reclaim disk space sequentially
too. So write should have very good performance (and we aggregate write too).
metadata is in memory, so this doesn't work well for big size disk.

Signed-off-by: Shaohua Li <shli@kernel.org>
---
 mm/Kconfig          |    7 
 mm/Makefile         |    1 
 mm/ssd-cleancache.c |  932 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 940 insertions(+)

Index: linux/mm/ssd-cleancache.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/mm/ssd-cleancache.c	2013-09-26 21:38:45.417119257 +0800
@@ -0,0 +1,932 @@
+#include <linux/kernel.h>
+#include <linux/cleancache.h>
+#include <linux/radix-tree.h>
+#include <linux/rbtree.h>
+#include <linux/slab.h>
+#include <linux/pagemap.h>
+#include <linux/wait.h>
+#include <linux/kthread.h>
+#include <linux/hashtable.h>
+#include <linux/module.h>
+#include <linux/bio.h>
+#include <linux/blkdev.h>
+#include <linux/buffer_head.h>
+
+/* For each inode */
+struct cache_inode {
+	struct radix_tree_root pages; /* radix tree leaf stores disk location */
+	unsigned free:1;
+	spinlock_t pages_lock; /* protect above */
+
+	struct rb_node rb_node;
+	unsigned long rb_index;
+	atomic_t refcnt;
+
+	struct cache_fs *fs;
+};
+
+/* For each fs */
+struct cache_fs {
+	struct rb_root inodes;
+	bool valid;
+};
+
+struct io_slot {
+	struct cache_inode *inode;
+	pgoff_t index;
+	struct page *page;
+	sector_t sect;
+
+	void (*end_get_page)(struct page *page, int err);
+	void (*end_io)(struct io_slot *slot, int err);
+
+	struct list_head link;
+	struct hlist_node hash_link;
+
+	unsigned rw:1;
+	unsigned abort:1;
+};
+
+#define SSDCACHE_GFP (__GFP_NORETRY|__GFP_NOWARN)
+
+#define BATCH_IOPAGES_NR (128*1024/PAGE_SIZE)
+#define MAX_WRITE_PERCENTAGE 5
+static unsigned long max_pending_write_pages __read_mostly;
+
+static struct block_device *cache_bdev;
+static char *blkdev_name;
+module_param_named(cache_device_name, blkdev_name, charp, 0);
+
+struct cache_meta {
+	struct cache_inode *inode;
+	pgoff_t index;
+};
+
+#define PAGE_SECTOR_SHIFT (PAGE_SHIFT - 9)
+#define META_PAGE_ENTRY_NR (PAGE_SIZE / sizeof(struct cache_meta))
+static struct cache_meta *cache_meta;
+static unsigned long data_alloc_index = 1;
+static unsigned long data_total_pages;
+static DEFINE_SPINLOCK(meta_lock);
+
+static void ssdcache_prepare_reclaim_inode_page(struct cache_inode *inode);
+static void ssdcache_reclaim_inode_page(struct cache_inode *inode,
+	pgoff_t index);
+/* alloc can sleep, free not */
+static sector_t ssdcache_alloc_sector(struct cache_inode *inode,
+	pgoff_t index)
+{
+	sector_t sect;
+	struct cache_inode *reclaim_inode;
+	pgoff_t reclaim_index;
+	unsigned long flags;
+	bool reclaim_run = false;
+
+	spin_lock_irqsave(&meta_lock, flags);
+again:
+	/* we must skip sector 0, as 0 == NULL */
+	if (cache_meta[data_alloc_index].inode == NULL) {
+		cache_meta[data_alloc_index].inode = inode;
+		cache_meta[data_alloc_index].index = index;
+		sect = data_alloc_index << PAGE_SECTOR_SHIFT;
+		data_alloc_index = (data_alloc_index + 1) % data_total_pages;
+		if (data_alloc_index == 0)
+			data_alloc_index = 1;
+		spin_unlock_irqrestore(&meta_lock, flags);
+		return sect;
+	}
+
+	/* The slot is busy IO */
+	if (reclaim_run) {
+		data_alloc_index = (data_alloc_index + 1) % data_total_pages;
+		if (data_alloc_index == 0)
+			data_alloc_index = 1;
+		reclaim_run = false;
+		goto again;
+	}
+
+	/*
+	 * We can make sure the inode is valid, because ssdcache_free_sector
+	 * holds meta_lock too. If sector isn't freed, inode isn't freed
+	 */
+	reclaim_inode = cache_meta[data_alloc_index].inode;
+	reclaim_index = cache_meta[data_alloc_index].index;
+	ssdcache_prepare_reclaim_inode_page(reclaim_inode);
+	spin_unlock_irqrestore(&meta_lock, flags);
+
+	ssdcache_reclaim_inode_page(reclaim_inode, reclaim_index);
+	reclaim_run = true;
+
+	spin_lock_irqsave(&meta_lock, flags);
+	goto again;
+}
+
+static void ssdcache_free_sector(sector_t sect)
+{
+	unsigned long flags;
+
+	pgoff_t index = sect >> PAGE_SECTOR_SHIFT;
+
+	spin_lock_irqsave(&meta_lock, flags);
+	BUG_ON(cache_meta[index].inode == NULL);
+	cache_meta[index].inode = NULL;
+	cache_meta[index].index = 0;
+	spin_unlock_irqrestore(&meta_lock, flags);
+}
+
+static void ssdcache_access_sector(sector_t sect)
+{
+	/* maybe a lru algorithm */
+}
+
+#define IOSLOT_HASH_BITS 8
+static DEFINE_HASHTABLE(io_slot_hashtbl, IOSLOT_HASH_BITS);
+static LIST_HEAD(write_io_slots);
+static unsigned long pending_write_nr, total_write_nr;
+static DEFINE_SPINLOCK(io_lock);
+
+static unsigned long ssdcache_io_slot_hash(struct cache_inode *inode,
+	pgoff_t index)
+{
+	return hash_ptr(inode, IOSLOT_HASH_BITS) ^
+		hash_long(index, IOSLOT_HASH_BITS);
+}
+
+static struct io_slot *__ssdcache_find_io_slot(struct cache_inode *inode,
+	pgoff_t index)
+{
+	struct io_slot *slot;
+
+	hash_for_each_possible(io_slot_hashtbl, slot, hash_link,
+		ssdcache_io_slot_hash(inode, index)) {
+		if (slot->inode == inode && slot->index == index)
+			return slot;
+	}
+	return NULL;
+}
+
+static struct io_slot *__ssdcache_get_io_slot(int rw)
+{
+	struct io_slot *slot;
+
+	if (rw == WRITE && total_write_nr >= max_pending_write_pages) {
+		return NULL;
+	}
+
+	slot = kmalloc(sizeof(*slot), SSDCACHE_GFP);
+	if (!slot) {
+		return NULL;
+	}
+
+	INIT_LIST_HEAD(&slot->link);
+	INIT_HLIST_NODE(&slot->hash_link);
+
+	slot->abort = 0;
+
+	if (rw == WRITE)
+		total_write_nr++;
+	return slot;
+}
+
+static void __ssdcache_put_io_slot(struct io_slot *slot)
+{
+	list_del(&slot->link);
+	hlist_del(&slot->hash_link);
+
+	if (slot->rw == WRITE)
+		total_write_nr--;
+	kfree(slot);
+}
+
+static void __ssdcache_io_slot_add_hash(struct io_slot *slot)
+{
+	hash_add(io_slot_hashtbl, &slot->hash_link,
+		ssdcache_io_slot_hash(slot->inode, slot->index));
+}
+
+static void ssdcache_wakeup_worker(void);
+static void __ssdcache_queue_io_slot_write(struct io_slot *slot)
+{
+	list_add_tail(&slot->link, &write_io_slots);
+	pending_write_nr++;
+	if (pending_write_nr >= BATCH_IOPAGES_NR)
+		ssdcache_wakeup_worker();
+}
+
+static void __ssdcache_io_slot_peek_write(struct list_head *list_head)
+{
+	if (pending_write_nr < BATCH_IOPAGES_NR)
+		return;
+	pending_write_nr = 0;
+
+	list_splice_init(&write_io_slots, list_head);
+}
+
+static void ssdcache_io_slot_end_bio(struct bio *bio, int err)
+{
+	struct io_slot *slot = bio->bi_private;
+
+	slot->end_io(slot, err);
+	bio_put(bio);
+}
+
+static int ssdcache_io_slot_submit(struct io_slot *slot)
+{
+	struct bio *bio;
+
+        bio = bio_alloc(SSDCACHE_GFP, 1);
+	if (!bio)
+		return -EINVAL;
+	bio->bi_sector = slot->sect;
+	bio->bi_io_vec[0].bv_page = slot->page;
+	bio->bi_io_vec[0].bv_len = PAGE_SIZE;
+	bio->bi_io_vec[0].bv_offset = 0;
+	bio->bi_vcnt = 1;
+	bio->bi_size = PAGE_SIZE;
+	bio->bi_end_io = ssdcache_io_slot_end_bio;
+
+	bio->bi_bdev = cache_bdev;
+	bio->bi_private = slot;
+
+	submit_bio(slot->rw, bio);
+	return 0;
+}
+
+#define SSDCACHE_MAGIC 0x10293a656c656c09
+struct ssdcache_super {
+	char bootbits[1024];
+	uint64_t magic;
+} __attribute__((packed));
+
+static int ssdcache_io_init(void)
+{
+	fmode_t mode = FMODE_READ | FMODE_WRITE | FMODE_EXCL;
+	ssize_t old_blocksize;
+	sector_t max_sector;
+	struct buffer_head *bh;
+	struct ssdcache_super *super;
+	int error;
+
+	cache_bdev = blkdev_get_by_path(blkdev_name, mode, ssdcache_io_init);
+	if (IS_ERR(cache_bdev))
+		return PTR_ERR(cache_bdev);
+
+	old_blocksize = block_size(cache_bdev);
+	error = set_blocksize(cache_bdev, PAGE_SIZE);
+	if (error < 0) {
+		blkdev_put(cache_bdev, mode);
+		return error;
+	}
+
+	bh = __bread(cache_bdev, 0, PAGE_SIZE);
+	if (!bh)
+		goto error;
+	super = (struct ssdcache_super *)bh->b_data;
+	if (super->magic != cpu_to_le64(SSDCACHE_MAGIC)) {
+		printk(KERN_ERR"Wrong magic number in disk\n");
+		brelse(bh);
+		goto error;
+	}
+	brelse(bh);
+
+	max_sector = i_size_read(cache_bdev->bd_inode) >> 9;
+	max_sector = rounddown(max_sector,
+		META_PAGE_ENTRY_NR << PAGE_SECTOR_SHIFT);
+	data_total_pages = max_sector >> PAGE_SECTOR_SHIFT;
+	cache_meta = vzalloc(data_total_pages / META_PAGE_ENTRY_NR * PAGE_SIZE);
+	if (!cache_meta)
+		goto error;
+
+	max_pending_write_pages = totalram_pages * MAX_WRITE_PERCENTAGE / 100;
+	return 0;
+error:
+	set_blocksize(cache_bdev, old_blocksize);
+	blkdev_put(cache_bdev, mode);
+	return -ENOMEM;
+}
+
+#define MAX_INITIALIZABLE_FS 32
+static struct cache_fs cache_fs_array[MAX_INITIALIZABLE_FS];
+static int cache_fs_nr;
+static DEFINE_SPINLOCK(cache_fs_lock);
+
+static wait_queue_head_t io_wait;
+
+/*
+ * Cleancache ops types: G(et), P(ut), I(nvalidate), I(nvalidate)I(node).
+ * Since we make P async now, put has a sync part (P) and async part (AP).
+ *
+ * P, G, I gets page lock, so run exclusive
+ * AP can run any time
+ * II doesn't hold any lock, so can run any time
+ */
+
+static struct cache_inode *ssdcache_get_inode(struct cache_fs *fs,
+				unsigned long index, bool create)
+{
+	struct cache_inode *inode;
+	struct rb_node **rb_link, *rb_parent, *rb_prev;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cache_fs_lock, flags);
+	rb_link = &fs->inodes.rb_node;
+	rb_prev = rb_parent = NULL;
+
+	while (*rb_link) {
+		rb_parent = *rb_link;
+		inode = rb_entry(rb_parent, struct cache_inode, rb_node);
+		if (inode->rb_index > index)
+			rb_link = &rb_parent->rb_left;
+		else if (inode->rb_index < index) {
+			rb_prev = rb_parent;
+			rb_link = &rb_parent->rb_right;
+		} else {
+			atomic_inc(&inode->refcnt);
+			spin_unlock_irqrestore(&cache_fs_lock, flags);
+			return inode;
+		}
+	}
+
+	if (!create) {
+		spin_unlock_irqrestore(&cache_fs_lock, flags);
+		return NULL;
+	}
+
+	inode = kmalloc(sizeof(*inode), SSDCACHE_GFP);
+	if (!inode) {
+		spin_unlock_irqrestore(&cache_fs_lock, flags);
+		return NULL;
+	}
+
+	INIT_RADIX_TREE(&inode->pages, SSDCACHE_GFP);
+	spin_lock_init(&inode->pages_lock);
+	inode->rb_index = index;
+	rb_link_node(&inode->rb_node, rb_parent, rb_link);
+	rb_insert_color(&inode->rb_node, &fs->inodes);
+	atomic_set(&inode->refcnt, 2);
+	inode->free = 0;
+	inode->fs = fs;
+
+	spin_unlock_irqrestore(&cache_fs_lock, flags);
+	return inode;
+}
+
+static void ssdcache_put_inode(struct cache_inode *inode)
+{
+	if (atomic_dec_and_test(&inode->refcnt)) {
+		BUG_ON(!inode->free);
+
+		kfree(inode);
+	}
+}
+
+/* put and optionally abort slot */
+static void ssdcache_put_abort_slot(struct io_slot *slot)
+{
+	struct cache_inode *inode = slot->inode;
+	unsigned long flags;
+
+	spin_lock_irqsave(&io_lock, flags);
+	if (slot->abort) {
+		spin_unlock(&io_lock);
+		spin_lock(&inode->pages_lock);
+
+		radix_tree_delete(&inode->pages, slot->index);
+
+		spin_unlock_irqrestore(&inode->pages_lock, flags);
+
+		ssdcache_free_sector(slot->sect);
+
+		spin_lock_irqsave(&io_lock, flags);
+	}
+
+	__ssdcache_put_io_slot(slot);
+	spin_unlock_irqrestore(&io_lock, flags);
+}
+
+static void ssdcache_put_page_endio(struct io_slot *slot, int err)
+{
+	struct cache_inode *inode = slot->inode;
+
+	page_cache_release(slot->page);
+
+	/* if another P or II, abort is set */
+	ssdcache_put_abort_slot(slot);
+
+	ssdcache_put_inode(inode);
+}
+
+static void ssdcache_do_put_page(struct io_slot *slot)
+{
+	struct cache_inode *inode = slot->inode;
+	unsigned long flags;
+	sector_t sect, old_sect;
+	int err;
+
+	/* Make sure page reclaim isn't using this page */
+	lock_page(slot->page);
+	__clear_page_locked(slot->page);
+
+	sect = ssdcache_alloc_sector(inode, slot->index);
+
+	spin_lock_irqsave(&inode->pages_lock, flags);
+
+	old_sect = (sector_t)radix_tree_delete(&inode->pages, slot->index);
+
+	if (inode->free)
+		goto error;
+
+	err = radix_tree_insert(&inode->pages, slot->index, (void *)sect);
+	if (err)
+		goto error;
+
+	spin_unlock_irqrestore(&inode->pages_lock, flags);
+
+	/* submit IO here */
+	slot->sect = sect;
+	err = ssdcache_io_slot_submit(slot);
+	if (err)
+		goto error_io;
+
+	if (old_sect)
+		ssdcache_free_sector(old_sect);
+	return;
+
+error_io:
+	spin_lock_irqsave(&inode->pages_lock, flags);
+	radix_tree_delete(&inode->pages, slot->index);
+error:
+	spin_unlock_irqrestore(&inode->pages_lock, flags);
+
+	if (old_sect)
+		ssdcache_free_sector(old_sect);
+	/* It's impossible sect is freed by invalidate_inode as io_slot exists */
+	ssdcache_free_sector(sect);
+
+	page_cache_release(slot->page);
+
+	spin_lock_irqsave(&io_lock, flags);
+	__ssdcache_put_io_slot(slot);
+	spin_unlock_irqrestore(&io_lock, flags);
+
+	ssdcache_put_inode(inode);
+}
+
+static void ssdcache_put_page(int pool_id, struct cleancache_filekey key,
+				pgoff_t index, struct page *page)
+{
+	struct cache_fs *fs = cache_fs_array + pool_id;
+	struct cache_inode *inode;
+	unsigned long ino;
+	struct io_slot *slot;
+	sector_t sect;
+	unsigned long flags;
+
+	/* we don't support filehandle */
+	ino = key.u.ino;
+
+	inode = ssdcache_get_inode(fs, ino, true);
+	if (!inode)
+		return;
+
+	spin_lock_irqsave(&io_lock, flags);
+	slot = __ssdcache_find_io_slot(inode, index);
+	if (slot) {
+		/*
+		 * AP -> P case. we ignore P and make AP abort. AP record
+		 * should be deleted. AP and P are using different pages.
+		 */
+		BUG_ON(slot->rw != WRITE);
+		slot->abort = 1;
+		spin_unlock_irqrestore(&io_lock, flags);
+		ssdcache_put_inode(inode);
+		return;
+	}
+
+	slot = __ssdcache_get_io_slot(WRITE);
+	if (!slot)
+		goto unlock;
+
+	slot->inode = inode;
+	slot->index = index;
+	slot->page = page;
+	slot->end_io = ssdcache_put_page_endio;
+	slot->rw = WRITE;
+	__ssdcache_io_slot_add_hash(slot);
+	spin_unlock_irqrestore(&io_lock, flags);
+
+	spin_lock_irqsave(&inode->pages_lock, flags);
+	sect = (sector_t)radix_tree_lookup(&inode->pages, index);
+	spin_unlock_irqrestore(&inode->pages_lock, flags);
+
+	/* the page isn't changed since last put */
+	if (sect != 0) {
+		/* II could run here */
+		ssdcache_access_sector(sect);
+		ssdcache_put_abort_slot(slot);
+
+		ssdcache_put_inode(inode);
+		return;
+	}
+
+	page_cache_get(page);
+
+	spin_lock_irqsave(&io_lock, flags);
+	__ssdcache_queue_io_slot_write(slot);
+	spin_unlock_irqrestore(&io_lock, flags);
+	return;
+unlock:
+	spin_unlock_irqrestore(&io_lock, flags);
+
+	spin_lock_irqsave(&inode->pages_lock, flags);
+	sect = (sector_t)radix_tree_delete(&inode->pages, index);
+	spin_unlock_irqrestore(&inode->pages_lock, flags);
+	ssdcache_put_inode(inode);
+	if (sect != 0)
+		ssdcache_free_sector(sect);
+}
+
+
+static void ssdcache_get_page_endio(struct io_slot *slot, int err)
+{
+	void (*end_get_page)(struct page *, int) = slot->end_get_page;
+	struct cache_inode *inode = slot->inode;
+	struct page *page = slot->page;
+
+	/* if II, abort is set */
+	ssdcache_put_abort_slot(slot);
+
+	ssdcache_put_inode(inode);
+
+	end_get_page(page, 0);
+}
+
+static int ssdcache_get_page(int pool_id, struct cleancache_filekey key,
+				pgoff_t index, struct page *page,
+				void (*end_get_page)(struct page *page, int err))
+{
+	struct cache_fs *fs = cache_fs_array + pool_id;
+	struct cache_inode *inode;
+	struct io_slot *slot;
+	unsigned long ino;
+	sector_t sect;
+	unsigned long flags;
+	int err;
+
+	/* we don't support filehandle */
+	ino = key.u.ino;
+
+	inode = ssdcache_get_inode(fs, ino, false);
+	if (!inode)
+		return -EINVAL;
+
+	spin_lock_irqsave(&io_lock, flags);
+	slot = __ssdcache_find_io_slot(inode, index);
+	if (slot) {
+		/* AP -> P -> G case, second P is ignore, so G should be ignored */
+		if (slot->abort)
+			goto unlock_error;
+
+		/* AP -> G case */
+		copy_highpage(page, slot->page);
+		goto unlock_success;
+	}
+
+	slot = __ssdcache_get_io_slot(READ);
+	if (!slot)
+		goto unlock_error;
+
+	slot->inode = inode;
+	slot->index = index;
+	slot->page = page;
+
+	slot->end_io = ssdcache_get_page_endio;
+	slot->end_get_page = end_get_page;
+	slot->rw = READ;
+
+	__ssdcache_io_slot_add_hash(slot);
+	spin_unlock_irqrestore(&io_lock, flags);
+
+	/* II can't free cache now */
+	spin_lock_irqsave(&inode->pages_lock, flags);
+	sect = (sector_t)radix_tree_lookup(&inode->pages, index);
+	spin_unlock_irqrestore(&inode->pages_lock, flags);
+	if (sect == 0)
+		goto error_put_ioslot;
+
+	slot->sect = sect;
+
+	err = ssdcache_io_slot_submit(slot);
+	if (err)
+		goto error_put_ioslot;
+	return 0;
+
+unlock_success:
+	spin_unlock_irqrestore(&io_lock, flags);
+	ssdcache_put_inode(inode);
+	end_get_page(page, 0);
+	return 0;
+error_put_ioslot:
+	spin_lock_irqsave(&io_lock, flags);
+	/* II want to abort the cache */
+	if (slot->abort && sect) {
+		spin_unlock(&io_lock);
+		spin_lock(&inode->pages_lock);
+
+		radix_tree_delete(&inode->pages, slot->index);
+
+		spin_unlock_irqrestore(&inode->pages_lock, flags);
+
+		ssdcache_free_sector(sect);
+
+		spin_lock_irqsave(&io_lock, flags);
+	}
+	__ssdcache_put_io_slot(slot);
+unlock_error:
+	spin_unlock_irqrestore(&io_lock, flags);
+	ssdcache_put_inode(inode);
+	return -EINVAL;
+}
+
+static void ssdcache_prepare_reclaim_inode_page(struct cache_inode *inode)
+{
+	atomic_inc(&inode->refcnt);
+}
+
+static void __ssdcache_reclaim_inode_page(struct cache_inode *inode,
+	pgoff_t index, bool reclaim)
+{
+	struct io_slot *slot;
+	sector_t sect;
+	unsigned long flags;
+
+	spin_lock_irqsave(&io_lock, flags);
+	slot = __ssdcache_find_io_slot(inode, index);
+	if (slot) {
+		/* If reclaim, ignore it */
+		if (!reclaim) {
+			/* AP -> I case */
+			BUG_ON(slot->rw != WRITE);
+			slot->abort = 1;
+		}
+		spin_unlock_irqrestore(&io_lock, flags);
+		ssdcache_put_inode(inode);
+		return;
+	}
+	spin_unlock_irqrestore(&io_lock, flags);
+
+	spin_lock_irqsave(&inode->pages_lock, flags);
+	sect = (sector_t)radix_tree_delete(&inode->pages, index);
+	spin_unlock_irqrestore(&inode->pages_lock, flags);
+
+	if (sect != 0)
+		ssdcache_free_sector(sect);
+
+	ssdcache_put_inode(inode);
+}
+
+static void ssdcache_reclaim_inode_page(struct cache_inode *inode,
+	pgoff_t index)
+{
+	__ssdcache_reclaim_inode_page(inode, index, true);
+}
+
+static void ssdcache_invalidate_page(int pool_id, struct cleancache_filekey key,
+					pgoff_t index)
+{
+	struct cache_fs *fs = cache_fs_array + pool_id;
+	struct cache_inode *inode;
+	unsigned long ino;
+
+	/* we don't support filehandle */
+	ino = key.u.ino;
+
+	inode = ssdcache_get_inode(fs, ino, false);
+	if (!inode)
+		return;
+
+	__ssdcache_reclaim_inode_page(inode, index, false);
+}
+
+#define RADIX_BATCH 8
+static int ssdcache_lookup_inode_caches(struct cache_inode *inode, pgoff_t start,
+	pgoff_t *index, sector_t *sects, ssize_t size)
+{
+	struct radix_tree_iter iter;
+	ssize_t cnt = 0;
+	void **slot;
+
+	radix_tree_for_each_slot(slot, &inode->pages, &iter, start) {
+		sects[cnt] = (sector_t)radix_tree_deref_slot(slot);
+		if (sects[cnt] == 0)
+			continue;
+		index[cnt] = iter.index;
+		cnt++;
+		if (cnt >= size)
+			break;
+	}
+	return cnt;
+}
+
+static void ssdcache_invalidate_inode(int pool_id, struct cleancache_filekey key)
+{
+	struct cache_fs *fs = cache_fs_array + pool_id;
+	struct cache_inode *inode;
+	unsigned long ino;
+	struct io_slot *slot;
+	unsigned long flags;
+	pgoff_t index[RADIX_BATCH];
+	sector_t sects[RADIX_BATCH];
+	pgoff_t start;
+	int cnt, i;
+
+	/* we don't support filehandle */
+	ino = key.u.ino;
+
+	inode = ssdcache_get_inode(fs, ino, false);
+	if (!inode)
+		return;
+
+	spin_lock_irqsave(&cache_fs_lock, flags);
+	/* Guarantee the inode can't be found any more */
+	rb_erase(&inode->rb_node, &inode->fs->inodes);
+	spin_unlock_irqrestore(&cache_fs_lock, flags);
+
+	/* II could run when G/P is running. So G/P should always add slot first */
+	spin_lock_irqsave(&inode->pages_lock, flags);
+	/* Guarantee no new entry is added to radix tree */
+	inode->free = 1;
+	start = 0;
+
+again:
+	cnt = ssdcache_lookup_inode_caches(inode, start, index, sects, RADIX_BATCH);
+
+	for (i = 0; i < cnt; i++) {
+		start = index[i];
+
+		/*
+		 * slot abort could delete radix entry too, but the duplication
+		 * is not a problem
+		 */
+		radix_tree_delete(&inode->pages, index[i]);
+	}
+	start++;
+	spin_unlock_irqrestore(&inode->pages_lock, flags);
+
+	spin_lock_irqsave(&io_lock, flags);
+	for (i = 0; i < cnt; i++) {
+		slot = __ssdcache_find_io_slot(inode, index[i]);
+		/*
+		 * either read/write endio will remove this radix entry and
+		 * free the sectors. io_slot protects we don't free sector duplicated
+		 */
+		if (slot) {
+			slot->abort = 1;
+			sects[i] = 0;
+		}
+	}
+	spin_unlock_irqrestore(&io_lock, flags);
+
+	/*
+	 * G, P, I could run here, but we don't free sectors duplicated. If G,
+	 * P are running, there are slots existing, we skip free sectors. If I
+	 * is running, we always free radix tree first, so no duplication.
+	 */
+	for (i = 0; i < cnt; i++) {
+		if (sects[i])
+			ssdcache_free_sector(sects[i]);
+	}
+
+	if (cnt) {
+		spin_lock_irqsave(&inode->pages_lock, flags);
+		goto again;
+	}
+
+	ssdcache_put_inode(inode);
+	ssdcache_put_inode(inode);
+	/* The inode might still be not freed, after G/P finish, it will be freed */
+}
+
+static void ssdcache_invalidate_fs(int pool_id)
+{
+	struct cache_fs *fs = cache_fs_array + pool_id;
+	struct cache_inode *inode;
+	struct rb_node *node;
+	unsigned long flags;
+	struct cleancache_filekey key;
+
+	while (1) {
+		spin_lock_irqsave(&cache_fs_lock, flags);
+		node = rb_first(&fs->inodes);
+		if (node) {
+			/* Get inode number with lock hold */
+			inode = rb_entry(node, struct cache_inode, rb_node);
+			key.u.ino = inode->rb_index;
+		}
+		spin_unlock_irqrestore(&cache_fs_lock, flags);
+
+		if (node == NULL)
+			return;
+
+		ssdcache_invalidate_inode(pool_id, key);
+	}
+}
+
+static int ssdcache_init_fs(size_t pagesize)
+{
+	int i;
+
+	if (pagesize != PAGE_SIZE)
+		return -EINVAL;
+
+	if (cache_fs_nr >= MAX_INITIALIZABLE_FS)
+		return -EINVAL;
+	cache_fs_nr++;
+
+	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
+		if (!cache_fs_array[i].valid) {
+			cache_fs_array[i].inodes = RB_ROOT;
+
+			cache_fs_array[i].valid = true;
+			break;
+		}
+	}
+	return i;
+}
+
+static int ssdcache_init_shared_fs(char *uuid, size_t pagesize)
+{
+	/* shared pools are unsupported and map to private */
+	return ssdcache_init_fs(pagesize);
+}
+
+static struct cleancache_ops ssdcache_ops = {
+	.put_page = ssdcache_put_page,
+	.get_page = ssdcache_get_page,
+	.invalidate_page = ssdcache_invalidate_page,
+	.invalidate_inode = ssdcache_invalidate_inode,
+	.invalidate_fs = ssdcache_invalidate_fs,
+	.init_shared_fs = ssdcache_init_shared_fs,
+	.init_fs = ssdcache_init_fs
+};
+
+static void ssdcache_wakeup_worker(void)
+{
+	wake_up(&io_wait);
+}
+
+static int ssdcache_do_io(void *data)
+{
+	struct io_slot *slot;
+	DEFINE_WAIT(wait);
+	unsigned long flags;
+	LIST_HEAD(write_list);
+	struct blk_plug plug;
+
+	blk_start_plug(&plug);
+	while (!kthread_should_stop()) {
+		while (1) {
+			prepare_to_wait(&io_wait, &wait, TASK_INTERRUPTIBLE);
+
+			spin_lock_irqsave(&io_lock, flags);
+			__ssdcache_io_slot_peek_write(&write_list);
+			spin_unlock_irqrestore(&io_lock, flags);
+
+			if (!list_empty(&write_list) || kthread_should_stop())
+				break;
+			schedule();
+		}
+		finish_wait(&io_wait, &wait);
+
+		while (!list_empty(&write_list)) {
+			slot = list_first_entry(&write_list, struct io_slot,
+				link);
+			list_del_init(&slot->link);
+			ssdcache_do_put_page(slot);
+		}
+	}
+	blk_finish_plug(&plug);
+	return 0;
+}
+
+static int __init ssdcache_init(void)
+{
+	struct task_struct *tsk;
+
+	init_waitqueue_head(&io_wait);
+	tsk = kthread_run(ssdcache_do_io, NULL, "ssd_cleancache");
+	if (!tsk)
+		return -EINVAL;
+	if (ssdcache_io_init()) {
+		kthread_stop(tsk);
+		return -EINVAL;
+	}
+	cleancache_register_ops(&ssdcache_ops);
+	return 0;
+}
+
+module_init(ssdcache_init);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Shaohua Li <shli@kernel.org>");
+MODULE_DESCRIPTION("SSD backed cleancache backend");
Index: linux/mm/Kconfig
===================================================================
--- linux.orig/mm/Kconfig	2013-09-26 21:38:45.425119143 +0800
+++ linux/mm/Kconfig	2013-09-26 21:38:45.417119257 +0800
@@ -532,6 +532,13 @@ config ZSWAP
 	  they have not be fully explored on the large set of potential
 	  configurations and workloads that exist.
 
+config SSD_CLEANCACHE
+	depends on CLEANCACHE
+	tristate "Enable SSD backed cleancache backend"
+	default n
+	help
+	  A SSD backed cleancache backend
+
 config MEM_SOFT_DIRTY
 	bool "Track memory changes"
 	depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY
Index: linux/mm/Makefile
===================================================================
--- linux.orig/mm/Makefile	2013-09-26 21:38:45.425119143 +0800
+++ linux/mm/Makefile	2013-09-26 21:38:45.421119196 +0800
@@ -60,3 +60,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kme
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
 obj-$(CONFIG_ZBUD)	+= zbud.o
+obj-$(CONFIG_SSD_CLEANCACHE) += ssd-cleancache.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
