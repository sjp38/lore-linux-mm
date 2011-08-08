Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E0DAD6B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 07:07:05 -0400 (EDT)
Subject: [PATCH 1/2] vmscan: promote shared file mapped pages
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 8 Aug 2011 15:06:58 +0400
Message-ID: <20110808110658.31053.55013.stgit@localhost6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

Commit v2.6.33-5448-g6457474 (vmscan: detect mapped file pages used only once)
greatly decreases lifetime of single-used mapped file pages.
Unfortunately it also decreases life time of all shared mapped file pages.
Because after commit v2.6.28-6130-gbf3f3bc (mm: don't mark_page_accessed in fault path)
page-fault handler does not mark page active or even referenced.

Thus page_check_references() activates file page only if it was used twice while
it stays in inactive list, meanwhile it activates anon pages after first access.
Inactive list can be small enough, this way reclaimer can accidentally
throw away any widely used page if it wasn't used twice in short period.

After this patch page_check_references() also activate file mapped page at first
inactive list scan if this page is already used multiple times via several ptes.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 47403c9..3cd766d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -724,7 +724,7 @@ static enum page_references page_check_references(struct page *page,
 		 */
 		SetPageReferenced(page);
 
-		if (referenced_page)
+		if (referenced_page || referenced_ptes > 1)
 			return PAGEREF_ACTIVATE;
 
 		return PAGEREF_KEEP;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
