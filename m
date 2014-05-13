Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id A00416B0070
	for <linux-mm@kvack.org>; Tue, 13 May 2014 05:46:17 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so208615eek.20
        for <linux-mm@kvack.org>; Tue, 13 May 2014 02:46:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r2si12685825eem.96.2014.05.13.02.46.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 02:46:16 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 18/19] mm: Non-atomically mark page accessed during page cache allocation where possible
Date: Tue, 13 May 2014 10:45:49 +0100
Message-Id: <1399974350-11089-19-git-send-email-mgorman@suse.de>
In-Reply-To: <1399974350-11089-1-git-send-email-mgorman@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

aops->write_begin may allocate a new page and make it visible only to
have mark_page_accessed called almost immediately after. Once the page is
visible the atomic operations are necessary which is noticable overhead when
writing to an in-memory filesystem like tmpfs but should also be noticable
with fast storage. The objective of the patch is to initialse the accessed
information with non-atomic operations before the page is visible.

The bulk of filesystems directly or indirectly use
grab_cache_page_write_begin or find_or_create_page for the initial allocation
of a page cache page. This patch adds an init_page_accessed() helper which
behaves like the first call to mark_page_accessed() but may called before
the page is visible and can be done non-atomically.

The primary APIs of concern in this care are the following and are used
by most filesystems.

	find_get_page
	find_lock_page
	find_or_create_page
	grab_cache_page_nowait
	grab_cache_page_write_begin

All of them are very similar in detail to the patch creates a core helper
pagecache_get_page() which takes a flags parameter that affects its behavior
such as whether the page should be marked accessed or not. Then old API
is preserved but is basically a thin wrapper around this core function.

Each of the filesystems are then updated to avoid calling mark_page_accessed
when it is known that the VM interfaces have already done the job.
There is a slight snag in that the timing of the mark_page_accessed() has
now changed so in rare cases it's possible a page gets to the end of the LRU
as PageReferenced where as previously it might have been repromoted. This
is expected to be rare but it's worth the filesystem people thinking about
it in case they see a problem with the timing change. It is also the case
that some filesystems may be marking pages accessed that previously did not
but it makes sense that filesystems have consistent behaviour in this regard.

The test case used to evaulate this is a simple dd of a large file done
multiple times with the file deleted on each iterations. The size of
the file is 1/10th physical memory to avoid dirty page balancing. In the
async case it will be possible that the workload completes without even
hitting the disk and will have variable results but highlight the impact
of mark_page_accessed for async IO. The sync results are expected to be
more stable. The exception is tmpfs where the normal case is for the "IO"
to not hit the disk.

The test machine was single socket and UMA to avoid any scheduling or
NUMA artifacts. Throughput and wall times are presented for sync IO, only
wall times are shown for async as the granularity reported by dd and the
variability is unsuitable for comparison. As async results were variable
do to writback timings, I'm only reporting the maximum figures. The sync
results were stable enough to make the mean and stddev uninteresting.

The performance results are reported based on a run with no profiling.
Profile data is based on a separate run with oprofile running.

async dd
                                    3.15.0-rc3            3.15.0-rc3
                                       vanilla           accessed-v2
ext3    Max      elapsed     13.9900 (  0.00%)     11.5900 ( 17.16%)
tmpfs	Max      elapsed      0.5100 (  0.00%)      0.4900 (  3.92%)
btrfs   Max      elapsed     12.8100 (  0.00%)     12.7800 (  0.23%)
ext4	Max      elapsed     18.6000 (  0.00%)     13.3400 ( 28.28%)
xfs	Max      elapsed     12.5600 (  0.00%)      2.0900 ( 83.36%)

The XFS figure is a bit as it managed to avoid a worst case by sheer luck
but the average figures looked reasonable.

        samples percentage
ext3       86107    0.9783  vmlinux-3.15.0-rc4-vanilla        mark_page_accessed
ext3       23833    0.2710  vmlinux-3.15.0-rc4-accessed-v3r25 mark_page_accessed
ext3        5036    0.0573  vmlinux-3.15.0-rc4-accessed-v3r25 init_page_accessed
ext4       64566    0.8961  vmlinux-3.15.0-rc4-vanilla        mark_page_accessed
ext4        5322    0.0713  vmlinux-3.15.0-rc4-accessed-v3r25 mark_page_accessed
ext4        2869    0.0384  vmlinux-3.15.0-rc4-accessed-v3r25 init_page_accessed
xfs        62126    1.7675  vmlinux-3.15.0-rc4-vanilla        mark_page_accessed
xfs         1904    0.0554  vmlinux-3.15.0-rc4-accessed-v3r25 init_page_accessed
xfs          103    0.0030  vmlinux-3.15.0-rc4-accessed-v3r25 mark_page_accessed
btrfs      10655    0.1338  vmlinux-3.15.0-rc4-vanilla        mark_page_accessed
btrfs       2020    0.0273  vmlinux-3.15.0-rc4-accessed-v3r25 init_page_accessed
btrfs        587    0.0079  vmlinux-3.15.0-rc4-accessed-v3r25 mark_page_accessed
tmpfs      59562    3.2628  vmlinux-3.15.0-rc4-vanilla        mark_page_accessed
tmpfs       1210    0.0696  vmlinux-3.15.0-rc4-accessed-v3r25 init_page_accessed
tmpfs         94    0.0054  vmlinux-3.15.0-rc4-accessed-v3r25 mark_page_accessed

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/btrfs/extent_io.c       |  11 +--
 fs/btrfs/file.c            |   5 +-
 fs/buffer.c                |   7 +-
 fs/ext4/mballoc.c          |  14 ++--
 fs/f2fs/checkpoint.c       |   3 -
 fs/f2fs/node.c             |   2 -
 fs/fuse/file.c             |   2 -
 fs/gfs2/aops.c             |   1 -
 fs/gfs2/meta_io.c          |   4 +-
 fs/ntfs/attrib.c           |   1 -
 fs/ntfs/file.c             |   1 -
 include/linux/page-flags.h |   1 +
 include/linux/pagemap.h    | 107 ++++++++++++++++++++++--
 include/linux/swap.h       |   1 +
 mm/filemap.c               | 202 +++++++++++++++++----------------------------
 mm/shmem.c                 |   6 +-
 mm/swap.c                  |  11 +++
 17 files changed, 217 insertions(+), 162 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 3955e47..158833c 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -4510,7 +4510,8 @@ static void check_buffer_tree_ref(struct extent_buffer *eb)
 	spin_unlock(&eb->refs_lock);
 }
 
-static void mark_extent_buffer_accessed(struct extent_buffer *eb)
+static void mark_extent_buffer_accessed(struct extent_buffer *eb,
+		struct page *accessed)
 {
 	unsigned long num_pages, i;
 
@@ -4519,7 +4520,8 @@ static void mark_extent_buffer_accessed(struct extent_buffer *eb)
 	num_pages = num_extent_pages(eb->start, eb->len);
 	for (i = 0; i < num_pages; i++) {
 		struct page *p = extent_buffer_page(eb, i);
-		mark_page_accessed(p);
+		if (p != accessed)
+			mark_page_accessed(p);
 	}
 }
 
@@ -4533,7 +4535,7 @@ struct extent_buffer *find_extent_buffer(struct btrfs_fs_info *fs_info,
 			       start >> PAGE_CACHE_SHIFT);
 	if (eb && atomic_inc_not_zero(&eb->refs)) {
 		rcu_read_unlock();
-		mark_extent_buffer_accessed(eb);
+		mark_extent_buffer_accessed(eb, NULL);
 		return eb;
 	}
 	rcu_read_unlock();
@@ -4581,7 +4583,7 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 				spin_unlock(&mapping->private_lock);
 				unlock_page(p);
 				page_cache_release(p);
-				mark_extent_buffer_accessed(exists);
+				mark_extent_buffer_accessed(exists, p);
 				goto free_eb;
 			}
 
@@ -4596,7 +4598,6 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 		attach_extent_buffer_page(eb, p);
 		spin_unlock(&mapping->private_lock);
 		WARN_ON(PageDirty(p));
-		mark_page_accessed(p);
 		eb->pages[i] = p;
 		if (!PageUptodate(p))
 			uptodate = 0;
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index ae6af07..74272a3 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -470,11 +470,12 @@ static void btrfs_drop_pages(struct page **pages, size_t num_pages)
 	for (i = 0; i < num_pages; i++) {
 		/* page checked is some magic around finding pages that
 		 * have been modified without going through btrfs_set_page_dirty
-		 * clear it here
+		 * clear it here. There should be no need to mark the pages
+		 * accessed as prepare_pages should have marked them accessed
+		 * in prepare_pages via find_or_create_page()
 		 */
 		ClearPageChecked(pages[i]);
 		unlock_page(pages[i]);
-		mark_page_accessed(pages[i]);
 		page_cache_release(pages[i]);
 	}
 }
diff --git a/fs/buffer.c b/fs/buffer.c
index e80012d..c541de0 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -227,7 +227,7 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
 	int all_mapped = 1;
 
 	index = block >> (PAGE_CACHE_SHIFT - bd_inode->i_blkbits);
-	page = find_get_page(bd_mapping, index);
+	page = find_get_page_flags(bd_mapping, index, FGP_ACCESSED);
 	if (!page)
 		goto out;
 
@@ -1366,12 +1366,13 @@ __find_get_block(struct block_device *bdev, sector_t block, unsigned size)
 	struct buffer_head *bh = lookup_bh_lru(bdev, block, size);
 
 	if (bh == NULL) {
+		/* __find_get_block_slow will mark the page accessed */
 		bh = __find_get_block_slow(bdev, block);
 		if (bh)
 			bh_lru_install(bh);
-	}
-	if (bh)
+	} else
 		touch_buffer(bh);
+
 	return bh;
 }
 EXPORT_SYMBOL(__find_get_block);
diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index c8238a2..afe8a13 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -1044,6 +1044,8 @@ int ext4_mb_init_group(struct super_block *sb, ext4_group_t group)
 	 * allocating. If we are looking at the buddy cache we would
 	 * have taken a reference using ext4_mb_load_buddy and that
 	 * would have pinned buddy page to page cache.
+	 * The call to ext4_mb_get_buddy_page_lock will mark the
+	 * page accessed.
 	 */
 	ret = ext4_mb_get_buddy_page_lock(sb, group, &e4b);
 	if (ret || !EXT4_MB_GRP_NEED_INIT(this_grp)) {
@@ -1062,7 +1064,6 @@ int ext4_mb_init_group(struct super_block *sb, ext4_group_t group)
 		ret = -EIO;
 		goto err;
 	}
-	mark_page_accessed(page);
 
 	if (e4b.bd_buddy_page == NULL) {
 		/*
@@ -1082,7 +1083,6 @@ int ext4_mb_init_group(struct super_block *sb, ext4_group_t group)
 		ret = -EIO;
 		goto err;
 	}
-	mark_page_accessed(page);
 err:
 	ext4_mb_put_buddy_page_lock(&e4b);
 	return ret;
@@ -1141,7 +1141,7 @@ ext4_mb_load_buddy(struct super_block *sb, ext4_group_t group,
 
 	/* we could use find_or_create_page(), but it locks page
 	 * what we'd like to avoid in fast path ... */
-	page = find_get_page(inode->i_mapping, pnum);
+	page = find_get_page_flags(inode->i_mapping, pnum, FGP_ACCESSED);
 	if (page == NULL || !PageUptodate(page)) {
 		if (page)
 			/*
@@ -1176,15 +1176,16 @@ ext4_mb_load_buddy(struct super_block *sb, ext4_group_t group,
 		ret = -EIO;
 		goto err;
 	}
+
+	/* Pages marked accessed already */
 	e4b->bd_bitmap_page = page;
 	e4b->bd_bitmap = page_address(page) + (poff * sb->s_blocksize);
-	mark_page_accessed(page);
 
 	block++;
 	pnum = block / blocks_per_page;
 	poff = block % blocks_per_page;
 
-	page = find_get_page(inode->i_mapping, pnum);
+	page = find_get_page_flags(inode->i_mapping, pnum, FGP_ACCESSED);
 	if (page == NULL || !PageUptodate(page)) {
 		if (page)
 			page_cache_release(page);
@@ -1209,9 +1210,10 @@ ext4_mb_load_buddy(struct super_block *sb, ext4_group_t group,
 		ret = -EIO;
 		goto err;
 	}
+
+	/* Pages marked accessed already */
 	e4b->bd_buddy_page = page;
 	e4b->bd_buddy = page_address(page) + (poff * sb->s_blocksize);
-	mark_page_accessed(page);
 
 	BUG_ON(e4b->bd_bitmap_page == NULL);
 	BUG_ON(e4b->bd_buddy_page == NULL);
diff --git a/fs/f2fs/checkpoint.c b/fs/f2fs/checkpoint.c
index 4aa521a..c405b8f 100644
--- a/fs/f2fs/checkpoint.c
+++ b/fs/f2fs/checkpoint.c
@@ -69,7 +69,6 @@ repeat:
 		goto repeat;
 	}
 out:
-	mark_page_accessed(page);
 	return page;
 }
 
@@ -137,13 +136,11 @@ int ra_meta_pages(struct f2fs_sb_info *sbi, int start, int nrpages, int type)
 		if (!page)
 			continue;
 		if (PageUptodate(page)) {
-			mark_page_accessed(page);
 			f2fs_put_page(page, 1);
 			continue;
 		}
 
 		f2fs_submit_page_mbio(sbi, page, blk_addr, &fio);
-		mark_page_accessed(page);
 		f2fs_put_page(page, 0);
 	}
 out:
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index a161e95..57caa6e 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -967,7 +967,6 @@ repeat:
 		goto repeat;
 	}
 got_it:
-	mark_page_accessed(page);
 	return page;
 }
 
@@ -1022,7 +1021,6 @@ page_hit:
 		f2fs_put_page(page, 1);
 		return ERR_PTR(-EIO);
 	}
-	mark_page_accessed(page);
 	return page;
 }
 
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 13f8bde..85a3359 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1089,8 +1089,6 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 		tmp = iov_iter_copy_from_user_atomic(page, ii, offset, bytes);
 		flush_dcache_page(page);
 
-		mark_page_accessed(page);
-
 		if (!tmp) {
 			unlock_page(page);
 			page_cache_release(page);
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index ce62dca..3c1ab7b 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -577,7 +577,6 @@ int gfs2_internal_read(struct gfs2_inode *ip, char *buf, loff_t *pos,
 		p = kmap_atomic(page);
 		memcpy(buf + copied, p + offset, amt);
 		kunmap_atomic(p);
-		mark_page_accessed(page);
 		page_cache_release(page);
 		copied += amt;
 		index++;
diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
index 2cf09b6..b984a6e 100644
--- a/fs/gfs2/meta_io.c
+++ b/fs/gfs2/meta_io.c
@@ -136,7 +136,8 @@ struct buffer_head *gfs2_getbuf(struct gfs2_glock *gl, u64 blkno, int create)
 			yield();
 		}
 	} else {
-		page = find_lock_page(mapping, index);
+		page = find_get_page_flags(mapping, index,
+						FGP_LOCK|FGP_ACCESSED);
 		if (!page)
 			return NULL;
 	}
@@ -153,7 +154,6 @@ struct buffer_head *gfs2_getbuf(struct gfs2_glock *gl, u64 blkno, int create)
 		map_bh(bh, sdp->sd_vfs, blkno);
 
 	unlock_page(page);
-	mark_page_accessed(page);
 	page_cache_release(page);
 
 	return bh;
diff --git a/fs/ntfs/attrib.c b/fs/ntfs/attrib.c
index a27e3fe..250ed5b 100644
--- a/fs/ntfs/attrib.c
+++ b/fs/ntfs/attrib.c
@@ -1748,7 +1748,6 @@ int ntfs_attr_make_non_resident(ntfs_inode *ni, const u32 data_size)
 	if (page) {
 		set_page_dirty(page);
 		unlock_page(page);
-		mark_page_accessed(page);
 		page_cache_release(page);
 	}
 	ntfs_debug("Done.");
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index db9bd8a..86ddab9 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -2060,7 +2060,6 @@ static ssize_t ntfs_file_buffered_write(struct kiocb *iocb,
 		}
 		do {
 			unlock_page(pages[--do_pages]);
-			mark_page_accessed(pages[do_pages]);
 			page_cache_release(pages[do_pages]);
 		} while (do_pages);
 		if (unlikely(status))
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 4d4b39a..2093eb7 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -198,6 +198,7 @@ struct page;	/* forward declaration */
 TESTPAGEFLAG(Locked, locked)
 PAGEFLAG(Error, error) TESTCLEARFLAG(Error, error)
 PAGEFLAG(Referenced, referenced) TESTCLEARFLAG(Referenced, referenced)
+	__SETPAGEFLAG(Referenced, referenced)
 PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
 PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
 PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 9175f52..e5ffaa0 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -259,12 +259,109 @@ pgoff_t page_cache_next_hole(struct address_space *mapping,
 pgoff_t page_cache_prev_hole(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan);
 
+#define FGP_ACCESSED		0x00000001
+#define FGP_LOCK		0x00000002
+#define FGP_CREAT		0x00000004
+#define FGP_WRITE		0x00000008
+#define FGP_NOFS		0x00000010
+#define FGP_NOWAIT		0x00000020
+
+struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
+		int fgp_flags, gfp_t cache_gfp_mask, gfp_t radix_gfp_mask);
+
+/**
+ * find_get_page - find and get a page reference
+ * @mapping: the address_space to search
+ * @offset: the page index
+ *
+ * Looks up the page cache slot at @mapping & @offset.  If there is a
+ * page cache page, it is returned with an increased refcount.
+ *
+ * Otherwise, %NULL is returned.
+ */
+static inline struct page *find_get_page(struct address_space *mapping,
+					pgoff_t offset)
+{
+	return pagecache_get_page(mapping, offset, 0, 0, 0);
+}
+
+static inline struct page *find_get_page_flags(struct address_space *mapping,
+					pgoff_t offset, int fgp_flags)
+{
+	return pagecache_get_page(mapping, offset, fgp_flags, 0, 0);
+}
+
+/**
+ * find_lock_page - locate, pin and lock a pagecache page
+ * pagecache_get_page - find and get a page reference
+ * @mapping: the address_space to search
+ * @offset: the page index
+ *
+ * Looks up the page cache slot at @mapping & @offset.  If there is a
+ * page cache page, it is returned locked and with an increased
+ * refcount.
+ *
+ * Otherwise, %NULL is returned.
+ *
+ * find_lock_page() may sleep.
+ */
+static inline struct page *find_lock_page(struct address_space *mapping,
+					pgoff_t offset)
+{
+	return pagecache_get_page(mapping, offset, FGP_LOCK, 0, 0);
+}
+
+/**
+ * find_or_create_page - locate or add a pagecache page
+ * @mapping: the page's address_space
+ * @index: the page's index into the mapping
+ * @gfp_mask: page allocation mode
+ *
+ * Looks up the page cache slot at @mapping & @offset.  If there is a
+ * page cache page, it is returned locked and with an increased
+ * refcount.
+ *
+ * If the page is not present, a new page is allocated using @gfp_mask
+ * and added to the page cache and the VM's LRU list.  The page is
+ * returned locked and with an increased refcount.
+ *
+ * On memory exhaustion, %NULL is returned.
+ *
+ * find_or_create_page() may sleep, even if @gfp_flags specifies an
+ * atomic allocation!
+ */
+static inline struct page *find_or_create_page(struct address_space *mapping,
+					pgoff_t offset, gfp_t gfp_mask)
+{
+	return pagecache_get_page(mapping, offset,
+					FGP_LOCK|FGP_ACCESSED|FGP_CREAT,
+					gfp_mask, gfp_mask & GFP_RECLAIM_MASK);
+}
+
+/**
+ * grab_cache_page_nowait - returns locked page at given index in given cache
+ * @mapping: target address_space
+ * @index: the page index
+ *
+ * Same as grab_cache_page(), but do not wait if the page is unavailable.
+ * This is intended for speculative data generators, where the data can
+ * be regenerated if the page couldn't be grabbed.  This routine should
+ * be safe to call while holding the lock for another page.
+ *
+ * Clear __GFP_FS when allocating the page to avoid recursion into the fs
+ * and deadlock against the caller's locked page.
+ */
+static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
+				pgoff_t index)
+{
+	return pagecache_get_page(mapping, index,
+			FGP_LOCK|FGP_CREAT|FGP_NOFS|FGP_NOWAIT,
+			mapping_gfp_mask(mapping),
+			GFP_NOFS);
+}
+
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
-struct page *find_get_page(struct address_space *mapping, pgoff_t offset);
 struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
-struct page *find_lock_page(struct address_space *mapping, pgoff_t offset);
-struct page *find_or_create_page(struct address_space *mapping, pgoff_t index,
-				 gfp_t gfp_mask);
 unsigned find_get_entries(struct address_space *mapping, pgoff_t start,
 			  unsigned int nr_entries, struct page **entries,
 			  pgoff_t *indices);
@@ -287,8 +384,6 @@ static inline struct page *grab_cache_page(struct address_space *mapping,
 	return find_or_create_page(mapping, index, mapping_gfp_mask(mapping));
 }
 
-extern struct page * grab_cache_page_nowait(struct address_space *mapping,
-				pgoff_t index);
 extern struct page * read_cache_page(struct address_space *mapping,
 				pgoff_t index, filler_t *filler, void *data);
 extern struct page * read_cache_page_gfp(struct address_space *mapping,
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 395dcab..b570ad5 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -314,6 +314,7 @@ extern void lru_add_page_tail(struct page *page, struct page *page_tail,
 			 struct lruvec *lruvec, struct list_head *head);
 extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
+extern void init_page_accessed(struct page *page);
 extern void lru_add_drain(void);
 extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
diff --git a/mm/filemap.c b/mm/filemap.c
index 5020b28..c60ed0f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -955,26 +955,6 @@ out:
 EXPORT_SYMBOL(find_get_entry);
 
 /**
- * find_get_page - find and get a page reference
- * @mapping: the address_space to search
- * @offset: the page index
- *
- * Looks up the page cache slot at @mapping & @offset.  If there is a
- * page cache page, it is returned with an increased refcount.
- *
- * Otherwise, %NULL is returned.
- */
-struct page *find_get_page(struct address_space *mapping, pgoff_t offset)
-{
-	struct page *page = find_get_entry(mapping, offset);
-
-	if (radix_tree_exceptional_entry(page))
-		page = NULL;
-	return page;
-}
-EXPORT_SYMBOL(find_get_page);
-
-/**
  * find_lock_entry - locate, pin and lock a page cache entry
  * @mapping: the address_space to search
  * @offset: the page cache index
@@ -1011,66 +991,84 @@ repeat:
 EXPORT_SYMBOL(find_lock_entry);
 
 /**
- * find_lock_page - locate, pin and lock a pagecache page
+ * pagecache_get_page - find and get a page reference
  * @mapping: the address_space to search
  * @offset: the page index
+ * @fgp_flags: PCG flags
+ * @gfp_mask: gfp mask to use if a page is to be allocated
  *
- * Looks up the page cache slot at @mapping & @offset.  If there is a
- * page cache page, it is returned locked and with an increased
- * refcount.
- *
- * Otherwise, %NULL is returned.
- *
- * find_lock_page() may sleep.
- */
-struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
-{
-	struct page *page = find_lock_entry(mapping, offset);
-
-	if (radix_tree_exceptional_entry(page))
-		page = NULL;
-	return page;
-}
-EXPORT_SYMBOL(find_lock_page);
-
-/**
- * find_or_create_page - locate or add a pagecache page
- * @mapping: the page's address_space
- * @index: the page's index into the mapping
- * @gfp_mask: page allocation mode
+ * Looks up the page cache slot at @mapping & @offset.
  *
- * Looks up the page cache slot at @mapping & @offset.  If there is a
- * page cache page, it is returned locked and with an increased
- * refcount.
+ * PCG flags modify how the page is returned
  *
- * If the page is not present, a new page is allocated using @gfp_mask
- * and added to the page cache and the VM's LRU list.  The page is
- * returned locked and with an increased refcount.
+ * FGP_ACCESSED: the page will be marked accessed
+ * FGP_LOCK: Page is return locked
+ * FGP_CREAT: If page is not present then a new page is allocated using
+ *		@gfp_mask and added to the page cache and the VM's LRU
+ *		list. The page is returned locked and with an increased
+ *		refcount. Otherwise, %NULL is returned.
  *
- * On memory exhaustion, %NULL is returned.
+ * If FGP_LOCK or FGP_CREAT are specified then the function may sleep even
+ * if the GFP flags specified for FGP_CREAT are atomic.
  *
- * find_or_create_page() may sleep, even if @gfp_flags specifies an
- * atomic allocation!
+ * If there is a page cache page, it is returned with an increased refcount.
  */
-struct page *find_or_create_page(struct address_space *mapping,
-		pgoff_t index, gfp_t gfp_mask)
+struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
+	int fgp_flags, gfp_t cache_gfp_mask, gfp_t radix_gfp_mask)
 {
 	struct page *page;
-	int err;
+
 repeat:
-	page = find_lock_page(mapping, index);
-	if (!page) {
-		page = __page_cache_alloc(gfp_mask);
+	page = find_get_entry(mapping, offset);
+	if (radix_tree_exceptional_entry(page))
+		page = NULL;
+	if (!page)
+		goto no_page;
+
+	if (fgp_flags & FGP_LOCK) {
+		if (fgp_flags & FGP_NOWAIT) {
+			if (!trylock_page(page)) {
+				page_cache_release(page);
+				return NULL;
+			}
+		} else {
+			lock_page(page);
+		}
+
+		/* Has the page been truncated? */
+		if (unlikely(page->mapping != mapping)) {
+			unlock_page(page);
+			page_cache_release(page);
+			goto repeat;
+		}
+		VM_BUG_ON_PAGE(page->index != offset, page);
+	}
+
+	if (page && (fgp_flags & FGP_ACCESSED))
+		mark_page_accessed(page);
+
+no_page:
+	if (!page && (fgp_flags & FGP_CREAT)) {
+		int err;
+		if ((fgp_flags & FGP_WRITE) && mapping_cap_account_dirty(mapping))
+			cache_gfp_mask |= __GFP_WRITE;
+		if (fgp_flags & FGP_NOFS) {
+			cache_gfp_mask &= ~__GFP_FS;
+			radix_gfp_mask &= ~__GFP_FS;
+		}
+
+		page = __page_cache_alloc(cache_gfp_mask);
 		if (!page)
 			return NULL;
-		/*
-		 * We want a regular kernel memory (not highmem or DMA etc)
-		 * allocation for the radix tree nodes, but we need to honour
-		 * the context-specific requirements the caller has asked for.
-		 * GFP_RECLAIM_MASK collects those requirements.
-		 */
-		err = add_to_page_cache_lru(page, mapping, index,
-			(gfp_mask & GFP_RECLAIM_MASK));
+
+		if (WARN_ON_ONCE(!(fgp_flags & FGP_LOCK)))
+			fgp_flags |= FGP_LOCK;
+
+		/* Init accessed so avoit atomic mark_page_accessed later */
+		if (fgp_flags & FGP_ACCESSED)
+			init_page_accessed(page);
+
+		err = add_to_page_cache_lru(page, mapping, offset, radix_gfp_mask);
 		if (unlikely(err)) {
 			page_cache_release(page);
 			page = NULL;
@@ -1078,9 +1076,10 @@ repeat:
 				goto repeat;
 		}
 	}
+
 	return page;
 }
-EXPORT_SYMBOL(find_or_create_page);
+EXPORT_SYMBOL(pagecache_get_page);
 
 /**
  * find_get_entries - gang pagecache lookup
@@ -1370,39 +1369,6 @@ repeat:
 }
 EXPORT_SYMBOL(find_get_pages_tag);
 
-/**
- * grab_cache_page_nowait - returns locked page at given index in given cache
- * @mapping: target address_space
- * @index: the page index
- *
- * Same as grab_cache_page(), but do not wait if the page is unavailable.
- * This is intended for speculative data generators, where the data can
- * be regenerated if the page couldn't be grabbed.  This routine should
- * be safe to call while holding the lock for another page.
- *
- * Clear __GFP_FS when allocating the page to avoid recursion into the fs
- * and deadlock against the caller's locked page.
- */
-struct page *
-grab_cache_page_nowait(struct address_space *mapping, pgoff_t index)
-{
-	struct page *page = find_get_page(mapping, index);
-
-	if (page) {
-		if (trylock_page(page))
-			return page;
-		page_cache_release(page);
-		return NULL;
-	}
-	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS);
-	if (page && add_to_page_cache_lru(page, mapping, index, GFP_NOFS)) {
-		page_cache_release(page);
-		page = NULL;
-	}
-	return page;
-}
-EXPORT_SYMBOL(grab_cache_page_nowait);
-
 /*
  * CD/DVDs are error prone. When a medium error occurs, the driver may fail
  * a _large_ part of the i/o request. Imagine the worst scenario:
@@ -2372,7 +2338,6 @@ int pagecache_write_end(struct file *file, struct address_space *mapping,
 {
 	const struct address_space_operations *aops = mapping->a_ops;
 
-	mark_page_accessed(page);
 	return aops->write_end(file, mapping, pos, len, copied, page, fsdata);
 }
 EXPORT_SYMBOL(pagecache_write_end);
@@ -2454,34 +2419,18 @@ EXPORT_SYMBOL(generic_file_direct_write);
 struct page *grab_cache_page_write_begin(struct address_space *mapping,
 					pgoff_t index, unsigned flags)
 {
-	int status;
-	gfp_t gfp_mask;
 	struct page *page;
-	gfp_t gfp_notmask = 0;
+	int fgp_flags = FGP_LOCK|FGP_ACCESSED|FGP_WRITE|FGP_CREAT;
 
-	gfp_mask = mapping_gfp_mask(mapping);
-	if (mapping_cap_account_dirty(mapping))
-		gfp_mask |= __GFP_WRITE;
 	if (flags & AOP_FLAG_NOFS)
-		gfp_notmask = __GFP_FS;
-repeat:
-	page = find_lock_page(mapping, index);
+		fgp_flags |= FGP_NOFS;
+
+	page = pagecache_get_page(mapping, index, fgp_flags,
+			mapping_gfp_mask(mapping),
+			GFP_KERNEL);
 	if (page)
-		goto found;
+		wait_for_stable_page(page);
 
-	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
-	if (!page)
-		return NULL;
-	status = add_to_page_cache_lru(page, mapping, index,
-						GFP_KERNEL & ~gfp_notmask);
-	if (unlikely(status)) {
-		page_cache_release(page);
-		if (status == -EEXIST)
-			goto repeat;
-		return NULL;
-	}
-found:
-	wait_for_stable_page(page);
 	return page;
 }
 EXPORT_SYMBOL(grab_cache_page_write_begin);
@@ -2530,7 +2479,7 @@ again:
 
 		status = a_ops->write_begin(file, mapping, pos, bytes, flags,
 						&page, &fsdata);
-		if (unlikely(status))
+		if (unlikely(status < 0))
 			break;
 
 		if (mapping_writably_mapped(mapping))
@@ -2539,7 +2488,6 @@ again:
 		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
 		flush_dcache_page(page);
 
-		mark_page_accessed(page);
 		status = a_ops->write_end(file, mapping, pos, bytes, copied,
 						page, fsdata);
 		if (unlikely(status < 0))
diff --git a/mm/shmem.c b/mm/shmem.c
index f47fb38..700a4ad 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1372,9 +1372,13 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata)
 {
+	int ret;
 	struct inode *inode = mapping->host;
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	return shmem_getpage(inode, index, pagep, SGP_WRITE, NULL);
+	ret = shmem_getpage(inode, index, pagep, SGP_WRITE, NULL);
+	if (*pagep)
+		init_page_accessed(*pagep);
+	return ret;
 }
 
 static int
diff --git a/mm/swap.c b/mm/swap.c
index 7a5bdd7..77baa36 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -583,6 +583,17 @@ void mark_page_accessed(struct page *page)
 EXPORT_SYMBOL(mark_page_accessed);
 
 /*
+ * Used to mark_page_accessed(page) that is not visible yet and when it is
+ * still safe to use non-atomic ops
+ */
+void init_page_accessed(struct page *page)
+{
+	if (!PageReferenced(page))
+		__SetPageReferenced(page);
+}
+EXPORT_SYMBOL(init_page_accessed);
+
+/*
  * Queue the page for addition to the LRU via pagevec. The decision on whether
  * to add the page to the [in]active [file|anon] list is deferred until the
  * pagevec is drained. This gives a chance for the caller of __lru_cache_add()
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
