Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1139E6B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 11:37:23 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH v2] mm: Fix assertion mapping->nrpages == 0 in end_writeback()
Date: Wed, 15 Jun 2011 17:37:13 +0200
Message-Id: <1308152233-16919-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Miklos Szeredi <mszeredi@suse.cz>, Jay <jinshan.xiong@whamcloud.com>, Jan Kara <jack@suse.cz>, Miklos Szeredi <mszeredi@suse.de>

Under heavy memory and filesystem load, users observe the assertion
mapping->nrpages == 0 in end_writeback() trigger. This can be caused
by page reclaim reclaiming the last page from a mapping in the following
race:
	CPU0				CPU1
  ...
  shrink_page_list()
    __remove_mapping()
      __delete_from_page_cache()
        radix_tree_delete()
					evict_inode()
					  truncate_inode_pages()
					    truncate_inode_pages_range()
					      pagevec_lookup() - finds nothing
					  end_writeback()
					    mapping->nrpages != 0 -> BUG
        page->mapping = NULL
        mapping->nrpages--

Fix the problem by doing a reliable check of mapping->nrpages under
mapping->tree_lock in end_writeback().

Analyzed by Jay <jinshan.xiong@whamcloud.com>, lost in LKML, and dug
out by Miklos Szeredi <mszeredi@suse.de>.

CC: Jay <jinshan.xiong@whamcloud.com>
CC: Miklos Szeredi <mszeredi@suse.de>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/inode.c         |    7 +++++++
 include/linux/fs.h |    1 +
 mm/truncate.c      |    5 +++++
 3 files changed, 13 insertions(+), 0 deletions(-)

  Andrew, does this look better?

diff --git a/fs/inode.c b/fs/inode.c
index 33c963d..1133cb0 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -467,7 +467,14 @@ EXPORT_SYMBOL(remove_inode_hash);
 void end_writeback(struct inode *inode)
 {
 	might_sleep();
+	/*
+	 * We have to cycle tree_lock here because reclaim can be still in the
+	 * process of removing the last page (in __delete_from_page_cache())
+	 * and we must not free mapping under it.
+	 */
+	spin_lock(&inode->i_data.tree_lock);
 	BUG_ON(inode->i_data.nrpages);
+	spin_unlock(&inode->i_data.tree_lock);
 	BUG_ON(!list_empty(&inode->i_data.private_list));
 	BUG_ON(!(inode->i_state & I_FREEING));
 	BUG_ON(inode->i_state & I_CLEAR);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index cdf9495..1a9375b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -636,6 +636,7 @@ struct address_space {
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
 	unsigned int		truncate_count;	/* Cover race condition with truncate */
+	/* protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
diff --git a/mm/truncate.c b/mm/truncate.c
index a956675..499d6ab 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -300,6 +300,11 @@ EXPORT_SYMBOL(truncate_inode_pages_range);
  * @lstart: offset from which to truncate
  *
  * Called under (and serialised by) inode->i_mutex.
+ *
+ * Note: When this function returns, there can be a page in the process of
+ * deletion (inside __delete_from_page_cache()) in the specified range.  Thus
+ * mapping->nrpages can be non-zero when this function returns even after
+ * truncation of the whole mapping.
  */
 void truncate_inode_pages(struct address_space *mapping, loff_t lstart)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
