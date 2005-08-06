From: Daniel Phillips <phillips@istop.com>
Subject: [RFC] Net vm deadlock fix (take two)
Date: Sat, 6 Aug 2005 17:22:23 +1000
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508061722.24106.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This version does not do blatantly stupid things in hardware irq context, is
more efficient, and... wow the patch is smaller!  (That never happens.)

I don't mark skbs as being allocated from reserve any more.  That works, but
it is slightly bogus, because it doesn't matter which skb came from reserve,
it only matters that we put one back.  So I just count them and don't mark
them.

The tricky issue that had to be dealt with is the possibility that a massive 
number of skbs could in theory be queued by the hardware interrupt before the 
softnet softirq gets around to delivering them to the protocol.  But we can 
only allocate a limited number of skbs from reserve memory.  If we run out of 
reserve memory we have no choice but to fail skb allocations, and that can 
cause packets to be dropped.  Since we don't know which packets are blockio 
packets and which are not at that point, we could be so unlucky as to always 
drop block IO packets and always let other junk through.  The other junk 
won't get very far though, because those packets will be dropped as soon as 
the protocol headers are decoded, which will reveal that they do not belong 
to a memalloc socket.  This short circuit ought to help take away the cpu 
load that caused the softirq constipation in the first place.

What is actually going to happen is, a few block IO packets might be randomly 
dropped under such conditions, degrading the transport efficiency.  Block IO 
progress will continue, unless we manage to accidently drop every block IO 
packet and our softirqs continue to stay comatose, probably indicating a 
scheduler bug.

OK, we want to allocate skbs from reserve, but we cannot go infinitely into 
reserve.  So we count how many packets a driver has allocated from reserve, 
in the net_device struct.  If this goes over some limit, the skb 
allocation fails and the device driver may drop a packet because of that.  
Note that the e1000 driver will just be trying to refill its rx-ring at this 
point, and it will try to refill it again as soon as the next packet arrives, 
so it is still some ways away from actually dropping a packet.  Other drivers 
may immediately drop a packet at this point, c'est la vie.  Remember, this 
can only happen if the softirqs are backed up a silly amount.

The thing is, we have got our block IO traffic moving, by virtue of dipping 
into the reserve, and most likely moving at near-optimal speed.  Normal 
memory-consuming tasks are not moving because they are blocked on vm IO.  The 
things that can mess us up are cpu hogs - a scheduler problem - and tons of 
unhelpful traffic sharing the network wire, which we are killing off early as 
mentioned above.

What happens when a packet arrives at the protocol handler is a little subtle.  
At this point, if the interface is into reserve, we can always decrement the 
reserve count, regardless of what type of packet it is.  If it is a block IO 
packet, the packet is still accounted for within the block driver's 
throttling.  We are sure that the packet's resources will be returned to the 
common pool in an organized way.  If it is some other random kind of packet, 
we drop it right away, also returning the resources to the common pool.  
Either way, it is not the responsibility of the interface to account for it 
any more.

I'll just reiterate what I'm trying to accomplish here:

   1) Guarantee network block io forward progress
   2) Block IO throughput should not degrade much under low memory

This iteration of the patch addresses those goals nicely, I think.  I have not 
yet shown how to drive this from the block IO layer, and I haven't shown how 
to be sure that all protocols on an interface (not just TCPv4, as here) can 
handle the reserve management semantics.  I have ignored all transports 
besides IP, though not much changes for other transports.  I have some 
accounting code that is very probably racy and needs to be rewritten with 
atomic_t.  I have ignored the many hooks that are possible in the protocol 
path.  I have assumed that all receive skbs are the same size, and haven't 
accounted for the possibility that that size (MTU) might change.  All these 
things need looking at, but the main point at the moment is to establish a 
solid sense of correctness and to get some real results on a vanilla delivery 
path.  That in itself will be useful for cluster work, where configuration
issues are kept under careful control.

As far as drivers are concerned, the new interface is dev_memalloc_skb, which 
is straightforward.  It needs to know about the netdev for accounting 
purposes, so it takes it as a parameter and thoughtfully plugs it into the 
skb for you.

I am still using the global memory reserve, not mempool.  But notice, now I am 
explicitly accounting and throttling how deep a driver dips into the global 
reserve.  So GFP_MEMALLOC wins a point: the driver isn't just using the 
global reserve blindly, as has been traditional.  The jury is still out 
though.  Mainly, I need to present a sane way for drivers to declare their 
maximum reserve requirements to the vm system, so the vm can adjust the size 
of the global pool appropriately.

Regards,

Daniel

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
+++ 2.6.12.3/include/linux/netdevice.h	2005-08-06 01:06:18.000000000 -0400
@@ -371,6 +371,8 @@ struct net_device
 	struct Qdisc		*qdisc_ingress;
 	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
+	int			rx_reserve;
+	int			rx_reserve_used;
 
 	/* ingress path synchronizer */
 	spinlock_t		ingress_lock;
@@ -929,6 +931,28 @@ extern void		net_disable_timestamp(void)
 extern char *net_sysctl_strdup(const char *s);
 #endif
 
+static inline struct sk_buff *__dev_memalloc_skb(struct net_device *dev,
+	unsigned length, int gfp_mask)
+{
+	struct sk_buff *skb = __dev_alloc_skb(length, gfp_mask);
+	if (skb)
+		goto done;
+	if (dev->rx_reserve_used >= dev->rx_reserve)
+		return NULL;
+	if (!__dev_alloc_skb(length, gfp_mask|__GFP_MEMALLOC))
+		return NULL;;
+	dev->rx_reserve_used++;
+done:
+	skb->dev = dev;
+	return skb;
+}
+
+static inline struct sk_buff *dev_alloc_skb_reserve(struct net_device *dev,
+	unsigned length)
+{
+	return __dev_memalloc_skb(dev, length, GFP_ATOMIC);
+}
+
 #endif /* __KERNEL__ */
 
 #endif	/* _LINUX_DEV_H */
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
diff -up --recursive 2.6.12.3.clean/net/ipv4/tcp_ipv4.c 2.6.12.3/net/ipv4/tcp_ipv4.c
--- 2.6.12.3.clean/net/ipv4/tcp_ipv4.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/ipv4/tcp_ipv4.c	2005-08-06 00:45:07.000000000 -0400
@@ -1766,6 +1766,12 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
 
+	if (skb->dev->rx_reserve_used) {
+		skb->dev->rx_reserve_used--; // racy
+		if (!is_memalloc_sock(sk))
+			goto discard_and_relse;
+	}
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
