Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36A55440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 08:14:57 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z81so11145287wrc.2
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:14:57 -0700 (PDT)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id 62si6210431wrh.283.2017.07.14.05.14.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 05:14:55 -0700 (PDT)
Received: by mail-wr0-f195.google.com with SMTP id k67so11555980wrc.1
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:14:55 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm, memory_hotplug: display allowed zones in the preferred ordering
Date: Fri, 14 Jul 2017 14:12:32 +0200
Message-Id: <20170714121233.16861-2-mhocko@kernel.org>
In-Reply-To: <20170714121233.16861-1-mhocko@kernel.org>
References: <20170714121233.16861-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Michal Hocko <mhocko@suse.com>

Prior to "mm, memory_hotplug: do not associate hotadded memory to zones
until online" we used to allow to change the valid zone types of a
memory block if it is adjacent to a different zone type. This fact was
reflected in memoryNN/valid_zones by the ordering of printed zones.
The first one was default (echo online > memoryNN/state) and the other
one could be onlined explicitly by online_{movable,kernel}. This
behavior was removed by the said patch and as such the ordering was
not all that important. In most cases a kernel zone would be default
anyway. The only exception is movable_node handled by "mm,
memory_hotplug: support movable_node for hotpluggable nodes".

Let's reintroduce this behavior again because later patch will remove
the zone overlap restriction and so user will be allowed to online
kernel resp. movable block regardless of its placement. Original
behavior will then become significant again because it would be
non-trivial for users to see what is the default zone to online into.

Implementation is really simple. Pull out zone selection out of
move_pfn_range into zone_for_pfn_range helper and use it in
show_valid_zones to display the zone for default onlining and then
both kernel and movable if they are allowed. Default online zone is not
duplicated.

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/base/memory.c          | 33 +++++++++++++------
 include/linux/memory_hotplug.h |  2 +-
 mm/memory_hotplug.c            | 73 ++++++++++++++++++++++++------------------
 3 files changed, 65 insertions(+), 43 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index c7c4e0325cdb..26383af9900c 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -388,6 +388,22 @@ static ssize_t show_phys_device(struct device *dev,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
+static void print_allowed_zone(char *buf, int nid, unsigned long start_pfn,
+		unsigned long nr_pages, int online_type,
+		struct zone *default_zone)
+{
+	struct zone *zone;
+
+	if (!allow_online_pfn_range(nid, start_pfn, nr_pages, online_type))
+		return;
+
+	zone = zone_for_pfn_range(online_type, nid, start_pfn, nr_pages);
+	if (zone != default_zone) {
+		strcat(buf, " ");
+		strcat(buf, zone->name);
+	}
+}
+
 static ssize_t show_valid_zones(struct device *dev,
 				struct device_attribute *attr, char *buf)
 {
@@ -395,7 +411,7 @@ static ssize_t show_valid_zones(struct device *dev,
 	unsigned long start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
 	unsigned long valid_start_pfn, valid_end_pfn;
-	bool append = false;
+	struct zone *default_zone;
 	int nid;
 
 	/*
@@ -418,16 +434,13 @@ static ssize_t show_valid_zones(struct device *dev,
 	}
 
 	nid = pfn_to_nid(start_pfn);
-	if (allow_online_pfn_range(nid, start_pfn, nr_pages, MMOP_ONLINE_KERNEL)) {
-		strcat(buf, default_zone_for_pfn(nid, start_pfn, nr_pages)->name);
-		append = true;
-	}
+	default_zone = zone_for_pfn_range(MMOP_ONLINE_KEEP, nid, start_pfn, nr_pages);
+	strcat(buf, default_zone->name);
 
-	if (allow_online_pfn_range(nid, start_pfn, nr_pages, MMOP_ONLINE_MOVABLE)) {
-		if (append)
-			strcat(buf, " ");
-		strcat(buf, NODE_DATA(nid)->node_zones[ZONE_MOVABLE].name);
-	}
+	print_allowed_zone(buf, nid, start_pfn, nr_pages, MMOP_ONLINE_KERNEL,
+			default_zone);
+	print_allowed_zone(buf, nid, start_pfn, nr_pages, MMOP_ONLINE_MOVABLE,
+			default_zone);
 out:
 	strcat(buf, "\n");
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index c8a5056a5ae0..5e6e4cc36ff4 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -319,6 +319,6 @@ extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
 		int online_type);
-extern struct zone *default_zone_for_pfn(int nid, unsigned long pfn,
+extern struct zone *zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
 		unsigned long nr_pages);
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d620d0427b6b..b4f2583677b1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -777,31 +777,6 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 	node_set_state(node, N_MEMORY);
 }
 
-bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages, int online_type)
-{
-	struct pglist_data *pgdat = NODE_DATA(nid);
-	struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
-	struct zone *default_zone = default_zone_for_pfn(nid, pfn, nr_pages);
-
-	/*
-	 * TODO there shouldn't be any inherent reason to have ZONE_NORMAL
-	 * physically before ZONE_MOVABLE. All we need is they do not
-	 * overlap. Historically we didn't allow ZONE_NORMAL after ZONE_MOVABLE
-	 * though so let's stick with it for simplicity for now.
-	 * TODO make sure we do not overlap with ZONE_DEVICE
-	 */
-	if (online_type == MMOP_ONLINE_KERNEL) {
-		if (zone_is_empty(movable_zone))
-			return true;
-		return movable_zone->zone_start_pfn >= pfn + nr_pages;
-	} else if (online_type == MMOP_ONLINE_MOVABLE) {
-		return zone_end_pfn(default_zone) <= pfn;
-	}
-
-	/* MMOP_ONLINE_KEEP will always succeed and inherits the current zone */
-	return online_type == MMOP_ONLINE_KEEP;
-}
-
 static void __meminit resize_zone_range(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages)
 {
@@ -860,7 +835,7 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
  * If no kernel zone covers this pfn range it will automatically go
  * to the ZONE_NORMAL.
  */
-struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
+static struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
 		unsigned long nr_pages)
 {
 	struct pglist_data *pgdat = NODE_DATA(nid);
@@ -876,6 +851,31 @@ struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
 	return &pgdat->node_zones[ZONE_NORMAL];
 }
 
+bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages, int online_type)
+{
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
+	struct zone *default_zone = default_zone_for_pfn(nid, pfn, nr_pages);
+
+	/*
+	 * TODO there shouldn't be any inherent reason to have ZONE_NORMAL
+	 * physically before ZONE_MOVABLE. All we need is they do not
+	 * overlap. Historically we didn't allow ZONE_NORMAL after ZONE_MOVABLE
+	 * though so let's stick with it for simplicity for now.
+	 * TODO make sure we do not overlap with ZONE_DEVICE
+	 */
+	if (online_type == MMOP_ONLINE_KERNEL) {
+		if (zone_is_empty(movable_zone))
+			return true;
+		return movable_zone->zone_start_pfn >= pfn + nr_pages;
+	} else if (online_type == MMOP_ONLINE_MOVABLE) {
+		return zone_end_pfn(default_zone) <= pfn;
+	}
+
+	/* MMOP_ONLINE_KEEP will always succeed and inherits the current zone */
+	return online_type == MMOP_ONLINE_KEEP;
+}
+
 static inline bool movable_pfn_range(int nid, struct zone *default_zone,
 		unsigned long start_pfn, unsigned long nr_pages)
 {
@@ -889,12 +889,8 @@ static inline bool movable_pfn_range(int nid, struct zone *default_zone,
 	return !zone_intersects(default_zone, start_pfn, nr_pages);
 }
 
-/*
- * Associates the given pfn range with the given node and the zone appropriate
- * for the given online type.
- */
-static struct zone * __meminit move_pfn_range(int online_type, int nid,
-		unsigned long start_pfn, unsigned long nr_pages)
+struct zone * zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
+		unsigned long nr_pages)
 {
 	struct pglist_data *pgdat = NODE_DATA(nid);
 	struct zone *zone = default_zone_for_pfn(nid, start_pfn, nr_pages);
@@ -913,6 +909,19 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
 		zone = &pgdat->node_zones[ZONE_MOVABLE];
 	}
 
+	return zone;
+}
+
+/*
+ * Associates the given pfn range with the given node and the zone appropriate
+ * for the given online type.
+ */
+static struct zone * __meminit move_pfn_range(int online_type, int nid,
+		unsigned long start_pfn, unsigned long nr_pages)
+{
+	struct zone *zone;
+
+	zone = zone_for_pfn_range(online_type, nid, start_pfn, nr_pages);
 	move_pfn_range_to_zone(zone, start_pfn, nr_pages);
 	return zone;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
