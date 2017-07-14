Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1D1E4408FE
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:00:30 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g15so8060087wmi.11
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:30 -0700 (PDT)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id w37si3242353wrc.319.2017.07.14.01.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 01:00:29 -0700 (PDT)
Received: by mail-wr0-f196.google.com with SMTP id y28so6551661wrd.2
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:29 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/9] mm, page_alloc: do not set_cpu_numa_mem on empty nodes initialization
Date: Fri, 14 Jul 2017 10:00:00 +0200
Message-Id: <20170714080006.7250-4-mhocko@kernel.org>
In-Reply-To: <20170714080006.7250-1-mhocko@kernel.org>
References: <20170714080006.7250-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__build_all_zonelists reinitializes each online cpu local node for
CONFIG_HAVE_MEMORYLESS_NODES. This makes sense because previously memory
less nodes could gain some memory during memory hotplug and so the local
node should be changed for CPUs close to such a node. It makes less
sense to do that unconditionally for a newly creaded NUMA node which is
still offline and without any memory.

Let's also simplify the cpu loop and use for_each_online_cpu instead of
an explicit cpu_online check for all possible cpus.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7746824a425d..ebc3311555b1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5096,10 +5096,8 @@ static int __build_all_zonelists(void *data)
 
 			build_zonelists(pgdat);
 		}
-	}
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
-	for_each_possible_cpu(cpu) {
 		/*
 		 * We now know the "local memory node" for each node--
 		 * i.e., the node of the first zone in the generic zonelist.
@@ -5108,10 +5106,10 @@ static int __build_all_zonelists(void *data)
 		 * secondary cpus' numa_mem as they come on-line.  During
 		 * node/memory hotplug, we'll fixup all on-line cpus.
 		 */
-		if (cpu_online(cpu))
+		for_each_online_cpu(cpu)
 			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
-	}
 #endif
+	}
 
 	return 0;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
