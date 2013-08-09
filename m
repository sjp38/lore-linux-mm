Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id A5A0C6B0033
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 06:22:34 -0400 (EDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MR900DB4E4XUP80@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 09 Aug 2013 11:22:32 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC PATCH v2 0/4] mm: reclaim zbud pages on migration and compaction
Date: Fri, 09 Aug 2013 12:22:16 +0200
Message-id: <1376043740-10576-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

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

One of patches introduces PageZbud() function which identifies zbud pages
my page->_mapcount. Dave Hansen proposed aliasing PG_zbud=PG_slab but in
such case patch would be more intrusive.

Any ideas for a better solution are welcome.

TODO-s:
1. Migrate zbud pages directly instead of reclaiming.

Changes since v1:
1. Rebased against v3.11-rc4-103-g6c2580c.
2. Remove rebalance_lists() to fix reinserting zbud page after zbud_free.
   This function was added because similar code was present in
   zbud_free/zbud_alloc/zbud_reclaim_page but it turns out that there
   is no benefit in generalizing this code.
   (suggested by Seth Jennings)
3. Remove BUG_ON checks for first/last chunks during free and reclaim.
   (suggested by Seth Jennings)
4. Use page->_mapcount==-127 instead of new PG_zbud flag.
   (suggested by Dave Hansen)
5. Fix invalid dereference of pointer to compact_control in page_alloc.c.
6. Fix lost return value in try_to_unuse() in swapfile.c (this fixes
   hang when swapoff was interrupted e.g. by CTRL+C).


Best regards,
Krzysztof Kozlowski


Krzysztof Kozlowski (4):
  zbud: use page ref counter for zbud pages
  mm: split code for unusing swap entries from try_to_unuse
  mm: use mapcount for identifying zbud pages
  mm: reclaim zbud pages on migration and compaction

 include/linux/mm.h       |   23 +++
 include/linux/swapfile.h |    2 +
 include/linux/zbud.h     |   11 +-
 mm/compaction.c          |   20 ++-
 mm/internal.h            |    1 +
 mm/page_alloc.c          |    6 +
 mm/swapfile.c            |  356 ++++++++++++++++++++++++----------------------
 mm/zbud.c                |  247 +++++++++++++++++++++++---------
 mm/zswap.c               |   57 +++++++-
 9 files changed, 476 insertions(+), 247 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
