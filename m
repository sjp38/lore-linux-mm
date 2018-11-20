Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8886B1FCC
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 08:43:38 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so1307403edd.2
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 05:43:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6sor21397135edx.21.2018.11.20.05.43.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 05:43:36 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/3] mm, memory_hotplug: try to migrate full section worth of pages
Date: Tue, 20 Nov 2018 14:43:21 +0100
Message-Id: <20181120134323.13007-2-mhocko@kernel.org>
In-Reply-To: <20181120134323.13007-1-mhocko@kernel.org>
References: <20181120134323.13007-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

do_migrate_range has been limiting the number of pages to migrate to 256
for some reason which is not documented. Even if the limit made some
sense back then when it was introduced it doesn't really serve a good
purpose these days. If the range contains huge pages then
we break out of the loop too early and go through LRU and pcp
caches draining and scan_movable_pages is quite suboptimal.

The only reason to limit the number of pages I can think of is to reduce
the potential time to react on the fatal signal. But even then the
number of pages is a questionable metric because even a single page
might migration block in a non-killable state (e.g. __unmap_and_move).

Remove the limit and offline the full requested range (this is one
membblock worth of pages with the current code). Should we ever get a
report that offlining takes too long to react on fatal signal then we
should rather fix the core migration to use killable waits and bailout
on a signal.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c82193db4be6..6263c8cd4491 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1339,18 +1339,16 @@ static struct page *new_node_page(struct page *page, unsigned long private)
 	return new_page_nodemask(page, nid, &nmask);
 }
 
-#define NR_OFFLINE_AT_ONCE_PAGES	(256)
 static int
 do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long pfn;
 	struct page *page;
-	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
 	int not_managed = 0;
 	int ret = 0;
 	LIST_HEAD(source);
 
-	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
+	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
@@ -1362,8 +1360,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 				ret = -EBUSY;
 				break;
 			}
-			if (isolate_huge_page(page, &source))
-				move_pages -= 1 << compound_order(head);
+			isolate_huge_page(page, &source);
 			continue;
 		} else if (PageTransHuge(page))
 			pfn = page_to_pfn(compound_head(page))
@@ -1382,7 +1379,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		if (!ret) { /* Success */
 			put_page(page);
 			list_add_tail(&page->lru, &source);
-			move_pages--;
 			if (!__PageMovable(page))
 				inc_node_page_state(page, NR_ISOLATED_ANON +
 						    page_is_file_cache(page));
-- 
2.19.1
