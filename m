Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3B9F26B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 14:20:19 -0400 (EDT)
Date: Wed, 30 May 2012 20:19:49 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 14/35] autonuma: knuma_migrated per NUMA node queues
Message-ID: <20120530181949.GG21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-15-git-send-email-aarcange@redhat.com>
 <1338299468.26856.80.camel@twins>
 <20120530001438.GX21339@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120530001438.GX21339@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Wed, May 30, 2012 at 02:14:38AM +0200, Andrea Arcangeli wrote:
> I fully agree, I prefer to fix it and I was fully aware about

I did this yesterday, this is saving a couple of pages on my numa
system with node shift = 9. However I'm not sure anymore if it's
really worth it... but since I did it I may as well keep it.

==
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] autonuma: autonuma_migrate_head[0] dynamic size

Reduce the autonuma_migrate_head array entries from MAX_NUMNODES to
num_possible_nodes() or zero if autonuma_impossible() is true.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/mm/numa.c             |    6 ++++--
 arch/x86/mm/numa_32.c          |    3 ++-
 include/linux/memory_hotplug.h |    3 ++-
 include/linux/mmzone.h         |    8 +++++++-
 include/linux/page_autonuma.h  |   10 ++++++++--
 mm/memory_hotplug.c            |    2 +-
 mm/page_autonuma.c             |    5 +++--
 7 files changed, 27 insertions(+), 10 deletions(-)

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
index e66da74..ed5b0c0 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -701,10 +701,16 @@ typedef struct pglist_data {
 #if !defined(CONFIG_SPARSEMEM)
 	struct page_autonuma *node_page_autonuma;
 #endif
-	struct list_head autonuma_migrate_head[MAX_NUMNODES];
 	unsigned long autonuma_nr_migrate_pages;
 	wait_queue_head_t autonuma_knuma_migrated_wait;
 	spinlock_t autonuma_lock;
+	/*
+	 * Archs supporting AutoNUMA should allocate the pgdat with
+	 * size autonuma_pglist_data_size() after including
+	 * <linux/page_autonuma.h> and the below field must remain the
+	 * last one of this structure.
+	 */
+	struct list_head autonuma_migrate_head[0];
 #endif
 } pg_data_t;
 
diff --git a/include/linux/page_autonuma.h b/include/linux/page_autonuma.h
index 05d2862..1d02643 100644
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
+#endif
 
 #define autonuma_impossible() true
 
-#endif
-
 static inline void pgdat_autonuma_init(struct pglist_data *pgdat) {}
 
 #endif /* CONFIG_AUTONUMA */
@@ -50,4 +50,10 @@ extern void __init sparse_early_page_autonuma_alloc_node(struct page_autonuma **
 							 int nodeid);
 #endif
 
+/* inline won't work here */
+#define autonuma_pglist_data_size() (sizeof(struct pglist_data) +	\
+				     (autonuma_impossible() ? 0 :	\
+				      sizeof(struct list_head) * \
+				      num_possible_nodes()))
+
 #endif /* _LINUX_PAGE_AUTONUMA_H */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0d7e3ec..604995b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -164,7 +164,7 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
 	struct page *page;
 	struct zone *zone;
 
-	nr_pages = PAGE_ALIGN(sizeof(struct pglist_data)) >> PAGE_SHIFT;
+	nr_pages = PAGE_ALIGN(autonuma_pglist_data_size()) >> PAGE_SHIFT;
 	page = virt_to_page(pgdat);
 
 	for (i = 0; i < nr_pages; i++, page++)
diff --git a/mm/page_autonuma.c b/mm/page_autonuma.c
index 131b5c9..c5c340b 100644
--- a/mm/page_autonuma.c
+++ b/mm/page_autonuma.c
@@ -23,8 +23,9 @@ static void __meminit __pgdat_autonuma_init(struct pglist_data *pgdat)
 	spin_lock_init(&pgdat->autonuma_lock);
 	init_waitqueue_head(&pgdat->autonuma_knuma_migrated_wait);
 	pgdat->autonuma_nr_migrate_pages = 0;
-	for_each_node(node_iter)
-		INIT_LIST_HEAD(&pgdat->autonuma_migrate_head[node_iter]);
+	if (!autonuma_impossible())
+		for_each_node(node_iter)
+			INIT_LIST_HEAD(&pgdat->autonuma_migrate_head[node_iter]);
 }
 
 #if !defined(CONFIG_SPARSEMEM)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
