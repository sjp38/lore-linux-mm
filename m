Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AC6B66B0223
	for <linux-mm@kvack.org>; Fri,  7 May 2010 13:39:56 -0400 (EDT)
Date: Fri, 7 May 2010 13:39:48 -0400
From: Josef Bacik <josef@redhat.com>
Subject: [PATCH 1/5] fs: allow short direct-io reads to be completed via
	buffered IO V2
Message-ID: <20100507173948.GB3360@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hch@infradead.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

V1->V2: Check to see if our current ppos is >= i_size after a short DIO read,
just in case it was actually a short read and we need to just return.

This is similar to what already happens in the write case.  If we have a short
read while doing O_DIRECT, instead of just returning, fallthrough and try to
read the rest via buffered IO.  BTRFS needs this because if we encounter a
compressed or inline extent during DIO, we need to fallback on buffered.  If the
extent is compressed we need to read the entire thing into memory and
de-compress it into the users pages.  I have tested this with fsx and everything
works great.  I also ran xfstests against xfs and btrfs with this patch and
everything came out as expected.  Thanks,

Signed-off-by: Josef Bacik <josef@redhat.com>
---
 mm/filemap.c |   36 +++++++++++++++++++++++++++++++-----
 1 files changed, 31 insertions(+), 5 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 140ebda..829ac9c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1263,7 +1263,7 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
 {
 	struct file *filp = iocb->ki_filp;
 	ssize_t retval;
-	unsigned long seg;
+	unsigned long seg = 0;
 	size_t count;
 	loff_t *ppos = &iocb->ki_pos;
 
@@ -1290,21 +1290,47 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
 				retval = mapping->a_ops->direct_IO(READ, iocb,
 							iov, pos, nr_segs);
 			}
-			if (retval > 0)
+			if (retval > 0) {
 				*ppos = pos + retval;
-			if (retval) {
+				count -= retval;
+			}
+
+			/*
+			 * Btrfs can have a short DIO read if we encounter
+			 * compressed extents, so if there was an error, or if
+			 * we've already read everything we wanted to, or if
+			 * there was a short read because we hit EOF, go ahead
+			 * and return.  Otherwise fallthrough to buffered io for
+			 * the rest of the read.
+			 */
+			if (retval < 0 || !count || *ppos >= size) {
 				file_accessed(filp);
 				goto out;
 			}
 		}
 	}
 
+	count = retval;
 	for (seg = 0; seg < nr_segs; seg++) {
 		read_descriptor_t desc;
+		loff_t offset = 0;
+
+		/*
+		 * If we did a short DIO read we need to skip the section of the
+		 * iov that we've already read data into.
+		 */
+		if (count) {
+			if (count > iov[seg].iov_len) {
+				count -= iov[seg].iov_len;
+				continue;
+			}
+			offset = count;
+			count = 0;
+		}
 
 		desc.written = 0;
-		desc.arg.buf = iov[seg].iov_base;
-		desc.count = iov[seg].iov_len;
+		desc.arg.buf = iov[seg].iov_base + offset;
+		desc.count = iov[seg].iov_len - offset;
 		if (desc.count == 0)
 			continue;
 		desc.error = 0;
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
