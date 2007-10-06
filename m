Date: Sat, 6 Oct 2007 21:46:33 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 5/7] shmem_getpage return page locked
In-Reply-To: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0710062145160.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In the new aops, write_begin is supposed to return the page locked:
though I've seen no ill effects, that's been overlooked in the case
of shmem_write_begin, and should be fixed.  Then shmem_write_end must
unlock the page: do so _after_ updating i_size, as we found to be
important in other filesystems (though since shmem pages don't go
the usual writeback route, they never suffered from that corruption).

For shmem_write_begin to return the page locked, we need shmem_getpage
to return the page locked in SGP_WRITE case as well as SGP_CACHE case:
let's simplify the interface and return it locked even when SGP_READ.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/shmem.c |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

--- patch4/mm/shmem.c	2007-10-04 19:24:39.000000000 +0100
+++ patch5/mm/shmem.c	2007-10-04 19:24:41.000000000 +0100
@@ -729,6 +729,8 @@ static int shmem_notify_change(struct de
 				(void) shmem_getpage(inode,
 					attr->ia_size>>PAGE_CACHE_SHIFT,
 						&page, SGP_READ, NULL);
+				if (page)
+					unlock_page(page);
 			}
 			/*
 			 * Reset SHMEM_PAGEIN flag so that shmem_truncate can
@@ -1270,12 +1272,7 @@ repeat:
 		SetPageUptodate(filepage);
 	}
 done:
-	if (*pagep != filepage) {
-		*pagep = filepage;
-		if (sgp != SGP_CACHE)
-			unlock_page(filepage);
-
-	}
+	*pagep = filepage;
 	return 0;
 
 failed:
@@ -1453,12 +1450,13 @@ shmem_write_end(struct file *file, struc
 {
 	struct inode *inode = mapping->host;
 
+	if (pos + copied > inode->i_size)
+		i_size_write(inode, pos + copied);
+
+	unlock_page(page);
 	set_page_dirty(page);
 	page_cache_release(page);
 
-	if (pos+copied > inode->i_size)
-		i_size_write(inode, pos+copied);
-
 	return copied;
 }
 
@@ -1513,6 +1511,7 @@ shmem_file_write(struct file *file, cons
 		if (err)
 			break;
 
+		unlock_page(page);
 		left = bytes;
 		if (PageHighMem(page)) {
 			volatile unsigned char dummy;
@@ -1594,6 +1593,8 @@ static void do_shmem_file_read(struct fi
 				desc->error = 0;
 			break;
 		}
+		if (page)
+			unlock_page(page);
 
 		/*
 		 * We must evaluate after, since reads (unlike writes)
@@ -1883,6 +1884,7 @@ static int shmem_symlink(struct inode *d
 			iput(inode);
 			return error;
 		}
+		unlock_page(page);
 		inode->i_op = &shmem_symlink_inode_operations;
 		kaddr = kmap_atomic(page, KM_USER0);
 		memcpy(kaddr, symname, len);
@@ -1910,6 +1912,8 @@ static void *shmem_follow_link(struct de
 	struct page *page = NULL;
 	int res = shmem_getpage(dentry->d_inode, 0, &page, SGP_READ, NULL);
 	nd_set_link(nd, res ? ERR_PTR(res) : kmap(page));
+	if (page)
+		unlock_page(page);
 	return page;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
