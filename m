Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C90266B0008
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 14:05:04 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id q5so5450456pll.17
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 11:05:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a26sor1620310pff.143.2018.02.24.11.05.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Feb 2018 11:05:03 -0800 (PST)
From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 1/2] slab: add flag to block merging of UAPI elements
Date: Sat, 24 Feb 2018 11:04:53 -0800
Message-Id: <20180224190454.23716-2-sthemmin@microsoft.com>
In-Reply-To: <20180224190454.23716-1-sthemmin@microsoft.com>
References: <20180224190454.23716-1-sthemmin@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net, willy@infradead.org
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, ikomyagin@gmail.com, Stephen Hemminger <sthemmin@microsoft.com>, Stephen Hemminger <stephen@networkplumber.org>

The iproute2 program ss reads /proc/slabinfo to get TCP socket
statistics; therefore those kmem cache's can not be merged.
This patch adds a new flag to block merging in these kind
of cases.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 include/linux/slab.h | 6 ++++++
 mm/slab_common.c     | 2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 231abc8976c5..867acc2ddcbc 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -108,6 +108,12 @@
 #define SLAB_KASAN		0
 #endif
 
+/*
+ * Some old applications may want to read/write particular slab cache
+ * by name and therefore this can not be merged.
+ */
+#define SLAB_VISIBLE_UAPI	0x10000000UL
+
 /* The following flags affect the page allocator grouping pages by mobility */
 /* Objects are reclaimable */
 #define SLAB_RECLAIM_ACCOUNT	((slab_flags_t __force)0x00020000U)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 10f127b2de7c..71eb5fc63cf8 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -49,7 +49,7 @@ static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
  */
 #define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
 		SLAB_TRACE | SLAB_TYPESAFE_BY_RCU | SLAB_NOLEAKTRACE | \
-		SLAB_FAILSLAB | SLAB_KASAN)
+		SLAB_FAILSLAB | SLAB_KASAN | SLAB_VISIBLE_UAPI)
 
 #define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | \
 			 SLAB_ACCOUNT)
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
