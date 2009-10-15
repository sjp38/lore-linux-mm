Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D8E336B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 20:46:20 -0400 (EDT)
Date: Thu, 15 Oct 2009 01:46:18 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 1/9] swap_info: private to swapfile.c
In-Reply-To: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
Message-ID: <Pine.LNX.4.64.0910150144310.3291@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The swap_info_struct is mostly private to mm/swapfile.c, with only
one other in-tree user: get_swap_bio().  Adjust its interface to
map_swap_page(), so that we can then remove get_swap_info_struct().

But there is a popular user out-of-tree, TuxOnIce: so leave the
declaration of swap_info_struct in linux/swap.h.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/swap.h |    3 +--
 mm/page_io.c         |   19 +++++++------------
 mm/swapfile.c        |   29 +++++++++++++++++------------
 3 files changed, 25 insertions(+), 26 deletions(-)

--- 2.6.32-rc4/include/linux/swap.h	2009-09-28 00:28:39.000000000 +0100
+++ si1/include/linux/swap.h	2009-10-14 21:25:58.000000000 +0100
@@ -317,9 +317,8 @@ extern void swapcache_free(swp_entry_t,
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
-extern sector_t map_swap_page(struct swap_info_struct *, pgoff_t);
+extern sector_t map_swap_page(swp_entry_t, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
-extern struct swap_info_struct *get_swap_info_struct(unsigned);
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
--- 2.6.32-rc4/mm/page_io.c	2009-09-09 23:13:59.000000000 +0100
+++ si1/mm/page_io.c	2009-10-14 21:25:58.000000000 +0100
@@ -19,20 +19,17 @@
 #include <linux/writeback.h>
 #include <asm/pgtable.h>
 
-static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
+static struct bio *get_swap_bio(gfp_t gfp_flags,
 				struct page *page, bio_end_io_t end_io)
 {
 	struct bio *bio;
 
 	bio = bio_alloc(gfp_flags, 1);
 	if (bio) {
-		struct swap_info_struct *sis;
-		swp_entry_t entry = { .val = index, };
-
-		sis = get_swap_info_struct(swp_type(entry));
-		bio->bi_sector = map_swap_page(sis, swp_offset(entry)) *
-					(PAGE_SIZE >> 9);
-		bio->bi_bdev = sis->bdev;
+		swp_entry_t entry;
+		entry.val = page_private(page);
+		bio->bi_sector = map_swap_page(entry, &bio->bi_bdev);
+		bio->bi_sector <<= PAGE_SHIFT - 9;
 		bio->bi_io_vec[0].bv_page = page;
 		bio->bi_io_vec[0].bv_len = PAGE_SIZE;
 		bio->bi_io_vec[0].bv_offset = 0;
@@ -102,8 +99,7 @@ int swap_writepage(struct page *page, st
 		unlock_page(page);
 		goto out;
 	}
-	bio = get_swap_bio(GFP_NOIO, page_private(page), page,
-				end_swap_bio_write);
+	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
 	if (bio == NULL) {
 		set_page_dirty(page);
 		unlock_page(page);
@@ -127,8 +123,7 @@ int swap_readpage(struct page *page)
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageUptodate(page));
-	bio = get_swap_bio(GFP_KERNEL, page_private(page), page,
-				end_swap_bio_read);
+	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
 	if (bio == NULL) {
 		unlock_page(page);
 		ret = -ENOMEM;
--- 2.6.32-rc4/mm/swapfile.c	2009-10-05 04:33:14.000000000 +0100
+++ si1/mm/swapfile.c	2009-10-14 21:25:58.000000000 +0100
@@ -1284,12 +1284,22 @@ static void drain_mmlist(void)
 
 /*
  * Use this swapdev's extent info to locate the (PAGE_SIZE) block which
- * corresponds to page offset `offset'.
+ * corresponds to page offset `offset'.  Note that the type of this function
+ * is sector_t, but it returns page offset into the bdev, not sector offset.
  */
-sector_t map_swap_page(struct swap_info_struct *sis, pgoff_t offset)
+sector_t map_swap_page(swp_entry_t entry, struct block_device **bdev)
 {
-	struct swap_extent *se = sis->curr_swap_extent;
-	struct swap_extent *start_se = se;
+	struct swap_info_struct *sis;
+	struct swap_extent *start_se;
+	struct swap_extent *se;
+	pgoff_t offset;
+
+	sis = swap_info + swp_type(entry);
+	*bdev = sis->bdev;
+
+	offset = swp_offset(entry);
+	start_se = sis->curr_swap_extent;
+	se = start_se;
 
 	for ( ; ; ) {
 		struct list_head *lh;
@@ -1315,12 +1325,14 @@ sector_t map_swap_page(struct swap_info_
 sector_t swapdev_block(int swap_type, pgoff_t offset)
 {
 	struct swap_info_struct *sis;
+	struct block_device *bdev;
 
 	if (swap_type >= nr_swapfiles)
 		return 0;
 
 	sis = swap_info + swap_type;
-	return (sis->flags & SWP_WRITEOK) ? map_swap_page(sis, offset) : 0;
+	return (sis->flags & SWP_WRITEOK) ?
+		map_swap_page(swp_entry(swap_type, offset), &bdev) : 0;
 }
 #endif /* CONFIG_HIBERNATION */
 
@@ -2160,13 +2172,6 @@ int swapcache_prepare(swp_entry_t entry)
 	return __swap_duplicate(entry, SWAP_CACHE);
 }
 
-
-struct swap_info_struct *
-get_swap_info_struct(unsigned type)
-{
-	return &swap_info[type];
-}
-
 /*
  * swap_lock prevents swap_map being freed. Don't grab an extra
  * reference on the swaphandle, it doesn't matter if it becomes unused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
