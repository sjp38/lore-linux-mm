Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 75BFF6B0036
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 18:34:33 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id w62so107820wes.0
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 15:34:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x47si123914eel.253.2014.04.07.15.34.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 15:34:31 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] mm: Disable zone_reclaim_mode by default
Date: Mon,  7 Apr 2014 23:34:27 +0100
Message-Id: <1396910068-11637-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1396910068-11637-1-git-send-email-mgorman@suse.de>
References: <1396910068-11637-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

zone_reclaim_mode causes processes to prefer reclaiming memory from local
node instead of spilling over to other nodes. This made sense initially when
NUMA machines were almost exclusively HPC and the workload was partitioned
into nodes. The NUMA penalties were sufficiently high to justify reclaiming
the memory. On current machines and workloads it is often the case that
zone_reclaim_mode destroys performance but not all users know how to detect
this. Favour the common case and disable it by default. Users that are
sophisticated enough to know they need zone_reclaim_mode will detect it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/sysctl/vm.txt | 17 +++++++++--------
 mm/page_alloc.c             |  2 --
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index d614a9b..ff5da70 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -751,16 +751,17 @@ This is value ORed together of
 2	= Zone reclaim writes dirty pages out
 4	= Zone reclaim swaps pages
 
-zone_reclaim_mode is set during bootup to 1 if it is determined that pages
-from remote zones will cause a measurable performance reduction. The
-page allocator will then reclaim easily reusable pages (those page
-cache pages that are currently not used) before allocating off node pages.
-
-It may be beneficial to switch off zone reclaim if the system is
-used for a file server and all of memory should be used for caching files
-from disk. In that case the caching effect is more important than
+zone_reclaim_mode is disabled by default.  For file servers or workloads
+that benefit from having their data cached, zone_reclaim_mode should be
+left disabled as the caching effect is likely to be more important than
 data locality.
 
+zone_reclaim may be enabled if it's known that the workload is partitioned
+such that each partition fits within a NUMA node and that accessing remote
+memory would cause a measurable performance reduction.  The page allocator
+will then reclaim easily reusable pages (those page cache pages that are
+currently not used) before allocating off node pages.
+
 Allowing zone reclaim to write out pages stops processes that are
 writing large amounts of data from dirtying pages on other nodes. Zone
 reclaim will write out dirty pages if a zone fills up and so effectively
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3bac76a..a256f85 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1873,8 +1873,6 @@ static void __paginginit init_zone_allows_reclaim(int nid)
 	for_each_online_node(i)
 		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
 			node_set(i, NODE_DATA(nid)->reclaim_nodes);
-		else
-			zone_reclaim_mode = 1;
 }
 
 #else	/* CONFIG_NUMA */
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
