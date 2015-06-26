Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 246666B006C
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 22:39:26 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so65430487pdj.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 19:39:25 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id qr9si46943883pbc.92.2015.06.25.19.39.24
        for <linux-mm@kvack.org>;
        Thu, 25 Jun 2015 19:39:25 -0700 (PDT)
From: sh.yoon@lge.com
Subject: [PATCH] mm: Make zone_reclaim() return ZONE_RECLAIM_NOSCAN not zero
Date: Fri, 26 Jun 2015 11:39:08 +0900
Message-Id: <1435286348-26366-1-git-send-email-sh.yoon@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: seungho1.park@lge.com, "sh.yoon" <sh.yoon@lge.com>

From: "sh.yoon" <sh.yoon@lge.com>

When zone watermark is not ok in get_page_from_freelist(), we call
zone_reclaim(). But !CONFIG_NUMA system`s zone_reclaim() just returns zero.
Zero means ZONE_RECLAIM_SOME and check zone watermark again needlessly.

To avoid needless zone watermark check, change it as ZONE_RECLAIM_NOSCAN.

Signed-off-by: sh.yoon <sh.yoon@lge.com>
---
 include/linux/swap.h | 7 ++++++-
 mm/internal.h        | 5 -----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3887472..e04e435 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -332,6 +332,11 @@ extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
 
+#define ZONE_RECLAIM_NOSCAN	-2
+#define ZONE_RECLAIM_FULL	-1
+#define ZONE_RECLAIM_SOME	0
+#define ZONE_RECLAIM_SUCCESS	1
+
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
@@ -341,7 +346,7 @@ extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
 #define zone_reclaim_mode 0
 static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
 {
-	return 0;
+	return ZONE_RECLAIM_NOSCAN;
 }
 #endif
 
diff --git a/mm/internal.h b/mm/internal.h
index a25e359..d8ec7f8 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -397,11 +397,6 @@ static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
 }
 #endif /* CONFIG_SPARSEMEM */
 
-#define ZONE_RECLAIM_NOSCAN	-2
-#define ZONE_RECLAIM_FULL	-1
-#define ZONE_RECLAIM_SOME	0
-#define ZONE_RECLAIM_SUCCESS	1
-
 extern int hwpoison_filter(struct page *p);
 
 extern u32 hwpoison_filter_dev_major;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
