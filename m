Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id E9E576B0073
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:33:33 -0400 (EDT)
Received: by labko7 with SMTP id ko7so28982515lab.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:33:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t1si16724348wjx.99.2015.06.10.02.33.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 02:33:20 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 5/6] mm, compaction: skip compound pages by order in free scanner
Date: Wed, 10 Jun 2015 11:32:33 +0200
Message-Id: <1433928754-966-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1433928754-966-1-git-send-email-vbabka@suse.cz>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

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
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index e37d361..4a14084 100644
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
+			if (comp_order > 0 && comp_order < MAX_ORDER) {
+				blockpfn += (1UL << comp_order) - 1;
+				cursor += (1UL << comp_order) - 1;
+			}
+
+			goto isolate_fail;
+		}
+
 		if (!PageBuddy(page))
 			goto isolate_fail;
 
@@ -496,6 +514,13 @@ isolate_fail:
 
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
