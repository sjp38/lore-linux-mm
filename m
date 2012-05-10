Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 5FF186B00F9
	for <linux-mm@kvack.org>; Thu, 10 May 2012 09:45:31 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/17] netvm: Set PF_MEMALLOC as appropriate during SKB processing
Date: Thu, 10 May 2012 14:45:06 +0100
Message-Id: <1336657510-24378-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1336657510-24378-1-git-send-email-mgorman@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Mel Gorman <mgorman@suse.de>

In order to make sure pfmemalloc packets receive all memory
needed to proceed, ensure processing of pfmemalloc SKBs happens
under PF_MEMALLOC. This is limited to a subset of protocols that
are expected to be used for writing to swap. Taps are not allowed to
use PF_MEMALLOC as these are expected to communicate with userspace
processes which could be paged out.

[a.p.zijlstra@chello.nl: Ideas taken from various patches]
[jslaby@suse.cz: Lock imbalance fix]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/net/sock.h |    5 +++++
 net/core/dev.c     |   52 ++++++++++++++++++++++++++++++++++++++++++++++------
 net/core/sock.c    |   16 ++++++++++++++++
 3 files changed, 67 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index e6a4248..7f04aa8 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -729,8 +729,13 @@ static inline __must_check int sk_add_backlog(struct sock *sk, struct sk_buff *s
 	return 0;
 }
 
+extern int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb);
+
 static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
+	if (skb_pfmemalloc(skb))
+		return __sk_backlog_rcv(sk, skb);
+
 	return sk->sk_backlog_rcv(sk, skb);
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 9bb8f87..e78273e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3173,6 +3173,23 @@ void netdev_rx_handler_unregister(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
 
+/*
+ * Limit the use of PFMEMALLOC reserves to those protocols that implement
+ * the special handling of PFMEMALLOC skbs.
+ */
+static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_ARP):
+	case __constant_htons(ETH_P_IP):
+	case __constant_htons(ETH_P_IPV6):
+	case __constant_htons(ETH_P_8021Q):
+		return true;
+	default:
+		return false;
+	}
+}
+
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
@@ -3182,14 +3199,27 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	bool deliver_exact = false;
 	int ret = NET_RX_DROP;
 	__be16 type;
+	unsigned long pflags = current->flags;
 
 	net_timestamp_check(!netdev_tstamp_prequeue, skb);
 
 	trace_netif_receive_skb(skb);
 
+	/*
+	 * PFMEMALLOC skbs are special, they should
+	 * - be delivered to SOCK_MEMALLOC sockets only
+	 * - stay away from userspace
+	 * - have bounded memory usage
+	 *
+	 * Use PF_MEMALLOC as this saves us from propagating the allocation
+	 * context down to all allocation sites.
+	 */
+	if (skb_pfmemalloc(skb))
+		current->flags |= PF_MEMALLOC;
+
 	/* if we've gotten here through NAPI, check netpoll */
 	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
+		goto out;
 
 	if (!skb->skb_iif)
 		skb->skb_iif = skb->dev->ifindex;
@@ -3210,7 +3240,7 @@ another_round:
 	if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
 		skb = vlan_untag(skb);
 		if (unlikely(!skb))
-			goto out;
+			goto unlock;
 	}
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -3220,6 +3250,9 @@ another_round:
 	}
 #endif
 
+	if (skb_pfmemalloc(skb))
+		goto skip_taps;
+
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (!ptype->dev || ptype->dev == skb->dev) {
 			if (pt_prev)
@@ -3228,13 +3261,17 @@ another_round:
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
 
+	if (skb_pfmemalloc(skb) && !skb_pfmemalloc_protocol(skb))
+		goto drop;
+
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (vlan_tx_tag_present(skb)) {
 		if (pt_prev) {
@@ -3244,7 +3281,7 @@ ncls:
 		if (vlan_do_receive(&skb, !rx_handler))
 			goto another_round;
 		else if (unlikely(!skb))
-			goto out;
+			goto unlock;
 	}
 
 	if (rx_handler) {
@@ -3254,7 +3291,7 @@ ncls:
 		}
 		switch (rx_handler(&skb)) {
 		case RX_HANDLER_CONSUMED:
-			goto out;
+			goto unlock;
 		case RX_HANDLER_ANOTHER:
 			goto another_round;
 		case RX_HANDLER_EXACT:
@@ -3284,6 +3321,7 @@ ncls:
 	if (pt_prev) {
 		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 	} else {
+drop:
 		atomic_long_inc(&skb->dev->rx_dropped);
 		kfree_skb(skb);
 		/* Jamal, now you will not able to escape explaining
@@ -3292,8 +3330,10 @@ ncls:
 		ret = NET_RX_DROP;
 	}
 
-out:
+unlock:
 	rcu_read_unlock();
+out:
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 	return ret;
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index cd2ad2b..9ad1ed9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -292,6 +292,22 @@ void sk_clear_memalloc(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sk_clear_memalloc);
 
+int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	int ret;
+	unsigned long pflags = current->flags;
+
+	/* these should have been dropped before queueing */
+	BUG_ON(!sock_flag(sk, SOCK_MEMALLOC));
+
+	current->flags |= PF_MEMALLOC;
+	ret = sk->sk_backlog_rcv(sk, skb);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
+
+	return ret;
+}
+EXPORT_SYMBOL(__sk_backlog_rcv);
+
 #if defined(CONFIG_CGROUPS)
 #if !defined(CONFIG_NET_CLS_CGROUP)
 int net_cls_subsys_id = -1;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
