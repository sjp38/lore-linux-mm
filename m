Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 984568E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:54:21 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o21so5274782edq.4
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:54:21 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id b11si2182035edj.393.2019.01.18.09.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:54:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id A150C1C3579
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:54:19 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 15/22] mm, compaction: Keep cached migration PFNs synced for unusable pageblocks
Date: Fri, 18 Jan 2019 17:51:29 +0000
Message-Id: <20190118175136.31341-16-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Migrate has separate cached PFNs for ASYNC and SYNC* migration on the
basis that some migrations will fail in ASYNC mode. However, if the cached
PFNs match at the start of scanning and pageblocks are skipped due to
having no isolation candidates, then the sync state does not matter.
This patch keeps matching cached PFNs in sync until a pageblock with
isolation candidates is found.

The actual benefit is marginal given that the sync scanner following the
async scanner will often skip a number of pageblocks but it's useless
work. Any benefit depends heavily on whether the scanners restarted
recently.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 14bb66d48392..829540f6f3da 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1969,6 +1969,7 @@ static enum compact_result compact_zone(struct compact_control *cc)
 	unsigned long end_pfn = zone_end_pfn(cc->zone);
 	unsigned long last_migrated_pfn;
 	const bool sync = cc->mode != MIGRATE_ASYNC;
+	bool update_cached;
 
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
@@ -2016,6 +2017,17 @@ static enum compact_result compact_zone(struct compact_control *cc)
 
 	last_migrated_pfn = 0;
 
+	/*
+	 * Migrate has separate cached PFNs for ASYNC and SYNC* migration on
+	 * the basis that some migrations will fail in ASYNC mode. However,
+	 * if the cached PFNs match and pageblocks are skipped due to having
+	 * no isolation candidates, then the sync state does not matter.
+	 * Until a pageblock with isolation candidates is found, keep the
+	 * cached PFNs in sync to avoid revisiting the same blocks.
+	 */
+	update_cached = !sync &&
+		cc->zone->compact_cached_migrate_pfn[0] == cc->zone->compact_cached_migrate_pfn[1];
+
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync);
 
@@ -2047,6 +2059,11 @@ static enum compact_result compact_zone(struct compact_control *cc)
 			last_migrated_pfn = 0;
 			goto out;
 		case ISOLATE_NONE:
+			if (update_cached) {
+				cc->zone->compact_cached_migrate_pfn[1] =
+					cc->zone->compact_cached_migrate_pfn[0];
+			}
+
 			/*
 			 * We haven't isolated and migrated anything, but
 			 * there might still be unflushed migrations from
@@ -2054,6 +2071,7 @@ static enum compact_result compact_zone(struct compact_control *cc)
 			 */
 			goto check_drain;
 		case ISOLATE_SUCCESS:
+			update_cached = false;
 			last_migrated_pfn = start_pfn;
 			;
 		}
-- 
2.16.4
