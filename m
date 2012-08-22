Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id E2F9B6B0081
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:11 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 29/36] autonuma: autonuma_migrate_head[0] dynamic size
Date: Wed, 22 Aug 2012 16:59:13 +0200
Message-Id: <1345647560-30387-30-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Reduce the autonuma_migrate_head array entries from MAX_NUMNODES to
num_possible_nodes() or zero if autonuma is not possible.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/mm/numa.c             |    6 ++++--
 arch/x86/mm/numa_32.c          |    3 ++-
 include/linux/memory_hotplug.h |    3 ++-
 include/linux/mmzone.h         |   19 +++++++++++++------
 include/linux/page_autonuma.h  |   10 ++++++++--
 mm/memory_hotplug.c            |    2 +-
 6 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 2d125be..a4a9e92 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -11,6 +11,7 @@
 #include <linux/nodemask.h>
 #include <linux/sched.h>
 #include <linux/topology.h>
+#include <linux/page_autonuma.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -192,7 +193,8 @@ int __init numa_add_memblk(int nid, u64 start, u64 end)
 /* Initialize NODE_DATA for a node on the local memory */
 static void __init setup_node_data(int nid, u64 start, u64 end)
 {
-	const size_t nd_size = roundup(sizeof(pg_data_t), PAGE_SIZE);
+	const size_t nd_size = roundup(autonuma_pglist_data_size(),
+				       PAGE_SIZE);
 	bool remapped = false;
 	u64 nd_pa;
 	void *nd;
@@ -239,7 +241,7 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
 		printk(KERN_INFO "    NODE_DATA(%d) on node %d\n", nid, tnid);
 
 	node_data[nid] = nd;
-	memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
+	memset(NODE_DATA(nid), 0, autonuma_pglist_data_size());
 	NODE_DATA(nid)->node_id = nid;
 	NODE_DATA(nid)->node_start_pfn = start >> PAGE_SHIFT;
 	NODE_DATA(nid)->node_spanned_pages = (end - start) >> PAGE_SHIFT;
diff --git a/arch/x86/mm/numa_32.c b/arch/x86/mm/numa_32.c
index 534255a..d32d6cc 100644
--- a/arch/x86/mm/numa_32.c
+++ b/arch/x86/mm/numa_32.c
@@ -25,6 +25,7 @@
 #include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/module.h>
+#include <linux/page_autonuma.h>
 
 #include "numa_internal.h"
 
@@ -194,7 +195,7 @@ void __init init_alloc_remap(int nid, u64 start, u64 end)
 
 	/* calculate the necessary space aligned to large page size */
 	size = node_memmap_size_bytes(nid, start_pfn, end_pfn);
-	size += ALIGN(sizeof(pg_data_t), PAGE_SIZE);
+	size += ALIGN(autonuma_pglist_data_size(), PAGE_SIZE);
 	size = ALIGN(size, LARGE_PAGE_BYTES);
 
 	/* allocate node memory and the lowmem remap area */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 910550f..76b1840 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -5,6 +5,7 @@
 #include <linux/spinlock.h>
 #include <linux/notifier.h>
 #include <linux/bug.h>
+#include <linux/page_autonuma.h>
 
 struct page;
 struct zone;
@@ -130,7 +131,7 @@ extern void arch_refresh_nodedata(int nid, pg_data_t *pgdat);
  */
 #define generic_alloc_nodedata(nid)				\
 ({								\
-	kzalloc(sizeof(pg_data_t), GFP_KERNEL);			\
+	kzalloc(autonuma_pglist_data_size(), GFP_KERNEL);	\
 })
 /*
  * This definition is just for error path in node hotadd.
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 853e236..4d8e100 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -713,12 +713,6 @@ typedef struct pglist_data {
 #if !defined(CONFIG_SPARSEMEM)
 	struct page_autonuma *node_page_autonuma;
 #endif
-	/*
-	 * All pages from node "page_nid" to be migrated to this node,
-	 * will be queued into the list
-	 * autonuma_migrate_head[page_nid].
-	 */
-	struct list_head autonuma_migrate_head[MAX_NUMNODES];
 	/* number of pages from other nodes queued for migration to this node */
 	unsigned long autonuma_nr_migrate_pages;
 	/* waitqueue for this node knuma_migrated daemon */
@@ -729,7 +723,20 @@ typedef struct pglist_data {
 	 * autonuma_nr_migrate_pages field.
 	 */
 	spinlock_t autonuma_lock;
+	/*
+	 * All pages from node "page_nid" to be migrated to this node,
+	 * will be queued into the list
+	 * autonuma_migrate_head[page_nid].
+	 *
+	 * Arches supporting AutoNUMA must allocate the pgdat
+	 * structure using the size returned from the
+	 * autonuma_pglist_data_size() function after including
+	 * <linux/page_autonuma.h>. The below field must remain the
+	 * last one of this structure.
+	 */
+	struct list_head autonuma_migrate_head[0];
 #endif
+	/* do not add more variables here, the above array size is dynamic */
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/include/linux/page_autonuma.h b/include/linux/page_autonuma.h
index 9763e61..bd6249c 100644
--- a/include/linux/page_autonuma.h
+++ b/include/linux/page_autonuma.h
@@ -10,6 +10,7 @@ static inline void __init page_autonuma_init_flatmem(void) {}
 #ifdef CONFIG_AUTONUMA
 
 #include <linux/autonuma_flags.h>
+#include <linux/autonuma_types.h>
 
 extern void __meminit page_autonuma_map_init(struct page *page,
 					     struct page_autonuma *page_autonuma,
@@ -29,11 +30,10 @@ extern void __meminit pgdat_autonuma_init(struct pglist_data *);
 struct page_autonuma;
 #define PAGE_AUTONUMA_SIZE 0
 #define SECTION_PAGE_AUTONUMA_SIZE 0
+#endif /* CONFIG_SPARSEMEM */
 
 #define autonuma_possible() false
 
-#endif /* CONFIG_SPARSEMEM */
-
 static inline void pgdat_autonuma_init(struct pglist_data *pgdat) {}
 
 #endif /* CONFIG_AUTONUMA */
@@ -50,4 +50,10 @@ extern void __init sparse_early_page_autonuma_alloc_node(struct page_autonuma **
 							 int nodeid);
 #endif
 
+/* inline won't work here */
+#define autonuma_pglist_data_size() (sizeof(struct pglist_data) +	\
+				     (autonuma_possible() ?		\
+				      sizeof(struct list_head) * \
+				      nr_node_ids : 0))
+
 #endif /* _LINUX_PAGE_AUTONUMA_H */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3ad25f9..86b37db 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -164,7 +164,7 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
 	struct page *page;
 	struct zone *zone;
 
-	nr_pages = PAGE_ALIGN(sizeof(struct pglist_data)) >> PAGE_SHIFT;
+	nr_pages = PAGE_ALIGN(autonuma_pglist_data_size()) >> PAGE_SHIFT;
 	page = virt_to_page(pgdat);
 
 	for (i = 0; i < nr_pages; i++, page++)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
