Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 4A1596B0038
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:42:46 -0400 (EDT)
Subject: [PATCH 03/16] fuse: Prepare to handle short reads
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:42:33 +0400
Message-ID: <20130629174225.20175.28402.stgit@maximpc.sw.ru>
In-Reply-To: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

From: Pavel Emelyanov <xemul@openvz.org>

A helper which gets called when read reports less bytes than was requested.
See patch #6 (trust kernel i_size only) for details.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 fs/fuse/file.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 6b6d307..ea70814 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -653,6 +653,15 @@ static void fuse_read_update_size(struct inode *inode, loff_t size,
 	spin_unlock(&fc->lock);
 }
 
+static void fuse_short_read(struct fuse_req *req, struct inode *inode,
+			    u64 attr_ver)
+{
+	size_t num_read = req->out.args[0].size;
+
+	loff_t pos = page_offset(req->pages[0]) + num_read;
+	fuse_read_update_size(inode, pos, attr_ver);
+}
+
 static int fuse_readpage(struct file *file, struct page *page)
 {
 	struct fuse_io_priv io = { .async = 0, .file = file };
@@ -690,18 +699,18 @@ static int fuse_readpage(struct file *file, struct page *page)
 	req->page_descs[0].length = count;
 	num_read = fuse_send_read(req, &io, pos, count, NULL);
 	err = req->out.h.error;
-	fuse_put_request(fc, req);
 
 	if (!err) {
 		/*
 		 * Short read means EOF.  If file size is larger, truncate it
 		 */
 		if (num_read < count)
-			fuse_read_update_size(inode, pos + num_read, attr_ver);
+			fuse_short_read(req, inode, attr_ver);
 
 		SetPageUptodate(page);
 	}
 
+	fuse_put_request(fc, req);
 	fuse_invalidate_attr(inode); /* atime changed */
  out:
 	unlock_page(page);
@@ -724,13 +733,9 @@ static void fuse_readpages_end(struct fuse_conn *fc, struct fuse_req *req)
 		/*
 		 * Short read means EOF. If file size is larger, truncate it
 		 */
-		if (!req->out.h.error && num_read < count) {
-			loff_t pos;
+		if (!req->out.h.error && num_read < count)
+			fuse_short_read(req, inode, req->misc.read.attr_ver);
 
-			pos = page_offset(req->pages[0]) + num_read;
-			fuse_read_update_size(inode, pos,
-					      req->misc.read.attr_ver);
-		}
 		fuse_invalidate_attr(inode); /* atime changed */
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
