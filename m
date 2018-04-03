Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 679D16B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 00:46:40 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d14-v6so8124605plj.4
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 21:46:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v69sor415259pgb.66.2018.04.02.21.46.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 21:46:39 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: consider non-anonymous thp as unmovable page
Date: Tue,  3 Apr 2018 13:46:28 +0900
Message-Id: <1522730788-24530-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

My testing for the latest kernel supporting thp migration found out an
infinite loop in offlining the memory block that is filled with shmem
thps.  We can get out of the loop with a signal, but kernel should
return with failure in this case.

What happens in the loop is that scan_movable_pages() repeats returning
the same pfn without any progress. That's because page migration always
fails for shmem thps.

In memory offline code, memory blocks containing unmovable pages should
be prevented from being offline targets by has_unmovable_pages() inside
start_isolate_page_range(). So this patch simply does it for
non-anonymous thps.

Fixes: commit 72b39cfc4d75 ("mm, memory_hotplug: do not fail offlining too early")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org # v4.15+
---
Actually I'm not sure which commit we should set to "Fixes" tag.
Commit 8135d8926c08 ("mm: memory_hotplug: memory hotremove supports thp
migration") failed to introduce the code that this patch is suggesting.
But the infinite loop became visible by commit 72b39cfc4d75 ("mm,
memory_hotplug: do not fail offlining too early") where retry code was
removed.
---
 mm/page_alloc.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git v4.16-rc7-mmotm-2018-03-28-16-05/mm/page_alloc.c v4.16-rc7-mmotm-2018-03-28-16-05_patched/mm/page_alloc.c
index 905db9d..dbbe8fa 100644
--- v4.16-rc7-mmotm-2018-03-28-16-05/mm/page_alloc.c
+++ v4.16-rc7-mmotm-2018-03-28-16-05_patched/mm/page_alloc.c
@@ -7682,6 +7682,18 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 
 		if (!PageLRU(page))
 			found++;
+
+		/*
+		 * Thp migration is available only for anonymous thps for now.
+		 * So let's consider non-anonymous thps as unmovable pages.
+		 */
+		if (PageTransCompound(page)) {
+			if (PageAnon(page))
+				iter += (1 << page_order(page)) - 1;
+			else
+				found++;
+		}
+
 		/*
 		 * If there are RECLAIMABLE pages, we need to check
 		 * it.  But now, memory offline itself doesn't call
-- 
2.7.0
