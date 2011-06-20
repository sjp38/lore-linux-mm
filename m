Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 58F7B6B00EE
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:12:29 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/14] net: Introduce sk_allocation() to allow addition of GFP flags depending on the individual socket
Date: Mon, 20 Jun 2011 14:12:12 +0100
Message-Id: <1308575540-25219-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1308575540-25219-1-git-send-email-mgorman@suse.de>
References: <1308575540-25219-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Introduce sk_allocation(), this function allows to inject sock specific
flags to each sock related allocation. It is only used on allocation
paths that may be required for writing pages back to network storage.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/net/sock.h    |    5 +++++
 net/ipv4/tcp.c        |    3 ++-
 net/ipv4/tcp_output.c |   13 +++++++------
 net/ipv6/tcp_ipv6.c   |   12 +++++++++---
 4 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index f2046e4..e89c38f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -585,6 +585,11 @@ static inline int sock_flag(struct sock *sk, enum sock_flags flag)
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
index 054a59d..8c1a9d5 100644
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
index 882e0b0..87b98f6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2324,7 +2324,7 @@ void tcp_send_fin(struct sock *sk)
 		/* Socket is locked, keep trying until memory is available. */
 		for (;;) {
 			skb = alloc_skb_fclone(MAX_TCP_HEADER,
-					       sk->sk_allocation);
+					       sk_allocation(sk, GFP_KERNEL));
 			if (skb)
 				break;
 			yield();
@@ -2350,7 +2350,7 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	struct sk_buff *skb;
 
 	/* NOTE: No TCP options attached and we never retransmit this. */
-	skb = alloc_skb(MAX_TCP_HEADER, priority);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, priority));
 	if (!skb) {
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
 		return;
@@ -2423,7 +2423,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	if (cvp != NULL && cvp->s_data_constant && cvp->s_data_desired)
 		s_data_desired = cvp->s_data_desired;
-	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1, GFP_ATOMIC);
+	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1,
+					sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return NULL;
 
@@ -2719,7 +2720,7 @@ void tcp_send_ack(struct sock *sk)
 	 * tcp_transmit_skb() will set the ownership to this
 	 * sock.
 	 */
-	buff = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	buff = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 	if (buff == NULL) {
 		inet_csk_schedule_ack(sk);
 		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
@@ -2734,7 +2735,7 @@ void tcp_send_ack(struct sock *sk)
 
 	/* Send it off, this clears delayed acks for us. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
-	tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
+	tcp_transmit_skb(sk, buff, 0, sk_allocation(sk, GFP_ATOMIC));
 }
 
 /* This routine sends a packet with an out of date sequence
@@ -2754,7 +2755,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	struct sk_buff *skb;
 
 	/* We don't queue it, tcp_transmit_skb() sets ownership. */
-	skb = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return -1;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d1fd287..62bc424 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -597,7 +597,8 @@ static int tcp_v6_md5_do_add(struct sock *sk, const struct in6_addr *peer,
 	} else {
 		/* reallocate new list if current one is full. */
 		if (!tp->md5sig_info) {
-			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info), GFP_ATOMIC);
+			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info),
+					sk_allocation(sk, GFP_ATOMIC));
 			if (!tp->md5sig_info) {
 				kfree(newkey);
 				return -ENOMEM;
@@ -610,7 +611,8 @@ static int tcp_v6_md5_do_add(struct sock *sk, const struct in6_addr *peer,
 		}
 		if (tp->md5sig_info->alloced6 == tp->md5sig_info->entries6) {
 			keys = kmalloc((sizeof (tp->md5sig_info->keys6[0]) *
-				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
+				       (tp->md5sig_info->entries6 + 1)),
+				       sk_allocation(sk, GFP_ATOMIC));
 
 			if (!keys) {
 				tcp_free_md5sig_pool();
@@ -734,7 +736,8 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 		struct tcp_sock *tp = tcp_sk(sk);
 		struct tcp_md5sig_info *p;
 
-		p = kzalloc(sizeof(struct tcp_md5sig_info), GFP_KERNEL);
+		p = kzalloc(sizeof(struct tcp_md5sig_info),
+				   sk_allocation(sk, GFP_KERNEL));
 		if (!p)
 			return -ENOMEM;
 
@@ -1084,6 +1087,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	struct tcphdr *th = tcp_hdr(skb);
 	u32 seq = 0, ack_seq = 0;
 	struct tcp_md5sig_key *key = NULL;
+	gfp_t gfp_mask = GFP_ATOMIC;
 
 	if (th->rst)
 		return;
@@ -1095,6 +1099,8 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	if (sk)
 		key = tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr);
 #endif
+	if (sk)
+		gfp_mask = sk_allocation(sk, gfp_mask);
 
 	if (th->ack)
 		seq = ntohl(th->ack_seq);
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
