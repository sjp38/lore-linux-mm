Message-Id: <20081002131609.071928149@chello.nl>
References: <20081002130504.927878499@chello.nl>
Date: Thu, 02 Oct 2008 15:05:24 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 20/32] netvm: INET reserves.
Content-Disposition: inline; filename=netvm-reserve-inet.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
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
 net/ipv4/ip_fragment.c   |   86 +++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/route.c         |   70 +++++++++++++++++++++++++++++++++++++-
 net/ipv6/reassembly.c    |   85 +++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/route.c         |   77 ++++++++++++++++++++++++++++++++++++++++--
 7 files changed, 325 insertions(+), 7 deletions(-)

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
@@ -599,6 +601,63 @@ int ip_defrag(struct sk_buff *skb, u32 u
 }
 
 #ifdef CONFIG_SYSCTL
+static int proc_dointvec_fragment(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	struct net *net = container_of(table->data, struct net,
+				       ipv4.frags.high_thresh);
+	ctl_table tmp = *table;
+	int new_bytes, ret;
+
+	mutex_lock(&net->ipv4.frags.lock);
+	if (write) {
+		tmp.data = &new_bytes;
+		table = &tmp;
+	}
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&net->ipv4.frags.reserve,
+				new_bytes);
+		if (!ret)
+			net->ipv4.frags.high_thresh = new_bytes;
+	}
+	mutex_unlock(&net->ipv4.frags.lock);
+
+	return ret;
+}
+
+static int sysctl_intvec_fragment(struct ctl_table *table,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	struct net *net = container_of(table->data, struct net,
+				       ipv4.frags.high_thresh);
+	int write = (newval && newlen);
+	ctl_table tmp = *table;
+	int new_bytes, ret;
+
+	mutex_lock(&net->ipv4.frags.lock);
+	if (write) {
+		tmp.data = &new_bytes;
+		table = &tmp;
+	}
+
+	ret = sysctl_intvec(table, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&net->ipv4.frags.reserve,
+				new_bytes);
+		if (!ret)
+			net->ipv4.frags.high_thresh = new_bytes;
+	}
+	mutex_unlock(&net->ipv4.frags.lock);
+
+	return ret;
+}
+
 static int zero;
 
 static struct ctl_table ip4_frags_ns_ctl_table[] = {
@@ -608,7 +667,8 @@ static struct ctl_table ip4_frags_ns_ctl
 		.data		= &init_net.ipv4.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment,
+		.strategy	= &sysctl_intvec_fragment,
 	},
 	{
 		.ctl_name	= NET_IPV4_IPFRAG_LOW_THRESH,
@@ -711,6 +771,8 @@ static inline void ip4_frags_ctl_registe
 
 static int ipv4_frags_init_net(struct net *net)
 {
+	int ret;
+
 	/*
 	 * Fragment cache limits. We will commit 256K at one time. Should we
 	 * cross that limit we will prune down to 192K. This should cope with
@@ -728,11 +790,31 @@ static int ipv4_frags_init_net(struct ne
 
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
@@ -632,6 +633,63 @@ static struct inet6_protocol frag_protoc
 };
 
 #ifdef CONFIG_SYSCTL
+static int proc_dointvec_fragment(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	struct net *net = container_of(table->data, struct net,
+				       ipv6.frags.high_thresh);
+	ctl_table tmp = *table;
+	int new_bytes, ret;
+
+	mutex_lock(&net->ipv6.frags.lock);
+	if (write) {
+		tmp.data = &new_bytes;
+		table = &tmp;
+	}
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&net->ipv6.frags.reserve,
+					      new_bytes);
+		if (!ret)
+			net->ipv6.frags.high_thresh = new_bytes;
+	}
+	mutex_unlock(&net->ipv6.frags.lock);
+
+	return ret;
+}
+
+static int sysctl_intvec_fragment(struct ctl_table *table,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	struct net *net = container_of(table->data, struct net,
+				       ipv6.frags.high_thresh);
+	int write = (newval && newlen);
+	ctl_table tmp = *table;
+	int new_bytes, ret;
+
+	mutex_lock(&net->ipv6.frags.lock);
+	if (write) {
+		tmp.data = &new_bytes;
+		table = &tmp;
+	}
+
+	ret = sysctl_intvec(table, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&net->ipv6.frags.reserve,
+					      new_bytes);
+		if (!ret)
+			net->ipv6.frags.high_thresh = new_bytes;
+	}
+	mutex_unlock(&net->ipv6.frags.lock);
+
+	return ret;
+}
+
 static struct ctl_table ip6_frags_ns_ctl_table[] = {
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_HIGH_THRESH,
@@ -639,7 +697,8 @@ static struct ctl_table ip6_frags_ns_ctl
 		.data		= &init_net.ipv6.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment,
+		.strategy	= &sysctl_intvec_fragment,
 	},
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_LOW_THRESH,
@@ -748,17 +807,39 @@ static inline void ip6_frags_sysctl_unre
 
 static int ipv6_frags_init_net(struct net *net)
 {
+	int ret;
+
 	net->ipv6.frags.high_thresh = 256 * 1024;
 	net->ipv6.frags.low_thresh = 192 * 1024;
 	net->ipv6.frags.timeout = IPV6_FRAG_TIMEOUT;
 
 	inet_frags_init_net(&net->ipv6.frags);
 
-	return ip6_frags_ns_sysctl_register(net);
+	ret = ip6_frags_ns_sysctl_register(net);
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
+	ip6_frags_ns_sysctl_unregister(net);
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
@@ -269,6 +270,8 @@ static inline int rt_genid(struct net *n
 	return atomic_read(&net->ipv4.rt_genid);
 }
 
+static struct mem_reserve ipv4_route_reserve;
+
 #ifdef CONFIG_PROC_FS
 struct rt_cache_iter_state {
 	struct seq_net_private p;
@@ -398,6 +401,61 @@ static int rt_cache_seq_show(struct seq_
 	return 0;
 }
 
+static struct mutex ipv4_route_lock;
+
+static int proc_dointvec_route(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	ctl_table tmp = *table;
+	int new_size, ret;
+
+	mutex_lock(&ipv4_route_lock);
+	if (write) {
+		tmp.data = &new_size;
+		table = &tmp;
+	}
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&ipv4_route_reserve,
+				ipv4_dst_ops.kmem_cachep, new_size);
+		if (!ret)
+			ip_rt_max_size = new_size;
+	}
+	mutex_unlock(&ipv4_route_lock);
+
+	return ret;
+}
+
+static int sysctl_intvec_route(struct ctl_table *table,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	int write = (newval && newlen);
+	ctl_table tmp = *table;
+	int new_size, ret;
+
+	mutex_lock(&ipv4_route_lock);
+	if (write) {
+		tmp.data = &new_size;
+		table = &tmp;
+	}
+
+	ret = sysctl_intvec(table, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&ipv4_route_reserve,
+				ipv4_dst_ops.kmem_cachep, new_size);
+		if (!ret)
+			ip_rt_max_size = new_size;
+	}
+	mutex_unlock(&ipv4_route_lock);
+
+	return ret;
+}
+
 static const struct seq_operations rt_cache_seq_ops = {
 	.start  = rt_cache_seq_start,
 	.next   = rt_cache_seq_next,
@@ -2992,7 +3050,8 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_max_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_dointvec_route,
+		.strategy	= &sysctl_intvec_route,
 	},
 	{
 		/*  Deprecated. Use gc_min_interval_ms */
@@ -3271,6 +3330,15 @@ int __init ip_rt_init(void)
 	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
 	ip_rt_max_size = (rt_hash_mask + 1) * 16;
 
+#ifdef CONFIG_PROCFS
+	mutex_init(&ipv4_route_lock);
+#endif
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
@@ -2473,6 +2474,63 @@ int ipv6_sysctl_rtcache_flush(ctl_table 
 		return -EINVAL;
 }
 
+static int proc_dointvec_route(struct ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	struct net *net = container_of(table->data, struct net,
+				       ipv6.sysctl.ip6_rt_max_size);
+	ctl_table tmp = *table;
+	int new_size, ret;
+
+	mutex_lock(&net->ipv6.sysctl.ip6_rt_lock);
+	if (write) {
+		tmp.data = &new_size;
+		table = &tmp;
+	}
+
+	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&net->ipv6.ip6_rt_reserve,
+				net->ipv6.ip6_dst_ops->kmem_cachep, new_size);
+		if (!ret)
+			net->ipv6.sysctl.ip6_rt_max_size = new_size;
+	}
+	mutex_unlock(&net->ipv6.sysctl.ip6_rt_lock);
+
+	return ret;
+}
+
+static int sysctl_intvec_route(struct ctl_table *table,
+		void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	struct net *net = container_of(table->data, struct net,
+				       ipv6.sysctl.ip6_rt_max_size);
+	int write = (newval && newlen);
+	ctl_table tmp = *table;
+	int new_size, ret;
+
+	mutex_lock(&net->ipv6.sysctl.ip6_rt_lock);
+	if (write) {
+		tmp.data = &new_size;
+		table = &tmp;
+	}
+
+	ret = sysctl_intvec(table, oldval, oldlenp, newval, newlen);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&net->ipv6.ip6_rt_reserve,
+				net->ipv6.ip6_dst_ops->kmem_cachep, new_size);
+		if (!ret)
+			net->ipv6.sysctl.ip6_rt_max_size = new_size;
+	}
+	mutex_unlock(&net->ipv6.sysctl.ip6_rt_lock);
+
+	return ret;
+}
+
 ctl_table ipv6_route_table_template[] = {
 	{
 		.procname	=	"flush",
@@ -2495,7 +2553,8 @@ ctl_table ipv6_route_table_template[] = 
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_max_size,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec,
+		.proc_handler	=	&proc_dointvec_route,
+		.strategy	= 	&sysctl_intvec_route,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL,
@@ -2583,6 +2642,8 @@ struct ctl_table *ipv6_route_sysctl_init
 		table[8].data = &net->ipv6.sysctl.ip6_rt_min_advmss;
 	}
 
+	mutex_init(&net->ipv6.sysctl.ip6_rt_lock);
+
 	return table;
 }
 #endif
@@ -2636,6 +2697,14 @@ static int ip6_route_net_init(struct net
 	net->ipv6.sysctl.ip6_rt_mtu_expires = 10*60*HZ;
 	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
 
+	mem_reserve_init(&net->ipv6.ip6_rt_reserve, "IPv6 route cache",
+			 &net_rx_reserve);
+	ret = mem_reserve_kmem_cache_set(&net->ipv6.ip6_rt_reserve,
+			net->ipv6.ip6_dst_ops->kmem_cachep,
+			net->ipv6.sysctl.ip6_rt_max_size);
+	if (ret)
+		goto out_reserve_fail;
+
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create(net, "ipv6_route", 0, &ipv6_route_proc_fops);
 	proc_net_fops_create(net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
@@ -2646,12 +2715,15 @@ static int ip6_route_net_init(struct net
 out:
 	return ret;
 
+out_reserve_fail:
+	mem_reserve_disconnect(&net->ipv6.ip6_rt_reserve);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	kfree(net->ipv6.ip6_blk_hole_entry);
 out_ip6_prohibit_entry:
 	kfree(net->ipv6.ip6_prohibit_entry);
 out_ip6_null_entry:
-	kfree(net->ipv6.ip6_null_entry);
 #endif
+	kfree(net->ipv6.ip6_null_entry);
 out_ip6_dst_ops:
 	release_net(net->ipv6.ip6_dst_ops->dst_net);
 	kfree(net->ipv6.ip6_dst_ops);
@@ -2664,6 +2736,7 @@ static void ip6_route_net_exit(struct ne
 	proc_net_remove(net, "ipv6_route");
 	proc_net_remove(net, "rt6_stats");
 #endif
+	mem_reserve_disconnect(&net->ipv6.ip6_rt_reserve);
 	kfree(net->ipv6.ip6_null_entry);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	kfree(net->ipv6.ip6_prohibit_entry);
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

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
