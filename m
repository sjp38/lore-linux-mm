Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C704E6B000E
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 05:56:35 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id ba8-v6so12166507plb.4
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 02:56:35 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w4-v6si17586520pfb.52.2018.07.10.02.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 02:56:34 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v35 1/5] mm: support to get hints of free page blocks
Date: Tue, 10 Jul 2018 17:31:03 +0800
Message-Id: <1531215067-35472-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

This patch adds support to get free page blocks from a free page list.
The physical addresses of the blocks are stored to a list of buffers
passed from the caller. The obtained free page blocks are hints about
free pages, because there is no guarantee that they are still on the free
page list after the function returns.

One use example of this patch is to accelerate live migration by skipping
the transfer of free pages reported from the guest. A popular method used
by the hypervisor to track which part of memory is written during live
migration is to write-protect all the guest memory. So, those pages that
are hinted as free pages but are written after this function returns will
be captured by the hypervisor, and they will be added to the next round of
memory transfer.

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 include/linux/mm.h |  3 ++
 mm/page_alloc.c    | 98 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 101 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a0fbb9f..5ce654f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2007,6 +2007,9 @@ extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
+unsigned long max_free_page_blocks(int order);
+int get_from_free_page_list(int order, struct list_head *pages,
+			    unsigned int size, unsigned long *loaded_num);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1521100..b67839b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5043,6 +5043,104 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 	show_swap_cache_info();
 }
 
+/**
+ * max_free_page_blocks - estimate the max number of free page blocks
+ * @order: the order of the free page blocks to estimate
+ *
+ * This function gives a rough estimation of the possible maximum number of
+ * free page blocks a free list may have. The estimation works on an assumption
+ * that all the system pages are on that list.
+ *
+ * Context: Any context.
+ *
+ * Return: The largest number of free page blocks that the free list can have.
+ */
+unsigned long max_free_page_blocks(int order)
+{
+	return totalram_pages / (1 << order);
+}
+EXPORT_SYMBOL_GPL(max_free_page_blocks);
+
+/**
+ * get_from_free_page_list - get hints of free pages from a free page list
+ * @order: the order of the free page list to check
+ * @pages: the list of page blocks used as buffers to load the addresses
+ * @size: the size of each buffer in bytes
+ * @loaded_num: the number of addresses loaded to the buffers
+ *
+ * This function offers hints about free pages. The addresses of free page
+ * blocks are stored to the list of buffers passed from the caller. There is
+ * no guarantee that the obtained free pages are still on the free page list
+ * after the function returns. pfn_to_page on the obtained free pages is
+ * strongly discouraged and if there is an absolute need for that, make sure
+ * to contact MM people to discuss potential problems.
+ *
+ * The addresses are currently stored to a buffer in little endian. This
+ * avoids the overhead of converting endianness by the caller who needs data
+ * in the little endian format. Big endian support can be added on demand in
+ * the future.
+ *
+ * Context: Process context.
+ *
+ * Return: 0 if all the free page block addresses are stored to the buffers;
+ *         -ENOSPC if the buffers are not sufficient to store all the
+ *         addresses; or -EINVAL if an unexpected argument is received (e.g.
+ *         incorrect @order, empty buffer list).
+ */
+int get_from_free_page_list(int order, struct list_head *pages,
+			    unsigned int size, unsigned long *loaded_num)
+{
+	struct zone *zone;
+	enum migratetype mt;
+	struct list_head *free_list;
+	struct page *free_page, *buf_page;
+	unsigned long addr;
+	__le64 *buf;
+	unsigned int used_buf_num = 0, entry_index = 0,
+		     entries = size / sizeof(__le64);
+	*loaded_num = 0;
+
+	/* Validity check */
+	if (order < 0 || order >= MAX_ORDER)
+		return -EINVAL;
+
+	buf_page = list_first_entry_or_null(pages, struct page, lru);
+	if (!buf_page)
+		return -EINVAL;
+	buf = (__le64 *)page_address(buf_page);
+
+	for_each_populated_zone(zone) {
+		spin_lock_irq(&zone->lock);
+		for (mt = 0; mt < MIGRATE_TYPES; mt++) {
+			free_list = &zone->free_area[order].free_list[mt];
+			list_for_each_entry(free_page, free_list, lru) {
+				addr = page_to_pfn(free_page) << PAGE_SHIFT;
+				/* This buffer is full, so use the next one */
+				if (entry_index == entries) {
+					buf_page = list_next_entry(buf_page,
+								   lru);
+					/* All the buffers are consumed */
+					if (!buf_page) {
+						spin_unlock_irq(&zone->lock);
+						*loaded_num = used_buf_num *
+							      entries;
+						return -ENOSPC;
+					}
+					buf = (__le64 *)page_address(buf_page);
+					entry_index = 0;
+					used_buf_num++;
+				}
+				buf[entry_index++] = cpu_to_le64(addr);
+			}
+		}
+		spin_unlock_irq(&zone->lock);
+	}
+
+	*loaded_num = used_buf_num * entries + entry_index;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(get_from_free_page_list);
+
 static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
 {
 	zoneref->zone = zone;
-- 
2.7.4
