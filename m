Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 88B216B00FF
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:03:08 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/4] mm: vmscan: Take page buffers dirty and locked state into account
Date: Mon, 27 May 2013 14:02:58 +0100
Message-Id: <1369659778-6772-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1369659778-6772-1-git-send-email-mgorman@suse.de>
References: <1369659778-6772-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Page reclaim keeps track of dirty and under writeback pages and uses it to
determine if wait_iff_congested() should stall or if kswapd should begin
writing back pages. This fails to account for buffer pages that can be under
writeback but not PageWriteback which is the case for filesystems like ext3
ordered mode. Furthermore, PageDirty buffer pages can have all the buffers
clean and writepage does no IO so it should not be accounted as congested.

This patch adds an address_space operation that filesystems may
optionally use to check if a page is really dirty or really under
writeback. An implementation is provided for for buffer_heads is added
and used for block operations and ext3 in ordered mode. By default the
page flags are obeyed.

Credit goes to Jan Kara for identifying that the page flags alone are
not sufficient for ext3 and sanity checking a number of ideas on how
the problem could be addressed.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/block_dev.c              |  1 +
 fs/buffer.c                 | 34 ++++++++++++++++++++++++++++++++++
 fs/ext3/inode.c             |  1 +
 include/linux/buffer_head.h |  3 +++
 include/linux/fs.h          |  1 +
 mm/vmscan.c                 |  8 ++++++++
 6 files changed, 48 insertions(+)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 2091db8..9c8ebe4 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -1583,6 +1583,7 @@ static const struct address_space_operations def_blk_aops = {
 	.writepages	= generic_writepages,
 	.releasepage	= blkdev_releasepage,
 	.direct_IO	= blkdev_direct_IO,
+	.is_dirty_writeback = buffer_check_dirty_writeback,
 };
 
 const struct file_operations def_blk_fops = {
diff --git a/fs/buffer.c b/fs/buffer.c
index 1aa0836..4247aa9 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -91,6 +91,40 @@ void unlock_buffer(struct buffer_head *bh)
 EXPORT_SYMBOL(unlock_buffer);
 
 /*
+ * Returns if the page has dirty or writeback buffers. If all the buffers
+ * are unlocked and clean then the PageDirty information is stale. If
+ * any of the pages are locked, it is assumed they are locked for IO.
+ */
+void buffer_check_dirty_writeback(struct page *page,
+				     bool *dirty, bool *writeback)
+{
+	struct buffer_head *head, *bh;
+	*dirty = false;
+	*writeback = false;
+
+	BUG_ON(!PageLocked(page));
+
+	if (!page_has_buffers(page))
+		return;
+
+	if (PageWriteback(page))
+		*writeback = true;
+
+	head = page_buffers(page);
+	bh = head;
+	do {
+		if (buffer_locked(bh))
+			*writeback = true;
+
+		if (buffer_dirty(bh))
+			*dirty = true;
+
+		bh = bh->b_this_page;
+	} while (bh != head);
+}
+EXPORT_SYMBOL(buffer_check_dirty_writeback);
+
+/*
  * Block until a buffer comes unlocked.  This doesn't stop it
  * from becoming locked again - you have to lock it yourself
  * if you want to preserve its state.
diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
index 23c7128..8e590bd 100644
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -1984,6 +1984,7 @@ static const struct address_space_operations ext3_ordered_aops = {
 	.direct_IO		= ext3_direct_IO,
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
+	.is_dirty_writeback	= buffer_check_dirty_writeback,
 	.error_remove_page	= generic_error_remove_page,
 };
 
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 6d9f5a2..d458880 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -139,6 +139,9 @@ BUFFER_FNS(Prio, prio)
 	})
 #define page_has_buffers(page)	PagePrivate(page)
 
+void buffer_check_dirty_writeback(struct page *page,
+				     bool *dirty, bool *writeback);
+
 /*
  * Declarations
  */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 0a9a6766..96f857f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -380,6 +380,7 @@ struct address_space_operations {
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
+	void (*is_dirty_writeback) (struct page *, bool *, bool *);
 	int (*error_remove_page)(struct address_space *, struct page *);
 
 	/* swapfile support */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f576bcc..6237725 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -688,6 +688,14 @@ static void page_check_dirty_writeback(struct page *page,
 	/* By default assume that the page flags are accurate */
 	*dirty = PageDirty(page);
 	*writeback = PageWriteback(page);
+
+	/* Verify dirty/writeback state if the filesystem supports it */
+	if (!page_has_private(page))
+		return;
+
+	mapping = page_mapping(page);
+	if (mapping && mapping->a_ops->is_dirty_writeback)
+		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
 }
 
 /*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
