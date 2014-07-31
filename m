Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2A08B6B0038
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 22:22:39 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so2676603pab.1
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 19:22:38 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id gk1si4222411pbd.79.2014.07.30.19.22.36
        for <linux-mm@kvack.org>;
        Wed, 30 Jul 2014 19:22:38 -0700 (PDT)
Message-ID: <53D9A86B.20208@lge.com>
Date: Thu, 31 Jul 2014 11:22:35 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: [PATCHv2] CMA/HOTPLUG: clear buffer-head lru before page migration
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, =?EUC-KR?B?J7Howdi89ic=?= <iamjoonsoo.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, Michal Nazarewicz <mina86@mina86.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ????????? <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>

The previous PATCH inserts invalidate_bh_lrus() only into CMA code.
HOTPLUG needs also dropping bh of lru.
So v2 inserts invalidate_bh_lrus() into both of CMA and HOTPLUG.


---------------------------- 8< ----------------------------
The bh must be free to migrate a page at which bh is mapped.
The reference count of bh is increased when it is installed
into lru so that the bh of lru must be freed before migrating the page.

This frees every bh of lru. We could free only bh of migrating page.
But searching lru sometimes costs more than invalidating entire lru.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
---
 mm/memory_hotplug.c |    1 +
 mm/page_alloc.c     |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a3797d3..1c5454f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1672,6 +1672,7 @@ repeat:
                lru_add_drain_all();
                cond_resched();
                drain_all_pages();
+               invalidate_bh_lrus();
        }

        pfn = scan_movable_pages(start_pfn, end_pfn);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b99643d4..c00dedf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6369,6 +6369,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
        if (ret)
                return ret;

+       invalidate_bh_lrus();
+
        ret = __alloc_contig_migrate_range(&cc, start, end);
        if (ret)
                goto done;
--
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
