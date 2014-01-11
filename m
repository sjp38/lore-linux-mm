Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 48E8B6B0031
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 07:36:50 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id p9so2276662lbv.33
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 04:36:49 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id x7si5312155lag.96.2014.01.11.04.36.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 11 Jan 2014 04:36:48 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 3/5] mm: vmscan: respect NUMA policy mask when shrinking slab on direct reclaim
Date: Sat, 11 Jan 2014 16:36:33 +0400
Message-ID: <a39e4c57c5a8db4d6e5bb8cd070ac807c8c6fce8.1389443272.git.vdavydov@parallels.com>
In-Reply-To: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com>
References: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

When direct reclaim is executed by a process bound to a set of NUMA
nodes, we should scan only those nodes when possible, but currently we
will scan kmem from all online nodes even if the kmem shrinker is NUMA
aware. That said, binding a process to a particular NUMA node won't
prevent it from shrinking inode/dentry caches from other nodes, which is
not good. Fix this.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Glauber Costa <glommer@gmail.com>
---
 mm/vmscan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index adc3ecb..ae6518d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2425,8 +2425,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 			unsigned long lru_pages = 0;
 
 			nodes_clear(shrink->nodes_to_scan);
-			for_each_zone_zonelist(zone, z, zonelist,
-					gfp_zone(sc->gfp_mask)) {
+			for_each_zone_zonelist_nodemask(zone, z, zonelist,
+					gfp_zone(sc->gfp_mask), sc->nodemask) {
 				if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 					continue;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
