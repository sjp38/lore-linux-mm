Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 74CD06B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 19:39:33 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x189so42930004pgb.11
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 16:39:33 -0700 (PDT)
Received: from mail-pg0-x236.google.com (mail-pg0-x236.google.com. [2607:f8b0:400e:c05::236])
        by mx.google.com with ESMTPS id s68si5995772pgc.592.2017.08.15.16.39.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 16:39:32 -0700 (PDT)
Received: by mail-pg0-x236.google.com with SMTP id u185so14729145pgb.1
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 16:39:31 -0700 (PDT)
Date: Tue, 15 Aug 2017 16:39:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/2] mm, compaction: kcompactd should not ignore pageblock
 skip
Message-ID: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Kcompactd is needlessly ignoring pageblock skip information.  It is doing
MIGRATE_SYNC_LIGHT compaction, which is no more powerful than
MIGRATE_SYNC compaction.

If compaction recently failed to isolate memory from a set of pageblocks,
there is nothing to indicate that kcompactd will be able to do so, or
that it is beneficial from attempting to isolate memory.

Use the pageblock skip hint to avoid rescanning pageblocks needlessly
until that information is reset.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1927,9 +1927,8 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		.total_free_scanned = 0,
 		.classzone_idx = pgdat->kcompactd_classzone_idx,
 		.mode = MIGRATE_SYNC_LIGHT,
-		.ignore_skip_hint = true,
+		.ignore_skip_hint = false,
 		.gfp_mask = GFP_KERNEL,
-
 	};
 	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
 							cc.classzone_idx);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
