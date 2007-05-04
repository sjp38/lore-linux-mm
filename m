Message-Id: <20070504103200.092467721@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:11 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 20/40] netvm: skb processing
Content-Disposition: inline; filename=netvm.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
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
--- linux-2.6-git.orig/net/core/dev.c
+++ linux-2.6-git/net/core/dev.c
@@ -1756,10 +1756,23 @@ int netif_receive_skb(struct sk_buff *sk
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
 
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
@@ -1770,7 +1783,7 @@ int netif_receive_skb(struct sk_buff *sk
 	orig_dev = skb_bond(skb);
 
 	if (!orig_dev)
-		return NET_RX_DROP;
+		goto out;
 
 	__get_cpu_var(netdev_rx_stat).total++;
 
@@ -1789,6 +1802,9 @@ int netif_receive_skb(struct sk_buff *sk
 	}
 #endif
 
+	if (skb_emergency(skb))
+		goto skip_taps;
+
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (!ptype->dev || ptype->dev == skb->dev) {
 			if (pt_prev)
@@ -1797,6 +1813,7 @@ int netif_receive_skb(struct sk_buff *sk
 		}
 	}
 
+skip_taps:
 #ifdef CONFIG_NET_CLS_ACT
 	if (pt_prev) {
 		ret = deliver_skb(skb, pt_prev, orig_dev);
@@ -1809,16 +1826,28 @@ int netif_receive_skb(struct sk_buff *sk
 
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
 	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
 	if (!skb)
-		goto out;
+		goto unlock;
 
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type)&15], list) {
@@ -1833,6 +1862,7 @@ ncls:
 	if (pt_prev) {
 		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 	} else {
+drop:
 		kfree_skb(skb);
 		/* Jamal, now you will not able to escape explaining
 		 * me how you were going to use this. :-)
@@ -1840,8 +1870,10 @@ ncls:
 		ret = NET_RX_DROP;
 	}
 
-out:
+unlock:
 	rcu_read_unlock();
+out:
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 	return ret;
 }
 
Index: linux-2.6-git/include/net/sock.h
===================================================================
--- linux-2.6-git.orig/include/net/sock.h
+++ linux-2.6-git/include/net/sock.h
@@ -527,10 +527,14 @@ static inline void sk_add_backlog(struct
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
--- linux-2.6-git.orig/net/core/sock.c
+++ linux-2.6-git/net/core/sock.c
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
+		tsk_restore_flags(current, pflags, PF_MEMALLOC);
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
