Message-Id: <20081002131607.731557157@chello.nl>
References: <20081002130504.927878499@chello.nl>
Date: Thu, 02 Oct 2008 15:05:07 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 03/32] net: ipv6: clean up ip6_route_net_init() error handling
Content-Disposition: inline; filename=net-ipv6-route-cleanup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

ip6_route_net_init() error handling looked less than solid, fix 'er up.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 net/ipv6/route.c |   19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

Index: linux-2.6/net/ipv6/route.c
===================================================================
--- linux-2.6.orig/net/ipv6/route.c
+++ linux-2.6/net/ipv6/route.c
@@ -2611,10 +2611,8 @@ static int ip6_route_net_init(struct net
 	net->ipv6.ip6_prohibit_entry = kmemdup(&ip6_prohibit_entry_template,
 					       sizeof(*net->ipv6.ip6_prohibit_entry),
 					       GFP_KERNEL);
-	if (!net->ipv6.ip6_prohibit_entry) {
-		kfree(net->ipv6.ip6_null_entry);
-		goto out;
-	}
+	if (!net->ipv6.ip6_prohibit_entry)
+		goto out_ip6_null_entry;
 	net->ipv6.ip6_prohibit_entry->u.dst.path =
 		(struct dst_entry *)net->ipv6.ip6_prohibit_entry;
 	net->ipv6.ip6_prohibit_entry->u.dst.ops = net->ipv6.ip6_dst_ops;
@@ -2622,11 +2620,8 @@ static int ip6_route_net_init(struct net
 	net->ipv6.ip6_blk_hole_entry = kmemdup(&ip6_blk_hole_entry_template,
 					       sizeof(*net->ipv6.ip6_blk_hole_entry),
 					       GFP_KERNEL);
-	if (!net->ipv6.ip6_blk_hole_entry) {
-		kfree(net->ipv6.ip6_null_entry);
-		kfree(net->ipv6.ip6_prohibit_entry);
-		goto out;
-	}
+	if (!net->ipv6.ip6_blk_hole_entry)
+		goto out_ip6_prohibit_entry;
 	net->ipv6.ip6_blk_hole_entry->u.dst.path =
 		(struct dst_entry *)net->ipv6.ip6_blk_hole_entry;
 	net->ipv6.ip6_blk_hole_entry->u.dst.ops = net->ipv6.ip6_dst_ops;
@@ -2642,6 +2637,12 @@ static int ip6_route_net_init(struct net
 out:
 	return ret;
 
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+out_ip6_prohibit_entry:
+	kfree(net->ipv6.ip6_prohibit_entry);
+out_ip6_null_entry:
+	kfree(net->ipv6.ip6_null_entry);
+#endif
 out_ip6_dst_ops:
 	release_net(net->ipv6.ip6_dst_ops->dst_net);
 	kfree(net->ipv6.ip6_dst_ops);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
