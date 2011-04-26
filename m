Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 545649000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:26:04 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 8so955640iwg.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:26:03 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 5/8] compaction: remove active list counting
Date: Wed, 27 Apr 2011 01:25:22 +0900
Message-Id: <2b79bbf9ddceb73624f49bbe9477126147d875fd.1303833417.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

acct_isolated of compaction uses page_lru_base_type which returns only
base type of LRU list so it never returns LRU_ACTIVE_ANON or LRU_ACTIVE_FILE.
So it's pointless to add lru[LRU_ACTIVE_[ANON|FILE]] to get sum.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9f80b5a..653b02b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -219,8 +219,8 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 		count[lru]++;
 	}
 
-	cc->nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
-	cc->nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
+	cc->nr_anon = count[LRU_INACTIVE_ANON];
+	cc->nr_file = count[LRU_INACTIVE_FILE];
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, cc->nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, cc->nr_file);
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
