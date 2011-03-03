Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 82E638D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:21:01 -0500 (EST)
Message-Id: <20110303074949.287801184@intel.com>
Date: Thu, 03 Mar 2011 14:45:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 05/27] btrfs: avoid duplicate balance_dirty_pages_ratelimited() calls
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=btrfs-fix-balance-size.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

When doing 1KB sequential writes to the same page,
balance_dirty_pages_ratelimited() should be called once instead of 4
times. Failing to do so will make all tasks throttled much too heavy.

CC: Chris Mason <chris.mason@oracle.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/btrfs/file.c       |   11 +++++++----
 fs/btrfs/ioctl.c      |    6 ++++--
 fs/btrfs/relocation.c |    6 ++++--
 3 files changed, 15 insertions(+), 8 deletions(-)

--- linux-next.orig/fs/btrfs/file.c	2011-02-21 14:24:56.000000000 +0800
+++ linux-next/fs/btrfs/file.c	2011-02-21 14:37:34.000000000 +0800
@@ -770,7 +770,8 @@ out:
 static noinline int prepare_pages(struct btrfs_root *root, struct file *file,
 			 struct page **pages, size_t num_pages,
 			 loff_t pos, unsigned long first_index,
-			 unsigned long last_index, size_t write_bytes)
+			 unsigned long last_index, size_t write_bytes,
+			 int *nr_dirtied)
 {
 	struct extent_state *cached_state = NULL;
 	int i;
@@ -837,7 +838,8 @@ again:
 				     GFP_NOFS);
 	}
 	for (i = 0; i < num_pages; i++) {
-		clear_page_dirty_for_io(pages[i]);
+		if (!clear_page_dirty_for_io(pages[i]))
+			(*nr_dirtied)++;
 		set_page_extent_mapped(pages[i]);
 		WARN_ON(!PageLocked(pages[i]));
 	}
@@ -989,6 +991,7 @@ static ssize_t btrfs_file_aio_write(stru
 	}
 
 	while (iov_iter_count(&i) > 0) {
+		int nr_dirtied = 0;
 		size_t offset = pos & (PAGE_CACHE_SIZE - 1);
 		size_t write_bytes = min(iov_iter_count(&i),
 					 nrptrs * (size_t)PAGE_CACHE_SIZE -
@@ -1015,7 +1018,7 @@ static ssize_t btrfs_file_aio_write(stru
 
 		ret = prepare_pages(root, file, pages, num_pages,
 				    pos, first_index, last_index,
-				    write_bytes);
+				    write_bytes, &nr_dirtied);
 		if (ret) {
 			btrfs_delalloc_release_space(inode,
 					num_pages << PAGE_CACHE_SHIFT);
@@ -1050,7 +1053,7 @@ static ssize_t btrfs_file_aio_write(stru
 			} else {
 				balance_dirty_pages_ratelimited_nr(
 							inode->i_mapping,
-							dirty_pages);
+							nr_dirtied);
 				if (dirty_pages <
 				(root->leafsize >> PAGE_CACHE_SHIFT) + 1)
 					btrfs_btree_balance_dirty(root, 1);
--- linux-next.orig/fs/btrfs/ioctl.c	2011-02-21 14:24:56.000000000 +0800
+++ linux-next/fs/btrfs/ioctl.c	2011-02-21 14:26:21.000000000 +0800
@@ -654,6 +654,7 @@ static int btrfs_defrag_file(struct file
 	u64 skip = 0;
 	u64 defrag_end = 0;
 	unsigned long i;
+	int dirtied;
 	int ret;
 	int compress_type = BTRFS_COMPRESS_ZLIB;
 
@@ -766,7 +767,7 @@ again:
 
 		btrfs_set_extent_delalloc(inode, page_start, page_end, NULL);
 		ClearPageChecked(page);
-		set_page_dirty(page);
+		dirtied = set_page_dirty(page);
 		unlock_extent(io_tree, page_start, page_end, GFP_NOFS);
 
 loop_unlock:
@@ -774,7 +775,8 @@ loop_unlock:
 		page_cache_release(page);
 		mutex_unlock(&inode->i_mutex);
 
-		balance_dirty_pages_ratelimited_nr(inode->i_mapping, 1);
+		if (dirtied)
+			balance_dirty_pages_ratelimited_nr(inode->i_mapping, 1);
 		i++;
 	}
 
--- linux-next.orig/fs/btrfs/relocation.c	2011-02-21 14:24:56.000000000 +0800
+++ linux-next/fs/btrfs/relocation.c	2011-02-21 14:26:21.000000000 +0800
@@ -2902,6 +2902,7 @@ static int relocate_file_extent_cluster(
 	struct file_ra_state *ra;
 	int nr = 0;
 	int ret = 0;
+	int dirtied;
 
 	if (!cluster->nr)
 		return 0;
@@ -2978,7 +2979,7 @@ static int relocate_file_extent_cluster(
 		}
 
 		btrfs_set_extent_delalloc(inode, page_start, page_end, NULL);
-		set_page_dirty(page);
+		dirtied = set_page_dirty(page);
 
 		unlock_extent(&BTRFS_I(inode)->io_tree,
 			      page_start, page_end, GFP_NOFS);
@@ -2986,7 +2987,8 @@ static int relocate_file_extent_cluster(
 		page_cache_release(page);
 
 		index++;
-		balance_dirty_pages_ratelimited(inode->i_mapping);
+		if (dirtied)
+			balance_dirty_pages_ratelimited(inode->i_mapping);
 		btrfs_throttle(BTRFS_I(inode)->root);
 	}
 	WARN_ON(nr != cluster->nr);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
