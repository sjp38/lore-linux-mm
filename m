Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 82F976B01C3
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 19:21:20 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:20:10 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V3 4/8] Cleancache: VFS hooks for cleancache
Message-ID: <20100621232010.GA19527@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com
List-ID: <linux-mm.kvack.org>

[PATCH V3 4/8] Cleancache: VFS hooks for cleancache

Implement core hooks in VFS for: initializing cleancache
per filesystem; capturing clean pages evicted by page cache;
attempting to get pages from cleancache before filesystem
read; and ensuring coherency between pagecache, disk,
and cleancache.  All hooks become no-ops if CONFIG_CLEANCACHE
is unset, or become compare-function-pointer-to-NULL if
CONFIG_CLEANCACHE is set but no cleancache "backend" has
claimed cleancache_ops.

Signed-off-by: Chris Mason <chris.mason@oracle.com>
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 fs/buffer.c                              |    5 +++++
 fs/mpage.c                               |    7 +++++++
 fs/super.c                               |    7 +++++++
 mm/filemap.c                             |   11 +++++++++++
 mm/truncate.c                            |   10 ++++++++++
 5 files changed, 40 insertions(+)

--- linux-2.6.35-rc2/fs/super.c	2010-06-05 21:43:24.000000000 -0600
+++ linux-2.6.35-rc2-cleancache/fs/super.c	2010-06-11 09:06:41.000000000 -0600
@@ -30,6 +30,7 @@
 #include <linux/idr.h>
 #include <linux/mutex.h>
 #include <linux/backing-dev.h>
+#include <linux/cleancache.h>
 #include "internal.h"
 
 
@@ -95,6 +96,7 @@ static struct super_block *alloc_super(s
 		s->s_maxbytes = MAX_NON_LFS;
 		s->s_op = &default_op;
 		s->s_time_gran = 1000000000;
+		s->cleancache_poolid = -1;
 	}
 out:
 	return s;
@@ -158,6 +160,11 @@ void deactivate_locked_super(struct supe
 	struct file_system_type *fs = s->s_type;
 	if (atomic_dec_and_test(&s->s_active)) {
 		fs->kill_sb(s);
+		if (s->cleancache_poolid >= 0) {
+			int cleancache_poolid = s->cleancache_poolid;
+			s->cleancache_poolid = -1; /* avoid races */
+			cleancache_flush_fs(cleancache_poolid);
+		}
 		put_filesystem(fs);
 		put_super(s);
 	} else {
--- linux-2.6.35-rc2/fs/buffer.c	2010-06-05 21:43:24.000000000 -0600
+++ linux-2.6.35-rc2-cleancache/fs/buffer.c	2010-06-11 09:01:37.000000000 -0600
@@ -41,6 +41,7 @@
 #include <linux/bitops.h>
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
+#include <linux/cleancache.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
 
@@ -277,6 +278,10 @@ void invalidate_bdev(struct block_device
 	invalidate_bh_lrus();
 	lru_add_drain_all();	/* make sure all lru add caches are flushed */
 	invalidate_mapping_pages(mapping, 0, -1);
+	/* 99% of the time, we don't need to flush the cleancache on the bdev.
+	 * But, for the strange corners, lets be cautious
+	 */
+	cleancache_flush_inode(mapping);
 }
 EXPORT_SYMBOL(invalidate_bdev);
 
--- linux-2.6.35-rc2/fs/mpage.c	2010-06-05 21:43:24.000000000 -0600
+++ linux-2.6.35-rc2-cleancache/fs/mpage.c	2010-06-11 10:29:15.000000000 -0600
@@ -27,6 +27,7 @@
 #include <linux/writeback.h>
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
+#include <linux/cleancache.h>
 
 /*
  * I/O completion handler for multipage BIOs.
@@ -286,6 +287,12 @@ do_mpage_readpage(struct bio *bio, struc
 		SetPageMappedToDisk(page);
 	}
 
+	if (fully_mapped && blocks_per_page == 1 && !PageUptodate(page) &&
+	    cleancache_get_page(page) == 0) {
+		SetPageUptodate(page);
+		goto confused;
+	}
+
 	/*
 	 * This page will go to BIO.  Do we need to send this BIO off first?
 	 */
--- linux-2.6.35-rc2/mm/filemap.c	2010-06-05 21:43:24.000000000 -0600
+++ linux-2.6.35-rc2-cleancache/mm/filemap.c	2010-06-11 09:01:37.000000000 -0600
@@ -34,6 +34,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
+#include <linux/cleancache.h>
 #include "internal.h"
 
 /*
@@ -119,6 +120,16 @@ void __remove_from_page_cache(struct pag
 {
 	struct address_space *mapping = page->mapping;
 
+	/*
+	 * if we're uptodate, flush out into the cleancache, otherwise
+	 * invalidate any existing cleancache entries.  We can't leave
+	 * stale data around in the cleancache once our page is gone
+	 */
+	if (PageUptodate(page))
+		cleancache_put_page(page);
+	else
+		cleancache_flush_page(mapping, page);
+
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
--- linux-2.6.35-rc2/mm/truncate.c	2010-06-05 21:43:24.000000000 -0600
+++ linux-2.6.35-rc2-cleancache/mm/truncate.c	2010-06-11 09:01:37.000000000 -0600
@@ -19,6 +19,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
+#include <linux/cleancache.h>
 #include "internal.h"
 
 
@@ -51,6 +52,7 @@ void do_invalidatepage(struct page *page
 static inline void truncate_partial_page(struct page *page, unsigned partial)
 {
 	zero_user_segment(page, partial, PAGE_CACHE_SIZE);
+	cleancache_flush_page(page->mapping, page);
 	if (page_has_private(page))
 		do_invalidatepage(page, partial);
 }
@@ -108,6 +110,10 @@ truncate_complete_page(struct address_sp
 	clear_page_mlock(page);
 	remove_from_page_cache(page);
 	ClearPageMappedToDisk(page);
+	/* this must be after the remove_from_page_cache which
+	 * calls cleancache_put_page (and note page->mapping is now NULL)
+	 */
+	cleancache_flush_page(mapping, page);
 	page_cache_release(page);	/* pagecache ref */
 	return 0;
 }
@@ -215,6 +221,7 @@ void truncate_inode_pages_range(struct a
 	pgoff_t next;
 	int i;
 
+	cleancache_flush_inode(mapping);
 	if (mapping->nrpages == 0)
 		return;
 
@@ -290,6 +297,7 @@ void truncate_inode_pages_range(struct a
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 	}
+	cleancache_flush_inode(mapping);
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
 
@@ -428,6 +436,7 @@ int invalidate_inode_pages2_range(struct
 	int did_range_unmap = 0;
 	int wrapped = 0;
 
+	cleancache_flush_inode(mapping);
 	pagevec_init(&pvec, 0);
 	next = start;
 	while (next <= end && !wrapped &&
@@ -486,6 +495,7 @@ int invalidate_inode_pages2_range(struct
 		mem_cgroup_uncharge_end();
 		cond_resched();
 	}
+	cleancache_flush_inode(mapping);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(invalidate_inode_pages2_range);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
