Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 271686B0269
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 20:40:10 -0500 (EST)
Received: by obbbj7 with SMTP id bj7so22120177obb.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 17:40:10 -0800 (PST)
Received: from cmccmta2.chinamobile.com (cmccmta2.chinamobile.com. [221.176.66.80])
        by mx.google.com with ESMTP id s83si212322oia.49.2015.11.17.17.40.08
        for <linux-mm@kvack.org>;
        Tue, 17 Nov 2015 17:40:09 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH] mm/mmzone: memmap_valid_within can be boolean
Date: Wed, 18 Nov 2015 09:38:20 +0800
Message-Id: <1447810700-2535-1-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch makes memmap_valid_within return bool due to this
particular function only using either one or zero as its return
value.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/mmzone.h | 6 +++---
 mm/mmzone.c            | 8 ++++----
 2 files changed, 7 insertions(+), 7 deletions(-)

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
index 7d87ebb..52687fb 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -72,16 +72,16 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
 }
 
 #ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
-int memmap_valid_within(unsigned long pfn,
+bool memmap_valid_within(unsigned long pfn,
 					struct page *page, struct zone *zone)
 {
 	if (page_to_pfn(page) != pfn)
-		return 0;
+		return false;
 
 	if (page_zone(page) != zone)
-		return 0;
+		return false;
 
-	return 1;
+	return true;
 }
 #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
 
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
