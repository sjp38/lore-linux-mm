Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 1CDF86B0039
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:46:41 -0400 (EDT)
Subject: [PATCH 13/16] fuse: fuse_flush() should wait on writeback
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:46:28 +0400
Message-ID: <20130629174612.20175.15469.stgit@maximpc.sw.ru>
In-Reply-To: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

The aim of .flush fop is to hint file-system that flushing its state or caches
or any other important data to reliable storage would be desirable now.
fuse_flush() passes this hint by sending FUSE_FLUSH request to userspace.
However, dirty pages and pages under writeback may be not visible to userspace
yet if we won't ensure it explicitly.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/file.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index f48f796..86ef60f 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -19,6 +19,7 @@
 #include <linux/falloc.h>
 
 static const struct file_operations fuse_direct_io_file_operations;
+static void fuse_sync_writes(struct inode *inode);
 
 static int fuse_send_open(struct fuse_conn *fc, u64 nodeid, struct file *file,
 			  int opcode, struct fuse_open_out *outargp)
@@ -400,6 +401,14 @@ static int fuse_flush(struct file *file, fl_owner_t id)
 	if (fc->no_flush)
 		return 0;
 
+	err = filemap_write_and_wait(file->f_mapping);
+	if (err)
+		return err;
+
+	mutex_lock(&inode->i_mutex);
+	fuse_sync_writes(inode);
+	mutex_unlock(&inode->i_mutex);
+
 	req = fuse_get_req_nofail_nopages(fc, file);
 	memset(&inarg, 0, sizeof(inarg));
 	inarg.fh = ff->fh;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
