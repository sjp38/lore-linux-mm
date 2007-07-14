Date: Sat, 14 Jul 2007 12:21:11 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/4] introduce write_begin write_end aops important fix
Message-ID: <20070714102111.GA12215@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Credit for these next 4 patches goes to Hugh. He found and fixed the
problem, I just split them up and added a bit of a changelog and 
hopefully no new bugs.

--

When running kbuild stress testing, it data corruptions on ext2 were
noticed occasionally.

The page being written to by write(2) was being unlocked in generic_write_end
before updating i_size, and that renders an extending-write vulnerable to have
its newly written data zeroed out if writepage comes at the wrong time and
finds the page unlocked but i_size is not yet updated.

Fortunately ext3 wasn't affected by this bug, but ext2 and others using
generic_write_end would be.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -2013,19 +2013,22 @@ int generic_write_end(struct file *file,
 
 	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
 
-	unlock_page(page);
-	mark_page_accessed(page); /* XXX: put this in caller? */
-	page_cache_release(page);
-
 	/*
 	 * No need to use i_size_read() here, the i_size
 	 * cannot change under us because we hold i_mutex.
+	 *
+	 * But it's important to update i_size while still holding page lock:
+	 * page writeout could otherwise come in and zero beyond i_size.
 	 */
 	if (pos+copied > inode->i_size) {
 		i_size_write(inode, pos+copied);
 		mark_inode_dirty(inode);
 	}
 
+	unlock_page(page);
+	mark_page_accessed(page);
+	page_cache_release(page);
+
 	return copied;
 }
 EXPORT_SYMBOL(generic_write_end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
