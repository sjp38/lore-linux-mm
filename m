Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 33DCF6B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 13:22:08 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcjenn@linux.vnet.ibm.com>;
	Fri, 26 Jul 2013 14:17:17 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 60CF42BB0053
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 03:21:57 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6PH6VjX1573318
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 03:06:31 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6PHLufO029151
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 03:21:56 +1000
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [RFC PATCH 1/2] vmsplice unmap gifted pages for recipient
Date: Thu, 25 Jul 2013 12:21:45 -0500
Message-Id: <1374772906-21511-2-git-send-email-rcj@linux.vnet.ibm.com>
In-Reply-To: <1374772906-21511-1-git-send-email-rcj@linux.vnet.ibm.com>
References: <1374772906-21511-1-git-send-email-rcj@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, Robert Jennings <rcj@linux.vnet.ibm.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <aliguori@us.ibm.com>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>

From: Matt Helsley <matthltc@us.ibm.com>

Introduce use of the unused SPLICE_F_MOVE flag for vmsplice to zap
pages.

When vmsplice is called with flags (SPLICE_F_GIFT | SPLICE_F_MOVE) the
writer's gift'ed pages would be zapped.  This patch supports further work
to move vmsplice'd pages rather than copying them.  That patch has the
restriction that the page must not be mapped by the source for the move,
otherwise it will fall back to copying the page.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Signed-off-by: Matt Helsley <matt.helsley@gmail.com>
Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
---
 fs/splice.c            | 25 ++++++++++++++++++++++++-
 include/linux/splice.h |  1 +
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/fs/splice.c b/fs/splice.c
index 3b7ee65..6aa964f 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -172,6 +172,18 @@ static void wakeup_pipe_readers(struct pipe_inode_info *pipe)
 	kill_fasync(&pipe->fasync_readers, SIGIO, POLL_IN);
 }
 
+static void zap_buf_page(unsigned long useraddr)
+{
+	struct vm_area_struct *vma;
+
+	down_read(&current->mm->mmap_sem);
+	vma = find_vma_intersection(current->mm, useraddr,
+			useraddr + PAGE_SIZE);
+	if (!IS_ERR_OR_NULL(vma))
+		zap_page_range(vma, useraddr, PAGE_SIZE, NULL);
+	up_read(&current->mm->mmap_sem);
+}
+
 /**
  * splice_to_pipe - fill passed data into a pipe
  * @pipe:	pipe to fill
@@ -212,8 +224,16 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 			buf->len = spd->partial[page_nr].len;
 			buf->private = spd->partial[page_nr].private;
 			buf->ops = spd->ops;
-			if (spd->flags & SPLICE_F_GIFT)
+			if (spd->flags & SPLICE_F_GIFT) {
+				unsigned long useraddr =
+						spd->partial[page_nr].useraddr;
+
+				if ((spd->flags & SPLICE_F_MOVE) &&
+				    !buf->offset && (buf->len == PAGE_SIZE))
+					/* Can move page aligned buf */
+					zap_buf_page(useraddr);
 				buf->flags |= PIPE_BUF_FLAG_GIFT;
+			}
 
 			pipe->nrbufs++;
 			page_nr++;
@@ -485,6 +505,7 @@ fill_it:
 
 		spd.partial[page_nr].offset = loff;
 		spd.partial[page_nr].len = this_len;
+		spd.partial[page_nr].useraddr = index << PAGE_CACHE_SHIFT;
 		len -= this_len;
 		loff = 0;
 		spd.nr_pages++;
@@ -656,6 +677,7 @@ ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 		this_len = min_t(size_t, vec[i].iov_len, res);
 		spd.partial[i].offset = 0;
 		spd.partial[i].len = this_len;
+		spd.partial[i].useraddr = (unsigned long)vec[i].iov_base;
 		if (!this_len) {
 			__free_page(spd.pages[i]);
 			spd.pages[i] = NULL;
@@ -1475,6 +1497,7 @@ static int get_iovec_page_array(const struct iovec __user *iov,
 
 			partial[buffers].offset = off;
 			partial[buffers].len = plen;
+			partial[buffers].useraddr = (unsigned long)base;
 
 			off = 0;
 			len -= plen;
diff --git a/include/linux/splice.h b/include/linux/splice.h
index 74575cb..56661e3 100644
--- a/include/linux/splice.h
+++ b/include/linux/splice.h
@@ -44,6 +44,7 @@ struct partial_page {
 	unsigned int offset;
 	unsigned int len;
 	unsigned long private;
+	unsigned long useraddr;
 };
 
 /*
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
