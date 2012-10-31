Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 63A3E6B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 01:35:15 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART1 Patch 1/3] mm, memory-hotplug: dynamic configure movable memory and portion memory
Date: Wed, 31 Oct 2012 13:40:34 +0800
Message-Id: <1351662036-7435-2-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351662036-7435-1-git-send-email-wency@cn.fujitsu.com>
References: <1351662036-7435-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

Add online_movable and online_kernel for logic memory hotplug.
This is the dynamic version of "movablecore" & "kernelcore".

We have the same reason to introduce it as to introduce "movablecore" & "kernelcore".
It has the same motive as "movablecore" & "kernelcore", but it is dynamic/running-time:

o	We can configure memory as kernelcore or movablecore after boot.

	Userspace workload is increased, we need more hugepage, we can't
	use "online_movable" to add memory and allow the system use more
	THP(transparent-huge-page), vice-verse when kernel workload is increase.

	Also help for virtualization to dynamic configure host/guest's memory,
	to save/(reduce waste) memory.

	Memory capacity on Demand

o	When a new node is physically online after boot, we need to use
	"online_movable" or "online_kernel" to configure/portion it
	as we expected when we logic-online it.

	This configuration also helps for physically-memory-migrate.

o	all benefit as the same as existed "movablecore" & "kernelcore".

o	Preparing for movable-node, which is very important for power-saving,
	hardware partitioning and high-available-system(hardware fault management).

	(Note, we don't introduce movable-node here.)

Action behavior:
When a memoryblock/memorysection is onlined by "online_movable", the kernel
will not have directly reference to the page of the memoryblock,
thus we can remove that memory any time when needed.

When it is online by "online_kernel", the kernel can use it.
When it is online by "online", the zone type doesn't changed.

Current constraints:
Only the memoryblock which is adjacent to the ZONE_MOVABLE
can be online from ZONE_NORMAL to ZONE_MOVABLE.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 Documentation/memory-hotplug.txt |  14 +++++-
 drivers/base/memory.c            |  27 +++++++----
 include/linux/memory_hotplug.h   |  13 ++++-
 mm/memory_hotplug.c              | 101 ++++++++++++++++++++++++++++++++++++++-
 4 files changed, 142 insertions(+), 13 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 6e6cbc7..c6f993d 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -161,7 +161,8 @@ a recent addition and not present on older kernels.
 		    in the memory block.
 'state'           : read-write
                     at read:  contains online/offline state of memory.
-                    at write: user can specify "online", "offline" command
+                    at write: user can specify "online_kernel",
+                    "online_movable", "online", "offline" command
                     which will be performed on al sections in the block.
 'phys_device'     : read-only: designed to show the name of physical memory
                     device.  This is not well implemented now.
@@ -255,6 +256,17 @@ For onlining, you have to write "online" to the section's state file as:
 
 % echo online > /sys/devices/system/memory/memoryXXX/state
 
+This onlining will not change the ZONE type of the target memory section,
+If the memory section is in ZONE_NORMAL, you can change it to ZONE_MOVABLE:
+
+% echo online_movable > /sys/devices/system/memory/memoryXXX/state
+(NOTE: current limit: this memory section must be adjacent to ZONE_MOVABLE)
+
+And if the memory section is in ZONE_MOVABLE, you can change it to ZONE_NORMAL:
+
+% echo online_kernel > /sys/devices/system/memory/memoryXXX/state
+(NOTE: current limit: this memory section must be adjacent to ZONE_NORMAL)
+
 After this, section memoryXXX's state will be 'online' and the amount of
 available memory will be increased.
 
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 86c8821..15a1dd7 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -246,7 +246,7 @@ static bool pages_correctly_reserved(unsigned long start_pfn,
  * OK to have direct references to sparsemem variables in here.
  */
 static int
-memory_block_action(unsigned long phys_index, unsigned long action)
+memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
 {
 	unsigned long start_pfn;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
@@ -261,7 +261,7 @@ memory_block_action(unsigned long phys_index, unsigned long action)
 			if (!pages_correctly_reserved(start_pfn, nr_pages))
 				return -EBUSY;
 
-			ret = online_pages(start_pfn, nr_pages);
+			ret = online_pages(start_pfn, nr_pages, online_type);
 			break;
 		case MEM_OFFLINE:
 			ret = offline_pages(start_pfn, nr_pages);
@@ -276,7 +276,8 @@ memory_block_action(unsigned long phys_index, unsigned long action)
 }
 
 static int __memory_block_change_state(struct memory_block *mem,
-		unsigned long to_state, unsigned long from_state_req)
+		unsigned long to_state, unsigned long from_state_req,
+		int online_type)
 {
 	int ret = 0;
 
@@ -288,7 +289,7 @@ static int __memory_block_change_state(struct memory_block *mem,
 	if (to_state == MEM_OFFLINE)
 		mem->state = MEM_GOING_OFFLINE;
 
-	ret = memory_block_action(mem->start_section_nr, to_state);
+	ret = memory_block_action(mem->start_section_nr, to_state, online_type);
 
 	if (ret) {
 		mem->state = from_state_req;
@@ -311,12 +312,14 @@ out:
 }
 
 static int memory_block_change_state(struct memory_block *mem,
-		unsigned long to_state, unsigned long from_state_req)
+		unsigned long to_state, unsigned long from_state_req,
+		int online_type)
 {
 	int ret;
 
 	mutex_lock(&mem->state_mutex);
-	ret = __memory_block_change_state(mem, to_state, from_state_req);
+	ret = __memory_block_change_state(mem, to_state, from_state_req,
+					  online_type);
 	mutex_unlock(&mem->state_mutex);
 
 	return ret;
@@ -330,10 +333,14 @@ store_mem_state(struct device *dev,
 
 	mem = container_of(dev, struct memory_block, dev);
 
-	if (!strncmp(buf, "online", min((int)count, 6)))
-		ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE);
+	if (!strncmp(buf, "online_kernel", min((int)count, 13)))
+		ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE, ONLINE_KERNEL);
+	else if (!strncmp(buf, "online_movable", min((int)count, 14)))
+		ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE, ONLINE_MOVABLE);
+	else if (!strncmp(buf, "online", min((int)count, 6)))
+		ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE, ONLINE_KEEP);
 	else if(!strncmp(buf, "offline", min((int)count, 7)))
-		ret = memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE);
+		ret = memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
 
 	if (ret)
 		return ret;
@@ -669,7 +676,7 @@ int offline_memory_block(struct memory_block *mem)
 
 	mutex_lock(&mem->state_mutex);
 	if (mem->state != MEM_OFFLINE)
-		ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE);
+		ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
 	mutex_unlock(&mem->state_mutex);
 
 	return ret;
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 95573ec..4a45c4e 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -26,6 +26,13 @@ enum {
 	MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE = NODE_INFO,
 };
 
+/* Types for control the zone type of onlined memory */
+enum {
+	ONLINE_KEEP,
+	ONLINE_KERNEL,
+	ONLINE_MOVABLE,
+};
+
 /*
  * pgdat resizing functions
  */
@@ -46,6 +53,10 @@ void pgdat_resize_init(struct pglist_data *pgdat)
 }
 /*
  * Zone resizing functions
+ *
+ * Note: any attempt to resize a zone should has pgdat_resize_lock()
+ * zone_span_writelock() both held. This ensure the size of a zone
+ * can't be changed while pgdat_resize_lock() held.
  */
 static inline unsigned zone_span_seqbegin(struct zone *zone)
 {
@@ -71,7 +82,7 @@ extern int zone_grow_free_lists(struct zone *zone, unsigned long new_nr_pages);
 extern int zone_grow_waitqueues(struct zone *zone, unsigned long nr_pages);
 extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
 /* VM interface that may be used by firmware interface */
-extern int online_pages(unsigned long, unsigned long);
+extern int online_pages(unsigned long, unsigned long, int);
 extern void __offline_isolated_pages(unsigned long, unsigned long);
 
 typedef void (*online_page_callback_t)(struct page *page);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index dfa6a91..4900025 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -221,6 +221,89 @@ static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
 	zone_span_writeunlock(zone);
 }
 
+static void resize_zone(struct zone *zone, unsigned long start_pfn,
+		unsigned long end_pfn)
+{
+
+	zone_span_writelock(zone);
+
+	zone->zone_start_pfn = start_pfn;
+	zone->spanned_pages = end_pfn - start_pfn;
+
+	zone_span_writeunlock(zone);
+}
+
+static void fix_zone_id(struct zone *zone, unsigned long start_pfn,
+		unsigned long end_pfn)
+{
+	enum zone_type zid = zone_idx(zone);
+	int nid = zone->zone_pgdat->node_id;
+	unsigned long pfn;
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn++)
+		set_page_links(pfn_to_page(pfn), zid, nid, pfn);
+}
+
+static int move_pfn_range_left(struct zone *z1, struct zone *z2,
+		unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long flags;
+
+	pgdat_resize_lock(z1->zone_pgdat, &flags);
+
+	/* can't move pfns which are higher than @z2 */
+	if (end_pfn > z2->zone_start_pfn + z2->spanned_pages)
+		goto out_fail;
+	/* the move out part mast at the left most of @z2 */
+	if (start_pfn > z2->zone_start_pfn)
+		goto out_fail;
+	/* must included/overlap */
+	if (end_pfn <= z2->zone_start_pfn)
+		goto out_fail;
+
+	resize_zone(z1, z1->zone_start_pfn, end_pfn);
+	resize_zone(z2, end_pfn, z2->zone_start_pfn + z2->spanned_pages);
+
+	pgdat_resize_unlock(z1->zone_pgdat, &flags);
+
+	fix_zone_id(z1, start_pfn, end_pfn);
+
+	return 0;
+out_fail:
+	pgdat_resize_unlock(z1->zone_pgdat, &flags);
+	return -1;
+}
+
+static int move_pfn_range_right(struct zone *z1, struct zone *z2,
+		unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long flags;
+
+	pgdat_resize_lock(z1->zone_pgdat, &flags);
+
+	/* can't move pfns which are lower than @z1 */
+	if (z1->zone_start_pfn > start_pfn)
+		goto out_fail;
+	/* the move out part mast at the right most of @z1 */
+	if (z1->zone_start_pfn + z1->spanned_pages >  end_pfn)
+		goto out_fail;
+	/* must included/overlap */
+	if (start_pfn >= z1->zone_start_pfn + z1->spanned_pages)
+		goto out_fail;
+
+	resize_zone(z1, z1->zone_start_pfn, start_pfn);
+	resize_zone(z2, start_pfn, z2->zone_start_pfn + z2->spanned_pages);
+
+	pgdat_resize_unlock(z1->zone_pgdat, &flags);
+
+	fix_zone_id(z2, start_pfn, end_pfn);
+
+	return 0;
+out_fail:
+	pgdat_resize_unlock(z1->zone_pgdat, &flags);
+	return -1;
+}
+
 static void grow_pgdat_span(struct pglist_data *pgdat, unsigned long start_pfn,
 			    unsigned long end_pfn)
 {
@@ -515,7 +598,7 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 }
 
 
-int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
+int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
 {
 	unsigned long onlined_pages = 0;
 	struct zone *zone;
@@ -532,6 +615,22 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	 */
 	zone = page_zone(pfn_to_page(pfn));
 
+	if (online_type == ONLINE_KERNEL && zone_idx(zone) == ZONE_MOVABLE) {
+		if (move_pfn_range_left(zone - 1, zone, pfn, pfn + nr_pages)) {
+			unlock_memory_hotplug();
+			return -1;
+		}
+	}
+	if (online_type == ONLINE_MOVABLE && zone_idx(zone) == ZONE_MOVABLE - 1) {
+		if (move_pfn_range_right(zone, zone + 1, pfn, pfn + nr_pages)) {
+			unlock_memory_hotplug();
+			return -1;
+		}
+	}
+
+	/* Previous code may changed the zone of the pfn range */
+	zone = page_zone(pfn_to_page(pfn));
+
 	arg.start_pfn = pfn;
 	arg.nr_pages = nr_pages;
 	node_states_check_changes_online(nr_pages, zone, &arg);
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
