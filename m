Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 507886B73AD
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:46:50 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s22so10799565pgv.8
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:46:50 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q8si18188276pgc.580.2018.12.05.01.46.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 01:46:48 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.14 65/69] mm/page_alloc.c: fix calculation of pgdat->nr_zones
Date: Wed,  5 Dec 2018 04:42:43 -0500
Message-Id: <20181205094247.6556-65-sashal@kernel.org>
In-Reply-To: <20181205094247.6556-1-sashal@kernel.org>
References: <20181205094247.6556-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Wei Yang <richard.weiyang@gmail.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Wei Yang <richard.weiyang@gmail.com>

[ Upstream commit 8f416836c0d50b198cad1225132e5abebf8980dc ]

init_currently_empty_zone() will adjust pgdat->nr_zones and set it to
'zone_idx(zone) + 1' unconditionally.  This is correct in the normal
case, while not exact in hot-plug situation.

This function is used in two places:

  * free_area_init_core()
  * move_pfn_range_to_zone()

In the first case, we are sure zone index increase monotonically.  While
in the second one, this is under users control.

One way to reproduce this is:
----------------------------

1. create a virtual machine with empty node1

   -m 4G,slots=32,maxmem=32G \
   -smp 4,maxcpus=8          \
   -numa node,nodeid=0,mem=4G,cpus=0-3 \
   -numa node,nodeid=1,mem=0G,cpus=4-7

2. hot-add cpu 3-7

   cpu-add [3-7]

2. hot-add memory to nod1

   object_add memory-backend-ram,id=ram0,size=1G
   device_add pc-dimm,id=dimm0,memdev=ram0,node=1

3. online memory with following order

   echo online_movable > memory47/state
   echo online > memory40/state

After this, node1 will have its nr_zones equals to (ZONE_NORMAL + 1)
instead of (ZONE_MOVABLE + 1).

Michal said:
 "Having an incorrect nr_zones might result in all sorts of problems
  which would be quite hard to debug (e.g. reclaim not considering the
  movable zone). I do not expect many users would suffer from this it
  but still this is trivial and obviously right thing to do so
  backporting to the stable tree shouldn't be harmful (last famous
  words)"

Link: http://lkml.kernel.org/r/20181117022022.9956-1-richard.weiyang@gmail.com
Fixes: f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded memory to zones until online")
Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_alloc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2074f424dabf..86a5cab8b5dc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5554,8 +5554,10 @@ void __meminit init_currently_empty_zone(struct zone *zone,
 					unsigned long size)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
+	int zone_idx = zone_idx(zone) + 1;
 
-	pgdat->nr_zones = zone_idx(zone) + 1;
+	if (zone_idx > pgdat->nr_zones)
+		pgdat->nr_zones = zone_idx;
 
 	zone->zone_start_pfn = zone_start_pfn;
 
-- 
2.17.1
