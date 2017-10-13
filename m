Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C30706B0038
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:00:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k4so5874941wmc.20
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 05:00:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38sor391509wrw.67.2017.10.13.05.00.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 05:00:23 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Date: Fri, 13 Oct 2017 14:00:12 +0200
Message-Id: <20171013120013.698-1-mhocko@kernel.org>
In-Reply-To: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Michael has noticed that the memory offline tries to migrate kernel code
pages when doing
 echo 0 > /sys/devices/system/memory/memory0/online

The current implementation will fail the operation after several failed
page migration attempts but we shouldn't even attempt to migrate
that memory and fail right away because this memory is clearly not
migrateable. This will become a real problem when we drop the retry loop
counter resp. timeout.

The real problem is in has_unmovable_pages in fact. We should fail if
there are any non migrateable pages in the area. In orther to guarantee
that remove the migrate type checks because MIGRATE_MOVABLE is not
guaranteed to contain only migrateable pages. It is merely a heuristic.
Similarly MIGRATE_CMA does guarantee that the page allocator doesn't
allocate any non-migrateable pages from the block but CMA allocations
themselves are unlikely to migrateable. Therefore remove both checks.

Reported-by: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3badcedf96a7..ad0294ab3e4f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7355,9 +7355,6 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	 */
 	if (zone_idx(zone) == ZONE_MOVABLE)
 		return false;
-	mt = get_pageblock_migratetype(page);
-	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
-		return false;
 
 	pfn = page_to_pfn(page);
 	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
