Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0C89B6B0169
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 16:38:45 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch] mm: thp: disable defrag for page faults per default
Date: Mon, 25 Jul 2011 22:38:41 +0200
Message-Id: <1311626321-14364-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

With defrag mode enabled per default, huge page allocations pass
__GFP_WAIT and may drop compaction into sync-mode where they wait for
pages under writeback.

I observe applications hang for several minutes(!) when they fault in
huge pages and compaction starts to wait on in-"flight" USB stick IO.

This patch disables defrag mode for page fault allocations unless the
VMA is madvised explicitely.  Khugepaged will continue to allocate
with __GFP_WAIT per default, but stalls are not a problem of
application responsiveness there.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/huge_memory.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 81532f2..8c8ff29 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -35,7 +35,7 @@ unsigned long transparent_hugepage_flags __read_mostly =
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE_MADVISE
 	(1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG)|
 #endif
-	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)|
+	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG);
 
 /* default scan 8*512 pte (or vmas) every 30 second */
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
