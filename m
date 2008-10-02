Message-Id: <20081002131607.801664200@chello.nl>
References: <20081002130504.927878499@chello.nl>
Date: Thu, 02 Oct 2008 15:05:08 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/32] net: ipv6: initialize ip6_route sysctl vars in ip6_route_net_init()
Content-Disposition: inline; filename=net-ipv6-route-cleanup-sysctl.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

This makes that ip6_route_net_init() does all of the route init code.
There used to be a race between ip6_route_net_init() and ip6_net_init()
and someone relying on the combined result was left out cold.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 net/ipv6/af_inet6.c |    8 --------
 net/ipv6/route.c    |    9 +++++++++
 2 files changed, 9 insertions(+), 8 deletions(-)

Index: linux-2.6/net/ipv6/af_inet6.c
===================================================================
--- linux-2.6.orig/net/ipv6/af_inet6.c
+++ linux-2.6/net/ipv6/af_inet6.c
@@ -839,14 +839,6 @@ static int inet6_net_init(struct net *ne
 	int err = 0;
 
 	net->ipv6.sysctl.bindv6only = 0;
-	net->ipv6.sysctl.flush_delay = 0;
-	net->ipv6.sysctl.ip6_rt_max_size = 4096;
-	net->ipv6.sysctl.ip6_rt_gc_min_interval = HZ / 2;
-	net->ipv6.sysctl.ip6_rt_gc_timeout = 60*HZ;
-	net->ipv6.sysctl.ip6_rt_gc_interval = 30*HZ;
-	net->ipv6.sysctl.ip6_rt_gc_elasticity = 9;
-	net->ipv6.sysctl.ip6_rt_mtu_expires = 10*60*HZ;
-	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 
 #ifdef CONFIG_PROC_FS
Index: linux-2.6/net/ipv6/route.c
===================================================================
--- linux-2.6.orig/net/ipv6/route.c
+++ linux-2.6/net/ipv6/route.c
@@ -2627,6 +2627,15 @@ static int ip6_route_net_init(struct net
 	net->ipv6.ip6_blk_hole_entry->u.dst.ops = net->ipv6.ip6_dst_ops;
 #endif
 
+	net->ipv6.sysctl.flush_delay = 0;
+	net->ipv6.sysctl.ip6_rt_max_size = 4096;
+	net->ipv6.sysctl.ip6_rt_gc_min_interval = HZ / 2;
+	net->ipv6.sysctl.ip6_rt_gc_timeout = 60*HZ;
+	net->ipv6.sysctl.ip6_rt_gc_interval = 30*HZ;
+	net->ipv6.sysctl.ip6_rt_gc_elasticity = 9;
+	net->ipv6.sysctl.ip6_rt_mtu_expires = 10*60*HZ;
+	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
+
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create(net, "ipv6_route", 0, &ipv6_route_proc_fops);
 	proc_net_fops_create(net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
