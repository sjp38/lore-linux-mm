Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 47EE66B01AC
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 01:39:46 -0400 (EDT)
Date: Mon, 22 Mar 2010 16:39:37 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch] mm, fs: warn on missing address space operations
Message-ID: <20100322053937.GA17637@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

It's ugly and lazy that we do these default aops in case it has not
been filled in by the filesystem.

A NULL operation should always mean either: we don't support the
operation; we don't require any action; or a bug in the filesystem,
depending on the context.

In practice, if we get rid of these fallbacks, it will be clearer
what operations are used by a given address_space_operations struct,
reduce branches, reduce #if BLOCK ifdefs, and should allow us to get
rid of all the buffer_head knowledge from core mm and fs code.

We could add a patch like this which spits out a recipe for how to fix
up filesystems and get them all converted quite easily.

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -2472,7 +2472,14 @@ int try_to_release_page(struct page *pag
 
 	if (mapping && mapping->a_ops->releasepage)
 		return mapping->a_ops->releasepage(page, gfp_mask);
-	return try_to_free_buffers(page);
+	else {
+		static bool warned = false;
+		if (!warned) {
+			warned = true;
+			print_symbol("address_space_operations %s missing releasepage method. Use try_to_free_buffers.\n", (unsigned long)page->mapping->a_ops);
+		}
+		return try_to_free_buffers(page);
+	}
 }
 
 EXPORT_SYMBOL(try_to_release_page);
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -1159,8 +1159,14 @@ int set_page_dirty(struct page *page)
 	if (likely(mapping)) {
 		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
 #ifdef CONFIG_BLOCK
-		if (!spd)
+		if (!spd) {
+			static bool warned = false;
+			if (!warned) {
+				warned = true;
+				print_symbol("address_space_operations %s missing set_page_dirty method. Use __set_page_dirty_buffers.\n", (unsigned long)page->mapping->a_ops);
+			}
 			spd = __set_page_dirty_buffers;
+		}
 #endif
 		return (*spd)(page);
 	}
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -16,8 +16,8 @@
 #include <linux/highmem.h>
 #include <linux/pagevec.h>
 #include <linux/task_io_accounting_ops.h>
-#include <linux/buffer_head.h>	/* grr. try_to_release_page,
-				   do_invalidatepage */
+#include <linux/buffer_head.h>	/* block_invalidatepage */
+#include <linux/kallsyms.h>
 #include "internal.h"
 
 
@@ -40,8 +40,14 @@ void do_invalidatepage(struct page *page
 	void (*invalidatepage)(struct page *, unsigned long);
 	invalidatepage = page->mapping->a_ops->invalidatepage;
 #ifdef CONFIG_BLOCK
-	if (!invalidatepage)
+	if (!invalidatepage) {
+		static bool warned = false;
+		if (!warned) {
+			warned = true;
+			print_symbol("address_space_operations %s missing invalidatepage method. Use block_invalidatepage.\n", (unsigned long)page->mapping->a_ops);
+		}
 		invalidatepage = block_invalidatepage;
+	}
 #endif
 	if (invalidatepage)
 		(*invalidatepage)(page, offset);
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c
+++ linux-2.6/fs/inode.c
@@ -25,6 +25,7 @@
 #include <linux/mount.h>
 #include <linux/async.h>
 #include <linux/posix_acl.h>
+#include <linux/kallsyms.h>
 
 /*
  * This is needed for the following functions:
@@ -311,8 +312,14 @@ void clear_inode(struct inode *inode)
 
 	might_sleep();
 	/* XXX: filesystems should invalidate this before calling */
-	if (!mapping->a_ops->release)
+	if (!mapping->a_ops->release) {
+		static bool warned = false;
+		if (!warned) {
+			warned = true;
+			print_symbol("address_space_operations %s missing release method. Use invalidate_inode_buffers.\n", (unsigned long)mapping->a_ops);
+		}
 		invalidate_inode_buffers(inode);
+	}
 
 	BUG_ON(mapping_has_private(mapping));
 	BUG_ON(mapping->nrpages);
@@ -393,9 +400,14 @@ static int invalidate_list(struct list_h
 		if (inode->i_state & I_NEW)
 			continue;
 		mapping = &inode->i_data;
-		if (!mapping->a_ops->release)
+		if (!mapping->a_ops->release) {
+			static bool warned = false;
+			if (!warned) {
+				warned = true;
+				print_symbol("address_space_operations %s missing release method. Using invalidate_inode_buffers.\n", (unsigned long)mapping->a_ops);
+			}
 			invalidate_inode_buffers(inode);
-		else
+		} else
 			mapping->a_ops->release(mapping, AOP_RELEASE_FORCE);
 		BUG_ON(mapping_has_private(mapping));
 		if (!atomic_read(&inode->i_count)) {
@@ -497,8 +509,14 @@ static void prune_icache(int nr_to_scan)
 			spin_unlock(&inode_lock);
 			if (mapping->a_ops->release)
 				ret = mapping->a_ops->release(mapping, 0);
-			else
+			else {
+				static bool warned = false;
+				if (!warned) {
+					warned = true;
+					print_symbol("address_space_operations %s missing release method. Using remove_inode_buffers.\n", (unsigned long)mapping->a_ops);
+				}
 				ret = !remove_inode_buffers(inode);
+			}
 			if (ret)
 				reap += invalidate_mapping_pages(&inode->i_data,
 								0, -1);
Index: linux-2.6/fs/libfs.c
===================================================================
--- linux-2.6.orig/fs/libfs.c
+++ linux-2.6/fs/libfs.c
@@ -11,6 +11,7 @@
 #include <linux/exportfs.h>
 #include <linux/writeback.h>
 #include <linux/buffer_head.h>
+#include <linux/kallsyms.h>
 
 #include <asm/uaccess.h>
 
@@ -827,9 +828,14 @@ int simple_fsync(struct file *file, stru
 	int err;
 	int ret;
 
-	if (!mapping->a_ops->sync)
+	if (!mapping->a_ops->sync) {
+		static bool warned = false;
+		if (!warned) {
+			warned = true;
+			print_symbol("address_space_operations %s missing sync method. Using sync_mapping_buffers.\n", (unsigned long)mapping->a_ops);
+		}
 		ret = sync_mapping_buffers(mapping);
-	else
+	} else
 		ret = mapping->a_ops->sync(mapping, AOP_SYNC_WRITE|AOP_SYNC_WAIT);
 
 	if (!(inode->i_state & I_DIRTY))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
