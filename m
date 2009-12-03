Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E647F6B007D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 14:59:32 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH 4/6] networking: rework socket to fd mapping using
	alloc-file
Date: Thu, 03 Dec 2009 14:59:17 -0500
Message-ID: <20091203195917.8925.84203.stgit@paris.rdu.redhat.com>
In-Reply-To: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com>
References: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, eparis@redhat.com, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

Currently the networking code does interesting things allocating its struct
file and file descriptors.  This patch attempts to unify all of that and
simplify the error paths.  It is also a part of my patch series trying to get
rid of init-file and get-empty_filp and friends.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 net/socket.c |  122 +++++++++++++++++++++-------------------------------------
 1 files changed, 45 insertions(+), 77 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 402abb3..41ac0b1 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -355,32 +355,24 @@ static const struct dentry_operations sockfs_dentry_operations = {
  *	but we take care of internal coherence yet.
  */
 
-static int sock_alloc_fd(struct file **filep, int flags)
+static int sock_alloc_fd(struct file **filep, struct socket *sock, int flags)
 {
-	int fd;
-
-	fd = get_unused_fd_flags(flags);
-	if (likely(fd >= 0)) {
-		struct file *file = get_empty_filp();
-
-		*filep = file;
-		if (unlikely(!file)) {
-			put_unused_fd(fd);
-			return -ENFILE;
-		}
-	} else
-		*filep = NULL;
-	return fd;
-}
-
-static int sock_attach_fd(struct socket *sock, struct file *file, int flags)
-{
-	struct dentry *dentry;
+	int fd, rc;
+	struct file *file;
+	struct dentry *dentry = NULL;
 	struct qstr name = { .name = "" };
 
+	fd = get_unused_fd_flags(flags & O_CLOEXEC);
+	if (unlikely(fd < 0)) {
+		rc = fd;
+		goto out_err;
+	}
+
 	dentry = d_alloc(sock_mnt->mnt_sb->s_root, &name);
-	if (unlikely(!dentry))
-		return -ENOMEM;
+	if (unlikely(!dentry)) {
+		rc = -ENOMEM;
+		goto out_err;
+	}
 
 	dentry->d_op = &sockfs_dentry_operations;
 	/*
@@ -391,32 +383,37 @@ static int sock_attach_fd(struct socket *sock, struct file *file, int flags)
 	dentry->d_flags &= ~DCACHE_UNHASHED;
 	d_instantiate(dentry, SOCK_INODE(sock));
 
+	file = alloc_file(sock_mnt, dentry, FMODE_READ | FMODE_WRITE,
+			  &socket_file_ops);
+	if (unlikely(!file)) {
+		rc = -ENFILE;
+		goto out_err;
+	}
+
 	sock->file = file;
-	init_file(file, sock_mnt, dentry, FMODE_READ | FMODE_WRITE,
-		  &socket_file_ops);
 	SOCK_INODE(sock)->i_fop = &socket_file_ops;
 	file->f_flags = O_RDWR | (flags & O_NONBLOCK);
-	file->f_pos = 0;
 	file->private_data = sock;
 
-	return 0;
+	return fd;
+out_err:
+	if (fd >= 0)
+		put_unused_fd(fd);
+	if (dentry)
+		dput(dentry);
+	*filep = NULL;
+	return rc;
 }
 
 int sock_map_fd(struct socket *sock, int flags)
 {
 	struct file *newfile;
-	int fd = sock_alloc_fd(&newfile, flags);
-
-	if (likely(fd >= 0)) {
-		int err = sock_attach_fd(sock, newfile, flags);
+	int fd;
 
-		if (unlikely(err < 0)) {
-			put_filp(newfile);
-			put_unused_fd(fd);
-			return err;
-		}
+	fd = sock_alloc_fd(&newfile, sock, flags);
+	if (likely(fd >= 0))
 		fd_install(fd, newfile);
-	}
+
 	return fd;
 }
 
@@ -1384,35 +1381,22 @@ SYSCALL_DEFINE4(socketpair, int, family, int, type, int, protocol,
 
 	err = sock_create(family, type, protocol, &sock2);
 	if (err < 0)
-		goto out_release_1;
+		goto out_release_sock_1;
 
 	err = sock1->ops->socketpair(sock1, sock2);
 	if (err < 0)
-		goto out_release_both;
+		goto out_release_sock_2;
 
-	fd1 = sock_alloc_fd(&newfile1, flags & O_CLOEXEC);
+	fd1 = sock_alloc_fd(&newfile1, sock1, flags & (O_CLOEXEC | O_NONBLOCK));
 	if (unlikely(fd1 < 0)) {
 		err = fd1;
-		goto out_release_both;
+		goto out_release_sock_2;
 	}
 
-	fd2 = sock_alloc_fd(&newfile2, flags & O_CLOEXEC);
+	fd2 = sock_alloc_fd(&newfile2, sock2, flags & (O_CLOEXEC | O_NONBLOCK));
 	if (unlikely(fd2 < 0)) {
 		err = fd2;
-		put_filp(newfile1);
-		put_unused_fd(fd1);
-		goto out_release_both;
-	}
-
-	err = sock_attach_fd(sock1, newfile1, flags & O_NONBLOCK);
-	if (unlikely(err < 0)) {
-		goto out_fd2;
-	}
-
-	err = sock_attach_fd(sock2, newfile2, flags & O_NONBLOCK);
-	if (unlikely(err < 0)) {
-		fput(newfile1);
-		goto out_fd1;
+		goto out_release_fd_1;
 	}
 
 	audit_fd_pair(fd1, fd2);
@@ -1432,22 +1416,15 @@ SYSCALL_DEFINE4(socketpair, int, family, int, type, int, protocol,
 	sys_close(fd1);
 	return err;
 
-out_release_both:
+out_release_fd_1:
+	fput(newfile1);
+	put_unused_fd(fd1);
+out_release_sock_2:
 	sock_release(sock2);
-out_release_1:
+out_release_sock_1:
 	sock_release(sock1);
 out:
 	return err;
-
-out_fd2:
-	put_filp(newfile1);
-	sock_release(sock1);
-out_fd1:
-	put_filp(newfile2);
-	sock_release(sock2);
-	put_unused_fd(fd1);
-	put_unused_fd(fd2);
-	goto out;
 }
 
 /*
@@ -1551,17 +1528,13 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	 */
 	__module_get(newsock->ops->owner);
 
-	newfd = sock_alloc_fd(&newfile, flags & O_CLOEXEC);
+	newfd = sock_alloc_fd(&newfile, newsock, flags & (O_CLOEXEC | O_NONBLOCK));
 	if (unlikely(newfd < 0)) {
 		err = newfd;
 		sock_release(newsock);
 		goto out_put;
 	}
 
-	err = sock_attach_fd(newsock, newfile, flags & O_NONBLOCK);
-	if (err < 0)
-		goto out_fd_simple;
-
 	err = security_socket_accept(sock, newsock);
 	if (err)
 		goto out_fd;
@@ -1591,11 +1564,6 @@ out_put:
 	fput_light(sock->file, fput_needed);
 out:
 	return err;
-out_fd_simple:
-	sock_release(newsock);
-	put_filp(newfile);
-	put_unused_fd(newfd);
-	goto out_put;
 out_fd:
 	fput(newfile);
 	put_unused_fd(newfd);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
