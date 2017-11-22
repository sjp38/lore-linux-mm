Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B41D6B02AC
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:37:48 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id w10so13815401qtb.4
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 11:37:48 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x189si4357236qke.183.2017.11.22.11.37.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 11:37:47 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAMJZtkv018975
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:37:46 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2edcarawkf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:37:45 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 22 Nov 2017 19:37:43 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v3 1/4] fs/splice: introduce pages_to_pipe helper
Date: Wed, 22 Nov 2017 21:36:28 +0200
In-Reply-To: <1511379391-988-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1511379391-988-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1511379391-988-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

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
