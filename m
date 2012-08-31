Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id BC0D76B0070
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 18:22:14 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH 04/15 v2] xfs: implement invalidatepage_range aop
Date: Fri, 31 Aug 2012 18:21:40 -0400
Message-Id: <1346451711-1931-5-git-send-email-lczerner@redhat.com>
In-Reply-To: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org, Lukas Czerner <lczerner@redhat.com>, xfs@oss.sgi.com

mm now supports invalidatepage_range address space operation which is
useful to allow truncating page range which is not aligned to the end of
the page. This will help in punch hole implementation once
truncate_inode_pages_range() is modify to allow this as well.

With this commit xfs now register only invalidatepage_range.
Additionally we also update the respective trace point.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
Cc: xfs@oss.sgi.com
---
 fs/xfs/xfs_aops.c  |   14 ++++++++------
 fs/xfs/xfs_trace.h |   41 ++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 48 insertions(+), 7 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index e562dd4..c395f9e 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -813,12 +813,14 @@ xfs_cluster_write(
 }
 
 STATIC void
-xfs_vm_invalidatepage(
+xfs_vm_invalidatepage_range(
 	struct page		*page,
-	unsigned long		offset)
+	unsigned int		offset,
+	unsigned int		length)
 {
-	trace_xfs_invalidatepage(page->mapping->host, page, offset);
-	block_invalidatepage(page, offset);
+	trace_xfs_invalidatepage_range(page->mapping->host, page, offset,
+				       length);
+	block_invalidatepage_range(page, offset, length);
 }
 
 /*
@@ -882,7 +884,7 @@ next_buffer:
 
 	xfs_iunlock(ip, XFS_ILOCK_EXCL);
 out_invalidate:
-	xfs_vm_invalidatepage(page, 0);
+	xfs_vm_invalidatepage_range(page, 0, PAGE_CACHE_SIZE);
 	return;
 }
 
@@ -1646,7 +1648,7 @@ const struct address_space_operations xfs_address_space_operations = {
 	.writepage		= xfs_vm_writepage,
 	.writepages		= xfs_vm_writepages,
 	.releasepage		= xfs_vm_releasepage,
-	.invalidatepage		= xfs_vm_invalidatepage,
+	.invalidatepage_range	= xfs_vm_invalidatepage_range,
 	.write_begin		= xfs_vm_write_begin,
 	.write_end		= xfs_vm_write_end,
 	.bmap			= xfs_vm_bmap,
diff --git a/fs/xfs/xfs_trace.h b/fs/xfs/xfs_trace.h
index e5795dd..e716754 100644
--- a/fs/xfs/xfs_trace.h
+++ b/fs/xfs/xfs_trace.h
@@ -981,7 +981,46 @@ DEFINE_EVENT(xfs_page_class, name,	\
 	TP_ARGS(inode, page, off))
 DEFINE_PAGE_EVENT(xfs_writepage);
 DEFINE_PAGE_EVENT(xfs_releasepage);
-DEFINE_PAGE_EVENT(xfs_invalidatepage);
+
+TRACE_EVENT(xfs_invalidatepage_range,
+	TP_PROTO(struct inode *inode, struct page *page, unsigned int off,
+		 unsigned int len),
+	TP_ARGS(inode, page, off, len),
+	TP_STRUCT__entry(
+		__field(dev_t, dev)
+		__field(xfs_ino_t, ino)
+		__field(pgoff_t, pgoff)
+		__field(loff_t, size)
+		__field(unsigned int, offset)
+		__field(unsigned int, length)
+		__field(int, delalloc)
+		__field(int, unwritten)
+	),
+	TP_fast_assign(
+		int delalloc = -1, unwritten = -1;
+
+		if (page_has_buffers(page))
+			xfs_count_page_state(page, &delalloc, &unwritten);
+		__entry->dev = inode->i_sb->s_dev;
+		__entry->ino = XFS_I(inode)->i_ino;
+		__entry->pgoff = page_offset(page);
+		__entry->size = i_size_read(inode);
+		__entry->offset = off;
+		__entry->length = len;
+		__entry->delalloc = delalloc;
+		__entry->unwritten = unwritten;
+	),
+	TP_printk("dev %d:%d ino 0x%llx pgoff 0x%lx size 0x%llx offset %x "
+		  "length %x delalloc %d unwritten %d",
+		  MAJOR(__entry->dev), MINOR(__entry->dev),
+		  __entry->ino,
+		  __entry->pgoff,
+		  __entry->size,
+		  __entry->offset,
+		  __entry->length,
+		  __entry->delalloc,
+		  __entry->unwritten)
+)
 
 DECLARE_EVENT_CLASS(xfs_imap_class,
 	TP_PROTO(struct xfs_inode *ip, xfs_off_t offset, ssize_t count,
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
