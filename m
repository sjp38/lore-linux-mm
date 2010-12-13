From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 36/47] btrfs: dont call balance_dirty_pages_ratelimited() on already dirty pages
Date: Mon, 13 Dec 2010 14:43:25 +0800
Message-ID: <20101213064841.424193583@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2Fu-00061I-Sx
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:51:31 +0100
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EC01F6B00A6
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:44 -0500 (EST)
Content-Disposition: inline; filename=btrfs-fix-balance-size.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

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

--- linux-next.orig/fs/btrfs/file.c	2010-12-09 12:21:03.000000000 +0800
+++ linux-next/fs/btrfs/file.c	2010-12-09 12:24:59.000000000 +0800
@@ -762,7 +762,8 @@ out:
 static noinline int prepare_pages(struct btrfs_root *root, struct file *file,
 			 struct page **pages, size_t num_pages,
 			 loff_t pos, unsigned long first_index,
-			 unsigned long last_index, size_t write_bytes)
+			 unsigned long last_index, size_t write_bytes,
+			 int *nr_dirtied)
 {
 	struct extent_state *cached_state = NULL;
 	int i;
@@ -825,7 +826,8 @@ again:
 				     GFP_NOFS);
 	}
 	for (i = 0; i < num_pages; i++) {
-		clear_page_dirty_for_io(pages[i]);
+		if (!clear_page_dirty_for_io(pages[i]))
+			(*nr_dirtied)++;
 		set_page_extent_mapped(pages[i]);
 		WARN_ON(!PageLocked(pages[i]));
 	}
@@ -966,6 +968,7 @@ static ssize_t btrfs_file_aio_write(stru
 					 offset);
 		size_t num_pages = (write_bytes + PAGE_CACHE_SIZE - 1) >>
 					PAGE_CACHE_SHIFT;
+		int nr_dirtied = 0;
 
 		WARN_ON(num_pages > nrptrs);
 		memset(pages, 0, sizeof(struct page *) * nrptrs);
@@ -976,7 +979,7 @@ static ssize_t btrfs_file_aio_write(stru
 
 		ret = prepare_pages(root, file, pages, num_pages,
 				    pos, first_index, last_index,
-				    write_bytes);
+				    write_bytes, &nr_dirtied);
 		if (ret) {
 			btrfs_delalloc_release_space(inode, write_bytes);
 			goto out;
@@ -1000,7 +1003,7 @@ static ssize_t btrfs_file_aio_write(stru
 						 pos + write_bytes - 1);
 		} else {
 			balance_dirty_pages_ratelimited_nr(inode->i_mapping,
-							   num_pages);
+							   nr_dirtied);
 			if (num_pages <
 			    (root->leafsize >> PAGE_CACHE_SHIFT) + 1)
 				btrfs_btree_balance_dirty(root, 1);
--- linux-next.orig/fs/btrfs/ioctl.c	2010-12-09 12:21:03.000000000 +0800
+++ linux-next/fs/btrfs/ioctl.c	2010-12-09 12:24:59.000000000 +0800
@@ -647,6 +647,7 @@ static int btrfs_defrag_file(struct file
 	u64 skip = 0;
 	u64 defrag_end = 0;
 	unsigned long i;
+	int dirtied;
 	int ret;
 
 	if (inode->i_size == 0)
@@ -751,7 +752,7 @@ again:
 
 		btrfs_set_extent_delalloc(inode, page_start, page_end, NULL);
 		ClearPageChecked(page);
-		set_page_dirty(page);
+		dirtied = set_page_dirty(page);
 		unlock_extent(io_tree, page_start, page_end, GFP_NOFS);
 
 loop_unlock:
@@ -759,7 +760,8 @@ loop_unlock:
 		page_cache_release(page);
 		mutex_unlock(&inode->i_mutex);
 
-		balance_dirty_pages_ratelimited_nr(inode->i_mapping, 1);
+		if (dirtied)
+			balance_dirty_pages_ratelimited_nr(inode->i_mapping, 1);
 		i++;
 	}
 
--- linux-next.orig/fs/btrfs/relocation.c	2010-12-09 12:21:03.000000000 +0800
+++ linux-next/fs/btrfs/relocation.c	2010-12-09 12:24:59.000000000 +0800
@@ -2894,6 +2894,7 @@ static int relocate_file_extent_cluster(
 	struct file_ra_state *ra;
 	int nr = 0;
 	int ret = 0;
+	int dirtied;
 
 	if (!cluster->nr)
 		return 0;
@@ -2970,7 +2971,7 @@ static int relocate_file_extent_cluster(
 		}
 
 		btrfs_set_extent_delalloc(inode, page_start, page_end, NULL);
-		set_page_dirty(page);
+		dirtied = set_page_dirty(page);
 
 		unlock_extent(&BTRFS_I(inode)->io_tree,
 			      page_start, page_end, GFP_NOFS);
@@ -2978,7 +2979,8 @@ static int relocate_file_extent_cluster(
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
