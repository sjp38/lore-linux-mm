Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E5B6F6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 07:18:53 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so80459pdj.2
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 04:18:51 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id gt3si8532734pbc.219.2014.08.27.04.18.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 04:18:41 -0700 (PDT)
Message-ID: <53FDBDF0.5000200@huawei.com>
Date: Wed, 27 Aug 2014 19:16:00 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] memory-hotplug: fix not enough check of valid zones
References: <1409124238-18635-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1409124238-18635-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>
Cc: wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

As Yasuaki Ishimatsu described the check here is not enough
if memory has hole as follows:

PFN       0x00          0xd0          0xe0          0xf0
             +-------------+-------------+-------------+
zone type   |   Normal    |     hole    |   Normal    |
             +-------------+-------------+-------------+
In this case, the check can't guarantee that this is "the last
block of memory".
The check of ZONE_MOVABLE has the same problem.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 drivers/base/memory.c | 36 ++++++------------------------------
 1 file changed, 6 insertions(+), 30 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index ccaf37c..0fc1d25 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -374,20 +374,6 @@ static ssize_t show_phys_device(struct device *dev,
 }

 #ifdef CONFIG_MEMORY_HOTREMOVE
-static int __zones_online_to(unsigned long end_pfn,
-				struct page *first_page, unsigned long nr_pages)
-{
-	struct zone *zone_next;
-
-	/* The mem block is the last block of memory. */
-	if (!pfn_valid(end_pfn + 1))
-		return 1;
-	zone_next = page_zone(first_page + nr_pages);
-	if (zone_idx(zone_next) == ZONE_MOVABLE)
-		return 1;
-	return 0;
-}
-
 static ssize_t show_zones_online_to(struct device *dev,
 				struct device_attribute *attr, char *buf)
 {
@@ -407,28 +393,18 @@ static ssize_t show_zones_online_to(struct device *dev,

 	zone = page_zone(first_page);

-#ifdef CONFIG_HIGHMEM
-	if (zone_idx(zone) == ZONE_HIGHMEM) {
-		if (__zones_online_to(end_pfn, first_page, nr_pages))
+	if (zone_idx(zone) == ZONE_MOVABLE - 1) {
+		/*The mem block is the last memoryblock of this zone.*/
+		if (end_pfn == zone_end_pfn(zone))
 			return sprintf(buf, "%s %s\n",
 					zone->name, (zone + 1)->name);
 	}
-#else
-	if (zone_idx(zone) == ZONE_NORMAL) {
-		if (__zones_online_to(end_pfn, first_page, nr_pages))
-			return sprintf(buf, "%s %s\n",
-					zone->name, (zone + 1)->name);
-	}
-#endif

 	if (zone_idx(zone) == ZONE_MOVABLE) {
-		if (!pfn_valid(start_pfn - nr_pages))
-			return sprintf(buf, "%s %s\n",
-						zone->name, (zone - 1)->name);
-		zone_prev = page_zone(first_page - nr_pages);
-		if (zone_idx(zone_prev) != ZONE_MOVABLE)
+		/*The mem block is the first memoryblock of ZONE_MOVABLE.*/
+		if (start_pfn == zone->zone_start_pfn)
 			return sprintf(buf, "%s %s\n",
-						zone->name, (zone - 1)->name);
+					zone->name, (zone - 1)->name);
 	}

 	return sprintf(buf, "%s\n", zone->name);
-- 
1.8.1.4


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
