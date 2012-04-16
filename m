Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 1981B6B00F8
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 08:18:01 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 01/11] netvm: Prevent a stream-specific deadlock
Date: Mon, 16 Apr 2012 13:17:45 +0100
Message-Id: <1334578675-23445-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1334578675-23445-1-git-send-email-mgorman@suse.de>
References: <1334578675-23445-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Mel Gorman <mgorman@suse.de>

It could happen that all !SOCK_MEMALLOC sockets have buffered so
much data that we're over the global rmem limit. This will prevent
SOCK_MEMALLOC buffers from receiving data, which will prevent userspace
from running, which is needed to reduce the buffered data.

Fix this by exempting the SOCK_MEMALLOC sockets from the rmem limit.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/net/sock.h     |    7 ++++---
 net/caif/caif_socket.c |    2 +-
 net/core/sock.c        |    2 +-
 net/ipv4/tcp_input.c   |   12 ++++++------
 net/sctp/ulpevent.c    |    2 +-
 5 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index de6ebda..733d614 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1279,12 +1279,13 @@ static inline int sk_wmem_schedule(struct sock *sk, int size)
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
+		skb_pfmemalloc(skb);
 }
 
 static inline void sk_mem_reclaim(struct sock *sk)
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 5016fa5..aaf711c 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -142,7 +142,7 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	err = sk_filter(sk, skb);
 	if (err)
 		return err;
-	if (!sk_rmem_schedule(sk, skb->truesize) && rx_flow_is_on(cf_sk)) {
+	if (!sk_rmem_schedule(sk, skb) && rx_flow_is_on(cf_sk)) {
 		set_rx_flow_off(cf_sk);
 		if (net_ratelimit())
 			pr_debug("sending flow OFF due to rmem_schedule\n");
diff --git a/net/core/sock.c b/net/core/sock.c
index 9ad1ed9..4193266 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -391,7 +391,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (err)
 		return err;
 
-	if (!sk_rmem_schedule(sk, skb->truesize)) {
+	if (!sk_rmem_schedule(sk, skb)) {
 		atomic_inc(&sk->sk_drops);
 		return -ENOBUFS;
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e886e2f..330c097 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4427,19 +4427,19 @@ static void tcp_ofo_queue(struct sock *sk)
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
@@ -4454,7 +4454,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 
 	TCP_ECN_check_ce(tp, skb);
 
-	if (tcp_try_rmem_schedule(sk, skb->truesize)) {
+	if (tcp_try_rmem_schedule(sk, skb)) {
 		/* TODO: should increment a counter */
 		__kfree_skb(skb);
 		return;
@@ -4623,7 +4623,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 		if (eaten <= 0) {
 queue_and_out:
 			if (eaten < 0 &&
-			    tcp_try_rmem_schedule(sk, skb->truesize))
+			    tcp_try_rmem_schedule(sk, skb))
 				goto drop;
 
 			skb_set_owner_r(skb, sk);
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
