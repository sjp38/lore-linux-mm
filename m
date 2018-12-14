Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4425A8E021B
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 18:03:14 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id l45so3463112edb.1
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:03:14 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id e18si316800eds.58.2018.12.14.15.03.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 15:03:12 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 82EC91C208A
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 23:03:12 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 07/14] mm, compaction: Always finish scanning of a full pageblock
Date: Fri, 14 Dec 2018 23:03:03 +0000
Message-Id: <20181214230310.572-8-mgorman@techsingularity.net>
In-Reply-To: <20181214230310.572-1-mgorman@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

When compaction is finishing, it uses a flag to ensure the pageblock is
complete.  However, in general it makes sense to always complete migration
of a pageblock. Minimally, skip information is based on a pageblock and
partially scanned pageblocks may incur more scanning in the future. The
pageblock skip handling also becomes more strict later in the series and
the hint is more useful if a complete pageblock was always scanned.

The impact here is potentially on latencies as more scanning is done
but it's not a consistent win or loss as the scanning is not always a
high percentage of the pageblock and sometimes it is offset by future
reductions in scanning. Hence, the results are not presented this time as
it's a mix of gains/losses without any clear pattern. However, completing
scanning of the pageblock is important for later patches.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 19 ++++++++-----------
 mm/internal.h   |  1 -
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 8134dba47584..4f51435c645a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1338,16 +1338,14 @@ static enum compact_result __compact_finished(struct compact_control *cc)
 	if (is_via_compact_memory(cc->order))
 		return COMPACT_CONTINUE;
 
-	if (cc->finishing_block) {
-		/*
-		 * We have finished the pageblock, but better check again that
-		 * we really succeeded.
-		 */
-		if (IS_ALIGNED(cc->migrate_pfn, pageblock_nr_pages))
-			cc->finishing_block = false;
-		else
-			return COMPACT_CONTINUE;
-	}
+	/*
+	 * Always finish scanning a pageblock to reduce the possibility of
+	 * fallbacks in the future. This is particularly important when
+	 * migration source is unmovable/reclaimable but it's not worth
+	 * special casing.
+	 */
+	if (!IS_ALIGNED(cc->migrate_pfn, pageblock_nr_pages))
+		return COMPACT_CONTINUE;
 
 	/* Direct compactor: Is a suitable page free? */
 	for (order = cc->order; order < MAX_ORDER; order++) {
@@ -1389,7 +1387,6 @@ static enum compact_result __compact_finished(struct compact_control *cc)
 				return COMPACT_SUCCESS;
 			}
 
-			cc->finishing_block = true;
 			return COMPACT_CONTINUE;
 		}
 	}
diff --git a/mm/internal.h b/mm/internal.h
index f40d06d70683..9b32f4cab0ae 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -203,7 +203,6 @@ struct compact_control {
 	bool direct_compaction;		/* False from kcompactd or /proc/... */
 	bool whole_zone;		/* Whole zone should/has been scanned */
 	bool contended;			/* Signal lock or sched contention */
-	bool finishing_block;		/* Finishing current pageblock */
 };
 
 unsigned long
-- 
2.16.4
