Message-Id: <20070221144842.497037000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Date: Wed, 21 Feb 2007 15:43:14 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 10/29] net: wrap sk->sk_backlog_rcv()
Content-Disposition: inline; filename=net-backlog.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Wrap calling sk->sk_backlog_rcv() in a function. This will allow extending the
generic sk_backlog_rcv behaviour.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h   |    5 +++++
 net/core/sock.c      |    4 ++--
 net/ipv4/tcp.c       |    2 +-
 net/ipv4/tcp_timer.c |    2 +-
 4 files changed, 9 insertions(+), 4 deletions(-)

Index: linux-2.6-git/include/net/sock.h
===================================================================
--- linux-2.6-git.orig/include/net/sock.h	2007-02-14 11:29:55.000000000 +0100
+++ linux-2.6-git/include/net/sock.h	2007-02-14 11:42:00.000000000 +0100
@@ -480,6 +480,11 @@ static inline void sk_add_backlog(struct
 	skb->next = NULL;
 }
 
+static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	return sk->sk_backlog_rcv(sk, skb);
+}
+
 #define sk_wait_event(__sk, __timeo, __condition)		\
 ({	int rc;							\
 	release_sock(__sk);					\
Index: linux-2.6-git/net/core/sock.c
===================================================================
--- linux-2.6-git.orig/net/core/sock.c	2007-02-14 11:29:55.000000000 +0100
+++ linux-2.6-git/net/core/sock.c	2007-02-14 11:42:00.000000000 +0100
@@ -290,7 +290,7 @@ int sk_receive_skb(struct sock *sk, stru
 		 */
 		mutex_acquire(&sk->sk_lock.dep_map, 0, 1, _RET_IP_);
 
-		rc = sk->sk_backlog_rcv(sk, skb);
+		rc = sk_backlog_rcv(sk, skb);
 
 		mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
 	} else
@@ -1244,7 +1244,7 @@ static void __release_sock(struct sock *
 			struct sk_buff *next = skb->next;
 
 			skb->next = NULL;
-			sk->sk_backlog_rcv(sk, skb);
+			sk_backlog_rcv(sk, skb);
 
 			/*
 			 * We are in process context here with softirqs
Index: linux-2.6-git/net/ipv4/tcp.c
===================================================================
--- linux-2.6-git.orig/net/ipv4/tcp.c	2007-02-14 11:29:35.000000000 +0100
+++ linux-2.6-git/net/ipv4/tcp.c	2007-02-14 11:42:00.000000000 +0100
@@ -1002,7 +1002,7 @@ static void tcp_prequeue_process(struct 
 	 * necessary */
 	local_bh_disable();
 	while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
-		sk->sk_backlog_rcv(sk, skb);
+		sk_backlog_rcv(sk, skb);
 	local_bh_enable();
 
 	/* Clear memory counter. */
Index: linux-2.6-git/net/ipv4/tcp_timer.c
===================================================================
--- linux-2.6-git.orig/net/ipv4/tcp_timer.c	2007-02-14 11:29:36.000000000 +0100
+++ linux-2.6-git/net/ipv4/tcp_timer.c	2007-02-14 11:42:00.000000000 +0100
@@ -198,7 +198,7 @@ static void tcp_delack_timer(unsigned lo
 		NET_INC_STATS_BH(LINUX_MIB_TCPSCHEDULERFAILED);
 
 		while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
-			sk->sk_backlog_rcv(sk, skb);
+			sk_backlog_rcv(sk, skb);
 
 		tp->ucopy.memory = 0;
 	}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
