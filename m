Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 26FC2600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:27:07 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 14/31] net: sk_allocation() - concentrate socket related allocations
Date: Thu,  1 Oct 2009 19:37:22 +0530
Message-Id: <1254406042-16156-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl> 

Introduce sk_allocation(), this function allows to inject sock specific
flags to each sock related allocation.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 include/net/sock.h    |    5 +++++
 net/ipv4/tcp.c        |    3 ++-
 net/ipv4/tcp_output.c |   12 +++++++-----
 net/ipv6/tcp_ipv6.c   |   15 +++++++++++----
 4 files changed, 25 insertions(+), 10 deletions(-)

Index: mmotm/include/net/sock.h
===================================================================
--- mmotm.orig/include/net/sock.h
+++ mmotm/include/net/sock.h
@@ -526,6 +526,11 @@ static inline int sock_flag(struct sock
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
Index: mmotm/net/ipv4/tcp.c
===================================================================
--- mmotm.orig/net/ipv4/tcp.c
+++ mmotm/net/ipv4/tcp.c
@@ -645,7 +645,8 @@ struct sk_buff *sk_stream_alloc_skb(stru
 	/* The TCP header must be at least 32-bit aligned.  */
 	size = ALIGN(size, 4);
 
-	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
+	skb = alloc_skb_fclone(size + sk->sk_prot->max_header,
+			       sk_allocation(sk, gfp));
 	if (skb) {
 		if (sk_wmem_schedule(sk, skb->truesize)) {
 			/*
Index: mmotm/net/ipv4/tcp_output.c
===================================================================
--- mmotm.orig/net/ipv4/tcp_output.c
+++ mmotm/net/ipv4/tcp_output.c
@@ -2101,7 +2101,8 @@ void tcp_send_fin(struct sock *sk)
 	} else {
 		/* Socket is locked, keep trying until memory is available. */
 		for (;;) {
-			skb = alloc_skb_fclone(MAX_TCP_HEADER, GFP_KERNEL);
+			skb = alloc_skb_fclone(MAX_TCP_HEADER,
+					       sk_allocation(sk, GFP_KERNEL));
 			if (skb)
 				break;
 			yield();
@@ -2127,7 +2128,7 @@ void tcp_send_active_reset(struct sock *
 	struct sk_buff *skb;
 
 	/* NOTE: No TCP options attached and we never retransmit this. */
-	skb = alloc_skb(MAX_TCP_HEADER, priority);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, priority));
 	if (!skb) {
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
 		return;
@@ -2196,7 +2197,8 @@ struct sk_buff *tcp_make_synack(struct s
 	__u8 *md5_hash_location;
 	int mss;
 
-	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
+	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1,
+			sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return NULL;
 
@@ -2443,7 +2445,7 @@ void tcp_send_ack(struct sock *sk)
 	 * tcp_transmit_skb() will set the ownership to this
 	 * sock.
 	 */
-	buff = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	buff = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 	if (buff == NULL) {
 		inet_csk_schedule_ack(sk);
 		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
@@ -2478,7 +2480,7 @@ static int tcp_xmit_probe_skb(struct soc
 	struct sk_buff *skb;
 
 	/* We don't queue it, tcp_transmit_skb() sets ownership. */
-	skb = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return -1;
 
Index: mmotm/net/ipv6/tcp_ipv6.c
===================================================================
--- mmotm.orig/net/ipv6/tcp_ipv6.c
+++ mmotm/net/ipv6/tcp_ipv6.c
@@ -584,7 +584,8 @@ static int tcp_v6_md5_do_add(struct sock
 	} else {
 		/* reallocate new list if current one is full. */
 		if (!tp->md5sig_info) {
-			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info), GFP_ATOMIC);
+			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info),
+					sk_allocation(sk, GFP_ATOMIC));
 			if (!tp->md5sig_info) {
 				kfree(newkey);
 				return -ENOMEM;
@@ -597,7 +598,8 @@ static int tcp_v6_md5_do_add(struct sock
 		}
 		if (tp->md5sig_info->alloced6 == tp->md5sig_info->entries6) {
 			keys = kmalloc((sizeof (tp->md5sig_info->keys6[0]) *
-				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
+				       (tp->md5sig_info->entries6 + 1)),
+				       sk_allocation(sk, GFP_ATOMIC));
 
 			if (!keys) {
 				tcp_free_md5sig_pool();
@@ -721,7 +723,8 @@ static int tcp_v6_parse_md5_keys (struct
 		struct tcp_sock *tp = tcp_sk(sk);
 		struct tcp_md5sig_info *p;
 
-		p = kzalloc(sizeof(struct tcp_md5sig_info), GFP_KERNEL);
+		p = kzalloc(sizeof(struct tcp_md5sig_info),
+				   sk_allocation(sk, GFP_KERNEL));
 		if (!p)
 			return -ENOMEM;
 
@@ -987,6 +990,7 @@ static void tcp_v6_send_response(struct
 	unsigned int tot_len = sizeof(struct tcphdr);
 	struct dst_entry *dst;
 	__be32 *topt;
+	gfp_t gfp_mask = GFP_ATOMIC;
 
 	if (ts)
 		tot_len += TCPOLEN_TSTAMP_ALIGNED;
@@ -996,7 +1000,7 @@ static void tcp_v6_send_response(struct
 #endif
 
 	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
-			 GFP_ATOMIC);
+			 gfp_mask);
 	if (buff == NULL)
 		return;
 
@@ -1073,6 +1077,7 @@ static void tcp_v6_send_reset(struct soc
 	struct tcphdr *th = tcp_hdr(skb);
 	u32 seq = 0, ack_seq = 0;
 	struct tcp_md5sig_key *key = NULL;
+	gfp_t gfp_mask = GFP_ATOMIC;
 
 	if (th->rst)
 		return;
@@ -1084,6 +1089,8 @@ static void tcp_v6_send_reset(struct soc
 	if (sk)
 		key = tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr);
 #endif
+	if (sk)
+		gfp_mask = sk_allocation(sk, gfp_mask);
 
 	if (th->ack)
 		seq = ntohl(th->ack_seq);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
