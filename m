Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70DAE6B1CA9
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 20:48:37 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 74so313666pfk.12
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 17:48:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c13-v6sor51445078pfc.26.2018.11.19.17.48.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 17:48:36 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Date: Tue, 20 Nov 2018 09:48:22 +0800
Message-Id: <20181120014822.27968-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, osalvador@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

After memory hot-added, users could online pages through sysfs, and this
could be done in parallel.

In case two threads online pages in two different empty zones at the
same time, there would be a contention to update the nr_zones.

The patch use pgdat_resize_lock() to protect this critical section.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e13987c2e1c4..525a5344a13b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5796,9 +5796,12 @@ void __meminit init_currently_empty_zone(struct zone *zone,
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int zone_idx = zone_idx(zone) + 1;
+	unsigned long flags;
 
+	pgdat_resize_lock(pgdat, &flags);
 	if (zone_idx > pgdat->nr_zones)
 		pgdat->nr_zones = zone_idx;
+	pgdat_resize_unlock(pgdat, &flags);
 
 	zone->zone_start_pfn = zone_start_pfn;
 
-- 
2.15.1
