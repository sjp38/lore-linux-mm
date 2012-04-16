Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id EEB4F6B00EC
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 08:17:14 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/16] net: Introduce sk_allocation() to allow addition of GFP flags depending on the individual socket
Date: Mon, 16 Apr 2012 13:16:54 +0100
Message-Id: <1334578624-23257-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1334578624-23257-1-git-send-email-mgorman@suse.de>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Mel Gorman <mgorman@suse.de>

Introduce sk_allocation(), this function allows to inject sock specific
flags to each sock related allocation. It is only used on allocation
paths that may be required for writing pages back to network storage.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/net/sock.h    |    5 +++++
 net/ipv4/tcp.c        |    3 ++-
 net/ipv4/tcp_output.c |   16 +++++++++-------
 net/ipv6/tcp_ipv6.c   |    8 +++++---
 4 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index a6ba1f8..ba8a339 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -643,6 +643,11 @@ static inline int sock_flag(struct sock *sk, enum sock_flags flag)
 	return test_bit(flag, &sk->sk_flags);
 }
 
+static inline gfp_t sk_allocation(struct sock *sk, gfp_t gfp_mask)
+{
+	return gfp_mask;
+}
+
 static inline void sk_acceptq_removed(struct sock *sk)
 {
 	sk->sk_ack_backlog--;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5d54ed3..bb17467 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -698,7 +698,8 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 	/* The TCP header must be at least 32-bit aligned.  */
 	size = ALIGN(size, 4);
 
-	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
+	skb = alloc_skb_fclone(size + sk->sk_prot->max_header,
+			       sk_allocation(sk, gfp));
 	if (skb) {
 		if (sk_wmem_schedule(sk, skb->truesize)) {
 			/*
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 364784a..45c69d9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2345,7 +2345,7 @@ void tcp_send_fin(struct sock *sk)
 		/* Socket is locked, keep trying until memory is available. */
 		for (;;) {
 			skb = alloc_skb_fclone(MAX_TCP_HEADER,
-					       sk->sk_allocation);
+					sk_allocation(sk, sk->sk_allocation));
 			if (skb)
 				break;
 			yield();
@@ -2371,7 +2371,7 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	struct sk_buff *skb;
 
 	/* NOTE: No TCP options attached and we never retransmit this. */
-	skb = alloc_skb(MAX_TCP_HEADER, priority);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, priority));
 	if (!skb) {
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
 		return;
@@ -2444,7 +2444,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	if (cvp != NULL && cvp->s_data_constant && cvp->s_data_desired)
 		s_data_desired = cvp->s_data_desired;
-	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1, GFP_ATOMIC);
+	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1,
+					sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return NULL;
 
@@ -2634,7 +2635,8 @@ int tcp_connect(struct sock *sk)
 
 	tcp_connect_init(sk);
 
-	buff = alloc_skb_fclone(MAX_TCP_HEADER + 15, sk->sk_allocation);
+	buff = alloc_skb_fclone(MAX_TCP_HEADER + 15,
+				sk_allocation(sk, sk->sk_allocation));
 	if (unlikely(buff == NULL))
 		return -ENOBUFS;
 
@@ -2740,7 +2742,7 @@ void tcp_send_ack(struct sock *sk)
 	 * tcp_transmit_skb() will set the ownership to this
 	 * sock.
 	 */
-	buff = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	buff = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 	if (buff == NULL) {
 		inet_csk_schedule_ack(sk);
 		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
@@ -2755,7 +2757,7 @@ void tcp_send_ack(struct sock *sk)
 
 	/* Send it off, this clears delayed acks for us. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
-	tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
+	tcp_transmit_skb(sk, buff, 0, sk_allocation(sk, GFP_ATOMIC));
 }
 
 /* This routine sends a packet with an out of date sequence
@@ -2775,7 +2777,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	struct sk_buff *skb;
 
 	/* We don't queue it, tcp_transmit_skb() sets ownership. */
-	skb = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return -1;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 12c6ece..765a25a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1352,7 +1352,8 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	/* Clone pktoptions received with SYN */
 	newnp->pktoptions = NULL;
 	if (treq->pktopts != NULL) {
-		newnp->pktoptions = skb_clone(treq->pktopts, GFP_ATOMIC);
+		newnp->pktoptions = skb_clone(treq->pktopts,
+						sk_allocation(sk, GFP_ATOMIC));
 		kfree_skb(treq->pktopts);
 		treq->pktopts = NULL;
 		if (newnp->pktoptions)
@@ -1401,7 +1402,8 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		 * across. Shucks.
 		 */
 		tcp_md5_do_add(newsk, (union tcp_md5_addr *)&newnp->daddr,
-			       AF_INET6, key->key, key->keylen, GFP_ATOMIC);
+			       AF_INET6, key->key, key->keylen,
+			       sk_allocation(sk, GFP_ATOMIC));
 	}
 #endif
 
@@ -1496,7 +1498,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 					       --ANK (980728)
 	 */
 	if (np->rxopt.all)
-		opt_skb = skb_clone(skb, GFP_ATOMIC);
+		opt_skb = skb_clone(skb, sk_allocation(sk, GFP_ATOMIC));
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		sock_rps_save_rxhash(sk, skb);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
