Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 835165F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:20:08 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 07/25] Check in advance if the zonelist needs additional filtering
Date: Mon, 20 Apr 2009 23:19:53 +0100
Message-Id: <1240266011-11140-8-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Zonelist are filtered based on nodemasks for memory policies normally.
It can be additionally filters on cpusets if they exist as well as
noting when zones are full. These simple checks are expensive enough to
be noticed in profiles. This patch checks in advance if zonelist
filtering will ever be needed. If not, then the bulk of the checks are
skipped.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/cpuset.h |    2 ++
 mm/page_alloc.c        |   37 ++++++++++++++++++++++++++-----------
 2 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index a5740fc..978e2f1 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -97,6 +97,8 @@ static inline void set_mems_allowed(nodemask_t nodemask)
 
 #else /* !CONFIG_CPUSETS */
 
+#define number_of_cpusets (0)
+
 static inline int cpuset_init(void) { return 0; }
 static inline void cpuset_init_smp(void) {}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c8465d0..3613ba4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1137,7 +1137,11 @@ failed:
 #define ALLOC_WMARK_HIGH	0x08 /* use pages_high watermark */
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
+#ifdef CONFIG_CPUSETS
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
+#else
+#define ALLOC_CPUSET		0x00
+#endif /* CONFIG_CPUSETS */
 
 #ifdef CONFIG_FAIL_PAGE_ALLOC
 
@@ -1401,6 +1405,7 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
+	int zonelist_filter = 0;
 
 	(void)first_zones_zonelist(zonelist, high_zoneidx, nodemask,
 							&preferred_zone);
@@ -1411,6 +1416,10 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 
 	VM_BUG_ON(order >= MAX_ORDER);
 
+	/* Determine in advance if the zonelist needs filtering */
+	if ((alloc_flags & ALLOC_CPUSET) && unlikely(number_of_cpusets > 1))
+		zonelist_filter = 1;
+
 zonelist_scan:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
@@ -1418,12 +1427,16 @@ zonelist_scan:
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						high_zoneidx, nodemask) {
-		if (NUMA_BUILD && zlc_active &&
-			!zlc_zone_worth_trying(zonelist, z, allowednodes))
-				continue;
-		if ((alloc_flags & ALLOC_CPUSET) &&
-			!cpuset_zone_allowed_softwall(zone, gfp_mask))
-				goto try_next_zone;
+
+		/* Ignore the additional zonelist filter checks if possible */
+		if (zonelist_filter) {
+			if (NUMA_BUILD && zlc_active &&
+				!zlc_zone_worth_trying(zonelist, z, allowednodes))
+					continue;
+			if ((alloc_flags & ALLOC_CPUSET) &&
+				!cpuset_zone_allowed_softwall(zone, gfp_mask))
+					goto try_next_zone;
+		}
 
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;
@@ -1445,13 +1458,15 @@ zonelist_scan:
 		if (page)
 			break;
 this_zone_full:
-		if (NUMA_BUILD)
+		if (NUMA_BUILD && zonelist_filter)
 			zlc_mark_zone_full(zonelist, z);
 try_next_zone:
-		if (NUMA_BUILD && !did_zlc_setup) {
-			/* we do zlc_setup after the first zone is tried */
-			allowednodes = zlc_setup(zonelist, alloc_flags);
-			zlc_active = 1;
+		if (NUMA_BUILD && zonelist_filter) {
+			if (!did_zlc_setup) {
+				/* do zlc_setup after the first zone is tried */
+				allowednodes = zlc_setup(zonelist, alloc_flags);
+				zlc_active = 1;
+			}
 			did_zlc_setup = 1;
 		}
 	}
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
