Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1B9856B0055
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 20:50:56 -0400 (EDT)
Date: Thu, 15 Oct 2009 01:50:54 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 4/9] swap_info: miscellaneous minor cleanups
In-Reply-To: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
Message-ID: <Pine.LNX.4.64.0910150149160.3291@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rafael Wysocki <rjw@sisk.pl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Move CONFIG_MIGRATION's swapdev_block() into the main CONFIG_MIGRATION
block, remove extraneous whitespace and return, fix typo in a comment.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/swapfile.c |   51 ++++++++++++++++++++++--------------------------
 1 file changed, 24 insertions(+), 27 deletions(-)

--- si3/mm/swapfile.c	2009-10-14 21:26:22.000000000 +0100
+++ si4/mm/swapfile.c	2009-10-14 21:26:32.000000000 +0100
@@ -519,9 +519,9 @@ swp_entry_t get_swap_page_of_type(int ty
 	return (swp_entry_t) {0};
 }
 
-static struct swap_info_struct * swap_info_get(swp_entry_t entry)
+static struct swap_info_struct *swap_info_get(swp_entry_t entry)
 {
-	struct swap_info_struct * p;
+	struct swap_info_struct *p;
 	unsigned long offset, type;
 
 	if (!entry.val)
@@ -599,7 +599,7 @@ static int swap_entry_free(struct swap_i
  */
 void swap_free(swp_entry_t entry)
 {
-	struct swap_info_struct * p;
+	struct swap_info_struct *p;
 
 	p = swap_info_get(entry);
 	if (p) {
@@ -629,7 +629,6 @@ void swapcache_free(swp_entry_t entry, s
 		}
 		spin_unlock(&swap_lock);
 	}
-	return;
 }
 
 /*
@@ -783,6 +782,21 @@ int swap_type_of(dev_t device, sector_t
 }
 
 /*
+ * Get the (PAGE_SIZE) block corresponding to given offset on the swapdev
+ * corresponding to given index in swap_info (swap type).
+ */
+sector_t swapdev_block(int type, pgoff_t offset)
+{
+	struct block_device *bdev;
+
+	if ((unsigned int)type >= nr_swapfiles)
+		return 0;
+	if (!(swap_info[type]->flags & SWP_WRITEOK))
+		return 0;
+	return map_swap_page(swp_entry(type, offset), &bdev);
+}
+
+/*
  * Return either the total number of swap pages of given type, or the number
  * of free pages of that type (depending on @free)
  *
@@ -805,7 +819,7 @@ unsigned int count_swap_pages(int type,
 	spin_unlock(&swap_lock);
 	return n;
 }
-#endif
+#endif /* CONFIG_HIBERNATION */
 
 /*
  * No need to decide whether this PTE shares the swap entry with others,
@@ -1317,23 +1331,6 @@ sector_t map_swap_page(swp_entry_t entry
 	}
 }
 
-#ifdef CONFIG_HIBERNATION
-/*
- * Get the (PAGE_SIZE) block corresponding to given offset on the swapdev
- * corresponding to given index in swap_info (swap type).
- */
-sector_t swapdev_block(int type, pgoff_t offset)
-{
-	struct block_device *bdev;
-
-	if ((unsigned int)type >= nr_swapfiles)
-		return 0;
-	if (!(swap_info[type]->flags & SWP_WRITEOK))
-		return 0;
-	return map_swap_page(swp_entry(type, offset), &bdev);
-}
-#endif /* CONFIG_HIBERNATION */
-
 /*
  * Free all of a swapdev's extent information
  */
@@ -1525,12 +1522,12 @@ bad_bmap:
 
 SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 {
-	struct swap_info_struct * p = NULL;
+	struct swap_info_struct *p = NULL;
 	unsigned short *swap_map;
 	struct file *swap_file, *victim;
 	struct address_space *mapping;
 	struct inode *inode;
-	char * pathname;
+	char *pathname;
 	int i, type, prev;
 	int err;
 
@@ -1782,7 +1779,7 @@ late_initcall(max_swapfiles_check);
  */
 SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 {
-	struct swap_info_struct * p;
+	struct swap_info_struct *p;
 	char *name = NULL;
 	struct block_device *bdev = NULL;
 	struct file *swap_file = NULL;
@@ -2117,7 +2114,7 @@ void si_swapinfo(struct sysinfo *val)
  */
 static int __swap_duplicate(swp_entry_t entry, bool cache)
 {
-	struct swap_info_struct * p;
+	struct swap_info_struct *p;
 	unsigned long offset, type;
 	int result = -EINVAL;
 	int count;
@@ -2186,7 +2183,7 @@ void swap_duplicate(swp_entry_t entry)
 /*
  * @entry: swap entry for which we allocate swap cache.
  *
- * Called when allocating swap cache for exising swap entry,
+ * Called when allocating swap cache for existing swap entry,
  * This can return error codes. Returns 0 at success.
  * -EBUSY means there is a swap cache.
  * Note: return code is different from swap_duplicate().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
