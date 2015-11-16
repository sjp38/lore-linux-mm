Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 990C46B0259
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 01:52:48 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so165458619pac.3
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 22:52:48 -0800 (PST)
Received: from cmccmta3.chinamobile.com (cmccmta3.chinamobile.com. [221.176.66.81])
        by mx.google.com with ESMTP id pp8si48586726pbc.2.2015.11.15.22.52.46
        for <linux-mm@kvack.org>;
        Sun, 15 Nov 2015 22:52:47 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 7/7] mm/mmzone: refactor memmap_valid_within
Date: Mon, 16 Nov 2015 14:51:26 +0800
Message-Id: <1447656686-4851-8-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch makes memmap_valid_within return bool due to this
particular function only using either one or zero as its return
value.

This patch also refactors memmap_valid_within for simplicity.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/mmzone.h |  6 +++---
 mm/mmzone.c            | 10 ++--------
 2 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9963846..b9b59bb8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1202,13 +1202,13 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
  * the zone and PFN linkages are still valid. This is expensive, but walkers
  * of the full memmap are extremely rare.
  */
-int memmap_valid_within(unsigned long pfn,
+bool memmap_valid_within(unsigned long pfn,
 					struct page *page, struct zone *zone);
 #else
-static inline int memmap_valid_within(unsigned long pfn,
+static inline bool memmap_valid_within(unsigned long pfn,
 					struct page *page, struct zone *zone)
 {
-	return 1;
+	return true;
 }
 #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
 
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 7d87ebb..de0824e 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -72,16 +72,10 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
 }
 
 #ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
-int memmap_valid_within(unsigned long pfn,
+bool memmap_valid_within(unsigned long pfn,
 					struct page *page, struct zone *zone)
 {
-	if (page_to_pfn(page) != pfn)
-		return 0;
-
-	if (page_zone(page) != zone)
-		return 0;
-
-	return 1;
+	return page_to_pfn(page) == pfn && page_zone(page) == zone;
 }
 #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
 
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
