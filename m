From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 23/23 V2] mm, memory-hotplug: add online_movable
Date: Thu, 2 Aug 2012 10:53:11 +0800
Message-ID: <1343875991-7533-24-git-send-email-laijs@cn.fujitsu.com>
References: <1343875991-7533-1-git-send-email-laijs@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1343875991-7533-1-git-send-email-laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Cc: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Dan Magenheimer <dan.magenheimer-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>, Konstantin Khlebnikov <khlebnikov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>, Gavin Shan <shangw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Petr Holasek <pholasek-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Wanlong Gao <gaowanlong-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Djalal Harouni <tixxdz-Umm1ozX2/EEdnm+yROfE0A@public.gmane.org>, Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>, Wen Congyang <wency-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Peter Zijlstra <a.p.zijlstra@ch>
List-Id: linux-mm.kvack.org

When a memoryblock/memorysection is onlined by "online_movable", the kernel
will not have directly reference to the page of the memoryblock,
thus we can remove that memory any time when needed.

It makes things easy when we dynamic hot-add/remove memory, make better
utilities of memories, and helps for THP.

Current constraints: Only the memoryblock which is adjacent to the ZONE_MOVABLE
can be onlined from ZONE_NORMAL to ZONE_MOVABLE.

For opposite onlining behavior, we also introduce "online_kernel" to change
a memoryblock of ZONE_MOVABLE to ZONE_KERNEL when online.

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/memory-hotplug.txt |   14 ++++-
 drivers/base/memory.c            |   19 ++++--
 include/linux/memory_hotplug.h   |   13 ++++-
 mm/memory_hotplug.c              |  114 +++++++++++++++++++++++++++++++++++--
 4 files changed, 144 insertions(+), 16 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 89f21b2..7b1269c 100644
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
index 7dda4f7..1ad2f48 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -246,7 +246,7 @@ static bool pages_correctly_reserved(unsigned long start_pfn,
  * OK to have direct references to sparsemem variables in here.
  */
 static int
-memory_block_action(unsigned long phys_index, unsigned long action)
+memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
 {
 	unsigned long start_pfn, start_paddr;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
@@ -262,7 +262,7 @@ memory_block_action(unsigned long phys_index, unsigned long action)
 			if (!pages_correctly_reserved(start_pfn, nr_pages))
 				return -EBUSY;
 
-			ret = online_pages(start_pfn, nr_pages);
+			ret = online_pages(start_pfn, nr_pages, online_type);
 			break;
 		case MEM_OFFLINE:
 			start_paddr = page_to_pfn(first_page) << PAGE_SHIFT;
@@ -279,7 +279,8 @@ memory_block_action(unsigned long phys_index, unsigned long action)
 }
 
 static int memory_block_change_state(struct memory_block *mem,
-		unsigned long to_state, unsigned long from_state_req)
+		unsigned long to_state, unsigned long from_state_req,
+		int online_type)
 {
 	int ret = 0;
 
@@ -293,7 +294,7 @@ static int memory_block_change_state(struct memory_block *mem,
 	if (to_state == MEM_OFFLINE)
 		mem->state = MEM_GOING_OFFLINE;
 
-	ret = memory_block_action(mem->start_section_nr, to_state);
+	ret = memory_block_action(mem->start_section_nr, to_state, online_type);
 
 	if (ret) {
 		mem->state = from_state_req;
@@ -325,10 +326,14 @@ store_mem_state(struct device *dev,
 
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
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 910550f..047cd1d 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -25,6 +25,13 @@ enum {
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
@@ -45,6 +52,10 @@ void pgdat_resize_init(struct pglist_data *pgdat)
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
@@ -70,7 +81,7 @@ extern int zone_grow_free_lists(struct zone *zone, unsigned long new_nr_pages);
 extern int zone_grow_waitqueues(struct zone *zone, unsigned long nr_pages);
 extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
 /* VM interface that may be used by firmware interface */
-extern int online_pages(unsigned long, unsigned long);
+extern int online_pages(unsigned long, unsigned long, int);
 extern void __offline_isolated_pages(unsigned long, unsigned long);
 
 typedef void (*online_page_callback_t)(struct page *page);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c44b39e..b5ee3db 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -210,6 +210,89 @@ static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
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
@@ -457,7 +540,7 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 }
 
 
-int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
+int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
 {
 	unsigned long onlined_pages = 0;
 	struct zone *zone;
@@ -467,6 +550,29 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	struct memory_notify arg;
 
 	lock_memory_hotplug();
+	/*
+	 * This doesn't need a lock to do pfn_to_page().
+	 * The section can't be removed here because of the
+	 * memory_block->state_mutex.
+	 */
+	zone = page_zone(pfn_to_page(pfn));
+
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
 	arg.status_change_nid = -1;
@@ -483,12 +589,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 		return ret;
 	}
 	/*
-	 * This doesn't need a lock to do pfn_to_page().
-	 * The section can't be removed here because of the
-	 * memory_block->state_mutex.
-	 */
-	zone = page_zone(pfn_to_page(pfn));
-	/*
 	 * If this zone is not populated, then it is not in zonelist.
 	 * This means the page allocator ignores this zone.
 	 * So, zonelist must be updated after online.
-- 
1.7.1
