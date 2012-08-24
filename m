Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 94B986B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 06:45:34 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M99003ET9V7INU0@mailout2.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Aug 2012 19:45:33 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M990073E9VOI960@mmp1.samsung.com> for linux-mm@kvack.org;
 Fri, 24 Aug 2012 19:45:32 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 0/4] cma: fix watermark checking
Date: Fri, 24 Aug 2012 12:45:16 +0200
Message-id: <1345805120-797-1-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, kyungmin.park@samsung.com, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Free pages belonging to Contiguous Memory Allocator (CMA) areas cannot be
used by unmovable allocations and this fact should be accounted for while
doing zone watermark checking.  Additionaly while CMA pages are isolated
they shouldn't be included in the total number of free pages (as they
cannot be allocated while they are isolated).  The following patch series
should fix both issues.  It is based on top of recent Minchan's CMA series
(https://lkml.org/lkml/2012/8/14/81 "[RFC 0/2] Reduce alloc_contig_range
latency").


Bartlomiej Zolnierkiewicz (3):
  cma: fix counting of isolated pages
  cma: count free CMA pages
  cma: fix watermark checking

Marek Szyprowski (1):
  mm: add accounting for CMA pages and use them for watermark
    calculation

 include/linux/mmzone.h |  5 +++-
 mm/compaction.c        | 11 ++++----
 mm/page_alloc.c        | 73 ++++++++++++++++++++++++++++++++++++++++----------
 mm/page_isolation.c    | 20 +++++++++++---
 mm/vmscan.c            |  4 +--
 mm/vmstat.c            |  1 +
 6 files changed, 89 insertions(+), 25 deletions(-)

-- 
1.7.11.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
