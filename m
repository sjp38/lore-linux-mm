Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 6E7B96B0078
	for <linux-mm@kvack.org>; Thu,  9 May 2013 03:21:34 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v5 1/7] mm: prevent to write out dirty page in CMA by may_writepage
Date: Thu,  9 May 2013 16:21:23 +0900
Message-Id: <1368084089-24576-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1368084089-24576-1-git-send-email-minchan@kernel.org>
References: <1368084089-24576-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Namhyung Kim <namhyung@kernel.org>, Minkyung Kim <minkyung88@lge.com>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>

Now, local variable references in shrink_page_list is
PAGEREF_RECLAIM_CLEAN as default. It is for preventing to reclaim
dirty pages when CMA try to migrate pages.
Strictly speaking, we don't need it because CMA already didn't allow
to write out by .may_writepage = 0 in reclaim_clean_pages_from_list.

Morever, it has a problem to prevent anonymous pages's swap out when
we use force_reclaim = true in shrink_page_list(ex, per process reclaim
can do it)

So this patch makes references's default value to PAGEREF_RECLAIM
and declare .may_writepage = 0 of scan_control in CMA part to make
code more clear.

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Mel Gorman <mgorman@suse.de>
Reported-by: Minkyung Kim <minkyung88@lge.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fa6a853..c22f9c1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -695,7 +695,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum page_references references = PAGEREF_RECLAIM;
 
 		cond_resched();
 
@@ -972,6 +972,8 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		.gfp_mask = GFP_KERNEL,
 		.priority = DEF_PRIORITY,
 		.may_unmap = 1,
+		/* Doesn't allow to write out dirty page */
+		.may_writepage = 0,
 	};
 	unsigned long ret, dummy1, dummy2;
 	struct page *page, *next;
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
