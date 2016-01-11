Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:06:32 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 01/13] signals: distinguish signals sent due to i/o via io_send_sig()
Message-ID: <c5b68b85f0bc7ffe78d13457fd16b4a51dc72e65.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

In preparation for thread based aio support, make the callers of
send_sig() that are sending a signal as a direct consequence of a
read or write operation (typically for SIGPIPE or SIGXFS) use a
separate helper of io_send_sig().  This will make it possible for
the thread based aio operations to direct these signals to the
process that actually submitted the aio request.

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 drivers/gpu/drm/drm_lock.c     |  2 +-
 drivers/gpu/drm/ttm/ttm_lock.c |  6 +++---
 fs/attr.c                      |  2 +-
 fs/binfmt_flat.c               |  2 +-
 fs/fuse/dev.c                  |  2 +-
 fs/pipe.c                      |  4 ++--
 fs/splice.c                    |  8 ++++----
 include/linux/sched.h          |  1 +
 kernel/auditsc.c               |  6 +++---
 kernel/signal.c                | 14 ++++++++++++++
 mm/filemap.c                   |  6 ++++--
 net/atm/common.c               |  4 ++--
 net/ax25/af_ax25.c             |  2 +-
 net/caif/caif_socket.c         |  2 +-
 net/core/stream.c              |  2 +-
 net/decnet/af_decnet.c         |  2 +-
 net/irda/af_irda.c             |  4 ++--
 net/netrom/af_netrom.c         |  2 +-
 net/rose/af_rose.c             |  2 +-
 net/sctp/socket.c              |  2 +-
 net/unix/af_unix.c             |  4 ++--
 net/x25/af_x25.c               |  2 +-
 22 files changed, 49 insertions(+), 32 deletions(-)

diff --git a/drivers/gpu/drm/drm_lock.c b/drivers/gpu/drm/drm_lock.c
index daa2ff1..3565563 100644
--- a/drivers/gpu/drm/drm_lock.c
+++ b/drivers/gpu/drm/drm_lock.c
@@ -83,7 +83,7 @@ int drm_legacy_lock(struct drm_device *dev, void *data,
 		__set_current_state(TASK_INTERRUPTIBLE);
 		if (!master->lock.hw_lock) {
 			/* Device has been unregistered */
-			send_sig(SIGTERM, current, 0);
+			io_send_sig(SIGTERM);
 			ret = -EINTR;
 			break;
 		}
diff --git a/drivers/gpu/drm/ttm/ttm_lock.c b/drivers/gpu/drm/ttm/ttm_lock.c
index f154fb1..816be91 100644
--- a/drivers/gpu/drm/ttm/ttm_lock.c
+++ b/drivers/gpu/drm/ttm/ttm_lock.c
@@ -68,7 +68,7 @@ static bool __ttm_read_lock(struct ttm_lock *lock)
 
 	spin_lock(&lock->lock);
 	if (unlikely(lock->kill_takers)) {
-		send_sig(lock->signal, current, 0);
+		io_send_sig(lock->signal);
 		spin_unlock(&lock->lock);
 		return false;
 	}
@@ -101,7 +101,7 @@ static bool __ttm_read_trylock(struct ttm_lock *lock, bool *locked)
 
 	spin_lock(&lock->lock);
 	if (unlikely(lock->kill_takers)) {
-		send_sig(lock->signal, current, 0);
+		io_send_sig(lock->signal);
 		spin_unlock(&lock->lock);
 		return false;
 	}
@@ -151,7 +151,7 @@ static bool __ttm_write_lock(struct ttm_lock *lock)
 
 	spin_lock(&lock->lock);
 	if (unlikely(lock->kill_takers)) {
-		send_sig(lock->signal, current, 0);
+		io_send_sig(lock->signal);
 		spin_unlock(&lock->lock);
 		return false;
 	}
diff --git a/fs/attr.c b/fs/attr.c
index 6530ced..0c63049 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -118,7 +118,7 @@ int inode_newsize_ok(const struct inode *inode, loff_t offset)
 
 	return 0;
 out_sig:
-	send_sig(SIGXFSZ, current, 0);
+	io_send_sig(SIGXFSZ);
 out_big:
 	return -EFBIG;
 }
diff --git a/fs/binfmt_flat.c b/fs/binfmt_flat.c
index f723cd3..51cf839 100644
--- a/fs/binfmt_flat.c
+++ b/fs/binfmt_flat.c
@@ -373,7 +373,7 @@ calc_reloc(unsigned long r, struct lib_info *p, int curid, int internalp)
 
 failed:
 	printk(", killing %s!\n", current->comm);
-	send_sig(SIGSEGV, current, 0);
+	io_send_sig(SIGSEGV);
 
 	return RELOC_FAILED;
 }
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index ebb5e37..20ffc52 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -1391,7 +1391,7 @@ static ssize_t fuse_dev_splice_read(struct file *in, loff_t *ppos,
 	pipe_lock(pipe);
 
 	if (!pipe->readers) {
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 		if (!ret)
 			ret = -EPIPE;
 		goto out_unlock;
diff --git a/fs/pipe.c b/fs/pipe.c
index 42cf8dd..e55ed9a 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -351,7 +351,7 @@ pipe_write(struct kiocb *iocb, struct iov_iter *from)
 	__pipe_lock(pipe);
 
 	if (!pipe->readers) {
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 		ret = -EPIPE;
 		goto out;
 	}
@@ -386,7 +386,7 @@ pipe_write(struct kiocb *iocb, struct iov_iter *from)
 		int bufs;
 
 		if (!pipe->readers) {
-			send_sig(SIGPIPE, current, 0);
+			io_send_sig(SIGPIPE);
 			if (!ret)
 				ret = -EPIPE;
 			break;
diff --git a/fs/splice.c b/fs/splice.c
index 4cf700d..336db78 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -193,7 +193,7 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 
 	for (;;) {
 		if (!pipe->readers) {
-			send_sig(SIGPIPE, current, 0);
+			io_send_sig(SIGPIPE);
 			if (!ret)
 				ret = -EPIPE;
 			break;
@@ -1769,7 +1769,7 @@ static int opipe_prep(struct pipe_inode_info *pipe, unsigned int flags)
 
 	while (pipe->nrbufs >= pipe->buffers) {
 		if (!pipe->readers) {
-			send_sig(SIGPIPE, current, 0);
+			io_send_sig(SIGPIPE);
 			ret = -EPIPE;
 			break;
 		}
@@ -1820,7 +1820,7 @@ retry:
 
 	do {
 		if (!opipe->readers) {
-			send_sig(SIGPIPE, current, 0);
+			io_send_sig(SIGPIPE);
 			if (!ret)
 				ret = -EPIPE;
 			break;
@@ -1924,7 +1924,7 @@ static int link_pipe(struct pipe_inode_info *ipipe,
 
 	do {
 		if (!opipe->readers) {
-			send_sig(SIGPIPE, current, 0);
+			io_send_sig(SIGPIPE);
 			if (!ret)
 				ret = -EPIPE;
 			break;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index edad7a4..6376d58 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2502,6 +2502,7 @@ extern __must_check bool do_notify_parent(struct task_struct *, int);
 extern void __wake_up_parent(struct task_struct *p, struct task_struct *parent);
 extern void force_sig(int, struct task_struct *);
 extern int send_sig(int, struct task_struct *, int);
+extern int io_send_sig(int signal);
 extern int zap_other_threads(struct task_struct *p);
 extern struct sigqueue *sigqueue_alloc(void);
 extern void sigqueue_free(struct sigqueue *);
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index b86cc04..8b4a3ea 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1025,7 +1025,7 @@ static int audit_log_single_execve_arg(struct audit_context *context,
 	 * any.
 	 */
 	if (WARN_ON_ONCE(len < 0 || len > MAX_ARG_STRLEN - 1)) {
-		send_sig(SIGKILL, current, 0);
+		io_send_sig(SIGKILL);
 		return -1;
 	}
 
@@ -1043,7 +1043,7 @@ static int audit_log_single_execve_arg(struct audit_context *context,
 		 */
 		if (ret) {
 			WARN_ON(1);
-			send_sig(SIGKILL, current, 0);
+			io_send_sig(SIGKILL);
 			return -1;
 		}
 		buf[to_send] = '\0';
@@ -1107,7 +1107,7 @@ static int audit_log_single_execve_arg(struct audit_context *context,
 			ret = 0;
 		if (ret) {
 			WARN_ON(1);
-			send_sig(SIGKILL, current, 0);
+			io_send_sig(SIGKILL);
 			return -1;
 		}
 		buf[to_send] = '\0';
diff --git a/kernel/signal.c b/kernel/signal.c
index f3f1f7a..7c14cb4 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1422,6 +1422,20 @@ int send_sig_info(int sig, struct siginfo *info, struct task_struct *p)
 	return do_send_sig_info(sig, info, p, false);
 }
 
+/* io_send_sig: send a signal caused by an i/o operation
+ *
+ * Use this helper when a signal is being sent to the task that is responsible
+ * for aer initiated operation.  Most commonly this is used to send signals
+ * like SIGPIPE or SIGXFS that are the result of attempting a read or write
+ * operation.  This is used by aio to direct a signal to the correct task in
+ * the case of async operations.
+ */
+int io_send_sig(int sig)
+{
+	return send_sig(sig, current, 0);
+}
+EXPORT_SYMBOL(io_send_sig);
+
 #define __si_special(priv) \
 	((priv) ? SEND_SIG_PRIV : SEND_SIG_NOINFO)
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 1bb0076..089ccd85 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2343,7 +2343,7 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 
 	if (limit != RLIM_INFINITY) {
 		if (iocb->ki_pos >= limit) {
-			send_sig(SIGXFSZ, current, 0);
+			io_send_sig(SIGXFSZ);
 			return -EFBIG;
 		}
 		iov_iter_truncate(from, limit - (unsigned long)pos);
@@ -2354,8 +2354,10 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 	 */
 	if (unlikely(pos + iov_iter_count(from) > MAX_NON_LFS &&
 				!(file->f_flags & O_LARGEFILE))) {
-		if (pos >= MAX_NON_LFS)
+		if (pos >= MAX_NON_LFS) {
+			io_send_sig(SIGXFSZ);
 			return -EFBIG;
+		}
 		iov_iter_truncate(from, MAX_NON_LFS - (unsigned long)pos);
 	}
 
diff --git a/net/atm/common.c b/net/atm/common.c
index 49a872d..3eef736 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -591,7 +591,7 @@ int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t size)
 	    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
 	    !test_bit(ATM_VF_READY, &vcc->flags)) {
 		error = -EPIPE;
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 		goto out;
 	}
 	if (!size) {
@@ -620,7 +620,7 @@ int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t size)
 		    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
 		    !test_bit(ATM_VF_READY, &vcc->flags)) {
 			error = -EPIPE;
-			send_sig(SIGPIPE, current, 0);
+			io_send_sig(SIGPIPE);
 			break;
 		}
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index fbd0acf..8dfd84c 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1457,7 +1457,7 @@ static int ax25_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	}
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 		err = -EPIPE;
 		goto out;
 	}
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index aa209b1..ba8d8e2 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -663,7 +663,7 @@ static int caif_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 
 pipe_err:
 	if (sent == 0 && !(msg->msg_flags&MSG_NOSIGNAL))
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 	err = -EPIPE;
 out_err:
 	return sent ? : err;
diff --git a/net/core/stream.c b/net/core/stream.c
index b96f7a7..6b24f6d 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -182,7 +182,7 @@ int sk_stream_error(struct sock *sk, int flags, int err)
 	if (err == -EPIPE)
 		err = sock_error(sk) ? : -EPIPE;
 	if (err == -EPIPE && !(flags & MSG_NOSIGNAL))
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 	return err;
 }
 EXPORT_SYMBOL(sk_stream_error);
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 13d6b1a..47ca404 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1954,7 +1954,7 @@ static int dn_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
 		err = -EPIPE;
 		if (!(flags & MSG_NOSIGNAL))
-			send_sig(SIGPIPE, current, 0);
+			io_send_sig(SIGPIPE);
 		goto out_err;
 	}
 
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 923abd6..f9c6b55 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1539,7 +1539,7 @@ static int irda_sendmsg_dgram(struct socket *sock, struct msghdr *msg,
 	lock_sock(sk);
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 		err = -EPIPE;
 		goto out;
 	}
@@ -1622,7 +1622,7 @@ static int irda_sendmsg_ultra(struct socket *sock, struct msghdr *msg,
 
 	err = -EPIPE;
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 		goto out;
 	}
 
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index ed212ff..b5eaecc 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1044,7 +1044,7 @@ static int nr_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	}
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 		err = -EPIPE;
 		goto out;
 	}
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 129d357..954725c 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1065,7 +1065,7 @@ static int rose_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 		return -EADDRNOTAVAIL;
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 		return -EPIPE;
 	}
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ef1d90f..75bb437 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1556,7 +1556,7 @@ static int sctp_error(struct sock *sk, int flags, int err)
 	if (err == -EPIPE)
 		err = sock_error(sk) ? : -EPIPE;
 	if (err == -EPIPE && !(flags & MSG_NOSIGNAL))
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 	return err;
 }
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index a4631477..a1d5cf8 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1909,7 +1909,7 @@ pipe_err_free:
 	kfree_skb(skb);
 pipe_err:
 	if (sent == 0 && !(msg->msg_flags&MSG_NOSIGNAL))
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 	err = -EPIPE;
 out_err:
 	scm_destroy(&scm);
@@ -2026,7 +2026,7 @@ err_unlock:
 err:
 	kfree_skb(newskb);
 	if (send_sigpipe && !(flags & MSG_NOSIGNAL))
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 	if (!init_scm)
 		scm_destroy(&scm);
 	return err;
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index a750f33..102dd03 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1103,7 +1103,7 @@ static int x25_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	rc = -EPIPE;
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
-		send_sig(SIGPIPE, current, 0);
+		io_send_sig(SIGPIPE);
 		goto out;
 	}
 
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
