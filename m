Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 918326007E3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 15:10:41 -0500 (EST)
Subject: [PATCH] swap:  rework map_swap_page() again
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 02 Dec 2009 15:10:31 -0500
Message-Id: <1259784631.4088.231.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hugh:  

when your swap_info cleanup patches went by back in mid-Oct, I noticed
your change to the map_swap_page() interface and this additional change
occurred to me.  Is this worth doing?  

[Maybe should do something about that magic '9' there in get_swap_bio()
and all those "PAGE_SHIFT - 9" in swapfile.c as well?]

Lee

-------------------

Re:  swap_info-private-to-swapfilec.patch in mmotm 091124

Seems that page_io.c doesn't really need to know that
page_private(page) is the swp_entry 'val'.  Rework
map_swap_page() to do what its name says and map a page
to a page offset in the swap space.

The only other caller of map_swap_page() is internal to
mm/swapfile.c and it does want to map a swap entry to
the 'sector'.  So rename map_swap_page() to map_swap_entry(),
make it 'static' and and implement map_swap_page() as a wrapper
around that.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/swap.h |    2 +-
 mm/page_io.c         |    4 +---
 mm/swapfile.c        |   20 ++++++++++++++++----
 3 files changed, 18 insertions(+), 8 deletions(-)

Index: linux-2.6.32-rc8-mmotm-091124-1647/include/linux/swap.h
===================================================================
--- linux-2.6.32-rc8-mmotm-091124-1647.orig/include/linux/swap.h	2009-12-02 14:05:25.000000000 -0500
+++ linux-2.6.32-rc8-mmotm-091124-1647/include/linux/swap.h	2009-12-02 14:05:26.000000000 -0500
@@ -325,7 +325,7 @@ extern void swapcache_free(swp_entry_t,
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
-extern sector_t map_swap_page(swp_entry_t, struct block_device **);
+extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
Index: linux-2.6.32-rc8-mmotm-091124-1647/mm/page_io.c
===================================================================
--- linux-2.6.32-rc8-mmotm-091124-1647.orig/mm/page_io.c	2009-12-02 14:05:25.000000000 -0500
+++ linux-2.6.32-rc8-mmotm-091124-1647/mm/page_io.c	2009-12-02 14:05:26.000000000 -0500
@@ -26,9 +26,7 @@ static struct bio *get_swap_bio(gfp_t gf
 
 	bio = bio_alloc(gfp_flags, 1);
 	if (bio) {
-		swp_entry_t entry;
-		entry.val = page_private(page);
-		bio->bi_sector = map_swap_page(entry, &bio->bi_bdev);
+		bio->bi_sector = map_swap_page(page, &bio->bi_bdev);
 		bio->bi_sector <<= PAGE_SHIFT - 9;
 		bio->bi_io_vec[0].bv_page = page;
 		bio->bi_io_vec[0].bv_len = PAGE_SIZE;
Index: linux-2.6.32-rc8-mmotm-091124-1647/mm/swapfile.c
===================================================================
--- linux-2.6.32-rc8-mmotm-091124-1647.orig/mm/swapfile.c	2009-12-02 14:05:25.000000000 -0500
+++ linux-2.6.32-rc8-mmotm-091124-1647/mm/swapfile.c	2009-12-02 14:51:44.000000000 -0500
@@ -39,6 +39,7 @@
 static bool swap_count_continued(struct swap_info_struct *, pgoff_t,
 				 unsigned char);
 static void free_swap_count_continuations(struct swap_info_struct *);
+static sector_t map_swap_entry(swp_entry_t, struct block_device**);
 
 static DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
@@ -785,7 +786,7 @@ sector_t swapdev_block(int type, pgoff_t
 		return 0;
 	if (!(swap_info[type]->flags & SWP_WRITEOK))
 		return 0;
-	return map_swap_page(swp_entry(type, offset), &bdev);
+	return map_swap_entry(swp_entry(type, offset), &bdev);
 }
 
 /*
@@ -1258,10 +1259,11 @@ static void drain_mmlist(void)
 
 /*
  * Use this swapdev's extent info to locate the (PAGE_SIZE) block which
- * corresponds to page offset `offset'.  Note that the type of this function
- * is sector_t, but it returns page offset into the bdev, not sector offset.
+ * corresponds to page offset for the specified swap entry.
+ * Note that the type of this function is sector_t, but it returns page offset
+ * into the bdev, not sector offset.
  */
-sector_t map_swap_page(swp_entry_t entry, struct block_device **bdev)
+static sector_t map_swap_entry(swp_entry_t entry, struct block_device **bdev)
 {
 	struct swap_info_struct *sis;
 	struct swap_extent *start_se;
@@ -1290,6 +1292,16 @@ sector_t map_swap_page(swp_entry_t entry
 }
 
 /*
+ * Returns the page offset into bdev for the specified page's swap entry.
+ */
+sector_t map_swap_page(struct page *page, struct block_device **bdev)
+{
+	swp_entry_t entry;
+	entry.val = page_private(page);
+	return map_swap_entry(entry, bdev);
+}
+
+/*
  * Free all of a swapdev's extent information
  */
 static void destroy_swap_extents(struct swap_info_struct *sis)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
