Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id C2DF36B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 22:39:52 -0400 (EDT)
Received: by ykdt186 with SMTP id t186so74161174ykd.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 19:39:52 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id o11si3669853ykb.45.2015.06.26.19.39.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 19:39:51 -0700 (PDT)
Message-ID: <558E0A28.6060607@huawei.com>
Date: Sat, 27 Jun 2015 10:27:52 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC v2 PATCH 7/8] mm: add the buddy system interface
References: <558E084A.60900@huawei.com>
In-Reply-To: <558E084A.60900@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add the buddy system interface for address range mirroring feature.
Use mirrored memory for all kernel allocations. If there is no mirrored pages
left, try to use other types pages.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/memblock.h |  1 +
 mm/memblock.c            |  6 +++---
 mm/page_alloc.c          | 19 +++++++++++++++++++
 3 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 53be030..8c33ac0 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -81,6 +81,7 @@ int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
 ulong choose_memblock_flags(void);
+extern struct static_key system_has_mirror;
 #ifdef CONFIG_MEMORY_MIRROR
 void memblock_mark_migratemirror(void);
 #endif
diff --git a/mm/memblock.c b/mm/memblock.c
index 0d0b210..430ad87 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -55,14 +55,14 @@ int memblock_debug __initdata_memblock;
 #ifdef CONFIG_MOVABLE_NODE
 bool movable_node_enabled __initdata_memblock = false;
 #endif
-static bool system_has_some_mirror __initdata_memblock = false;
+struct static_key system_has_mirror = STATIC_KEY_INIT;
 static int memblock_can_resize __initdata_memblock;
 static int memblock_memory_in_slab __initdata_memblock = 0;
 static int memblock_reserved_in_slab __initdata_memblock = 0;
 
 ulong __init_memblock choose_memblock_flags(void)
 {
-	return system_has_some_mirror ? MEMBLOCK_MIRROR : MEMBLOCK_NONE;
+	return static_key_false(&system_has_mirror) ? MEMBLOCK_MIRROR : MEMBLOCK_NONE;
 }
 
 /* inline so we don't get a warning when pr_debug is compiled out */
@@ -814,7 +814,7 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
  */
 int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
 {
-	system_has_some_mirror = true;
+	static_key_slow_inc(&system_has_mirror);
 
 	return memblock_setclr_flag(base, size, 1, MEMBLOCK_MIRROR);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4c5bc50..8a6125e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1033,6 +1033,9 @@ static int fallbacks[MIGRATE_TYPES][4] = {
 	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
 	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
 	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   MIGRATE_RESERVE },
+#ifdef CONFIG_MEMORY_MIRROR
+	[MIGRATE_MIRROR]      = { MIGRATE_RESERVE }, /* Never used */
+#endif
 #ifdef CONFIG_CMA
 	[MIGRATE_CMA]         = { MIGRATE_RESERVE }, /* Never used */
 #endif
@@ -1295,6 +1298,15 @@ retry_reserve:
 	page = __rmqueue_smallest(zone, order, migratetype);
 
 	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
+		/*
+		 * If there is no mirrored memory left, alloc other types
+		 * memory. But we should not change the pageblock's
+		 * migratetype between mirror and others, so just use
+		 * MIGRATE_RECLAIMABLE to retry
+		 */
+		if (is_migrate_mirror(migratetype))
+			return __rmqueue(zone, order, MIGRATE_RECLAIMABLE);
+
 		if (migratetype == MIGRATE_MOVABLE)
 			page = __rmqueue_cma_fallback(zone, order);
 
@@ -2872,6 +2884,13 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 
+#ifdef CONFIG_MEMORY_MIRROR
+	/* Alloc mirrored memory for kernel */
+	if (static_key_false(&system_has_mirror)
+			&& !(gfp_mask & __GFP_MOVABLE))
+		ac.migratetype = MIGRATE_MIRROR;
+#endif
+
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
