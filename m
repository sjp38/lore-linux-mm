Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1C16B0010
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 11:55:40 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z13-v6so2018662pgv.18
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 08:55:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21-v6sor33730839pgb.24.2018.11.02.08.55.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Nov 2018 08:55:38 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, memory_hotplug: teach has_unmovable_pages about of LRU migrateable pages
Date: Fri,  2 Nov 2018 16:55:28 +0100
Message-Id: <20181102155528.20358-1-mhocko@kernel.org>
In-Reply-To: <20181101091055.GA15166@MiWiFi-R3L-srv>
References: <20181101091055.GA15166@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Stable tree <stable@vger.kernel.org>

From: Michal Hocko <mhocko@suse.com>

Baoquan He has noticed that 15c30bc09085  ("mm, memory_hotplug: make
has_unmovable_pages more robust") is causing memory offlining failures
on a movable node. After a further debugging it turned out that
has_unmovable_pages fails prematurely because it stumbles over off-LRU
pages. Nevertheless those pages are not on LRU because they are waiting
on the pcp LRU caches (an example of __dump_page added by a debugging
patch)
[  560.923297] page:ffffea043f39fa80 count:1 mapcount:0 mapping:ffff880e5dce1b59 index:0x7f6eec459
[  560.931967] flags: 0x5fffffc0080024(uptodate|active|swapbacked)
[  560.937867] raw: 005fffffc0080024 dead000000000100 dead000000000200 ffff880e5dce1b59
[  560.945606] raw: 00000007f6eec459 0000000000000000 00000001ffffffff ffff880e43ae8000
[  560.953323] page dumped because: hotplug
[  560.957238] page->mem_cgroup:ffff880e43ae8000
[  560.961620] has_unmovable_pages: pfn:0x10fd030d, found:0x1, count:0x0
[  560.968127] page:ffffea043f40c340 count:2 mapcount:0 mapping:ffff880e2f2d8628 index:0x0
[  560.976104] flags: 0x5fffffc0000006(referenced|uptodate)
[  560.981401] raw: 005fffffc0000006 dead000000000100 dead000000000200 ffff880e2f2d8628
[  560.989119] raw: 0000000000000000 0000000000000000 00000002ffffffff ffff88010a8f5000
[  560.996833] page dumped because: hotplug

The issue could be worked around by calling lru_add_drain_all but we can
do better than that. We know that all swap backed pages are migrateable
and the same applies for pages which do implement the migratepage
callback.

Reported-by: Baoquan He <bhe@redhat.com>
Fixes: 15c30bc09085  ("mm, memory_hotplug: make has_unmovable_pages more robust")
Cc: stable
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
we have been discussing issue reported by Baoquan [1] mostly off-list
and he has confirmed the patch solved failures he is seeing. I believe
that has_unmovable_pages begs for a much better implementation and/or
substantial pages isolation design rethinking but let's close the bug
which can be really annoying first.

[1] http://lkml.kernel.org/r/20181101091055.GA15166@MiWiFi-R3L-srv

 mm/page_alloc.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 863d46da6586..48ceda313332 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7824,8 +7824,22 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		if (__PageMovable(page))
 			continue;
 
-		if (!PageLRU(page))
-			found++;
+		if (PageLRU(page))
+			continue;
+
+		/*
+		 * Some LRU pages might be temporarily off-LRU for all
+		 * sort of different reasons - reclaim, migration,
+		 * per-cpu LRU caches etc.
+		 * Make sure we do not consider those pages to be unmovable.
+		 */
+		if (PageSwapBacked(page))
+			continue;
+
+		if (page->mapping && page->mapping->a_ops &&
+				page->mapping->a_ops->migratepage)
+			continue;
+
 		/*
 		 * If there are RECLAIMABLE pages, we need to check
 		 * it.  But now, memory offline itself doesn't call
@@ -7839,7 +7853,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		 * is set to both of a memory hole page and a _used_ kernel
 		 * page at boot.
 		 */
-		if (found > count)
+		if (++found > count)
 			goto unmovable;
 	}
 	return false;
-- 
2.19.1
