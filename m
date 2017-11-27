Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5B726B025F
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:24:58 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id z14so13560461wrb.12
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 23:24:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s44si287869edm.230.2017.11.26.23.24.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Nov 2017 23:24:57 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAR7Ob5U098388
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:24:56 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2egawdg3v5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:24:55 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 27 Nov 2017 07:19:53 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v4 1/4] fs/splice: introduce pages_to_pipe helper
Date: Mon, 27 Nov 2017 09:19:38 +0200
In-Reply-To: <1511767181-22793-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1511767181-22793-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1511767181-22793-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/splice.c | 57 ++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 36 insertions(+), 21 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 39e2dc0..7f1ffc5 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1185,6 +1185,36 @@ static long do_splice(struct file *in, loff_t __user *off_in,
 	return -EINVAL;
 }
 
+static int pages_to_pipe(struct page **pages, struct pipe_inode_info *pipe,
+			 struct pipe_buffer *buf, size_t *total,
+			 ssize_t copied, size_t start)
+{
+	bool failed = false;
+	size_t len = 0;
+	int ret = 0;
+	int n;
+
+	for (n = 0; copied; n++, start = 0) {
+		int size = min_t(int, copied, PAGE_SIZE - start);
+		if (!failed) {
+			buf->page = pages[n];
+			buf->offset = start;
+			buf->len = size;
+			ret = add_to_pipe(pipe, buf);
+			if (unlikely(ret < 0))
+				failed = true;
+			else
+				len += ret;
+		} else {
+			put_page(pages[n]);
+		}
+		copied -= size;
+	}
+
+	*total += len;
+	return failed ? ret : len;
+}
+
 static int iter_to_pipe(struct iov_iter *from,
 			struct pipe_inode_info *pipe,
 			unsigned flags)
@@ -1195,13 +1225,11 @@ static int iter_to_pipe(struct iov_iter *from,
 	};
 	size_t total = 0;
 	int ret = 0;
-	bool failed = false;
 
-	while (iov_iter_count(from) && !failed) {
+	while (iov_iter_count(from)) {
 		struct page *pages[16];
 		ssize_t copied;
 		size_t start;
-		int n;
 
 		copied = iov_iter_get_pages(from, pages, ~0UL, 16, &start);
 		if (copied <= 0) {
@@ -1209,24 +1237,11 @@ static int iter_to_pipe(struct iov_iter *from,
 			break;
 		}
 
-		for (n = 0; copied; n++, start = 0) {
-			int size = min_t(int, copied, PAGE_SIZE - start);
-			if (!failed) {
-				buf.page = pages[n];
-				buf.offset = start;
-				buf.len = size;
-				ret = add_to_pipe(pipe, &buf);
-				if (unlikely(ret < 0)) {
-					failed = true;
-				} else {
-					iov_iter_advance(from, ret);
-					total += ret;
-				}
-			} else {
-				put_page(pages[n]);
-			}
-			copied -= size;
-		}
+		ret = pages_to_pipe(pages, pipe, &buf, &total, copied, start);
+		if (unlikely(ret < 0))
+			break;
+
+		iov_iter_advance(from, ret);
 	}
 	return total ? total : ret;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
