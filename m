Message-Id: <20070504103204.389358464@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:29 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 38/40] netlink: add SOCK_VMIO support to AF_NETLINK
Content-Disposition: inline; filename=netlink_vmio.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Modify the netlink code so that SOCK_VMIO has the desired effect on the
user-space side of the connection.

Modify sys_{send,recv}msg to use sk->sk_allocation instead of GFP_KERNEL,
this should not change existing behaviour because the default of
sk->sk_allocation is GFP_KERNEL, and no user-space exposed socket would
have it any different at this time.

This change allows the system calls to succeed for SOCK_VMIO sockets 
(who have sk->sk_allocation |= GFP_EMERGENCY) even under extreme memory
pressure.

Since netlink_sendmsg is used to transfer msgs from user- to kernel-space
treat the skb allocation there as a receive allocation.

Also export netlink_lookup, this is needed to locate the kernel side struct
sock object associated with the user-space netlink socket. 

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: David Miller <davem@davemloft.net>
Cc: Mike Christie <michaelc@cs.wisc.edu>
---
 include/linux/netlink.h  |    1 +
 net/compat.c             |    2 +-
 net/netlink/af_netlink.c |   12 +++++++++---
 net/socket.c             |    6 +++---
 4 files changed, 14 insertions(+), 7 deletions(-)

Index: linux-2.6-git/net/netlink/af_netlink.c
===================================================================
--- linux-2.6-git.orig/net/netlink/af_netlink.c
+++ linux-2.6-git/net/netlink/af_netlink.c
@@ -203,7 +203,7 @@ netlink_unlock_table(void)
 		wake_up(&nl_table_wait);
 }
 
-static __inline__ struct sock *netlink_lookup(int protocol, u32 pid)
+struct sock *netlink_lookup(int protocol, u32 pid)
 {
 	struct nl_pid_hash *hash = &nl_table[protocol].hash;
 	struct hlist_head *head;
@@ -1157,7 +1157,7 @@ static int netlink_sendmsg(struct kiocb 
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
 	err = -ENOBUFS;
-	skb = alloc_skb(len, GFP_KERNEL);
+	skb = __alloc_skb(len, GFP_KERNEL, SKB_ALLOC_RX, -1);
 	if (skb==NULL)
 		goto out;
 
@@ -1186,8 +1186,13 @@ static int netlink_sendmsg(struct kiocb 
 	}
 
 	if (dst_group) {
+		gfp_t gfp_mask = sk->sk_allocation;
+
+		if (skb_emergency(skb))
+			gfp_mask |= __GFP_EMERGENCY;
+
 		atomic_inc(&skb->users);
-		netlink_broadcast(sk, skb, dst_pid, dst_group, GFP_KERNEL);
+		netlink_broadcast(sk, skb, dst_pid, dst_group, gfp_mask);
 	}
 	err = netlink_unicast(sk, skb, dst_pid, msg->msg_flags&MSG_DONTWAIT);
 
@@ -1850,6 +1855,7 @@ panic:
 
 core_initcall(netlink_proto_init);
 
+EXPORT_SYMBOL(netlink_lookup);
 EXPORT_SYMBOL(netlink_ack);
 EXPORT_SYMBOL(netlink_run_queue);
 EXPORT_SYMBOL(netlink_broadcast);
Index: linux-2.6-git/net/socket.c
===================================================================
--- linux-2.6-git.orig/net/socket.c
+++ linux-2.6-git/net/socket.c
@@ -1817,7 +1817,7 @@ asmlinkage long sys_sendmsg(int fd, stru
 	err = -ENOMEM;
 	iov_size = msg_sys.msg_iovlen * sizeof(struct iovec);
 	if (msg_sys.msg_iovlen > UIO_FASTIOV) {
-		iov = sock_kmalloc(sock->sk, iov_size, GFP_KERNEL);
+		iov = sock_kmalloc(sock->sk, iov_size, sock->sk->sk_allocation);
 		if (!iov)
 			goto out_put;
 	}
@@ -1846,7 +1846,7 @@ asmlinkage long sys_sendmsg(int fd, stru
 		ctl_len = msg_sys.msg_controllen;
 	} else if (ctl_len) {
 		if (ctl_len > sizeof(ctl)) {
-			ctl_buf = sock_kmalloc(sock->sk, ctl_len, GFP_KERNEL);
+			ctl_buf = sock_kmalloc(sock->sk, ctl_len, sock->sk->sk_allocation);
 			if (ctl_buf == NULL)
 				goto out_freeiov;
 		}
@@ -1922,7 +1922,7 @@ asmlinkage long sys_recvmsg(int fd, stru
 	err = -ENOMEM;
 	iov_size = msg_sys.msg_iovlen * sizeof(struct iovec);
 	if (msg_sys.msg_iovlen > UIO_FASTIOV) {
-		iov = sock_kmalloc(sock->sk, iov_size, GFP_KERNEL);
+		iov = sock_kmalloc(sock->sk, iov_size, sock->sk->sk_allocation);
 		if (!iov)
 			goto out_put;
 	}
Index: linux-2.6-git/include/linux/netlink.h
===================================================================
--- linux-2.6-git.orig/include/linux/netlink.h
+++ linux-2.6-git/include/linux/netlink.h
@@ -157,6 +157,7 @@ struct netlink_skb_parms
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
 
+extern struct sock *netlink_lookup(int protocol, __u32 pid);
 extern struct sock *netlink_kernel_create(int unit, unsigned int groups,
 					  void (*input)(struct sock *sk, int len),
 					  struct mutex *cb_mutex,
Index: linux-2.6-git/net/compat.c
===================================================================
--- linux-2.6-git.orig/net/compat.c
+++ linux-2.6-git/net/compat.c
@@ -169,7 +169,7 @@ int cmsghdr_from_user_compat_to_kern(str
 	 * from the user.
 	 */
 	if (kcmlen > stackbuf_size)
-		kcmsg_base = kcmsg = sock_kmalloc(sk, kcmlen, GFP_KERNEL);
+		kcmsg_base = kcmsg = sock_kmalloc(sk, kcmlen, sk->sk_allocation);
 	if (kcmsg == NULL)
 		return -ENOBUFS;
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
