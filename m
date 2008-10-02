Message-Id: <20081002131609.350956725@chello.nl>
References: <20081002130504.927878499@chello.nl>
Date: Thu, 02 Oct 2008 15:05:27 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 23/32] netvm: prevent a stream specific deadlock
Content-Disposition: inline; filename=netvm-tcp-deadlock.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
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
 net/ipv4/tcp_input.c |   12 ++++++------
 net/sctp/ulpevent.c  |    2 +-
 4 files changed, 12 insertions(+), 11 deletions(-)

Index: linux-2.6/include/net/sock.h
===================================================================
--- linux-2.6.orig/include/net/sock.h
+++ linux-2.6/include/net/sock.h
@@ -788,12 +788,13 @@ static inline int sk_wmem_schedule(struc
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
@@ -383,7 +383,7 @@ int sock_queue_rcv_skb(struct sock *sk, 
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
@@ -3877,19 +3877,19 @@ static void tcp_ofo_queue(struct sock *s
 static int tcp_prune_ofo_queue(struct sock *sk);
 static int tcp_prune_queue(struct sock *sk);
 
-static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
+static inline int tcp_try_rmem_schedule(struct sock *sk, struct sk_buff *skb)
 {
 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-	    !sk_rmem_schedule(sk, size)) {
+	    !sk_rmem_schedule(sk, skb)) {
 
 		if (tcp_prune_queue(sk) < 0)
 			return -1;
 
-		if (!sk_rmem_schedule(sk, size)) {
+		if (!sk_rmem_schedule(sk, skb)) {
 			if (!tcp_prune_ofo_queue(sk))
 				return -1;
 
-			if (!sk_rmem_schedule(sk, size))
+			if (!sk_rmem_schedule(sk, skb))
 				return -1;
 		}
 	}
@@ -3945,7 +3945,7 @@ static void tcp_data_queue(struct sock *
 		if (eaten <= 0) {
 queue_and_out:
 			if (eaten < 0 &&
-			    tcp_try_rmem_schedule(sk, skb->truesize))
+			    tcp_try_rmem_schedule(sk, skb))
 				goto drop;
 
 			skb_set_owner_r(skb, sk);
@@ -4016,7 +4016,7 @@ drop:
 
 	TCP_ECN_check_ce(tp, skb);
 
-	if (tcp_try_rmem_schedule(sk, skb->truesize))
+	if (tcp_try_rmem_schedule(sk, skb))
 		goto drop;
 
 	/* Disable header prediction. */
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
