Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 126236B006E
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 20:42:59 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so41149556pdb.2
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 17:42:58 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ok4si42218439pab.221.2015.06.24.17.42.54
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 17:42:55 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 05/10] mm/compaction: make freepage scanner scans non-movable pageblock
Date: Thu, 25 Jun 2015 09:45:16 +0900
Message-Id: <1435193121-25880-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, freescanner doesn't scan non-movable pageblock, because if
freepages in non-movable pageblock are exhausted, another movable
pageblock would be used for non-movable allocation and it could cause
fragmentation.

But, we should know that watermark check for compaction doesn't consider
this reality. So, if all freepages are in non-movable pageblock, although,
system has enough freepages and watermark check is passed, freepage
scanner can't get any freepage and compaction will be failed. There is
no way to get precise number of freepage on movable pageblock and no way
to reclaim only used pages in movable pageblock. Therefore, I think
that best way to overcome this situation is to use freepage in non-movable
pageblock in compaction.

My test setup for this situation is:

Memory is artificially fragmented to make order 3 allocation hard. And,
most of pageblocks are changed to unmovable migratetype.

  System: 512 MB with 32 MB Zram
  Memory: 25% memory is allocated to make fragmentation and kernel build
  	is running on background.
  Fragmentation: Successful order 3 allocation candidates may be around
  	1500 roughly.
  Allocation attempts: Roughly 3000 order 3 allocation attempts
  	with GFP_NORETRY. This value is determined to saturate allocation
  	success.

Below is the result of this test.

Test: build-frag-unmovable
                                      base nonmovable
compact_free_scanned               5032378    4110920
compact_isolated                     53368     330762
compact_migrate_scanned            1456516    6164677
compact_stall                          538        746
compact_success                         93        350
pgmigrate_success                    19926     152754
Success:                                15         31
Success(N):                             33         65

Column 'Success' and 'Success(N) are calculated by following equations.

Success = successful allocation * 100 / attempts
Success(N) = successful allocation * 100 / order 3 candidate

Result shows that success rate is doubled in this case
because we can search more area.

But, we can observe regression in other case.

Test: stress-highalloc in mmtests
(tweaks to request order-7 unmovable allocation)

Ops 1		30.00		 8.33
Ops 2		32.33		26.67
Ops 3		91.67		92.00
Compaction stalls                 5110        5581
Compaction success                1787        1807
Compaction failures               3323        3774
Compaction pages isolated      6370911    15421622
Compaction migrate scanned    52681405    83721428
Compaction free scanned      418049611   579768237
Compaction cost                   3745        8822

Although this regression is bad, there are also much improvement
in other cases that most of pageblocks are non-movable migratetype.
IMHO, this patch can be justified by this improvement. Moreover,
this regression disappears after applying following patches, so
we don't need to worry about regression much.

Migration scanner already scans non-movable pageblock and make some
freepage in that pageblock through migration. So, even if freepage
scanner scans non-movable pageblock and uses freepage in that pageblock,
number of freepages on non-movable pageblock wouldn't diminish much and
wouldn't cause much fragmentation.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index dd2063b..8d1b3b5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -905,12 +905,8 @@ static bool suitable_migration_target(struct page *page)
 			return false;
 	}
 
-	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(get_pageblock_migratetype(page)))
-		return true;
-
-	/* Otherwise skip the block */
-	return false;
+	/* Otherwise scan the block */
+	return true;
 }
 
 /*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
