Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id E264A6B006E
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 11:34:00 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id l18so9572587wgh.17
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 08:34:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf8si298547wib.72.2014.10.07.08.34.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 08:34:00 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/5] mm, compaction: defer only on COMPACT_COMPLETE
Date: Tue,  7 Oct 2014 17:33:37 +0200
Message-Id: <1412696019-21761-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

Deferred compaction is employed to avoid compacting zone where sync direct
compaction has recently failed. As such, it makes sense to only defer when
a full zone was scanned, which is when compact_zone returns with
COMPACT_COMPLETE. It's less useful to defer when compact_zone returns with
apparent success (COMPACT_PARTIAL), followed by a watermark check failure,
which can happen due to parallel allocation activity. It also does not make
much sense to defer compaction which was completely skipped (COMPACT_SKIP) for
being unsuitable in the first place.

This patch therefore makes deferred compaction trigger only when
COMPACT_COMPLETE is returned from compact_zone(). Results of stress-highalloc
becnmark show the difference is within measurement error, so the issue is
rather cosmetic.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 4b3e0bd..9107588 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1340,7 +1340,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			goto break_loop;
 		}
 
-		if (mode != MIGRATE_ASYNC) {
+		if (mode != MIGRATE_ASYNC && status == COMPACT_COMPLETE) {
 			/*
 			 * We think that allocation won't succeed in this zone
 			 * so we defer compaction there. If it ends up
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
