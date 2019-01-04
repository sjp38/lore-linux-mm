Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A02A8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:53:17 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t7so34967632edr.21
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:53:17 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id h13si2217209edf.24.2019.01.04.04.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:53:15 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 8096A1C1788
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:53:15 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 17/25] mm, compaction: Keep cached migration PFNs synced for unusable pageblocks
Date: Fri,  4 Jan 2019 12:50:03 +0000
Message-Id: <20190104125011.16071-18-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Migrate has separate cached PFNs for ASYNC and SYNC* migration on the
basis that some migrations will fail in ASYNC mode. However, if the cached
PFNs match at the start of scanning and pageblocks are skipped due to
having no isolation candidates, then the sync state does not matter.
This patch keeps matching cached PFNs in sync until a pageblock with
isolation candidates is found.

The actual benefit is marginal given that the sync scanner following the
async scanner will often skip a number of pageblocks but it's useless
work. Any benefit depends heavily on whether the scanners restarted
recently so overall the reduction in scan rates is a mere 2.8% which
is borderline noise.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 921720f7a416..be27e4fa1b40 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1967,6 +1967,7 @@ static enum compact_result compact_zone(struct compact_control *cc)
 	unsigned long end_pfn = zone_end_pfn(cc->zone);
 	unsigned long last_migrated_pfn;
 	const bool sync = cc->mode != MIGRATE_ASYNC;
+	bool update_cached;
 	unsigned long a, b, c;
 
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
@@ -2019,6 +2020,17 @@ static enum compact_result compact_zone(struct compact_control *cc)
 
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
 
@@ -2050,6 +2062,11 @@ static enum compact_result compact_zone(struct compact_control *cc)
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
@@ -2057,6 +2074,7 @@ static enum compact_result compact_zone(struct compact_control *cc)
 			 */
 			goto check_drain;
 		case ISOLATE_SUCCESS:
+			update_cached = false;
 			last_migrated_pfn = start_pfn;
 			;
 		}
-- 
2.16.4
