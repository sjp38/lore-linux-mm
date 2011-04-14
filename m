Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BC867900088
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 06:41:47 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/12] netvm: Allow the use of __GFP_MEMALLOC by specific sockets
Date: Thu, 14 Apr 2011 11:41:33 +0100
Message-Id: <1302777698-28237-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1302777698-28237-1-git-send-email-mgorman@suse.de>
References: <1302777698-28237-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Allow specific sockets to be tagged SOCK_MEMALLOC and use __GFP_MEMALLOC
for their allocations. These sockets will be able to go below watermarks
and allocate from the emergency reserve. Such sockets are to be used
to service the VM (iow. to swap over). They must be handled kernel side,
exposing such a socket to user-space is a bug.

There is a risk that the reserves be depleted so for now, the administrator is
responsible for increasing min_free_kbytes as necessary to prevent deadlock
for their workloads.

[a.p.zijlstra@chello.nl: Original patches]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/net/sock.h |    5 ++++-
 net/core/sock.c    |   22 ++++++++++++++++++++++
 2 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index f687e0b..e6ead99 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -553,6 +553,7 @@ enum sock_flags {
 	SOCK_RCVTSTAMPNS, /* %SO_TIMESTAMPNS setting */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
+	SOCK_MEMALLOC, /* VM depends on this socket for swapping */
 	SOCK_TIMESTAMPING_TX_HARDWARE,  /* %SOF_TIMESTAMPING_TX_HARDWARE */
 	SOCK_TIMESTAMPING_TX_SOFTWARE,  /* %SOF_TIMESTAMPING_TX_SOFTWARE */
 	SOCK_TIMESTAMPING_RX_HARDWARE,  /* %SOF_TIMESTAMPING_RX_HARDWARE */
@@ -586,7 +587,7 @@ static inline int sock_flag(struct sock *sk, enum sock_flags flag)
 
 static inline gfp_t sk_allocation(struct sock *sk, gfp_t gfp_mask)
 {
-	return gfp_mask;
+	return gfp_mask | (sk->sk_allocation & __GFP_MEMALLOC);
 }
 
 static inline void sk_acceptq_removed(struct sock *sk)
@@ -716,6 +717,8 @@ extern int sk_stream_wait_memory(struct sock *sk, long *timeo_p);
 extern void sk_stream_wait_close(struct sock *sk, long timeo_p);
 extern int sk_stream_error(struct sock *sk, int flags, int err);
 extern void sk_stream_kill_queues(struct sock *sk);
+extern void sk_set_memalloc(struct sock *sk);
+extern void sk_clear_memalloc(struct sock *sk);
 
 extern int sk_wait_data(struct sock *sk, long *timeo);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 7dfed79..1deb48b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -219,6 +219,28 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
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
 #if defined(CONFIG_CGROUPS) && !defined(CONFIG_NET_CLS_CGROUP)
 int net_cls_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_cls_subsys_id);
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
