Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75CD76B04E7
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 05:18:51 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id r200-v6so13880347wmg.1
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 02:18:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e13-v6sor163387wrj.23.2018.11.07.02.18.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 02:18:50 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 5/5] mm, memory_hotplug: be more verbose for memory offline failures
Date: Wed,  7 Nov 2018 11:18:30 +0100
Message-Id: <20181107101830.17405-6-mhocko@kernel.org>
In-Reply-To: <20181107101830.17405-1-mhocko@kernel.org>
References: <20181107101830.17405-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

There is only very limited information printed when the memory offlining
fails:
[ 1984.506184] rac1 kernel: memory offlining [mem 0x82600000000-0x8267fffffff] failed due to signal backoff

This tells us that the failure is triggered by the userspace
intervention but it doesn't tell us much more about the underlying
reason. It might be that the page migration failes repeatedly and the
userspace timeout expires and send a signal or it might be some of the
earlier steps (isolation, memory notifier) takes too long.

If the migration failes then it would be really helpful to see which
page that and its state. The same applies to the isolation phase. If we
fail to isolate a page from the allocator then knowing the state of the
page would be helpful as well.

Dump the page state that fails to get isolated or migrated. This will
tell us more about the failure and what to focus on during debugging.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 12 ++++++++----
 mm/page_alloc.c     |  1 +
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1badac89c58e..bf214beccda3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1388,10 +1388,8 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 						    page_is_file_cache(page));
 
 		} else {
-#ifdef CONFIG_DEBUG_VM
-			pr_alert("failed to isolate pfn %lx\n", pfn);
+			pr_warn("failed to isolate pfn %lx\n", pfn);
 			dump_page(page, "isolation failed");
-#endif
 			put_page(page);
 			/* Because we don't have big zone->lock. we should
 			   check this again here. */
@@ -1411,8 +1409,14 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		/* Allocate a new page from the nearest neighbor node */
 		ret = migrate_pages(&source, new_node_page, NULL, 0,
 					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
-		if (ret)
+		if (ret) {
+			list_for_each_entry(page, &source, lru) {
+				pr_warn("migrating pfn %lx failed ",
+				       page_to_pfn(page), ret);
+				dump_page(page, NULL);
+			}
 			putback_movable_pages(&source);
+		}
 	}
 out:
 	return ret;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a919ba5cb3c8..23267767bf98 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7845,6 +7845,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	return false;
 unmovable:
 	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
+	dump_page(pfn_to_page(pfn+iter), "has_unmovable_pages");
 	return true;
 }
 
-- 
2.19.1
