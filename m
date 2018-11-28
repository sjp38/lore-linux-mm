Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4E536B4EF4
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 16:08:29 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id l131so12919317pga.2
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 13:08:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8sor10906018plo.55.2018.11.28.13.08.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Nov 2018 13:08:28 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, show_mem: drop pgdat_resize_lock in show_mem()
Date: Thu, 29 Nov 2018 05:08:15 +0800
Message-Id: <20181128210815.2134-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org, jweiner@fb.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Function show_mem() is used to print system memory status when user
requires or fail to allocate memory. Generally, this is a best effort
information and not willing to affect core mm subsystem.

The data protected by pgdat_resize_lock is mostly correct except there is:

   * page struct defer init
   * memory hotplug

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 lib/show_mem.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/lib/show_mem.c b/lib/show_mem.c
index 0beaa1d899aa..1d996e5771ab 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -21,7 +21,6 @@ void show_mem(unsigned int filter, nodemask_t *nodemask)
 		unsigned long flags;
 		int zoneid;
 
-		pgdat_resize_lock(pgdat, &flags);
 		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 			struct zone *zone = &pgdat->node_zones[zoneid];
 			if (!populated_zone(zone))
@@ -33,7 +32,6 @@ void show_mem(unsigned int filter, nodemask_t *nodemask)
 			if (is_highmem_idx(zoneid))
 				highmem += zone->present_pages;
 		}
-		pgdat_resize_unlock(pgdat, &flags);
 	}
 
 	printk("%lu pages RAM\n", total);
-- 
2.15.1
