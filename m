Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 659586B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 10:57:53 -0500 (EST)
Date: Wed, 4 Nov 2009 17:55:02 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv8 1/3] tun: export underlying socket
Message-ID: <20091104155502.GB32673@redhat.com>
References: <cover.1257349249.git.mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1257349249.git.mst@redhat.com>
Sender: owner-linux-mm@kvack.org
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

Tun device looks similar to a packet socket
in that both pass complete frames from/to userspace.

This patch fills in enough fields in the socket underlying tun driver
to support sendmsg/recvmsg operations, and message flags
MSG_TRUNC and MSG_DONTWAIT, and exports access to this socket
to modules.  Regular read/write behaviour is unchanged.

This way, code using raw sockets to inject packets
into a physical device, can support injecting
packets into host network stack almost without modification.

First user of this interface will be vhost virtualization
accelerator.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Acked-by: David S. Miller <davem@davemloft.net>
---

DaveM agreed that this will go in through Rusty's tree together
with vhost patch, because vhost is the first user of the new
interface.

 drivers/net/tun.c      |  101 +++++++++++++++++++++++++++++++++++++++---------
 include/linux/if_tun.h |   14 +++++++
 2 files changed, 96 insertions(+), 19 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4fdfa2a..18f8876 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -144,6 +144,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	err = 0;
 	tfile->tun = tun;
 	tun->tfile = tfile;
+	tun->socket.file = file;
 	dev_hold(tun->dev);
 	sock_hold(tun->socket.sk);
 	atomic_inc(&tfile->count);
@@ -158,6 +159,7 @@ static void __tun_detach(struct tun_struct *tun)
 	/* Detach from net device */
 	netif_tx_lock_bh(tun->dev);
 	tun->tfile = NULL;
+	tun->socket.file = NULL;
 	netif_tx_unlock_bh(tun->dev);
 
 	/* Drop read queue */
@@ -387,7 +389,8 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Notify and wake up reader process */
 	if (tun->flags & TUN_FASYNC)
 		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
-	wake_up_interruptible(&tun->socket.wait);
+	wake_up_interruptible_poll(&tun->socket.wait, POLLIN |
+				   POLLRDNORM | POLLRDBAND);
 	return NETDEV_TX_OK;
 
 drop:
@@ -743,7 +746,7 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 	len = min_t(int, skb->len, len);
 
 	skb_copy_datagram_const_iovec(skb, 0, iv, total, len);
-	total += len;
+	total += skb->len;
 
 	tun->dev->stats.tx_packets++;
 	tun->dev->stats.tx_bytes += len;
@@ -751,34 +754,23 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 	return total;
 }
 
-static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
-			    unsigned long count, loff_t pos)
+static ssize_t tun_do_read(struct tun_struct *tun,
+			   struct kiocb *iocb, const struct iovec *iv,
+			   ssize_t len, int noblock)
 {
-	struct file *file = iocb->ki_filp;
-	struct tun_file *tfile = file->private_data;
-	struct tun_struct *tun = __tun_get(tfile);
 	DECLARE_WAITQUEUE(wait, current);
 	struct sk_buff *skb;
-	ssize_t len, ret = 0;
-
-	if (!tun)
-		return -EBADFD;
+	ssize_t ret = 0;
 
 	DBG(KERN_INFO "%s: tun_chr_read\n", tun->dev->name);
 
-	len = iov_length(iv, count);
-	if (len < 0) {
-		ret = -EINVAL;
-		goto out;
-	}
-
 	add_wait_queue(&tun->socket.wait, &wait);
 	while (len) {
 		current->state = TASK_INTERRUPTIBLE;
 
 		/* Read frames from the queue */
 		if (!(skb=skb_dequeue(&tun->socket.sk->sk_receive_queue))) {
-			if (file->f_flags & O_NONBLOCK) {
+			if (noblock) {
 				ret = -EAGAIN;
 				break;
 			}
@@ -805,6 +797,27 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 	current->state = TASK_RUNNING;
 	remove_wait_queue(&tun->socket.wait, &wait);
 
+	return ret;
+}
+
+static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
+			    unsigned long count, loff_t pos)
+{
+	struct file *file = iocb->ki_filp;
+	struct tun_file *tfile = file->private_data;
+	struct tun_struct *tun = __tun_get(tfile);
+	ssize_t len, ret;
+
+	if (!tun)
+		return -EBADFD;
+	len = iov_length(iv, count);
+	if (len < 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = tun_do_read(tun, iocb, iv, len, file->f_flags & O_NONBLOCK);
+	ret = min_t(ssize_t, ret, len);
 out:
 	tun_put(tun);
 	return ret;
@@ -847,7 +860,8 @@ static void tun_sock_write_space(struct sock *sk)
 		return;
 
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible_sync(sk->sk_sleep);
+		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLOUT |
+						POLLWRNORM | POLLWRBAND);
 
 	tun = container_of(sk, struct tun_sock, sk)->tun;
 	kill_fasync(&tun->fasync, SIGIO, POLL_OUT);
@@ -858,6 +872,37 @@ static void tun_sock_destruct(struct sock *sk)
 	free_netdev(container_of(sk, struct tun_sock, sk)->tun->dev);
 }
 
+static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
+		       struct msghdr *m, size_t total_len)
+{
+	struct tun_struct *tun = container_of(sock, struct tun_struct, socket);
+	return tun_get_user(tun, m->msg_iov, total_len,
+			    m->msg_flags & MSG_DONTWAIT);
+}
+
+static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
+		       struct msghdr *m, size_t total_len,
+		       int flags)
+{
+	struct tun_struct *tun = container_of(sock, struct tun_struct, socket);
+	int ret;
+	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
+		return -EINVAL;
+	ret = tun_do_read(tun, iocb, m->msg_iov, total_len,
+			  flags & MSG_DONTWAIT);
+	if (ret > total_len) {
+		m->msg_flags |= MSG_TRUNC;
+		ret = flags & MSG_TRUNC ? ret : total_len;
+	}
+	return ret;
+}
+
+/* Ops structure to mimic raw sockets with tun */
+static const struct proto_ops tun_socket_ops = {
+	.sendmsg = tun_sendmsg,
+	.recvmsg = tun_recvmsg,
+};
+
 static struct proto tun_proto = {
 	.name		= "tun",
 	.owner		= THIS_MODULE,
@@ -986,6 +1031,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			goto err_free_dev;
 
 		init_waitqueue_head(&tun->socket.wait);
+		tun->socket.ops = &tun_socket_ops;
 		sock_init_data(&tun->socket, sk);
 		sk->sk_write_space = tun_sock_write_space;
 		sk->sk_sndbuf = INT_MAX;
@@ -1489,6 +1535,23 @@ static void tun_cleanup(void)
 	rtnl_link_unregister(&tun_link_ops);
 }
 
+/* Get an underlying socket object from tun file.  Returns error unless file is
+ * attached to a device.  The returned object works like a packet socket, it
+ * can be used for sock_sendmsg/sock_recvmsg.  The caller is responsible for
+ * holding a reference to the file for as long as the socket is in use. */
+struct socket *tun_get_socket(struct file *file)
+{
+	struct tun_struct *tun;
+	if (file->f_op != &tun_fops)
+		return ERR_PTR(-EINVAL);
+	tun = tun_get(file);
+	if (!tun)
+		return ERR_PTR(-EBADFD);
+	tun_put(tun);
+	return &tun->socket;
+}
+EXPORT_SYMBOL_GPL(tun_get_socket);
+
 module_init(tun_init);
 module_exit(tun_cleanup);
 MODULE_DESCRIPTION(DRV_DESCRIPTION);
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 3f5fd52..404abe0 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -86,4 +86,18 @@ struct tun_filter {
 	__u8   addr[0][ETH_ALEN];
 };
 
+#ifdef __KERNEL__
+#if defined(CONFIG_TUN) || defined(CONFIG_TUN_MODULE)
+struct socket *tun_get_socket(struct file *);
+#else
+#include <linux/err.h>
+#include <linux/errno.h>
+struct file;
+struct socket;
+static inline struct socket *tun_get_socket(struct file *f)
+{
+	return ERR_PTR(-EINVAL);
+}
+#endif /* CONFIG_TUN */
+#endif /* __KERNEL__ */
 #endif /* __IF_TUN_H */
-- 
1.6.5.2.143.g8cc62

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
