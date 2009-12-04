Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DE44360021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:47:16 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH 03/15] pipes: use alloc-file instead of duplicating code
Date: Fri, 04 Dec 2009 15:47:04 -0500
Message-ID: <20091204204704.18286.49884.stgit@paris.rdu.redhat.com>
In-Reply-To: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
References: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, eparis@redhat.com, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

The pipe code duplicates the functionality of alloc-file and init-file.  Use
the generic vfs functions instead of duplicating code.

Signed-off-by: Eric Paris <eparis@redhat.com>
Acked-by: Miklos Szeredi <miklos@szeredi.hu>
---

 fs/pipe.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/fs/pipe.c b/fs/pipe.c
index ae17d02..5d6c969 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -1028,20 +1028,17 @@ void free_write_pipe(struct file *f)
 
 struct file *create_read_pipe(struct file *wrf, int flags)
 {
-	struct file *f = get_empty_filp();
-	if (!f)
-		return ERR_PTR(-ENFILE);
-
-	/* Grab pipe from the writer */
-	f->f_path = wrf->f_path;
-	path_get(&wrf->f_path);
-	f->f_mapping = wrf->f_path.dentry->d_inode->i_mapping;
+	struct file *f;
+	struct dentry *dentry = wrf->f_path.dentry;
+	struct vfsmount *mnt = wrf->f_path.mnt;
 
-	f->f_pos = 0;
+	dentry = dget(dentry);
+	f = alloc_file(mnt, dentry, FMODE_READ, &read_pipefifo_fops);
+	if (!f) {
+		dput(dentry);
+		return ERR_PTR(-ENFILE);
+	}
 	f->f_flags = O_RDONLY | (flags & O_NONBLOCK);
-	f->f_op = &read_pipefifo_fops;
-	f->f_mode = FMODE_READ;
-	f->f_version = 0;
 
 	return f;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
