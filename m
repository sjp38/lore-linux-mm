Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3665D6B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 18:52:19 -0400 (EDT)
From: Mandeep Singh Baines <msb@chromium.org>
Subject: [PATCH] vmscan: move referenced VM_EXEC pages to active list
Date: Fri, 22 Oct 2010 15:51:51 -0700
Message-Id: <1287787911-4257-1-git-send-email-msb@chromium.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, Mandeep Singh Baines <msb@chromium.org>
List-ID: <linux-mm.kvack.org>

In commit 64574746, "vmscan: detect mapped file pages used only once",
Johannes Weiner, added logic to page_check_reference to cycle again
used once pages.

In commit 8cab4754, "vmscan: make mapped executable pages the first
class citizen", Wu Fengguang, added logic to shrink_active_list which
protects file-backed VM_EXEC pages by keeping them in the active_list if
they are referenced.

This patch adds logic to move such pages from the inactive list to the
active list immediately if they have been referenced. If a VM_EXEC page
is seen as referenced during an inactive list scan, that reference must
have occurred after the page was put on the inactive list. There is no
need to wait for the page to be referenced again.

Change-Id: I17c312e916377e93e5a92c52518b6c829f9ab30b
Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
---
 mm/vmscan.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c5dfabf..0984dee 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -593,6 +593,17 @@ static enum page_references page_check_references(struct page *page,
 	if (referenced_ptes) {
 		if (PageAnon(page))
 			return PAGEREF_ACTIVATE;
+
+		/*
+		 * Identify referenced, file-backed active pages and move them
+		 * to the active list. We know that this page has been
+		 * referenced since being put on the inactive list. VM_EXEC
+		 * pages are only moved to the inactive list when they have not
+		 * been referenced between scans (see shrink_active_list).
+		 */
+		if ((vm_flags & VM_EXEC) && page_is_file_cache(page))
+			return PAGEREF_ACTIVATE;
+
 		/*
 		 * All mapped pages start out with page table
 		 * references from the instantiating fault, so we need
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
