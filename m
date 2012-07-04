Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 06A5E6B0078
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 04:38:56 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 3/3 V1 resend] mm, memory-hotplug: add online_movable
Date: Wed, 4 Jul 2012 16:38:58 +0800
Message-Id: <1341391138-9547-4-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1341391138-9547-1-git-send-email-laijs@cn.fujitsu.com>
References: <1341391138-9547-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andi Kleen <andi@firstfloor.org>, Julia Lawall <julia@diku.dk>, David Howells <dhowells@redhat.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kay Sievers <kay.sievers@vrfy.org>, Ingo Molnar <mingo@elte.hu>, Paul Gortmaker <paul.gortmaker@windriver.com>, Daniel Kiper <dkiper@net-space.pl>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Bjorn Helgaas <bhelgaas@google.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

When a memoryblock is onlined by "online_movable", the kernel will not
have directly reference to the page of the memoryblock,
thus we can remove that memory any time when needed.

It makes things easy when we dynamic hot-add/remove memory, make better
utilities of memories.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 arch/tile/mm/init.c            |    2 +-
 drivers/acpi/acpi_memhotplug.c |    3 ++-
 drivers/base/memory.c          |   24 +++++++++++++++---------
 include/linux/memory.h         |    1 +
 include/linux/memory_hotplug.h |    4 ++--
 include/linux/mmzone.h         |    2 ++
 mm/memory_hotplug.c            |   36 +++++++++++++++++++++++++++++-------
 mm/page_alloc.c                |    2 +-
 8 files changed, 53 insertions(+), 21 deletions(-)

diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index 630dd2c..624d397 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -943,7 +943,7 @@ int arch_add_memory(u64 start, u64 size)
 	return __add_pages(zone, start_pfn, nr_pages);
 }
 
-int remove_memory(u64 start, u64 size)
+int remove_memory(u64 start, u64 size, int movable)
 {
 	return -EINVAL;
 }
diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index d985713..8a9c039 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -318,7 +318,8 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
 	 */
 	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
 		if (info->enabled) {
-			result = remove_memory(info->start_addr, info->length);
+			result = remove_memory(info->start_addr,
+					info->length, 0);
 			if (result)
 				return result;
 		}
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 7dda4f7..cc6c5d2 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -246,7 +246,7 @@ static bool pages_correctly_reserved(unsigned long start_pfn,
  * OK to have direct references to sparsemem variables in here.
  */
 static int
-memory_block_action(unsigned long phys_index, unsigned long action)
+memory_block_action(unsigned long phys_index, unsigned long action, int movable)
 {
 	unsigned long start_pfn, start_paddr;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
@@ -262,12 +262,12 @@ memory_block_action(unsigned long phys_index, unsigned long action)
 			if (!pages_correctly_reserved(start_pfn, nr_pages))
 				return -EBUSY;
 
-			ret = online_pages(start_pfn, nr_pages);
+			ret = online_pages(start_pfn, nr_pages, movable);
 			break;
 		case MEM_OFFLINE:
 			start_paddr = page_to_pfn(first_page) << PAGE_SHIFT;
 			ret = remove_memory(start_paddr,
-					    nr_pages << PAGE_SHIFT);
+					    nr_pages << PAGE_SHIFT, movable);
 			break;
 		default:
 			WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
@@ -279,7 +279,8 @@ memory_block_action(unsigned long phys_index, unsigned long action)
 }
 
 static int memory_block_change_state(struct memory_block *mem,
-		unsigned long to_state, unsigned long from_state_req)
+		unsigned long to_state, unsigned long from_state_req,
+		int movable)
 {
 	int ret = 0;
 
@@ -290,16 +291,19 @@ static int memory_block_change_state(struct memory_block *mem,
 		goto out;
 	}
 
-	if (to_state == MEM_OFFLINE)
+	if (to_state == MEM_OFFLINE) {
+		movable = mem->movable;
 		mem->state = MEM_GOING_OFFLINE;
+	}
 
-	ret = memory_block_action(mem->start_section_nr, to_state);
+	ret = memory_block_action(mem->start_section_nr, to_state, movable);
 
 	if (ret) {
 		mem->state = from_state_req;
 		goto out;
 	}
 
+	mem->movable = movable;
 	mem->state = to_state;
 	switch (mem->state) {
 	case MEM_OFFLINE:
@@ -325,10 +329,12 @@ store_mem_state(struct device *dev,
 
 	mem = container_of(dev, struct memory_block, dev);
 
-	if (!strncmp(buf, "online", min((int)count, 6)))
-		ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE);
+	if (!strncmp(buf, "online_movable", min((int)count, 14)))
+		ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE, 1);
+	else if (!strncmp(buf, "online", min((int)count, 6)))
+		ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE, 0);
 	else if(!strncmp(buf, "offline", min((int)count, 7)))
-		ret = memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE);
+		ret = memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, 0);
 
 	if (ret)
 		return ret;
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 1ac7f6e..90eae9c 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -26,6 +26,7 @@ struct memory_block {
 	unsigned long end_section_nr;
 	unsigned long state;
 	int section_count;
+	int movable;
 
 	/*
 	 * This serializes all state change requests.  It isn't
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 910550f..0e6501c 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -70,7 +70,7 @@ extern int zone_grow_free_lists(struct zone *zone, unsigned long new_nr_pages);
 extern int zone_grow_waitqueues(struct zone *zone, unsigned long nr_pages);
 extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
 /* VM interface that may be used by firmware interface */
-extern int online_pages(unsigned long, unsigned long);
+extern int online_pages(unsigned long, unsigned long, int);
 extern void __offline_isolated_pages(unsigned long, unsigned long);
 
 typedef void (*online_page_callback_t)(struct page *page);
@@ -233,7 +233,7 @@ static inline int is_mem_section_removable(unsigned long pfn,
 extern int mem_online_node(int nid);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
-extern int remove_memory(u64 start, u64 size);
+extern int remove_memory(u64 start, u64 size, int);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 872f430..458bd0b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -115,6 +115,8 @@ static inline int get_pageblock_migratetype(struct page *page)
 	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
 }
 
+extern void set_pageblock_migratetype(struct page *page, int migratetype);
+
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0d7e3ec..cb49893 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -457,7 +457,7 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 }
 
 
-int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
+int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int movable)
 {
 	unsigned long onlined_pages = 0;
 	struct zone *zone;
@@ -466,6 +466,12 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	int ret;
 	struct memory_notify arg;
 
+	/* at least, alignment against pageblock is necessary */
+	if (!IS_ALIGNED(pfn, pageblock_nr_pages))
+		return -EINVAL;
+	if (!IS_ALIGNED(nr_pages, pageblock_nr_pages))
+		return -EINVAL;
+
 	lock_memory_hotplug();
 	arg.start_pfn = pfn;
 	arg.nr_pages = nr_pages;
@@ -497,6 +503,21 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	if (!populated_zone(zone))
 		need_zonelists_rebuild = 1;
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+	if (movable) {
+		unsigned long offset;
+
+		for (offset = 0;
+		     offset < nr_pages;
+		     offset += pageblock_nr_pages) {
+			spin_lock_irq(&zone->lock);
+			set_pageblock_migratetype(pfn_to_page(pfn + offset),
+					MIGRATE_HOTREMOVE);
+			spin_unlock_irq(&zone->lock);
+		}
+	}
+#endif
+
 	ret = walk_system_ram_range(pfn, nr_pages, &onlined_pages,
 		online_pages_range);
 	if (ret) {
@@ -866,13 +887,14 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 }
 
 static int __ref offline_pages(unsigned long start_pfn,
-		  unsigned long end_pfn, unsigned long timeout)
+		  unsigned long end_pfn, unsigned long timeout, int movable)
 {
 	unsigned long pfn, nr_pages, expire;
 	long offlined_pages;
 	int ret, drain, retry_max, node;
 	struct zone *zone;
 	struct memory_notify arg;
+	int origin_mt = movable ? MIGRATE_HOTREMOVE : MIGRATE_MOVABLE;
 
 	BUG_ON(start_pfn >= end_pfn);
 	/* at least, alignment against pageblock is necessary */
@@ -892,7 +914,7 @@ static int __ref offline_pages(unsigned long start_pfn,
 	nr_pages = end_pfn - start_pfn;
 
 	/* set above range as isolated */
-	ret = start_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	ret = start_isolate_page_range(start_pfn, end_pfn, origin_mt);
 	if (ret)
 		goto out;
 
@@ -983,23 +1005,23 @@ failed_removal:
 	       ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
 	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
-	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	undo_isolate_page_range(start_pfn, end_pfn, origin_mt);
 
 out:
 	unlock_memory_hotplug();
 	return ret;
 }
 
-int remove_memory(u64 start, u64 size)
+int remove_memory(u64 start, u64 size, int movable)
 {
 	unsigned long start_pfn, end_pfn;
 
 	start_pfn = PFN_DOWN(start);
 	end_pfn = start_pfn + PFN_DOWN(size);
-	return offline_pages(start_pfn, end_pfn, 120 * HZ);
+	return offline_pages(start_pfn, end_pfn, 120 * HZ, movable);
 }
 #else
-int remove_memory(u64 start, u64 size)
+int remove_memory(u64 start, u64 size, int movable)
 {
 	return -EINVAL;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7a4a03b..801772c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -219,7 +219,7 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
-static void set_pageblock_migratetype(struct page *page, int migratetype)
+void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 
 	if (unlikely(page_group_by_mobility_disabled))
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
