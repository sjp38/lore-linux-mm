Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3B36A6B01EF
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 08:16:31 -0400 (EDT)
Subject: Cleancache [PATCH 3/7] (was Transcendent Memory): VFS hooks
Reply-To: dan.magenheimer@oracle.com
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Message-Id: <E1O4vIn-0006ak-I1@ca-server1.us.oracle.com>
Date: Thu, 22 Apr 2010 05:14:41 -0700
Sender: owner-linux-mm@kvack.org
To: adilger@sun.com, akpm@linux-foundation.org, chris.mason@oracle.com, dave.mccracken@oracle.com, JBeulich@novell.com, jeremy@goop.org, joel.becker@oracle.com, kurt.hackel@oracle.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, matthew@wil.cx, mfasheh@suse.com, ngupta@vflare.org, npiggin@suse.de, ocfs2-devel@oss.oracle.com, riel@redhat.com, tytso@mit.edu, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

Cleancache [PATCH 3/7] (was Transcendent Memory): VFS hooks

Implement core hooks in VFS for: initializing cleancache
per filesystem; capturing clean pages evicted by page cache;
attempting to get pages from cleancache before filesystem
read; and ensuring coherency between pagecache, disk,
and cleancache.  All hooks become no-ops if CONFIG_CLEANCACHE
is unset, or become compare-pointer-to-NULL if
CONFIG_CLEANCACHE is set but no cleancache "backend" has
claimed cleancache_ops.

Signed-off-by: Chris Mason <chris.mason@oracle.com>
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 fs/buffer.c                              |    5 +++++
 fs/mpage.c                               |    7 +++++++
 fs/super.c                               |    8 ++++++++
 mm/filemap.c                             |   11 +++++++++++
 mm/truncate.c                            |   10 ++++++++++
 5 files changed, 41 insertions(+)

--- linux-2.6.34-rc5/fs/super.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-cleancache/fs/super.c	2010-04-21 10:06:39.000000000 -0600
@@ -37,6 +37,7 @@
 #include <linux/kobject.h>
 #include <linux/mutex.h>
 #include <linux/file.h>
+#include <linux/cleancache.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 
@@ -104,6 +105,7 @@ static struct super_block *alloc_super(s
 		s->s_qcop = sb_quotactl_ops;
 		s->s_op = &default_op;
 		s->s_time_gran = 1000000000;
+		s->cleancache_poolid = -1;
 	}
 out:
 	return s;
@@ -194,6 +196,11 @@ void deactivate_super(struct super_block
 		vfs_dq_off(s, 0);
 		down_write(&s->s_umount);
 		fs->kill_sb(s);
+		if (s->cleancache_poolid > 0) {
+			int cleancache_poolid = s->cleancache_poolid;
+			s->cleancache_poolid = -1; /* avoid races */
+			cleancache_flush_fs(cleancache_poolid);
+		}
 		put_filesystem(fs);
 		put_super(s);
 	}
@@ -220,6 +227,7 @@ void deactivate_locked_super(struct supe
 		spin_unlock(&sb_lock);
 		vfs_dq_off(s, 0);
 		fs->kill_sb(s);
+		cleancache_flush_fs(s->cleancache_poolid);
 		put_filesystem(fs);
 		put_super(s);
 	} else {
--- linux-2.6.34-rc5/fs/buffer.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-cleancache/fs/buffer.c	2010-04-21 10:06:39.000000000 -0600
@@ -41,6 +41,7 @@
 #include <linux/bitops.h>
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
+#include <linux/cleancache.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
 
@@ -276,6 +277,10 @@ void invalidate_bdev(struct block_device
 
 	invalidate_bh_lrus();
 	invalidate_mapping_pages(mapping, 0, -1);
+	/* 99% of the time, we don't need to flush the cleancache on the bdev.
+	 * But, for the strange corners, lets be cautious
+	 */
+	cleancache_flush_inode(mapping);
 }
 EXPORT_SYMBOL(invalidate_bdev);
 
--- linux-2.6.34-rc5/fs/mpage.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-cleancache/fs/mpage.c	2010-04-21 10:06:39.000000000 -0600
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
 
+	if (fully_mapped && blocks_per_page == 1 &&
+	    !PageUptodate(page) && cleancache_get_page(page) == 1) {
+		SetPageUptodate(page);
+		goto confused;
+	}
+
 	/*
 	 * This page will go to BIO.  Do we need to send this BIO off first?
 	 */
--- linux-2.6.34-rc5/mm/filemap.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-cleancache/mm/filemap.c	2010-04-21 10:06:39.000000000 -0600
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
--- linux-2.6.34-rc5/mm/truncate.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-cleancache/mm/truncate.c	2010-04-21 10:06:39.000000000 -0600
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
