Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA44E4408FE
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:00:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u89so1802788wrc.1
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:29 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id a13si1599082wma.62.2017.07.14.01.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 01:00:28 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id g46so760269wrd.0
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:28 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/9] mm, page_alloc: remove boot pageset initialization from memory hotplug
Date: Fri, 14 Jul 2017 09:59:59 +0200
Message-Id: <20170714080006.7250-3-mhocko@kernel.org>
In-Reply-To: <20170714080006.7250-1-mhocko@kernel.org>
References: <20170714080006.7250-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

boot_pageset is a boot time hack which gets superseded by normal
pagesets later in the boot process. It makes zero sense to reinitialize
it again and again during memory hotplug.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 38 +++++++++++++++++++++-----------------
 1 file changed, 21 insertions(+), 17 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d9f4ea057e74..7746824a425d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
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
