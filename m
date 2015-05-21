Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2146B0160
	for <linux-mm@kvack.org>; Thu, 21 May 2015 09:27:34 -0400 (EDT)
Received: by wgjc11 with SMTP id c11so85737197wgj.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 06:27:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10si3124603wiy.56.2015.05.21.06.27.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 May 2015 06:27:32 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] hugetlb: Do not account hugetlb pages as NR_FILE_PAGES
Date: Thu, 21 May 2015 15:27:22 +0200
Message-Id: <1432214842-22730-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

hugetlb pages uses add_to_page_cache to track shared mappings. This
is OK from the data structure point of view but it is less so from the
NR_FILE_PAGES accounting:
	- huge pages are accounted as 4k which is clearly wrong
	- this counter is used as the amount of the reclaimable page
	  cache which is incorrect as well because hugetlb pages are
	  special and not reclaimable
	- the counter is then exported to userspace via /proc/meminfo
	  (in Cached:), /proc/vmstat and /proc/zoneinfo as
	  nr_file_pages which is confusing at least:
	  Cached:          8883504 kB
	  HugePages_Free:     8348
	  ...
	  Cached:          8916048 kB
	  HugePages_Free:      156
	  ...
	  thats 8192 huge pages allocated which is ~16G accounted as 32M

There are usually not that many huge pages in the system for this to
make any visible difference e.g. by fooling __vm_enough_memory or
zone_pagecache_reclaimable.

Fix this by special casing huge pages in both __delete_from_page_cache
and __add_to_page_cache_locked. replace_page_cache_page is currently
only used by fuse and that shouldn't touch hugetlb pages AFAICS but it
is more robust to check for special casing there as well.

Hugetlb pages shouldn't get to any other paths where we do accounting:
	- migration - we have a special handling via
	  hugetlbfs_migrate_page
	- shmem - doesn't handle hugetlb pages directly even for
	  SHM_HUGETLB resp. MAP_HUGETLB
	- swapcache - hugetlb is not swapable

This has a user visible effect but I believe it is reasonable because
the previously exported number is simply bogus.

An alternative would be to account hugetlb pages with their real size
and treat them similar to shmem. But this has some drawbacks.

First we would have to special case in kernel users of NR_FILE_PAGES and
considering how hugetlb is special we would have to do it everywhere. We
do not want Cached exported by /proc/meminfo to include it because the
value would be even more misleading.
__vm_enough_memory and zone_pagecache_reclaimable would have to do
the same thing because those pages are simply not reclaimable. The
correction is even not trivial because we would have to consider all
active hugetlb page sizes properly. Users of the counter outside of the
kernel would have to do the same.
So the question is why to account something that needs to be basically
excluded for each reasonable usage. This doesn't make much sense to me.

It seems that this has been broken since hugetlb was introduced but I
haven't checked the whole history.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/filemap.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 413eb20abfa7..249bde91c273 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -197,7 +197,9 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
 
-	__dec_zone_page_state(page, NR_FILE_PAGES);
+	/* hugetlb pages do not participate into page cache accounting. */
+	if (!PageHuge(page))
+		__dec_zone_page_state(page, NR_FILE_PAGES);
 	if (PageSwapBacked(page))
 		__dec_zone_page_state(page, NR_SHMEM);
 	BUG_ON(page_mapped(page));
@@ -484,7 +486,13 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
 		BUG_ON(error);
 		mapping->nrpages++;
-		__inc_zone_page_state(new, NR_FILE_PAGES);
+
+		/*
+		 * hugetlb pages do not participate into page cache
+		 * accounting.
+		 */
+		if (!PageHuge(new))
+			__inc_zone_page_state(new, NR_FILE_PAGES);
 		if (PageSwapBacked(new))
 			__inc_zone_page_state(new, NR_SHMEM);
 		spin_unlock_irq(&mapping->tree_lock);
@@ -576,7 +584,10 @@ static int __add_to_page_cache_locked(struct page *page,
 	radix_tree_preload_end();
 	if (unlikely(error))
 		goto err_insert;
-	__inc_zone_page_state(page, NR_FILE_PAGES);
+
+	/* hugetlb pages do not participate into page cache accounting. */
+	if (!huge)
+		__inc_zone_page_state(page, NR_FILE_PAGES);
 	spin_unlock_irq(&mapping->tree_lock);
 	if (!huge)
 		mem_cgroup_commit_charge(page, memcg, false);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
