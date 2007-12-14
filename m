Message-Id: <20071214154441.337409000@chello.nl>
References: <20071214153907.770251000@chello.nl>
Date: Fri, 14 Dec 2007 16:39:23 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 16/29] netvm: INET reserves.
Content-Disposition: inline; filename=netvm-reserve-inet.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Add reserves for INET.

The two big users seem to be the route cache and ip-fragment cache.

Reserve the route cache under generic RX reserve, its usage is bounded by
the high reclaim watermark, and thus does not need further accounting.

Reserve the ip-fragement caches under SKB data reserve, these add to the
SKB RX limit. By ensuring we can at least receive as much data as fits in
the reassmbly line we avoid fragment attack deadlocks.

Use proc conv() routines to update these limits and return -ENOMEM to user
space.

Adds to the reserve tree:

  total network reserve      
    network TX reserve       
      protocol TX pages      
    network RX reserve       
+     IPv6 route cache       
+     IPv4 route cache       
      SKB data reserve       
+       IPv6 fragment cache  
+       IPv4 fragment cache  

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 net/ipv4/ip_fragment.c     |    7 ++++
 net/ipv4/route.c           |   64 +++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/sysctl_net_ipv4.c |   57 ++++++++++++++++++++++++++++++++++++++--
 net/ipv6/reassembly.c      |    7 ++++
 net/ipv6/route.c           |   64 +++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/sysctl_net_ipv6.c |   57 ++++++++++++++++++++++++++++++++++++++--
 6 files changed, 248 insertions(+), 8 deletions(-)

Index: linux-2.6/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- linux-2.6.orig/net/ipv4/sysctl_net_ipv4.c
+++ linux-2.6/net/ipv4/sysctl_net_ipv4.c
@@ -21,6 +21,7 @@
 #include <net/tcp.h>
 #include <net/cipso_ipv4.h>
 #include <net/inet_frag.h>
+#include <linux/reserve.h>
 
 static int zero;
 static int tcp_retr1_max = 255;
@@ -192,6 +193,57 @@ static int strategy_allowed_congestion_c
 
 }
 
+static int ipv4_frag_bytes;
+extern struct mem_reserve ipv4_frag_reserve;
+
+static int proc_dointvec_fragment(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	int old_bytes, ret;
+
+	if (!write)
+		ipv4_frag_bytes = ip4_frags_ctl.high_thresh;
+       	old_bytes = ipv4_frag_bytes;
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&ipv4_frag_reserve, ipv4_frag_bytes);
+		if (!ret)
+			ip4_frags_ctl.high_thresh = ipv4_frag_bytes;
+		else
+			ipv4_frag_bytes = old_bytes;
+	}
+
+	return ret;
+}
+
+static int sysctl_intvec_fragment(struct ctl_table *table,
+		int __user *name, int nlen,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	int old_bytes, ret;
+	int write = (newval && newlen);
+
+	if (!write)
+		ipv4_frag_bytes = ip4_frags_ctl.high_thresh;
+       	old_bytes = ipv4_frag_bytes;
+
+	ret = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&ipv4_frag_reserve, ipv4_frag_bytes);
+		if (!ret)
+			ip4_frags_ctl.high_thresh = ipv4_frag_bytes;
+		else
+			ipv4_frag_bytes = old_bytes;
+	}
+
+	return ret;
+}
+
 static struct ctl_table ipv4_table[] = {
 	{
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
@@ -285,10 +337,11 @@ static struct ctl_table ipv4_table[] = {
 	{
 		.ctl_name	= NET_IPV4_IPFRAG_HIGH_THRESH,
 		.procname	= "ipfrag_high_thresh",
-		.data		= &ip4_frags_ctl.high_thresh,
+		.data		= &ipv4_frag_bytes,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment,
+		.strategy	= &sysctl_intvec_fragment,
 	},
 	{
 		.ctl_name	= NET_IPV4_IPFRAG_LOW_THRESH,
Index: linux-2.6/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- linux-2.6.orig/net/ipv6/sysctl_net_ipv6.c
+++ linux-2.6/net/ipv6/sysctl_net_ipv6.c
@@ -13,6 +13,58 @@
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
+#include <linux/reserve.h>
+
+static int ipv6_frag_bytes;
+extern struct mem_reserve ipv6_frag_reserve;
+
+static int proc_dointvec_fragment(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	int old_bytes, ret;
+
+	if (!write)
+		ipv6_frag_bytes = ip6_frags_ctl.high_thresh;
+       	old_bytes = ipv6_frag_bytes;
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&ipv6_frag_reserve, ipv6_frag_bytes);
+		if (!ret)
+			ip6_frags_ctl.high_thresh = ipv6_frag_bytes;
+		else
+			ipv6_frag_bytes = old_bytes;
+	}
+
+	return ret;
+}
+
+static int sysctl_intvec_fragment(struct ctl_table *table,
+		int __user *name, int nlen,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	int old_bytes, ret;
+	int write = (newval && newlen);
+
+	if (!write)
+		ipv6_frag_bytes = ip6_frags_ctl.high_thresh;
+       	old_bytes = ipv6_frag_bytes;
+
+	ret = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&ipv6_frag_reserve, ipv6_frag_bytes);
+		if (!ret)
+			ip6_frags_ctl.high_thresh = ipv6_frag_bytes;
+		else
+			ipv6_frag_bytes = old_bytes;
+	}
+
+	return ret;
+}
 
 static ctl_table ipv6_table[] = {
 	{
@@ -40,10 +92,11 @@ static ctl_table ipv6_table[] = {
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_HIGH_THRESH,
 		.procname	= "ip6frag_high_thresh",
-		.data		= &ip6_frags_ctl.high_thresh,
+		.data		= &ipv6_frag_bytes,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment,
+		.strategy	= &sysctl_intvec_fragment,
 	},
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_LOW_THRESH,
Index: linux-2.6/net/ipv4/ip_fragment.c
===================================================================
--- linux-2.6.orig/net/ipv4/ip_fragment.c
+++ linux-2.6/net/ipv4/ip_fragment.c
@@ -44,6 +44,7 @@
 #include <linux/udp.h>
 #include <linux/inet.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/reserve.h>
 
 /* NOTE. Logic of IP defragmentation is parallel to corresponding IPv6
  * code now. If you change something here, _PLEASE_ update ipv6/reassembly.c
@@ -607,6 +608,8 @@ int ip_defrag(struct sk_buff *skb, u32 u
 	return -ENOMEM;
 }
 
+struct mem_reserve ipv4_frag_reserve;
+
 void __init ipfrag_init(void)
 {
 	ip4_frags.ctl = &ip4_frags_ctl;
@@ -618,6 +621,10 @@ void __init ipfrag_init(void)
 	ip4_frags.match = ip4_frag_match;
 	ip4_frags.frag_expire = ip_expire;
 	inet_frags_init(&ip4_frags);
+
+	mem_reserve_init(&ipv4_frag_reserve, "IPv4 fragment cache",
+			 &net_skb_reserve);
+	mem_reserve_kmalloc_set(&ipv4_frag_reserve, ip4_frags_ctl.high_thresh);
 }
 
 EXPORT_SYMBOL(ip_defrag);
Index: linux-2.6/net/ipv6/reassembly.c
===================================================================
--- linux-2.6.orig/net/ipv6/reassembly.c
+++ linux-2.6/net/ipv6/reassembly.c
@@ -43,6 +43,7 @@
 #include <linux/random.h>
 #include <linux/jhash.h>
 #include <linux/skbuff.h>
+#include <linux/reserve.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -632,6 +633,8 @@ static struct inet6_protocol frag_protoc
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
+struct mem_reserve ipv6_frag_reserve;
+
 int __init ipv6_frag_init(void)
 {
 	int ret;
@@ -650,6 +653,10 @@ int __init ipv6_frag_init(void)
 	inet_frags_init(&ip6_frags);
 out:
 	return ret;
+
+	mem_reserve_init(&ipv6_frag_reserve, "IPv6 fragment cache",
+			&net_skb_reserve);
+	mem_reserve_kmalloc_set(&ipv6_frag_reserve, ip6_frags_ctl.high_thresh);
 }
 
 void ipv6_frag_exit(void)
Index: linux-2.6/net/ipv4/route.c
===================================================================
--- linux-2.6.orig/net/ipv4/route.c
+++ linux-2.6/net/ipv4/route.c
@@ -109,6 +109,7 @@
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
+#include <linux/reserve.h>
 
 #define RT_FL_TOS(oldflp) \
     ((u32)(oldflp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK)))
@@ -2815,6 +2816,59 @@ static int ipv4_sysctl_rtcache_flush_str
 	return 0;
 }
 
+static int ipv4_route_size;
+static struct mem_reserve ipv4_route_reserve;
+
+static int proc_dointvec_route(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	int old_size, ret;
+
+	if (!write)
+		ipv4_route_size = ip_rt_max_size;
+       	old_size = ipv4_route_size;
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&ipv4_route_reserve,
+				ipv4_dst_ops.kmem_cachep, ipv4_route_size);
+		if (!ret)
+			ip_rt_max_size = ipv4_route_size;
+		else
+			ipv4_route_size = old_size;
+	}
+
+	return ret;
+}
+
+static int sysctl_intvec_route(struct ctl_table *table,
+		int __user *name, int nlen,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	int old_size, ret;
+	int write = (newval && newlen);
+
+	if (!write)
+		ipv4_route_size = ip_rt_max_size;
+       	old_size = ipv4_route_size;
+
+	ret = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&ipv4_route_reserve,
+				ipv4_dst_ops.kmem_cachep, ipv4_route_size);
+		if (!ret)
+			ip_rt_max_size = ipv4_route_size;
+		else
+			ipv4_route_size = old_size;
+	}
+
+	return ret;
+}
+
 ctl_table ipv4_route_table[] = {
 	{
 		.ctl_name 	= NET_IPV4_ROUTE_FLUSH,
@@ -2854,10 +2908,11 @@ ctl_table ipv4_route_table[] = {
 	{
 		.ctl_name	= NET_IPV4_ROUTE_MAX_SIZE,
 		.procname	= "max_size",
-		.data		= &ip_rt_max_size,
+		.data		= &ipv4_route_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_dointvec_route,
+		.strategy	= &sysctl_intvec_route,
 	},
 	{
 		/*  Deprecated. Use gc_min_interval_ms */
@@ -3032,6 +3087,11 @@ int __init ip_rt_init(void)
 	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
 	ip_rt_max_size = (rt_hash_mask + 1) * 16;
 
+	mem_reserve_init(&ipv4_route_reserve, "IPv4 route cache",
+			&net_rx_reserve);
+	mem_reserve_kmem_cache_set(&ipv4_route_reserve,
+			ipv4_dst_ops.kmem_cachep, ip_rt_max_size);
+
 	devinet_init();
 	ip_fib_init();
 
Index: linux-2.6/net/ipv6/route.c
===================================================================
--- linux-2.6.orig/net/ipv6/route.c
+++ linux-2.6/net/ipv6/route.c
@@ -38,6 +38,7 @@
 #include <linux/in6.h>
 #include <linux/init.h>
 #include <linux/if_arp.h>
+#include <linux/reserve.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <net/net_namespace.h>
@@ -2405,6 +2406,59 @@ int ipv6_sysctl_rtcache_flush(ctl_table 
 		return -EINVAL;
 }
 
+static int ipv6_route_size;
+static struct mem_reserve ipv6_route_reserve;
+
+static int proc_dointvec_route(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	int old_size, ret;
+
+	if (!write)
+		ipv6_route_size = ip6_rt_max_size;
+       	old_size = ipv6_route_size;
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&ipv6_route_reserve,
+				ip6_dst_ops.kmem_cachep, ipv6_route_size);
+		if (!ret)
+			ip6_rt_max_size = ipv6_route_size;
+		else
+			ipv6_route_size = old_size;
+	}
+
+	return ret;
+}
+
+static int sysctl_intvec_route(struct ctl_table *table,
+		int __user *name, int nlen,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	int old_size, ret;
+	int write = (newval && newlen);
+
+	if (!write)
+		ipv6_route_size = ip6_rt_max_size;
+       	old_size = ipv6_route_size;
+
+	ret = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&ipv6_route_reserve,
+				ip6_dst_ops.kmem_cachep, ipv6_route_size);
+		if (!ret)
+			ip6_rt_max_size = ipv6_route_size;
+		else
+			ipv6_route_size = old_size;
+	}
+
+	return ret;
+}
+
 ctl_table ipv6_route_table[] = {
 	{
 		.procname	=	"flush",
@@ -2424,10 +2478,11 @@ ctl_table ipv6_route_table[] = {
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_MAX_SIZE,
 		.procname	=	"max_size",
-		.data		=	&ip6_rt_max_size,
+		.data		=	&ipv6_route_size,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec,
+         	.proc_handler	=	&proc_dointvec_route,
+		.strategy	= 	&sysctl_intvec_route,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL,
@@ -2509,6 +2564,11 @@ int __init ip6_route_init(void)
 
 	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops.kmem_cachep;
 
+	mem_reserve_init(&ipv6_route_reserve, "IPv6 route cache",
+			&net_rx_reserve);
+	mem_reserve_kmem_cache_set(&ipv6_route_reserve,
+			ip6_dst_ops.kmem_cachep, ip6_rt_max_size);
+
 	ret = fib6_init();
 	if (ret)
 		goto out_kmem_cache;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
