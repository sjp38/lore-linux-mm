Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id BA2506B007B
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:40:47 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/16] netvm: Allow the use of __GFP_MEMALLOC by specific sockets
Date: Thu, 12 Jul 2012 07:40:24 +0100
Message-Id: <1342075232-29267-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075232-29267-1-git-send-email-mgorman@suse.de>
References: <1342075232-29267-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

Allow specific sockets to be tagged SOCK_MEMALLOC and use
__GFP_MEMALLOC for their allocations. These sockets will be able to go
below watermarks and allocate from the emergency reserve. Such sockets
are to be used to service the VM (iow. to swap over). They must be
handled kernel side, exposing such a socket to user-space is a bug.

There is a risk that the reserves be depleted so for now, the
administrator is responsible for increasing min_free_kbytes as
necessary to prevent deadlock for their workloads.

[a.p.zijlstra@chello.nl: Original patches]
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: David S. Miller <davem@davemloft.net>
---
 include/net/sock.h |    5 ++++-
 net/core/sock.c    |   22 ++++++++++++++++++++++
 2 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index d6ee4c6..a52e02a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -621,6 +621,7 @@ enum sock_flags {
 	SOCK_RCVTSTAMPNS, /* %SO_TIMESTAMPNS setting */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
+	SOCK_MEMALLOC, /* VM depends on this socket for swapping */
 	SOCK_TIMESTAMPING_TX_HARDWARE,  /* %SOF_TIMESTAMPING_TX_HARDWARE */
 	SOCK_TIMESTAMPING_TX_SOFTWARE,  /* %SOF_TIMESTAMPING_TX_SOFTWARE */
 	SOCK_TIMESTAMPING_RX_HARDWARE,  /* %SOF_TIMESTAMPING_RX_HARDWARE */
@@ -660,7 +661,7 @@ static inline bool sock_flag(const struct sock *sk, enum sock_flags flag)
 
 static inline gfp_t sk_gfp_atomic(struct sock *sk, gfp_t gfp_mask)
 {
-	return GFP_ATOMIC;
+	return GFP_ATOMIC | (sk->sk_allocation & __GFP_MEMALLOC);
 }
 
 static inline void sk_acceptq_removed(struct sock *sk)
@@ -803,6 +804,8 @@ extern int sk_stream_wait_memory(struct sock *sk, long *timeo_p);
 extern void sk_stream_wait_close(struct sock *sk, long timeo_p);
 extern int sk_stream_error(struct sock *sk, int flags, int err);
 extern void sk_stream_kill_queues(struct sock *sk);
+extern void sk_set_memalloc(struct sock *sk);
+extern void sk_clear_memalloc(struct sock *sk);
 
 extern int sk_wait_data(struct sock *sk, long *timeo);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index a42c772..b6bb8fd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -271,6 +271,28 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
 
+/**
+ * sk_set_memalloc - sets %SOCK_MEMALLOC
+ * @sk: socket to set it on
+ *
+ * Set %SOCK_MEMALLOC on a socket for access to emergency reserves.
+ * It's the responsibility of the admin to adjust min_free_kbytes
+ * to meet the requirements
+ */
+void sk_set_memalloc(struct sock *sk)
+{
+	sock_set_flag(sk, SOCK_MEMALLOC);
+	sk->sk_allocation |= __GFP_MEMALLOC;
+}
+EXPORT_SYMBOL_GPL(sk_set_memalloc);
+
+void sk_clear_memalloc(struct sock *sk)
+{
+	sock_reset_flag(sk, SOCK_MEMALLOC);
+	sk->sk_allocation &= ~__GFP_MEMALLOC;
+}
+EXPORT_SYMBOL_GPL(sk_clear_memalloc);
+
 #if defined(CONFIG_CGROUPS)
 #if !defined(CONFIG_NET_CLS_CGROUP)
 int net_cls_subsys_id = -1;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
