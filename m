Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 838E66B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 20:49:16 -0400 (EDT)
Date: Thu, 15 Oct 2009 01:49:13 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 3/9] swap_info: include first_swap_extent
In-Reply-To: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
Message-ID: <Pine.LNX.4.64.0910150148040.3291@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make better use of the space by folding first swap_extent into its
swap_info_struct, instead of just the list_head: swap partitions need
only that one, and for others it's used as a circular list anyway.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/swap.h |    2 -
 mm/swapfile.c        |   72 +++++++++++++++++++++--------------------
 2 files changed, 38 insertions(+), 36 deletions(-)

--- si2/include/linux/swap.h	2009-10-14 21:26:09.000000000 +0100
+++ si3/include/linux/swap.h	2009-10-14 21:26:22.000000000 +0100
@@ -165,7 +165,7 @@ struct swap_info_struct {
 	signed char	next;		/* next type on the swap list */
 	struct file *swap_file;
 	struct block_device *bdev;
-	struct list_head extent_list;
+	struct swap_extent first_swap_extent;
 	struct swap_extent *curr_swap_extent;
 	unsigned short *swap_map;
 	unsigned int lowest_bit;
--- si2/mm/swapfile.c	2009-10-14 21:26:09.000000000 +0100
+++ si3/mm/swapfile.c	2009-10-14 21:26:22.000000000 +0100
@@ -145,23 +145,28 @@ void swap_unplug_io_fn(struct backing_de
 static int discard_swap(struct swap_info_struct *si)
 {
 	struct swap_extent *se;
+	sector_t start_block;
+	sector_t nr_blocks;
 	int err = 0;
 
-	list_for_each_entry(se, &si->extent_list, list) {
-		sector_t start_block = se->start_block << (PAGE_SHIFT - 9);
-		sector_t nr_blocks = (sector_t)se->nr_pages << (PAGE_SHIFT - 9);
-
-		if (se->start_page == 0) {
-			/* Do not discard the swap header page! */
-			start_block += 1 << (PAGE_SHIFT - 9);
-			nr_blocks -= 1 << (PAGE_SHIFT - 9);
-			if (!nr_blocks)
-				continue;
-		}
+	/* Do not discard the swap header page! */
+	se = &si->first_swap_extent;
+	start_block = (se->start_block + 1) << (PAGE_SHIFT - 9);
+	nr_blocks = ((sector_t)se->nr_pages - 1) << (PAGE_SHIFT - 9);
+	if (nr_blocks) {
+		err = blkdev_issue_discard(si->bdev, start_block,
+				nr_blocks, GFP_KERNEL, DISCARD_FL_BARRIER);
+		if (err)
+			return err;
+		cond_resched();
+	}
+
+	list_for_each_entry(se, &si->first_swap_extent.list, list) {
+		start_block = se->start_block << (PAGE_SHIFT - 9);
+		nr_blocks = (sector_t)se->nr_pages << (PAGE_SHIFT - 9);
 
 		err = blkdev_issue_discard(si->bdev, start_block,
-						nr_blocks, GFP_KERNEL,
-						DISCARD_FL_BARRIER);
+				nr_blocks, GFP_KERNEL, DISCARD_FL_BARRIER);
 		if (err)
 			break;
 
@@ -200,14 +205,11 @@ static void discard_swap_cluster(struct
 			start_block <<= PAGE_SHIFT - 9;
 			nr_blocks <<= PAGE_SHIFT - 9;
 			if (blkdev_issue_discard(si->bdev, start_block,
-							nr_blocks, GFP_NOIO,
-							DISCARD_FL_BARRIER))
+				    nr_blocks, GFP_NOIO, DISCARD_FL_BARRIER))
 				break;
 		}
 
 		lh = se->list.next;
-		if (lh == &si->extent_list)
-			lh = lh->next;
 		se = list_entry(lh, struct swap_extent, list);
 	}
 }
@@ -761,10 +763,8 @@ int swap_type_of(dev_t device, sector_t
 			return type;
 		}
 		if (bdev == sis->bdev) {
-			struct swap_extent *se;
+			struct swap_extent *se = &sis->first_swap_extent;
 
-			se = list_entry(sis->extent_list.next,
-					struct swap_extent, list);
 			if (se->start_block == offset) {
 				if (bdev_p)
 					*bdev_p = bdgrab(sis->bdev);
@@ -1311,8 +1311,6 @@ sector_t map_swap_page(swp_entry_t entry
 			return se->start_block + (offset - se->start_page);
 		}
 		lh = se->list.next;
-		if (lh == &sis->extent_list)
-			lh = lh->next;
 		se = list_entry(lh, struct swap_extent, list);
 		sis->curr_swap_extent = se;
 		BUG_ON(se == start_se);		/* It *must* be present */
@@ -1341,10 +1339,10 @@ sector_t swapdev_block(int type, pgoff_t
  */
 static void destroy_swap_extents(struct swap_info_struct *sis)
 {
-	while (!list_empty(&sis->extent_list)) {
+	while (!list_empty(&sis->first_swap_extent.list)) {
 		struct swap_extent *se;
 
-		se = list_entry(sis->extent_list.next,
+		se = list_entry(sis->first_swap_extent.list.next,
 				struct swap_extent, list);
 		list_del(&se->list);
 		kfree(se);
@@ -1365,8 +1363,16 @@ add_swap_extent(struct swap_info_struct
 	struct swap_extent *new_se;
 	struct list_head *lh;
 
-	lh = sis->extent_list.prev;	/* The highest page extent */
-	if (lh != &sis->extent_list) {
+	if (start_page == 0) {
+		se = &sis->first_swap_extent;
+		sis->curr_swap_extent = se;
+		INIT_LIST_HEAD(&se->list);
+		se->start_page = 0;
+		se->nr_pages = nr_pages;
+		se->start_block = start_block;
+		return 1;
+	} else {
+		lh = sis->first_swap_extent.list.prev;	/* Highest extent */
 		se = list_entry(lh, struct swap_extent, list);
 		BUG_ON(se->start_page + se->nr_pages != start_page);
 		if (se->start_block + se->nr_pages == start_block) {
@@ -1386,7 +1392,7 @@ add_swap_extent(struct swap_info_struct
 	new_se->nr_pages = nr_pages;
 	new_se->start_block = start_block;
 
-	list_add_tail(&new_se->list, &sis->extent_list);
+	list_add_tail(&new_se->list, &sis->first_swap_extent.list);
 	return 1;
 }
 
@@ -1438,7 +1444,7 @@ static int setup_swap_extents(struct swa
 	if (S_ISBLK(inode->i_mode)) {
 		ret = add_swap_extent(sis, 0, sis->max, 0);
 		*span = sis->pages;
-		goto done;
+		goto out;
 	}
 
 	blkbits = inode->i_blkbits;
@@ -1509,15 +1515,12 @@ reprobe:
 	sis->max = page_no;
 	sis->pages = page_no - 1;
 	sis->highest_bit = page_no - 1;
-done:
-	sis->curr_swap_extent = list_entry(sis->extent_list.prev,
-					struct swap_extent, list);
-	goto out;
+out:
+	return ret;
 bad_bmap:
 	printk(KERN_ERR "swapon: swapfile has holes\n");
 	ret = -EINVAL;
-out:
-	return ret;
+	goto out;
 }
 
 SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
@@ -1816,7 +1819,6 @@ SYSCALL_DEFINE2(swapon, const char __use
 		kfree(p);
 		goto out;
 	}
-	INIT_LIST_HEAD(&p->extent_list);
 	if (type >= nr_swapfiles) {
 		p->type = type;
 		swap_info[type] = p;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
