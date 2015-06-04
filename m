Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 169EE900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 09:15:04 -0400 (EDT)
Received: by obbgp2 with SMTP id gp2so9740595obb.2
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 06:15:03 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id m2si1654245obx.5.2015.06.04.06.15.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 06:15:03 -0700 (PDT)
Message-ID: <55704B55.1020403@huawei.com>
Date: Thu, 4 Jun 2015 20:57:57 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH 02/12] mm: introduce mirror_info
References: <55704A7E.5030507@huawei.com>
In-Reply-To: <55704A7E.5030507@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This patch introduces a new struct called "mirror_info", it is used to storage
the mirror address range which reported by EFI or ACPI.

TBD: call add_mirror_info() to fill it.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 arch/x86/mm/numa.c     |  3 +++
 include/linux/mmzone.h | 15 +++++++++++++++
 mm/page_alloc.c        | 33 +++++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 4053bb5..781fd68 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -619,6 +619,9 @@ static int __init numa_init(int (*init_func)(void))
 	/* In case that parsing SRAT failed. */
 	WARN_ON(memblock_clear_hotplug(0, ULLONG_MAX));
 	numa_reset_distance();
+#ifdef CONFIG_MEMORY_MIRROR
+	memset(&mirror_info, 0, sizeof(mirror_info));
+#endif
 
 	ret = init_func();
 	if (ret < 0)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 54d74f6..1fae07b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -69,6 +69,21 @@ enum {
 #  define is_migrate_cma(migratetype) false
 #endif
 
+#ifdef CONFIG_MEMORY_MIRROR
+struct numa_mirror_info {
+	int node;
+	unsigned long start;
+	unsigned long size;
+};
+
+struct mirror_info {
+	int count;
+	struct numa_mirror_info info[MAX_NUMNODES];
+};
+
+extern struct mirror_info mirror_info;
+#endif
+
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
 		for (type = 0; type < MIGRATE_TYPES; type++)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e..41a95a7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -210,6 +210,10 @@ static char * const zone_names[MAX_NR_ZONES] = {
 int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
 
+#ifdef CONFIG_MEMORY_MIRROR
+struct mirror_info mirror_info;
+#endif
+
 static unsigned long __meminitdata nr_kernel_pages;
 static unsigned long __meminitdata nr_all_pages;
 static unsigned long __meminitdata dma_reserve;
@@ -545,6 +549,31 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	return 0;
 }
 
+#ifdef CONFIG_MEMORY_MIRROR
+static void __init add_mirror_info(int node,
+			unsigned long start, unsigned long size)
+{
+	mirror_info.info[mirror_info.count].node = node;
+	mirror_info.info[mirror_info.count].start = start;
+	mirror_info.info[mirror_info.count].size = size;
+
+	mirror_info.count++;
+}
+
+static void __init print_mirror_info(void)
+{
+	int i;
+
+	printk("Mirror info\n");
+	for (i = 0; i < mirror_info.count; i++)
+		printk("  node %3d: [mem %#010lx-%#010lx]\n",
+			mirror_info.info[i].node,
+			mirror_info.info[i].start,
+			mirror_info.info[i].start +
+				mirror_info.info[i].size - 1);
+}
+#endif
+
 /*
  * Freeing function for a buddy system allocator.
  *
@@ -5438,6 +5467,10 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 			       (u64)zone_movable_pfn[i] << PAGE_SHIFT);
 	}
 
+#ifdef CONFIG_MEMORY_MIRROR
+	print_mirror_info();
+#endif
+
 	/* Print out the early node map */
 	pr_info("Early memory node ranges\n");
 	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
