Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3EB696B006A
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 14:59:24 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH 3/6] inotify: use alloc_file instead of doing it internally
Date: Thu, 03 Dec 2009 14:59:10 -0500
Message-ID: <20091203195909.8925.6864.stgit@paris.rdu.redhat.com>
In-Reply-To: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com>
References: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, eparis@redhat.com, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

inotify basically duplicates everything from alloc-file and init-file.  Use
the generic vfs functions instead.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 fs/notify/inotify/inotify_user.c |   23 +++++++++--------------
 1 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index c40894a..3e03803 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -725,6 +725,7 @@ SYSCALL_DEFINE1(inotify_init1, int, flags)
 	struct fsnotify_group *group;
 	struct user_struct *user;
 	struct file *filp;
+	struct dentry *dentry;
 	int fd, ret;
 
 	/* Check the IN_* constants for consistency.  */
@@ -738,12 +739,6 @@ SYSCALL_DEFINE1(inotify_init1, int, flags)
 	if (fd < 0)
 		return fd;
 
-	filp = get_empty_filp();
-	if (!filp) {
-		ret = -ENFILE;
-		goto out_put_fd;
-	}
-
 	user = get_current_user();
 	if (unlikely(atomic_read(&user->inotify_devs) >=
 			inotify_max_user_instances)) {
@@ -758,11 +753,12 @@ SYSCALL_DEFINE1(inotify_init1, int, flags)
 		goto out_free_uid;
 	}
 
-	filp->f_op = &inotify_fops;
-	filp->f_path.mnt = mntget(inotify_mnt);
-	filp->f_path.dentry = dget(inotify_mnt->mnt_root);
-	filp->f_mapping = filp->f_path.dentry->d_inode->i_mapping;
-	filp->f_mode = FMODE_READ;
+	dentry = dget(inotify_mnt->mnt_root);
+	filp = alloc_file(inotify_mnt, dentry, FMODE_READ, &inotify_fops);
+	if (!filp) {
+		ret = -ENFILE;
+		goto out_dput;
+	}
 	filp->f_flags = O_RDONLY | (flags & O_NONBLOCK);
 	filp->private_data = group;
 
@@ -771,11 +767,10 @@ SYSCALL_DEFINE1(inotify_init1, int, flags)
 	fd_install(fd, filp);
 
 	return fd;
-
+out_dput:
+	dput(dentry);
 out_free_uid:
 	free_uid(user);
-	put_filp(filp);
-out_put_fd:
 	put_unused_fd(fd);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
