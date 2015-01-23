Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF066B0071
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 08:15:29 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id bs8so2878755wib.0
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 05:15:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id it4si2516441wid.13.2015.01.23.05.15.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 05:15:20 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 1/3] mm: when stealing freepages, also take pages created by splitting buddy page
Date: Fri, 23 Jan 2015 14:15:04 +0100
Message-Id: <1422018906-8880-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1422018906-8880-1-git-send-email-vbabka@suse.cz>
References: <1422018906-8880-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, stable@vger.kernel.org, #@kvack.org, v3.13+@kvack.org, containing@kvack.org, 0cbef29a7821@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

When __rmqueue_fallback() is called to allocate a page of order X, it will
find a page of order Y >= X of a fallback migratetype, which is different from
the desired migratetype. With the help of try_to_steal_freepages(), it may
change the migratetype (to the desired one) also of:

1) all currently free pages in the pageblock containing the fallback page
2) the fallback pageblock itself
3) buddy pages created by splitting the fallback page (when Y > X)

These decisions take the order Y into account, as well as the desired
migratetype, with the goal of preventing multiple fallback allocations that
could e.g. distribute UNMOVABLE allocations among multiple pageblocks.

Originally, decision for 1) has implied the decision for 3). Commit
47118af076f6 ("mm: mmzone: MIGRATE_CMA migration type added") changed that
(probably unintentionally) so that the buddy pages in case 3) are always
changed to the desired migratetype, except for CMA pageblocks.

Commit fef903efcf0c ("mm/page_allo.c: restructure free-page stealing code and
fix a bug") did some refactoring and added a comment that the case of 3) is
intended. Commit 0cbef29a7821 ("mm: __rmqueue_fallback() should respect
pageblock type") removed the comment and tried to restore the original behavior
where 1) implies 3), but due to the previous refactoring, the result is instead
that only 2) implies 3) - and the conditions for 2) are less frequently met
than conditions for 1). This may increase fragmentation in situations where the
code decides to steal all free pages from the pageblock (case 1)), but then
gives back the buddy pages produced by splitting.

This patch restores the original intended logic where 1) implies 3). During
testing with stress-highalloc from mmtests, this has shown to decrease the
number of events where UNMOVABLE and RECLAIMABLE allocations steal from MOVABLE
pageblocks, which can lead to permanent fragmentation. In some cases it has
increased the number of events when MOVABLE allocations steal from UNMOVABLE
or RECLAIMABLE pageblocks, but these are fixable by sync compaction and thus
less harmful.

Note that evaluation has shown that the behavior introduced by 47118af076f6
for buddy pages in case 3) is actually even better than the original logic,
so the following patch will introduce it properly once again.
For stable backports of this patch it makes thus sense to only fix versions
containing 0cbef29a7821.

[iamjoonsoo.kim@lge.com: tracepoint fix]
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: stable@vger.kernel.org # v3.13+ containing 0cbef29a7821
---
 include/trace/events/kmem.h |  7 ++++---
 mm/page_alloc.c             | 12 +++++-------
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index aece134..4ad10ba 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -268,11 +268,11 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 
 	TP_PROTO(struct page *page,
 		int alloc_order, int fallback_order,
-		int alloc_migratetype, int fallback_migratetype, int new_migratetype),
+		int alloc_migratetype, int fallback_migratetype),
 
 	TP_ARGS(page,
 		alloc_order, fallback_order,
-		alloc_migratetype, fallback_migratetype, new_migratetype),
+		alloc_migratetype, fallback_migratetype),
 
 	TP_STRUCT__entry(
 		__field(	struct page *,	page			)
@@ -289,7 +289,8 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__entry->fallback_order		= fallback_order;
 		__entry->alloc_migratetype	= alloc_migratetype;
 		__entry->fallback_migratetype	= fallback_migratetype;
-		__entry->change_ownership	= (new_migratetype == alloc_migratetype);
+		__entry->change_ownership	= (alloc_migratetype ==
+					get_pageblock_migratetype(page));
 	),
 
 	TP_printk("page=%p pfn=%lu alloc_order=%d fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d fragmenting=%d change_ownership=%d",
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7633c50..2d40492 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1138,8 +1138,8 @@ static void change_pageblock_range(struct page *pageblock_page,
  * nor move CMA pages to different free lists. We don't want unmovable pages
  * to be allocated from MIGRATE_CMA areas.
  *
- * Returns the new migratetype of the pageblock (or the same old migratetype
- * if it was unchanged).
+ * Returns the allocation migratetype if free pages were stolen, or the
+ * fallback migratetype if it was decided not to steal.
  */
 static int try_to_steal_freepages(struct zone *zone, struct page *page,
 				  int start_type, int fallback_type)
@@ -1170,12 +1170,10 @@ static int try_to_steal_freepages(struct zone *zone, struct page *page,
 
 		/* Claim the whole block if over half of it is free */
 		if (pages >= (1 << (pageblock_order-1)) ||
-				page_group_by_mobility_disabled) {
-
+				page_group_by_mobility_disabled)
 			set_pageblock_migratetype(page, start_type);
-			return start_type;
-		}
 
+		return start_type;
 	}
 
 	return fallback_type;
@@ -1227,7 +1225,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 			set_freepage_migratetype(page, new_type);
 
 			trace_mm_page_alloc_extfrag(page, order, current_order,
-				start_migratetype, migratetype, new_type);
+				start_migratetype, migratetype);
 
 			return page;
 		}
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
