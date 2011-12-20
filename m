Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id E757A6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 04:59:47 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 2/3] page_alloc: break early in check_for_regular_memory()
Date: Tue, 20 Dec 2011 18:02:39 +0800
Message-ID: <1324375359-31306-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, tj@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, Bob Liu <lliubbo@gmail.com>

If there is a zone below ZONE_NORMAL has present_pages, we can set
node state to N_NORMAL_MEMORY, no need to loop to end.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/page_alloc.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7f28eb8..8d64ba0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4671,8 +4671,10 @@ static void check_for_regular_memory(pg_data_t *pgdat)
 
 	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
 		struct zone *zone = &pgdat->node_zones[zone_type];
-		if (zone->present_pages)
+		if (zone->present_pages) {
 			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
+			break;
+		}
 	}
 #endif
 }
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
