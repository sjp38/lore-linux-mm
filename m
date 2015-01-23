Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 170036B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 12:38:35 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id l15so4427709wiw.0
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 09:38:34 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qm1si2523915wjc.14.2015.01.23.09.38.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 09:38:33 -0800 (PST)
Date: Fri, 23 Jan 2015 12:38:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
Message-ID: <20150123173828.GC12036@phnom.home.cmpxchg.org>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
 <20150123050802.GB22751@roeck-us.net>
 <20150123141817.GA22926@phnom.home.cmpxchg.org>
 <alpine.DEB.2.11.1501230908560.15325@gentwo.org>
 <20150123160204.GA32592@phnom.home.cmpxchg.org>
 <54C27E07.6000908@roeck-us.net>
 <20150123173659.GB12036@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150123173659.GB12036@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, mhocko@suse.cz

On Fri, Jan 23, 2015 at 12:36:59PM -0500, Johannes Weiner wrote:
> ("mm: memcontrol: consolidate swap controller code") gave me no issues
> when rebasing, but ("mm: memcontrol: consolidate memory controller
> initialization") needs updating.

And this as the refreshed version of ("mm: memcontrol: consolidate
memory controller initialization"):

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: consolidate memory controller initialization

The initialization code for the per-cpu charge stock and the soft
limit tree is compact enough to inline it into mem_cgroup_init().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c | 60 ++++++++++++++++++++++++---------------------------------
 1 file changed, 25 insertions(+), 35 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 88c67303d141..2ad11e5c95c3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2150,17 +2150,6 @@ static void drain_local_stock(struct work_struct *dummy)
 	clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
 }
 
-static void __init memcg_stock_init(void)
-{
-	int cpu;
-
-	for_each_possible_cpu(cpu) {
-		struct memcg_stock_pcp *stock =
-					&per_cpu(memcg_stock, cpu);
-		INIT_WORK(&stock->work, drain_local_stock);
-	}
-}
-
 /*
  * Cache charges(val) to local per_cpu area.
  * This will be consumed by consume_stock() function, later.
@@ -4535,28 +4524,6 @@ struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(parent_mem_cgroup);
 
-static void __init mem_cgroup_soft_limit_tree_init(void)
-{
-	int node;
-
-	for_each_node(node) {
-		struct mem_cgroup_tree_per_node *rtpn;
-		int zone;
-
-		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
-				    node_online(node) ? node : NUMA_NO_NODE);
-
-		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
-			struct mem_cgroup_tree_per_zone *rtpz;
-
-			rtpz = &rtpn->rb_tree_per_zone[zone];
-			rtpz->rb_root = RB_ROOT;
-			spin_lock_init(&rtpz->lock);
-		}
-		soft_limit_tree.rb_tree_per_node[node] = rtpn;
-	}
-}
-
 static struct cgroup_subsys_state * __ref
 mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
@@ -5934,10 +5901,33 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
  */
 static int __init mem_cgroup_init(void)
 {
+	int cpu, node;
+
 	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
+
+	for_each_possible_cpu(cpu)
+		INIT_WORK(&per_cpu_ptr(&memcg_stock, cpu)->work,
+			  drain_local_stock);
+
+	for_each_node(node) {
+		struct mem_cgroup_tree_per_node *rtpn;
+		int zone;
+
+		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
+				    node_online(node) ? node : NUMA_NO_NODE);
+
+		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+			struct mem_cgroup_tree_per_zone *rtpz;
+
+			rtpz = &rtpn->rb_tree_per_zone[zone];
+			rtpz->rb_root = RB_ROOT;
+			spin_lock_init(&rtpz->lock);
+		}
+		soft_limit_tree.rb_tree_per_node[node] = rtpn;
+	}
+
 	enable_swap_cgroup();
-	mem_cgroup_soft_limit_tree_init();
-	memcg_stock_init();
+
 	return 0;
 }
 subsys_initcall(mem_cgroup_init);
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
