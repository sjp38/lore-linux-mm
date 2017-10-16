Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 987606B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 18:03:40 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j140so89684itj.10
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 15:03:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d16sor4749800itj.44.2017.10.16.15.03.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 15:03:39 -0700 (PDT)
Date: Mon, 16 Oct 2017 15:03:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, compaction: properly initialize alloc_flags in
 compact_control
Message-ID: <alpine.DEB.2.10.1710161503020.102726@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


compaction_suitable() requires a useful cc->alloc_flags, otherwise the
results of compact_zone() can be indeterminate.  Kcompactd currently
checks compaction_suitable() itself with alloc_flags == 0, but passes an
uninitialized value from the stack to compact_zone(), which does its own
check.

The same is true for compact_node() when explicitly triggering full node
compaction.

Properly initialize cc.alloc_flags on the stack.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1792,9 +1792,9 @@ static void compact_node(int nid)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 	int zoneid;
-	struct zone *zone;
 	struct compact_control cc = {
 		.order = -1,
+		.alloc_flags = 0,
 		.total_migrate_scanned = 0,
 		.total_free_scanned = 0,
 		.mode = MIGRATE_SYNC,
@@ -1805,6 +1805,7 @@ static void compact_node(int nid)
 
 
 	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+		struct zone *zone;
 
 		zone = &pgdat->node_zones[zoneid];
 		if (!populated_zone(zone))
@@ -1923,6 +1924,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	struct zone *zone;
 	struct compact_control cc = {
 		.order = pgdat->kcompactd_max_order,
+		.alloc_flags = 0,
 		.total_migrate_scanned = 0,
 		.total_free_scanned = 0,
 		.classzone_idx = pgdat->kcompactd_classzone_idx,
@@ -1945,8 +1947,8 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		if (compaction_deferred(zone, cc.order))
 			continue;
 
-		if (compaction_suitable(zone, cc.order, 0, zoneid) !=
-							COMPACT_CONTINUE)
+		if (compaction_suitable(zone, cc.order, cc.alloc_flags,
+					zoneid) != COMPACT_CONTINUE)
 			continue;
 
 		cc.nr_freepages = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
