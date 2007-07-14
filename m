Date: Sat, 14 Jul 2007 12:24:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 4/4] hostfs convert to new aops fix
Message-ID: <20070714102441.GD12215@wotan.suse.de>
References: <20070714102111.GA12215@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070714102111.GA12215@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Fix lock ordering for hostfs. It seems that this filesystem may not be
vulnerable to the bug, given that it implements its own writepage, but
it is better to retain the safe ordering.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/fs/hostfs/hostfs_kern.c
===================================================================
--- linux-2.6.orig/fs/hostfs/hostfs_kern.c
+++ linux-2.6/fs/hostfs/hostfs_kern.c
@@ -16,6 +16,7 @@
 #include <linux/list.h>
 #include <linux/statfs.h>
 #include <linux/kdev_t.h>
+#include <linux/swap.h> /* mark_page_accessed */
 #include <asm/uaccess.h>
 #include "hostfs.h"
 #include "kern_util.h"
@@ -493,14 +494,15 @@ int hostfs_write_end(struct file *file, 
 
 	if (!PageUptodate(page) && err == PAGE_CACHE_SIZE)
 		SetPageUptodate(page);
-	unlock_page(page);
-	page_cache_release(page);
 
 	/* If err > 0, write_file has added err to pos, so we are comparing
 	 * i_size against the last byte written.
 	 */
 	if (err > 0 && (pos > inode->i_size))
 		inode->i_size = pos;
+	unlock_page(page);
+	mark_page_accessed(page);
+	page_cache_release(page);
 
 	return err;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
