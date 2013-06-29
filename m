Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 387EE6B003B
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:45:17 -0400 (EDT)
Subject: [PATCH 08/16] fuse: Flush files on wb close
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:45:04 +0400
Message-ID: <20130629174458.20175.11065.stgit@maximpc.sw.ru>
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

Any write request requires a file handle to report to the userspace. Thus
when we close a file (and free the fuse_file with this info) we have to
flush all the outstanding dirty pages.

filemap_write_and_wait() is enough because every page under fuse writeback
is accounted in ff->count. This delays actual close until all fuse wb is
completed.

In case of "write cache" turned off, the flush is ensured by fuse_vma_close().

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/file.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index f53697c..799bf46 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -291,6 +291,12 @@ static int fuse_open(struct inode *inode, struct file *file)
 
 static int fuse_release(struct inode *inode, struct file *file)
 {
+	struct fuse_conn *fc = get_fuse_conn(inode);
+
+	/* see fuse_vma_close() for !writeback_cache case */
+	if (fc->writeback_cache)
+		filemap_write_and_wait(file->f_mapping);
+
 	if (test_bit(FUSE_I_MTIME_UPDATED,
 		     &get_fuse_inode(inode)->state))
 		fuse_flush_mtime(file, true);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
