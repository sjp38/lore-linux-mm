Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 05E0760021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:47:50 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH 07/15] fs: move get_empty_filp() deffinition to internal.h
Date: Fri, 04 Dec 2009 15:47:36 -0500
Message-ID: <20091204204736.18286.94011.stgit@paris.rdu.redhat.com>
In-Reply-To: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
References: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, eparis@redhat.com, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

All users outside of fs/ of get_empty_filp() have been removed.  This patch
moves the definition from the include/ directory to internal.h so no new
users crop up and removes the EXPORT_SYMBOL.  I'd love to see open intents
stop using it too, but that's a problem for another day and a smarter
developer!

Signed-off-by: Eric Paris <eparis@redhat.com>
Acked-by: Miklos Szeredi <miklos@szeredi.hu>
---

 fs/file_table.c    |    4 ++--
 fs/internal.h      |    1 +
 fs/namei.c         |    2 ++
 fs/open.c          |    2 ++
 include/linux/fs.h |    1 -
 5 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index 0f9d2f2..629a167 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -24,6 +24,8 @@
 
 #include <asm/atomic.h>
 
+#include "internal.h"
+
 /* sysctl tunables... */
 struct files_stat_struct files_stat = {
 	.max_files = NR_FILE
@@ -147,8 +149,6 @@ fail:
 	return NULL;
 }
 
-EXPORT_SYMBOL(get_empty_filp);
-
 /**
  * init_file - initialize a 'struct file'
  * @file: the already allocated 'struct file' to initialized
diff --git a/fs/internal.h b/fs/internal.h
index 515175b..f67cd14 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -79,6 +79,7 @@ extern void chroot_fs_refs(struct path *, struct path *);
  * file_table.c
  */
 extern void mark_files_ro(struct super_block *);
+extern struct file *get_empty_filp(void);
 
 /*
  * super.c
diff --git a/fs/namei.c b/fs/namei.c
index 87f97ba..d7ecd2f 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -35,6 +35,8 @@
 #include <linux/fs_struct.h>
 #include <asm/uaccess.h>
 
+#include "internal.h"
+
 #define ACC_MODE(x) ("\000\004\002\006"[(x)&O_ACCMODE])
 
 /* [Feb-1997 T. Schoebel-Theuer]
diff --git a/fs/open.c b/fs/open.c
index fa3bf4c..ebb74d4 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -31,6 +31,8 @@
 #include <linux/falloc.h>
 #include <linux/fs_struct.h>
 
+#include "internal.h"
+
 int vfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	int retval = -ENODEV;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c0a3b6c..112d71a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2193,7 +2193,6 @@ static inline void insert_inode_hash(struct inode *inode) {
 	__insert_inode_hash(inode, inode->i_ino);
 }
 
-extern struct file * get_empty_filp(void);
 extern void file_move(struct file *f, struct list_head *list);
 extern void file_kill(struct file *f);
 #ifdef CONFIG_BLOCK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
