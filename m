Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 34B356B0037
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 04:43:23 -0400 (EDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MSC00IZB5JWMI90@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Aug 2013 09:43:21 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC PATCH 0/4] mm: migrate zbud pages
Date: Fri, 30 Aug 2013 10:42:52 +0200
Message-id: <1377852176-30970-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Hi,

Currently zbud pages are not movable and they cannot be allocated from CMA
region. These patches add migration of zbud pages.

The zbud migration code utilizes mapping so many exceptions to migrate
code was added. It can be replaced for example with pin page
control subsystem:
http://article.gmane.org/gmane.linux.kernel.mm/105308
In such case the zbud migration code (zbud_migrate_page()) can be safely
re-used.


Patch "[PATCH 3/4] mm: use indirect zbud handle and radix tree" changes zbud
handle to support migration. Now the handle is an index in radix tree and
zbud_map() maps it to proper virtual address. This exposes race conditions,
some of them are discussed already here:
http://article.gmane.org/gmane.linux.kernel.mm/105988

Races are fixed by adding internal map count for each zbud handle.
The map count is increased on zbud_map() call.

Some races between writeback and invalidate still exist. In such case a message
can be seen in logs:
  zbud: error: could not lookup handle 13810 in tree
Patches from discussion above may resolve it.

I have considered using "pgoff_t offset" as handle but it prevented storing
duplicate pages in zswap.


Patch "[PATCH 2/4] mm: use mapcount for identifying zbud pages" introduces
PageZbud() function which identifies zbud pages by page->_mapcount.
Dave Hansen proposed aliasing PG_zbud=PG_slab but in such case patch
would be more intrusive.

Any ideas for a better solution are welcome.


This patch set is based on v3.11-rc7-30-g41615e8.


This is continuation of my previous work: reclaiming zbud pages on migration
and compaction. However it current solution is completely different so I am not
attaching previous changelog.
Previous patches can be found here:
 * [RFC PATCH v2 0/4] mm: reclaim zbud pages on migration and compaction
   http://article.gmane.org/gmane.linux.kernel.mm/105153
 * [RFC PATCH 0/4] mm: reclaim zbud pages on migration and compaction
   http://article.gmane.org/gmane.linux.kernel.mm/104801

One patch from previous work is re-used along with minor changes:
"[PATCH 1/4] zbud: use page ref counter for zbud pages"
 * Add missing spin_unlock in zbud_reclaim_page().
 * Decrease pool->pages_nr in zbud_free(), not when putting page. This also
removes the need of holding lock while call to put_zbud_page().


Best regards,
Krzysztof Kozlowski


Krzysztof Kozlowski (4):
  zbud: use page ref counter for zbud pages
  mm: use mapcount for identifying zbud pages
  mm: use indirect zbud handle and radix tree
  mm: migrate zbud pages

 include/linux/mm.h   |   23 +++
 include/linux/zbud.h |    3 +-
 mm/compaction.c      |    7 +
 mm/migrate.c         |   17 +-
 mm/zbud.c            |  552 +++++++++++++++++++++++++++++++++++++++++---------
 mm/zswap.c           |   28 ++-
 6 files changed, 525 insertions(+), 105 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
