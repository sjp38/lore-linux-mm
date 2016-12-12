Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37DB46B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 15:29:09 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 20so111446043uak.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 12:29:09 -0800 (PST)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id 37si11924546uac.26.2016.12.12.12.29.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 12:29:08 -0800 (PST)
Received: by mail-qk0-x241.google.com with SMTP id h201so12115273qke.3
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 12:29:08 -0800 (PST)
Subject: memory_hotplug: zone_can_shift() returns boolean value
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Message-ID: <8f85e530-4cc9-164b-ab44-6ebd78389c7b@gmail.com>
Date: Mon, 12 Dec 2016 15:29:04 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: isimatu.yasuaki@jp.fujitsu.com, arbab@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

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
is not onlined when memory zone cannot be changed.

Fixes: df429ac03936 ("memory-hotplug: more general validation of zone during online")
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Reza Arbab <arbab@linux.vnet.ibm.com>
---
  drivers/base/memory.c          |  6 ++----
  include/linux/memory_hotplug.h |  4 ++--
  mm/memory_hotplug.c            | 26 +++++++++++++++-----------
  3 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 62c63c0..5a94d5e 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -410,15 +410,13 @@ static ssize_t show_valid_zones(struct device *dev,
  	sprintf(buf, "%s", zone->name);

  	/* MMOP_ONLINE_KERNEL */
-	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_NORMAL);
-	if (zone_shift) {
+	if (zone_can_shift(start_pfn, nr_pages, ZONE_NORMAL, &zone_shift)) {
  		strcat(buf, " ");
  		strcat(buf, (zone + zone_shift)->name);
  	}

  	/* MMOP_ONLINE_MOVABLE */
-	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_MOVABLE);
-	if (zone_shift) {
+	if (zone_can_shift(start_pfn, nr_pages, ZONE_MOVABLE, &zone_shift)) {
  		strcat(buf, " ");
  		strcat(buf, (zone + zone_shift)->name);
  	}
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
index cad4b91..96f05e9 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1033,8 +1033,8 @@ static void node_states_set_node(int node, struct memory_notify *arg)
  	node_set_state(node, N_MEMORY);
  }

-int zone_can_shift(unsigned long pfn, unsigned long nr_pages,
-		   enum zone_type target)
+bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
+		   enum zone_type target, int *zone_shift)
  {
  	struct zone *zone = page_zone(pfn_to_page(pfn));
  	enum zone_type idx = zone_idx(zone);
@@ -1043,26 +1043,27 @@ int zone_can_shift(unsigned long pfn, unsigned long nr_pages,
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
@@ -1089,10 +1090,13 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
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
