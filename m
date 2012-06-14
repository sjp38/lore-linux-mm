Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 7548F6B006C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 12:05:11 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5M009BK7CIB760@mailout3.samsung.com> for
 linux-mm@kvack.org; Fri, 15 Jun 2012 01:05:07 +0900 (KST)
Received: from bzolnier-desktop.localnet ([106.116.48.38])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5M002ZB7CFS450@mmp1.samsung.com> for linux-mm@kvack.org;
 Fri, 15 Jun 2012 01:05:07 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 2/2] mm: compaction: add /proc/vmstat entry for rescued
 MIGRATE_UNMOVABLE pageblocks
Date: Thu, 14 Jun 2012 18:02:49 +0200
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Message-id: <201206141802.50075.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Dave Jones <davej@redhat.com>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] mm: compaction: add /proc/vmstat entry for rescued MIGRATE_UNMOVABLE pageblocks

compact_rescued_unmovable_blocks shows the number of MIGRATE_UNMOVABLE
pageblocks converted back to MIGRATE_MOVABLE type by the memory compaction
code.  Non-zero values indicate that large kernel-originated allocations
of MIGRATE_UNMOVABLE type happen in the system and need special handling 
from the memory compaction code.

This new vmstat entry is optional but useful for development and understanding
the system.

Cc: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Cong Wang <amwang@redhat.com>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---

 include/linux/vm_event_item.h |    1 +
 mm/compaction.c               |    2 ++
 mm/vmstat.c                   |    1 +
 3 files changed, 4 insertions(+)

Index: b/include/linux/vm_event_item.h
===================================================================
--- a/include/linux/vm_event_item.h	2012-06-14 11:28:48.812775316 +0200
+++ b/include/linux/vm_event_item.h	2012-06-14 11:31:17.132775300 +0200
@@ -39,6 +39,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 #ifdef CONFIG_COMPACTION
 		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
+		COMPACT_RESCUED_UNMOVABLE_BLOCKS,
 #endif
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
Index: b/mm/compaction.c
===================================================================
--- a/mm/compaction.c	2012-06-14 11:31:24.800775299 +0200
+++ b/mm/compaction.c	2012-06-14 11:31:31.612775298 +0200
@@ -387,6 +387,8 @@ static void rescue_unmovable_pageblock(s
 {
 	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
+
+	count_vm_event(COMPACT_RESCUED_UNMOVABLE_BLOCKS);
 }
 
 /*
Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c	2012-06-14 11:28:48.824775319 +0200
+++ b/mm/vmstat.c	2012-06-14 11:31:17.132775300 +0200
@@ -767,6 +767,7 @@ const char * const vmstat_text[] = {
 	"compact_stall",
 	"compact_fail",
 	"compact_success",
+	"compact_rescued_unmovable_blocks",
 #endif
 
 #ifdef CONFIG_HUGETLB_PAGE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
