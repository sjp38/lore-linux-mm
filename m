Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 35ED882A8B
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:35:51 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so993591pad.23
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:35:50 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ka9si1543122pad.137.2014.07.11.00.35.49
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:35:50 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:24 +0800
Message-Id: <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <jiang.liu@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>
Cc: Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
may return a node without memory, and later cause system failure/panic
when calling kmalloc_node() and friends with returned node id.
So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
memory for the/current cpu.

If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
is the same as cpu_to_node()/numa_node_id().

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 include/linux/gfp.h |    6 +++---
 mm/memory.c         |    2 +-
 mm/percpu-vm.c      |    2 +-
 mm/vmalloc.c        |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 6eb1fb37de9a..56dd2043f510 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -314,7 +314,7 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 {
 	/* Unknown node is current node */
 	if (nid < 0)
-		nid = numa_node_id();
+		nid = numa_mem_id();
 
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
@@ -340,13 +340,13 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			int node);
 #else
 #define alloc_pages(gfp_mask, order) \
-		alloc_pages_node(numa_node_id(), gfp_mask, order)
+		alloc_pages_node(numa_mem_id(), gfp_mask, order)
 #define alloc_pages_vma(gfp_mask, order, vma, addr, node)	\
 	alloc_pages(gfp_mask, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
-	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id())
+	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_mem_id())
 #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
 	alloc_pages_vma(gfp_mask, 0, vma, addr, node)
 
diff --git a/mm/memory.c b/mm/memory.c
index d67fd9fcf1f2..f434d2692f70 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3074,7 +3074,7 @@ static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 	get_page(page);
 
 	count_vm_numa_event(NUMA_HINT_FAULTS);
-	if (page_nid == numa_node_id()) {
+	if (page_nid == numa_mem_id()) {
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 		*flags |= TNF_FAULT_LOCAL;
 	}
diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index 3707c71ae4cd..a20b8f7d0dd0 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -115,7 +115,7 @@ static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
 		for (i = page_start; i < page_end; i++) {
 			struct page **pagep = &pages[pcpu_page_idx(cpu, i)];
 
-			*pagep = alloc_pages_node(cpu_to_node(cpu), gfp, 0);
+			*pagep = alloc_pages_node(cpu_to_mem(cpu), gfp, 0);
 			if (!*pagep) {
 				pcpu_free_pages(chunk, pages, populated,
 						page_start, page_end);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f64632b67196..c06f90641916 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -800,7 +800,7 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
 	unsigned long vb_idx;
 	int node, err;
 
-	node = numa_node_id();
+	node = numa_mem_id();
 
 	vb = kmalloc_node(sizeof(struct vmap_block),
 			gfp_mask & GFP_RECLAIM_MASK, node);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
