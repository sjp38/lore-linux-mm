Date: Sat, 14 Jul 2007 12:23:01 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/4] reiserfs convert to new aops fix
Message-ID: <20070714102301.GB12215@wotan.suse.de>
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

Lock ordering fix for the same problem for reiserfs.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/fs/reiserfs/inode.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/inode.c
+++ linux-2.6/fs/reiserfs/inode.c
@@ -2694,9 +2694,6 @@ static int reiserfs_write_end(struct fil
 	flush_dcache_page(page);
 
 	reiserfs_commit_page(inode, page, start, start + copied);
-	unlock_page(page);
-	mark_page_accessed(page);
-	page_cache_release(page);
 
 	/* generic_commit_write does this for us, but does not update the
 	 ** transaction tracking stuff when the size changes.  So, we have
@@ -2746,6 +2743,9 @@ static int reiserfs_write_end(struct fil
 	}
 
       out:
+	unlock_page(page);
+	mark_page_accessed(page);
+	page_cache_release(page);
 	return ret == 0 ? copied : ret;
 
       journal_error:
@@ -2757,7 +2757,7 @@ static int reiserfs_write_end(struct fil
 		reiserfs_write_unlock(inode->i_sb);
 	}
 
-	return ret;
+	goto out;
 }
 
 int reiserfs_commit_write(struct file *f, struct page *page,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
