Received: from atlas.iskon.hr (atlas.iskon.hr [213.191.131.6])
	by inje.iskon.hr (8.9.3/8.9.3/Debian 8.9.3-6) with ESMTP id OAA07484
	for <linux-mm@kvack.org>; Sun, 14 Jan 2001 14:42:01 +0100
Subject: [patch] mm-deactivate-fix-1
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 14 Jan 2001 14:40:55 +0100
Message-ID: <87ofxaz1y0.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have noticed that in deactivate_page_nolock() function pages get
unconditionally moved from the active to the inact_dirty list. Even if
it is really easy with additional check to put them straight to the
inact_clean list if they're freeable. That keeps the list statistics
more accurate and in the end should result in a little bit less CPU
cycles burned (only one list transition, less locking). As a bonus,
the comment above the function is now correct. :)

I have tested the patch thoroughly and couldn't find any problems with
it. It should be really safe as reclaim_page() already carefully
checks pages before freeing.

Comments?


Index: 0.19/mm/swap.c
--- 0.19/mm/swap.c Sat, 06 Jan 2001 01:48:21 +0100 zcalusic (linux24/j/17_swap.c 1.1 644)
+++ 0.19(w)/mm/swap.c Sun, 14 Jan 2001 14:05:49 +0100 zcalusic (linux24/j/17_swap.c 1.1 644)
@@ -172,7 +172,6 @@
 	 * Besides, as long as we don't move unfreeable pages to the
 	 * inactive_clean list it doesn't need to be perfect...
 	 */
-	int maxcount = (page->buffers ? 3 : 2);
 	page->age = 0;
 	ClearPageReferenced(page);
 
@@ -180,11 +179,19 @@
 	 * Don't touch it if it's not on the active list.
 	 * (some pages aren't on any list at all)
 	 */
-	if (PageActive(page) && page_count(page) <= maxcount && !page_ramdisk(page)) {
-		del_page_from_active_list(page);
+	if (!PageActive(page)
+	    || page_count(page) > (page->buffers ? 3 : 2)
+	    || page_ramdisk(page))
+		return;
+
+	del_page_from_active_list(page);
+
+	if (page->mapping && !page->buffers && !PageDirty(page)) {
+		add_page_to_inactive_clean_list(page);
+	} else {
 		add_page_to_inactive_dirty_list(page);
 	}
-}	
+}
 
 void deactivate_page(struct page * page)
 {

-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
