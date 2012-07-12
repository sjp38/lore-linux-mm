Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id A982D6B0096
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:41:18 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/12] mm: swap: Implement generic handler for swap_activate
Date: Thu, 12 Jul 2012 07:40:59 +0100
Message-Id: <1342075266-29593-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075266-29593-1-git-send-email-mgorman@suse.de>
References: <1342075266-29593-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

The version of swap_activate introduced is sufficient for swap-over-NFS
but would not provide enough information to implement a generic handler.
This patch shuffles things slightly to ensure the same information is
available for aops->swap_activate() as is available to the core.

No functionality change.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/fs.h   |    6 ++--
 include/linux/swap.h |    5 +++
 mm/page_io.c         |   92 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/swapfile.c        |   91 +++----------------------------------------------
 4 files changed, 106 insertions(+), 88 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 5d53f03..6d269ba 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -427,6 +427,7 @@ struct kstatfs;
 struct vm_area_struct;
 struct vfsmount;
 struct cred;
+struct swap_info_struct;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
@@ -640,8 +641,9 @@ struct address_space_operations {
 	int (*error_remove_page)(struct address_space *, struct page *);
 
 	/* swapfile support */
-	int (*swap_activate)(struct file *file);
-	int (*swap_deactivate)(struct file *file);
+	int (*swap_activate)(struct swap_info_struct *sis, struct file *file,
+				sector_t *span);
+	void (*swap_deactivate)(struct file *file);
 };
 
 extern const struct address_space_operations empty_aops;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 468fd4a..d0d720b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -324,6 +324,11 @@ extern int swap_writepage(struct page *page, struct writeback_control *wbc);
 extern int swap_set_page_dirty(struct page *page);
 extern void end_swap_bio_read(struct bio *bio, int err);
 
+int add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
+		unsigned long nr_pages, sector_t start_block);
+int generic_swapfile_activate(struct swap_info_struct *, struct file *,
+		sector_t *);
+
 /* linux/mm/swap_state.c */
 extern struct address_space swapper_space;
 #define total_swapcache_pages  swapper_space.nrpages
diff --git a/mm/page_io.c b/mm/page_io.c
index 307a3e7..4a37962 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -87,6 +87,98 @@ void end_swap_bio_read(struct bio *bio, int err)
 	bio_put(bio);
 }
 
+int generic_swapfile_activate(struct swap_info_struct *sis,
+				struct file *swap_file,
+				sector_t *span)
+{
+	struct address_space *mapping = swap_file->f_mapping;
+	struct inode *inode = mapping->host;
+	unsigned blocks_per_page;
+	unsigned long page_no;
+	unsigned blkbits;
+	sector_t probe_block;
+	sector_t last_block;
+	sector_t lowest_block = -1;
+	sector_t highest_block = 0;
+	int nr_extents = 0;
+	int ret;
+
+	blkbits = inode->i_blkbits;
+	blocks_per_page = PAGE_SIZE >> blkbits;
+
+	/*
+	 * Map all the blocks into the extent list.  This code doesn't try
+	 * to be very smart.
+	 */
+	probe_block = 0;
+	page_no = 0;
+	last_block = i_size_read(inode) >> blkbits;
+	while ((probe_block + blocks_per_page) <= last_block &&
+			page_no < sis->max) {
+		unsigned block_in_page;
+		sector_t first_block;
+
+		first_block = bmap(inode, probe_block);
+		if (first_block == 0)
+			goto bad_bmap;
+
+		/*
+		 * It must be PAGE_SIZE aligned on-disk
+		 */
+		if (first_block & (blocks_per_page - 1)) {
+			probe_block++;
+			goto reprobe;
+		}
+
+		for (block_in_page = 1; block_in_page < blocks_per_page;
+					block_in_page++) {
+			sector_t block;
+
+			block = bmap(inode, probe_block + block_in_page);
+			if (block == 0)
+				goto bad_bmap;
+			if (block != first_block + block_in_page) {
+				/* Discontiguity */
+				probe_block++;
+				goto reprobe;
+			}
+		}
+
+		first_block >>= (PAGE_SHIFT - blkbits);
+		if (page_no) {	/* exclude the header page */
+			if (first_block < lowest_block)
+				lowest_block = first_block;
+			if (first_block > highest_block)
+				highest_block = first_block;
+		}
+
+		/*
+		 * We found a PAGE_SIZE-length, PAGE_SIZE-aligned run of blocks
+		 */
+		ret = add_swap_extent(sis, page_no, 1, first_block);
+		if (ret < 0)
+			goto out;
+		nr_extents += ret;
+		page_no++;
+		probe_block += blocks_per_page;
+reprobe:
+		continue;
+	}
+	ret = nr_extents;
+	*span = 1 + highest_block - lowest_block;
+	if (page_no == 0)
+		page_no = 1;	/* force Empty message */
+	sis->max = page_no;
+	sis->pages = page_no - 1;
+	sis->highest_bit = page_no - 1;
+out:
+	return ret;
+bad_bmap:
+	printk(KERN_ERR "swapon: swapfile has holes\n");
+	ret = -EINVAL;
+	goto out;
+}
+
 /*
  * We may have stale swap cache pages in memory: notice
  * them here and get rid of the unnecessary final write.
diff --git a/mm/swapfile.c b/mm/swapfile.c
index b8b5861..1d77b13 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1358,7 +1358,7 @@ static void destroy_swap_extents(struct swap_info_struct *sis)
  *
  * This function rather assumes that it is called in ascending page order.
  */
-static int
+int
 add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
 		unsigned long nr_pages, sector_t start_block)
 {
@@ -1434,106 +1434,25 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
 	struct file *swap_file = sis->swap_file;
 	struct address_space *mapping = swap_file->f_mapping;
 	struct inode *inode = mapping->host;
-	unsigned blocks_per_page;
-	unsigned long page_no;
-	unsigned blkbits;
-	sector_t probe_block;
-	sector_t last_block;
-	sector_t lowest_block = -1;
-	sector_t highest_block = 0;
-	int nr_extents = 0;
 	int ret;
 
 	if (S_ISBLK(inode->i_mode)) {
 		ret = add_swap_extent(sis, 0, sis->max, 0);
 		*span = sis->pages;
-		goto out;
+		return ret;
 	}
 
 	if (mapping->a_ops->swap_activate) {
-		ret = mapping->a_ops->swap_activate(swap_file);
+		ret = mapping->a_ops->swap_activate(sis, swap_file, span);
 		if (!ret) {
 			sis->flags |= SWP_FILE;
 			ret = add_swap_extent(sis, 0, sis->max, 0);
 			*span = sis->pages;
 		}
-		goto out;
+		return ret;
 	}
 
-	blkbits = inode->i_blkbits;
-	blocks_per_page = PAGE_SIZE >> blkbits;
-
-	/*
-	 * Map all the blocks into the extent list.  This code doesn't try
-	 * to be very smart.
-	 */
-	probe_block = 0;
-	page_no = 0;
-	last_block = i_size_read(inode) >> blkbits;
-	while ((probe_block + blocks_per_page) <= last_block &&
-			page_no < sis->max) {
-		unsigned block_in_page;
-		sector_t first_block;
-
-		first_block = bmap(inode, probe_block);
-		if (first_block == 0)
-			goto bad_bmap;
-
-		/*
-		 * It must be PAGE_SIZE aligned on-disk
-		 */
-		if (first_block & (blocks_per_page - 1)) {
-			probe_block++;
-			goto reprobe;
-		}
-
-		for (block_in_page = 1; block_in_page < blocks_per_page;
-					block_in_page++) {
-			sector_t block;
-
-			block = bmap(inode, probe_block + block_in_page);
-			if (block == 0)
-				goto bad_bmap;
-			if (block != first_block + block_in_page) {
-				/* Discontiguity */
-				probe_block++;
-				goto reprobe;
-			}
-		}
-
-		first_block >>= (PAGE_SHIFT - blkbits);
-		if (page_no) {	/* exclude the header page */
-			if (first_block < lowest_block)
-				lowest_block = first_block;
-			if (first_block > highest_block)
-				highest_block = first_block;
-		}
-
-		/*
-		 * We found a PAGE_SIZE-length, PAGE_SIZE-aligned run of blocks
-		 */
-		ret = add_swap_extent(sis, page_no, 1, first_block);
-		if (ret < 0)
-			goto out;
-		nr_extents += ret;
-		page_no++;
-		probe_block += blocks_per_page;
-reprobe:
-		continue;
-	}
-	ret = nr_extents;
-	*span = 1 + highest_block - lowest_block;
-	if (page_no == 0)
-		page_no = 1;	/* force Empty message */
-	sis->max = page_no;
-	sis->pages = page_no - 1;
-	sis->highest_bit = page_no - 1;
-out:
-	return ret;
-bad_bmap:
-	printk(KERN_ERR "swapon: swapfile has holes\n");
-	ret = -EINVAL;
-	goto out;
+	return generic_swapfile_activate(sis, swap_file, span);
 }
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
