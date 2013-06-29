Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id ABB026B005C
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:46:20 -0400 (EDT)
Subject: [PATCH 12/16] fuse: fuse_writepage_locked() should wait on writeback
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:46:07 +0400
Message-ID: <20130629174552.20175.47375.stgit@maximpc.sw.ru>
In-Reply-To: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

fuse_writepage_locked() should never submit new i/o for given page->index
if there is another one 'in progress' already. In most cases it's safe to
wait on page writeback. But if it was called due to memory shortage
(WB_SYNC_NONE), we should redirty page rather than blocking caller.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/file.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 89b08d6..f48f796 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1595,7 +1595,8 @@ static struct fuse_file *fuse_write_file(struct fuse_conn *fc,
 	return ff;
 }
 
-static int fuse_writepage_locked(struct page *page)
+static int fuse_writepage_locked(struct page *page,
+				 struct writeback_control *wbc)
 {
 	struct address_space *mapping = page->mapping;
 	struct inode *inode = mapping->host;
@@ -1604,6 +1605,14 @@ static int fuse_writepage_locked(struct page *page)
 	struct fuse_req *req;
 	struct page *tmp_page;
 
+	if (fuse_page_is_writeback(inode, page->index)) {
+		if (wbc->sync_mode != WB_SYNC_ALL) {
+			redirty_page_for_writepage(wbc, page);
+			return 0;
+		}
+		fuse_wait_on_page_writeback(inode, page->index);
+	}
+
 	set_page_writeback(page);
 
 	req = fuse_request_alloc_nofs(1);
@@ -1651,7 +1660,7 @@ static int fuse_writepage(struct page *page, struct writeback_control *wbc)
 {
 	int err;
 
-	err = fuse_writepage_locked(page);
+	err = fuse_writepage_locked(page, wbc);
 	unlock_page(page);
 
 	return err;
@@ -1926,7 +1935,10 @@ static int fuse_launder_page(struct page *page)
 	int err = 0;
 	if (clear_page_dirty_for_io(page)) {
 		struct inode *inode = page->mapping->host;
-		err = fuse_writepage_locked(page);
+		struct writeback_control wbc = {
+			.sync_mode = WB_SYNC_ALL,
+		};
+		err = fuse_writepage_locked(page, &wbc);
 		if (!err)
 			fuse_wait_on_page_writeback(inode, page->index);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
