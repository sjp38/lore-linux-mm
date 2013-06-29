Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 9E3C66B003D
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:45:32 -0400 (EDT)
Subject: [PATCH 09/16] fuse: restructure fuse_readpage()
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:45:19 +0400
Message-ID: <20130629174509.20175.7283.stgit@maximpc.sw.ru>
In-Reply-To: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

Move the code filling and sending read request to a separate function. Future
patches will use it for .write_begin -- partial modification of a page
requires reading the page from the storage very similarly to what fuse_readpage
does.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/file.c |   55 +++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 37 insertions(+), 18 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 799bf46..e693e35 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -702,21 +702,14 @@ static void fuse_short_read(struct fuse_req *req, struct inode *inode,
 	}
 }
 
-static int fuse_readpage(struct file *file, struct page *page)
+static int __fuse_readpage(struct file *file, struct page *page, size_t count,
+			   int *err, struct fuse_req **req_pp, u64 *attr_ver_p)
 {
 	struct fuse_io_priv io = { .async = 0, .file = file };
 	struct inode *inode = page->mapping->host;
 	struct fuse_conn *fc = get_fuse_conn(inode);
 	struct fuse_req *req;
 	size_t num_read;
-	loff_t pos = page_offset(page);
-	size_t count = PAGE_CACHE_SIZE;
-	u64 attr_ver;
-	int err;
-
-	err = -EIO;
-	if (is_bad_inode(inode))
-		goto out;
 
 	/*
 	 * Page writeback can extend beyond the lifetime of the
@@ -726,20 +719,45 @@ static int fuse_readpage(struct file *file, struct page *page)
 	fuse_wait_on_page_writeback(inode, page->index);
 
 	req = fuse_get_req(fc, 1);
-	err = PTR_ERR(req);
+	*err = PTR_ERR(req);
 	if (IS_ERR(req))
-		goto out;
+		return 0;
 
-	attr_ver = fuse_get_attr_version(fc);
+	if (attr_ver_p)
+		*attr_ver_p = fuse_get_attr_version(fc);
 
 	req->out.page_zeroing = 1;
 	req->out.argpages = 1;
 	req->num_pages = 1;
 	req->pages[0] = page;
 	req->page_descs[0].length = count;
-	num_read = fuse_send_read(req, &io, pos, count, NULL);
-	err = req->out.h.error;
 
+	num_read = fuse_send_read(req, &io, page_offset(page), count, NULL);
+	*err = req->out.h.error;
+
+	if (*err)
+		fuse_put_request(fc, req);
+	else
+		*req_pp = req;
+
+	return num_read;
+}
+
+static int fuse_readpage(struct file *file, struct page *page)
+{
+	struct inode *inode = page->mapping->host;
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_req *req = NULL;
+	size_t num_read;
+	size_t count = PAGE_CACHE_SIZE;
+	u64 attr_ver = 0;
+	int err;
+
+	err = -EIO;
+	if (is_bad_inode(inode))
+		goto out;
+
+	num_read = __fuse_readpage(file, page, count, &err, &req, &attr_ver);
 	if (!err) {
 		/*
 		 * Short read means EOF.  If file size is larger, truncate it
@@ -749,10 +767,11 @@ static int fuse_readpage(struct file *file, struct page *page)
 
 		SetPageUptodate(page);
 	}
-
-	fuse_put_request(fc, req);
-	fuse_invalidate_attr(inode); /* atime changed */
- out:
+	if (req) {
+		fuse_put_request(fc, req);
+		fuse_invalidate_attr(inode); /* atime changed */
+	}
+out:
 	unlock_page(page);
 	return err;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
