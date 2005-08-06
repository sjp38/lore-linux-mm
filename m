From: Daniel Phillips <phillips@istop.com>
Subject: [RFC] Net vm deadlock fix, version 4
Date: Sun, 7 Aug 2005 07:52:28 +1000
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508070752.29214.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This patch fills in some missing pieces:

   * Support v4 udp: same as v4 tcp, when in reserve, drop packets on
     noncritical sockets

   * Support v4 icmp: when in reserve, drop icmp traffic

   * Add reserve skb support to e1000 driver

   * API for dropping packets before delivery (dev_drop_skb)

   * Atomic_t for reserve accounting

Now ready for proof-of-concept testing.  High level API boilerplate will come
later.

Regards,

Daniel

diff -up --recursive 2.6.12.3.clean/drivers/net/e1000/e1000_main.c 2.6.12.3/drivers/net/e1000/e1000_main.c
--- 2.6.12.3.clean/drivers/net/e1000/e1000_main.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/drivers/net/e1000/e1000_main.c	2005-08-06 16:46:13.000000000 -0400
@@ -3242,7 +3242,7 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
 				cpu_to_le64(ps_page_dma->ps_page_dma[j]);
 		}
 
-		skb = dev_alloc_skb(adapter->rx_ps_bsize0 + NET_IP_ALIGN);
+		skb = dev_memalloc_skb(netdev, adapter->rx_ps_bsize0 + NET_IP_ALIGN);
 
 		if(unlikely(!skb))
 			break;
@@ -3253,8 +3253,6 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 
-		skb->dev = netdev;
-
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_ps_bsize0;
 		buffer_info->dma = pci_map_single(pdev, skb->data,
diff -up --recursive 2.6.12.3.clean/include/linux/gfp.h 2.6.12.3/include/linux/gfp.h
--- 2.6.12.3.clean/include/linux/gfp.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/linux/gfp.h	2005-08-05 21:53:09.000000000 -0400
@@ -39,6 +39,7 @@ struct vm_area_struct;
 #define __GFP_COMP	0x4000u	/* Add compound page metadata */
 #define __GFP_ZERO	0x8000u	/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC 0x10000u /* Don't use emergency reserves */
+#define __GFP_MEMALLOC  0x20000u /* Use emergency reserves */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((1 << __GFP_BITS_SHIFT) - 1)
diff -up --recursive 2.6.12.3.clean/include/linux/netdevice.h 2.6.12.3/include/linux/netdevice.h
--- 2.6.12.3.clean/include/linux/netdevice.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/linux/netdevice.h	2005-08-06 16:37:14.000000000 -0400
@@ -371,6 +371,8 @@ struct net_device
 	struct Qdisc		*qdisc_ingress;
 	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
+	int			rx_reserve;
+	atomic_t		rx_reserve_used;
 
 	/* ingress path synchronizer */
 	spinlock_t		ingress_lock;
@@ -662,6 +664,49 @@ static inline void dev_kfree_skb_any(str
 		dev_kfree_skb(skb);
 }
 
+/*
+ * Support for critical network IO under low memory conditions
+ */
+static inline int dev_reserve_used(struct net_device *dev)
+{
+	return atomic_read(&dev->rx_reserve_used);
+}
+
+static inline struct sk_buff *__dev_memalloc_skb(struct net_device *dev,
+	unsigned length, int gfp_mask)
+{
+	struct sk_buff *skb = __dev_alloc_skb(length, gfp_mask);
+	if (skb)
+		goto done;
+	if (dev_reserve_used(dev) >= dev->rx_reserve)
+		return NULL;
+	if (!__dev_alloc_skb(length, gfp_mask|__GFP_MEMALLOC))
+		return NULL;;
+	atomic_inc(&dev->rx_reserve_used);
+done:
+	skb->dev = dev;
+	return skb;
+}
+
+static inline struct sk_buff *dev_memalloc_skb(struct net_device *dev,
+	unsigned length)
+{
+	return __dev_memalloc_skb(dev, length, GFP_ATOMIC);
+}
+
+static inline void dev_unreserve(struct net_device *dev)
+{
+	if (atomic_dec_return(&dev->rx_reserve_used) < 0)
+		atomic_inc(&dev->rx_reserve_used);
+}
+
+static inline void dev_drop_skb(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	__kfree_skb(skb);
+	dev_unreserve(dev);
+}
+
 #define HAVE_NETIF_RX 1
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
diff -up --recursive 2.6.12.3.clean/include/net/sock.h 2.6.12.3/include/net/sock.h
--- 2.6.12.3.clean/include/net/sock.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/net/sock.h	2005-08-05 21:53:09.000000000 -0400
@@ -382,6 +382,7 @@ enum sock_flags {
 	SOCK_NO_LARGESEND, /* whether to sent large segments or not */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
+	SOCK_MEMALLOC, /* protocol can use memalloc reserve */
 };
 
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
@@ -399,6 +400,11 @@ static inline int sock_flag(struct sock 
 	return test_bit(flag, &sk->sk_flags);
 }
 
+static inline int is_memalloc_sock(struct sock *sk)
+{
+	return sock_flag(sk, SOCK_MEMALLOC);
+}
+
 static inline void sk_acceptq_removed(struct sock *sk)
 {
 	sk->sk_ack_backlog--;
diff -up --recursive 2.6.12.3.clean/mm/page_alloc.c 2.6.12.3/mm/page_alloc.c
--- 2.6.12.3.clean/mm/page_alloc.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/mm/page_alloc.c	2005-08-05 21:53:09.000000000 -0400
@@ -802,8 +802,8 @@ __alloc_pages(unsigned int __nocast gfp_
 
 	/* This allocation should allow future memory freeing. */
 
-	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
-			&& !in_interrupt()) {
+	if ((((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
+			&& !in_interrupt()) || (gfp_mask & __GFP_MEMALLOC)) {
 		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
 			/* go through the zonelist yet again, ignoring mins */
 			for (i = 0; (z = zones[i]) != NULL; i++) {
diff -up --recursive 2.6.12.3.clean/net/ethernet/eth.c 2.6.12.3/net/ethernet/eth.c
--- 2.6.12.3.clean/net/ethernet/eth.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/ethernet/eth.c	2005-08-06 02:32:02.000000000 -0400
@@ -281,6 +281,7 @@ void ether_setup(struct net_device *dev)
 	dev->mtu		= 1500; /* eth_mtu */
 	dev->addr_len		= ETH_ALEN;
 	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */	
+	dev->rx_reserve		= 50;
 	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
 	
 	memset(dev->broadcast,0xFF, ETH_ALEN);
diff -up --recursive 2.6.12.3.clean/net/ipv4/icmp.c 2.6.12.3/net/ipv4/icmp.c
--- 2.6.12.3.clean/net/ipv4/icmp.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/ipv4/icmp.c	2005-08-06 16:58:17.000000000 -0400
@@ -944,6 +944,11 @@ int icmp_rcv(struct sk_buff *skb)
 	default:;
 	}
 
+	if (dev_reserve_used(skb->dev)) {
+		dev_unreserve(skb->dev);
+		goto drop;
+	}
+
 	if (!pskb_pull(skb, sizeof(struct icmphdr)))
 		goto error;
 
diff -up --recursive 2.6.12.3.clean/net/ipv4/tcp_ipv4.c 2.6.12.3/net/ipv4/tcp_ipv4.c
--- 2.6.12.3.clean/net/ipv4/tcp_ipv4.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/ipv4/tcp_ipv4.c	2005-08-06 16:59:15.000000000 -0400
@@ -1766,6 +1766,12 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
 
+	if (unlikely(dev_reserve_used(skb->dev))) {
+		dev_unreserve(skb->dev);
+		if (!is_memalloc_sock(sk))
+			goto discard_and_relse;
+	}
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
diff -up --recursive 2.6.12.3.clean/net/ipv4/udp.c 2.6.12.3/net/ipv4/udp.c
--- 2.6.12.3.clean/net/ipv4/udp.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/ipv4/udp.c	2005-08-06 17:12:20.000000000 -0400
@@ -1152,6 +1152,12 @@ int udp_rcv(struct sk_buff *skb)
 	sk = udp_v4_lookup(saddr, uh->source, daddr, uh->dest, skb->dev->ifindex);
 
 	if (sk != NULL) {
+		if (unlikely(dev_reserve_used(skb->dev))) {
+			dev_unreserve(skb->dev);
+			if (!is_memalloc_sock(sk))
+				goto drop_noncritical;
+		}
+
 		int ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
@@ -1163,6 +1169,7 @@ int udp_rcv(struct sk_buff *skb)
 		return 0;
 	}
 
+drop_noncritical:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto drop;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
