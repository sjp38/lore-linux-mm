Received: from host62-7-65-22.btinternet.com ([62.7.65.22] helo=smtp.btinternet.com)
	by tungsten.btinternet.com with esmtp (Exim 2.05 #1)
	id 12pe4c-0006iV-00
	for linux-mm@kvack.org; Wed, 10 May 2000 22:31:19 +0100
Received: (from news@localhost)
	by smtp.btinternet.com (8.9.3/8.9.3) id VAA21784
	for linux-mm@kvack.org; Wed, 10 May 2000 21:55:42 +0100
From: dave@denial.force9.co.uk (Dave Jones)
Subject: Re: [PATCH] remove_inode_page rewrite.
Date: 10 May 2000 20:55:42 GMT
Message-ID: <slrn8hjir4.i6o.dave@neo.local>
References: <Pine.LNX.4.21.0005101821260.17653-100000@neo.local>
Reply-To: dave@denial.force9.co.uk
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ok, I've thrown some ideas around in #kernelnewbies with regards
to my last patch, and with the help of Arjan & Quintela, have
arrived at the following patch.

The last patch I sent would 'forget' about locked pages, and never
release them. This one makes multiple passes at the list until
they have all been freed. (but in a much better wat than the original
code) When we get to a locked page, we now sleep in lock_page() until the
page is freed.

This diff is untested, and has been sent here primarily to self-ensure I'm
not going down some blind-alley making things worse than they already are.

Arjan pointed out that there could be a possibility of a page being
unlocked from an interrupt which this code doesn't take into
consideration, and I've not tested. If others want to prove/disprove that,
please do so.

regards,

-- 
Dave.


--- filemap.c~	Tue May  9 19:37:13 2000
+++ filemap.c	Wed May 10 20:50:52 2000
@@ -91,45 +91,64 @@
  * Remove a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.
+ * Caller must also be holding pagecache_lock
  */
 void remove_inode_page(struct page *page)
 {
 	if (!PageLocked(page))
 		PAGE_BUG(page);
 
-	spin_lock(&pagecache_lock);
 	remove_page_from_inode_queue(page);
 	remove_page_from_hash_queue(page);
 	page->mapping = NULL;
-	spin_unlock(&pagecache_lock);
 }
 
+
 void invalidate_inode_pages(struct inode * inode)
 {
 	struct list_head *head, *curr;
 	struct page * page;
 
- repeat:
-	head = &inode->i_mapping->pages;
-	spin_lock(&pagecache_lock);
-	curr = head->next;
+	while (head != head->next) {
 
-	while (curr != head) {
-		page = list_entry(curr, struct page, list);
-		curr = curr->next;
+		spin_lock(&pagecache_lock);
+
+		head = &inode->i_mapping->pages;
+		curr = head->next;
+
+		while (curr != head) {
+
+			page = list_entry(curr, struct page, list);
+			curr = curr->next;
 
-		/* We cannot invalidate a locked page */
-		if (TryLockPage(page))
-			continue;
-		spin_unlock(&pagecache_lock);
-
-		lru_cache_del(page);
-		remove_inode_page(page);
-		UnlockPage(page);
-		page_cache_release(page);
-		goto repeat;
+			/* We cannot invalidate a locked page */
+			if (PageLocked(page))
+				continue;
+
+			lru_cache_del(page);
+			remove_inode_page(page);
+			page_cache_release(page);
+		}
+
+		/* At this stage we have passed through the list
+		 * once, and there may still be locked pages. */
+
+		if (head->next!=head) {
+			page = list_entry(head->next,struct page,list);
+			spin_unlock(&pagecache_lock);
+
+			/* We need to block */
+			lock_page(page);
+			UnlockPage(page);
+
+		} else {
+		
+			/* No pages left in list. */
+			spin_unlock(&pagecache_lock);
+		}
 	}
-	spin_unlock(&pagecache_lock);
+
+empty_list:
 }
 
 /*
@@ -180,7 +199,9 @@
 			 * page cache and creates a buffer-cache alias
 			 * to it causing all sorts of fun problems ...
 			 */
+			spin_lock(&pagecache_lock);
 			remove_inode_page(page);
+			spin_unlock(&pagecache_lock);
 
 			UnlockPage(page);
 			page_cache_release(page);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
