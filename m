Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 981216B0088
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 03:26:26 -0400 (EDT)
Received: by oiga141 with SMTP id a141so2192848oig.13
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 00:26:26 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id 70si12811655oic.2.2015.03.10.00.26.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Mar 2015 00:26:25 -0700 (PDT)
Message-ID: <54FE9C21.8060107@huawei.com>
Date: Tue, 10 Mar 2015 15:24:17 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: refactor zone_movable_is_highmem()
References: <1425972055-53804-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1425972055-53804-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, iamjoonsoo.kim@lge.com
Cc: David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>

All callers of zone_movable_is_highmem are under #ifdef CONFIG_HIGHMEM,
so the else branch return 0 is not needed.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 include/linux/mmzone.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f279d9c..218f892 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -843,16 +843,16 @@ static inline int populated_zone(struct zone *zone)

 extern int movable_zone;

+#ifdef CONFIG_HIGHMEM
 static inline int zone_movable_is_highmem(void)
 {
-#if defined(CONFIG_HIGHMEM) && defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	return movable_zone == ZONE_HIGHMEM;
-#elif defined(CONFIG_HIGHMEM)
-	return (ZONE_MOVABLE - 1) == ZONE_HIGHMEM;
 #else
-	return 0;
+	return (ZONE_MOVABLE - 1) == ZONE_HIGHMEM;
 #endif
 }
+#endif

 static inline int is_highmem_idx(enum zone_type idx)
 {
-- 
1.8.5.5


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
