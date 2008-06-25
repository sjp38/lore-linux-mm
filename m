Message-Id: <20080625124123.124728808@szeredi.hu>
References: <20080625124038.103406301@szeredi.hu>
Date: Wed, 25 Jun 2008 14:40:40 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 2/2] splice: fix generic_file_splice_read() race with page invalidation
Content-Disposition: inline; filename=splice_generic_file_splice_read_fix.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

If a page was invalidated during splicing from file to a pipe, then
generic_file_splice_read() could return a short or zero count.

This manifested itself in rare I/O errors seen on nfs exported fuse
filesystems.  This is because nfsd uses splice_direct_to_actor() to
read files, and fuse uses invalidate_inode_pages2() to invalidate
stale data on open.

Fix by redoing the page find/create if it was found to be truncated
(invalidated). 

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/splice.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c	2008-06-25 08:18:51.000000000 +0200
+++ linux-2.6/fs/splice.c	2008-06-25 11:57:33.000000000 +0200
@@ -379,13 +379,22 @@ __generic_file_splice_read(struct file *
 				lock_page(page);
 
 			/*
-			 * page was truncated, stop here. if this isn't the
-			 * first page, we'll just complete what we already
-			 * added
+			 * Page was truncated, or invalidated by the
+			 * filesystem.  Redo the find/create, but this time the
+			 * page is kept locked, so there's no chance of another
+			 * race with truncate/invalidate.
 			 */
 			if (!page->mapping) {
 				unlock_page(page);
-				break;
+				page = find_or_create_page(mapping, index,
+						mapping_gfp_mask(mapping));
+
+				if (!page) {
+					error = -ENOMEM;
+					break;
+				}
+				page_cache_release(pages[page_nr]);
+				pages[page_nr] = page;
 			}
 			/*
 			 * page was already under io and is now done, great

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
