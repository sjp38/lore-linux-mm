Message-Id: <20080320202124.540993000@chello.nl>
References: <20080320201042.675090000@chello.nl>
Date: Thu, 20 Mar 2008 21:11:03 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 21/30] netvm: prevent a stream specific deadlock
Content-Disposition: inline; filename=netvm-tcp-deadlock.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, neilb@suse.de, miklos@szeredi.hu, penberg@cs.helsinki.fi, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

It could happen that all !SOCK_MEMALLOC sockets have buffered so much data
that we're over the global rmem limit. This will prevent SOCK_MEMALLOC buffers
from receiving data, which will prevent userspace from running, which is needed
to reduce the buffered data.

Fix this by exempting the SOCK_MEMALLOC sockets from the rmem limit.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h   |    7 ++++---
 net/core/sock.c      |    2 +-
 net/ipv4/tcp_input.c |    8 ++++----
 net/sctp/ulpevent.c  |    2 +-
 4 files changed, 10 insertions(+), 9 deletions(-)

Index: linux-2.6/include/net/sock.h
===================================================================
--- linux-2.6.orig/include/net/sock.h
+++ linux-2.6/include/net/sock.h
@@ -800,12 +800,13 @@ static inline int sk_wmem_schedule(struc
 		__sk_mem_schedule(sk, size, SK_MEM_SEND);
 }
 
-static inline int sk_rmem_schedule(struct sock *sk, int size)
+static inline int sk_rmem_schedule(struct sock *sk, struct sk_buff *skb)
 {
 	if (!sk_has_account(sk))
 		return 1;
-	return size <= sk->sk_forward_alloc ||
-		__sk_mem_schedule(sk, size, SK_MEM_RECV);
+	return skb->truesize <= sk->sk_forward_alloc ||
+		__sk_mem_schedule(sk, skb->truesize, SK_MEM_RECV) ||
+		skb_emergency(skb);
 }
 
 static inline void sk_mem_reclaim(struct sock *sk)
Index: linux-2.6/net/core/sock.c
===================================================================
--- linux-2.6.orig/net/core/sock.c
+++ linux-2.6/net/core/sock.c
@@ -384,7 +384,7 @@ int sock_queue_rcv_skb(struct sock *sk, 
 	if (err)
 		goto out;
 
-	if (!sk_rmem_schedule(sk, skb->truesize)) {
+	if (!sk_rmem_schedule(sk, skb)) {
 		err = -ENOBUFS;
 		goto out;
 	}
Index: linux-2.6/net/ipv4/tcp_input.c
===================================================================
--- linux-2.6.orig/net/ipv4/tcp_input.c
+++ linux-2.6/net/ipv4/tcp_input.c
@@ -3862,9 +3862,9 @@ static void tcp_data_queue(struct sock *
 queue_and_out:
 			if (eaten < 0 &&
 			    (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-			     !sk_rmem_schedule(sk, skb->truesize))) {
+			     !sk_rmem_schedule(sk, skb))) {
 				if (tcp_prune_queue(sk) < 0 ||
-				    !sk_rmem_schedule(sk, skb->truesize))
+				    !sk_rmem_schedule(sk, skb))
 					goto drop;
 			}
 			skb_set_owner_r(skb, sk);
@@ -3936,9 +3936,9 @@ drop:
 	TCP_ECN_check_ce(tp, skb);
 
 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-	    !sk_rmem_schedule(sk, skb->truesize)) {
+	    !sk_rmem_schedule(sk, skb)) {
 		if (tcp_prune_queue(sk) < 0 ||
-		    !sk_rmem_schedule(sk, skb->truesize))
+		    !sk_rmem_schedule(sk, skb))
 			goto drop;
 	}
 
Index: linux-2.6/net/sctp/ulpevent.c
===================================================================
--- linux-2.6.orig/net/sctp/ulpevent.c
+++ linux-2.6/net/sctp/ulpevent.c
@@ -701,7 +701,7 @@ struct sctp_ulpevent *sctp_ulpevent_make
 	if (rx_count >= asoc->base.sk->sk_rcvbuf) {
 
 		if ((asoc->base.sk->sk_userlocks & SOCK_RCVBUF_LOCK) ||
-		    (!sk_rmem_schedule(asoc->base.sk, chunk->skb->truesize)))
+		    (!sk_rmem_schedule(asoc->base.sk, chunk->skb)))
 			goto fail;
 	}
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
