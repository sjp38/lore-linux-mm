Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3EE538E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:02:40 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 82so5446100pfs.20
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:02:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5sor40224028pgq.34.2018.12.21.09.02.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 09:02:38 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v3] mm: remove extra drain pages on pcp list
Date: Sat, 22 Dec 2018 01:02:28 +0800
Message-Id: <20181221170228.10686-1-richard.weiyang@gmail.com>
In-Reply-To: <20181218204656.4297-1-richard.weiyang@gmail.com>
References: <20181218204656.4297-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de, david@redhat.com, Wei Yang <richard.weiyang@gmail.com>

In current implementation, there are two places to isolate a range of
page: __offline_pages() and alloc_contig_range(). During this procedure,
it will drain pages on pcp list.

Below is a brief call flow:

  __offline_pages()/alloc_contig_range()
      start_isolate_page_range()
          set_migratetype_isolate()
              drain_all_pages()
      drain_all_pages()                 <--- A

>From this snippet we can see current logic is isolate and drain pcp list
for each pageblock and drain pcp list again for the whole range.

While the drain at A is not necessary. The reason is
start_isolate_page_range() will set the migrate type of a range to
MIGRATE_ISOLATE. After doing so, this range will never be allocated from
Buddy, neither to a real user nor to pcp list. This means the procedure
to drain pages on pcp list after start_isolate_page_range() will not
drain any page in the target range.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

---
v3:
  * it is not proper to rely on caller to drain pages, so keep to drain
    pages during iteration and remove the one in callers.
v2: adjust changelog with MIGRATE_ISOLATE effects for the isolated range
---
 mm/memory_hotplug.c | 1 -
 mm/page_alloc.c     | 1 -
 2 files changed, 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6910e0eea074..d2fa6cbbb2db 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1599,7 +1599,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	cond_resched();
 	lru_add_drain_all();
-	drain_all_pages(zone);
 
 	pfn = scan_movable_pages(start_pfn, end_pfn);
 	if (pfn) { /* We have movable pages */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f1edd36a1e2b..d9ee4bb3a1a7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8041,7 +8041,6 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 */
 
 	lru_add_drain_all();
-	drain_all_pages(cc.zone);
 
 	order = 0;
 	outer_start = start;
-- 
2.15.1
