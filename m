Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id BADB16B0039
	for <linux-mm@kvack.org>; Sun, 20 Jul 2014 23:57:30 -0400 (EDT)
Received: by mail-oi0-f48.google.com with SMTP id h136so3031542oig.7
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 20:57:30 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id xp6si31243982obc.19.2014.07.20.20.57.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 20 Jul 2014 20:57:30 -0700 (PDT)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH v2 1/7] memory-hotplug: add zone_for_memory() for selecting zone for new memory
Date: Mon, 21 Jul 2014 11:46:36 +0800
Message-ID: <1405914402-66212-2-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405914402-66212-1-git-send-email-wangnan0@huawei.com>
References: <1405914402-66212-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel
 Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave
 Hansen <dave.hansen@intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: peifeiyue@huawei.com, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, wangnan0@huawei.com

This patch introduces a zone_for_memory function in arch independent
code for arch_add_memory() using.

Many arch_add_memory() function simply selects ZONE_HIGHMEM or
ZONE_NORMAL and add new memory into it. However, with the existance of
ZONE_MOVABLE, the selection method should be carefully considered: if
new, higher memory is added after ZONE_MOVABLE is setup, the default
zone and ZONE_MOVABLE may overlap each other.

should_add_memory_movable() checks the status of ZONE_MOVABLE. If it has
already contain memory, compare the address of new memory and movable
memory. If new memory is higher than movable, it should be added into
ZONE_MOVABLE instead of default zone.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 include/linux/memory_hotplug.h |  1 +
 mm/memory_hotplug.c            | 28 ++++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 010d125..3de3d02 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -258,6 +258,7 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
 extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
 extern int add_memory(int nid, u64 start, u64 size);
+extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 469bbf5..348fda7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1156,6 +1156,34 @@ static int check_hotplug_memory_range(u64 start, u64 size)
 	return 0;
 }
 
+/*
+ * If movable zone has already been setup, newly added memory should be check.
+ * If its address is higher than movable zone, it should be added as movable.
+ * Without this check, movable zone may overlap with other zone.
+ */
+static int should_add_memory_movable(int nid, u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	pg_data_t *pgdat = NODE_DATA(nid);
+	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
+
+	if (zone_is_empty(movable_zone))
+		return 0;
+
+	if (movable_zone->zone_start_pfn <= start_pfn)
+		return 1;
+
+	return 0;
+}
+
+int zone_for_memory(int nid, u64 start, u64 size, int zone_default)
+{
+	if (should_add_memory_movable(nid, start, size))
+		return ZONE_MOVABLE;
+
+	return zone_default;
+}
+
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
 int __ref add_memory(int nid, u64 start, u64 size)
 {
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
