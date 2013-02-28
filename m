Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 710B76B000E
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:30 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 16:27:29 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E85B438C8022
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:04 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SLR4hE14090442
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:04 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SLR38g020204
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:03 -0500
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 15/24] mm: add memlayout & dnuma to track pfn->nid & transplant pages between nodes
Date: Thu, 28 Feb 2013 13:26:12 -0800
Message-Id: <1362086781-16725-6-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, David Hansen <dave@linux.vnet.ibm.com>

On certain systems, the hypervisor can (and will) relocate physical
addresses as seen in a VM between real NUMA nodes. For example, IBM's
Power systems which are using PHYP (their proprietary hypervisor).

This change set introduces the infrastructure for tracking & dynamically
changing "memory layouts" (or "memlayouts"): the mapping between page
ranges & the actual backing NUMA node.

A memlayout is an rbtree which maps pfns (really, ranges of pfns) to a
node. This mapping (combined with the LookupNode pageflag) is used to
"transplant" (move pages between nodes) pages when they are freed back
to the page allocator.

Additionally, when a new memlayout is commited the currently free pages
that are now in the wrong zone's freelist are immidiately transplanted.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/dnuma.h     |  96 +++++++++++++
 include/linux/memlayout.h | 110 +++++++++++++++
 mm/Kconfig                |  19 +++
 mm/Makefile               |   1 +
 mm/dnuma.c                | 349 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/memlayout.c            | 238 +++++++++++++++++++++++++++++++
 6 files changed, 813 insertions(+)
 create mode 100644 include/linux/dnuma.h
 create mode 100644 include/linux/memlayout.h
 create mode 100644 mm/dnuma.c
 create mode 100644 mm/memlayout.c

diff --git a/include/linux/dnuma.h b/include/linux/dnuma.h
new file mode 100644
index 0000000..8f5cbf9
--- /dev/null
+++ b/include/linux/dnuma.h
@@ -0,0 +1,96 @@
+#ifndef LINUX_DNUMA_H_
+#define LINUX_DNUMA_H_
+
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/memlayout.h>
+#include <linux/spinlock.h>
+#include <linux/atomic.h>
+
+#ifdef CONFIG_DYNAMIC_NUMA
+/* Must be called _before_ setting a new_ml to the pfn_to_node_map */
+void dnuma_online_required_nodes_and_zones(struct memlayout *new_ml);
+
+/* Must be called _after_ setting a new_ml to the pfn_to_node_map */
+void dnuma_move_free_pages(struct memlayout *new_ml);
+void dnuma_mark_page_range(struct memlayout *new_ml);
+
+static inline bool dnuma_is_active(void)
+{
+	struct memlayout *ml;
+	bool ret;
+
+	rcu_read_lock();
+	ml = rcu_dereference(pfn_to_node_map);
+	ret = ml && (ml->type != ML_INITIAL);
+	rcu_read_unlock();
+
+	return ret;
+}
+
+static inline bool dnuma_has_memlayout(void)
+{
+	return !!rcu_access_pointer(pfn_to_node_map);
+}
+
+static inline int dnuma_page_needs_move(struct page *page)
+{
+	int new_nid, old_nid;
+
+	if (!TestClearPageLookupNode(page))
+		return NUMA_NO_NODE;
+
+	/* FIXME: this does rcu_lock, deref, unlock */
+	if (WARN_ON(!dnuma_is_active()))
+		return NUMA_NO_NODE;
+
+	/* FIXME: and so does this (rcu lock, deref, and unlock) */
+	new_nid = memlayout_pfn_to_nid(page_to_pfn(page));
+	old_nid = page_to_nid(page);
+
+	if (new_nid == NUMA_NO_NODE) {
+		pr_alert("dnuma: pfn %05lx has moved from node %d to a non-memlayout range.\n",
+				page_to_pfn(page), old_nid);
+		return NUMA_NO_NODE;
+	}
+
+	if (new_nid == old_nid)
+		return NUMA_NO_NODE;
+
+	if (WARN_ON(!zone_is_initialized(nid_zone(new_nid, page_zonenum(page)))))
+		return NUMA_NO_NODE;
+
+	return new_nid;
+}
+
+void dnuma_post_free_to_new_zone(struct page *page, int order);
+void dnuma_prior_free_to_new_zone(struct page *page, int order,
+				  struct zone *dest_zone,
+				  int dest_nid);
+
+#else /* !defined CONFIG_DYNAMIC_NUMA */
+
+static inline bool dnuma_is_active(void)
+{
+	return false;
+}
+
+static inline void dnuma_prior_free_to_new_zone(struct page *page, int order,
+						struct zone *dest_zone,
+						int dest_nid)
+{
+	BUG();
+}
+
+static inline void dnuma_post_free_to_new_zone(struct page *page, int order)
+{
+	BUG();
+}
+
+static inline int dnuma_page_needs_move(struct page *page)
+{
+	return NUMA_NO_NODE;
+}
+#endif /* !defined CONFIG_DYNAMIC_NUMA */
+
+#endif /* defined LINUX_DNUMA_H_ */
diff --git a/include/linux/memlayout.h b/include/linux/memlayout.h
new file mode 100644
index 0000000..eeb88e0
--- /dev/null
+++ b/include/linux/memlayout.h
@@ -0,0 +1,110 @@
+#ifndef LINUX_MEMLAYOUT_H_
+#define LINUX_MEMLAYOUT_H_
+
+#include <linux/memblock.h> /* __init_memblock */
+#include <linux/mm.h>       /* NODE_DATA, page_zonenum */
+#include <linux/mmzone.h>   /* pfn_to_nid */
+#include <linux/rbtree.h>
+#include <linux/types.h>    /* size_t */
+
+#ifdef CONFIG_DYNAMIC_NUMA
+# ifdef NODE_NOT_IN_PAGE_FLAGS
+#  error "CONFIG_DYNAMIC_NUMA requires the NODE is in page flags. Try freeing up some flags by decreasing the maximum number of NUMA nodes, or switch to sparsmem-vmemmap"
+# endif
+
+enum memlayout_type {
+	ML_INITIAL,
+	ML_DNUMA,
+	ML_NUM_TYPES
+};
+
+/*
+ * - rbtree of {node, start, end}.
+ * - assumes no 'ranges' overlap.
+ */
+struct rangemap_entry {
+	struct rb_node node;
+	unsigned long pfn_start;
+	/* @pfn_end: inclusive, not stored as a count to make the lookup
+	 *           faster
+	 */
+	unsigned long pfn_end;
+	int nid;
+};
+
+struct memlayout {
+	struct rb_root root;
+	enum memlayout_type type;
+
+	/*
+	 * When a memlayout is commited, 'cache' is accessed (the field is read
+	 * from & written to) by multiple tasks without additional locking
+	 * (other than the rcu locking for accessing the memlayout).
+	 *
+	 * Do not assume that it will not change. Use ACCESS_ONCE() to avoid
+	 * potential races.
+	 */
+	struct rangemap_entry *cache;
+
+#ifdef CONFIG_DNUMA_DEBUGFS
+	unsigned seq;
+	struct dentry *d;
+#endif
+};
+
+extern __rcu struct memlayout *pfn_to_node_map;
+
+/* FIXME: overflow potential in completion check */
+#define ml_for_each_pfn_in_range(rme, pfn)	\
+	for (pfn = rme->pfn_start;		\
+	     pfn <= rme->pfn_end;		\
+	     pfn++)
+
+#define ml_for_each_range(ml, rme) \
+	for (rme = rb_entry(rb_first(&ml->root), typeof(*rme), node);	\
+	     &rme->node;						\
+	     rme = rb_entry(rb_next(&rme->node), typeof(*rme), node))
+
+#define rme_next(rme) rb_entry(rb_next(&rme->node), typeof(*rme), node)
+
+struct memlayout *memlayout_create(enum memlayout_type);
+void              memlayout_destroy(struct memlayout *ml);
+
+/* Callers accesing the same memlayout are assumed to be serialized */
+int memlayout_new_range(struct memlayout *ml,
+		unsigned long pfn_start, unsigned long pfn_end, int nid);
+
+/* only queries the memlayout tracking structures. */
+int memlayout_pfn_to_nid(unsigned long pfn);
+
+/* Put ranges added by memlayout_new_range() into use by
+ * memlayout_pfn_get_nid() and retire old ranges.
+ *
+ * No modifications to a memlayout can be made after it is commited.
+ *
+ * sleeps via syncronize_rcu().
+ *
+ * memlayout takes ownership of ml, no futher mamlayout_new_range's should be
+ * issued
+ */
+void memlayout_commit(struct memlayout *ml);
+
+/* Sets up an inital memlayout in early boot.
+ * A weak default which uses memblock is provided.
+ */
+void memlayout_global_init(void);
+
+#else /* ! defined(CONFIG_DYNAMIC_NUMA) */
+
+/* memlayout_new_range() & memlayout_commit() are purposefully omitted */
+
+static inline void memlayout_global_init(void)
+{}
+
+static inline int memlayout_pfn_to_nid(unsigned long pfn)
+{
+	return NUMA_NO_NODE;
+}
+#endif /* !defined(CONFIG_DYNAMIC_NUMA) */
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 2c7aea7..7209ea5 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -169,6 +169,25 @@ config MOVABLE_NODE
 config HAVE_BOOTMEM_INFO_NODE
 	def_bool n
 
+config DYNAMIC_NUMA
+	bool "Dynamic Numa: Allow NUMA layout to change after boot time"
+	depends on NUMA
+	depends on !DISCONTIGMEM
+	depends on MEMORY_HOTPLUG # locking + mem_online_node().
+	help
+	 Dynamic Numa (DNUMA) allows the movement of pages between NUMA nodes at
+	 run time.
+
+	 Typically, this is used on systems running under a hypervisor which
+	 may move the running VM based on the hypervisors needs. On such a
+	 system, this config option enables Linux to update it's knowledge of
+	 the memory layout.
+
+	 If the feature is not used but is enabled, there is a small amount of overhead (an
+	 additional pointer NULL check) added to all page frees.
+
+	 Choose Y if you have one of these systems (XXX: which ones?), otherwise choose N.
+
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
diff --git a/mm/Makefile b/mm/Makefile
index 3a46287..82fe7c9b 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -58,3 +58,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
+obj-$(CONFIG_DYNAMIC_NUMA) += dnuma.o memlayout.o
diff --git a/mm/dnuma.c b/mm/dnuma.c
new file mode 100644
index 0000000..8bc81b2
--- /dev/null
+++ b/mm/dnuma.c
@@ -0,0 +1,349 @@
+#define pr_fmt(fmt) "dnuma: " fmt
+
+#include <linux/dnuma.h>
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/atomic.h>
+#include <linux/memory.h>
+
+#include "internal.h"
+
+/* Issues due to pageflag_blocks attached to zones with Discontig Mem (&
+ * Flatmem??).
+ * - Need atomicity over the combination of commiting a new memlayout and
+ *   removing the pages from free lists.
+ */
+
+/* XXX: "present pages" is guarded by lock_memory_hotplug(), not the spanlock.
+ * Need to change all users. */
+void adjust_zone_present_pages(struct zone *zone, long delta)
+{
+	unsigned long flags;
+	pgdat_resize_lock(zone->zone_pgdat, &flags);
+	zone_span_writelock(zone);
+
+	zone->managed_pages += delta;
+	zone->present_pages += delta;
+	zone->zone_pgdat->node_present_pages += delta;
+
+	zone_span_writeunlock(zone);
+	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+}
+
+/* - must be called under lock_memory_hotplug() */
+/* TODO: avoid iterating over all PFNs. */
+void dnuma_online_required_nodes_and_zones(struct memlayout *new_ml)
+{
+	struct rangemap_entry *rme;
+	ml_for_each_range(new_ml, rme) {
+		unsigned long pfn;
+		int nid = rme->nid;
+
+		if (!node_online(nid)) {
+			pr_info("onlining node %d [start]\n", nid);
+
+			/* XXX: somewhere in here do a memory online notify: we
+			 * aren't really onlining memory, but some code uses
+			 * memory online notifications to tell if new nodes
+			 * have been created.
+			 *
+			 * Also note that the notifyers expect to be able to do
+			 * allocations, ie we must allow for might_sleep() */
+			{
+				int ret;
+
+				/* memory_notify() expects:
+				 *	- to add pages at the same time
+				 *	- to add zones at the same time
+				 * We can do neither of these things.
+				 *
+				 * FIXME: Right now we just set the things
+				 * needed by the slub handler.
+				 */
+				struct memory_notify arg = {
+					.status_change_nid_normal = nid,
+				};
+
+				ret = memory_notify(MEM_GOING_ONLINE, &arg);
+				ret = notifier_to_errno(ret);
+				if (WARN_ON(ret)) {
+					/* XXX: other stuff will bug out if we
+					 * keep going, need to actually cancel
+					 * memlayout changes
+					 */
+					memory_notify(MEM_CANCEL_ONLINE, &arg);
+				}
+			}
+
+			/* Consult hotadd_new_pgdat() */
+			__mem_online_node(nid);
+			if (!node_online(nid)) {
+				pr_alert("node %d not online after onlining\n", nid);
+			}
+
+			pr_info("onlining node %d [complete]\n", nid);
+		}
+
+		/* Determine the zones required */
+		for (pfn = rme->pfn_start; pfn <= rme->pfn_end; pfn++) {
+			struct zone *zone;
+			if (!pfn_valid(pfn))
+				continue;
+
+			zone = nid_zone(nid, page_zonenum(pfn_to_page(pfn)));
+			/* XXX: we (dnuma paths) can handle this (there will
+			 * just be quite a few WARNS in the logs), but if we
+			 * are indicating error above, should we bail out here
+			 * as well? */
+			WARN_ON(ensure_zone_is_initialized(zone, 0, 0));
+		}
+	}
+}
+
+/*
+ * Cannot be folded into dnuma_move_unallocated_pages() because unmarked pages
+ * could be freed back into the zone as dnuma_move_unallocated_pages() was in
+ * the process of iterating over it.
+ */
+void dnuma_mark_page_range(struct memlayout *new_ml)
+{
+	struct rangemap_entry *rme;
+	ml_for_each_range(new_ml, rme) {
+		unsigned long pfn;
+		for (pfn = rme->pfn_start; pfn <= rme->pfn_end; pfn++) {
+			if (!pfn_valid(pfn))
+				continue;
+			/* FIXME: should we be skipping compound / buddied
+			 *        pages? */
+			/* FIXME: if PageReserved(), can we just poke the nid
+			 *        directly? Should we? */
+			SetPageLookupNode(pfn_to_page(pfn));
+		}
+	}
+}
+
+#if 0
+static void node_states_set_node(int node, struct memory_notify *arg)
+{
+	if (arg->status_change_nid_normal >= 0)
+		node_set_state(node, N_NORMAL_MEMORY);
+
+	if (arg->status_change_nid_high >= 0)
+		node_set_state(node, N_HIGH_MEMORY);
+
+	node_set_state(node, N_MEMORY);
+}
+#endif
+
+void dnuma_post_free_to_new_zone(struct page *page, int order)
+{
+	adjust_zone_present_pages(page_zone(page), (1 << order));
+}
+
+static void dnuma_prior_return_to_new_zone(struct page *page, int order,
+					   struct zone *dest_zone,
+					   int dest_nid)
+{
+	int i;
+	unsigned long pfn = page_to_pfn(page);
+
+	grow_pgdat_and_zone(dest_zone, pfn, pfn + (1UL << order));
+
+	for (i = 0; i < 1UL << order; i++)
+		set_page_node(&page[i], dest_nid);
+}
+
+static void clear_lookup_node(struct page *page, int order)
+{
+	int i;
+	for (i = 0; i < 1UL << order; i++)
+		ClearPageLookupNode(&page[i]);
+}
+
+/* Does not assume it is called with any locking (but can be called with zone
+ * locks held, if needed) */
+void dnuma_prior_free_to_new_zone(struct page *page, int order,
+				  struct zone *dest_zone,
+				  int dest_nid)
+{
+	struct zone *curr_zone = page_zone(page);
+
+	/* XXX: Fiddle with 1st zone's locks */
+	adjust_zone_present_pages(curr_zone, -(1UL << order));
+
+	/* XXX: fiddles with 2nd zone's locks */
+	dnuma_prior_return_to_new_zone(page, order, dest_zone, dest_nid);
+}
+
+/* must be called with zone->lock held and memlayout's update_lock held */
+static void remove_free_pages_from_zone(struct zone *zone, struct page *page, int order)
+{
+	/* zone free stats */
+	zone->free_area[order].nr_free--;
+	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+	adjust_zone_present_pages(zone, -(1UL << order));
+
+	list_del(&page->lru);
+	__ClearPageBuddy(page);
+
+	/* Allowed because we hold the memlayout update_lock. */
+	clear_lookup_node(page, order);
+
+	/* XXX: can we shrink spanned_pages & start_pfn without too much work?
+	 *  - not crutial because having a
+	 *    larger-than-necessary span simply means that more
+	 *    PFNs are iterated over.
+	 *  - would be nice to be able to do this to cut down
+	 *    on overhead caused by PFN iterators.
+	 */
+}
+
+/*
+ * __ref is to allow (__meminit) zone_pcp_update(), which we will have because
+ * DYNAMIC_NUMA depends on MEMORY_HOTPLUG (and all the MEMORY_HOTPLUG comments
+ * indicate __meminit is allowed when they are enabled).
+ */
+static void __ref add_free_page_to_node(int dest_nid, struct page *page, int order)
+{
+	bool need_zonelists_rebuild = false;
+	struct zone *dest_zone = nid_zone(dest_nid, page_zonenum(page));
+	VM_BUG_ON(!zone_is_initialized(dest_zone));
+
+	if (zone_is_empty(dest_zone))
+		need_zonelists_rebuild = true;
+
+	/* Add page to new zone */
+	dnuma_prior_return_to_new_zone(page, order, dest_zone, dest_nid);
+	return_pages_to_zone(page, order, dest_zone);
+	dnuma_post_free_to_new_zone(page, order);
+
+	/* XXX: fixme, there are other states that need fixing up */
+	if (!node_state(dest_nid, N_MEMORY))
+		node_set_state(dest_nid, N_MEMORY);
+
+	if (need_zonelists_rebuild) {
+		/* XXX: also does stop_machine() */
+		//zone_pcp_reset(zone);
+		/* XXX: why is this locking actually needed? */
+		mutex_lock(&zonelists_mutex);
+		//build_all_zonelists(NULL, NULL);
+		build_all_zonelists(NULL, dest_zone);
+		mutex_unlock(&zonelists_mutex);
+	} else
+		/* FIXME: does stop_machine() after EVERY SINGLE PAGE */
+		/* XXX: this is probably wrong. What does "update" actually
+		 * indicate in zone_pcp terms? */
+		zone_pcp_update(dest_zone);
+}
+
+static struct rangemap_entry *add_split_pages_to_zones(
+		struct rangemap_entry *first_rme,
+		struct page *page, int order)
+{
+	int i;
+	struct rangemap_entry *rme = first_rme;
+	for (i = 0; i < (1 << order); i++) {
+		unsigned long pfn = page_to_pfn(page);
+		while (pfn > rme->pfn_end) {
+			rme = rme_next(rme);
+		}
+
+		add_free_page_to_node(rme->nid, page + i, 0);
+	}
+
+	return rme;
+}
+
+void dnuma_move_free_pages(struct memlayout *new_ml)
+{
+	/* FIXME: how does this removal of pages from a zone interact with
+	 * migrate types? ISOLATION? */
+	struct rangemap_entry *rme;
+	ml_for_each_range(new_ml, rme) {
+		unsigned long pfn = rme->pfn_start;
+		int range_nid;
+		struct page *page;
+new_rme:
+		range_nid = rme->nid;
+
+		for (; pfn <= rme->pfn_end; pfn++) {
+			struct zone *zone;
+			int page_nid, order;
+			unsigned long flags, last_pfn, first_pfn;
+			if (!pfn_valid(pfn))
+				continue;
+
+			page = pfn_to_page(pfn);
+#if 0
+			/* XXX: can we ensure this is safe? Pages marked
+			 * reserved could be freed into the page allocator if
+			 * they mark memory areas that were allocated via
+			 * earlier allocators. */
+			if (PageReserved(page)) {
+				set_page_node(page, range_nid);
+				/* TODO: adjust spanned_pages & present_pages & start_pfn. */
+			}
+#endif
+
+			/* Currently allocated, will be fixed up when freed. */
+			if (!PageBuddy(page))
+				continue;
+
+			page_nid = page_to_nid(page);
+			if (page_nid == range_nid)
+				continue;
+
+			zone = page_zone(page);
+			spin_lock_irqsave(&zone->lock, flags);
+
+			/* Someone allocated it since we last checked. It will
+			 * be fixed up when it is freed */
+			if (!PageBuddy(page))
+				goto skip_unlock;
+
+			/* It has already been transplanted "somewhere",
+			 * somewhere should be the proper zone. */
+			if (page_zone(page) != zone) {
+				VM_BUG_ON(zone != nid_zone(range_nid, page_zonenum(page)));
+				goto skip_unlock;
+			}
+
+			order = page_order(page);
+			first_pfn = pfn & ~((1 << order) - 1);
+			last_pfn  = pfn |  ((1 << order) - 1);
+			if (WARN(pfn != first_pfn, "pfn %05lx is not first_pfn %05lx\n",
+							pfn, first_pfn)) {
+				pfn = last_pfn;
+				goto skip_unlock;
+			}
+
+			if (last_pfn > rme->pfn_end) {
+				/* this higher order page doesn't fit into the
+				 * current range even though it starts there.
+				 */
+				pr_warn("high-order page from pfn %05lx to %05lx extends beyond end of rme {%05lx - %05lx}:%d\n",
+						first_pfn, last_pfn,
+						rme->pfn_start, rme->pfn_end,
+						rme->nid);
+
+				remove_free_pages_from_zone(zone, page, order);
+				spin_unlock_irqrestore(&zone->lock, flags);
+
+				rme = add_split_pages_to_zones(rme, page, order);
+				pfn = last_pfn + 1;
+				goto new_rme;
+			}
+
+			remove_free_pages_from_zone(zone, page, order);
+			spin_unlock_irqrestore(&zone->lock, flags);
+
+			add_free_page_to_node(range_nid, page, order);
+			pfn = last_pfn;
+			continue;
+skip_unlock:
+			spin_unlock_irqrestore(&zone->lock, flags);
+		}
+	}
+}
diff --git a/mm/memlayout.c b/mm/memlayout.c
new file mode 100644
index 0000000..69222ac
--- /dev/null
+++ b/mm/memlayout.c
@@ -0,0 +1,238 @@
+/*
+ * memlayout - provides a mapping of PFN ranges to nodes with the requirements
+ * that looking up a node from a PFN is fast, and changes to the mapping will
+ * occour relatively infrequently.
+ *
+ */
+#define pr_fmt(fmt) "memlayout: " fmt
+
+#include <linux/dnuma.h>
+#include <linux/export.h>
+#include <linux/memblock.h>
+#include <linux/printk.h>
+#include <linux/rbtree.h>
+#include <linux/rcupdate.h>
+#include <linux/slab.h>
+
+/* protected by memlayout_lock */
+__rcu struct memlayout *pfn_to_node_map;
+DEFINE_MUTEX(memlayout_lock);
+
+static void free_rme_tree(struct rb_root *root)
+{
+	struct rangemap_entry *pos, *n;
+	rbtree_postorder_for_each_entry_safe(pos, n, root, node) {
+		kfree(pos);
+	}
+}
+
+static void ml_destroy_mem(struct memlayout *ml)
+{
+	if (!ml)
+		return;
+	free_rme_tree(&ml->root);
+	kfree(ml);
+}
+
+static int find_insertion_point(struct memlayout *ml, unsigned long pfn_start,
+		unsigned long pfn_end, int nid, struct rb_node ***o_new,
+		struct rb_node **o_parent)
+{
+	struct rb_node **new = &ml->root.rb_node, *parent = NULL;
+	struct rangemap_entry *rme;
+	pr_debug("adding range: {%lX-%lX}:%d\n", pfn_start, pfn_end, nid);
+	while (*new) {
+		rme = rb_entry(*new, typeof(*rme), node);
+
+		parent = *new;
+		if (pfn_end < rme->pfn_start && pfn_start < rme->pfn_end)
+			new = &((*new)->rb_left);
+		else if (pfn_start > rme->pfn_end && pfn_end > rme->pfn_end)
+			new = &((*new)->rb_right);
+		else {
+			/* an embedded region, need to use an interval or
+			 * sequence tree. */
+			pr_warn("tried to embed {%lX,%lX}:%d inside {%lX-%lX}:%d\n",
+				 pfn_start, pfn_end, nid,
+				 rme->pfn_start, rme->pfn_end, rme->nid);
+			return 1;
+		}
+	}
+
+	*o_new = new;
+	*o_parent = parent;
+	return 0;
+}
+
+int memlayout_new_range(struct memlayout *ml, unsigned long pfn_start,
+		unsigned long pfn_end, int nid)
+{
+	struct rb_node **new, *parent;
+	struct rangemap_entry *rme;
+
+	if (WARN_ON(nid < 0))
+		return -EINVAL;
+	if (WARN_ON(nid >= MAX_NUMNODES))
+		return -EINVAL;
+
+	if (find_insertion_point(ml, pfn_start, pfn_end, nid, &new, &parent))
+		return 1;
+
+	rme = kmalloc(sizeof(*rme), GFP_KERNEL);
+	if (!rme)
+		return -ENOMEM;
+
+	rme->pfn_start = pfn_start;
+	rme->pfn_end = pfn_end;
+	rme->nid = nid;
+
+	rb_link_node(&rme->node, parent, new);
+	rb_insert_color(&rme->node, &ml->root);
+	return 0;
+}
+
+static inline bool rme_bounds_pfn(struct rangemap_entry *rme, unsigned long pfn)
+{
+	return rme->pfn_start <= pfn && pfn <= rme->pfn_end;
+}
+
+int memlayout_pfn_to_nid(unsigned long pfn)
+{
+	struct rb_node *node;
+	struct memlayout *ml;
+	struct rangemap_entry *rme;
+	rcu_read_lock();
+	ml = rcu_dereference(pfn_to_node_map);
+	if (!ml || (ml->type == ML_INITIAL))
+		goto out;
+
+	rme = ACCESS_ONCE(ml->cache);
+	if (rme && rme_bounds_pfn(rme, pfn)) {
+		rcu_read_unlock();
+		return rme->nid;
+	}
+
+	node = ml->root.rb_node;
+	while (node) {
+		struct rangemap_entry *rme = rb_entry(node, typeof(*rme), node);
+		bool greater_than_start = rme->pfn_start <= pfn;
+		bool less_than_end = pfn <= rme->pfn_end;
+
+		if (greater_than_start && !less_than_end)
+			node = node->rb_right;
+		else if (less_than_end && !greater_than_start)
+			node = node->rb_left;
+		else {
+			/* greater_than_start && less_than_end.
+			 *  the case (!greater_than_start  && !less_than_end)
+			 *  is impossible */
+			int nid = rme->nid;
+			ACCESS_ONCE(ml->cache) = rme;
+			rcu_read_unlock();
+			return nid;
+		}
+	}
+
+out:
+	rcu_read_unlock();
+	return NUMA_NO_NODE;
+}
+
+void memlayout_destroy(struct memlayout *ml)
+{
+	ml_destroy_mem(ml);
+}
+
+struct memlayout *memlayout_create(enum memlayout_type type)
+{
+	struct memlayout *ml;
+
+	if (WARN_ON(type < 0 || type >= ML_NUM_TYPES))
+		return NULL;
+
+	ml = kmalloc(sizeof(*ml), GFP_KERNEL);
+	if (!ml)
+		return NULL;
+
+	ml->root = RB_ROOT;
+	ml->type = type;
+	ml->cache = NULL;
+
+	return ml;
+}
+
+void memlayout_commit(struct memlayout *ml)
+{
+	struct memlayout *old_ml;
+
+	if (ml->type == ML_INITIAL) {
+		if (WARN(dnuma_has_memlayout(), "memlayout marked first is not first, ignoring.\n")) {
+			memlayout_destroy(ml);
+			return;
+		}
+
+		mutex_lock(&memlayout_lock);
+		rcu_assign_pointer(pfn_to_node_map, ml);
+		mutex_unlock(&memlayout_lock);
+		return;
+	}
+
+	lock_memory_hotplug();
+	dnuma_online_required_nodes_and_zones(ml);
+	unlock_memory_hotplug();
+
+	mutex_lock(&memlayout_lock);
+	old_ml = rcu_dereference_protected(pfn_to_node_map,
+			mutex_is_locked(&memlayout_lock));
+
+	rcu_assign_pointer(pfn_to_node_map, ml);
+
+	synchronize_rcu();
+	memlayout_destroy(old_ml);
+
+	/* Must be called only after the new value for pfn_to_node_map has
+	 * propogated to all tasks, otherwise some pages may lookup the old
+	 * pfn_to_node_map on free & not transplant themselves to their new-new
+	 * node. */
+	dnuma_mark_page_range(ml);
+
+	/* Do this after the free path is set up so that pages are free'd into
+	 * their "new" zones so that after this completes, no free pages in the
+	 * wrong zone remain. */
+	dnuma_move_free_pages(ml);
+
+	/* All new _non pcp_ page allocations now match the memlayout*/
+	drain_all_pages();
+	/* All new page allocations now match the memlayout */
+
+	mutex_unlock(&memlayout_lock);
+}
+
+/*
+ * The default memlayout global initializer, using memblock to determine affinities
+ * reqires: slab_is_available() && memblock is not (yet) freed.
+ * sleeps: definitely: memlayout_commit() -> synchronize_rcu()
+ *	   potentially: kmalloc()
+ */
+__weak __meminit
+void memlayout_global_init(void)
+{
+	int i, nid, errs = 0;
+	unsigned long start, end;
+	struct memlayout *ml = memlayout_create(ML_INITIAL);
+	if (WARN_ON(!ml))
+		return;
+
+	for_each_mem_pfn_range(i, MAX_NUMNODES, &start, &end, &nid) {
+		int r = memlayout_new_range(ml, start, end - 1, nid);
+		if (r) {
+			pr_err("failed to add range [%05lx, %05lx] in node %d to mapping\n",
+					start, end, nid);
+			errs++;
+		} else
+			pr_devel("added range [%05lx, %05lx] in node %d\n",
+					start, end, nid);
+	}
+
+	memlayout_commit(ml);
+}
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
