Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 2791A6B009F
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:19 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 31/36] autonuma: shrink the per-page page_autonuma struct size
Date: Wed, 22 Aug 2012 16:59:15 +0200
Message-Id: <1345647560-30387-32-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

>From 32 to 12 bytes, so the AutoNUMA memory footprint is reduced to
0.29% of RAM.

This however will fail to migrate pages above a 16 Terabyte offset
from the start of each node (migration failure isn't fatal, simply
those pages will not follow the CPU, a warning will be printed in the
log just once in that case).

AutoNUMA will also fail to build if there are more than (2**15)-1
nodes supported by the MAX_NUMNODES at build time (it would be easy to
relax it to (2**16)-1 nodes without increasing the memory footprint,
but it's not even worth it, so let's keep the negative space reserved
for now).

This means the max RAM configuration fully supported by AutoNUMA
becomes AUTONUMA_LIST_MAX_PFN_OFFSET multiplied by 32767 nodes
multiplied by the PAGE_SIZE (assume 4096 here, but for some archs it's
bigger).

4096*32767*(0xffffffff-3)>>(10*5) = 511 PetaBytes.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma_list.h  |  100 +++++++++++++++++++++++
 include/linux/autonuma_types.h |   45 ++++++-----
 include/linux/mmzone.h         |    3 +-
 include/linux/page_autonuma.h  |    2 +-
 mm/Makefile                    |    2 +-
 mm/autonuma.c                  |   93 ++++++++++++++++------
 mm/autonuma_list.c             |  169 ++++++++++++++++++++++++++++++++++++++++
 mm/page_autonuma.c             |   24 +++---
 8 files changed, 380 insertions(+), 58 deletions(-)
 create mode 100644 include/linux/autonuma_list.h
 create mode 100644 mm/autonuma_list.c

diff --git a/include/linux/autonuma_list.h b/include/linux/autonuma_list.h
new file mode 100644
index 0000000..b77acb4
--- /dev/null
+++ b/include/linux/autonuma_list.h
@@ -0,0 +1,100 @@
+#ifndef __AUTONUMA_LIST_H
+#define __AUTONUMA_LIST_H
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+
+typedef uint32_t autonuma_list_entry;
+#define AUTONUMA_LIST_MAX_PFN_OFFSET	(AUTONUMA_LIST_HEAD-3)
+#define AUTONUMA_LIST_POISON1		(AUTONUMA_LIST_HEAD-2)
+#define AUTONUMA_LIST_POISON2		(AUTONUMA_LIST_HEAD-1)
+#define AUTONUMA_LIST_HEAD		((uint32_t)UINT_MAX)
+
+struct autonuma_list_head {
+	autonuma_list_entry anl_next_pfn;
+	autonuma_list_entry anl_prev_pfn;
+};
+
+static inline void AUTONUMA_INIT_LIST_HEAD(struct autonuma_list_head *anl)
+{
+	anl->anl_next_pfn = AUTONUMA_LIST_HEAD;
+	anl->anl_prev_pfn = AUTONUMA_LIST_HEAD;
+}
+
+/* abstraction conversion methods */
+extern struct page *autonuma_list_entry_to_page(int nid,
+					autonuma_list_entry pfn_offset);
+extern autonuma_list_entry autonuma_page_to_list_entry(int page_nid,
+						       struct page *page);
+extern struct autonuma_list_head *__autonuma_list_head(int page_nid,
+					struct autonuma_list_head *head,
+					autonuma_list_entry pfn_offset);
+
+extern bool __autonuma_list_add(int page_nid,
+				struct page *page,
+				struct autonuma_list_head *head,
+				autonuma_list_entry prev,
+				autonuma_list_entry next);
+
+/*
+ * autonuma_list_add - add a new entry
+ *
+ * Insert a new entry after the specified head.
+ */
+static inline bool autonuma_list_add(int page_nid,
+				     struct page *page,
+				     autonuma_list_entry entry,
+				     struct autonuma_list_head *head)
+{
+	struct autonuma_list_head *entry_head;
+	entry_head = __autonuma_list_head(page_nid, head, entry);
+	return __autonuma_list_add(page_nid, page, head,
+				   entry, entry_head->anl_next_pfn);
+}
+
+/*
+ * autonuma_list_add_tail - add a new entry
+ *
+ * Insert a new entry before the specified head.
+ * This is useful for implementing queues.
+ */
+static inline bool autonuma_list_add_tail(int page_nid,
+					  struct page *page,
+					  autonuma_list_entry entry,
+					  struct autonuma_list_head *head)
+{
+	struct autonuma_list_head *entry_head;
+	entry_head = __autonuma_list_head(page_nid, head, entry);
+	return __autonuma_list_add(page_nid, page, head,
+				   entry_head->anl_prev_pfn, entry);
+}
+
+/*
+ * autonuma_list_del - deletes entry from list.
+ * @entry: the element to delete from the list.
+ */
+extern void autonuma_list_del(int page_nid,
+			      struct autonuma_list_head *entry,
+			      struct autonuma_list_head *head);
+
+static inline bool autonuma_list_empty(const struct autonuma_list_head *head)
+{
+	return ACCESS_ONCE(head->anl_next_pfn) == AUTONUMA_LIST_HEAD;
+}
+
+/* safe to call only when the list cannot change under us */
+extern bool autonuma_list_empty_debug(const struct autonuma_list_head *head);
+
+#if 0 /* not needed so far */
+/*
+ * autonuma_list_is_singular - tests whether a list has just one entry.
+ * @head: the list to test.
+ */
+static inline int autonuma_list_is_singular(const struct autonuma_list_head *head)
+{
+	return !autonuma_list_empty_debug(head) &&
+		(head->anl_next_pfn == head->anl_prev_pfn);
+}
+#endif
+
+#endif /* __AUTONUMA_LIST_H */
diff --git a/include/linux/autonuma_types.h b/include/linux/autonuma_types.h
index 525c31f..80ace7f 100644
--- a/include/linux/autonuma_types.h
+++ b/include/linux/autonuma_types.h
@@ -4,6 +4,7 @@
 #ifdef CONFIG_AUTONUMA
 
 #include <linux/numa.h>
+#include <linux/autonuma_list.h>
 
 
 /*
@@ -81,6 +82,19 @@ struct task_autonuma {
 /*
  * Per page (or per-pageblock) structure dynamically allocated only if
  * autonuma is possible.
+ *
+ * This structure takes 12 bytes per page for all architectures. There
+ * are two constraints to make this work:
+ *
+ * 1) the build will abort if MAX_NUMNODES is too big according to
+ *    the #error check below
+ *
+ * 2) AutoNUMA will not succeed to insert into the migration queue any
+ *    page whose pfn offset value (offset with respect to the first
+ *    pfn of the node) is bigger than AUTONUMA_LIST_MAX_PFN_OFFSET
+ *    (NOTE: AUTONUMA_LIST_MAX_PFN_OFFSET is still a valid pfn offset
+ *    value). This means with huge node sizes and small PAGE_SIZE,
+ *    some pages may not be allowed to be migrated.
  */
 struct page_autonuma {
 	/*
@@ -91,7 +105,14 @@ struct page_autonuma {
 	 * systems). Architectures without this granularity require
 	 * autonuma_last_nid to be a long.
 	 */
-#ifdef CONFIG_64BIT
+#if MAX_NUMNODES > 32767
+	/*
+	 * Verify at build time that int16_t for autonuma_migrate_nid
+	 * and autonuma_last_nid won't risk to overflow, max allowed
+	 * nid value is (2**15)-1.
+	 */
+#error "too many nodes"
+#endif
 	/*
 	 * If autonuma_migrate_nid is >= 0, it means the page_autonuma
 	 * structure is linked into one of the NUMA node's migrate
@@ -100,7 +121,7 @@ struct page_autonuma {
 	 * page_autonuma structure is not linked into any NUMA node's
 	 * migrate list.
 	 */
-	int autonuma_migrate_nid;
+	int16_t autonuma_migrate_nid;
 	/*
 	 * autonuma_last_nid records the NUMA node that accessed the
 	 * page during the last NUMA hinting page fault. If a
@@ -109,28 +130,14 @@ struct page_autonuma {
 	 * requiring that a page be accessed by the same node twice in
 	 * a row before it is queued for migration.
 	 */
-	int autonuma_last_nid;
-#else
-#if MAX_NUMNODES > 32767
-#error "too many nodes"
-#endif
-	short autonuma_migrate_nid;
-	short autonuma_last_nid;
-#endif
+	int16_t autonuma_last_nid;
+
 	/*
 	 * This is the list node that links the page (referenced by
 	 * the page_autonuma structure) in the
 	 * &NODE_DATA(dst_nid)->autonuma_migrate_head[page_nid] lru.
 	 */
-	struct list_head autonuma_migrate_node;
-
-	/*
-	 * To find the page starting from the autonuma_migrate_node we
-	 * need a backlink.
-	 *
-	 * FIXME: drop it;
-	 */
-	struct page *page;
+	struct autonuma_list_head autonuma_migrate_node;
 };
 
 extern int alloc_task_autonuma(struct task_struct *tsk,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4d8e100..af71633 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -17,6 +17,7 @@
 #include <linux/pageblock-flags.h>
 #include <generated/bounds.h>
 #include <linux/atomic.h>
+#include <linux/autonuma_list.h>
 #include <asm/page.h>
 
 /* Free memory management - zoned buddy allocator.  */
@@ -734,7 +735,7 @@ typedef struct pglist_data {
 	 * <linux/page_autonuma.h>. The below field must remain the
 	 * last one of this structure.
 	 */
-	struct list_head autonuma_migrate_head[0];
+	struct autonuma_list_head autonuma_migrate_head[0];
 #endif
 	/* do not add more variables here, the above array size is dynamic */
 } pg_data_t;
diff --git a/include/linux/page_autonuma.h b/include/linux/page_autonuma.h
index bd6249c..aeb2e9d 100644
--- a/include/linux/page_autonuma.h
+++ b/include/linux/page_autonuma.h
@@ -53,7 +53,7 @@ extern void __init sparse_early_page_autonuma_alloc_node(struct page_autonuma **
 /* inline won't work here */
 #define autonuma_pglist_data_size() (sizeof(struct pglist_data) +	\
 				     (autonuma_possible() ?		\
-				      sizeof(struct list_head) * \
+				      sizeof(struct autonuma_list_head) * \
 				      nr_node_ids : 0))
 
 #endif /* _LINUX_PAGE_AUTONUMA_H */
diff --git a/mm/Makefile b/mm/Makefile
index 5a4fa30..04357c1 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -34,7 +34,7 @@ obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
-obj-$(CONFIG_AUTONUMA) 	+= autonuma.o page_autonuma.o
+obj-$(CONFIG_AUTONUMA) 	+= autonuma.o page_autonuma.o autonuma_list.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
diff --git a/mm/autonuma.c b/mm/autonuma.c
index 7967507..ada6c57 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -89,7 +89,14 @@ void autonuma_migrate_split_huge_page(struct page *page,
 	VM_BUG_ON(nid < -1);
 	VM_BUG_ON(page_tail_autonuma->autonuma_migrate_nid != -1);
 	if (nid >= 0) {
-		VM_BUG_ON(page_to_nid(page) != page_to_nid(page_tail));
+		bool added;
+		int page_nid = page_to_nid(page);
+		struct autonuma_list_head *head;
+		autonuma_list_entry entry;
+		entry = autonuma_page_to_list_entry(page_nid, page);
+		head = &NODE_DATA(nid)->autonuma_migrate_head[page_nid];
+		VM_BUG_ON(page_nid != page_to_nid(page_tail));
+		VM_BUG_ON(page_nid == nid);
 
 		/*
 		 * The caller only takes the compound_lock for the
@@ -101,11 +108,19 @@ void autonuma_migrate_split_huge_page(struct page *page,
 		 */
 		compound_lock(page_tail);
 		autonuma_migrate_lock(nid);
-		list_add_tail(&page_tail_autonuma->autonuma_migrate_node,
-			      &page_autonuma->autonuma_migrate_node);
+		added = autonuma_list_add_tail(page_nid, page_tail, entry,
+					       head);
+		/*
+		 * AUTONUMA_LIST_MAX_PFN_OFFSET+1 isn't a power of 2
+		 * so "added" may be false if there's a pfn overflow
+		 * in the list.
+		 */
+		if (!added)
+			NODE_DATA(nid)->autonuma_nr_migrate_pages--;
 		autonuma_migrate_unlock(nid);
 
-		page_tail_autonuma->autonuma_migrate_nid = nid;
+		if (added)
+			page_tail_autonuma->autonuma_migrate_nid = nid;
 		compound_unlock(page_tail);
 	}
 
@@ -127,8 +142,15 @@ void __autonuma_migrate_page_remove(struct page *page,
 	VM_BUG_ON(nid < -1);
 	if (nid >= 0) {
 		int numpages = hpage_nr_pages(page);
+		int page_nid = page_to_nid(page);
+		struct autonuma_list_head *head;
+		VM_BUG_ON(nid == page_nid);
+		head = &NODE_DATA(nid)->autonuma_migrate_head[page_nid];
+
 		autonuma_migrate_lock(nid);
-		list_del(&page_autonuma->autonuma_migrate_node);
+		autonuma_list_del(page_nid,
+				  &page_autonuma->autonuma_migrate_node,
+				  head);
 		NODE_DATA(nid)->autonuma_nr_migrate_pages -= numpages;
 		autonuma_migrate_unlock(nid);
 
@@ -147,6 +169,8 @@ static void __autonuma_migrate_page_add(struct page *page,
 	int numpages;
 	unsigned long nr_migrate_pages;
 	wait_queue_head_t *wait_queue;
+	struct autonuma_list_head *head;
+	bool added;
 
 	VM_BUG_ON(dst_nid >= MAX_NUMNODES);
 	VM_BUG_ON(dst_nid < -1);
@@ -170,25 +194,42 @@ static void __autonuma_migrate_page_add(struct page *page,
 	VM_BUG_ON(nid >= MAX_NUMNODES);
 	VM_BUG_ON(nid < -1);
 	if (nid >= 0) {
+		VM_BUG_ON(nid == page_nid);
+		head = &NODE_DATA(nid)->autonuma_migrate_head[page_nid];
+
 		autonuma_migrate_lock(nid);
-		list_del(&page_autonuma->autonuma_migrate_node);
+		autonuma_list_del(page_nid,
+				  &page_autonuma->autonuma_migrate_node,
+				  head);
 		NODE_DATA(nid)->autonuma_nr_migrate_pages -= numpages;
 		autonuma_migrate_unlock(nid);
 	}
 
+	head = &NODE_DATA(dst_nid)->autonuma_migrate_head[page_nid];
+
 	autonuma_migrate_lock(dst_nid);
-	list_add(&page_autonuma->autonuma_migrate_node,
-		 &NODE_DATA(dst_nid)->autonuma_migrate_head[page_nid]);
-	NODE_DATA(dst_nid)->autonuma_nr_migrate_pages += numpages;
-	nr_migrate_pages = NODE_DATA(dst_nid)->autonuma_nr_migrate_pages;
+	added = autonuma_list_add(page_nid, page, AUTONUMA_LIST_HEAD, head);
+	if (added) {
+		NODE_DATA(dst_nid)->autonuma_nr_migrate_pages += numpages;
+		nr_migrate_pages = NODE_DATA(dst_nid)->autonuma_nr_migrate_pages;
+	}
 
 	autonuma_migrate_unlock(dst_nid);
 
-	page_autonuma->autonuma_migrate_nid = dst_nid;
+	if (added)
+		page_autonuma->autonuma_migrate_nid = dst_nid;
 
 	compound_unlock_irqrestore(page, flags);
 
-	if (!autonuma_migrate_defer()) {
+	/* Done, if migrate defer flag is set */
+	if (autonuma_migrate_defer())
+		return;
+
+	/*
+	 * Wake up migrate daemon if the number of pages has reached
+	 * the threshold.
+	 */
+	if (added) {
 		wait_queue = &NODE_DATA(dst_nid)->autonuma_knuma_migrated_wait;
 		if (nr_migrate_pages >= pages_to_migrate &&
 		    nr_migrate_pages - numpages < pages_to_migrate &&
@@ -904,7 +945,7 @@ static int isolate_migratepages(struct list_head *migratepages,
 				struct pglist_data *pgdat)
 {
 	int nr = 0, nid;
-	struct list_head *heads = pgdat->autonuma_migrate_head;
+	struct autonuma_list_head *heads = pgdat->autonuma_migrate_head;
 
 	/* FIXME: THP balancing, restart from last nid */
 	for_each_online_node(nid) {
@@ -924,10 +965,10 @@ static int isolate_migratepages(struct list_head *migratepages,
 			  "thread has been altered in a suboptimal way\n",
 			  pgdat->node_id);
 		if (nid == pgdat->node_id) {
-			VM_BUG_ON(!list_empty(&heads[nid]));
+			VM_BUG_ON(!autonuma_list_empty_debug(&heads[nid]));
 			continue;
 		}
-		if (list_empty(&heads[nid]))
+		if (autonuma_list_empty(&heads[nid]))
 			continue;
 		/* some page wants to go to this pgdat */
 		/*
@@ -939,22 +980,26 @@ static int isolate_migratepages(struct list_head *migratepages,
 		 * obtained the autonuma_migrate_lock here.
 		 */
 		autonuma_migrate_lock_irq(pgdat->node_id);
-		if (list_empty(&heads[nid])) {
+		if (autonuma_list_empty_debug(&heads[nid])) {
 			autonuma_migrate_unlock_irq(pgdat->node_id);
 			continue;
 		}
-		page_autonuma = list_entry(heads[nid].prev,
-					   struct page_autonuma,
-					   autonuma_migrate_node);
-		page = page_autonuma->page;
+		page = autonuma_list_entry_to_page(nid,
+						   heads[nid].anl_prev_pfn);
+		BUG_ON(nid != page_to_nid(page));
+		page_autonuma = lookup_page_autonuma(page);
 		if (unlikely(!get_page_unless_zero(page))) {
+			struct autonuma_list_head *entry_head;
 			/*
 			 * Is getting freed and will remove self from the
 			 * autonuma list shortly, skip it for now.
 			 */
-			list_del(&page_autonuma->autonuma_migrate_node);
-			list_add(&page_autonuma->autonuma_migrate_node,
-				 &heads[nid]);
+			entry_head = &page_autonuma->autonuma_migrate_node;
+			autonuma_list_del(nid, entry_head, &heads[nid]);
+			if (!autonuma_list_add(nid, page,
+					       AUTONUMA_LIST_HEAD,
+					       &heads[nid]))
+				BUG();
 			autonuma_migrate_unlock_irq(pgdat->node_id);
 			autonuma_printk("autonuma migrate page is free\n");
 			continue;
@@ -967,8 +1012,6 @@ static int isolate_migratepages(struct list_head *migratepages,
 			continue;
 		}
 
-		VM_BUG_ON(nid != page_to_nid(page));
-
 		if (PageTransHuge(page)) {
 			VM_BUG_ON(!PageAnon(page));
 			/* FIXME: remove split_huge_page */
diff --git a/mm/autonuma_list.c b/mm/autonuma_list.c
new file mode 100644
index 0000000..0a1cab1
--- /dev/null
+++ b/mm/autonuma_list.c
@@ -0,0 +1,169 @@
+/*
+ * Copyright 2006, Red Hat, Inc., Dave Jones
+ * Copyright 2012, Red Hat, Inc.
+ * Released under the General Public License (GPL).
+ *
+ * This file contains the linked list implementations for
+ * autonuma migration lists.
+ */
+
+#include <linux/mm.h>
+#include <linux/autonuma.h>
+
+/*
+ * Insert a new entry between two known consecutive entries.
+ *
+ * This is only for internal list manipulation where we know
+ * the prev/next entries already!
+ *
+ * return true if succeeded, or false if the (page_nid, pfn_offset)
+ * pair couldn't represent the pfn and the list_add didn't succeed.
+ */
+bool __autonuma_list_add(int page_nid,
+			 struct page *page,
+			 struct autonuma_list_head *head,
+			 autonuma_list_entry prev,
+			 autonuma_list_entry next)
+{
+	autonuma_list_entry new;
+
+	VM_BUG_ON(page_nid != page_to_nid(page));
+	new = autonuma_page_to_list_entry(page_nid, page);
+	if (new > AUTONUMA_LIST_MAX_PFN_OFFSET)
+		return false;
+
+	WARN(new == prev || new == next,
+	     "autonuma_list_add double add: new=%u, prev=%u, next=%u.\n",
+	     new, prev, next);
+
+	__autonuma_list_head(page_nid, head, next)->anl_prev_pfn = new;
+	__autonuma_list_head(page_nid, head, new)->anl_next_pfn = next;
+	__autonuma_list_head(page_nid, head, new)->anl_prev_pfn = prev;
+	__autonuma_list_head(page_nid, head, prev)->anl_next_pfn = new;
+	return true;
+}
+
+static inline void __autonuma_list_del_entry(int page_nid,
+					     struct autonuma_list_head *entry,
+					     struct autonuma_list_head *head)
+{
+	autonuma_list_entry prev, next;
+
+	next = entry->anl_next_pfn;
+	prev = entry->anl_prev_pfn;
+
+	if (WARN(next == AUTONUMA_LIST_POISON1,
+		 "autonuma_list_del corruption, "
+		 "%p->anl_next_pfn is AUTONUMA_LIST_POISON1 (%u)\n",
+		entry, AUTONUMA_LIST_POISON1) ||
+	    WARN(prev == AUTONUMA_LIST_POISON2,
+		"autonuma_list_del corruption, "
+		 "%p->anl_prev_pfn is AUTONUMA_LIST_POISON2 (%u)\n",
+		entry, AUTONUMA_LIST_POISON2))
+		return;
+
+	__autonuma_list_head(page_nid, head, next)->anl_prev_pfn = prev;
+	__autonuma_list_head(page_nid, head, prev)->anl_next_pfn = next;
+}
+
+/*
+ * autonuma_list_del - deletes entry from list.
+ *
+ * Note: autonuma_list_empty on entry does not return true after this,
+ * the entry is in an undefined state.
+ */
+void autonuma_list_del(int page_nid, struct autonuma_list_head *entry,
+		       struct autonuma_list_head *head)
+{
+	__autonuma_list_del_entry(page_nid, entry, head);
+	entry->anl_next_pfn = AUTONUMA_LIST_POISON1;
+	entry->anl_prev_pfn = AUTONUMA_LIST_POISON2;
+}
+
+/*
+ * autonuma_list_empty - tests whether a list is empty
+ * @head: the list to test.
+ */
+bool autonuma_list_empty_debug(const struct autonuma_list_head *head)
+{
+	bool ret = false;
+	if (head->anl_next_pfn == AUTONUMA_LIST_HEAD) {
+		ret = true;
+		BUG_ON(head->anl_prev_pfn != AUTONUMA_LIST_HEAD);
+	}
+	return ret;
+}
+
+/* abstraction conversion methods */
+
+static inline struct page *__autonuma_list_entry_to_page(int page_nid,
+							 autonuma_list_entry pfn_offset)
+{
+	struct pglist_data *pgdat = NODE_DATA(page_nid);
+	unsigned long pfn = pgdat->node_start_pfn + pfn_offset;
+	BUG_ON(pfn_offset >= pgdat->node_spanned_pages);
+	return pfn_to_page(pfn);
+}
+
+struct page *autonuma_list_entry_to_page(int page_nid,
+					 autonuma_list_entry pfn_offset)
+{
+	VM_BUG_ON(page_nid < 0);
+	BUG_ON(pfn_offset == AUTONUMA_LIST_POISON1);
+	BUG_ON(pfn_offset == AUTONUMA_LIST_POISON2);
+	BUG_ON(pfn_offset == AUTONUMA_LIST_HEAD);
+	return __autonuma_list_entry_to_page(page_nid, pfn_offset);
+}
+
+/*
+ * returns a value above AUTONUMA_LIST_MAX_PFN_OFFSET if the pfn is
+ * located a too big offset from the start of the node and cannot be
+ * represented by the (page_nid, pfn_offset) pair.
+ */
+autonuma_list_entry autonuma_page_to_list_entry(int page_nid,
+						struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	struct pglist_data *pgdat = NODE_DATA(page_nid);
+	VM_BUG_ON(page_nid != page_to_nid(page));
+	BUG_ON(pfn < pgdat->node_start_pfn);
+	BUG_ON(pfn >= pgdat->node_start_pfn + pgdat->node_spanned_pages);
+	pfn -= pgdat->node_start_pfn;
+	if (pfn > AUTONUMA_LIST_MAX_PFN_OFFSET) {
+		WARN_ONCE(1, "autonuma_page_to_list_entry: "
+			  "pfn_offset  %lu, pgdat %p, "
+			  "pgdat->node_start_pfn %lu\n",
+			  pfn, pgdat, pgdat->node_start_pfn);
+		/*
+		 * Any value bigger than AUTONUMA_LIST_MAX_PFN_OFFSET
+		 * will work as an error retval, but better pick one
+		 * that will cause noise if computed wrong by the
+		 * caller.
+		 */
+		return AUTONUMA_LIST_POISON1;
+	}
+	return pfn; /* convert to uint16_t without losing information */
+}
+
+static inline struct autonuma_list_head *____autonuma_list_head(int page_nid,
+					autonuma_list_entry pfn_offset)
+{
+	struct pglist_data *pgdat = NODE_DATA(page_nid);
+	unsigned long pfn = pgdat->node_start_pfn + pfn_offset;
+	struct page *page = pfn_to_page(pfn);
+	struct page_autonuma *page_autonuma = lookup_page_autonuma(page);
+	return &page_autonuma->autonuma_migrate_node;
+}
+
+struct autonuma_list_head *__autonuma_list_head(int page_nid,
+					struct autonuma_list_head *head,
+					autonuma_list_entry pfn_offset)
+{
+	VM_BUG_ON(page_nid < 0);
+	BUG_ON(pfn_offset == AUTONUMA_LIST_POISON1);
+	BUG_ON(pfn_offset == AUTONUMA_LIST_POISON2);
+	if (pfn_offset != AUTONUMA_LIST_HEAD)
+		return ____autonuma_list_head(page_nid, pfn_offset);
+	else
+		return head;
+}
diff --git a/mm/page_autonuma.c b/mm/page_autonuma.c
index 46d616c..c8ba137 100644
--- a/mm/page_autonuma.c
+++ b/mm/page_autonuma.c
@@ -1,5 +1,6 @@
 #include <linux/mm.h>
 #include <linux/memory.h>
+#include <linux/vmalloc.h>
 #include <linux/autonuma.h>
 #include <linux/page_autonuma.h>
 #include <linux/bootmem.h>
@@ -12,7 +13,6 @@ void __meminit page_autonuma_map_init(struct page *page,
 	for (end = page + nr_pages; page < end; page++, page_autonuma++) {
 		page_autonuma->autonuma_last_nid = -1;
 		page_autonuma->autonuma_migrate_nid = -1;
-		page_autonuma->page = page;
 	}
 }
 
@@ -20,6 +20,9 @@ static void __meminit __pgdat_autonuma_init(struct pglist_data *pgdat)
 {
 	int node_iter;
 
+	/* verify the per-page page_autonuma 12 byte fixed cost */
+	BUILD_BUG_ON((unsigned long) &((struct page_autonuma *)0)[1] != 12);
+
 	spin_lock_init(&pgdat->autonuma_lock);
 	init_waitqueue_head(&pgdat->autonuma_knuma_migrated_wait);
 	pgdat->autonuma_nr_migrate_pages = 0;
@@ -30,8 +33,11 @@ static void __meminit __pgdat_autonuma_init(struct pglist_data *pgdat)
 
 	/* noautonuma early param may also clear AUTONUMA_POSSIBLE_FLAG */
 	if (autonuma_possible())
-		for_each_node(node_iter)
-			INIT_LIST_HEAD(&pgdat->autonuma_migrate_head[node_iter]);
+		for_each_node(node_iter) {
+			struct autonuma_list_head *head;
+			head = &pgdat->autonuma_migrate_head[node_iter];
+			AUTONUMA_INIT_LIST_HEAD(head);
+		}
 }
 
 #if !defined(CONFIG_SPARSEMEM)
@@ -119,14 +125,6 @@ struct page_autonuma *lookup_page_autonuma(struct page *page)
 	unsigned long pfn = page_to_pfn(page);
 	struct mem_section *section = __pfn_to_section(pfn);
 
-	/* if it's not a power of two we may be wasting memory */
-	BUILD_BUG_ON(SECTION_PAGE_AUTONUMA_SIZE &
-		     (SECTION_PAGE_AUTONUMA_SIZE-1));
-
-	/* memsection must be a power of two */
-	BUILD_BUG_ON(sizeof(struct mem_section) &
-		     (sizeof(struct mem_section)-1));
-
 #ifdef CONFIG_DEBUG_VM
 	/*
 	 * The sanity checks the page allocator does upon freeing a
@@ -142,6 +140,10 @@ struct page_autonuma *lookup_page_autonuma(struct page *page)
 
 void __meminit pgdat_autonuma_init(struct pglist_data *pgdat)
 {
+	/* memsection must be a power of two */
+	BUILD_BUG_ON(sizeof(struct mem_section) &
+		     (sizeof(struct mem_section)-1));
+
 	__pgdat_autonuma_init(pgdat);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
