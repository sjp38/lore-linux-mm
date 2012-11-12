Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 9C0126B006E
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 14:35:46 -0500 (EST)
Received: by mail-la0-f73.google.com with SMTP id d3so112502lah.2
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 11:35:44 -0800 (PST)
From: Sonny Rao <sonnyrao@chromium.org>
Subject: [PATCH] mm: Fix calculation of dirtyable memory
Date: Mon, 12 Nov 2012 11:35:28 -0800
Message-Id: <1352748928-738-1-git-send-email-sonnyrao@chromium.org>
In-Reply-To: <20121109023638.GA11105@localhost>
References: <20121109023638.GA11105@localhost>
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
 v2: added apkm's suggestion to make the highmem calculation better
 v3: added Fengguang Wu's suggestions fix zone_dirtyable_memory() and
     (offlist mail) to use max() in global_dirtyable_memory()
 mm/page-writeback.c |   25 ++++++++++++++++++++-----
 1 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 830893b..f9efbe8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -201,6 +201,18 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 		     zone_reclaimable_pages(z) - z->dirty_balance_reserve;
 	}
 	/*
+	 * Unreclaimable memory (kernel memory or anonymous memory
+	 * without swap) can bring down the dirtyable pages below
+	 * the zone's dirty balance reserve and the above calculation
+	 * will underflow.  However we still want to add in nodes
+	 * which are below threshold (negative values) to get a more
+	 * accurate calculation but make sure that the total never
+	 * underflows.
+	 */
+	if ((long)x < 0)
+		x = 0;
+
+	/*
 	 * Make sure that the number of highmem pages is never larger
 	 * than the number of the total dirtyable memory. This can only
 	 * occur in very strange VM situations but we want to make sure
@@ -222,8 +234,8 @@ static unsigned long global_dirtyable_memory(void)
 {
 	unsigned long x;
 
-	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages() -
-	    dirty_balance_reserve;
+	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
+	x -= max(x, dirty_balance_reserve);
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
@@ -290,9 +302,12 @@ static unsigned long zone_dirtyable_memory(struct zone *zone)
 	 * highmem zone can hold its share of dirty pages, so we don't
 	 * care about vm_highmem_is_dirtyable here.
 	 */
-	return zone_page_state(zone, NR_FREE_PAGES) +
-	       zone_reclaimable_pages(zone) -
-	       zone->dirty_balance_reserve;
+	unsigned long nr_pages = zone_page_state(zone, NR_FREE_PAGES) +
+		zone_reclaimable_pages(zone);
+
+	/* don't allow this to underflow */
+	nr_pages -= max(nr_pages, zone->dirty_balance_reserve);
+	return nr_pages;
 }
 
 /**
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
