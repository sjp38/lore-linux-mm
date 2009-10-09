Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F01416B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 16:38:09 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n99KZKF7031821
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 16:35:20 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n99Kc5V3219898
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 16:38:05 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n99Kc4nZ012124
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 16:38:05 -0400
Date: Fri, 9 Oct 2009 15:38:04 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH 1/2][v3] mm: add notifier in pageblock isolation for
	balloon drivers
Message-ID: <20091009203803.GC19114@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Gerald Schaefer <geralds@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robert Jennings <rcj@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Memory balloon drivers can allocate a large amount of memory which
is not movable but could be freed to accomodate memory hotplug remove.

Prior to calling the memory hotplug notifier chain the memory in
the pageblock is isolated.  Currently, if the migrate type is not
MIGRATE_MOVABLE the isolation will not proceed, causing the memory
removal for that page range to fail.

Rather than failing pageblock isolation if the migrateteype is not
MIGRATE_MOVABLE, this patch checks if all of the pages in the pageblock,
and not on the LRU, are owned by a registered balloon driver (or other
entity) using a notifier chain.  If all of the non-movable pages are
owned by a balloon, they can be freed later through the memory notifier
chain and the range can still be isolated in set_migratetype_isolate().

Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>

---

Testing:
 * With the patch memory remove succeeds for pageblocks containing balloon
    allocations.  The balloon driver frees pages in the ranges being
    taken offline.  Prior to the patch, pageblocks with balloon allocations
    could not be taken offline.
 * Tested with CONFIG_MEMORY_HOTPLUG_SPARSE=n to ensure that the patches
    did not affect that configuration.

Changes since v2:
 * comments cleaned up based on patch reviews.
 * documented variables in struct memory_isolate_notify.
 * made search for active pages in set_isolate_pageblock safe if
    CONFIG_HOLES_IN_ZONE is set.
 * changed notifier chain from BLOCKING to ATOMIC.
 * added check for pages on an LRU to be considered movable.
 
 drivers/base/memory.c  |   19 ++++++++++++++++
 include/linux/memory.h |   27 +++++++++++++++++++++++
 mm/page_alloc.c        |   57 +++++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 96 insertions(+), 7 deletions(-)

Index: b/drivers/base/memory.c
===================================================================
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -63,6 +63,20 @@ void unregister_memory_notifier(struct n
 }
 EXPORT_SYMBOL(unregister_memory_notifier);
 
+static ATOMIC_NOTIFIER_HEAD(memory_isolate_chain);
+
+int register_memory_isolate_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&memory_isolate_chain, nb);
+}
+EXPORT_SYMBOL(register_memory_isolate_notifier);
+
+void unregister_memory_isolate_notifier(struct notifier_block *nb)
+{
+	atomic_notifier_chain_unregister(&memory_isolate_chain, nb);
+}
+EXPORT_SYMBOL(unregister_memory_isolate_notifier);
+
 /*
  * register_memory - Setup a sysfs device for a memory block
  */
@@ -157,6 +171,11 @@ int memory_notify(unsigned long val, voi
 	return blocking_notifier_call_chain(&memory_chain, val, v);
 }
 
+int memory_isolate_notify(unsigned long val, void *v)
+{
+	return atomic_notifier_call_chain(&memory_isolate_chain, val, v);
+}
+
 /*
  * MEMORY_HOTPLUG depends on SPARSEMEM in mm/Kconfig, so it is
  * OK to have direct references to sparsemem variables in here.
Index: b/include/linux/memory.h
===================================================================
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -50,6 +50,19 @@ struct memory_notify {
 	int status_change_nid;
 };
 
+/*
+ * During pageblock isolation, count the number of pages within the
+ * range [start_pfn, start_pfn + nr_pages) which are owned by code
+ * in the notifier chain.
+ */
+#define MEM_ISOLATE_COUNT	(1<<0)
+
+struct memory_isolate_notify {
+	unsigned long start_pfn;	/* Start of range to check */
+	unsigned int nr_pages;		/* # pages in range to check */
+	unsigned int pages_found;	/* # pages owned found by callbacks */
+};
+
 struct notifier_block;
 struct mem_section;
 
@@ -76,14 +89,28 @@ static inline int memory_notify(unsigned
 {
 	return 0;
 }
+static inline int register_memory_isolate_notifier(struct notifier_block *nb)
+{
+	return 0;
+}
+static inline void unregister_memory_isolate_notifier(struct notifier_block *nb)
+{
+}
+static inline int memory_isolate_notify(unsigned long val, void *v)
+{
+	return 0;
+}
 #else
 extern int register_memory_notifier(struct notifier_block *nb);
 extern void unregister_memory_notifier(struct notifier_block *nb);
+extern int register_memory_isolate_notifier(struct notifier_block *nb);
+extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
 extern int register_new_memory(int, struct mem_section *);
 extern int unregister_memory_section(struct mem_section *);
 extern int memory_dev_init(void);
 extern int remove_memory_block(unsigned long, struct mem_section *, int);
 extern int memory_notify(unsigned long val, void *v);
+extern int memory_isolate_notify(unsigned long val, void *v);
 extern struct memory_block *find_memory_block(struct mem_section *);
 #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
 enum mem_add_context { BOOT, HOTPLUG };
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -48,6 +48,7 @@
 #include <linux/page_cgroup.h>
 #include <linux/debugobjects.h>
 #include <linux/kmemleak.h>
+#include <linux/memory.h>
 #include <trace/events/kmem.h>
 
 #include <asm/tlbflush.h>
@@ -5003,23 +5004,65 @@ void set_pageblock_flags_group(struct pa
 int set_migratetype_isolate(struct page *page)
 {
 	struct zone *zone;
-	unsigned long flags;
+	struct page *curr_page;
+	unsigned long flags, pfn, iter;
+	unsigned long immobile = 0;
+	struct memory_isolate_notify arg;
+	int notifier_ret;
 	int ret = -EBUSY;
 	int zone_idx;
 
 	zone = page_zone(page);
 	zone_idx = zone_idx(zone);
+
 	spin_lock_irqsave(&zone->lock, flags);
+	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
+	    zone_idx == ZONE_MOVABLE) {
+		ret = 0;
+		goto out;
+	}
+
+	pfn = page_to_pfn(page);
+	arg.start_pfn = pfn;
+	arg.nr_pages = pageblock_nr_pages;
+	arg.pages_found = 0;
+
 	/*
-	 * In future, more migrate types will be able to be isolation target.
+	 * It may be possible to isolate a pageblock even if the
+	 * migratetype is not MIGRATE_MOVABLE. The memory isolation
+	 * notifier chain is used by balloon drivers to return the
+	 * number of pages in a range that are held by the balloon
+	 * driver to shrink memory. If all the pages are accounted for
+	 * by balloons, are free, or on the LRU, isolation can continue.
+	 * Later, for example, when memory hotplug notifier runs, these
+	 * pages reported as "can be isolated" should be isolated(freed)
+	 * by the balloon driver through the memory notifier chain.
 	 */
-	if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE &&
-	    zone_idx != ZONE_MOVABLE)
+	notifier_ret = memory_isolate_notify(MEM_ISOLATE_COUNT, &arg);
+	notifier_ret = notifier_to_errno(notifier_ret);
+	if (notifier_ret || !arg.pages_found)
 		goto out;
-	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
-	move_freepages_block(zone, page, MIGRATE_ISOLATE);
-	ret = 0;
+
+	for (iter = pfn; iter < (pfn + pageblock_nr_pages); iter++) {
+		if (!pfn_valid_within(pfn))
+			continue;
+
+		curr_page = pfn_to_page(iter);
+		if (!page_count(curr_page) || PageLRU(curr_page))
+			continue;
+
+		immobile++;
+	}
+
+	if (arg.pages_found == immobile)
+		ret = 0;
+
 out:
+	if (!ret) {
+		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
+		move_freepages_block(zone, page, MIGRATE_ISOLATE);
+	}
+
 	spin_unlock_irqrestore(&zone->lock, flags);
 	if (!ret)
 		drain_all_pages();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
