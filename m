Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 956E86B0072
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:40:46 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/16] net: Introduce sk_gfp_atomic() to allow addition of GFP flags depending on the individual socket
Date: Thu, 12 Jul 2012 07:40:23 +0100
Message-Id: <1342075232-29267-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075232-29267-1-git-send-email-mgorman@suse.de>
References: <1342075232-29267-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

Introduce sk_gfp_atomic(), this function allows to inject sock specific
flags to each sock related allocation. It is only used on allocation
paths that may be required for writing pages back to network storage.

[davem@davemloft.net: Use sk_gfp_atomic only when necessary]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: David S. Miller <davem@davemloft.net>
---
 include/net/sock.h    |    5 +++++
 net/ipv4/tcp_output.c |   12 +++++++-----
 net/ipv6/tcp_ipv6.c   |    8 +++++---
 3 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ef68cbf..d6ee4c6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -658,6 +658,11 @@ static inline bool sock_flag(const struct sock *sk, enum sock_flags flag)
 	return test_bit(flag, &sk->sk_flags);
 }
 
+static inline gfp_t sk_gfp_atomic(struct sock *sk, gfp_t gfp_mask)
+{
+	return GFP_ATOMIC;
+}
+
 static inline void sk_acceptq_removed(struct sock *sk)
 {
 	sk->sk_ack_backlog--;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c465d3e..05e61b7 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1849,7 +1849,8 @@ void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 	if (unlikely(sk->sk_state == TCP_CLOSE))
 		return;
 
-	if (tcp_write_xmit(sk, cur_mss, nonagle, 0, GFP_ATOMIC))
+	if (tcp_write_xmit(sk, cur_mss, nonagle, 0,
+			   sk_gfp_atomic(sk, GFP_ATOMIC)))
 		tcp_check_probe_timer(sk);
 }
 
@@ -2470,7 +2471,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	if (cvp != NULL && cvp->s_data_constant && cvp->s_data_desired)
 		s_data_desired = cvp->s_data_desired;
-	skb = alloc_skb(MAX_TCP_HEADER + 15 + s_data_desired, GFP_ATOMIC);
+	skb = alloc_skb(MAX_TCP_HEADER + 15 + s_data_desired,
+			sk_gfp_atomic(sk, GFP_ATOMIC));
 	if (unlikely(!skb)) {
 		dst_release(dst);
 		return NULL;
@@ -2769,7 +2771,7 @@ void tcp_send_ack(struct sock *sk)
 	 * tcp_transmit_skb() will set the ownership to this
 	 * sock.
 	 */
-	buff = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	buff = alloc_skb(MAX_TCP_HEADER, sk_gfp_atomic(sk, GFP_ATOMIC));
 	if (buff == NULL) {
 		inet_csk_schedule_ack(sk);
 		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
@@ -2784,7 +2786,7 @@ void tcp_send_ack(struct sock *sk)
 
 	/* Send it off, this clears delayed acks for us. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
-	tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
+	tcp_transmit_skb(sk, buff, 0, sk_gfp_atomic(sk, GFP_ATOMIC));
 }
 
 /* This routine sends a packet with an out of date sequence
@@ -2804,7 +2806,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	struct sk_buff *skb;
 
 	/* We don't queue it, tcp_transmit_skb() sets ownership. */
-	skb = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_gfp_atomic(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return -1;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 64d3e5c..078445e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1337,7 +1337,8 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	/* Clone pktoptions received with SYN */
 	newnp->pktoptions = NULL;
 	if (treq->pktopts != NULL) {
-		newnp->pktoptions = skb_clone(treq->pktopts, GFP_ATOMIC);
+		newnp->pktoptions = skb_clone(treq->pktopts,
+					      sk_gfp_atomic(sk, GFP_ATOMIC));
 		consume_skb(treq->pktopts);
 		treq->pktopts = NULL;
 		if (newnp->pktoptions)
@@ -1387,7 +1388,8 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		 * across. Shucks.
 		 */
 		tcp_md5_do_add(newsk, (union tcp_md5_addr *)&newnp->daddr,
-			       AF_INET6, key->key, key->keylen, GFP_ATOMIC);
+			       AF_INET6, key->key, key->keylen,
+			       sk_gfp_atomic(sk, GFP_ATOMIC));
 	}
 #endif
 
@@ -1480,7 +1482,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 					       --ANK (980728)
 	 */
 	if (np->rxopt.all)
-		opt_skb = skb_clone(skb, GFP_ATOMIC);
+		opt_skb = skb_clone(skb, sk_gfp_atomic(sk, GFP_ATOMIC));
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		sock_rps_save_rxhash(sk, skb);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
