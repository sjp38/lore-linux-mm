Subject: Re: PATCH: Rewrite of truncate_inode_pages (WIP)
References: <yttvgzwg70s.fsf@serpe.mitica> <shsd7m3w0xp.fsf@charged.uio.no>
	<ytt7lcaex4g.fsf@serpe.mitica>
	<14645.1518.740545.133390@charged.uio.no>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Trond Myklebust's message of "Wed, 31 May 2000 14:30:38 +0200 (CEST)"
Date: 31 May 2000 17:03:26 +0200
Message-ID: <yttem6iahj5.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: trond.myklebust@fys.uio.no
Cc: lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

>>>>> "trond" == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:
>> OK, the problem here is that __remove_inode_pages needs to be
>> called with page->buffers==NULL.  What do you suggest to obtain
>> that?

>> Ok, tell me *the* correct way of doing that.  We need to make
>> sere that __remove_inode_page is called with page->buffers ==
>> NULL.  It is ok for you:
>> if(page->buffers)
>> BUG();

trond> That's good. It won't affect NFS or smbfs, and it will catch any block 
trond> devices that try to use that function.

Here is the patch, alan, please apply.

Later, Juan.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude ac7/mm/filemap.c working/mm/filemap.c
--- ac7/mm/filemap.c	Wed May 31 15:52:30 2000
+++ working/mm/filemap.c	Wed May 31 16:55:59 2000
@@ -119,7 +119,9 @@
  * @inode: the inode which pages we want to invalidate
  *
  * This function only removes the unlocked pages, if you want to
- * remove all the pages of one inode, you must call truncate_inode_pages.
+ * remove all the pages of one inode, you must call
+ * truncate_inode_pages.  This function is not supposed to be called
+ * by block based filesystems.
  */
 void invalidate_inode_pages(struct inode * inode)
 {
@@ -127,7 +129,6 @@
 	struct page * page;
 
 	head = &inode->i_mapping->pages;
-repeat:
 	spin_lock(&pagecache_lock);
 	spin_lock(&pagemap_lru_lock);
 	curr = head->next;
@@ -139,18 +140,10 @@
 		/* We cannot invalidate a locked page */
 		if (TryLockPage(page))
 			continue;
-		if (page->buffers) {
-			page_cache_get(page);
-			spin_unlock(&pagemap_lru_lock);
-			spin_unlock(&pagecache_lock);			
-			block_destroy_buffers(page);
-			remove_inode_page(page);
-			lru_cache_del(page);
-			page_cache_release(page);
-			UnlockPage(page);
-			page_cache_release(page);
-			goto repeat;
-		}
+		/* We _should not be called_ by block based filesystems */
+		if (page->buffers) 
+			BUG();
+
 		__remove_inode_page(page);
 		__lru_cache_del(page);
 		UnlockPage(page);




-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
