Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB906B0036
	for <linux-mm@kvack.org>; Sun, 10 Aug 2014 13:48:31 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so9845431pad.13
        for <linux-mm@kvack.org>; Sun, 10 Aug 2014 10:48:31 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ms8si7718162pdb.218.2014.08.10.10.48.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Aug 2014 10:48:30 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] slab: fix cpuset check in fallback_alloc
Date: Sun, 10 Aug 2014 21:48:11 +0400
Message-ID: <1407692891-24312-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

fallback_alloc is called on kmalloc if the preferred node doesn't have
free or partial slabs and there's no pages on the node's free list
(GFP_THISNODE allocations fail). Before invoking the reclaimer it tries
to locate a free or partial slab on other allowed nodes' lists. While
iterating over the preferred node's zonelist it skips those zones which
cpuset_zone_allowed_hardwall returns false for. That means that for a
task bound to a specific node using cpusets fallback_alloc will always
ignore free slabs on other nodes and go directly to the reclaimer,
which, however, may allocate from other nodes if cpuset.mem_hardwall is
unset (default). As a result, we may get lists of free slabs grow
without bounds on other nodes, which is bad, because inactive slabs are
only evicted by cache_reap at a very slow rate and cannot be dropped
forcefully.

To reproduce the issue, run a process that will walk over a directory
tree with lots of files inside a cpuset bound to a node that constantly
experiences memory pressure. Look at num_slabs vs active_slabs growth as
reported by /proc/slabinfo.

We should use cpuset_zone_allowed_softwall in fallback_alloc. Since it
can sleep, we only call it on __GFP_WAIT allocations. For atomic
allocations we simply ignore cpusets, which is in agreement with the
cpuset documenation (see the comment to __cpuset_node_allowed_softwall).

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |   23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 2e60bf3dedbb..1d77a4df7ee1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3049,14 +3049,23 @@ retry:
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		nid = zone_to_nid(zone);
 
-		if (cpuset_zone_allowed_hardwall(zone, flags) &&
-			get_node(cache, nid) &&
-			get_node(cache, nid)->free_objects) {
-				obj = ____cache_alloc_node(cache,
-					flags | GFP_THISNODE, nid);
-				if (obj)
-					break;
+		if (!get_node(cache, nid) ||
+		    !get_node(cache, nid)->free_objects)
+			continue;
+
+		if (local_flags & __GFP_WAIT) {
+			bool allowed;
+
+			local_irq_enable();
+			allowed = cpuset_zone_allowed_softwall(zone, flags);
+			local_irq_disable();
+			if (!allowed)
+				continue;
 		}
+
+		obj = ____cache_alloc_node(cache, flags | GFP_THISNODE, nid);
+		if (obj)
+			break;
 	}
 
 	if (!obj) {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
