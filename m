Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4266B025E
	for <linux-mm@kvack.org>; Thu, 12 May 2016 07:14:46 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ne4so10636708lbc.1
        for <linux-mm@kvack.org>; Thu, 12 May 2016 04:14:46 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id a9si15615466wjw.98.2016.05.12.04.14.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 04:14:43 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id e201so15359338wme.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 04:14:43 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm, oom: protect !costly allocations some more for !CONFIG_COMPACTION
Date: Thu, 12 May 2016 13:14:37 +0200
Message-Id: <1463051677-29418-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1463051677-29418-1-git-send-email-mhocko@kernel.org>
References: <1463051677-29418-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Joonsoo has reported that he is able to trigger OOM for !costly high
order requests (heavy fork() workload close the OOM) with the new
oom detection rework. This is because we rely only on should_reclaim_retry
when the compaction is disabled and it only checks watermarks for the
requested order and so we might trigger OOM when there is a lot of free
memory.

It is not very clear what are the usual workloads when the compaction
is disabled. Relying on high order allocations heavily without any
mechanism to create those orders except for unbound amount of reclaim is
certainly not a good idea.

To prevent from potential regressions let's help this configuration
some. We have to sacrifice the determinsm though because there simply is
none here possible. should_compact_retry implementation for
!CONFIG_COMPACTION, which was empty so far, will do watermark check
for order-0 on all eligible zones. This will cause retrying until either
the reclaim cannot make any further progress or all the zones are
depleted even for order-0 pages. This means that the number of retries
is basically unbounded for !costly orders but that was the case before
the rework as well so this shouldn't regress.

Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 620ec002aea2..7e2defbfe55b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3310,6 +3310,24 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
 		     enum migrate_mode *migrate_mode,
 		     int compaction_retries)
 {
+	struct zone *zone;
+	struct zoneref *z;
+
+	if (!order || order > PAGE_ALLOC_COSTLY_ORDER)
+		return false;
+
+	/*
+	 * There are setups with compaction disabled which would prefer to loop
+	 * inside the allocator rather than hit the oom killer prematurely. Let's
+	 * give them a good hope and keep retrying while the order-0 watermarks
+	 * are OK.
+	 */
+	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
+					ac->nodemask) {
+		if(zone_watermark_ok(zone, 0, min_wmark_pages(zone),
+					ac_classzone_idx(ac), alloc_flags))
+			return true;
+	}
 	return false;
 }
 #endif /* CONFIG_COMPACTION */
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
