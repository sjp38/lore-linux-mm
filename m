Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 294956B553D
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 18:55:41 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 202so2337766pgb.6
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 15:55:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v12sor4859642pfd.68.2018.11.29.15.55.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 15:55:40 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v2] mm, show_mem: drop pgdat_resize_lock in show_mem()
Date: Fri, 30 Nov 2018 07:55:32 +0800
Message-Id: <20181129235532.9328-1-richard.weiyang@gmail.com>
In-Reply-To: <20181128210815.2134-1-richard.weiyang@gmail.com>
References: <20181128210815.2134-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org, jweiner@fb.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Function show_mem() is used to print system memory status when user
requires or fail to allocate memory. Generally, this is a best effort
information so any races with memory hotplug (or very theoretically an
early initialization) should be tolerable and the worst that could
happen is to print an imprecise node state.

Drop the resize lock because this is the only place which might hold the
lock from the interrupt context and so all other callers might use a
simple spinlock. Even though this doesn't solve any real issue it makes
the code easier to follow and tiny more effective.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

---
v2:
   * adjust the changelog to show the reason of this change
   * remove unused variable flags
---
 lib/show_mem.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/lib/show_mem.c b/lib/show_mem.c
index 0beaa1d899aa..f4e029e1ddec 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -18,10 +18,8 @@ void show_mem(unsigned int filter, nodemask_t *nodemask)
 	show_free_areas(filter, nodemask);
 
 	for_each_online_pgdat(pgdat) {
-		unsigned long flags;
 		int zoneid;
 
-		pgdat_resize_lock(pgdat, &flags);
 		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 			struct zone *zone = &pgdat->node_zones[zoneid];
 			if (!populated_zone(zone))
@@ -33,7 +31,6 @@ void show_mem(unsigned int filter, nodemask_t *nodemask)
 			if (is_highmem_idx(zoneid))
 				highmem += zone->present_pages;
 		}
-		pgdat_resize_unlock(pgdat, &flags);
 	}
 
 	printk("%lu pages RAM\n", total);
-- 
2.15.1
