Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 6F4646B0038
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 12:06:45 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 7/9] mm: zone_reclaim: compaction: export compact_zone_order()
Date: Fri,  2 Aug 2013 18:06:34 +0200
Message-Id: <1375459596-30061-8-git-send-email-aarcange@redhat.com>
In-Reply-To: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

Needed by zone_reclaim_mode compaction-awareness.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/compaction.h | 10 ++++++++++
 mm/compaction.c            |  2 +-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index fc3f266..e953acb 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -23,6 +23,9 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
 			bool sync, bool *contended);
+extern unsigned long compact_zone_order(struct zone *zone,
+					int order, gfp_t gfp_mask,
+					bool sync, bool *contended);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 
@@ -79,6 +82,13 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	return COMPACT_CONTINUE;
 }
 
+static inline unsigned long compact_zone_order(struct zone *zone,
+					       int order, gfp_t gfp_mask,
+					       bool sync, bool *contended)
+{
+	return COMPACT_CONTINUE;
+}
+
 static inline void compact_pgdat(pg_data_t *pgdat, int order)
 {
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index afaf692..a1154c8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1008,7 +1008,7 @@ out:
 	return ret;
 }
 
-static unsigned long compact_zone_order(struct zone *zone,
+unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
 				 bool sync, bool *contended)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
