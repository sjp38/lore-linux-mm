Message-Id: <20070504103158.425942315@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:04 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 13/40] net: sk_allocation() - concentrate socket related allocations
Content-Disposition: inline; filename=net-sk_allocation.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Introduce sk_allocation(), this function allows to inject sock specific
flags to each sock related allocation.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h    |    7 ++++++-
 net/ipv4/tcp_output.c |   11 ++++++-----
 net/ipv6/tcp_ipv6.c   |   14 +++++++++-----
 3 files changed, 21 insertions(+), 11 deletions(-)

Index: linux-2.6-git/net/ipv4/tcp_output.c
===================================================================
--- linux-2.6-git.orig/net/ipv4/tcp_output.c
+++ linux-2.6-git/net/ipv4/tcp_output.c
@@ -2011,7 +2011,7 @@ void tcp_send_fin(struct sock *sk)
 	} else {
 		/* Socket is locked, keep trying until memory is available. */
 		for (;;) {
-			skb = alloc_skb_fclone(MAX_TCP_HEADER, GFP_KERNEL);
+			skb = alloc_skb_fclone(MAX_TCP_HEADER, sk->sk_allocation);
 			if (skb)
 				break;
 			yield();
@@ -2044,7 +2044,7 @@ void tcp_send_active_reset(struct sock *
 	struct sk_buff *skb;
 
 	/* NOTE: No TCP options attached and we never retransmit this. */
-	skb = alloc_skb(MAX_TCP_HEADER, priority);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, priority));
 	if (!skb) {
 		NET_INC_STATS(LINUX_MIB_TCPABORTFAILED);
 		return;
@@ -2117,7 +2117,8 @@ struct sk_buff * tcp_make_synack(struct 
 	__u8 *md5_hash_location;
 #endif
 
-	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
+	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1,
+			sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return NULL;
 
@@ -2376,7 +2377,7 @@ void tcp_send_ack(struct sock *sk)
 		 * tcp_transmit_skb() will set the ownership to this
 		 * sock.
 		 */
-		buff = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+		buff = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 		if (buff == NULL) {
 			inet_csk_schedule_ack(sk);
 			inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
@@ -2418,7 +2419,7 @@ static int tcp_xmit_probe_skb(struct soc
 	struct sk_buff *skb;
 
 	/* We don't queue it, tcp_transmit_skb() sets ownership. */
-	skb = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	skb = alloc_skb(MAX_TCP_HEADER, sk_allocation(sk, GFP_ATOMIC));
 	if (skb == NULL)
 		return -1;
 
Index: linux-2.6-git/include/net/sock.h
===================================================================
--- linux-2.6-git.orig/include/net/sock.h
+++ linux-2.6-git/include/net/sock.h
@@ -415,6 +415,11 @@ static inline int sock_flag(struct sock 
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
@@ -1207,7 +1212,7 @@ static inline struct sk_buff *sk_stream_
 	int hdr_len;
 
 	hdr_len = SKB_DATA_ALIGN(sk->sk_prot->max_header);
-	skb = alloc_skb_fclone(size + hdr_len, gfp);
+	skb = alloc_skb_fclone(size + hdr_len, sk_allocation(sk, gfp));
 	if (skb) {
 		skb->truesize += mem;
 		if (sk_stream_wmem_schedule(sk, skb->truesize)) {
Index: linux-2.6-git/net/ipv6/tcp_ipv6.c
===================================================================
--- linux-2.6-git.orig/net/ipv6/tcp_ipv6.c
+++ linux-2.6-git/net/ipv6/tcp_ipv6.c
@@ -581,7 +581,8 @@ static int tcp_v6_md5_do_add(struct sock
 	} else {
 		/* reallocate new list if current one is full. */
 		if (!tp->md5sig_info) {
-			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info), GFP_ATOMIC);
+			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info),
+					sk_allocation(sk, GFP_ATOMIC));
 			if (!tp->md5sig_info) {
 				kfree(newkey);
 				return -ENOMEM;
@@ -590,7 +591,8 @@ static int tcp_v6_md5_do_add(struct sock
 		tcp_alloc_md5sig_pool();
 		if (tp->md5sig_info->alloced6 == tp->md5sig_info->entries6) {
 			keys = kmalloc((sizeof (tp->md5sig_info->keys6[0]) *
-				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
+				       (tp->md5sig_info->entries6 + 1)),
+				       sk_allocation(sk, GFP_ATOMIC));
 
 			if (!keys) {
 				tcp_free_md5sig_pool();
@@ -715,7 +717,7 @@ static int tcp_v6_parse_md5_keys (struct
 		struct tcp_sock *tp = tcp_sk(sk);
 		struct tcp_md5sig_info *p;
 
-		p = kzalloc(sizeof(struct tcp_md5sig_info), GFP_KERNEL);
+		p = kzalloc(sizeof(struct tcp_md5sig_info), sk->allocation);
 		if (!p)
 			return -ENOMEM;
 
@@ -1011,7 +1013,7 @@ static void tcp_v6_send_reset(struct soc
 	 */
 
 	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
-			 GFP_ATOMIC);
+			 sk_allocation(sk, GFP_ATOMIC));
 	if (buff == NULL)
 		return;
 
@@ -1090,10 +1092,12 @@ static void tcp_v6_send_ack(struct tcp_t
 	struct tcp_md5sig_key *key;
 	struct tcp_md5sig_key tw_key;
 #endif
+	gfp_t gfp_mask = GFP_ATOMIC;
 
 #ifdef CONFIG_TCP_MD5SIG
 	if (!tw && skb->sk) {
 		key = tcp_v6_md5_do_lookup(skb->sk, &ipv6_hdr(skb)->daddr);
+		gfp_mask = sk_allocation(skb->sk, gfp_mask);
 	} else if (tw && tw->tw_md5_keylen) {
 		tw_key.key = tw->tw_md5_key;
 		tw_key.keylen = tw->tw_md5_keylen;
@@ -1111,7 +1115,7 @@ static void tcp_v6_send_ack(struct tcp_t
 #endif
 
 	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
-			 GFP_ATOMIC);
+			 gfp_mask);
 	if (buff == NULL)
 		return;
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
