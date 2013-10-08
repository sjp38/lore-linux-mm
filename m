Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id C023A6B0037
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 09:29:59 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so8643854pdj.6
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 06:29:59 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUC00KK6QTP7W50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 08 Oct 2013 14:29:55 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH v3 0/6] mm: migrate zbud pages
Date: Tue, 08 Oct 2013 15:29:34 +0200
Message-id: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Hi,

This is third version of patches adding migration of zbud pages with changes
after discussions with Seth:
http://article.gmane.org/gmane.linux.kernel.mm/107695

In patch [PATCH 5/6] I removed the red-black tree in zswap and instead added
a radix tree in zbud. This also lead to removal of the "handle" concept and
to usage of offset as radix tree's index.

This particular change (5/6) still needs some improvements:
1. Accept storing of duplicated pages (as it was in original zswap).
2. Use RCU for radix tree reads and updates.
3. Optimize locking in zbud_free_all().
4. Iterate over LRU list instead of radix tree in zbud_free_all().


Description of patches:
-----------------
Currently zbud pages are not movable and they cannot be allocated from CMA
(Contiguous Memory Allocator) region. These patches add migration of zbud pages.

The zbud migration code utilizes mapping so many exceptions to migrate
code were added. This can be replaced for example with pin page
control subsystem:
http://article.gmane.org/gmane.linux.kernel.mm/105308
In such case the zbud migration code (zbud_migrate_page()) can be safely
re-used.

 * [PATCH 1/6] adds a reference counter to zbud pages.
 * [PATCH 2/6] is a trivial change of scope of local variable.
 * [PATCH 3/6] introduces PageZbud() function which identifies zbud pages by
   page->_mapcount. Dave Hansen proposed aliasing PG_zbud=PG_slab but in such
   case patch would be more intrusive.
   Any ideas for a better solution are welcome.
 * [PATCH 4/6] replaces direct initialization of zbud_header with memset.
 * [PATCH 5/6] replaces zswap's red-black tree with a new radix tree in zbud.
   Offset is used as index to this tree.
 * [PATCH 6/6] implements migration of zbud pages.


This patch set is based on v3.12-rc4-19-g8b5ede6.


Changes since v2:
-----------------
1. Rebased against v3.12-rc4-19-g8b5ede6.
2. Replace zswap's red-black tree with a new radix tree in zbud. Use
   offset as tree's index. Many zbud API changes.
3. Add patch 4/6.

Changes since v1:
-----------------
1. Rebased against v3.11.
2. Updated documentation of zbud_reclaim_page() to match usage of zbud page
   reference counters.
3. Split from patch 2/4 trivial change of scope of freechunks var to separate
   patch (3/5) (suggested by Seth Jennings).


Best regards,
Krzysztof Kozlowski


Krzysztof Kozlowski (6):
  zbud: use page ref counter for zbud pages
  zbud: make freechunks a block local variable
  mm: use mapcount for identifying zbud pages
  zbud: memset zbud_header to 0 during init
  zswap: replace tree in zswap with radix tree in zbud
  mm: migrate zbud pages

 include/linux/mm.h   |   23 ++
 include/linux/zbud.h |   28 ++-
 mm/compaction.c      |    7 +
 mm/migrate.c         |   17 +-
 mm/zbud.c            |  644 +++++++++++++++++++++++++++++++++++++++-----------
 mm/zswap.c           |  419 ++++++--------------------------
 6 files changed, 643 insertions(+), 495 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
