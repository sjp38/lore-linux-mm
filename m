Message-Id: <200405222203.i4MM31r12291@mail.osdl.org>
Subject: [patch 05/57] Make sync_page use swapper_space again
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:02:13 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>


Revert recent changes to sync_page().  Now that page_mapping() returns
&swapper_space for swapcache pages we don't need to test for PageSwapCache in
sync_page().


---

 25-akpm/mm/filemap.c    |   11 +++++------
 25-akpm/mm/swap_state.c |    1 +
 2 files changed, 6 insertions(+), 6 deletions(-)

diff -puN mm/filemap.c~sync_page-use-swapper-space mm/filemap.c
--- 25/mm/filemap.c~sync_page-use-swapper-space	2004-05-22 14:56:21.856768792 -0700
+++ 25-akpm/mm/filemap.c	2004-05-22 14:59:42.131322432 -0700
@@ -121,14 +121,13 @@ static inline int sync_page(struct page 
 {
 	struct address_space *mapping;
 
+	/*
+	 * FIXME, fercrissake.  What is this barrier here for?
+	 */
 	smp_mb();
 	mapping = page_mapping(page);
-	if (mapping) {
-		if (mapping->a_ops && mapping->a_ops->sync_page)
-			return mapping->a_ops->sync_page(page);
-	} else if (PageSwapCache(page)) {
-		swap_unplug_io_fn(NULL, page);
-	}
+	if (mapping && mapping->a_ops && mapping->a_ops->sync_page)
+		return mapping->a_ops->sync_page(page);
 	return 0;
 }
 
diff -puN mm/swap_state.c~sync_page-use-swapper-space mm/swap_state.c
--- 25/mm/swap_state.c~sync_page-use-swapper-space	2004-05-22 14:56:21.857768640 -0700
+++ 25-akpm/mm/swap_state.c	2004-05-22 14:59:40.057637680 -0700
@@ -23,6 +23,7 @@
  */
 static struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
+	.sync_page	= block_sync_page,
 	.set_page_dirty	= __set_page_dirty_nobuffers,
 };
 

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
