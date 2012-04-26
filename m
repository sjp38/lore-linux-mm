Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id C66CB6B004D
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 03:54:33 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id gg6so999112lbb.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 00:54:33 -0700 (PDT)
Subject: [PATCH 11/12] mm/vmscan: push lruvec pointer into
 should_continue_reclaim()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 26 Apr 2012 11:54:30 +0400
Message-ID: <20120426075430.18961.71526.stgit@zurg>
In-Reply-To: <20120426074632.18961.17803.stgit@zurg>
References: <20120426074632.18961.17803.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1724ec6..a9114739 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1750,14 +1750,13 @@ static bool in_reclaim_compaction(struct scan_control *sc)
  * calls try_to_compact_zone() that it will have enough free pages to succeed.
  * It will give up earlier than that if there is difficulty reclaiming pages.
  */
-static inline bool should_continue_reclaim(struct mem_cgroup_zone *mz,
+static inline bool should_continue_reclaim(struct lruvec *lruvec,
 					unsigned long nr_reclaimed,
 					unsigned long nr_scanned,
 					struct scan_control *sc)
 {
 	unsigned long pages_for_compaction;
 	unsigned long inactive_lru_pages;
-	struct lruvec *lruvec;
 
 	/* If not in reclaim/compaction mode, stop */
 	if (!in_reclaim_compaction(sc))
@@ -1790,7 +1789,6 @@ static inline bool should_continue_reclaim(struct mem_cgroup_zone *mz,
 	 * If we have not reclaimed enough pages for compaction and the
 	 * inactive lists are large enough, continue reclaiming
 	 */
-	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
 	pages_for_compaction = (2UL << sc->order);
 	inactive_lru_pages = get_lruvec_size(lruvec, LRU_INACTIVE_FILE);
 	if (nr_swap_pages > 0)
@@ -1801,7 +1799,7 @@ static inline bool should_continue_reclaim(struct mem_cgroup_zone *mz,
 		return true;
 
 	/* If compaction would go ahead or the allocation would succeed, stop */
-	switch (compaction_suitable(mz->zone, sc->order)) {
+	switch (compaction_suitable(lruvec_zone(lruvec), sc->order)) {
 	case COMPACT_PARTIAL:
 	case COMPACT_CONTINUE:
 		return false;
@@ -1868,7 +1866,7 @@ restart:
 				   sc, LRU_ACTIVE_ANON);
 
 	/* reclaim/compaction might need reclaim to continue */
-	if (should_continue_reclaim(mz, nr_reclaimed,
+	if (should_continue_reclaim(lruvec, nr_reclaimed,
 				    sc->nr_scanned - nr_scanned, sc))
 		goto restart;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
