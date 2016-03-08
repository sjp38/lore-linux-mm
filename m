Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 263EF6B0255
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 08:42:54 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id n186so132167477wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:42:54 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id x64si4545661wmx.5.2016.03.08.05.42.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 05:42:51 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id n186so4162590wmn.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:42:51 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm, compaction: cover all compaction mode in compact_zone
Date: Tue,  8 Mar 2016 14:42:44 +0100
Message-Id: <1457444565-10524-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1457444565-10524-1-git-send-email-mhocko@kernel.org>
References: <20160307160838.GB5028@dhcp22.suse.cz>
 <1457444565-10524-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

the compiler is complaining after "mm, compaction: change COMPACT_
constants into enum"

mm/compaction.c: In function a??compact_zonea??:
mm/compaction.c:1350:2: warning: enumeration value a??COMPACT_DEFERREDa?? not handled in switch [-Wswitch]
  switch (ret) {
  ^
mm/compaction.c:1350:2: warning: enumeration value a??COMPACT_COMPLETEa?? not handled in switch [-Wswitch]
mm/compaction.c:1350:2: warning: enumeration value a??COMPACT_NO_SUITABLE_PAGEa?? not handled in switch [-Wswitch]
mm/compaction.c:1350:2: warning: enumeration value a??COMPACT_NOT_SUITABLE_ZONEa?? not handled in switch [-Wswitch]
mm/compaction.c:1350:2: warning: enumeration value a??COMPACT_CONTENDEDa?? not handled in switch [-Wswitch]

compaction_suitable is allowed to return only COMPACT_PARTIAL,
COMPACT_SKIPPED and COMPACT_CONTINUE so other cases are simply
impossible. Put a VM_BUG_ON to catch an impossible return value.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/compaction.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 0f61f12d82b6..86968d3a04e6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1347,15 +1347,12 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 
 	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
-	switch (ret) {
-	case COMPACT_PARTIAL:
-	case COMPACT_SKIPPED:
-		/* Compaction is likely to fail */
+	/* Compaction is likely to fail */
+	if (ret == COMPACT_PARTIAL || ret == COMPACT_SKIPPED)
 		return ret;
-	case COMPACT_CONTINUE:
-		/* Fall through to compaction */
-		;
-	}
+
+	/* huh, compaction_suitable is returning something unexpected */
+	VM_BUG_ON(ret != COMPACT_CONTINUE);
 
 	/*
 	 * Clear pageblock skip if there were failures recently and compaction
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
