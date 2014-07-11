Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 640B46B0036
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:35:33 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so943963pdj.29
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:35:33 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dn2si756915pdb.500.2014.07.11.00.35.31
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:35:32 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 03/30] mm, net: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:20 +0800
Message-Id: <1405064267-11678-4-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, "David S. Miller" <davem@davemloft.net>, Steffen Klassert <steffen.klassert@secunet.com>, Herbert Xu <herbert@gondor.apana.org.au>, Veaceslav Falico <vfalico@redhat.com>, Eric Dumazet <edumazet@google.com>, Vlad Yasevich <vyasevic@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, stephen hemminger <stephen@networkplumber.org>, Jerry Chu <hkchu@google.com>, Ben Hutchings <bhutchings@solarflare.com>, Fan Du <fan.du@windriver.com>, Mathias Krause <minipli@googlemail.com>, Thomas Graf <tgraf@suug.ch>, Jiang Liu <jiang.liu@linux.intel.com>, Joe Perches <joe@perches.com>, Roman Gushchin <klamm@yandex-team.ru>
Cc: Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
may return a node without memory, and later cause system failure/panic
when calling kmalloc_node() and friends with returned node id.
So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
memory for the/current cpu.

If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
is the same as cpu_to_node()/numa_node_id().

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 net/core/dev.c             |    6 +++---
 net/core/flow.c            |    2 +-
 net/core/pktgen.c          |   10 +++++-----
 net/core/sysctl_net_core.c |    2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 30eedf677913..e4c1e84374b7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1910,7 +1910,7 @@ static struct xps_map *expand_xps_map(struct xps_map *map,
 
 	/* Need to allocate new map to store queue on this CPU's map */
 	new_map = kzalloc_node(XPS_MAP_SIZE(alloc_len), GFP_KERNEL,
-			       cpu_to_node(cpu));
+			       cpu_to_mem(cpu));
 	if (!new_map)
 		return NULL;
 
@@ -1973,8 +1973,8 @@ int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
 				map->queues[map->len++] = index;
 #ifdef CONFIG_NUMA
 			if (numa_node_id == -2)
-				numa_node_id = cpu_to_node(cpu);
-			else if (numa_node_id != cpu_to_node(cpu))
+				numa_node_id = cpu_to_mem(cpu);
+			else if (numa_node_id != cpu_to_mem(cpu))
 				numa_node_id = -1;
 #endif
 		} else if (dev_maps) {
diff --git a/net/core/flow.c b/net/core/flow.c
index a0348fde1fdf..4139dbb50cc0 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -396,7 +396,7 @@ static int flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
 	size_t sz = sizeof(struct hlist_head) * flow_cache_hash_size(fc);
 
 	if (!fcp->hash_table) {
-		fcp->hash_table = kzalloc_node(sz, GFP_KERNEL, cpu_to_node(cpu));
+		fcp->hash_table = kzalloc_node(sz, GFP_KERNEL, cpu_to_mem(cpu));
 		if (!fcp->hash_table) {
 			pr_err("NET: failed to allocate flow cache sz %zu\n", sz);
 			return -ENOMEM;
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fc17a9d309ac..45d18f88dce4 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2653,7 +2653,7 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 			   (datalen/frags) : PAGE_SIZE;
 		while (datalen > 0) {
 			if (unlikely(!pkt_dev->page)) {
-				int node = numa_node_id();
+				int node = numa_mem_id();
 
 				if (pkt_dev->node >= 0 && (pkt_dev->flags & F_NODE))
 					node = pkt_dev->node;
@@ -2698,7 +2698,7 @@ static struct sk_buff *pktgen_alloc_skb(struct net_device *dev,
 			    pkt_dev->pkt_overhead;
 
 	if (pkt_dev->flags & F_NODE) {
-		int node = pkt_dev->node >= 0 ? pkt_dev->node : numa_node_id();
+		int node = pkt_dev->node >= 0 ? pkt_dev->node : numa_mem_id();
 
 		skb = __alloc_skb(NET_SKB_PAD + size, GFP_NOWAIT, 0, node);
 		if (likely(skb)) {
@@ -3533,7 +3533,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 {
 	struct pktgen_dev *pkt_dev;
 	int err;
-	int node = cpu_to_node(t->cpu);
+	int node = cpu_to_mem(t->cpu);
 
 	/* We don't allow a device to be on several threads */
 
@@ -3621,7 +3621,7 @@ static int __net_init pktgen_create_thread(int cpu, struct pktgen_net *pn)
 	struct task_struct *p;
 
 	t = kzalloc_node(sizeof(struct pktgen_thread), GFP_KERNEL,
-			 cpu_to_node(cpu));
+			 cpu_to_mem(cpu));
 	if (!t) {
 		pr_err("ERROR: out of memory, can't create new thread\n");
 		return -ENOMEM;
@@ -3637,7 +3637,7 @@ static int __net_init pktgen_create_thread(int cpu, struct pktgen_net *pn)
 
 	p = kthread_create_on_node(pktgen_thread_worker,
 				   t,
-				   cpu_to_node(cpu),
+				   cpu_to_mem(cpu),
 				   "kpktgend_%d", cpu);
 	if (IS_ERR(p)) {
 		pr_err("kernel_thread() failed for cpu %d\n", t->cpu);
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cf9cd13509a7..1375447b833e 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -123,7 +123,7 @@ static int flow_limit_cpu_sysctl(struct ctl_table *table, int write,
 				kfree(cur);
 			} else if (!cur && cpumask_test_cpu(i, mask)) {
 				cur = kzalloc_node(len, GFP_KERNEL,
-						   cpu_to_node(i));
+						   cpu_to_mem(i));
 				if (!cur) {
 					/* not unwinding previous changes */
 					ret = -ENOMEM;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
