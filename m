Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 53979280244
	for <linux-mm@kvack.org>; Sun, 16 Aug 2015 23:16:38 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so98434274pab.0
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 20:16:38 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id dx4si3277826pab.25.2015.08.16.20.16.37
        for <linux-mm@kvack.org>;
        Sun, 16 Aug 2015 20:16:37 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [Patch V3 8/9] mm: Update _mem_id_[] for every possible CPU when memory configuration changes
Date: Mon, 17 Aug 2015 11:19:05 +0800
Message-Id: <1439781546-7217-9-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

Current kernel only updates _mem_id_[cpu] for onlined CPUs when memory
configuration changes. So kernel may allocate memory from remote node
for a CPU if the CPU is still in absent or offline state even if the
node associated with the CPU has already been onlined. This patch tries
to improve performance by updating _mem_id_[cpu] for each possible CPU
when memory configuration changes, thus kernel could always allocate
from local node once the node is onlined.

We check node_online(cpu_to_node(cpu)) because:
1) local_memory_node(nid) needs to access NODE_DATA(nid)
2) try_offline_node(nid) just zeroes out NODE_DATA(nid) instead of free it

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 mm/page_alloc.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index beda41710802..bcfd66e66820 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4334,13 +4334,13 @@ static int __build_all_zonelists(void *data)
 		/*
 		 * We now know the "local memory node" for each node--
 		 * i.e., the node of the first zone in the generic zonelist.
-		 * Set up numa_mem percpu variable for on-line cpus.  During
-		 * boot, only the boot cpu should be on-line;  we'll init the
-		 * secondary cpus' numa_mem as they come on-line.  During
-		 * node/memory hotplug, we'll fixup all on-line cpus.
+		 * Set up numa_mem percpu variable for all possible cpus
+		 * if associated node has been onlined.
 		 */
-		if (cpu_online(cpu))
+		if (node_online(cpu_to_node(cpu)))
 			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
+		else
+			set_cpu_numa_mem(cpu, NUMA_NO_NODE);
 #endif
 	}
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
