Subject: PATCH: Bug in invalidate_inode_pages()?
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 09 May 2000 01:39:18 +0200
Message-ID: <yttk8h4vcgp.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi
        I think that I have found a bug in invalidate_inode_pages.
It results that we don't remove the pages from the
&inode->i_mapping->pages list, then when we return te do the next loop
through all the pages, we can try to free a page that we have freed in
the previous pass.  Once here I have also removed the goto

Comments, have I lost something obvious?

Later, Juan.

diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-6/mm/filemap.c testing2/mm/filemap.c
--- pre7-6/mm/filemap.c	Fri May  5 23:58:56 2000
+++ testing2/mm/filemap.c	Tue May  9 01:37:57 2000
@@ -121,6 +121,7 @@
 		/* We cannot invalidate a locked page */
 		if (TryLockPage(page))
 			continue;
+                list_del(curr);
 		spin_unlock(&pagecache_lock);
 
 		lru_cache_del(page);

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
