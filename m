Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84850440901
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:00:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 79so8054929wmg.4
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:34 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id p68si5849731wrc.206.2017.07.14.01.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 01:00:33 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id y5so9361993wmh.3
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:33 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 7/9] mm, page_alloc: remove stop_machine from build_all_zonelists
Date: Fri, 14 Jul 2017 10:00:04 +0200
Message-Id: <20170714080006.7250-8-mhocko@kernel.org>
In-Reply-To: <20170714080006.7250-1-mhocko@kernel.org>
References: <20170714080006.7250-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

build_all_zonelists has been (ab)using stop_machine to make sure that
zonelists do not change while somebody is looking at them. This is
is just a gross hack because a) it complicates the context from which
we can call build_all_zonelists (see 3f906ba23689 ("mm/memory-hotplug:
switch locking to a percpu rwsem")) and b) is is not really necessary
especially after "mm, page_alloc: simplify zonelist initialization".

Updates of the zonelists happen very seldom, basically only when a zone
becomes populated during memory online or when it loses all the memory
during offline. A racing iteration over zonelists could either miss a
zone or try to work on one zone twice. Both of these are something we
can live with occasionally because there will always be at least one
zone visible so we are not likely to fail allocation too easily for
example.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 78bd62418380..217889ecd13f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5066,8 +5066,7 @@ static DEFINE_PER_CPU(struct per_cpu_nodestat, boot_nodestats);
  */
 DEFINE_MUTEX(zonelists_mutex);
 
-/* return values int ....just for stop_machine() */
-static int __build_all_zonelists(void *data)
+static void __build_all_zonelists(void *data)
 {
 	int nid;
 	int cpu;
@@ -5103,8 +5102,6 @@ static int __build_all_zonelists(void *data)
 			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
 #endif
 	}
-
-	return 0;
 }
 
 static noinline void __init
@@ -5147,9 +5144,7 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
 	if (system_state == SYSTEM_BOOTING) {
 		build_all_zonelists_init();
 	} else {
-		/* we have to stop all cpus to guarantee there is no user
-		   of zonelist */
-		stop_machine_cpuslocked(__build_all_zonelists, pgdat, NULL);
+		__build_all_zonelists(pgdat);
 		/* cpuset refresh routine should be here */
 	}
 	vm_total_pages = nr_free_pagecache_pages();
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
