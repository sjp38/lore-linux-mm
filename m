Message-Id: <20070221144842.896272000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Date: Wed, 21 Feb 2007 15:43:18 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 14/29] netvm: INET reserves.
Content-Disposition: inline; filename=netvm-reserve-inet.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Add reserves for INET.

The two big users seem to be the route cache and ip-fragment cache.

Account the route cache to the auxillary reserve.
Account the fragments to the skb reserve so that one can at least
overflow the fragment cache (avoids fragment deadlocks).

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 net/ipv4/ip_fragment.c     |    1 +
 net/ipv4/route.c           |   18 +++++++++++++++++-
 net/ipv4/sysctl_net_ipv4.c |   13 ++++++++++++-
 net/ipv6/reassembly.c      |    1 +
 net/ipv6/route.c           |   18 +++++++++++++++++-
 net/ipv6/sysctl_net_ipv6.c |   12 +++++++++++-
 6 files changed, 59 insertions(+), 4 deletions(-)

Index: linux-2.6-git/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- linux-2.6-git.orig/net/ipv4/sysctl_net_ipv4.c	2007-02-20 15:12:56.000000000 +0100
+++ linux-2.6-git/net/ipv4/sysctl_net_ipv4.c	2007-02-20 16:41:28.000000000 +0100
@@ -18,6 +18,7 @@
 #include <net/route.h>
 #include <net/tcp.h>
 #include <net/cipso_ipv4.h>
+#include <net/sock.h>
 
 /* From af_inet.c */
 extern int sysctl_ip_nonlocal_bind;
@@ -186,6 +187,16 @@ static int strategy_allowed_congestion_c
 
 }
 
+static int proc_dointvec_fragment(ctl_table *table, int write, struct file *filp,
+		     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret;
+	int old_thresh = *(int *)table->data;
+	ret = proc_dointvec(table,write,filp,buffer,lenp,ppos);
+	skb_reserve_memory(*(int *)table->data - old_thresh);
+	return ret;
+}
+
 ctl_table ipv4_table[] = {
 	{
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
@@ -291,7 +302,7 @@ ctl_table ipv4_table[] = {
 		.data		= &sysctl_ipfrag_high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment
 	},
 	{
 		.ctl_name	= NET_IPV4_IPFRAG_LOW_THRESH,
Index: linux-2.6-git/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- linux-2.6-git.orig/net/ipv6/sysctl_net_ipv6.c	2007-02-20 15:12:56.000000000 +0100
+++ linux-2.6-git/net/ipv6/sysctl_net_ipv6.c	2007-02-20 16:41:28.000000000 +0100
@@ -15,6 +15,16 @@
 
 #ifdef CONFIG_SYSCTL
 
+static int proc_dointvec_fragment(ctl_table *table, int write, struct file *filp,
+		     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret;
+	int old_thresh = *(int *)table->data;
+	ret = proc_dointvec(table,write,filp,buffer,lenp,ppos);
+	skb_reserve_memory(*(int *)table->data - old_thresh);
+	return ret;
+}
+
 static ctl_table ipv6_table[] = {
 	{
 		.ctl_name	= NET_IPV6_ROUTE,
@@ -44,7 +54,7 @@ static ctl_table ipv6_table[] = {
 		.data		= &sysctl_ip6frag_high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment
 	},
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_LOW_THRESH,
Index: linux-2.6-git/net/ipv4/ip_fragment.c
===================================================================
--- linux-2.6-git.orig/net/ipv4/ip_fragment.c	2007-02-20 15:12:56.000000000 +0100
+++ linux-2.6-git/net/ipv4/ip_fragment.c	2007-02-20 16:41:28.000000000 +0100
@@ -743,6 +743,7 @@ void ipfrag_init(void)
 	ipfrag_secret_timer.function = ipfrag_secret_rebuild;
 	ipfrag_secret_timer.expires = jiffies + sysctl_ipfrag_secret_interval;
 	add_timer(&ipfrag_secret_timer);
+	skb_reserve_memory(sysctl_ipfrag_high_thresh);
 }
 
 EXPORT_SYMBOL(ip_defrag);
Index: linux-2.6-git/net/ipv6/reassembly.c
===================================================================
--- linux-2.6-git.orig/net/ipv6/reassembly.c	2007-02-20 15:12:56.000000000 +0100
+++ linux-2.6-git/net/ipv6/reassembly.c	2007-02-20 16:41:28.000000000 +0100
@@ -772,4 +772,5 @@ void __init ipv6_frag_init(void)
 	ip6_frag_secret_timer.function = ip6_frag_secret_rebuild;
 	ip6_frag_secret_timer.expires = jiffies + sysctl_ip6frag_secret_interval;
 	add_timer(&ip6_frag_secret_timer);
+	skb_reserve_memory(sysctl_ip6frag_high_thresh);
 }
Index: linux-2.6-git/net/ipv4/route.c
===================================================================
--- linux-2.6-git.orig/net/ipv4/route.c	2007-02-20 15:12:56.000000000 +0100
+++ linux-2.6-git/net/ipv4/route.c	2007-02-20 16:41:28.000000000 +0100
@@ -2884,6 +2884,20 @@ static int ipv4_sysctl_rtcache_flush_str
 	return 0;
 }
 
+static int proc_dointvec_rt_size(ctl_table *table, int write, struct file *filp,
+		     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret;
+	int new_pages;
+	int old_pages = kmem_cache_objs_to_pages(ipv4_dst_ops.kmem_cachep,
+			*(int *)table->data);
+	ret = proc_dointvec(table,write,filp,buffer,lenp,ppos);
+	new_pages = kmem_cache_objs_to_pages(ipv4_dst_ops.kmem_cachep,
+			*(int *)table->data);
+	aux_reserve_memory(new_pages - old_pages);
+	return ret;
+}
+
 ctl_table ipv4_route_table[] = {
 	{
 		.ctl_name 	= NET_IPV4_ROUTE_FLUSH,
@@ -2926,7 +2940,7 @@ ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_max_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_dointvec_rt_size,
 	},
 	{
 		/*  Deprecated. Use gc_min_interval_ms */
@@ -3153,6 +3167,8 @@ int __init ip_rt_init(void)
 
 	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
 	ip_rt_max_size = (rt_hash_mask + 1) * 16;
+	aux_reserve_memory(kmem_cache_objs_to_pages(ipv4_dst_ops.kmem_cachep,
+				ip_rt_max_size));
 
 	devinet_init();
 	ip_fib_init();
Index: linux-2.6-git/net/ipv6/route.c
===================================================================
--- linux-2.6-git.orig/net/ipv6/route.c	2007-02-20 15:12:56.000000000 +0100
+++ linux-2.6-git/net/ipv6/route.c	2007-02-20 17:46:13.000000000 +0100
@@ -2370,6 +2370,20 @@ int ipv6_sysctl_rtcache_flush(ctl_table 
 		return -EINVAL;
 }
 
+static int proc_dointvec_rt_size(ctl_table *table, int write, struct file *filp,
+		     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret;
+	int new_pages;
+	int old_pages = kmem_cache_objs_to_pages(ip6_dst_ops.kmem_cachep,
+			*(int *)table->data);
+	ret = proc_dointvec(table,write,filp,buffer,lenp,ppos);
+	new_pages = kmem_cache_objs_to_pages(ip6_dst_ops.kmem_cachep,
+			*(int *)table->data);
+	aux_reserve_memory(new_pages - old_pages);
+	return ret;
+}
+
 ctl_table ipv6_route_table[] = {
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_FLUSH,
@@ -2393,7 +2407,7 @@ ctl_table ipv6_route_table[] = {
 		.data		=	&ip6_rt_max_size,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec,
+         	.proc_handler	=	&proc_dointvec_rt_size,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL,
@@ -2478,6 +2492,8 @@ void __init ip6_route_init(void)
 
 	proc_net_fops_create("rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
 #endif
+	aux_reserve_memory(kmem_cache_objs_to_pages(ip6_dst_ops.kmem_cachep,
+				ip6_rt_max_size));
 #ifdef CONFIG_XFRM
 	xfrm6_init();
 #endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
