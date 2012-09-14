Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 5C4116B0263
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 10:29:47 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MAC005KNG9KLH30@mailout2.samsung.com> for
 linux-mm@kvack.org; Fri, 14 Sep 2012 23:29:46 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MAC00M85G9E5EA0@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 14 Sep 2012 23:29:45 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH v4 0/4] cma: fix watermark checking
Date: Fri, 14 Sep 2012 16:29:30 +0200
Message-id: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Free pages belonging to Contiguous Memory Allocator (CMA) areas cannot be
used by unmovable allocations and this fact should be accounted for while
doing zone watermark checking.  Additionaly while CMA pages are isolated
they shouldn't be included in the total number of free pages (as they
cannot be allocated while they are isolated).  The following patch series
should fix both issues.  It is based on top of recent Minchan's CMA series
(https://lkml.org/lkml/2012/8/14/81 "[RFC 0/2] Reduce alloc_contig_range
latency").

v4:
- update patch description in patch #1
- add unlikely() to patch #2 (noticed by Minchan Kim)
- fix whitespace change in patch #2 (noticed by Mel Gorman)
- add __mod_zone_freepage_state() in patch #3 (from Minchan)
- fold patch #4 into patch #5 (suggested by Minchan)
- use ALLOC_CMA alloc flag instead of gfp_flags (from Minchan)

v3:
- fix tracing in free_pcppages_bulk()
- fix counting of free CMA pages (broken by v2)

v2:
- no need to call get_pageblock_migratetype() in free_one_page() in patch #1
  (thanks to review from Michal Nazarewicz)
- fix issues pointed in http://www.spinics.net/lists/linux-mm/msg41017.html
  in patch #2 (ditto)
- remove no longer needed is_cma_pageblock() from patch #2


Bartlomiej Zolnierkiewicz (4):
  mm: fix tracing in free_pcppages_bulk()
  cma: fix counting of isolated pages
  cma: count free CMA pages
  cma: fix watermark checking

 include/linux/mmzone.h | 16 ++++++++++++
 include/linux/vmstat.h |  8 ++++++
 mm/compaction.c        |  8 +++++-
 mm/page_alloc.c        | 68 +++++++++++++++++++++++++++++++-------------------
 mm/page_isolation.c    | 13 +++++++---
 mm/vmstat.c            |  1 +
 6 files changed, 85 insertions(+), 29 deletions(-)

-- 
1.7.11.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
