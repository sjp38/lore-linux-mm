Message-Id: <20070504103158.666983610@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:05 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 14/40] netvm: link network to vm layer
Content-Disposition: inline; filename=netvm-reserve.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Hook up networking to the memory reserve.

There are two kinds of reserves: skb and aux. 
 - skb reserves are used for incomming packets,
 - aux reserves are used for processing these packets.

The consumers for these reserves are sockets marked with:
  SOCK_VMIO

Such sockets are to be used to service the VM (iow. to swap over). They
must be handled kernel side, exposing such a socket to user-space is a BUG.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h |   43 ++++++++++++++++
 net/Kconfig        |    3 +
 net/core/sock.c    |  135 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 180 insertions(+), 1 deletion(-)

Index: linux-2.6-git/include/net/sock.h
===================================================================
--- linux-2.6-git.orig/include/net/sock.h
+++ linux-2.6-git/include/net/sock.h
@@ -49,6 +49,7 @@
 #include <linux/skbuff.h>	/* struct sk_buff */
 #include <linux/mm.h>
 #include <linux/security.h>
+#include <linux/log2.h>
 
 #include <linux/filter.h>
 
@@ -393,6 +394,7 @@ enum sock_flags {
 	SOCK_RCVTSTAMPNS, /* %SO_TIMESTAMPNS setting */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
+	SOCK_VMIO, /* the VM depends on us - make sure we're serviced */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
@@ -415,9 +417,48 @@ static inline int sock_flag(struct sock 
 	return test_bit(flag, &sk->sk_flags);
 }
 
+static inline int sk_has_vmio(struct sock *sk)
+{
+	return sock_flag(sk, SOCK_VMIO);
+}
+
+/*
+ * Guestimate the per request queue TX upper bound.
+ *
+ * Max packet size is 64k, and we need to reserve that much since the data
+ * might need to bounce it. Double it to be on the safe side.
+ */
+#define TX_RESERVE_PAGES DIV_ROUND_UP(2*65536, PAGE_SIZE)
+
+extern atomic_t vmio_socks;
+
+static inline int sk_vmio_socks(void)
+{
+	return atomic_read(&vmio_socks);
+}
+
+extern int rx_emergency_get(int bytes);
+extern int rx_emergency_get_overcommit(int bytes);
+extern void rx_emergency_put(int bytes);
+
+static inline
+int guess_kmem_cache_pages(struct kmem_cache *cachep, int nr_objs)
+{
+	int guess = DIV_ROUND_UP((kmem_cache_objsize(cachep) * nr_objs),
+			PAGE_SIZE);
+	guess += ilog2(guess);
+	return guess;
+}
+
+extern void sk_adjust_memalloc(int socks, int tx_reserve_pages);
+extern void skb_reserve_memory(int skb_reserve_bytes);
+extern void aux_reserve_memory(int aux_reserve_pages);
+extern int sk_set_vmio(struct sock *sk);
+extern int sk_clear_vmio(struct sock *sk);
+
 static inline gfp_t sk_allocation(struct sock *sk, gfp_t gfp_mask)
 {
-	return gfp_mask;
+	return gfp_mask | (sk->sk_allocation & __GFP_EMERGENCY);
 }
 
 static inline void sk_acceptq_removed(struct sock *sk)
Index: linux-2.6-git/net/core/sock.c
===================================================================
--- linux-2.6-git.orig/net/core/sock.c
+++ linux-2.6-git/net/core/sock.c
@@ -112,6 +112,7 @@
 #include <linux/tcp.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/log2.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -198,6 +199,139 @@ __u32 sysctl_rmem_default __read_mostly 
 /* Maximal space eaten by iovec or ancilliary data plus some space */
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 
+static atomic_t rx_emergency_bytes;
+
+static int skb_reserve_bytes;
+static int aux_reserve_pages;
+
+static DEFINE_SPINLOCK(memalloc_lock);
+static int rx_net_reserve;
+atomic_t vmio_socks;
+EXPORT_SYMBOL_GPL(vmio_socks);
+
+/*
+ * is there room for another emergency packet?
+ * we account in power of two units to approx the slab allocator.
+ */
+static int __rx_emergency_get(int bytes, bool overcommit)
+{
+	int size = roundup_pow_of_two(bytes);
+	int nr = atomic_add_return(size, &rx_emergency_bytes);
+	int thresh = 2 * skb_reserve_bytes;
+	if (nr < thresh || overcommit)
+		return 1;
+
+	atomic_dec(&rx_emergency_bytes);
+	return 0;
+}
+
+int rx_emergency_get(int bytes)
+{
+	return __rx_emergency_get(bytes, false);
+}
+
+int rx_emergency_get_overcommit(int bytes)
+{
+	return __rx_emergency_get(bytes, true);
+}
+
+void rx_emergency_put(int bytes)
+{
+	int size = roundup_pow_of_two(bytes);
+	return atomic_sub(size, &rx_emergency_bytes);
+}
+
+/**
+ *	sk_adjust_memalloc - adjust the global memalloc reserve for critical RX
+ *	@socks: number of new %SOCK_VMIO sockets
+ *	@tx_resserve_pages: number of pages to (un)reserve for TX
+ *
+ *	This function adjusts the memalloc reserve based on system demand.
+ *	The RX reserve is a limit, and only added once, not for each socket.
+ *
+ *	NOTE:
+ *	   @tx_reserve_pages is an upper-bound of memory used for TX hence
+ *	   we need not account the pages like we do for RX pages.
+ */
+void sk_adjust_memalloc(int socks, int tx_reserve_pages)
+{
+	unsigned long flags;
+	int reserve = tx_reserve_pages;
+	int nr_socks;
+
+	spin_lock_irqsave(&memalloc_lock, flags);
+	nr_socks = atomic_add_return(socks, &vmio_socks);
+	BUG_ON(nr_socks < 0);
+
+	if (nr_socks) {
+		int skb_reserve_pages =
+			DIV_ROUND_UP(skb_reserve_bytes, PAGE_SIZE);
+		int rx_pages = 2 * skb_reserve_pages + aux_reserve_pages;
+		reserve += rx_pages - rx_net_reserve;
+		rx_net_reserve = rx_pages;
+	} else {
+		reserve -= rx_net_reserve;
+		rx_net_reserve = 0;
+	}
+
+	if (reserve)
+		adjust_memalloc_reserve(reserve);
+	spin_unlock_irqrestore(&memalloc_lock, flags);
+}
+EXPORT_SYMBOL_GPL(sk_adjust_memalloc);
+
+/*
+ * tiny helper functions to track the memory reserves
+ * needed because of modular ipv6
+ */
+void skb_reserve_memory(int bytes)
+{
+	skb_reserve_bytes += bytes;
+	sk_adjust_memalloc(0, 0);
+}
+EXPORT_SYMBOL_GPL(skb_reserve_memory);
+
+void aux_reserve_memory(int pages)
+{
+	aux_reserve_pages += pages;
+	sk_adjust_memalloc(0, 0);
+}
+EXPORT_SYMBOL_GPL(aux_reserve_memory);
+
+/**
+ *	sk_set_vmio - sets %SOCK_VMIO
+ *	@sk: socket to set it on
+ *
+ *	Set %SOCK_VMIO on a socket and increase the memalloc reserve
+ *	accordingly.
+ */
+int sk_set_vmio(struct sock *sk)
+{
+	int set = sock_flag(sk, SOCK_VMIO);
+#ifndef CONFIG_NETVM
+	BUG();
+#endif
+	if (!set) {
+		sk_adjust_memalloc(1, 0);
+		sock_set_flag(sk, SOCK_VMIO);
+		sk->sk_allocation |= __GFP_EMERGENCY;
+	}
+	return !set;
+}
+EXPORT_SYMBOL_GPL(sk_set_vmio);
+
+int sk_clear_vmio(struct sock *sk)
+{
+	int set = sock_flag(sk, SOCK_VMIO);
+	if (set) {
+		sk_adjust_memalloc(-1, 0);
+		sock_reset_flag(sk, SOCK_VMIO);
+		sk->sk_allocation &= ~__GFP_EMERGENCY;
+	}
+	return set;
+}
+EXPORT_SYMBOL_GPL(sk_clear_vmio);
+
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 {
 	struct timeval tv;
@@ -879,6 +1013,7 @@ void sk_free(struct sock *sk)
 	struct sk_filter *filter;
 	struct module *owner = sk->sk_prot_creator->owner;
 
+	sk_clear_vmio(sk);
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);
 
Index: linux-2.6-git/net/Kconfig
===================================================================
--- linux-2.6-git.orig/net/Kconfig
+++ linux-2.6-git/net/Kconfig
@@ -224,6 +224,9 @@ source "net/ieee80211/Kconfig"
 
 endmenu
 
+config NETVM
+	def_bool n
+
 endif   # if NET
 endmenu # Networking
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
