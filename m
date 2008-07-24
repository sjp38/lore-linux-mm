Message-Id: <20080724141530.942450703@chello.nl>
References: <20080724140042.408642539@chello.nl>
Date: Thu, 24 Jul 2008 16:01:05 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 23/30] netvm: skb processing
Content-Disposition: inline; filename=netvm.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

In order to make sure emergency packets receive all memory needed to proceed
ensure processing of emergency SKBs happens under PF_MEMALLOC.

Use the (new) sk_backlog_rcv() wrapper to ensure this for backlog processing.

Skip taps, since those are user-space again.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h |    5 ++++
 net/core/dev.c     |   59 +++++++++++++++++++++++++++++++++++++++++++++++------
 net/core/sock.c    |   16 ++++++++++++++
 3 files changed, 74 insertions(+), 6 deletions(-)

Index: linux-2.6/net/core/dev.c
===================================================================
--- linux-2.6.orig/net/core/dev.c
+++ linux-2.6/net/core/dev.c
@@ -2008,6 +2008,30 @@ out:
 }
 #endif
 
+/*
+ * Filter the protocols for which the reserves are adequate.
+ *
+ * Before adding a protocol make sure that it is either covered by the existing
+ * reserves, or add reserves covering the memory need of the new protocol's
+ * packet processing.
+ */
+static int skb_emergency_protocol(struct sk_buff *skb)
+{
+	if (skb_emergency(skb))
+		switch (skb->protocol) {
+		case __constant_htons(ETH_P_ARP):
+		case __constant_htons(ETH_P_IP):
+		case __constant_htons(ETH_P_IPV6):
+		case __constant_htons(ETH_P_8021Q):
+			break;
+
+		default:
+			return 0;
+		}
+
+	return 1;
+}
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
@@ -2029,10 +2053,23 @@ int netif_receive_skb(struct sk_buff *sk
 	struct net_device *orig_dev;
 	int ret = NET_RX_DROP;
 	__be16 type;
+	unsigned long pflags = current->flags;
+
+	/* Emergency skb are special, they should
+	 *  - be delivered to SOCK_MEMALLOC sockets only
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
 	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
+		goto out;
 
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
@@ -2043,7 +2080,7 @@ int netif_receive_skb(struct sk_buff *sk
 	orig_dev = skb_bond(skb);
 
 	if (!orig_dev)
-		return NET_RX_DROP;
+		goto out;
 
 	__get_cpu_var(netdev_rx_stat).total++;
 
@@ -2062,6 +2099,9 @@ int netif_receive_skb(struct sk_buff *sk
 	}
 #endif
 
+	if (skb_emergency(skb))
+		goto skip_taps;
+
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (!ptype->dev || ptype->dev == skb->dev) {
 			if (pt_prev)
@@ -2070,19 +2110,23 @@ int netif_receive_skb(struct sk_buff *sk
 		}
 	}
 
+skip_taps:
 #ifdef CONFIG_NET_CLS_ACT
 	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
 	if (!skb)
-		goto out;
+		goto unlock;
 ncls:
 #endif
 
+	if (!skb_emergency_protocol(skb))
+		goto drop;
+
 	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
 	if (!skb)
-		goto out;
+		goto unlock;
 	skb = handle_macvlan(skb, &pt_prev, &ret, orig_dev);
 	if (!skb)
-		goto out;
+		goto unlock;
 
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype,
@@ -2098,6 +2142,7 @@ ncls:
 	if (pt_prev) {
 		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 	} else {
+drop:
 		kfree_skb(skb);
 		/* Jamal, now you will not able to escape explaining
 		 * me how you were going to use this. :-)
@@ -2105,8 +2150,10 @@ ncls:
 		ret = NET_RX_DROP;
 	}
 
-out:
+unlock:
 	rcu_read_unlock();
+out:
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 	return ret;
 }
 
Index: linux-2.6/include/net/sock.h
===================================================================
--- linux-2.6.orig/include/net/sock.h
+++ linux-2.6/include/net/sock.h
@@ -521,8 +521,13 @@ static inline void sk_add_backlog(struct
 	skb->next = NULL;
 }
 
+extern int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb);
+
 static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
+	if (skb_emergency(skb))
+		return __sk_backlog_rcv(sk, skb);
+
 	return sk->sk_backlog_rcv(sk, skb);
 }
 
Index: linux-2.6/net/core/sock.c
===================================================================
--- linux-2.6.orig/net/core/sock.c
+++ linux-2.6/net/core/sock.c
@@ -313,6 +313,22 @@ int sk_clear_memalloc(struct sock *sk)
 	return set;
 }
 EXPORT_SYMBOL_GPL(sk_clear_memalloc);
+
+int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	int ret;
+	unsigned long pflags = current->flags;
+
+	/* these should have been dropped before queueing */
+	BUG_ON(!sk_has_memalloc(sk));
+
+	current->flags |= PF_MEMALLOC;
+	ret = sk->sk_backlog_rcv(sk, skb);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
+
+	return ret;
+}
+EXPORT_SYMBOL(__sk_backlog_rcv);
 #endif
 
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
