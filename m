Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 717186B0260
	for <linux-mm@kvack.org>; Mon,  9 May 2016 13:53:50 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id d66so153198845vkb.0
        for <linux-mm@kvack.org>; Mon, 09 May 2016 10:53:50 -0700 (PDT)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id y84si10176136qhc.114.2016.05.09.10.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 09 May 2016 10:53:49 -0700 (PDT)
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 9 May 2016 13:53:49 -0400
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH 3/3] memory-hotplug: use zone_can_shift() for sysfs valid_zones attribute
Date: Mon,  9 May 2016 12:53:39 -0500
Message-Id: <1462816419-4479-4-git-send-email-arbab@linux.vnet.ibm.com>
In-Reply-To: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Vrabel <david.vrabel@citrix.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Banman <abanman@sgi.com>, Chen Yucong <slaoub@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Reza Arbab <arbab@linux.vnet.ibm.com>

Since zone_can_shift() is being used to validate the target zone during
onlining, it should also be used to determine the content of valid_zones.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 drivers/base/memory.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 31e9c61..8e385ea 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -389,6 +389,7 @@ static ssize_t show_valid_zones(struct device *dev,
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
 	struct page *first_page;
 	struct zone *zone;
+	int zone_shift = 0;
 
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	end_pfn = start_pfn + nr_pages;
@@ -400,21 +401,26 @@ static ssize_t show_valid_zones(struct device *dev,
 
 	zone = page_zone(first_page);
 
-	if (zone_idx(zone) == ZONE_MOVABLE - 1) {
-		/*The mem block is the last memoryblock of this zone.*/
-		if (end_pfn == zone_end_pfn(zone))
-			return sprintf(buf, "%s %s\n",
-					zone->name, (zone + 1)->name);
+	/* MMOP_ONLINE_KEEP */
+	sprintf(buf, "%s", zone->name);
+
+	/* MMOP_ONLINE_KERNEL */
+	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_NORMAL);
+	if (zone_shift) {
+		strcat(buf, " ");
+		strcat(buf, (zone + zone_shift)->name);
 	}
 
-	if (zone_idx(zone) == ZONE_MOVABLE) {
-		/*The mem block is the first memoryblock of ZONE_MOVABLE.*/
-		if (start_pfn == zone->zone_start_pfn)
-			return sprintf(buf, "%s %s\n",
-					zone->name, (zone - 1)->name);
+	/* MMOP_ONLINE_MOVABLE */
+	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_MOVABLE);
+	if (zone_shift) {
+		strcat(buf, " ");
+		strcat(buf, (zone + zone_shift)->name);
 	}
 
-	return sprintf(buf, "%s\n", zone->name);
+	strcat(buf, "\n");
+
+	return strlen(buf);
 }
 static DEVICE_ATTR(valid_zones, 0444, show_valid_zones, NULL);
 #endif
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
