Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 7221F6B0083
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 05:35:41 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/17] netvm: Prevent a stream-specific deadlock
Date: Wed, 20 Jun 2012 10:35:20 +0100
Message-Id: <1340184920-22288-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1340184920-22288-1-git-send-email-mgorman@suse.de>
References: <1340184920-22288-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Mel Gorman <mgorman@suse.de>

It could happen that all !SOCK_MEMALLOC sockets have buffered so
much data that we're over the global rmem limit. This will prevent
SOCK_MEMALLOC buffers from receiving data, which will prevent userspace
from running, which is needed to reduce the buffered data.

Fix this by exempting the SOCK_MEMALLOC sockets from the rmem limit.
Once this change it applied, it is important that sockets that set
SOCK_MEMALLOC do not clear the flag until the socket is being torn down.
If this happens, a warning is generated and the tokens reclaimed to
avoid accounting errors until the bug is fixed.

[davem@davemloft.net: Warning about clearing SOCK_MEMALLOC]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: David S. Miller <davem@davemloft.net>
---
 include/net/sock.h     |    7 ++++---
 net/caif/caif_socket.c |    2 +-
 net/core/sock.c        |   14 +++++++++++++-
 net/ipv4/tcp_input.c   |   12 ++++++------
 net/sctp/ulpevent.c    |    2 +-
 5 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 772577f..9ab9934 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1315,12 +1315,13 @@ static inline bool sk_wmem_schedule(struct sock *sk, int size)
 		__sk_mem_schedule(sk, size, SK_MEM_SEND);
 }
 
-static inline bool sk_rmem_schedule(struct sock *sk, int size)
+static inline bool sk_rmem_schedule(struct sock *sk, struct sk_buff *skb)
 {
 	if (!sk_has_account(sk))
 		return true;
-	return size <= sk->sk_forward_alloc ||
-		__sk_mem_schedule(sk, size, SK_MEM_RECV);
+	return skb->truesize <= sk->sk_forward_alloc ||
+		__sk_mem_schedule(sk, skb->truesize, SK_MEM_RECV) ||
+		skb_pfmemalloc(skb);
 }
 
 static inline void sk_mem_reclaim(struct sock *sk)
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index fb89443..5855b3a 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -141,7 +141,7 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	err = sk_filter(sk, skb);
 	if (err)
 		return err;
-	if (!sk_rmem_schedule(sk, skb->truesize) && rx_flow_is_on(cf_sk)) {
+	if (!sk_rmem_schedule(sk, skb) && rx_flow_is_on(cf_sk)) {
 		set_rx_flow_off(cf_sk);
 		net_dbg_ratelimited("sending flow OFF due to rmem_schedule\n");
 		caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_OFF_REQ);
diff --git a/net/core/sock.c b/net/core/sock.c
index 4388a8a..b51a49a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -294,6 +294,18 @@ void sk_clear_memalloc(struct sock *sk)
 	sock_reset_flag(sk, SOCK_MEMALLOC);
 	sk->sk_allocation &= ~__GFP_MEMALLOC;
 	static_key_slow_dec(&memalloc_socks);
+
+	/*
+	 * SOCK_MEMALLOC is allowed to ignore rmem limits to ensure forward
+	 * progress of swapping. However, if SOCK_MEMALLOC is cleared while
+	 * it has rmem allocations there is a risk that the user of the
+	 * socket cannot make forward progress due to exceeding the rmem
+	 * limits. By rights, sk_clear_memalloc() should only be called
+	 * on sockets being torn down but warn and reset the accounting if
+	 * that assumption breaks.
+	 */
+	if (WARN_ON(sk->sk_forward_alloc))
+		sk_mem_reclaim(sk);
 }
 EXPORT_SYMBOL_GPL(sk_clear_memalloc);
 
@@ -395,7 +407,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (err)
 		return err;
 
-	if (!sk_rmem_schedule(sk, skb->truesize)) {
+	if (!sk_rmem_schedule(sk, skb)) {
 		atomic_inc(&sk->sk_drops);
 		return -ENOBUFS;
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b224eb8..c121d6a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4512,19 +4512,19 @@ static void tcp_ofo_queue(struct sock *sk)
 static bool tcp_prune_ofo_queue(struct sock *sk);
 static int tcp_prune_queue(struct sock *sk);
 
-static int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
+static int tcp_try_rmem_schedule(struct sock *sk, struct sk_buff *skb)
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
@@ -4579,7 +4579,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 
 	TCP_ECN_check_ce(tp, skb);
 
-	if (tcp_try_rmem_schedule(sk, skb->truesize)) {
+	if (tcp_try_rmem_schedule(sk, skb)) {
 		/* TODO: should increment a counter */
 		__kfree_skb(skb);
 		return;
@@ -4791,7 +4791,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 		if (eaten <= 0) {
 queue_and_out:
 			if (eaten < 0 &&
-			    tcp_try_rmem_schedule(sk, skb->truesize))
+			    tcp_try_rmem_schedule(sk, skb))
 				goto drop;
 
 			eaten = tcp_queue_rcv(sk, skb, 0, &fragstolen);
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 8a84017..6c6ed2d 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -702,7 +702,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_rcvmsg(struct sctp_association *asoc,
 	if (rx_count >= asoc->base.sk->sk_rcvbuf) {
 
 		if ((asoc->base.sk->sk_userlocks & SOCK_RCVBUF_LOCK) ||
-		    (!sk_rmem_schedule(asoc->base.sk, chunk->skb->truesize)))
+		    (!sk_rmem_schedule(asoc->base.sk, chunk->skb)))
 			goto fail;
 	}
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
