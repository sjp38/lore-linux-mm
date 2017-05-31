Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC846B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 02:25:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 204so992757wmy.1
        for <linux-mm@kvack.org>; Tue, 30 May 2017 23:25:56 -0700 (PDT)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id 68si17296507wra.23.2017.05.30.23.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 23:25:55 -0700 (PDT)
Received: by mail-wr0-f196.google.com with SMTP id 6so561124wrb.1
        for <linux-mm@kvack.org>; Tue, 30 May 2017 23:25:55 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm, memory_hotplug: fix MMOP_ONLINE_KEEP behavior
Date: Wed, 31 May 2017 08:25:45 +0200
Message-Id: <20170531062545.4122-1-mhocko@kernel.org>
In-Reply-To: <20170531062439.GA3853@dhcp22.suse.cz>
References: <20170531062439.GA3853@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Heiko Carstens has noticed that the MMOP_ONLINE_KEEP is broken currently
$ grep . memory3?/valid_zones
memory34/valid_zones:Normal Movable
memory35/valid_zones:Normal Movable
memory36/valid_zones:Normal Movable
memory37/valid_zones:Normal Movable

$ echo online_movable > memory34/state
$ grep . memory3?/valid_zones
memory34/valid_zones:Movable
memory35/valid_zones:Movable
memory36/valid_zones:Movable
memory37/valid_zones:Movable

$ echo online > memory36/state
$ grep . memory3?/valid_zones
memory34/valid_zones:Movable
memory36/valid_zones:Normal
memory37/valid_zones:Movable

so we have effectivelly punched a hole into the movable zone. The
problem is that move_pfn_range() check for MMOP_ONLINE_KEEP is wrong.
It only checks whether the given range is already part of the movable
zone which is not the case here as only memory34 is in the zone. Fix
this by using allow_online_pfn_range(..., MMOP_ONLINE_KERNEL) if that
is false then we can be sure that movable onlining is the right thing to
do.

Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Fixes: "mm, memory_hotplug: do not associate hotadded memory to zones until online"
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0a895df2397e..b3895fd609f4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -950,11 +950,12 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
 	if (online_type == MMOP_ONLINE_KEEP) {
 		struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
 		/*
-		 * MMOP_ONLINE_KEEP inherits the current zone which is
-		 * ZONE_NORMAL by default but we might be within ZONE_MOVABLE
-		 * already.
+		 * MMOP_ONLINE_KEEP defaults to MMOP_ONLINE_KERNEL but use
+		 * movable zone if that is not possible (e.g. we are within
+		 * or past the existing movable zone)
 		 */
-		if (zone_intersects(movable_zone, start_pfn, nr_pages))
+		if (!allow_online_pfn_range(nid, start_pfn, nr_pages,
+					MMOP_ONLINE_KERNEL))
 			zone = movable_zone;
 	} else if (online_type == MMOP_ONLINE_MOVABLE) {
 		zone = &pgdat->node_zones[ZONE_MOVABLE];
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
