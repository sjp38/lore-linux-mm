Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 6D4BF6B0081
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:39:06 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 27/34] vmscan: activate executable pages after first usage
Date: Mon, 23 Jul 2012 14:38:40 +0100
Message-Id: <1343050727-3045-28-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Konstantin Khlebnikov <khlebnikov@openvz.org>

commit c909e99364c8b6ca07864d752950b6b4ecf6bef4 upstream.

Stable note: Not tracked in Bugzilla. There were reports of shared
	mapped pages being unfairly reclaimed in comparison to older kernels.
	This is being addressed over time.

Logic added in commit 8cab4754d24a0 ("vmscan: make mapped executable pages
the first class citizen") was noticeably weakened in commit
645747462435d84 ("vmscan: detect mapped file pages used only once").

Currently these pages can become "first class citizens" only after second
usage.  After this patch page_check_references() will activate they after
first usage, and executable code gets yet better chance to stay in memory.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Shaohua Li <shaohua.li@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7edaaac..8b98a75 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -726,6 +726,12 @@ static enum page_references page_check_references(struct page *page,
 		if (referenced_page || referenced_ptes > 1)
 			return PAGEREF_ACTIVATE;
 
+		/*
+		 * Activate file-backed executable pages after first usage.
+		 */
+		if (vm_flags & VM_EXEC)
+			return PAGEREF_ACTIVATE;
+
 		return PAGEREF_KEEP;
 	}
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
