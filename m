Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 80BBC6B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 17:06:55 -0400 (EDT)
Date: Tue, 23 Apr 2013 16:06:50 -0500
From: Ben Myers <bpm@sgi.com>
Subject: Re: [PATCH v3 05/18] xfs: use ->invalidatepage() length argument
Message-ID: <20130423210650.GA2408@sgi.com>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
 <1365498867-27782-6-git-send-email-lczerner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365498867-27782-6-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, xfs@oss.sgi.com

Hey Lukas,

On Tue, Apr 09, 2013 at 11:14:14AM +0200, Lukas Czerner wrote:
> ->invalidatepage() aop now accepts range to invalidate so we can make
> use of it in xfs_vm_invalidatepage()
> 
> Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> Cc: xfs@oss.sgi.com
> ---
>  fs/xfs/xfs_aops.c  |    5 +++--
>  fs/xfs/xfs_trace.h |   41 ++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 43 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index e426796..e8018d3 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -826,8 +826,9 @@ xfs_vm_invalidatepage(
>  	unsigned int		offset,
>  	unsigned int		length)
>  {
> -	trace_xfs_invalidatepage(page->mapping->host, page, offset);
> -	block_invalidatepage(page, offset, PAGE_CACHE_SIZE - offset);
> +	trace_xfs_invalidatepage(page->mapping->host, page, offset,
> +				 length);
> +	block_invalidatepage(page, offset, length);
>  }
>  
>  /*
> diff --git a/fs/xfs/xfs_trace.h b/fs/xfs/xfs_trace.h
> index 16a8129..91d6434 100644
> --- a/fs/xfs/xfs_trace.h
> +++ b/fs/xfs/xfs_trace.h
> @@ -991,7 +991,46 @@ DEFINE_EVENT(xfs_page_class, name,	\
>  	TP_ARGS(inode, page, off))
>  DEFINE_PAGE_EVENT(xfs_writepage);
>  DEFINE_PAGE_EVENT(xfs_releasepage);
> -DEFINE_PAGE_EVENT(xfs_invalidatepage);

I think it might be better if we continue using the xfs_invalidatepage trace
point as part of the xfs_page_class rather than as a separate trace point, like below.

Else this looks great.

Reviewed-by: Ben Myers <bpm@sgi.com>

Regards,
Ben



Index: xfs/fs/xfs/xfs_aops.c
===================================================================
--- xfs.orig/fs/xfs/xfs_aops.c
+++ xfs/fs/xfs/xfs_aops.c
@@ -825,7 +825,7 @@ xfs_vm_invalidatepage(
 	struct page		*page,
 	unsigned long		offset)
 {
-	trace_xfs_invalidatepage(page->mapping->host, page, offset);
+	trace_xfs_invalidatepage(page->mapping->host, page, offset, 0);
 	block_invalidatepage(page, offset);
 }
 
@@ -920,7 +920,7 @@ xfs_vm_writepage(
 	int			count = 0;
 	int			nonblocking = 0;
 
-	trace_xfs_writepage(inode, page, 0);
+	trace_xfs_writepage(inode, page, 0, 0);
 
 	ASSERT(page_has_buffers(page));
 
@@ -1151,7 +1151,7 @@ xfs_vm_releasepage(
 {
 	int			delalloc, unwritten;
 
-	trace_xfs_releasepage(page->mapping->host, page, 0);
+	trace_xfs_releasepage(page->mapping->host, page, 0, 0);
 
 	xfs_count_page_state(page, &delalloc, &unwritten);
 
Index: xfs/fs/xfs/xfs_trace.h
===================================================================
--- xfs.orig/fs/xfs/xfs_trace.h
+++ xfs/fs/xfs/xfs_trace.h
@@ -974,14 +974,16 @@ DEFINE_RW_EVENT(xfs_file_splice_read);
 DEFINE_RW_EVENT(xfs_file_splice_write);
 
 DECLARE_EVENT_CLASS(xfs_page_class,
-	TP_PROTO(struct inode *inode, struct page *page, unsigned long off),
-	TP_ARGS(inode, page, off),
+	TP_PROTO(struct inode *inode, struct page *page, unsigned long off,
+		 unsigned int len),
+	TP_ARGS(inode, page, off, len),
 	TP_STRUCT__entry(
 		__field(dev_t, dev)
 		__field(xfs_ino_t, ino)
 		__field(pgoff_t, pgoff)
 		__field(loff_t, size)
 		__field(unsigned long, offset)
+		__field(unsigned int, length)
 		__field(int, delalloc)
 		__field(int, unwritten)
 	),
@@ -995,24 +997,27 @@ DECLARE_EVENT_CLASS(xfs_page_class,
 		__entry->pgoff = page_offset(page);
 		__entry->size = i_size_read(inode);
 		__entry->offset = off;
+		__entry->length = len;
 		__entry->delalloc = delalloc;
 		__entry->unwritten = unwritten;
 	),
 	TP_printk("dev %d:%d ino 0x%llx pgoff 0x%lx size 0x%llx offset %lx "
-		  "delalloc %d unwritten %d",
+		  "length %x delalloc %d unwritten %d",
 		  MAJOR(__entry->dev), MINOR(__entry->dev),
 		  __entry->ino,
 		  __entry->pgoff,
 		  __entry->size,
 		  __entry->offset,
+		  __entry->length,
 		  __entry->delalloc,
 		  __entry->unwritten)
 )
 
 #define DEFINE_PAGE_EVENT(name)		\
 DEFINE_EVENT(xfs_page_class, name,	\
-	TP_PROTO(struct inode *inode, struct page *page, unsigned long off),	\
-	TP_ARGS(inode, page, off))
+	TP_PROTO(struct inode *inode, struct page *page, unsigned long off, \
+		 unsigned int len),	\
+	TP_ARGS(inode, page, off, len))
 DEFINE_PAGE_EVENT(xfs_writepage);
 DEFINE_PAGE_EVENT(xfs_releasepage);
 DEFINE_PAGE_EVENT(xfs_invalidatepage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
