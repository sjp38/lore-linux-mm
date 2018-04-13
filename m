Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B85C6B0011
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:17:00 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id j130so5247644qke.13
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:17:00 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t14si3707816qkj.5.2018.04.13.06.16.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 06:16:59 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 3/8] mm: use PG_offline in online/offlining code
Date: Fri, 13 Apr 2018 15:16:27 +0200
Message-Id: <20180413131632.1413-4-david@redhat.com>
In-Reply-To: <20180413131632.1413-1-david@redhat.com>
References: <20180413131632.1413-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Hildenbrand <david@redhat.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "open list:Hyper-V CORE AND DRIVERS" <devel@linuxdriverproject.org>, open list <linux-kernel@vger.kernel.org>

Let's mark all offline pages with PG_offline. We'll continue to mark
them reserved.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/hv/hv_balloon.c |  2 +-
 mm/memory_hotplug.c     | 10 ++++++----
 mm/page_alloc.c         |  5 ++++-
 3 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index b3e9f13f8bc3..04d98d9b6191 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -893,7 +893,7 @@ static unsigned long handle_pg_range(unsigned long pg_start,
 			 * backed previously) online too.
 			 */
 			if (start_pfn > has->start_pfn &&
-			    !PageReserved(pfn_to_page(start_pfn - 1)))
+			    !PageOffline(pfn_to_page(start_pfn - 1)))
 				hv_bring_pgs_online(has, start_pfn, pgs_ol);
 
 		}
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d4474781c799..3a8d56476233 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -260,8 +260,8 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 		return ret;
 
 	/*
-	 * Make all the pages reserved so that nobody will stumble over half
-	 * initialized state.
+	 * Make all the pages offline and reserved so that nobody will stumble
+	 * over half initialized state.
 	 * FIXME: We also have to associate it with a node because page_to_nid
 	 * relies on having page with the proper node.
 	 */
@@ -274,6 +274,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 		page = pfn_to_page(pfn);
 		set_page_node(page, nid);
 		SetPageReserved(page);
+		SetPageOffline(page);
 	}
 
 	if (!want_memblock)
@@ -669,6 +670,7 @@ EXPORT_SYMBOL_GPL(__online_page_increment_counters);
 
 void __online_page_free(struct page *page)
 {
+	ClearPageOffline(page);
 	__free_reserved_page(page);
 }
 EXPORT_SYMBOL_GPL(__online_page_free);
@@ -687,7 +689,7 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	unsigned long onlined_pages = *(unsigned long *)arg;
 	struct page *page;
 
-	if (PageReserved(pfn_to_page(start_pfn)))
+	if (PageOffline(pfn_to_page(start_pfn)))
 		for (i = 0; i < nr_pages; i++) {
 			page = pfn_to_page(start_pfn + i);
 			(*online_page_callback)(page);
@@ -1437,7 +1439,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 }
 
 /*
- * remove from free_area[] and mark all as Reserved.
+ * remove from free_area[] and mark all as Reserved and Offline.
  */
 static int
 offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 647c8c6dd4d1..2e5dcfdb0908 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8030,6 +8030,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		if (unlikely(!PageBuddy(page) && PageHWPoison(page))) {
 			pfn++;
 			SetPageReserved(page);
+			SetPageOffline(page);
 			continue;
 		}
 
@@ -8043,8 +8044,10 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		list_del(&page->lru);
 		rmv_page_order(page);
 		zone->free_area[order].nr_free--;
-		for (i = 0; i < (1 << order); i++)
+		for (i = 0; i < (1 << order); i++) {
 			SetPageReserved((page+i));
+			SetPageOffline(page + i);
+		}
 		pfn += (1 << order);
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
-- 
2.14.3
