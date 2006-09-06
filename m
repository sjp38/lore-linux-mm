Message-Id: <20060906133956.264720000@chello.nl>
References: <20060906131630.793619000@chello.nl>>
Date: Wed, 06 Sep 2006 15:16:49 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 19/21] netlink: add SOCK_VMIO support to AF_NETLINK
Content-Disposition: inline; filename=netlink_vmio.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>
List-ID: <linux-mm.kvack.org>

Propagate SOCK_VMIO from kernel socket to userspace sockets.
Allow sys_{send,recv}msg to succeed under memory pressure for
SOCK_VMIO netlink sockets.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Mike Christie <michaelc@cs.wisc.edu>
---
 include/linux/netlink.h  |    1 +
 net/netlink/af_netlink.c |    8 +++++---
 net/socket.c             |    6 +++---
 3 files changed, 9 insertions(+), 6 deletions(-)

Index: linux-2.6/net/netlink/af_netlink.c
===================================================================
--- linux-2.6.orig/net/netlink/af_netlink.c
+++ linux-2.6/net/netlink/af_netlink.c
@@ -199,7 +199,7 @@ netlink_unlock_table(void)
 		wake_up(&nl_table_wait);
 }
 
-static __inline__ struct sock *netlink_lookup(int protocol, u32 pid)
+__inline__ struct sock *netlink_lookup(int protocol, u32 pid)
 {
 	struct nl_pid_hash *hash = &nl_table[protocol].hash;
 	struct hlist_head *head;
@@ -1147,7 +1147,7 @@ static int netlink_sendmsg(struct kiocb 
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
 	err = -ENOBUFS;
-	skb = alloc_skb(len, GFP_KERNEL);
+	skb = __alloc_skb(len, GFP_KERNEL, SKB_ALLOC_RX);
 	if (skb==NULL)
 		goto out;
 
@@ -1178,7 +1178,8 @@ static int netlink_sendmsg(struct kiocb 
 
 	if (dst_group) {
 		atomic_inc(&skb->users);
-		netlink_broadcast(sk, skb, dst_pid, dst_group, GFP_KERNEL);
+		netlink_broadcast(sk, skb, dst_pid, dst_group,
+				sk->sk_allocation);
 	}
 	err = netlink_unicast(sk, skb, dst_pid, msg->msg_flags&MSG_DONTWAIT);
 
@@ -1788,6 +1789,7 @@ panic:
 
 core_initcall(netlink_proto_init);
 
+EXPORT_SYMBOL(netlink_lookup);
 EXPORT_SYMBOL(netlink_ack);
 EXPORT_SYMBOL(netlink_run_queue);
 EXPORT_SYMBOL(netlink_queue_skip);
Index: linux-2.6/net/socket.c
===================================================================
--- linux-2.6.orig/net/socket.c
+++ linux-2.6/net/socket.c
@@ -1790,7 +1790,7 @@ asmlinkage long sys_sendmsg(int fd, stru
 	err = -ENOMEM;
 	iov_size = msg_sys.msg_iovlen * sizeof(struct iovec);
 	if (msg_sys.msg_iovlen > UIO_FASTIOV) {
-		iov = sock_kmalloc(sock->sk, iov_size, GFP_KERNEL);
+		iov = sock_kmalloc(sock->sk, iov_size, sock->sk->sk_allocation);
 		if (!iov)
 			goto out_put;
 	}
@@ -1818,7 +1818,7 @@ asmlinkage long sys_sendmsg(int fd, stru
 	} else if (ctl_len) {
 		if (ctl_len > sizeof(ctl))
 		{
-			ctl_buf = sock_kmalloc(sock->sk, ctl_len, GFP_KERNEL);
+			ctl_buf = sock_kmalloc(sock->sk, ctl_len, sock->sk->sk_allocation);
 			if (ctl_buf == NULL) 
 				goto out_freeiov;
 		}
@@ -1891,7 +1891,7 @@ asmlinkage long sys_recvmsg(int fd, stru
 	err = -ENOMEM;
 	iov_size = msg_sys.msg_iovlen * sizeof(struct iovec);
 	if (msg_sys.msg_iovlen > UIO_FASTIOV) {
-		iov = sock_kmalloc(sock->sk, iov_size, GFP_KERNEL);
+		iov = sock_kmalloc(sock->sk, iov_size, sock->sk->sk_allocation);
 		if (!iov)
 			goto out_put;
 	}
Index: linux-2.6/include/linux/netlink.h
===================================================================
--- linux-2.6.orig/include/linux/netlink.h
+++ linux-2.6/include/linux/netlink.h
@@ -150,6 +150,7 @@ struct netlink_skb_parms
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
 
+extern struct sock *netlink_lookup(int protocol, __u32 pid);
 extern struct sock *netlink_kernel_create(int unit, unsigned int groups, void (*input)(struct sock *sk, int len), struct module *module);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
