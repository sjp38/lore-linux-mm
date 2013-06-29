Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 5C5626B0039
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:43:00 -0400 (EDT)
Subject: [PATCH 04/16] fuse: Prepare to handle multiple pages in writeback
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:42:48 +0400
Message-ID: <20130629174238.20175.12369.stgit@maximpc.sw.ru>
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

The .writepages callback will issue writeback requests with more than one
page aboard. Make existing end/check code be aware of this.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/file.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index ea70814..90fb235 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -350,7 +350,8 @@ static bool fuse_page_is_writeback(struct inode *inode, pgoff_t index)
 
 		BUG_ON(req->inode != inode);
 		curr_index = req->misc.write.in.offset >> PAGE_CACHE_SHIFT;
-		if (curr_index == index) {
+		if (curr_index <= index &&
+		    index < curr_index + req->num_pages) {
 			found = true;
 			break;
 		}
@@ -1425,7 +1426,10 @@ static ssize_t fuse_direct_write(struct file *file, const char __user *buf,
 
 static void fuse_writepage_free(struct fuse_conn *fc, struct fuse_req *req)
 {
-	__free_page(req->pages[0]);
+	int i;
+
+	for (i = 0; i < req->num_pages; i++)
+		__free_page(req->pages[i]);
 	fuse_file_put(req->ff, false);
 }
 
@@ -1434,11 +1438,14 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
 	struct inode *inode = req->inode;
 	struct fuse_inode *fi = get_fuse_inode(inode);
 	struct backing_dev_info *bdi = inode->i_mapping->backing_dev_info;
+	int i;
 
 	list_del(&req->writepages_entry);
-	dec_bdi_stat(bdi, BDI_WRITEBACK);
-	dec_zone_page_state(req->pages[0], NR_WRITEBACK_TEMP);
-	bdi_writeout_inc(bdi);
+	for (i = 0; i < req->num_pages; i++) {
+		dec_bdi_stat(bdi, BDI_WRITEBACK);
+		dec_zone_page_state(req->pages[i], NR_WRITEBACK_TEMP);
+		bdi_writeout_inc(bdi);
+	}
 	wake_up(&fi->page_waitq);
 }
 
@@ -1450,14 +1457,15 @@ __acquires(fc->lock)
 	struct fuse_inode *fi = get_fuse_inode(req->inode);
 	loff_t size = i_size_read(req->inode);
 	struct fuse_write_in *inarg = &req->misc.write.in;
+	__u64 data_size = req->num_pages * PAGE_CACHE_SIZE;
 
 	if (!fc->connected)
 		goto out_free;
 
-	if (inarg->offset + PAGE_CACHE_SIZE <= size) {
-		inarg->size = PAGE_CACHE_SIZE;
+	if (inarg->offset + data_size <= size) {
+		inarg->size = data_size;
 	} else if (inarg->offset < size) {
-		inarg->size = size & (PAGE_CACHE_SIZE - 1);
+		inarg->size = size - inarg->offset;
 	} else {
 		/* Got truncated off completely */
 		goto out_free;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
