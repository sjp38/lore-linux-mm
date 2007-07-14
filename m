Date: Sat, 14 Jul 2007 12:24:04 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 3/4] affs convert to new aops fix
Message-ID: <20070714102404.GC12215@wotan.suse.de>
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

Hugh noticed the page wasn't being unlocked at all in the affs
conversion.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/fs/affs/file.c
===================================================================
--- linux-2.6.orig/fs/affs/file.c
+++ linux-2.6/fs/affs/file.c
@@ -13,6 +13,7 @@
  */
 
 #include "affs.h"
+#include <linux/swap.h> /* mark_page_accessed */
 
 #if PAGE_SIZE < 4096
 #error PAGE_SIZE must be at least 4096
@@ -767,6 +768,10 @@ done:
 	if (tmp > inode->i_size)
 		inode->i_size = AFFS_I(inode)->mmu_private = tmp;
 
+	unlock_page(page);
+	mark_page_accessed(page);
+	page_cache_release(page);
+
 	return written;
 
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
