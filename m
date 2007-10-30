Message-Id: <20071030160914.070739000@chello.nl>
References: <20071030160401.296770000@chello.nl>
Date: Tue, 30 Oct 2007 17:04:19 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 18/33] netvm: INET reserves.
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
 include/linux/sysctl.h     |   11 +++++++++++
 kernel/sysctl.c            |    8 ++++++--
 net/ipv4/ip_fragment.c     |    7 +++++++
 net/ipv4/route.c           |   30 +++++++++++++++++++++++++++++-
 net/ipv4/sysctl_net_ipv4.c |   24 +++++++++++++++++++++++-
 net/ipv6/reassembly.c      |    7 +++++++
 net/ipv6/route.c           |   31 ++++++++++++++++++++++++++++++-
 net/ipv6/sysctl_net_ipv6.c |   24 +++++++++++++++++++++++-
 8 files changed, 136 insertions(+), 6 deletions(-)

Index: linux-2.6/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- linux-2.6.orig/net/ipv4/sysctl_net_ipv4.c
+++ linux-2.6/net/ipv4/sysctl_net_ipv4.c
@@ -18,6 +18,7 @@
 #include <net/route.h>
 #include <net/tcp.h>
 #include <net/cipso_ipv4.h>
+#include <linux/reserve.h>
 
 /* From af_inet.c */
 extern int sysctl_ip_nonlocal_bind;
@@ -186,6 +187,27 @@ static int strategy_allowed_congestion_c
 
 }
 
+extern struct mem_reserve ipv4_frag_reserve;
+
+static int do_proc_dointvec_fragment_conv(int *negp, unsigned long *lvalp,
+				 int *valp, int write, void *data)
+{
+	if (write) {
+		long value = *negp ? -*lvalp : *lvalp;
+		int err = mem_reserve_kmalloc_set(&ipv4_frag_reserve, value);
+		if (err)
+			return err;
+	}
+	return do_proc_dointvec_conv(negp, lvalp, valp, write, data);
+}
+
+static int proc_dointvec_fragment(ctl_table *table, int write, struct file *filp,
+		     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return do_proc_dointvec(table, write, filp, buffer, lenp, ppos,
+			do_proc_dointvec_fragment_conv, NULL);
+}
+
 ctl_table ipv4_table[] = {
 	{
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
@@ -291,7 +313,7 @@ ctl_table ipv4_table[] = {
 		.data		= &sysctl_ipfrag_high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment
 	},
 	{
 		.ctl_name	= NET_IPV4_IPFRAG_LOW_THRESH,
Index: linux-2.6/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- linux-2.6.orig/net/ipv6/sysctl_net_ipv6.c
+++ linux-2.6/net/ipv6/sysctl_net_ipv6.c
@@ -12,9 +12,31 @@
 #include <net/ndisc.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
+#include <linux/reserve.h>
 
 #ifdef CONFIG_SYSCTL
 
+extern struct mem_reserve ipv6_frag_reserve;
+
+static int do_proc_dointvec_fragment_conv(int *negp, unsigned long *lvalp,
+				 int *valp, int write, void *data)
+{
+	if (write) {
+		long value = *negp ? -*lvalp : *lvalp;
+		int err = mem_reserve_kmalloc_set(&ipv6_frag_reserve, value);
+		if (err)
+			return err;
+	}
+	return do_proc_dointvec_conv(negp, lvalp, valp, write, data);
+}
+
+static int proc_dointvec_fragment(ctl_table *table, int write, struct file *filp,
+		     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return do_proc_dointvec(table, write, filp, buffer, lenp, ppos,
+			do_proc_dointvec_fragment_conv, NULL);
+}
+
 static ctl_table ipv6_table[] = {
 	{
 		.ctl_name	= NET_IPV6_ROUTE,
@@ -44,7 +66,7 @@ static ctl_table ipv6_table[] = {
 		.data		= &sysctl_ip6frag_high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment
 	},
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_LOW_THRESH,
Index: linux-2.6/net/ipv4/ip_fragment.c
===================================================================
--- linux-2.6.orig/net/ipv4/ip_fragment.c
+++ linux-2.6/net/ipv4/ip_fragment.c
@@ -43,6 +43,7 @@
 #include <linux/udp.h>
 #include <linux/inet.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/reserve.h>
 
 /* NOTE. Logic of IP defragmentation is parallel to corresponding IPv6
  * code now. If you change something here, _PLEASE_ update ipv6/reassembly.c
@@ -733,6 +734,8 @@ struct sk_buff *ip_defrag(struct sk_buff
 	return NULL;
 }
 
+struct mem_reserve ipv4_frag_reserve;
+
 void __init ipfrag_init(void)
 {
 	ipfrag_hash_rnd = (u32) ((num_physpages ^ (num_physpages>>7)) ^
@@ -742,6 +745,10 @@ void __init ipfrag_init(void)
 	ipfrag_secret_timer.function = ipfrag_secret_rebuild;
 	ipfrag_secret_timer.expires = jiffies + sysctl_ipfrag_secret_interval;
 	add_timer(&ipfrag_secret_timer);
+
+	mem_reserve_init(&ipv4_frag_reserve, "IPv4 fragment cache",
+			 &net_skb_reserve);
+	mem_reserve_kmalloc_set(&ipv4_frag_reserve, sysctl_ipfrag_high_thresh);
 }
 
 EXPORT_SYMBOL(ip_defrag);
Index: linux-2.6/net/ipv6/reassembly.c
===================================================================
--- linux-2.6.orig/net/ipv6/reassembly.c
+++ linux-2.6/net/ipv6/reassembly.c
@@ -42,6 +42,7 @@
 #include <linux/icmpv6.h>
 #include <linux/random.h>
 #include <linux/jhash.h>
+#include <linux/reserve.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -770,6 +771,8 @@ static struct inet6_protocol frag_protoc
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
+struct mem_reserve ipv6_frag_reserve;
+
 void __init ipv6_frag_init(void)
 {
 	if (inet6_add_protocol(&frag_protocol, IPPROTO_FRAGMENT) < 0)
@@ -782,4 +785,8 @@ void __init ipv6_frag_init(void)
 	ip6_frag_secret_timer.function = ip6_frag_secret_rebuild;
 	ip6_frag_secret_timer.expires = jiffies + sysctl_ip6frag_secret_interval;
 	add_timer(&ip6_frag_secret_timer);
+
+	mem_reserve_init(&ipv6_frag_reserve, "IPv6 fragment cache",
+			&net_skb_reserve);
+	mem_reserve_kmalloc_set(&ipv6_frag_reserve, sysctl_ip6frag_high_thresh);
 }
Index: linux-2.6/net/ipv4/route.c
===================================================================
--- linux-2.6.orig/net/ipv4/route.c
+++ linux-2.6/net/ipv4/route.c
@@ -108,6 +108,7 @@
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
+#include <linux/reserve.h>
 
 #define RT_FL_TOS(oldflp) \
     ((u32)(oldflp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK)))
@@ -2698,6 +2699,28 @@ static int ipv4_sysctl_rtcache_flush_str
 	return 0;
 }
 
+static struct mem_reserve ipv4_route_reserve;
+
+static int do_proc_dointvec_route_conv(int *negp, unsigned long *lvalp,
+				 int *valp, int write, void *data)
+{
+	if (write) {
+		long value = *negp ? -*lvalp : *lvalp;
+		int err = mem_reserve_kmem_cache_set(&ipv4_route_reserve,
+				ipv4_dst_ops.kmem_cachep, value);
+		if (err)
+			return err;
+	}
+	return do_proc_dointvec_conv(negp, lvalp, valp, write, data);
+}
+
+static int proc_dointvec_route(ctl_table *table, int write, struct file *filp,
+		     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return do_proc_dointvec(table, write, filp, buffer, lenp, ppos,
+			do_proc_dointvec_route_conv, NULL);
+}
+
 ctl_table ipv4_route_table[] = {
 	{
 		.ctl_name 	= NET_IPV4_ROUTE_FLUSH,
@@ -2740,7 +2763,7 @@ ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_max_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_dointvec_route,
 	},
 	{
 		/*  Deprecated. Use gc_min_interval_ms */
@@ -2970,6 +2993,11 @@ int __init ip_rt_init(void)
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
 
 #ifdef 	CONFIG_PROC_FS
 #include <linux/proc_fs.h>
@@ -2454,6 +2455,28 @@ int ipv6_sysctl_rtcache_flush(ctl_table 
 		return -EINVAL;
 }
 
+static struct mem_reserve ipv6_route_reserve;
+
+static int do_proc_dointvec_route6_conv(int *negp, unsigned long *lvalp,
+				 int *valp, int write, void *data)
+{
+	if (write) {
+		long value = *negp ? -*lvalp : *lvalp;
+		int err = mem_reserve_kmem_cache_set(&ipv6_route_reserve,
+				ip6_dst_ops.kmem_cachep, value);
+		if (err)
+			return err;
+	}
+	return do_proc_dointvec_conv(negp, lvalp, valp, write, data);
+}
+
+static int proc_dointvec_route6(ctl_table *table, int write, struct file *filp,
+		     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return do_proc_dointvec(table, write, filp, buffer, lenp, ppos,
+			do_proc_dointvec_route6_conv, NULL);
+}
+
 ctl_table ipv6_route_table[] = {
 	{
 		.procname	=	"flush",
@@ -2476,7 +2499,7 @@ ctl_table ipv6_route_table[] = {
 		.data		=	&ip6_rt_max_size,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec,
+         	.proc_handler	=	&proc_dointvec_route6,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL,
@@ -2564,6 +2587,12 @@ void __init ip6_route_init(void)
 
 	proc_net_fops_create(&init_net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
 #endif
+
+	mem_reserve_init(&ipv6_route_reserve, "IPv6 route cache",
+			&net_rx_reserve);
+	mem_reserve_kmem_cache_set(&ipv6_route_reserve,
+			ip6_dst_ops.kmem_cachep, ip6_rt_max_size);
+
 #ifdef CONFIG_XFRM
 	xfrm6_init();
 #endif
Index: linux-2.6/include/linux/sysctl.h
===================================================================
--- linux-2.6.orig/include/linux/sysctl.h
+++ linux-2.6/include/linux/sysctl.h
@@ -966,6 +966,17 @@ typedef int proc_handler (struct ctl_tab
 
 extern int proc_dostring(struct ctl_table *, int, struct file *,
 			 void __user *, size_t *, loff_t *);
+
+extern int do_proc_dointvec_conv(int *negp, unsigned long *lvalp,
+				 int *valp,
+				 int write, void *data);
+
+extern int do_proc_dointvec(ctl_table *table, int write, struct file *filp,
+		  void __user *buffer, size_t *lenp, loff_t *ppos,
+		  int (*conv)(int *negp, unsigned long *lvalp, int *valp,
+			      int write, void *data),
+		  void *data);
+
 extern int proc_dointvec(struct ctl_table *, int, struct file *,
 			 void __user *, size_t *, loff_t *);
 extern int proc_dointvec_bset(struct ctl_table *, int, struct file *,
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c
+++ linux-2.6/kernel/sysctl.c
@@ -1702,7 +1702,7 @@ int proc_dostring(struct ctl_table *tabl
 }
 
 
-static int do_proc_dointvec_conv(int *negp, unsigned long *lvalp,
+int do_proc_dointvec_conv(int *negp, unsigned long *lvalp,
 				 int *valp,
 				 int write, void *data)
 {
@@ -1721,6 +1721,8 @@ static int do_proc_dointvec_conv(int *ne
 	return 0;
 }
 
+EXPORT_SYMBOL(do_proc_dointvec_conv);
+
 static int __do_proc_dointvec(void *tbl_data, struct ctl_table *table,
 		  int write, struct file *filp, void __user *buffer,
 		  size_t *lenp, loff_t *ppos,
@@ -1832,7 +1834,7 @@ static int __do_proc_dointvec(void *tbl_
 #undef TMPBUFLEN
 }
 
-static int do_proc_dointvec(struct ctl_table *table, int write, struct file *filp,
+int do_proc_dointvec(struct ctl_table *table, int write, struct file *filp,
 		  void __user *buffer, size_t *lenp, loff_t *ppos,
 		  int (*conv)(int *negp, unsigned long *lvalp, int *valp,
 			      int write, void *data),
@@ -1842,6 +1844,8 @@ static int do_proc_dointvec(struct ctl_t
 			buffer, lenp, ppos, conv, data);
 }
 
+EXPORT_SYMBOL(do_proc_dointvec);
+
 /**
  * proc_dointvec - read a vector of integers
  * @table: the sysctl table

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
