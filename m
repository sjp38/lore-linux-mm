Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88F7A600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:27:15 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 15/31] netvm: network reserve infrastructure
Date: Thu,  1 Oct 2009 19:37:34 +0530
Message-Id: <1254406054-16192-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl> 

Provide the basic infrastructure to reserve and charge/account network memory.

We provide the following reserve tree:

1)  total network reserve
2)    network TX reserve
3)      protocol TX pages
4)    network RX reserve
5)      SKB data reserve

[1] is used to make all the network reserves a single subtree, for easy
manipulation.

[2] and [4] are merely for eastetic reasons.

The TX pages reserve [3] is assumed bounded by it being the upper bound of
memory that can be used for sending pages (not quite true, but good enough)

The SKB reserve [5] is an aggregate reserve, which is used to charge SKB data
against in the fallback path.

The consumers for these reserves are sockets marked with:
  SOCK_MEMALLOC

Such sockets are to be used to service the VM (iow. to swap over). They
must be handled kernel side, exposing such a socket to user-space is a BUG.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 include/net/sock.h |   43 ++++++++++++++++++++-
 net/Kconfig        |    3 +
 net/core/sock.c    |  107 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 152 insertions(+), 1 deletion(-)

Index: mmotm/include/net/sock.h
===================================================================
--- mmotm.orig/include/net/sock.h
+++ mmotm/include/net/sock.h
@@ -51,6 +51,7 @@
 #include <linux/skbuff.h>	/* struct sk_buff */
 #include <linux/mm.h>
 #include <linux/security.h>
+#include <linux/reserve.h>
 
 #include <linux/filter.h>
 #include <linux/rculist_nulls.h>
@@ -497,6 +498,7 @@ enum sock_flags {
 	SOCK_RCVTSTAMPNS, /* %SO_TIMESTAMPNS setting */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
+	SOCK_MEMALLOC, /* the VM depends on us - make sure we're serviced */
 	SOCK_TIMESTAMPING_TX_HARDWARE,  /* %SOF_TIMESTAMPING_TX_HARDWARE */
 	SOCK_TIMESTAMPING_TX_SOFTWARE,  /* %SOF_TIMESTAMPING_TX_SOFTWARE */
 	SOCK_TIMESTAMPING_RX_HARDWARE,  /* %SOF_TIMESTAMPING_RX_HARDWARE */
@@ -526,9 +528,48 @@ static inline int sock_flag(struct sock
 	return test_bit(flag, &sk->sk_flags);
 }
 
+static inline int sk_has_memalloc(struct sock *sk)
+{
+	return sock_flag(sk, SOCK_MEMALLOC);
+}
+
+extern struct mem_reserve net_rx_reserve;
+extern struct mem_reserve net_skb_reserve;
+
+#ifdef CONFIG_NETVM
+/*
+ * Guestimate the per request queue TX upper bound.
+ *
+ * Max packet size is 64k, and we need to reserve that much since the data
+ * might need to bounce it. Double it to be on the safe side.
+ */
+#define TX_RESERVE_PAGES DIV_ROUND_UP(2*65536, PAGE_SIZE)
+
+extern int memalloc_socks;
+
+static inline int sk_memalloc_socks(void)
+{
+	return memalloc_socks;
+}
+
+extern int sk_adjust_memalloc(int socks, long tx_reserve_pages);
+extern int sk_set_memalloc(struct sock *sk);
+extern int sk_clear_memalloc(struct sock *sk);
+#else
+static inline int sk_memalloc_socks(void)
+{
+	return 0;
+}
+
+static inline int sk_clear_memalloc(struct sock *sk)
+{
+	return 0;
+}
+#endif
+
 static inline gfp_t sk_allocation(struct sock *sk, gfp_t gfp_mask)
 {
-	return gfp_mask;
+	return gfp_mask | (sk->sk_allocation & __GFP_MEMALLOC);
 }
 
 static inline void sk_acceptq_removed(struct sock *sk)
Index: mmotm/net/core/sock.c
===================================================================
--- mmotm.orig/net/core/sock.c
+++ mmotm/net/core/sock.c
@@ -110,6 +110,7 @@
 #include <linux/tcp.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/reserve.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -217,6 +218,105 @@ __u32 sysctl_rmem_default __read_mostly
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
 
+static struct mem_reserve net_reserve;
+struct mem_reserve net_rx_reserve;
+EXPORT_SYMBOL_GPL(net_rx_reserve); /* modular ipv6 only */
+struct mem_reserve net_skb_reserve;
+EXPORT_SYMBOL_GPL(net_skb_reserve); /* modular ipv6 only */
+static struct mem_reserve net_tx_reserve;
+static struct mem_reserve net_tx_pages;
+
+#ifdef CONFIG_NETVM
+static DEFINE_MUTEX(memalloc_socks_lock);
+int memalloc_socks;
+
+/**
+ *	sk_adjust_memalloc - adjust the global memalloc reserve for critical RX
+ *	@socks: number of new %SOCK_MEMALLOC sockets
+ *	@tx_resserve_pages: number of pages to (un)reserve for TX
+ *
+ *	This function adjusts the memalloc reserve based on system demand.
+ *	The RX reserve is a limit, and only added once, not for each socket.
+ *
+ *	NOTE:
+ *	   @tx_reserve_pages is an upper-bound of memory used for TX hence
+ *	   we need not account the pages like we do for RX pages.
+ */
+int sk_adjust_memalloc(int socks, long tx_reserve_pages)
+{
+	int err;
+
+	mutex_lock(&memalloc_socks_lock);
+	err = mem_reserve_pages_add(&net_tx_pages, tx_reserve_pages);
+	if (err)
+		goto unlock;
+
+	/*
+	 * either socks is positive and we need to check for 0 -> !0
+	 * transition and connect the reserve tree when we observe it.
+	 */
+	if (!memalloc_socks && socks > 0) {
+		err = mem_reserve_connect(&net_reserve, &mem_reserve_root);
+		if (err) {
+			/*
+			 * if we failed to connect the tree, undo the tx
+			 * reserve so that failure has no side effects.
+			 */
+			mem_reserve_pages_add(&net_tx_pages, -tx_reserve_pages);
+			goto unlock;
+		}
+	}
+	memalloc_socks += socks;
+	/*
+	 * or socks is negative and we must observe the !0 -> 0 transition
+	 * and disconnect the reserve tree.
+	 */
+	if (!memalloc_socks && socks)
+		mem_reserve_disconnect(&net_reserve);
+
+unlock:
+	mutex_unlock(&memalloc_socks_lock);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(sk_adjust_memalloc);
+
+/**
+ *	sk_set_memalloc - sets %SOCK_MEMALLOC
+ *	@sk: socket to set it on
+ *
+ *	Set %SOCK_MEMALLOC on a socket and increase the memalloc reserve
+ *	accordingly.
+ */
+int sk_set_memalloc(struct sock *sk)
+{
+	int set = sock_flag(sk, SOCK_MEMALLOC);
+
+	if (!set) {
+		int err = sk_adjust_memalloc(1, 0);
+		if (err)
+			return err;
+
+		sock_set_flag(sk, SOCK_MEMALLOC);
+		sk->sk_allocation |= __GFP_MEMALLOC;
+	}
+	return !set;
+}
+EXPORT_SYMBOL_GPL(sk_set_memalloc);
+
+int sk_clear_memalloc(struct sock *sk)
+{
+	int set = sock_flag(sk, SOCK_MEMALLOC);
+	if (set) {
+		sk_adjust_memalloc(-1, 0);
+		sock_reset_flag(sk, SOCK_MEMALLOC);
+		sk->sk_allocation &= ~__GFP_MEMALLOC;
+	}
+	return set;
+}
+EXPORT_SYMBOL_GPL(sk_clear_memalloc);
+#endif
+
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 {
 	struct timeval tv;
@@ -1036,6 +1136,7 @@ static void __sk_free(struct sock *sk)
 {
 	struct sk_filter *filter;
 
+	sk_clear_memalloc(sk);
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);
 
@@ -1205,6 +1306,12 @@ void __init sk_init(void)
 		sysctl_wmem_max = 131071;
 		sysctl_rmem_max = 131071;
 	}
+
+	mem_reserve_init(&net_reserve, "total network reserve", NULL);
+	mem_reserve_init(&net_rx_reserve, "network RX reserve", &net_reserve);
+	mem_reserve_init(&net_skb_reserve, "SKB data reserve", &net_rx_reserve);
+	mem_reserve_init(&net_tx_reserve, "network TX reserve", &net_reserve);
+	mem_reserve_init(&net_tx_pages, "protocol TX pages", &net_tx_reserve);
 }
 
 /*
Index: mmotm/net/Kconfig
===================================================================
--- mmotm.orig/net/Kconfig
+++ mmotm/net/Kconfig
@@ -256,4 +256,7 @@ source "net/wimax/Kconfig"
 source "net/rfkill/Kconfig"
 source "net/9p/Kconfig"
 
+config NETVM
+	def_bool n
+
 endif   # if NET

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
