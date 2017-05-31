Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 664F06B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 02:26:12 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k30so943422wrc.9
        for <linux-mm@kvack.org>; Tue, 30 May 2017 23:26:12 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id b7si18121403wrd.314.2017.05.30.23.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 23:26:11 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id g15so1454610wmc.2
        for <linux-mm@kvack.org>; Tue, 30 May 2017 23:26:11 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm, memory_hotplug: do not assume ZONE_NORMAL is default kernel zone
Date: Wed, 31 May 2017 08:26:05 +0200
Message-Id: <20170531062605.4347-1-mhocko@kernel.org>
In-Reply-To: <20170531062439.GA3853@dhcp22.suse.cz>
References: <20170531062439.GA3853@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Heiko Carstens has noticed that he can generate overlapping zones for
ZONE_DMA and ZONE_NORMAL:
DMA      [mem 0x0000000000000000-0x000000007fffffff]
Normal   [mem 0x0000000080000000-0x000000017fffffff]

$ cat /sys/devices/system/memory/block_size_bytes
10000000
$ cat /sys/devices/system/memory/memory5/valid_zones
DMA
$ echo 0 > /sys/devices/system/memory/memory5/online
$ cat /sys/devices/system/memory/memory5/valid_zones
Normal
$ echo 1 > /sys/devices/system/memory/memory5/online
Normal

$ cat /proc/zoneinfo
Node 0, zone      DMA
spanned  524288        <-----
present  458752
managed  455078
start_pfn:           0 <-----

Node 0, zone   Normal
spanned  720896
present  589824
managed  571648
start_pfn:           327680 <-----

The reason is that we assume that the default zone for kernel onlining
is ZONE_NORMAL. This was a simplification introduced by the memory
hotplug rework and it is easily fixable by checking the range overlap in
the zone order and considering the first matching zone as the default
one. If there is no such zone then assume ZONE_NORMAL as we have been
doing so far.

Fixes: "mm, memory_hotplug: do not associate hotadded memory to zones until online"
Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/base/memory.c          |  2 +-
 include/linux/memory_hotplug.h |  2 ++
 mm/memory_hotplug.c            | 27 ++++++++++++++++++++++++---
 3 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index b86fda30ce62..c7c4e0325cdb 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -419,7 +419,7 @@ static ssize_t show_valid_zones(struct device *dev,
 
 	nid = pfn_to_nid(start_pfn);
 	if (allow_online_pfn_range(nid, start_pfn, nr_pages, MMOP_ONLINE_KERNEL)) {
-		strcat(buf, NODE_DATA(nid)->node_zones[ZONE_NORMAL].name);
+		strcat(buf, default_zone_for_pfn(nid, start_pfn, nr_pages)->name);
 		append = true;
 	}
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 9e0249d0f5e4..ed167541e4fc 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -309,4 +309,6 @@ extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
 		int online_type);
+extern struct zone *default_zone_for_pfn(int nid, unsigned long pfn,
+		unsigned long nr_pages);
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b3895fd609f4..a0348de3e18c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -858,7 +858,7 @@ bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
 {
 	struct pglist_data *pgdat = NODE_DATA(nid);
 	struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
-	struct zone *normal_zone =  &pgdat->node_zones[ZONE_NORMAL];
+	struct zone *default_zone = default_zone_for_pfn(nid, pfn, nr_pages);
 
 	/*
 	 * TODO there shouldn't be any inherent reason to have ZONE_NORMAL
@@ -872,7 +872,7 @@ bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
 			return true;
 		return movable_zone->zone_start_pfn >= pfn + nr_pages;
 	} else if (online_type == MMOP_ONLINE_MOVABLE) {
-		return zone_end_pfn(normal_zone) <= pfn;
+		return zone_end_pfn(default_zone) <= pfn;
 	}
 
 	/* MMOP_ONLINE_KEEP will always succeed and inherits the current zone */
@@ -938,6 +938,27 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
 }
 
 /*
+ * Returns a default kernel memory zone for the given pfn range.
+ * If no kernel zone covers this pfn range it will automatically go
+ * to the ZONE_NORMAL.
+ */
+struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
+		unsigned long nr_pages)
+{
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	int zid;
+
+	for (zid = 0; zid <= ZONE_NORMAL; zid++) {
+		struct zone *zone = &pgdat->node_zones[zid];
+
+		if (zone_intersects(zone, start_pfn, nr_pages))
+			return zone;
+	}
+
+	return &pgdat->node_zones[ZONE_NORMAL];
+}
+
+/*
  * Associates the given pfn range with the given node and the zone appropriate
  * for the given online type.
  */
@@ -945,7 +966,7 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
 		unsigned long start_pfn, unsigned long nr_pages)
 {
 	struct pglist_data *pgdat = NODE_DATA(nid);
-	struct zone *zone = &pgdat->node_zones[ZONE_NORMAL];
+	struct zone *zone = default_zone_for_pfn(nid, start_pfn, nr_pages);
 
 	if (online_type == MMOP_ONLINE_KEEP) {
 		struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
