Message-Id: <20081002131608.667433428@chello.nl>
References: <20081002130504.927878499@chello.nl>
Date: Thu, 02 Oct 2008 15:05:20 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 16/32] net: wrap sk->sk_backlog_rcv()
Content-Disposition: inline; filename=net-backlog.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Wrap calling sk->sk_backlog_rcv() in a function. This will allow extending the
generic sk_backlog_rcv behaviour.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h   |    5 +++++
 include/net/tcp.h    |    2 +-
 net/core/sock.c      |    4 ++--
 net/ipv4/tcp.c       |    2 +-
 net/ipv4/tcp_timer.c |    2 +-
 5 files changed, 10 insertions(+), 5 deletions(-)

Index: linux-2.6/include/net/sock.h
===================================================================
--- linux-2.6.orig/include/net/sock.h
+++ linux-2.6/include/net/sock.h
@@ -482,6 +482,11 @@ static inline void sk_add_backlog(struct
 	skb->next = NULL;
 }
 
+static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	return sk->sk_backlog_rcv(sk, skb);
+}
+
 #define sk_wait_event(__sk, __timeo, __condition)			\
 	({	int __rc;						\
 		release_sock(__sk);					\
Index: linux-2.6/net/core/sock.c
===================================================================
--- linux-2.6.orig/net/core/sock.c
+++ linux-2.6/net/core/sock.c
@@ -324,7 +324,7 @@ int sk_receive_skb(struct sock *sk, stru
 		 */
 		mutex_acquire(&sk->sk_lock.dep_map, 0, 1, _RET_IP_);
 
-		rc = sk->sk_backlog_rcv(sk, skb);
+		rc = sk_backlog_rcv(sk, skb);
 
 		mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
 	} else
@@ -1371,7 +1371,7 @@ static void __release_sock(struct sock *
 			struct sk_buff *next = skb->next;
 
 			skb->next = NULL;
-			sk->sk_backlog_rcv(sk, skb);
+			sk_backlog_rcv(sk, skb);
 
 			/*
 			 * We are in process context here with softirqs
Index: linux-2.6/net/ipv4/tcp.c
===================================================================
--- linux-2.6.orig/net/ipv4/tcp.c
+++ linux-2.6/net/ipv4/tcp.c
@@ -1157,7 +1157,7 @@ static void tcp_prequeue_process(struct 
 	 * necessary */
 	local_bh_disable();
 	while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
-		sk->sk_backlog_rcv(sk, skb);
+		sk_backlog_rcv(sk, skb);
 	local_bh_enable();
 
 	/* Clear memory counter. */
Index: linux-2.6/net/ipv4/tcp_timer.c
===================================================================
--- linux-2.6.orig/net/ipv4/tcp_timer.c
+++ linux-2.6/net/ipv4/tcp_timer.c
@@ -201,7 +201,7 @@ static void tcp_delack_timer(unsigned lo
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSCHEDULERFAILED);
 
 		while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
-			sk->sk_backlog_rcv(sk, skb);
+			sk_backlog_rcv(sk, skb);
 
 		tp->ucopy.memory = 0;
 	}
Index: linux-2.6/include/net/tcp.h
===================================================================
--- linux-2.6.orig/include/net/tcp.h
+++ linux-2.6/include/net/tcp.h
@@ -894,7 +894,7 @@ static inline int tcp_prequeue(struct so
 			BUG_ON(sock_owned_by_user(sk));
 
 			while ((skb1 = __skb_dequeue(&tp->ucopy.prequeue)) != NULL) {
-				sk->sk_backlog_rcv(sk, skb1);
+				sk_backlog_rcv(sk, skb1);
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPPREQUEUEDROPPED);
 			}
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
