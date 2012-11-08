Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id A21CA6B002B
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 18:25:55 -0500 (EST)
Received: by mail-lb0-f201.google.com with SMTP id n8so212472lbj.2
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 15:25:53 -0800 (PST)
From: Sonny Rao <sonnyrao@chromium.org>
Subject: [PATCH] mm: Fix calculation of dirtyable memory
Date: Thu,  8 Nov 2012 15:25:35 -0800
Message-Id: <1352417135-25122-1-git-send-email-sonnyrao@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mandeep Singh Baines <msb@chromium.org>, Johannes Weiner <jweiner@redhat.com>, Olof Johansson <olofj@chromium.org>, Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>, Aaron Durbin <adurbin@chromium.org>, Sonny Rao <sonnyrao@chromium.org>, Puneet Kumar <puneetster@chromium.org>

The system uses global_dirtyable_memory() to calculate
number of dirtyable pages/pages that can be allocated
to the page cache.  A bug causes an underflow thus making
the page count look like a big unsigned number.  This in turn
confuses the dirty writeback throttling to aggressively write
back pages as they become dirty (usually 1 page at a time).

Fix is to ensure there is no underflow while doing the math.

Signed-off-by: Sonny Rao <sonnyrao@chromium.org>
Signed-off-by: Puneet Kumar <puneetster@chromium.org>
---
 mm/page-writeback.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 830893b..2a6356c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -194,11 +194,19 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 	unsigned long x = 0;
 
 	for_each_node_state(node, N_HIGH_MEMORY) {
+		unsigned long nr_pages;
 		struct zone *z =
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
-		x += zone_page_state(z, NR_FREE_PAGES) +
-		     zone_reclaimable_pages(z) - z->dirty_balance_reserve;
+		nr_pages = zone_page_state(z, NR_FREE_PAGES) +
+			zone_reclaimable_pages(z);
+		/*
+		 * Unreclaimable memory (kernel memory or anonymous memory
+		 * without swap) can bring down the dirtyable pages below
+		 * the zone's dirty balance reserve.
+		 */
+		if (nr_pages >= z->dirty_balance_reserve)
+			x += nr_pages - z->dirty_balance_reserve;
 	}
 	/*
 	 * Make sure that the number of highmem pages is never larger
@@ -222,8 +230,9 @@ static unsigned long global_dirtyable_memory(void)
 {
 	unsigned long x;
 
-	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages() -
-	    dirty_balance_reserve;
+	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
+	if (x >= dirty_balance_reserve)
+		x -= dirty_balance_reserve;
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
