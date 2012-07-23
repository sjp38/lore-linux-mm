Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 2CE416B009D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:39:08 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 30/34] mm: vmscan: Do not force kswapd to scan small targets
Date: Mon, 23 Jul 2012 14:38:43 +0100
Message-Id: <1343050727-3045-31-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit ad2b8e601099a23dffffb53f91c18d874fe98854 upstream - WARNING: this is a substitute patch.

Stable note: Not tracked in Bugzilla. This is a substitute for an
	upstream commit addressing a completely different issue that
	accidentally contained an important fix. The workload this patch
	helps was memcached when IO is started in the background. memcached
	should stay resident but without this patch it gets swapped more
	than it should. Sometimes this manifests as a drop in throughput
	but mostly it was observed through /proc/vmstat.

Commit [246e87a9: memcg: fix get_scan_count() for small targets] was
meant to fix a problem whereby small scan targets on memcg were ignored
causing priority to raise too sharply. It forced scanning to take place
if the target was small, memcg or kswapd.

>From the time it was introduced it cause excessive reclaim by kswapd
with workloads being pushed to swap that previously would have stayed
resident. This was accidentally fixed by commit [ad2b8e60: mm: memcg:
remove optimization of keeping the root_mem_cgroup LRU lists empty] but
that patchset is not suitable for backporting.

The original patch came with no information on what workloads it benefits
but the cost of it is obvious in that it forces scanning to take place
on lists that would otherwise have been ignored such as small anonymous
inactive lists. This patch partially reverts 246e87a9 so that small lists
are not force scanned which means that IO-intensive workloads with small
amounts of anonymous memory will not be swapped.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e5382ad..49d8547 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1849,9 +1849,6 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	bool force_scan = false;
 	unsigned long nr_force_scan[2];
 
-	/* kswapd does zone balancing and needs to scan this zone */
-	if (scanning_global_lru(sc) && current_is_kswapd())
-		force_scan = true;
 	/* memcg may have small limit and need to avoid priority drop */
 	if (!scanning_global_lru(sc))
 		force_scan = true;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
