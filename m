Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBAE86B0311
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 10:39:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k71so17046690wrc.15
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:33 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e19si1935697wra.251.2017.07.21.07.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 07:39:32 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id 65so7242919wmf.0
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:32 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 7/9] mm, page_alloc: remove stop_machine from build_all_zonelists
Date: Fri, 21 Jul 2017 16:39:13 +0200
Message-Id: <20170721143915.14161-8-mhocko@kernel.org>
In-Reply-To: <20170721143915.14161-1-mhocko@kernel.org>
References: <20170721143915.14161-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

build_all_zonelists has been (ab)using stop_machine to make sure that
zonelists do not change while somebody is looking at them. This is
is just a gross hack because a) it complicates the context from which
we can call build_all_zonelists (see 3f906ba23689 ("mm/memory-hotplug:
switch locking to a percpu rwsem")) and b) is is not really necessary
especially after "mm, page_alloc: simplify zonelist initialization"
and c) it doesn't really provide the protection it claims (see below).

Updates of the zonelists happen very seldom, basically only when a zone
becomes populated during memory online or when it loses all the memory
during offline. A racing iteration over zonelists could either miss a
zone or try to work on one zone twice. Both of these are something we
can live with occasionally because there will always be at least one
zone visible so we are not likely to fail allocation too easily for
example.

Please note that the original stop_machine approach doesn't really
provide a better exclusion because the iteration might be interrupted
half way (unless the whole iteration is preempt disabled which is not
the case in most cases) so the some zones could still be seen twice or a
zone missed.

I have run the pathological online/offline of the single memblock in the
movable zone while stressing the same small node with some memory pressure.
Node 1, zone      DMA
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 943, 943, 943)
Node 1, zone    DMA32
  pages free     227310
        min      8294
        low      10367
        high     12440
        spanned  262112
        present  262112
        managed  241436
        protection: (0, 0, 0, 0)
Node 1, zone   Normal
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 1024)
Node 1, zone  Movable
  pages free     32722
        min      85
        low      117
        high     149
        spanned  32768
        present  32768
        managed  32768
        protection: (0, 0, 0, 0)

root@test1:/sys/devices/system/node/node1# while true
do
	echo offline > memory34/state
	echo online_movable > memory34/state
done

root@test1:/mnt/data/test/linux-3.7-rc5# numactl --preferred=1 make -j4

and it survived without any unexpected behavior. While this is not
really a great testing coverage it should exercise the allocation path
quite a lot.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0d78dc5a708f..cf2eb3cf2cc5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5073,8 +5073,7 @@ static DEFINE_PER_CPU(struct per_cpu_nodestat, boot_nodestats);
  */
 DEFINE_MUTEX(zonelists_mutex);
 
-/* return values int ....just for stop_machine() */
-static int __build_all_zonelists(void *data)
+static void __build_all_zonelists(void *data)
 {
 	int nid;
 	int __maybe_unused cpu;
@@ -5110,8 +5109,6 @@ static int __build_all_zonelists(void *data)
 			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
 #endif
 	}
-
-	return 0;
 }
 
 static noinline void __init
@@ -5153,9 +5150,7 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
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
