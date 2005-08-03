From: Daniel Phillips <phillips@istop.com>
Subject: [RFC] Net vm deadlock fix (preliminary)
Date: Wed, 3 Aug 2005 16:57:34 +1000
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_erG8Cxp+SIt3lHl"
Message-Id: <200508031657.34948.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_erG8Cxp+SIt3lHl
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

Here is a preliminary patch, not tested at all, just to give everybody a 
target to aim bricks at.

  * A new __GFP_MEMALLOC flag gives access to the memalloc reserve.

  * In dev_alloc_skb, if GFP_ATOMIC fails then try again with __GFP_MEMALLOC.

  * We know an skb was allocated from reserve if we see __GFP_MEMALLOC in the
    (misnamed) priority field.

  * When a driver uses netif_rx to deliver the packet to the protocol layer,
    if the packet was allocated from the reserve it is delivered directly to
    the protocol layer, otherwise queue the packet via softnet.

  * When the protocol handler (tcp/ipv4 in this case) looks up the socket,
    if the packet was allocated from reserve but the socket is not serving
    vm traffic, the packet is discarded.

There are some users of __dev_alloc_skb that inherit the new memalloc behavior 
for free.  This is probably not a good thing.  There are a dozen or so users 
to check... later.

I claimed earlier that an advantage of using the memalloc reserve over a 
mempool is that the pool becomes available to the whole call chain of the 
user.  This isn't true in a softirq, sorry.  Maybe we could make it true, 
that's another question.  Anyway, memalloc reserve vs mempool is a detail at 
this point.

There is a big hole here through which precious reserve memory can escape: if 
the network driver is allocating packets from reserve but a protocol handler 
does not test such packets, things will deteriorate quickly.  The easiest 
thing to do is make sure all protocols know about this logic.  They probably 
all need to anyway.

A memalloc task (one handling IO on behalf of the vm) will set the SO_MEMALLOC 
flag after creating the socket.  The memalloc task will throttle the amount 
of traffic in flight to keep the maximum reserve usage to some reasonable 
amount.  (It will be necessary to get more precise about this at some point.) 
The memalloc task itself will be in PF_MEMALLOC mode when it uses this 
socket.

This patch only covers socket input, not output.  As you can see, the fast 
path is not compromised at all, and even when the low memory path triggers, 
efficiency only falls off a little (allocations may take longer and we bypass 
the softnet optimization).  But the thing is, we don't fall back to 
single-request-at-a-time handling, which is exactly what you don't want to do 
when the vm is desperately trying to clean memory.

Regards,

Daniel

--Boundary-00=_erG8Cxp+SIt3lHl
Content-Type: text/x-diff;
  charset="us-ascii";
  name="net.memalloc-2.6.12.3"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="net.memalloc-2.6.12.3"

--- 2.6.12.3.clean/include/linux/gfp.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/linux/gfp.h	2005-08-03 01:12:33.000000000 -0400
@@ -39,6 +39,7 @@
 #define __GFP_COMP	0x4000u	/* Add compound page metadata */
 #define __GFP_ZERO	0x8000u	/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC 0x10000u /* Don't use emergency reserves */
+#define __GFP_MEMALLOC  0x20000u /* Use emergency reserves */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((1 << __GFP_BITS_SHIFT) - 1)
--- 2.6.12.3.clean/include/linux/skbuff.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/linux/skbuff.h	2005-08-03 01:53:43.000000000 -0400
@@ -969,7 +969,6 @@
 		kfree_skb(skb);
 }
 
-#ifndef CONFIG_HAVE_ARCH_DEV_ALLOC_SKB
 /**
  *	__dev_alloc_skb - allocate an skbuff for sending
  *	@length: length to allocate
@@ -985,14 +984,14 @@
 static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
 					      int gfp_mask)
 {
-	struct sk_buff *skb = alloc_skb(length + 16, gfp_mask);
+	struct sk_buff *skb = alloc_skb(length += 16, gfp_mask);
+
+	if (unlikely(!skb))
+		skb = alloc_skb(length, gfp_mask|__GFP_MEMALLOC);
 	if (likely(skb))
 		skb_reserve(skb, 16);
 	return skb;
 }
-#else
-extern struct sk_buff *__dev_alloc_skb(unsigned int length, int gfp_mask);
-#endif
 
 /**
  *	dev_alloc_skb - allocate an skbuff for sending
@@ -1011,6 +1010,11 @@
 	return __dev_alloc_skb(length, GFP_ATOMIC);
 }
 
+static inline int is_memalloc_skb(struct sk_buff *skb)
+{
+	return !!(skb->priority & __GFP_MEMALLOC);
+}
+
 /**
  *	skb_cow - copy header of skb when it is required
  *	@skb: buffer to cow
--- 2.6.12.3.clean/include/net/sock.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/net/sock.h	2005-08-03 01:20:56.000000000 -0400
@@ -382,6 +382,7 @@
 	SOCK_NO_LARGESEND, /* whether to sent large segments or not */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
+	SOCK_MEMALLOC, /* protocol can use memalloc reserve */
 };
 
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
@@ -399,6 +400,11 @@
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
--- 2.6.12.3.clean/mm/page_alloc.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/mm/page_alloc.c	2005-08-03 01:46:10.000000000 -0400
@@ -802,8 +802,8 @@
 
 	/* This allocation should allow future memory freeing. */
 
-	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
-			&& !in_interrupt()) {
+	if ((((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
+			&& !in_interrupt()) || (gfp_mask & __GFP_MEMALLOC)) {
 		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
 			/* go through the zonelist yet again, ignoring mins */
 			for (i = 0; (z = zones[i]) != NULL; i++) {
--- 2.6.12.3.clean/net/core/dev.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/core/dev.c	2005-08-03 01:42:46.000000000 -0400
@@ -1452,6 +1452,11 @@
 	struct softnet_data *queue;
 	unsigned long flags;
 
+        if (unlikely(is_memalloc_skb(skb))) {
+                netif_receive_skb(skb);
+                return NET_RX_CN_HIGH;
+        }
+
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
--- 2.6.12.3.clean/net/core/skbuff.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/core/skbuff.c	2005-08-03 01:36:50.000000000 -0400
@@ -355,7 +355,7 @@
 	n->nohdr = 0;
 	C(pkt_type);
 	C(ip_summed);
-	C(priority);
+	n->priority = skb->priority & ~__GFP_MEMALLOC;
 	C(protocol);
 	C(security);
 	n->destructor = NULL;
@@ -411,7 +411,7 @@
 	new->sk		= NULL;
 	new->dev	= old->dev;
 	new->real_dev	= old->real_dev;
-	new->priority	= old->priority;
+	new->priority	= old->priority & ~__GFP_MEMALLOC;
 	new->protocol	= old->protocol;
 	new->dst	= dst_clone(old->dst);
 #ifdef CONFIG_INET
--- 2.6.12.3.clean/net/ipv4/tcp_ipv4.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/ipv4/tcp_ipv4.c	2005-08-02 21:35:54.000000000 -0400
@@ -1766,6 +1766,9 @@
 	if (!sk)
 		goto no_tcp_socket;
 
+	if (unlikely(is_memalloc_skb(skb)) && !is_memalloc_sock(sk))
+		goto discard_and_relse;
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;

--Boundary-00=_erG8Cxp+SIt3lHl--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
