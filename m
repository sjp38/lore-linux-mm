Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A87BE6B003B
	for <linux-mm@kvack.org>; Tue,  6 May 2014 22:22:54 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so394475pab.1
        for <linux-mm@kvack.org>; Tue, 06 May 2014 19:22:54 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id bc5si1020406pbb.332.2014.05.06.19.22.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 19:22:53 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id fa1so382809pad.20
        for <linux-mm@kvack.org>; Tue, 06 May 2014 19:22:53 -0700 (PDT)
Date: Tue, 6 May 2014 19:22:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v3 6/6] mm, compaction: terminate async compaction when
 rescheduling
In-Reply-To: <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Async compaction terminates prematurely when need_resched(), see
compact_checklock_irqsave().  This can never trigger, however, if the 
cond_resched() in isolate_migratepages_range() always takes care of the 
scheduling.

If the cond_resched() actually triggers, then terminate this pageblock scan for 
async compaction as well.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -500,8 +500,13 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			return 0;
 	}
 
+	if (cond_resched()) {
+		/* Async terminates prematurely on need_resched() */
+		if (cc->mode == MIGRATE_ASYNC)
+			return 0;
+	}
+
 	/* Time to isolate some pages for migration */
-	cond_resched();
 	for (; low_pfn < end_pfn; low_pfn++) {
 		/* give a chance to irqs before checking need_resched() */
 		if (locked && !(low_pfn % SWAP_CLUSTER_MAX)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
