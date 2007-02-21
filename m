Message-Id: <20070221144843.433257000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Date: Wed, 21 Feb 2007 15:43:23 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 19/29] netvm: skb processing
Content-Disposition: inline; filename=netvm.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

In order to make sure emergency packets receive all memory needed to proceed
ensure processing of emergency skbs happens under PF_MEMALLOC.

Use the (new) sk_backlog_rcv() wrapper to ensure this for backlog processing.

Skip taps, since those are user-space again.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h |    4 ++++
 net/core/dev.c     |   42 +++++++++++++++++++++++++++++++++++++-----
 net/core/sock.c    |   19 +++++++++++++++++++
 3 files changed, 60 insertions(+), 5 deletions(-)

Index: linux-2.6-git/net/core/dev.c
===================================================================
--- linux-2.6-git.orig/net/core/dev.c	2007-02-14 12:16:03.000000000 +0100
+++ linux-2.6-git/net/core/dev.c	2007-02-14 12:28:33.000000000 +0100
@@ -1767,10 +1767,23 @@ int netif_receive_skb(struct sk_buff *sk
 	struct net_device *orig_dev;
 	int ret = NET_RX_DROP;
 	__be16 type;
+	unsigned long pflags = current->flags;
+
+	/* Emergency skb are special, they should
+	 *  - be delivered to SOCK_VMIO sockets only
+	 *  - stay away from userspace
+	 *  - have bounded memory usage
+	 *
+	 * Use PF_MEMALLOC as a poor mans memory pool - the grouping kind.
+	 * This saves us from propagating the allocation context down to all
+	 * allocation sites.
+	 */
+	if (skb_emergency(skb))
+		current->flags |= PF_MEMALLOC;
 
 	/* if we've gotten here through NAPI, check netpoll */
 	if (skb->dev->poll && netpoll_rx(skb))
-		return NET_RX_DROP;
+		goto out;
 
 	if (!skb->tstamp.off_sec)
 		net_timestamp(skb);
@@ -1781,7 +1794,7 @@ int netif_receive_skb(struct sk_buff *sk
 	orig_dev = skb_bond(skb);
 
 	if (!orig_dev)
-		return NET_RX_DROP;
+		goto out;
 
 	__get_cpu_var(netdev_rx_stat).total++;
 
@@ -1799,6 +1812,9 @@ int netif_receive_skb(struct sk_buff *sk
 	}
 #endif
 
+	if (skb_emergency(skb))
+		goto skip_taps;
+
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (!ptype->dev || ptype->dev == skb->dev) {
 			if (pt_prev)
@@ -1807,6 +1823,7 @@ int netif_receive_skb(struct sk_buff *sk
 		}
 	}
 
+skip_taps:
 #ifdef CONFIG_NET_CLS_ACT
 	if (pt_prev) {
 		ret = deliver_skb(skb, pt_prev, orig_dev);
@@ -1819,15 +1836,27 @@ int netif_receive_skb(struct sk_buff *sk
 
 	if (ret == TC_ACT_SHOT || (ret == TC_ACT_STOLEN)) {
 		kfree_skb(skb);
-		goto out;
+		goto unlock;
 	}
 
 	skb->tc_verd = 0;
 ncls:
 #endif
 
+	if (skb_emergency(skb))
+		switch(skb->protocol) {
+			case __constant_htons(ETH_P_ARP):
+			case __constant_htons(ETH_P_IP):
+			case __constant_htons(ETH_P_IPV6):
+			case __constant_htons(ETH_P_8021Q):
+				break;
+
+			default:
+				goto drop;
+		}
+
 	if (handle_bridge(&skb, &pt_prev, &ret, orig_dev))
-		goto out;
+		goto unlock;
 
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type)&15], list) {
@@ -1842,6 +1871,7 @@ ncls:
 	if (pt_prev) {
 		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 	} else {
+drop:
 		kfree_skb(skb);
 		/* Jamal, now you will not able to escape explaining
 		 * me how you were going to use this. :-)
@@ -1849,8 +1879,10 @@ ncls:
 		ret = NET_RX_DROP;
 	}
 
-out:
+unlock:
 	rcu_read_unlock();
+out:
+	current->flags = pflags;
 	return ret;
 }
 
Index: linux-2.6-git/include/net/sock.h
===================================================================
--- linux-2.6-git.orig/include/net/sock.h	2007-02-14 12:32:03.000000000 +0100
+++ linux-2.6-git/include/net/sock.h	2007-02-14 12:32:37.000000000 +0100
@@ -510,10 +510,14 @@ static inline void sk_add_backlog(struct
 	skb->next = NULL;
 }
 
+#ifndef CONFIG_NETVM
 static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	return sk->sk_backlog_rcv(sk, skb);
 }
+#else
+extern int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb);
+#endif
 
 #define sk_wait_event(__sk, __timeo, __condition)		\
 ({	int rc;							\
Index: linux-2.6-git/net/core/sock.c
===================================================================
--- linux-2.6-git.orig/net/core/sock.c	2007-02-14 12:32:07.000000000 +0100
+++ linux-2.6-git/net/core/sock.c	2007-02-14 12:37:11.000000000 +0100
@@ -332,6 +332,25 @@ int sk_clear_vmio(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sk_clear_vmio);
 
+#ifdef CONFIG_NETVM
+int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	if (skb_emergency(skb)) {
+		int ret;
+		unsigned long pflags = current->flags;
+	       	/* these should have been dropped before queueing */
+		BUG_ON(!sk_has_vmio(sk));
+		current->flags |= PF_MEMALLOC;
+		ret = sk->sk_backlog_rcv(sk, skb);
+		current->flags = pflags;
+		return ret;
+	}
+
+	return sk->sk_backlog_rcv(sk, skb);
+}
+EXPORT_SYMBOL(sk_backlog_rcv);
+#endif
+
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 {
 	struct timeval tv;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
