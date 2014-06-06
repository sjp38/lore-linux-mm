Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id D8C8F6B0037
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 01:32:46 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so2179845pbb.19
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 22:32:46 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id gn5si17223665pbb.200.2014.06.05.22.32.44
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 22:32:45 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 RESEND 2/2] mem-hotplug: Introduce MMOP_OFFLINE to replace the hard coding -1.
Date: Fri, 6 Jun 2014 13:33:49 +0800
Message-ID: <1402032829-18455-1-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <20140606051535.GC4454@G08FNSTD100614.fnst.cn.fujitsu.com>
References: <20140606051535.GC4454@G08FNSTD100614.fnst.cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hutao@cn.fujitsu.com
Cc: tangchen@cn.fujitsu.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, toshi.kani@hp.com, tj@kernel.org, hpa@zytor.com, mingo@elte.hu, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

In store_mem_state(), we have:
......
 334         else if (!strncmp(buf, "offline", min_t(int, count, 7)))
 335                 online_type = -1;
......
 355         case -1:
 356                 ret = device_offline(&mem->dev);
 357                 break;
......

Here, "offline" is hard coded as -1.

This patch does the following renaming:
 ONLINE_KEEP     ->  MMOP_ONLINE_KEEP
 ONLINE_KERNEL   ->  MMOP_ONLINE_KERNEL
 ONLINE_MOVABLE  ->  MMOP_ONLINE_MOVABLE

and introduce MMOP_OFFLINE = -1 to avoid hard coding.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 drivers/base/memory.c          | 18 +++++++++---------
 include/linux/memory_hotplug.h |  9 +++++----
 mm/memory_hotplug.c            |  9 ++++++---
 3 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index fa664b9..904442c 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -294,7 +294,7 @@ static int memory_subsys_online(struct device *dev)
 	 * attribute and need to set the online_type.
 	 */
 	if (mem->online_type < 0)
-		mem->online_type = ONLINE_KEEP;
+		mem->online_type = MMOP_ONLINE_KEEP;
 
 	ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE);
 
@@ -326,22 +326,22 @@ store_mem_state(struct device *dev,
 		return ret;
 
 	if (sysfs_streq(buf, "online_kernel"))
-		online_type = ONLINE_KERNEL;
+		online_type = MMOP_ONLINE_KERNEL;
 	else if (sysfs_streq(buf, "online_movable"))
-		online_type = ONLINE_MOVABLE;
+		online_type = MMOP_ONLINE_MOVABLE;
 	else if (sysfs_streq(buf, "online"))
-		online_type = ONLINE_KEEP;
+		online_type = MMOP_ONLINE_KEEP;
 	else if (sysfs_streq(buf, "offline"))
-		online_type = -1;
+		online_type = MMOP_OFFLINE;
 	else {
 		ret = -EINVAL;
 		goto err;
 	}
 
 	switch (online_type) {
-	case ONLINE_KERNEL:
-	case ONLINE_MOVABLE:
-	case ONLINE_KEEP:
+	case MMOP_ONLINE_KERNEL:
+	case MMOP_ONLINE_MOVABLE:
+	case MMOP_ONLINE_KEEP:
 		/*
 		 * mem->online_type is not protected so there can be a
 		 * race here.  However, when racing online, the first
@@ -352,7 +352,7 @@ store_mem_state(struct device *dev,
 		mem->online_type = online_type;
 		ret = device_online(&mem->dev);
 		break;
-	case -1:
+	case MMOP_OFFLINE:
 		ret = device_offline(&mem->dev);
 		break;
 	default:
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 4ca3d95..b4240cf 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -26,11 +26,12 @@ enum {
 	MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE = NODE_INFO,
 };
 
-/* Types for control the zone type of onlined memory */
+/* Types for control the zone type of onlined and offlined memory */
 enum {
-	ONLINE_KEEP,
-	ONLINE_KERNEL,
-	ONLINE_MOVABLE,
+	MMOP_OFFLINE = -1,
+	MMOP_ONLINE_KEEP,
+	MMOP_ONLINE_KERNEL,
+	MMOP_ONLINE_MOVABLE,
 };
 
 /*
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a650db2..6075f04 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -907,19 +907,22 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	 */
 	zone = page_zone(pfn_to_page(pfn));
 
-	if ((zone_idx(zone) > ZONE_NORMAL || online_type == ONLINE_MOVABLE) &&
+	if ((zone_idx(zone) > ZONE_NORMAL ||
+	     online_type == MMOP_ONLINE_MOVABLE) &&
 	    !can_online_high_movable(zone)) {
 		unlock_memory_hotplug();
 		return -EINVAL;
 	}
 
-	if (online_type == ONLINE_KERNEL && zone_idx(zone) == ZONE_MOVABLE) {
+	if (online_type == MMOP_ONLINE_KERNEL &&
+	    zone_idx(zone) == ZONE_MOVABLE) {
 		if (move_pfn_range_left(zone - 1, zone, pfn, pfn + nr_pages)) {
 			unlock_memory_hotplug();
 			return -EINVAL;
 		}
 	}
-	if (online_type == ONLINE_MOVABLE && zone_idx(zone) == ZONE_MOVABLE - 1) {
+	if (online_type == MMOP_ONLINE_MOVABLE &&
+	    zone_idx(zone) == ZONE_MOVABLE - 1) {
 		if (move_pfn_range_right(zone, zone + 1, pfn, pfn + nr_pages)) {
 			unlock_memory_hotplug();
 			return -EINVAL;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
