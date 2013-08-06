Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 90ABA6B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 02:42:56 -0400 (EDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MR300EBZJZ5FG30@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 06 Aug 2013 07:42:54 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC PATCH 0/4] mm: reclaim zbud pages on migration and compaction
Date: Tue, 06 Aug 2013 08:42:37 +0200
Message-id: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Hi,

Currently zbud pages are not movable and they cannot be allocated from CMA
region. These patches try to address the problem by:
1. Adding a new form of reclaim of zbud pages.
2. Reclaiming zbud pages during migration and compaction.
3. Allocating zbud pages with __GFP_RECLAIMABLE flag.

This reclaim process is different than zbud_reclaim_page(). It acts more
like swapoff() by trying to unuse pages stored in zbud page and bring
them back to memory. The standard zbud_reclaim_page() on the other hand
tries to write them back.

One of patches introduces a new flag: PageZbud. This flag is used in
isolate_migratepages_range() to grab zbud pages and pass them later
for reclaim. Probably this could be replaced with something
smarter than a flag used only in one case.
Any ideas for a better solution are welcome.

This patch set is based on Linux 3.11-rc4.

TODOs:
1. Replace PageZbud flag with other solution.

Best regards,
Krzysztof Kozlowski


Krzysztof Kozlowski (4):
  zbud: use page ref counter for zbud pages
  mm: split code for unusing swap entries from try_to_unuse
  mm: add zbud flag to page flags
  mm: reclaim zbud pages on migration and compaction

 include/linux/page-flags.h |   12 ++
 include/linux/swapfile.h   |    2 +
 include/linux/zbud.h       |   11 +-
 mm/compaction.c            |   20 ++-
 mm/internal.h              |    1 +
 mm/page_alloc.c            |    9 ++
 mm/swapfile.c              |  354 +++++++++++++++++++++++---------------------
 mm/zbud.c                  |  301 +++++++++++++++++++++++++------------
 mm/zswap.c                 |   57 ++++++-
 9 files changed, 499 insertions(+), 268 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
