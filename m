Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2EBF6B025E
	for <linux-mm@kvack.org>; Mon,  9 May 2016 13:53:49 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id u23so152762869vkb.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 10:53:49 -0700 (PDT)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id e123si19426864qhc.4.2016.05.09.10.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 09 May 2016 10:53:49 -0700 (PDT)
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 9 May 2016 11:53:48 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH 2/3] memory-hotplug: more general validation of zone during online
Date: Mon,  9 May 2016 12:53:38 -0500
Message-Id: <1462816419-4479-3-git-send-email-arbab@linux.vnet.ibm.com>
In-Reply-To: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Vrabel <david.vrabel@citrix.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Banman <abanman@sgi.com>, Chen Yucong <slaoub@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Reza Arbab <arbab@linux.vnet.ibm.com>

When memory is onlined, we are only able to rezone from ZONE_MOVABLE to
ZONE_KERNEL, or from (ZONE_MOVABLE - 1) to ZONE_MOVABLE.

To be more flexible, use the following criteria instead; to online memory
from zone X into zone Y,

* Any zones between X and Y must be unused.
* If X is lower than Y, the onlined memory must lie at the end of X.
* If X is higher than Y, the onlined memory must lie at the start of X.

Add zone_can_shift() to make this determination.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 include/linux/memory_hotplug.h |  2 ++
 mm/memory_hotplug.c            | 42 +++++++++++++++++++++++++++++++++++-------
 2 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index adbef58..7bff0f9 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -284,5 +284,7 @@ extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 		unsigned long map_offset);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
+extern int zone_can_shift(unsigned long pfn, unsigned long nr_pages,
+			  enum zone_type target);
 
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6b4b005..b63cc28 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1032,6 +1032,37 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 	node_set_state(node, N_MEMORY);
 }
 
+int zone_can_shift(unsigned long pfn, unsigned long nr_pages,
+		   enum zone_type target)
+{
+	struct zone *zone = page_zone(pfn_to_page(pfn));
+	enum zone_type idx = zone_idx(zone);
+	int i;
+
+	if (idx < target) {
+		/* pages must be at end of current zone */
+		if (pfn + nr_pages != zone_end_pfn(zone))
+			return 0;
+
+		/* no zones in use between current zone and target */
+		for (i = idx + 1; i < target; i++)
+			if (zone_is_initialized(zone - idx + i))
+				return 0;
+	}
+
+	if (target < idx) {
+		/* pages must be at beginning of current zone */
+		if (pfn != zone->zone_start_pfn)
+			return 0;
+
+		/* no zones in use between current zone and target */
+		for (i = target + 1; i < idx; i++)
+			if (zone_is_initialized(zone - idx + i))
+				return 0;
+	}
+
+	return target - idx;
+}
 
 /* Must be protected by mem_hotplug_begin() */
 int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
@@ -1057,13 +1088,10 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	    !can_online_high_movable(zone))
 		return -EINVAL;
 
-	if (online_type == MMOP_ONLINE_KERNEL &&
-	    zone_idx(zone) == ZONE_MOVABLE)
-		zone_shift = -1;
-
-	if (online_type == MMOP_ONLINE_MOVABLE &&
-	    zone_idx(zone) == ZONE_MOVABLE - 1)
-		zone_shift = 1;
+	if (online_type == MMOP_ONLINE_KERNEL)
+		zone_shift = zone_can_shift(pfn, nr_pages, ZONE_NORMAL);
+	else if (online_type == MMOP_ONLINE_MOVABLE)
+		zone_shift = zone_can_shift(pfn, nr_pages, ZONE_MOVABLE);
 
 	zone = move_pfn_range(zone_shift, pfn, pfn + nr_pages);
 	if (!zone)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
