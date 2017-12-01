Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E4E4D6B0069
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 08:57:54 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v8so1030132wmh.2
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 05:57:54 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s11si5808748edj.532.2017.12.01.05.57.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Dec 2017 05:57:53 -0800 (PST)
Date: Fri, 1 Dec 2017 13:57:50 +0000
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 07/15] mm: memcontrol: fix excessive complexity in
 memory.stat reporting
Message-ID: <20171201135750.GB8097@cmpxchg.org>
References: <5a208303.hxMsAOT0gjSsd0Gf%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a208303.hxMsAOT0gjSsd0Gf%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mhocko@suse.com, vdavydov.dev@gmail.com

On Thu, Nov 30, 2017 at 02:15:31PM -0800, akpm@linux-foundation.org wrote:
> @@ -1858,9 +1824,44 @@ static void drain_all_stock(struct mem_c
>  static int memcg_hotplug_cpu_dead(unsigned int cpu)
>  {
>  	struct memcg_stock_pcp *stock;
> +	struct mem_cgroup *memcg;
>  
>  	stock = &per_cpu(memcg_stock, cpu);
>  	drain_stock(stock);
> +
> +	for_each_mem_cgroup(memcg) {
> +		int i;
> +
> +		for (i = 0; i < MEMCG_NR_STAT; i++) {
> +			int nid;
> +			long x;
> +
> +			x = __this_cpu_xchg(memcg->stat_cpu->count[i], 0);
> +			if (x)
> +				atomic_long_add(x, &memcg->stat[i]);
> +
> +			if (i >= NR_VM_NODE_STAT_ITEMS)
> +				continue;
> +
> +			for_each_node(nid) {
> +				struct mem_cgroup_per_node *pn;
> +
> +				pn = mem_cgroup_nodeinfo(memcg, nid);
> +				x = __this_cpu_xchg(pn->lruvec_stat_cpu->count[i], 0);
> +				if (x)
> +					atomic_long_add(x, &pn->lruvec_stat[i]);
> +			}
> +		}
> +
> +		for (i = 0; i < MEMCG_NR_EVENTS; i++) {
> +			long x;
> +
> +			x = __this_cpu_xchg(memcg->stat_cpu->events[i], 0);
> +			if (x)
> +				atomic_long_add(x, &memcg->events[i]);
> +		}
> +	}
> +
>  	return 0;
>  }

The memcg cpu_dead callback can be called early during startup
(CONFIG_DEBUG_HOTPLUG_CPU0) with preemption enabled, which triggers a
warning in its __this_cpu_xchg() calls. But CPU locality is always
guaranteed, which is the only thing we really care about here.

Using the preemption-safe this_cpu_xchg() addresses this problem.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

Andrew, can you please merge this fixlet into the original patch?

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 40d1ef65fbd2..e616c1b0e458 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1836,7 +1836,7 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 			int nid;
 			long x;
 
-			x = __this_cpu_xchg(memcg->stat_cpu->count[i], 0);
+			x = this_cpu_xchg(memcg->stat_cpu->count[i], 0);
 			if (x)
 				atomic_long_add(x, &memcg->stat[i]);
 
@@ -1847,7 +1847,7 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 				struct mem_cgroup_per_node *pn;
 
 				pn = mem_cgroup_nodeinfo(memcg, nid);
-				x = __this_cpu_xchg(pn->lruvec_stat_cpu->count[i], 0);
+				x = this_cpu_xchg(pn->lruvec_stat_cpu->count[i], 0);
 				if (x)
 					atomic_long_add(x, &pn->lruvec_stat[i]);
 			}
@@ -1856,7 +1856,7 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 		for (i = 0; i < MEMCG_NR_EVENTS; i++) {
 			long x;
 
-			x = __this_cpu_xchg(memcg->stat_cpu->events[i], 0);
+			x = this_cpu_xchg(memcg->stat_cpu->events[i], 0);
 			if (x)
 				atomic_long_add(x, &memcg->events[i]);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
