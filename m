Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 94154280244
	for <linux-mm@kvack.org>; Sun, 16 Aug 2015 23:16:11 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so98427482pab.0
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 20:16:11 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id dn2si22343750pdb.103.2015.08.16.20.16.10
        for <linux-mm@kvack.org>;
        Sun, 16 Aug 2015 20:16:10 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [Patch V3 4/9] openvswitch: Replace cpu_to_node() with cpu_to_mem() to support memoryless node
Date: Mon, 17 Aug 2015 11:19:01 +0800
Message-Id: <1439781546-7217-5-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Pravin Shelar <pshelar@nicira.com>, "David S. Miller" <davem@davemloft.net>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, netdev@vger.kernel.org, dev@openvswitch.org

Function ovs_flow_stats_update() allocates memory with __GFP_THISNODE
flag set, which may cause permanent memory allocation failure on
memoryless node. So replace cpu_to_node() with cpu_to_mem() to better
support memoryless node. For node with memory, cpu_to_mem() is the same
as cpu_to_node().

This change only affects performance and shouldn't affect functionality.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 net/openvswitch/flow.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index bc7b0aba994a..e50a5681d0c2 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -69,7 +69,7 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 			   const struct sk_buff *skb)
 {
 	struct flow_stats *stats;
-	int node = numa_node_id();
+	int node = numa_mem_id();
 	int len = skb->len + (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 
 	stats = rcu_dereference(flow->stats[node]);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
