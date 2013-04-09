Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 5F5086B003B
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 05:14:47 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH v3 05/18] xfs: use ->invalidatepage() length argument
Date: Tue,  9 Apr 2013 11:14:14 +0200
Message-Id: <1365498867-27782-6-git-send-email-lczerner@redhat.com>
In-Reply-To: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Lukas Czerner <lczerner@redhat.com>, xfs@oss.sgi.com

->invalidatepage() aop now accepts range to invalidate so we can make
use of it in xfs_vm_invalidatepage()

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
Cc: xfs@oss.sgi.com
---
 fs/xfs/xfs_aops.c  |    5 +++--
 fs/xfs/xfs_trace.h |   41 ++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index e426796..e8018d3 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -826,8 +826,9 @@ xfs_vm_invalidatepage(
 	unsigned int		offset,
 	unsigned int		length)
 {
-	trace_xfs_invalidatepage(page->mapping->host, page, offset);
-	block_invalidatepage(page, offset, PAGE_CACHE_SIZE - offset);
+	trace_xfs_invalidatepage(page->mapping->host, page, offset,
+				 length);
+	block_invalidatepage(page, offset, length);
 }
 
 /*
diff --git a/fs/xfs/xfs_trace.h b/fs/xfs/xfs_trace.h
index 16a8129..91d6434 100644
--- a/fs/xfs/xfs_trace.h
+++ b/fs/xfs/xfs_trace.h
@@ -991,7 +991,46 @@ DEFINE_EVENT(xfs_page_class, name,	\
 	TP_ARGS(inode, page, off))
 DEFINE_PAGE_EVENT(xfs_writepage);
 DEFINE_PAGE_EVENT(xfs_releasepage);
-DEFINE_PAGE_EVENT(xfs_invalidatepage);
+
+TRACE_EVENT(xfs_invalidatepage,
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
