Message-Id: <20080724141530.573585429@chello.nl>
References: <20080724140042.408642539@chello.nl>
Date: Thu, 24 Jul 2008 16:01:00 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 18/30] netvm: INET reserves.
Content-Disposition: inline; filename=netvm-reserve-inet.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

Add reserves for INET.

The two big users seem to be the route cache and ip-fragment cache.

Reserve the route cache under generic RX reserve, its usage is bounded by
the high reclaim watermark, and thus does not need further accounting.

Reserve the ip-fragement caches under SKB data reserve, these add to the
SKB RX limit. By ensuring we can at least receive as much data as fits in
the reassmbly line we avoid fragment attack deadlocks.

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
 include/net/inet_frag.h  |    7 +++
 include/net/netns/ipv6.h |    4 ++
 net/ipv4/inet_fragment.c |    3 +
 net/ipv4/ip_fragment.c   |   89 +++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/route.c         |   72 +++++++++++++++++++++++++++++++++++++-
 net/ipv6/af_inet6.c      |   20 +++++++++-
 net/ipv6/reassembly.c    |   88 +++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/route.c         |   66 ++++++++++++++++++++++++++++++++++
 8 files changed, 341 insertions(+), 8 deletions(-)

Index: linux-2.6/net/ipv4/ip_fragment.c
===================================================================
--- linux-2.6.orig/net/ipv4/ip_fragment.c
+++ linux-2.6/net/ipv4/ip_fragment.c
@@ -42,6 +42,8 @@
 #include <linux/udp.h>
 #include <linux/inet.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/reserve.h>
+#include <linux/nsproxy.h>
 
 /* NOTE. Logic of IP defragmentation is parallel to corresponding IPv6
  * code now. If you change something here, _PLEASE_ update ipv6/reassembly.c
@@ -596,6 +598,66 @@ int ip_defrag(struct sk_buff *skb, u32 u
 }
 
 #ifdef CONFIG_SYSCTL
+static int proc_dointvec_fragment(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	struct net *net = current->nsproxy->net_ns;
+	int new_bytes, ret;
+
+	mutex_lock(&net->ipv4.frags.lock);
+
+	if (write)
+		table->data = &new_bytes;
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&net->ipv4.frags.reserve,
+				new_bytes);
+		if (!ret)
+			net->ipv4.frags.high_thresh = new_bytes;
+	}
+
+	if (write)
+		table->data = &net->ipv4.frags.high_thresh;
+
+	mutex_unlock(&net->ipv4.frags.lock);
+
+	return ret;
+}
+
+static int sysctl_intvec_fragment(struct ctl_table *table,
+		int __user *name, int nlen,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	struct net *net = current->nsproxy->net_ns;
+	int write = (newval && newlen);
+	int new_bytes, ret;
+
+	mutex_lock(&net->ipv4.frags.lock);
+
+	if (write)
+		table->data = &new_bytes;
+
+	ret = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&net->ipv4.frags.reserve,
+				new_bytes);
+		if (!ret)
+			net->ipv4.frags.high_thresh = new_bytes;
+	}
+
+	if (write)
+		table->data = &net->ipv4.frags.high_thresh;
+
+	mutex_unlock(&net->ipv4.frags.lock);
+
+	return ret;
+}
+
 static int zero;
 
 static struct ctl_table ip4_frags_ns_ctl_table[] = {
@@ -605,7 +667,8 @@ static struct ctl_table ip4_frags_ns_ctl
 		.data		= &init_net.ipv4.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment,
+		.strategy	= &sysctl_intvec_fragment,
 	},
 	{
 		.ctl_name	= NET_IPV4_IPFRAG_LOW_THRESH,
@@ -708,6 +771,8 @@ static inline void ip4_frags_ctl_registe
 
 static int ipv4_frags_init_net(struct net *net)
 {
+	int ret;
+
 	/*
 	 * Fragment cache limits. We will commit 256K at one time. Should we
 	 * cross that limit we will prune down to 192K. This should cope with
@@ -725,11 +790,31 @@ static int ipv4_frags_init_net(struct ne
 
 	inet_frags_init_net(&net->ipv4.frags);
 
-	return ip4_frags_ns_ctl_register(net);
+	ret = ip4_frags_ns_ctl_register(net);
+	if (ret)
+		goto out_reg;
+
+	mem_reserve_init(&net->ipv4.frags.reserve, "IPv4 fragment cache",
+			&net_skb_reserve);
+	ret = mem_reserve_kmalloc_set(&net->ipv4.frags.reserve,
+			net->ipv4.frags.high_thresh);
+	if (ret)
+		goto out_reserve;
+
+	return 0;
+
+out_reserve:
+	mem_reserve_disconnect(&net->ipv4.frags.reserve);
+	ip4_frags_ns_ctl_unregister(net);
+out_reg:
+	inet_frags_exit_net(&net->ipv4.frags, &ip4_frags);
+
+	return ret;
 }
 
 static void ipv4_frags_exit_net(struct net *net)
 {
+	mem_reserve_disconnect(&net->ipv4.frags.reserve);
 	ip4_frags_ns_ctl_unregister(net);
 	inet_frags_exit_net(&net->ipv4.frags, &ip4_frags);
 }
Index: linux-2.6/net/ipv6/reassembly.c
===================================================================
--- linux-2.6.orig/net/ipv6/reassembly.c
+++ linux-2.6/net/ipv6/reassembly.c
@@ -41,6 +41,7 @@
 #include <linux/random.h>
 #include <linux/jhash.h>
 #include <linux/skbuff.h>
+#include <linux/reserve.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -632,6 +633,66 @@ static struct inet6_protocol frag_protoc
 };
 
 #ifdef CONFIG_SYSCTL
+static int proc_dointvec_fragment(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	struct net *net = current->nsproxy->net_ns;
+	int new_bytes, ret;
+
+	mutex_lock(&net->ipv6.frags.lock);
+
+	if (write)
+		table->data = &new_bytes;
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&net->ipv6.frags.reserve,
+					      new_bytes);
+		if (!ret)
+			net->ipv6.frags.high_thresh = new_bytes;
+	}
+
+	if (write)
+		table->data = &net->ipv6.frags.high_thresh;
+
+	mutex_unlock(&net->ipv6.frags.lock);
+
+	return ret;
+}
+
+static int sysctl_intvec_fragment(struct ctl_table *table,
+		int __user *name, int nlen,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	struct net *net = current->nsproxy->net_ns;
+	int write = (newval && newlen);
+	int new_bytes, ret;
+
+	mutex_lock(&net->ipv6.frags.lock);
+
+	if (write)
+		table->data = &new_bytes;
+
+	ret = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&net->ipv6.frags.reserve,
+					      new_bytes);
+		if (!ret)
+			net->ipv6.frags.high_thresh = new_bytes;
+	}
+
+	if (write)
+		table->data = &net->ipv6.frags.high_thresh;
+
+	mutex_unlock(&net->ipv6.frags.lock);
+
+	return ret;
+}
+
 static struct ctl_table ip6_frags_ns_ctl_table[] = {
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_HIGH_THRESH,
@@ -639,7 +700,8 @@ static struct ctl_table ip6_frags_ns_ctl
 		.data		= &init_net.ipv6.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment,
+		.strategy	= &sysctl_intvec_fragment,
 	},
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_LOW_THRESH,
@@ -748,17 +810,39 @@ static inline void ip6_frags_sysctl_unre
 
 static int ipv6_frags_init_net(struct net *net)
 {
+	int ret;
+
 	net->ipv6.frags.high_thresh = 256 * 1024;
 	net->ipv6.frags.low_thresh = 192 * 1024;
 	net->ipv6.frags.timeout = IPV6_FRAG_TIMEOUT;
 
 	inet_frags_init_net(&net->ipv6.frags);
 
-	return ip6_frags_ns_sysctl_register(net);
+	ret = ip6_frags_sysctl_register(net);
+	if (ret)
+		goto out_reg;
+
+	mem_reserve_init(&net->ipv6.frags.reserve, "IPv6 fragment cache",
+			 &net_skb_reserve);
+	ret = mem_reserve_kmalloc_set(&net->ipv6.frags.reserve,
+				      net->ipv6.frags.high_thresh);
+	if (ret)
+		goto out_reserve;
+
+	return 0;
+
+out_reserve:
+	mem_reserve_disconnect(&net->ipv6.frags.reserve);
+	ip6_frags_sysctl_unregister(net);
+out_reg:
+	inet_frags_exit_net(&net->ipv6.frags, &ip6_frags);
+
+	return ret;
 }
 
 static void ipv6_frags_exit_net(struct net *net)
 {
+	mem_reserve_disconnect(&net->ipv6.frags.reserve);
 	ip6_frags_ns_sysctl_unregister(net);
 	inet_frags_exit_net(&net->ipv6.frags, &ip6_frags);
 }
Index: linux-2.6/net/ipv4/route.c
===================================================================
--- linux-2.6.orig/net/ipv4/route.c
+++ linux-2.6/net/ipv4/route.c
@@ -107,6 +107,7 @@
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
+#include <linux/reserve.h>
 
 #define RT_FL_TOS(oldflp) \
     ((u32)(oldflp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK)))
@@ -2828,7 +2829,10 @@ void ip_rt_multicast_event(struct in_dev
 	rt_cache_flush(0);
 }
 
+static struct mem_reserve ipv4_route_reserve;
+
 #ifdef CONFIG_SYSCTL
+static struct mutex ipv4_route_lock;
 static int flush_delay;
 
 static int ipv4_sysctl_rtcache_flush(ctl_table *ctl, int write,
@@ -2861,6 +2865,64 @@ static int ipv4_sysctl_rtcache_flush_str
 	return 0;
 }
 
+static int proc_dointvec_route(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	int new_size, ret;
+
+	mutex_lock(&ipv4_route_lock);
+
+	if (write)
+		table->data = &new_size;
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&ipv4_route_reserve,
+				ipv4_dst_ops.kmem_cachep, new_size);
+		if (!ret)
+			ip_rt_max_size = new_size;
+	}
+
+	if (write)
+		table->data = &ip_rt_max_size;
+
+	mutex_unlock(&ipv4_route_lock);
+
+	return ret;
+}
+
+static int sysctl_intvec_route(struct ctl_table *table,
+		int __user *name, int nlen,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	int write = (newval && newlen);
+	int new_size, ret;
+
+	mutex_lock(&ipv4_route_lock);
+
+	if (write)
+		table->data = &new_size;
+
+	ret = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&ipv4_route_reserve,
+				ipv4_dst_ops.kmem_cachep, new_size);
+		if (!ret)
+			ip_rt_max_size = new_size;
+	}
+
+	if (write)
+		table->data = &ip_rt_max_size;
+
+	mutex_unlock(&ipv4_route_lock);
+
+	return ret;
+}
+
 ctl_table ipv4_route_table[] = {
 	{
 		.ctl_name 	= NET_IPV4_ROUTE_FLUSH,
@@ -2885,7 +2947,8 @@ ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_max_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_dointvec_route,
+		.strategy	= &sysctl_intvec_route,
 	},
 	{
 		/*  Deprecated. Use gc_min_interval_ms */
@@ -3060,6 +3123,13 @@ int __init ip_rt_init(void)
 	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
 	ip_rt_max_size = (rt_hash_mask + 1) * 16;
 
+	mutex_init(&ipv4_route_lock);
+
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
@@ -37,6 +37,7 @@
 #include <linux/mroute6.h>
 #include <linux/init.h>
 #include <linux/if_arp.h>
+#include <linux/reserve.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/nsproxy.h>
@@ -2498,6 +2499,66 @@ int ipv6_sysctl_rtcache_flush(ctl_table 
 		return -EINVAL;
 }
 
+static int proc_dointvec_route(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	struct net *net = current->nsproxy->net_ns;
+	int new_size, ret;
+
+	mutex_lock(&net->ipv6.sysctl.ip6_rt_lock);
+
+	if (write)
+		table->data = &new_size;
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&net->ipv6.ip6_rt_reserve,
+				net->ipv6.ip6_dst_ops.kmem_cachep, new_size);
+		if (!ret)
+			net->ipv6.sysctl.ip6_rt_max_size = new_size;
+	}
+
+	if (write)
+		table->data = &net->ipv6.sysctl.ip6_rt_max_size;
+
+	mutex_unlock(&net->ipv6.sysctl.ip6_rt_lock);
+
+	return ret;
+}
+
+static int sysctl_intvec_route(struct ctl_table *table,
+		int __user *name, int nlen,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	struct net *net = current->nsproxy->net_ns;
+	int write = (newval && newlen);
+	int new_size, ret;
+
+	mutex_lock(&net->ipv6.sysctl.ip6_rt_lock);
+
+	if (write)
+		table->data = &new_size;
+
+	ret = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&net->ipv6.ip6_rt_reserve,
+				net->ipv6.ip6_dst_ops.kmem_cachep, new_size);
+		if (!ret)
+			net->ipv6.sysctl.ip6_rt_max_size = new_size;
+	}
+
+	if (write)
+		table->data = &net->ipv6.sysctl.ip6_rt_max_size;
+
+	mutex_unlock(&net->ipv6.sysctl.ip6_rt_lock);
+
+	return ret;
+}
+
 ctl_table ipv6_route_table_template[] = {
 	{
 		.procname	=	"flush",
@@ -2520,7 +2581,8 @@ ctl_table ipv6_route_table_template[] = 
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_max_size,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec,
+		.proc_handler	=	&proc_dointvec_route,
+		.strategy	= 	&sysctl_intvec_route,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL,
@@ -2608,6 +2670,8 @@ struct ctl_table *ipv6_route_sysctl_init
 		table[8].data = &net->ipv6.sysctl.ip6_rt_min_advmss;
 	}
 
+	mutex_init(&net->ipv6.sysctl.ip6_rt_lock);
+
 	return table;
 }
 #endif
Index: linux-2.6/include/net/inet_frag.h
===================================================================
--- linux-2.6.orig/include/net/inet_frag.h
+++ linux-2.6/include/net/inet_frag.h
@@ -1,6 +1,9 @@
 #ifndef __NET_FRAG_H__
 #define __NET_FRAG_H__
 
+#include <linux/reserve.h>
+#include <linux/mutex.h>
+
 struct netns_frags {
 	int			nqueues;
 	atomic_t		mem;
@@ -10,6 +13,10 @@ struct netns_frags {
 	int			timeout;
 	int			high_thresh;
 	int			low_thresh;
+
+	/* reserves */
+	struct mutex		lock;
+	struct mem_reserve	reserve;
 };
 
 struct inet_frag_queue {
Index: linux-2.6/net/ipv4/inet_fragment.c
===================================================================
--- linux-2.6.orig/net/ipv4/inet_fragment.c
+++ linux-2.6/net/ipv4/inet_fragment.c
@@ -19,6 +19,7 @@
 #include <linux/random.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
+#include <linux/reserve.h>
 
 #include <net/inet_frag.h>
 
@@ -74,6 +75,8 @@ void inet_frags_init_net(struct netns_fr
 	nf->nqueues = 0;
 	atomic_set(&nf->mem, 0);
 	INIT_LIST_HEAD(&nf->lru_list);
+	mutex_init(&nf->lock);
+	mem_reserve_init(&nf->reserve, "IP fragement cache", NULL);
 }
 EXPORT_SYMBOL(inet_frags_init_net);
 
Index: linux-2.6/include/net/netns/ipv6.h
===================================================================
--- linux-2.6.orig/include/net/netns/ipv6.h
+++ linux-2.6/include/net/netns/ipv6.h
@@ -24,6 +24,8 @@ struct netns_sysctl_ipv6 {
 	int ip6_rt_mtu_expires;
 	int ip6_rt_min_advmss;
 	int icmpv6_time;
+
+	struct mutex ip6_rt_lock;
 };
 
 struct netns_ipv6 {
@@ -55,5 +57,7 @@ struct netns_ipv6 {
 	struct sock             *ndisc_sk;
 	struct sock             *tcp_sk;
 	struct sock             *igmp_sk;
+
+	struct mem_reserve	ip6_rt_reserve;
 };
 #endif
Index: linux-2.6/net/ipv6/af_inet6.c
===================================================================
--- linux-2.6.orig/net/ipv6/af_inet6.c
+++ linux-2.6/net/ipv6/af_inet6.c
@@ -851,6 +851,20 @@ static int inet6_net_init(struct net *ne
 	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 
+	mem_reserve_init(&net->ipv6.ip6_rt_reserve, "IPv6 route cache",
+			 &net_rx_reserve);
+	/*
+	 * XXX: requires that net->ipv6.ip6_dst_ops is already set-up
+	 *      but afaikt its impossible to order the various
+	 *      pernet_subsys calls so that this one is done after
+	 *      ip6_route_net_init().
+	 */
+	err = mem_reserve_kmem_cache_set(&net->ipv6.ip6_rt_reserve,
+			net->ipv6.ip6_dst_ops.kmem_cachep,
+			net->ipv6.sysctl.ip6_rt_max_size);
+	if (err)
+		goto reserve_fail;
+
 #ifdef CONFIG_PROC_FS
 	err = udp6_proc_init(net);
 	if (err)
@@ -861,8 +875,8 @@ static int inet6_net_init(struct net *ne
 	err = ac6_proc_init(net);
 	if (err)
 		goto proc_ac6_fail;
-out:
 #endif
+out:
 	return err;
 
 #ifdef CONFIG_PROC_FS
@@ -870,8 +884,10 @@ proc_ac6_fail:
 	tcp6_proc_exit(net);
 proc_tcp6_fail:
 	udp6_proc_exit(net);
-	goto out;
 #endif
+reserve_fail:
+	mem_reserve_disconnect(&net->ipv6.ip6_rt_reserve);
+	goto out;
 }
 
 static void inet6_net_exit(struct net *net)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
