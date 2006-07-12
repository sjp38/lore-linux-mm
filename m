From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:41:54 +0200
Message-Id: <20060712144154.16998.1788.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 25/39] mm: pgrep: documentation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

Documentation for the page replace framework.

Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

 Documentation/vm/pgrepment_api.txt |  216 +++++++++++++++++++++++++++++++++++++
 1 file changed, 216 insertions(+)

Index: linux-2.6/Documentation/vm/pgrepment_api.txt
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/Documentation/vm/pgrepment_api.txt	2006-07-12 16:09:19.000000000 +0200
@@ -0,0 +1,216 @@
+		Page Replacement Policy Interface
+
+Introduction
+============
+
+This document describes the page replacement interfaces used by the
+virtual memory subsystem.
+
+When the system's free memory runs below a certain threshold, an action
+must be initiated to reclaim memory for future use. The decision of
+which memory pages to evict is called the replacement policy.
+
+There are several types of reclaimable objects which live in the
+system's memory:
+
+a) file cache pages
+b) anonymous process pages
+c) shared memory (shm) pages
+d) SLAB cache pages, used for internal kernel objects such as the inode
+and dentry caches.
+
+The policy API abstracts the replacement structure for pagecache objects
+(items a) b) and c)), separating it from the reclaim code path.
+
+This allows maintenance of different policies to deal with different
+workload requirements.
+
+Zoned VM
+========
+
+In Linux, physical memory is managed separately into zones, because
+certain types of allocations are address constrained.
+
+The operating system has to support types of hardware which cannot
+access full 32-bit addresses, but are limited to an address mask. For
+instance, ISA devices can only address the lower 24-bits (hence their
+visilibity goes up to 16MB).
+
+Additionally, pages used for internal kernel data must be restricted to
+the direct kernel mapping, which is approximately 1GB in current default
+configurations.
+
+Different zones must be managed separately from the perspective of page
+reclaim path, because particular zones might suffer more pressure than
+others.
+
+This means that the page replacement structures have to be maintained
+separately for each zone.
+
+Description
+===========
+
+The page replacement policy interface consists off a set of operations
+which are invoked from the common VM code.
+
+As mentioned before, the policy specific data has to be maintained
+separately for each zone, therefore "struct zone" embeds the following
+data structure:
+
+	struct pgrep_data policy;
+
+Which is to be defined by the policy in a separate header file.
+
+At the moment, this data structure is guarded by the "zone->lru_lock"
+spinlock, thus shared by all policies.
+
+Initialization (invoked during system bootup)
+--------------
+
+ * void __init pgrep_init(void)
+
+Policy private initialization.
+
+ * void __init pgrep_init_zone(struct zone *)
+
+Initialize zone specific policy data.
+
+
+Methods called by the VM
+------------------------
+
+ * void pgrep_hint_active(struct page *);
+ * void pgrep_hint_use_once(struct page *);
+
+Give the policy hints as to the importance of the page. These hints can
+be viewed as initial priority of page, where active is +1 and use_once -1.
+
+
+ * void fastcall pgrep_add(struct page *);
+
+Insert page into per-CPU list(s), used for batching groups of pages to
+relief zone->lru_lock contention. Called during page instantiation.
+
+
+ * void pgrep_add_drain(void);
+ * void pgrep_add_drain_cpu(unsigned int);
+
+Drain the per-CPU lists(s), pushing pages to the actual cache.
+Called in locations where it is important to not have stale data
+into the per-CPU lists.
+
+
+ * void pagevec_pgrep_add(struct pagevec *);
+ * void __pagevec_pgrep_add(struct pagevec *);
+
+Insert a whole pagevec worth of pages directly.
+
+
+ * void pgrep_get_candidates(struct zone *, int, struct list_head *);
+
+Select candidates for eviction from the specified zone.
+
+@zone: which memory zone to scan for.
+@nr_to_scan: number of pages to scan.
+@page_list: list_head to add select pages
+
+Called by mm/vmscan.c::shrink_cache(), the main function used to
+evict pagecache pages from a specific zone.
+
+
+ * reclaim_t pgrep_reclaimable(struct page *);
+
+Determines wether a page is reclaimable, used by shrink_list().
+This function encapsulates the call to page_referenced.
+
+
+ * void pgrep_activate(struct page *);
+
+Callback used to let the policy know this page was referenced.
+
+
+ * void pgrep_put_candidates(struct zone *, struct list_head *);
+
+Put unfreeable pages back into the zone's cache mgmt structures.
+
+@zone: memory zone which pages belong
+@page_list: list of pages to reinsert
+
+
+ * void pgrep_remove(struct zone *, struct page *);
+
+Remove page from cache. This function clears the page state.
+
+
+ * int pgrep_isolate(struct page *);
+
+Isolate a specified page; ie. remove it from the cache mgmt structures without
+clearing its page state (used for page migration).
+
+
+ * void pgrep_reinsert(struct list_head *);
+
+Reinsert a list of pages previously isolated by pgrep_isolate().
+Remember that these pages still have their page state; this property
+distinguishes this function from pgrep_add().
+NOTE: the pages on the list need not be in the same zone.
+
+
+ * void __pgrep_rotate_reclaimable(struct zone *, struct page *);
+
+Place this page so that it will be in the next candidate batch.
+
+
+ * void pgrep_remember(struct zone *, struct page*);
+ * void pgrep_forget(struct address_space *, unsigned long);
+
+Hooks for nonresident page management. Allows the policy to remember and
+forget about pages that are no longer resident.
+
+ * void pgrep_show(struct zone *);
+ * void pgrep_zoneinfo(struct zone *, struct seq_file *);
+
+Prints zoneinfo in the various ways.
+
+* void __pgrep_counts(unsigned long *, unsigned long *,
+			     unsigned long *, struct pglist_data *);
+
+Gives 'active', 'inactive' and free count in pages for the selected pgdat.
+Where active/inactive are open for interpretation of the policy.
+
+ * unsigned long __pgrep_nr_pages(struct zone *);
+
+Gives the total number of pages currently managed by the page replacement
+policy.
+
+
+ * unsigned long __pgrep_nr_scan(struct zone *);
+
+Gives the number of pages needed to drive the scanning.
+
+Helpers
+-------
+
+Certain helpers are shared by all policies, follows a description of them:
+
+1) int should_reclaim_mapped(struct zone *);
+
+The point of this algorithm is to decide when to start reclaiming mapped
+memory instead of clean pagecache.
+
+Returns 1 if mapped pages should be candidates for reclaim, 0 otherwise.
+
+Page flags
+----------
+
+A number of bits in page->flags are reserved for the page replacement
+policies, they are:
+
+	PG_reclaim1	/* bit 6 */
+	PG_reclaim2	/* bit 20 */
+	PG_reclaim3	/* bit 21 */
+
+The policy private semantics of this bits are to be defined in
+the policy implementation. This bits are internal to the policy and as such
+should not be interpreted in any way by external code.
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
