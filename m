Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3C38D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 19:53:13 -0400 (EDT)
From: Vaibhav Nagarnaik <vnagarnaik@google.com>
Subject: [PATCH] trace: Add tracepoints to fs subsystem
Date: Mon, 25 Apr 2011 16:53:04 -0700
Message-Id: <1303775584-13347-1-git-send-email-vnagarnaik@google.com>
In-Reply-To: <1303513209-26436-1-git-send-email-vnagarnaik@google.com>
References: <1303513209-26436-1-git-send-email-vnagarnaik@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Steven Rostedt <rostedt@goodmis.org>
Cc: Michael Rubin <mrubin@google.com>, David Sharp <dhsharp@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jiaying Zhang <jiayingz@google.com>, Vaibhav Nagarnaik <vnagarnaik@google.com>

From: Jiaying Zhang <jiayingz@google.com>

These few fs tracepoints are useful while debugging latency issues in
filesystems and were used specifically for debugging various writeback
subsystem issues. This patch adds entry and exit tracepoints for the
following functions, viz.:
wait_on_buffer
block_write_full_page
mpage_readpages
file_read

Signed-off-by: Vaibhav Nagarnaik <vnagarnaik@google.com>
---
 fs/buffer.c               |   10 +++
 fs/mpage.c                |    3 +
 include/trace/events/fs.h |  162 +++++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c              |    4 +-
 4 files changed, 178 insertions(+), 1 deletions(-)
 create mode 100644 include/trace/events/fs.h

diff --git a/fs/buffer.c b/fs/buffer.c
index a08bb8e..1c118f4 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -42,6 +42,9 @@
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/fs.h>
+
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
 
 #define BH_ENTRY(list) list_entry((list), struct buffer_head, b_assoc_buffers)
@@ -82,7 +85,9 @@ EXPORT_SYMBOL(unlock_buffer);
  */
 void __wait_on_buffer(struct buffer_head * bh)
 {
+	trace_fs_buffer_wait_enter(bh);
 	wait_on_bit(&bh->b_state, BH_Lock, sleep_on_buffer, TASK_UNINTERRUPTIBLE);
+	trace_fs_buffer_wait_exit(bh);
 }
 EXPORT_SYMBOL(__wait_on_buffer);
 
@@ -1647,6 +1652,8 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
 	head = page_buffers(page);
 	bh = head;
 
+	trace_block_write_full_page_enter(inode, block, last_block);
+
 	/*
 	 * Get all the dirty buffers mapped to disk addresses and
 	 * handle any aliases from the underlying blockdev's mapping.
@@ -1736,6 +1743,9 @@ done:
 		 * here on.
 		 */
 	}
+
+	trace_block_write_full_page_exit(inode, nr_underway, err);
+
 	return err;
 
 recover:
diff --git a/fs/mpage.c b/fs/mpage.c
index 0afc809..1c3b8e1 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -28,6 +28,7 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 
+#include <trace/events/fs.h>
 /*
  * I/O completion handler for multipage BIOs.
  *
@@ -373,6 +374,8 @@ mpage_readpages(struct address_space *mapping, struct list_head *pages,
 	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
 		struct page *page = list_entry(pages->prev, struct page, lru);
 
+		if (page_idx == 0)
+			trace_mpage_readpages(page, mapping, nr_pages);
 		prefetchw(&page->flags);
 		list_del(&page->lru);
 		if (!add_to_page_cache_lru(page, mapping,
diff --git a/include/trace/events/fs.h b/include/trace/events/fs.h
new file mode 100644
index 0000000..95f7bc8
--- /dev/null
+++ b/include/trace/events/fs.h
@@ -0,0 +1,162 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM fs
+
+#if !defined(_TRACE_FS_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_FS_H
+
+#include <linux/tracepoint.h>
+
+DECLARE_EVENT_CLASS(fs_buffer_wait,
+
+	TP_PROTO(struct buffer_head *bh),
+
+	TP_ARGS(bh),
+
+	TP_STRUCT__entry(
+		__field(	void *,	bh	)
+	),
+
+	TP_fast_assign(
+		__entry->bh = bh;
+	),
+
+	TP_printk("bh %p", __entry->bh)
+);
+
+DEFINE_EVENT(fs_buffer_wait, fs_buffer_wait_enter,
+
+	TP_PROTO(struct buffer_head *bh),
+
+	TP_ARGS(bh)
+);
+
+DEFINE_EVENT(fs_buffer_wait, fs_buffer_wait_exit,
+
+	TP_PROTO(struct buffer_head *bh),
+
+	TP_ARGS(bh)
+);
+
+TRACE_EVENT(block_write_full_page_enter,
+
+	TP_PROTO(struct inode *inode, sector_t block, sector_t last_block),
+
+	TP_ARGS(inode, block, last_block),
+
+	TP_STRUCT__entry(
+		__field(	dev_t,		dev		)
+		__field(	unsigned long,	ino		)
+		__field(	sector_t,	block		)
+		__field(	sector_t,	last_block	)
+	),
+
+	TP_fast_assign(
+		__entry->dev		= inode->i_sb->s_dev;
+		__entry->ino		= inode->i_ino;
+		__entry->block		= block;
+		__entry->last_block	= last_block;
+	),
+
+	TP_printk("dev %d,%d ino %lu block %lu last block %lu",
+		  MAJOR(__entry->dev), MINOR(__entry->dev),
+		  __entry->ino,
+		  (unsigned long)__entry->block,
+		  (unsigned long)__entry->last_block)
+);
+
+TRACE_EVENT(block_write_full_page_exit,
+
+	TP_PROTO(struct inode *inode, int nr_underway, int err),
+
+	TP_ARGS(inode, nr_underway, err),
+
+	TP_STRUCT__entry(
+		__field(	dev_t,		dev		)
+		__field(	unsigned long,	ino		)
+		__field(	int,		nr_underway	)
+		__field(	int,		err		)
+	),
+
+	TP_fast_assign(
+		__entry->dev		= inode->i_sb->s_dev;
+		__entry->ino		= inode->i_ino;
+		__entry->nr_underway	= nr_underway;
+		__entry->err		= err;
+	),
+
+	TP_printk("dev %d,%d ino %lu nr_underway %d err %d",
+		  MAJOR(__entry->dev), MINOR(__entry->dev),
+		  __entry->ino, __entry->nr_underway, __entry->err)
+);
+
+DECLARE_EVENT_CLASS(file_read,
+	TP_PROTO(struct inode *inode, loff_t pos, size_t len),
+
+	TP_ARGS(inode, pos, len),
+
+	TP_STRUCT__entry(
+		__field(	ino_t,	ino			)
+		__field(	dev_t,	dev			)
+		__field(	loff_t,	pos			)
+		__field(	size_t,	len			)
+	),
+
+	TP_fast_assign(
+		__entry->ino	= inode->i_ino;
+		__entry->dev	= inode->i_sb->s_dev;
+		__entry->pos	= pos;
+		__entry->len	= len;
+	),
+
+	TP_printk("dev %d,%d ino %lu pos %llu len %lu",
+		  MAJOR(__entry->dev), MINOR(__entry->dev),
+		  (unsigned long) __entry->ino,
+		   __entry->pos,  __entry->len)
+);
+
+DEFINE_EVENT(file_read, file_read_enter,
+
+	TP_PROTO(struct inode *inode, loff_t pos, size_t len),
+
+	TP_ARGS(inode, pos, len)
+);
+
+DEFINE_EVENT(file_read, file_read_exit,
+
+	TP_PROTO(struct inode *inode, loff_t pos, size_t len),
+
+	TP_ARGS(inode, pos, len)
+);
+
+TRACE_EVENT(mpage_readpages,
+	TP_PROTO(struct page *page, struct address_space *mapping,
+		 unsigned nr_pages),
+
+	TP_ARGS(page, mapping, nr_pages),
+
+	TP_STRUCT__entry(
+		__field(	pgoff_t, index			)
+		__field(	ino_t,	ino			)
+		__field(	dev_t,	dev			)
+		__field(	unsigned,	nr_pages	)
+
+	),
+
+	TP_fast_assign(
+		__entry->index	= page->index;
+		__entry->ino	= mapping->host->i_ino;
+		__entry->dev	= mapping->host->i_sb->s_dev;
+		__entry->nr_pages	= nr_pages;
+	),
+
+	TP_printk("dev %d,%d ino %lu page_index %lu nr_pages %u",
+		  MAJOR(__entry->dev), MINOR(__entry->dev),
+		  (unsigned long) __entry->ino,
+		  __entry->index, __entry->nr_pages)
+);
+
+#endif /* _TRACE_FS_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
+
diff --git a/mm/filemap.c b/mm/filemap.c
index c641edf..94e549c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -42,7 +42,7 @@
 #include <linux/buffer_head.h> /* for try_to_free_buffers */
 
 #include <asm/mman.h>
-
+#include <trace/events/fs.h>
 /*
  * Shared mappings implemented 30.11.1994. It's not fully working yet,
  * though.
@@ -1054,6 +1054,7 @@ static void do_generic_file_read(struct file *filp, loff_t *ppos,
 	unsigned int prev_offset;
 	int error;
 
+	trace_file_read_enter(inode, *ppos, desc->count);
 	index = *ppos >> PAGE_CACHE_SHIFT;
 	prev_index = ra->prev_pos >> PAGE_CACHE_SHIFT;
 	prev_offset = ra->prev_pos & (PAGE_CACHE_SIZE-1);
@@ -1254,6 +1255,7 @@ out:
 	ra->prev_pos <<= PAGE_CACHE_SHIFT;
 	ra->prev_pos |= prev_offset;
 
+	trace_file_read_exit(inode, *ppos, desc->written);
 	*ppos = ((loff_t)index << PAGE_CACHE_SHIFT) + offset;
 	file_accessed(filp);
 }
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
