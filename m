Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id E90CA6B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 22:32:21 -0400 (EDT)
Received: by iecvh10 with SMTP id vh10so86484448iec.3
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 19:32:21 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id q142si29283268ioe.75.2015.06.26.19.32.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 19:32:21 -0700 (PDT)
Message-ID: <558E0948.2010104@huawei.com>
Date: Sat, 27 Jun 2015 10:24:08 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC v2 PATCH 2/8] mm: introduce MIGRATE_MIRROR to manage the mirrored
 pages
References: <558E084A.60900@huawei.com>
In-Reply-To: <558E084A.60900@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This patch introduces a new migratetype called "MIGRATE_MIRROR", it is used to
allocate mirrored pages.
When cat /proc/pagetypeinfo, you can see the count of free mirrored blocks.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/mmzone.h | 9 +++++++++
 mm/page_alloc.c        | 3 +++
 mm/vmstat.c            | 3 +++
 3 files changed, 15 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 54d74f6..54e891a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -39,6 +39,9 @@ enum {
 	MIGRATE_UNMOVABLE,
 	MIGRATE_RECLAIMABLE,
 	MIGRATE_MOVABLE,
+#ifdef CONFIG_MEMORY_MIRROR
+	MIGRATE_MIRROR,
+#endif
 	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
 	MIGRATE_RESERVE = MIGRATE_PCPTYPES,
 #ifdef CONFIG_CMA
@@ -69,6 +72,12 @@ enum {
 #  define is_migrate_cma(migratetype) false
 #endif
 
+#ifdef CONFIG_MEMORY_MIRROR
+#  define is_migrate_mirror(migratetype) unlikely((migratetype) == MIGRATE_MIRROR)
+#else
+#  define is_migrate_mirror(migratetype) false
+#endif
+
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
 		for (type = 0; type < MIGRATE_TYPES; type++)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e..6e4d79f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3216,6 +3216,9 @@ static void show_migration_types(unsigned char type)
 		[MIGRATE_UNMOVABLE]	= 'U',
 		[MIGRATE_RECLAIMABLE]	= 'E',
 		[MIGRATE_MOVABLE]	= 'M',
+#ifdef CONFIG_MEMORY_MIRROR
+		[MIGRATE_MIRROR]	= 'O',
+#endif
 		[MIGRATE_RESERVE]	= 'R',
 #ifdef CONFIG_CMA
 		[MIGRATE_CMA]		= 'C',
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4f5cd97..d0323e0 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -901,6 +901,9 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
 	"Unmovable",
 	"Reclaimable",
 	"Movable",
+#ifdef CONFIG_MEMORY_MIRROR
+	"Mirror",
+#endif
 	"Reserve",
 #ifdef CONFIG_CMA
 	"CMA",
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
