Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:07:06 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 05/13] fs: make do_loop_readv_writev() non-static
Message-ID: <4047629ed53edd8f24f2d7175f02c24184593169.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

The threaded aio helper code needs to be able to call
do_loop_readv_writev() to perform i/o to file_operations that do not have
read_iter or write_iter methods.  Make the prototype for
do_loop_readv_writev() non-static and move it into fs/internal.h

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/internal.h   | 6 ++++++
 fs/read_write.c | 5 +----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/internal.h b/fs/internal.h
index 71859c4d..57b6010 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -16,6 +16,9 @@ struct path;
 struct mount;
 struct shrink_control;
 
+typedef ssize_t (*io_fn_t)(struct file *, char __user *, size_t, loff_t *);
+typedef ssize_t (*iter_fn_t)(struct kiocb *, struct iov_iter *);
+
 /*
  * block_dev.c
  */
@@ -135,6 +138,9 @@ extern long prune_dcache_sb(struct super_block *sb, struct shrink_control *sc);
  * read_write.c
  */
 extern int rw_verify_area(int, struct file *, const loff_t *, size_t);
+extern ssize_t do_loop_readv_writev(struct file *filp, struct iov_iter *iter,
+				    loff_t *ppos, io_fn_t fn);
+
 
 /*
  * pipe.c
diff --git a/fs/read_write.c b/fs/read_write.c
index 819ef3f..36344ff 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -21,9 +21,6 @@
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
 
-typedef ssize_t (*io_fn_t)(struct file *, char __user *, size_t, loff_t *);
-typedef ssize_t (*iter_fn_t)(struct kiocb *, struct iov_iter *);
-
 const struct file_operations generic_ro_fops = {
 	.llseek		= generic_file_llseek,
 	.read_iter	= generic_file_read_iter,
@@ -668,7 +665,7 @@ static ssize_t do_iter_readv_writev(struct file *filp, struct iov_iter *iter,
 }
 
 /* Do it by hand, with file-ops */
-static ssize_t do_loop_readv_writev(struct file *filp, struct iov_iter *iter,
+ssize_t do_loop_readv_writev(struct file *filp, struct iov_iter *iter,
 		loff_t *ppos, io_fn_t fn)
 {
 	ssize_t ret = 0;
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
