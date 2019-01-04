Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 39E728E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:53:07 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so35319862eda.3
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:53:07 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id k7si7138254edx.327.2019.01.04.04.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:53:05 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 4A8B1988BA
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:53:05 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 16/25] mm, compaction: Check early for huge pages encountered by the migration scanner
Date: Fri,  4 Jan 2019 12:50:02 +0000
Message-Id: <20190104125011.16071-17-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

When scanning for sources or targets, PageCompound is checked for huge
pages as they can be skipped quickly but it happens relatively late after
a lot of setup and checking. This patch short-cuts the check to make it
earlier. It might still change when the lock is acquired but this has
less overhead overall. The free scanner advances but the migration scanner
does not. Typically the free scanner encounters more movable blocks that
change state over the lifetime of the system and also tends to scan more
aggressively as it's actively filling its portion of the physical address
space with data. This could change in the future but for the moment,
this worked better in practice and incurred fewer scan restarts.

The impact on latency and allocation success rates is marginal but the
free scan rates are reduced by 32% and system CPU usage is reduced by
2.6%. The 2-socket results are not materially different.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 608d274f9880..921720f7a416 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1071,6 +1071,9 @@ static bool suitable_migration_source(struct compact_control *cc,
 {
 	int block_mt;
 
+	if (pageblock_skip_persistent(page))
+		return false;
+
 	if ((cc->mode != MIGRATE_ASYNC) || !cc->direct_compaction)
 		return true;
 
@@ -1693,12 +1696,17 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 
 		/*
-		 * For async compaction, also only scan in MOVABLE blocks.
-		 * Async compaction is optimistic to see if the minimum amount
-		 * of work satisfies the allocation.
+		 * For async compaction, also only scan in MOVABLE blocks
+		 * without huge pages. Async compaction is optimistic to see
+		 * if the minimum amount of work satisfies the allocation.
+		 * The cached PFN is updated as it's possible that all
+		 * remaining blocks between source and target are suitable
+		 * and the compaction scanners fail to meet.
 		 */
-		if (!suitable_migration_source(cc, page))
+		if (!suitable_migration_source(cc, page)) {
+			update_cached_migrate(cc, block_end_pfn);
 			continue;
+		}
 
 		/* Perform the isolation */
 		low_pfn = isolate_migratepages_block(cc, low_pfn,
-- 
2.16.4
