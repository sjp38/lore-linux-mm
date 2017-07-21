Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E06456B02F3
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 10:39:27 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u89so17066204wrc.1
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:27 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id y202si1102613wmd.234.2017.07.21.07.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 07:39:26 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id p204so7229193wmg.1
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:26 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/9] mm, page_alloc: remove boot pageset initialization from memory hotplug
Date: Fri, 21 Jul 2017 16:39:08 +0200
Message-Id: <20170721143915.14161-3-mhocko@kernel.org>
In-Reply-To: <20170721143915.14161-1-mhocko@kernel.org>
References: <20170721143915.14161-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

boot_pageset is a boot time hack which gets superseded by normal
pagesets later in the boot process. It makes zero sense to reinitialize
it again and again during memory hotplug.

Changes since v1
- use __maybe_unused for cpu to silence annoying warning for
  CONFIG_HAVE_MEMORYLESS_NODES=y

Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 40 ++++++++++++++++++++++------------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b839a90e24c8..ff53f709c44c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5077,7 +5077,7 @@ DEFINE_MUTEX(zonelists_mutex);
 static int __build_all_zonelists(void *data)
 {
 	int nid;
-	int cpu;
+	int __maybe_unused cpu;
 	pg_data_t *self = data;
 
 #ifdef CONFIG_NUMA
@@ -5098,23 +5098,8 @@ static int __build_all_zonelists(void *data)
 		}
 	}
 
-	/*
-	 * Initialize the boot_pagesets that are going to be used
-	 * for bootstrapping processors. The real pagesets for
-	 * each zone will be allocated later when the per cpu
-	 * allocator is available.
-	 *
-	 * boot_pagesets are used also for bootstrapping offline
-	 * cpus if the system is already booted because the pagesets
-	 * are needed to initialize allocators on a specific cpu too.
-	 * F.e. the percpu allocator needs the page allocator which
-	 * needs the percpu allocator in order to allocate its pagesets
-	 * (a chicken-egg dilemma).
-	 */
-	for_each_possible_cpu(cpu) {
-		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
-
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
+	for_each_possible_cpu(cpu) {
 		/*
 		 * We now know the "local memory node" for each node--
 		 * i.e., the node of the first zone in the generic zonelist.
@@ -5125,8 +5110,8 @@ static int __build_all_zonelists(void *data)
 		 */
 		if (cpu_online(cpu))
 			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
-#endif
 	}
+#endif
 
 	return 0;
 }
@@ -5134,7 +5119,26 @@ static int __build_all_zonelists(void *data)
 static noinline void __init
 build_all_zonelists_init(void)
 {
+	int cpu;
+
 	__build_all_zonelists(NULL);
+
+	/*
+	 * Initialize the boot_pagesets that are going to be used
+	 * for bootstrapping processors. The real pagesets for
+	 * each zone will be allocated later when the per cpu
+	 * allocator is available.
+	 *
+	 * boot_pagesets are used also for bootstrapping offline
+	 * cpus if the system is already booted because the pagesets
+	 * are needed to initialize allocators on a specific cpu too.
+	 * F.e. the percpu allocator needs the page allocator which
+	 * needs the percpu allocator in order to allocate its pagesets
+	 * (a chicken-egg dilemma).
+	 */
+	for_each_possible_cpu(cpu)
+		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
+
 	mminit_verify_zonelist();
 	cpuset_init_current_mems_allowed();
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
