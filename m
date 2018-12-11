Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6A0B8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 03:51:22 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 68so12134429pfr.6
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:51:22 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id i6si11326633pgq.207.2018.12.11.00.51.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 00:51:21 -0800 (PST)
From: Oscar Salvador <osalvador@suse.de>
Subject: [PATCH] mm, memory_hotplug: Don't bail out in do_migrate_range prematurely
Date: Tue, 11 Dec 2018 09:50:42 +0100
Message-Id: <20181211085042.2696-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, david@redhat.com, pasha.tatashin@soleen.com, dan.j.williams@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

do_migrate_ranges() takes a memory range and tries to isolate the
pages to put them into a list.
This list will be later on used in migrate_pages() to know
the pages we need to migrate.

Currently, if we fail to isolate a single page, we put all already
isolated pages back to their LRU and we bail out from the function.
This is quite suboptimal, as this will force us to start over again
because scan_movable_pages will give us the same range.
If there is no chance that we can isolate that page, we will loop here
forever.

Issue debugged in 4d0c7db96 ("hwpoison, memory_hotplug: allow hwpoisoned
pages to be offlined") has proved that.
During the debugging of that issue, it was noticed that if
do_migrate_ranges() fails to isolate a single page, we will
just discard the work we have done so far and bail out, which means
that scan_movable_pages() will find again the same set of pages.

Instead, we can just skip the error, keep isolating as much pages
as possible and then proceed with the call to migrate_pages().
This will allow us to do some work at least.

There is no danger in the skipped pages to be lost, because
scan_movable_pages() will give us them as they could not
be isolated and therefore migrated.

Although this patch has proved to be useful when dealing with
4d0c7db96 because it allows us to move forward as long as the
page is not in LRU, we still need 4d0c7db96
("hwpoison, memory_hotplug: allow hwpoisoned pages to be offlined")
to handle the LRU case and the unmapping of the page if needed.
So, this is just a follow-up cleanup.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 86ab673fc4e3..804d0280d2ab 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1339,7 +1339,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 	unsigned long pfn;
 	struct page *page;
 	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
-	int not_managed = 0;
 	int ret = 0;
 	LIST_HEAD(source);
 
@@ -1395,25 +1394,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 				inc_node_page_state(page, NR_ISOLATED_ANON +
 						    page_is_file_cache(page));
 
-		} else {
-			pr_warn("failed to isolate pfn %lx\n", pfn);
-			dump_page(page, "isolation failed");
-			put_page(page);
-			/* Because we don't have big zone->lock. we should
-			   check this again here. */
-			if (page_count(page)) {
-				not_managed++;
-				ret = -EBUSY;
-				break;
-			}
 		}
 	}
 	if (!list_empty(&source)) {
-		if (not_managed) {
-			putback_movable_pages(&source);
-			goto out;
-		}
-
 		/* Allocate a new page from the nearest neighbor node */
 		ret = migrate_pages(&source, new_node_page, NULL, 0,
 					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
@@ -1426,7 +1409,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			putback_movable_pages(&source);
 		}
 	}
-out:
+
 	return ret;
 }
 
-- 
2.13.7
