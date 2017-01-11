Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A803E6B0266
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:48:17 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id d75so114053825qkc.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:48:17 -0800 (PST)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id v5si4124053qki.308.2017.01.11.08.48.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 08:48:16 -0800 (PST)
Received: by mail-qt0-x243.google.com with SMTP id n13so12940477qtc.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:48:16 -0800 (PST)
Subject: [PATCH v3] memory_hotplug: zone_can_shift() returns boolean value
References: <2f9c3837-33d7-b6e5-59c0-6ca4372b2d84@gmail.com>
 <20170109152703.4dd336106200d55d8f4deafb@linux-foundation.org>
 <53c25651-026f-898a-7204-c164528ab4e6@gmail.com>
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Message-ID: <02923677-0fe4-1969-394e-bda34471910e@gmail.com>
Date: Wed, 11 Jan 2017 11:48:08 -0500
MIME-Version: 1.0
In-Reply-To: <53c25651-026f-898a-7204-c164528ab4e6@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, Reza Arbab <arbab@linux.vnet.ibm.com>

online_{kernel|movable} is used to change the memory zone to
ZONE_{NORMAL|MOVABLE} and online the memory.

To check that memory zone can be changed, zone_can_shift() is used.
Currently the function returns minus integer value, plus integer
value and 0. When the function returns minus or plus integer value,
it means that the memory zone can be changed to ZONE_{NORNAL|MOVABLE}.

But when the function returns 0, there is 2 meanings.

One of the meanings is that the memory zone does not need to be changed.
For example, when memory is in ZONE_NORMAL and onlined by online_kernel
the memory zone does not need to be changed.

Another meaning is that the memory zone cannot be changed. When memory
is in ZONE_NORMAL and onlined by online_movable, the memory zone may
not be changed to ZONE_MOVALBE due to memory online limitation(see
Documentation/memory-hotplug.txt). In this case, memory must not be
onlined.

The patch changes the return type of zone_can_shift() so that memory
online operation fails when memory zone cannot be changed as follows:

Before applying patch:
   # grep -A 35 "Node 2" /proc/zoneinfo
   Node 2, zone   Normal
   <snip>
      node_scanned  0
           spanned  8388608
           present  7864320
           managed  7864320
   # echo online_movable > memory4097/state
   # grep -A 35 "Node 2" /proc/zoneinfo
   Node 2, zone   Normal
   <snip>
      node_scanned  0
           spanned  8388608
           present  8388608
           managed  8388608

   online_movable operation succeeded. But memory is onlined as
   ZONE_NORMAL, not ZONE_MOVABLE.

After applying patch:
   # grep -A 35 "Node 2" /proc/zoneinfo
   Node 2, zone   Normal
   <snip>
      node_scanned  0
           spanned  8388608
           present  7864320
           managed  7864320
   # echo online_movable > memory4097/state
   bash: echo: write error: Invalid argument
   # grep -A 35 "Node 2" /proc/zoneinfo
   Node 2, zone   Normal
   <snip>
      node_scanned  0
           spanned  8388608
           present  7864320
           managed  7864320

   online_movable operation failed because of failure of changing
   the memory zone from ZONE_NORMAL to ZONE_MOVABLE

Fixes: df429ac03936 ("memory-hotplug: more general validation of zone during online")
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Reviewed-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
from v2:
  - Add the user-visible runtime effects of this fix

from v1:
  - Initialize zone_shift argument in zone_can_shift() to 0
  - Fix duplicate output of valid_zones

  drivers/base/memory.c          |  4 ++--
  include/linux/memory_hotplug.h |  4 ++--
  mm/memory_hotplug.c            | 28 +++++++++++++++++-----------
  3 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index bb69e58..3f47d94 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -408,14 +408,14 @@ static ssize_t show_valid_zones(struct device *dev,
  	sprintf(buf, "%s", zone->name);

  	/* MMOP_ONLINE_KERNEL */
-	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_NORMAL);
+	zone_can_shift(start_pfn, nr_pages, ZONE_NORMAL, &zone_shift);
  	if (zone_shift) {
  		strcat(buf, " ");
  		strcat(buf, (zone + zone_shift)->name);
  	}

  	/* MMOP_ONLINE_MOVABLE */
-	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_MOVABLE);
+	zone_can_shift(start_pfn, nr_pages, ZONE_MOVABLE, &zone_shift);
  	if (zone_shift) {
  		strcat(buf, " ");
  		strcat(buf, (zone + zone_shift)->name);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 01033fa..c1784c0 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -284,7 +284,7 @@ extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
  		unsigned long map_offset);
  extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
  					  unsigned long pnum);
-extern int zone_can_shift(unsigned long pfn, unsigned long nr_pages,
-			  enum zone_type target);
+extern bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
+			  enum zone_type target, int *zone_shift);

  #endif /* __LINUX_MEMORY_HOTPLUG_H */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9847e4a..d6dd65c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1034,36 +1034,39 @@ static void node_states_set_node(int node, struct memory_notify *arg)
  	node_set_state(node, N_MEMORY);
  }

-int zone_can_shift(unsigned long pfn, unsigned long nr_pages,
-		   enum zone_type target)
+bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
+		   enum zone_type target, int *zone_shift)
  {
  	struct zone *zone = page_zone(pfn_to_page(pfn));
  	enum zone_type idx = zone_idx(zone);
  	int i;

+	*zone_shift = 0;
+
  	if (idx < target) {
  		/* pages must be at end of current zone */
  		if (pfn + nr_pages != zone_end_pfn(zone))
-			return 0;
+			return false;

  		/* no zones in use between current zone and target */
  		for (i = idx + 1; i < target; i++)
  			if (zone_is_initialized(zone - idx + i))
-				return 0;
+				return false;
  	}

  	if (target < idx) {
  		/* pages must be at beginning of current zone */
  		if (pfn != zone->zone_start_pfn)
-			return 0;
+			return false;

  		/* no zones in use between current zone and target */
  		for (i = target + 1; i < idx; i++)
  			if (zone_is_initialized(zone - idx + i))
-				return 0;
+				return false;
  	}

-	return target - idx;
+	*zone_shift = target - idx;
+	return true;
  }

  /* Must be protected by mem_hotplug_begin() */
@@ -1090,10 +1093,13 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
  	    !can_online_high_movable(zone))
  		return -EINVAL;

-	if (online_type == MMOP_ONLINE_KERNEL)
-		zone_shift = zone_can_shift(pfn, nr_pages, ZONE_NORMAL);
-	else if (online_type == MMOP_ONLINE_MOVABLE)
-		zone_shift = zone_can_shift(pfn, nr_pages, ZONE_MOVABLE);
+	if (online_type == MMOP_ONLINE_KERNEL) {
+		if (!zone_can_shift(pfn, nr_pages, ZONE_NORMAL, &zone_shift))
+			return -EINVAL;
+	} else if (online_type == MMOP_ONLINE_MOVABLE) {
+		if (!zone_can_shift(pfn, nr_pages, ZONE_MOVABLE, &zone_shift))
+			return -EINVAL;
+	}

  	zone = move_pfn_range(zone_shift, pfn, pfn + nr_pages);
  	if (!zone)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
