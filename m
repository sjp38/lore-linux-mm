Message-Id: <20081002131608.821584767@chello.nl>
References: <20081002130504.927878499@chello.nl>
Date: Thu, 02 Oct 2008 15:05:22 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 18/32] net: sk_allocation() - concentrate socket related allocations
Content-Disposition: inline; filename=net-sk_allocation.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Introduce sk_allocation(), this function allows to inject sock specific
flags to each sock related allocation.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h    |    5 +++++
 net/ipv4/tcp.c        |    3 ++-
 net/ipv4/tcp_output.c |   12 +++++++-----
 net/ipv6/tcp_ipv6.c   |   17 ++++++++++++-----
 4 files changed, 26 insertions(+), 11 deletions(-)

Index: linux-2.6/net/ipv4/tcp_output.c
===================================================================
--- linux-2.6.orig/net/ipv4/tcp_output.c
+++ linux-2.6/net/ipv4/tcp_output.c
@@ -2148,7 +2148,8 @@ void tcp_send_fin(struct sock *sk)
 	} else {
 		/* Socket is locked, keep trying until memory is available. */
 		for (;;) {
-			skb = alloc_skb_fclone(MAX_TCP_HEADER, GFP_KERNEL);
+			skb = alloc_skb_fclone(MAX_TCP_HEADER,
+					       sk_allocation(sk, GFP_KERNEL));
 			if (skb)
 				break;
 			yield();
@@ -2174,7 +2175,7 @@ void tcp_send_active_reset(struct sock *
 	struct sk_buff *skb;
 
 	/* NOTE: No TCP options attached and we never retransmit this. */
-	skb = alloc_skb(MAX_TCP_HEADER, priority);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, priority));
 	if (!skb) {
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
 		return;
@@ -2242,7 +2243,8 @@ struct sk_buff *tcp_make_synack(struct s
 	struct tcp_md5sig_key *md5;
 	__u8 *md5_hash_location;
 
-	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
+	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1,
+			sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return NULL;
 
@@ -2482,7 +2484,7 @@ void tcp_send_ack(struct sock *sk)
 	 * tcp_transmit_skb() will set the ownership to this
 	 * sock.
 	 */
-	buff = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	buff = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 	if (buff == NULL) {
 		inet_csk_schedule_ack(sk);
 		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
@@ -2517,7 +2519,7 @@ static int tcp_xmit_probe_skb(struct soc
 	struct sk_buff *skb;
 
 	/* We don't queue it, tcp_transmit_skb() sets ownership. */
-	skb = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return -1;
 
Index: linux-2.6/include/net/sock.h
===================================================================
--- linux-2.6.orig/include/net/sock.h
+++ linux-2.6/include/net/sock.h
@@ -435,6 +435,11 @@ static inline int sock_flag(struct sock 
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
Index: linux-2.6/net/ipv6/tcp_ipv6.c
===================================================================
--- linux-2.6.orig/net/ipv6/tcp_ipv6.c
+++ linux-2.6/net/ipv6/tcp_ipv6.c
@@ -582,7 +582,8 @@ static int tcp_v6_md5_do_add(struct sock
 	} else {
 		/* reallocate new list if current one is full. */
 		if (!tp->md5sig_info) {
-			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info), GFP_ATOMIC);
+			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info),
+					sk_allocation(sk, GFP_ATOMIC));
 			if (!tp->md5sig_info) {
 				kfree(newkey);
 				return -ENOMEM;
@@ -595,7 +596,8 @@ static int tcp_v6_md5_do_add(struct sock
 		}
 		if (tp->md5sig_info->alloced6 == tp->md5sig_info->entries6) {
 			keys = kmalloc((sizeof (tp->md5sig_info->keys6[0]) *
-				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
+				       (tp->md5sig_info->entries6 + 1)),
+				       sk_allocation(sk, GFP_ATOMIC));
 
 			if (!keys) {
 				tcp_free_md5sig_pool();
@@ -719,7 +721,8 @@ static int tcp_v6_parse_md5_keys (struct
 		struct tcp_sock *tp = tcp_sk(sk);
 		struct tcp_md5sig_info *p;
 
-		p = kzalloc(sizeof(struct tcp_md5sig_info), GFP_KERNEL);
+		p = kzalloc(sizeof(struct tcp_md5sig_info),
+				   sk_allocation(sk, GFP_KERNEL));
 		if (!p)
 			return -ENOMEM;
 
@@ -952,6 +955,7 @@ static void tcp_v6_send_reset(struct soc
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
 #endif
+	gfp_t gfp_mask = GFP_ATOMIC;
 
 	if (th->rst)
 		return;
@@ -969,13 +973,16 @@ static void tcp_v6_send_reset(struct soc
 		tot_len += TCPOLEN_MD5SIG_ALIGNED;
 #endif
 
+	if (sk)
+		gfp_mask = sk_allocation(skb->sk, gfp_mask);
+
 	/*
 	 * We need to grab some memory, and put together an RST,
 	 * and then put it into the queue to be sent.
 	 */
 
 	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
-			 GFP_ATOMIC);
+			 sk_allocation(sk, GFP_ATOMIC));
 	if (buff == NULL)
 		return;
 
@@ -1063,7 +1070,7 @@ static void tcp_v6_send_ack(struct sk_bu
 #endif
 
 	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
-			 GFP_ATOMIC);
+			 sk_allocation(ctl_sk, GFP_ATOMIC));
 	if (buff == NULL)
 		return;
 
Index: linux-2.6/net/ipv4/tcp.c
===================================================================
--- linux-2.6.orig/net/ipv4/tcp.c
+++ linux-2.6/net/ipv4/tcp.c
@@ -635,7 +635,8 @@ struct sk_buff *sk_stream_alloc_skb(stru
 	/* The TCP header must be at least 32-bit aligned.  */
 	size = ALIGN(size, 4);
 
-	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
+	skb = alloc_skb_fclone(size + sk->sk_prot->max_header,
+			       sk_allocation(sk, gfp));
 	if (skb) {
 		if (sk_wmem_schedule(sk, skb->truesize)) {
 			/*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
