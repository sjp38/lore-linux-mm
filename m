From: Daniel Phillips <phillips@istop.com>
Subject: Re: [RFC] Net vm deadlock fix (preliminary)
Date: Fri, 5 Aug 2005 07:51:33 +1000
References: <200508031657.34948.phillips@istop.com> <1123093305.11483.21.camel@localhost.localdomain> <200508040606.07769.phillips@istop.com>
In-Reply-To: <200508040606.07769.phillips@istop.com>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_m3o8CTPb+4WjxCG"
Message-Id: <200508050751.34174.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_m3o8CTPb+4WjxCG
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

I spent the last day mulling things over and doing research.  It seems to me 
that the patch as first posted is correct and solves the deadlock, except 
that some uses of __GFP_MEMALLOC in __dev_alloc_skb may escape into contexts 
where the reserve is not guaranteed to be reclaimed.  It may be that this 
does not actually happen, but there is enough different usage that I would 
rather err on the side of caution just now, and offer a variant called, e.g., 
dev_memalloc_skb so that drivers will explicitly have to choose to use it (or 
supply the flag to __dev_alloc_skb).  This is just a stack of inline 
functions so there should be no extra object code.  The dev_memalloc_skb 
variant can go away in time, but for now it does no harm.

A minor cleanup: somebody (Rik) complained about his bleeding eyes after 
reading my side-effecty alloc_skb expression, so that was rearranged in a way 
that should optimize to the same thing.

On the "first write the patch, then do the research" principle, the entire 
thread on this topic from the ksummit-2005-discuss mailing list is a good 
read:

http://thunker.thunk.org/pipermail/ksummit-2005-discuss/2005-March/thread.html#186

Matt, you are close to the truth here:

http://thunker.thunk.org/pipermail/ksummit-2005-discuss/2005-March/000242.html

but this part isn't right: "it's important to note here that "making progress" 
may require M acknowledgements to N packets representing a single IO. So we 
need separate send and acknowledge pools for each SO_MEMALLOC socket so that 
we don't find ourselves wedged with M-1 available mempool slots when we're 
waiting on ACKs".  This erroneously assumes that mempools throttle the block 
IO traffic.  In fact, the throttling _must_ take place higher up, in the 
block IO stack.  The block driver that submits the network IO must 
pre-account any per-request resources and block until sufficient resources 
become available.  So the accounting would include both space for transmit 
and acknowledge, and the network block IO protocol must be designed to obey 
that accounting.  (I will wave my hands at the question of how we arrange for 
low-level components to communicate their resource needs to high-level 
throttlers, just for now.)

Andrea, also getting close:

http://thunker.thunk.org/pipermail/ksummit-2005-discuss/2005-March/000200.html

But there is no need to be random.  Short of actually overlowing the input 
ring buffer, we can be precise about accepting all block IO packets and 
dropping non-blockio traffic as necessary.

Rik, not bad:

http://thunker.thunk.org/pipermail/ksummit-2005-discuss/2005-March/000218.html

particularly for deducing it from first principles without actually looking at 
the network code ;-)  It is even the same socket flag name as I settled on 
(SO_MEMALLOC).  But step 4 veers off course: out of order does not matter.  
And the conclusion that we can throttle here by dropping non-blockio packets 
is not right: the packets that we got from reserve still can live an 
arbitrary time in the protocol stack, so we could still exhaust the reserve 
and be back to the same bad old deadlock conditions.

Everybody noticed that dropping non-blockio packets is key, and everybody 
missed the fact that softnet introduces additional queues that need 
throttling (which can't be done sanely) or bypassing.  Almost everybody 
noticed that throttling in the block IO submission path is non-optional.

Everybody thought that mempool is the one true way of reserving memory.  I am 
not so sure, though I still intend to produce a mempool variant of the patch.  
One problem I see with mempool is that it not only reserves resources, but 
pins them.  If the kernel is full of mempools pinning memory pages here and 
there, physical defragmentation gets that much harder and the buddy tree will 
fragment that much sooner.  The __GPF_MEMALLOC interface does not have this 
problem because pages stay in the global pool.  So the jury is still out on 
which method is better.

Obviously, to do the job properly, __GPF_MEMALLOC would need a way of resizing 
the memalloc reserve as users are loaded and unloaded.  Such an interface can 
be very lightweight.  I will cook one up just to demonstrate this.

Now, the scheme in my patch does the job and I think it does it in a way that 
works for all drivers, even e1000 (by method 1. in the thread above).  But we 
could tighten this up a little by noticing that it doesn't actually matter 
which socket buffer we return to the pool as long as we are sure to return 
the same amount of memory as we withdrew.  Therefore, we could just account 
the number of pages alloc_skb withdraws, and the number that freeing a packet 
returns.  The e1000 driver would look at this number to determine whether to 
mark a packet as from_reserve or not.  That way, the e1000 driver could set 
things in motion to release reserve resources sooner, rather than waiting for 
certain specially flagged skbs to work their way around the rx-ring.  This 
also makes it easier for related systems (such as delivery hooks) to draw 
from a single pool with accurate accounting.

I will follow the current simple per-skb approach all the way to the end on 
the "perfect is the enemy of good enough" principle.  In the long run, page 
accounting is the way to go.

Next, on to actually trying this.

Regards,

Daniel

--Boundary-00=_m3o8CTPb+4WjxCG
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="net.memalloc-2.6.12.3-2"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="net.memalloc-2.6.12.3-2"

--- 2.6.12.3.clean/include/linux/gfp.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/linux/gfp.h	2005-08-04 00:12:48.000000000 -0400
@@ -39,6 +39,7 @@
 #define __GFP_COMP	0x4000u	/* Add compound page metadata */
 #define __GFP_ZERO	0x8000u	/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC 0x10000u /* Don't use emergency reserves */
+#define __GFP_MEMALLOC  0x20000u /* Use emergency reserves */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((1 << __GFP_BITS_SHIFT) - 1)
--- 2.6.12.3.clean/include/linux/skbuff.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/linux/skbuff.h	2005-08-04 13:46:35.000000000 -0400
@@ -969,7 +969,6 @@
 		kfree_skb(skb);
 }
 
-#ifndef CONFIG_HAVE_ARCH_DEV_ALLOC_SKB
 /**
  *	__dev_alloc_skb - allocate an skbuff for sending
  *	@length: length to allocate
@@ -982,17 +981,17 @@
  *
  *	%NULL is returned in there is no free memory.
  */
-static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
-					      int gfp_mask)
+static inline struct sk_buff *__dev_alloc_skb(unsigned length, int gfp_mask)
 {
-	struct sk_buff *skb = alloc_skb(length + 16, gfp_mask);
+	int opaque = 16, size = length + opaque;
+	struct sk_buff *skb = alloc_skb(size, gfp_mask & ~__GFP_MEMALLOC);
+
+	if (unlikely(!skb) && (gfp_mask & __GFP_MEMALLOC))
+		skb = alloc_skb(size, gfp_mask);
 	if (likely(skb))
-		skb_reserve(skb, 16);
+		skb_reserve(skb, opaque);
 	return skb;
 }
-#else
-extern struct sk_buff *__dev_alloc_skb(unsigned int length, int gfp_mask);
-#endif
 
 /**
  *	dev_alloc_skb - allocate an skbuff for sending
@@ -1011,6 +1010,16 @@
 	return __dev_alloc_skb(length, GFP_ATOMIC);
 }
 
+static inline struct sk_buff *dev_alloc_skb_reserve(unsigned int length)
+{
+	return __dev_alloc_skb(length, gfp_mask | __GFP_MEMALLOC);
+}
+
+static inline int is_memalloc_skb(struct sk_buff *skb)
+{
+	return !!(skb->priority & __GFP_MEMALLOC);
+}
+
 /**
  *	skb_cow - copy header of skb when it is required
  *	@skb: buffer to cow
--- 2.6.12.3.clean/include/net/sock.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/net/sock.h	2005-08-04 00:12:49.000000000 -0400
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
+++ 2.6.12.3/mm/page_alloc.c	2005-08-04 00:12:49.000000000 -0400
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
+++ 2.6.12.3/net/core/dev.c	2005-08-04 00:12:49.000000000 -0400
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
+++ 2.6.12.3/net/core/skbuff.c	2005-08-04 00:12:49.000000000 -0400
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
+++ 2.6.12.3/net/ipv4/tcp_ipv4.c	2005-08-04 00:12:49.000000000 -0400
@@ -1766,6 +1766,9 @@
 	if (!sk)
 		goto no_tcp_socket;
 
+	if (unlikely(is_memalloc_skb(skb)) && !is_memalloc_sock(sk))
+		goto discard_and_relse;
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;

--Boundary-00=_m3o8CTPb+4WjxCG--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
