Received: from smtp3.akamai.com (vwall2.sanmateo.corp.akamai.com [172.23.1.72])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j2G1T46O007978
	for <linux-mm@kvack.org>; Tue, 15 Mar 2005 17:29:04 -0800 (PST)
From: pmeda@akamai.com
Date: Tue, 15 Mar 2005 17:37:57 -0800
Message-Id: <200503160137.RAA19604@allur.sanmateo.akamai.com>
Subject: [PATCH] pipe: save one pipe page
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Save one page in pipe writev without incuring additional
cost(just that ampersand operator).

Signed-off-by: Prasanna Meda <pmeda@akamai.com>

--- a/fs/pipe.c Sun Mar 13 11:01:45 2005
+++ b/fs/pipe.c	Sun Mar 13 11:55:00 2005
@@ -224,6 +224,7 @@
 	int do_wakeup;
 	struct iovec *iov = (struct iovec *)_iov;
 	size_t total_len;
+	ssize_t chars;
 
 	total_len = iov_length(iov, nr_segs);
 	/* Null write succeeds. */
@@ -242,24 +243,26 @@
 	}
 
 	/* We try to merge small writes */
-	if (info->nrbufs && total_len < PAGE_SIZE) {
+	chars = total_len & (PAGE_SIZE-1); /* size of the last buffer */
+	if (info->nrbufs && chars != 0) {
 		int lastbuf = (info->curbuf + info->nrbufs - 1) & (PIPE_BUFFERS-1);
 		struct pipe_buffer *buf = info->bufs + lastbuf;
 		struct pipe_buf_operations *ops = buf->ops;
 		int offset = buf->offset + buf->len;
-		if (ops->can_merge && offset + total_len <= PAGE_SIZE) {
+		if (ops->can_merge && offset + chars <= PAGE_SIZE) {
 			void *addr = ops->map(filp, info, buf);
-			int error = pipe_iov_copy_from_user(offset + addr, iov, total_len);
+			int error = pipe_iov_copy_from_user(offset + addr, iov, chars);
 			ops->unmap(info, buf);
 			ret = error;
 			do_wakeup = 1;
 			if (error)
 				goto out;
-			buf->len += total_len;
-			ret = total_len;
-			goto out;
+			buf->len += chars;
+			total_len -= chars;
+			ret = chars;
+			if (!total_len)
+				goto out;
 		}
-			
 	}
 
 	for (;;) {
@@ -271,7 +274,6 @@
 		}
 		bufs = info->nrbufs;
 		if (bufs < PIPE_BUFFERS) {
-			ssize_t chars;
 			int newbuf = (info->curbuf + bufs) & (PIPE_BUFFERS-1);
 			struct pipe_buffer *buf = info->bufs + newbuf;
 			struct page *page = info->tmp_page;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
