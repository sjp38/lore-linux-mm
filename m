Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9CEBA6B0254
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 07:01:05 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/10] mm: swap: Implement generic handlers for swap-related address ops
Date: Fri,  9 Sep 2011 12:00:48 +0100
Message-Id: <1315566054-17209-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1315566054-17209-1-git-send-email-mgorman@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

With the introduction of swap_activate, swap_writepage and
swap_readpage, there is a number of SWP_FILE checks that call a_ops and
fallback to generic handlers. This patch clarifies things by creating
generic versions of these functions and passing in all the information
required to implement a generic handler so the same information is
available to filesystems.  This removes the need for SWP_FILE and
cleans up the flow slightly.  There are no functional changes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/fs.h   |    7 ++-
 include/linux/swap.h |    6 ++-
 mm/page_io.c         |  184 +++++++++++++++++++++++++++++++++++++++-----------
 mm/swapfile.c        |  102 +++-------------------------
 4 files changed, 162 insertions(+), 137 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 387b767..dd93bb1 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -581,6 +581,8 @@ typedef struct {
 typedef int (*read_actor_t)(read_descriptor_t *, struct page *,
 		unsigned long, unsigned long);
 
+struct swap_info_struct;
+
 struct address_space_operations {
 	int (*writepage)(struct page *page, struct writeback_control *wbc);
 	int (*readpage)(struct file *, struct page *);
@@ -619,8 +621,9 @@ struct address_space_operations {
 	int (*error_remove_page)(struct address_space *, struct page *);
 
 	/* swapfile support */
-	int (*swap_activate)(struct file *file);
-	int (*swap_deactivate)(struct file *file);
+	int (*swap_activate)(struct swap_info_struct *sis, struct file *file,
+				sector_t *span);
+	void (*swap_deactivate)(struct file *file);
 	int (*swap_writepage)(struct file *file, struct page *page,
 			struct writeback_control *wbc);
 	int (*swap_readpage)(struct file *file, struct page *page);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a044198..195ae15 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -148,7 +148,6 @@ enum {
 	SWP_SOLIDSTATE	= (1 << 4),	/* blkdev seeks are cheap */
 	SWP_CONTINUED	= (1 << 5),	/* swap_map has count continuation */
 	SWP_BLKDEV	= (1 << 6),	/* its a block device */
-	SWP_FILE	= (1 << 7),	/* set after swap_activate success */
 					/* add others here before... */
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
@@ -307,6 +306,11 @@ extern int swap_writepage(struct page *page, struct writeback_control *wbc);
 extern int swap_set_page_dirty(struct page *page);
 extern void end_swap_bio_read(struct bio *bio, int err);
 
+int add_swap_extent(struct swap_info_struct *, unsigned long start_pfn,
+		unsigned long nr_pages, sector_t);
+int generic_swapfile_activate(struct swap_info_struct *, struct file *,
+		sector_t *);
+
 /* linux/mm/swap_state.c */
 extern struct address_space swapper_space;
 #define total_swapcache_pages  swapper_space.nrpages
diff --git a/mm/page_io.c b/mm/page_io.c
index 5ed5710..6ea49d3 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -86,87 +86,189 @@ void end_swap_bio_read(struct bio *bio, int err)
 	bio_put(bio);
 }
 
+int generic_swap_writepage(struct page *page, struct writeback_control *wbc)
+{
+	struct bio *bio;
+	int rw = WRITE;
+
+	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
+	if (bio == NULL) {
+		set_page_dirty(page);
+		unlock_page(page);
+		return -ENOMEM;
+	}
+	if (wbc->sync_mode == WB_SYNC_ALL)
+		rw |= REQ_SYNC;
+	count_vm_event(PSWPOUT);
+	set_page_writeback(page);
+	unlock_page(page);
+	submit_bio(rw, bio);
+
+	return 0;
+}
+
+int generic_swap_readpage(struct page *page)
+{
+	struct bio *bio;
+	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
+	if (bio == NULL) {
+		unlock_page(page);
+		return -ENOMEM;
+	}
+	count_vm_event(PSWPIN);
+	submit_bio(READ, bio);
+
+	return 0;
+}
+
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
 /*
  * We may have stale swap cache pages in memory: notice
  * them here and get rid of the unnecessary final write.
  */
 int swap_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct bio *bio;
-	int ret = 0, rw = WRITE;
+	int ret = 0;
 	struct swap_info_struct *sis = page_swap_info(page);
+	struct file *swap_file;
+	struct address_space *mapping;
 
 	if (try_to_free_swap(page)) {
 		unlock_page(page);
-		goto out;
+		return ret;
 	}
 
-	if (sis->flags & SWP_FILE) {
-		struct file *swap_file = sis->swap_file;
-		struct address_space *mapping = swap_file->f_mapping;
-
+	swap_file = sis->swap_file;
+	mapping = swap_file->f_mapping;
+	if (mapping->a_ops->swap_writepage) {
 		ret = mapping->a_ops->swap_writepage(swap_file, page, wbc);
 		if (!ret)
 			count_vm_event(PSWPOUT);
 		return ret;
 	}
 
-	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
-	if (bio == NULL) {
-		set_page_dirty(page);
-		unlock_page(page);
-		ret = -ENOMEM;
-		goto out;
-	}
-	if (wbc->sync_mode == WB_SYNC_ALL)
-		rw |= REQ_SYNC;
-	count_vm_event(PSWPOUT);
-	set_page_writeback(page);
-	unlock_page(page);
-	submit_bio(rw, bio);
-out:
-	return ret;
+	return generic_swap_writepage(page, wbc);
 }
 
 int swap_readpage(struct page *page)
 {
-	struct bio *bio;
 	int ret = 0;
 	struct swap_info_struct *sis = page_swap_info(page);
+	struct file *swap_file;
+	struct address_space *mapping;
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageUptodate(page));
 
-	if (sis->flags & SWP_FILE) {
-		struct file *swap_file = sis->swap_file;
-		struct address_space *mapping = swap_file->f_mapping;
-
+	swap_file = sis->swap_file;
+	mapping = swap_file->f_mapping;
+	if (mapping->a_ops->swap_readpage) {
 		ret = mapping->a_ops->swap_readpage(swap_file, page);
 		if (!ret)
 			count_vm_event(PSWPIN);
 		return ret;
 	}
 
-	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
-	if (bio == NULL) {
-		unlock_page(page);
-		ret = -ENOMEM;
-		goto out;
-	}
-	count_vm_event(PSWPIN);
-	submit_bio(READ, bio);
-out:
-	return ret;
+	return generic_swap_readpage(page);
 }
 
 int swap_set_page_dirty(struct page *page)
 {
 	struct swap_info_struct *sis = page_swap_info(page);
+	struct address_space *mapping = sis->swap_file->f_mapping;
 
-	if (sis->flags & SWP_FILE) {
-		struct address_space *mapping = sis->swap_file->f_mapping;
+	if (mapping->a_ops->set_page_dirty)
 		return mapping->a_ops->set_page_dirty(page);
-	} else {
+	else
 		return __set_page_dirty_nobuffers(page);
-	}
 }
diff --git a/mm/swapfile.c b/mm/swapfile.c
index f181884..c49cb33 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1335,6 +1335,9 @@ sector_t map_swap_page(struct page *page, struct block_device **bdev)
  */
 static void destroy_swap_extents(struct swap_info_struct *sis)
 {
+	struct file *swap_file = sis->swap_file;
+	struct address_space *mapping = swap_file->f_mapping;
+
 	while (!list_empty(&sis->first_swap_extent.list)) {
 		struct swap_extent *se;
 
@@ -1344,13 +1347,8 @@ static void destroy_swap_extents(struct swap_info_struct *sis)
 		kfree(se);
 	}
 
-	if (sis->flags & SWP_FILE) {
-		struct file *swap_file = sis->swap_file;
-		struct address_space *mapping = swap_file->f_mapping;
-
-		sis->flags &= ~SWP_FILE;
+	if (mapping->a_ops->swap_deactivate)
 		mapping->a_ops->swap_deactivate(swap_file);
-	}
 }
 
 /*
@@ -1359,7 +1357,7 @@ static void destroy_swap_extents(struct swap_info_struct *sis)
  *
  * This function rather assumes that it is called in ascending page order.
  */
-static int
+int
 add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
 		unsigned long nr_pages, sector_t start_block)
 {
@@ -1435,106 +1433,24 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
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
-			sis->flags |= SWP_FILE;
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
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
