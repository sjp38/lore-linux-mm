Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 38A566B025C
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:28:38 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so62549047wic.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:28:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n18si6018943wij.109.2015.07.31.08.28.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 08:28:26 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 5/5] mm, compaction: skip compound pages by order in free scanner
Date: Fri, 31 Jul 2015 17:28:07 +0200
Message-Id: <1438356487-7082-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1438356487-7082-1-git-send-email-vbabka@suse.cz>
References: <1438356487-7082-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>

The compaction free scanner is looking for PageBuddy() pages and skipping all
others.  For large compound pages such as THP or hugetlbfs, we can save a lot
of iterations if we skip them at once using their compound_order(). This is
generally unsafe and we can read a bogus value of order due to a race, but if
we are careful, the only danger is skipping too much.

When tested with stress-highalloc from mmtests on 4GB system with 1GB hugetlbfs
pages, the vmstat compact_free_scanned count decreased by at least 15%.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 70b0776..b978693 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -437,6 +437,24 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 		if (!valid_page)
 			valid_page = page;
+
+		/*
+		 * For compound pages such as THP and hugetlbfs, we can save
+		 * potentially a lot of iterations if we skip them at once.
+		 * The check is racy, but we can consider only valid values
+		 * and the only danger is skipping too much.
+		 */
+		if (PageCompound(page)) {
+			unsigned int comp_order = compound_order(page);
+
+			if (likely(comp_order < MAX_ORDER)) {
+				blockpfn += (1UL << comp_order) - 1;
+				cursor += (1UL << comp_order) - 1;
+			}
+
+			goto isolate_fail;
+		}
+
 		if (!PageBuddy(page))
 			goto isolate_fail;
 
@@ -496,6 +514,13 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 	}
 
+	/*
+	 * There is a tiny chance that we have read bogus compound_order(),
+	 * so be careful to not go outside of the pageblock.
+	 */
+	if (unlikely(blockpfn > end_pfn))
+		blockpfn = end_pfn;
+
 	trace_mm_compaction_isolate_freepages(*start_pfn, blockpfn,
 					nr_scanned, total_isolated);
 
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
