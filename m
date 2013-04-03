Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 2A60C6B0083
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 22:43:51 -0400 (EDT)
Date: Tue, 2 Apr 2013 21:43:44 -0500
From: Robin Holt <holt@sgi.com>
Subject: [PATCH] mm, x86: Do not zero hugetlbfs pages at boot. -v2
Message-ID: <20130403024344.GA4384@sgi.com>
References: <E1UDME8-00041J-B4@eag09.americas.sgi.com>
 <20130314085138.GA11636@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130314085138.GA11636@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Cliff Wickman <cpw@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, wli@holomorphy.com

Reserving a large number of 1GB hugetlbfs pages at boot takes a very
long time due to the pages being memset to 0 during the reservation.
This is unneeded as the pages will be zeroed by clear_huge_page() when
being allocated by the user.

Large system sites would at times like to allocate a very large amount
of memory as 1GB pages.  They would put this on the kernel boot line:
   default_hugepagesz=1G hugepagesz=1G hugepages=4096
[Dynamic allocation of 1G pages is not an option, as zone pages only go
 up to MAX_ORDER, and MAX_ORDER cannot exceed the section size.]

Each page is zeroed as it is allocated, and all allocation is done by
cpu 0, as this path is early in boot:
      start_kernel
        kernel_init
          do_pre_smp_initcalls
            hugetlb_init
              hugetlb_init_hstates
                hugetlb_hstate_alloc_pages

Zeroing remote (offnode) memory takes ~1GB/sec (and most memory is offnode
on large numa systems).  This estimate is approximate (it depends on
core frequency & number of hops to remote memory) but should be within
a factor of 2 on most systems.  A benchmark attempting to reserve a TB
for 1GB pages would thus require ~1000 seconds of boot time just for
this allocating.  32TB would take 8 hours.

Signed-off-by: Robin Holt <holt@sgi.com>
To: Cliff Whickman <cpw@sgi.com>
To: Michal Hocko <mhocko@suse.cz>
Cc: lkml <linux-kernel@vger.kernel.org>
Cc: Linux mm <linux-mm@kvack.org>
Cc: x86 Maintainers <x86@kernel.org>
---

Changes since -v1
 - Reworked to remove the special NO_ZERO flag and push that down further
   in the call chain.

Note: I compiled this only with a .config which specified
CONFIG_NO_BOOTMEM (x86_64).  I have not tried a config which uses a
bootmem allocator.

 include/linux/bootmem.h |  8 +++++++-
 mm/bootmem.c            | 21 +++++++++++++++++----
 mm/hugetlb.c            |  2 +-
 mm/nobootmem.c          | 37 +++++++++++++++++++++++++++----------
 mm/sparse.c             |  2 +-
 5 files changed, 53 insertions(+), 17 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index cdc3bab..04563fc 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -92,11 +92,17 @@ extern void *__alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 				  unsigned long size,
 				  unsigned long align,
 				  unsigned long goal);
+extern void *__alloc_bootmem_node_nopanic_notzeroed(
+				  pg_data_t *pgdat,
+				  unsigned long size,
+				  unsigned long align,
+				  unsigned long goal);
 void *___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 				  unsigned long size,
 				  unsigned long align,
 				  unsigned long goal,
-				  unsigned long limit);
+				  unsigned long limit,
+				  int zeroed);
 extern void *__alloc_bootmem_low(unsigned long size,
 				 unsigned long align,
 				 unsigned long goal);
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 2b0bcb0..b2e4027 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -705,12 +705,16 @@ void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 
 void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 				unsigned long size, unsigned long align,
-				unsigned long goal, unsigned long limit)
+				unsigned long goal, unsigned long limit,
+				int zeroed)
 {
 	void *ptr;
 
 	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc(size, GFP_NOWAIT);
+		if (zeroed)
+			return kzalloc(size, GFP_NOWAIT);
+		else
+			return kmalloc(size, GFP_NOWAIT);
 again:
 
 	/* do not panic in alloc_bootmem_bdata() */
@@ -733,13 +737,22 @@ again:
 	return NULL;
 }
 
+void * __init __alloc_bootmem_node_nopanic_notzeroed(pg_data_t *pgdat, unsigned long size,
+				   unsigned long align, unsigned long goal)
+{
+	if (WARN_ON_ONCE(slab_is_available()))
+		return kmalloc_node(size, GFP_NOWAIT, pgdat->node_id);
+
+	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0, 0);
+}
+
 void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
 {
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
-	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
+	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0, 1);
 }
 
 void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
@@ -748,7 +761,7 @@ void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 {
 	void *ptr;
 
-	ptr = ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
+	ptr = ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0, 1);
 	if (ptr)
 		return ptr;
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ca9a7c6..7683f6a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1185,7 +1185,7 @@ int __weak alloc_bootmem_huge_page(struct hstate *h)
 	while (nr_nodes) {
 		void *addr;
 
-		addr = __alloc_bootmem_node_nopanic(
+		addr = __alloc_bootmem_node_nopanic_notzeroed(
 				NODE_DATA(hstate_next_node_to_alloc(h,
 						&node_states[N_MEMORY])),
 				huge_page_size(h), huge_page_size(h), 0);
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 5e07d36..342511b 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -32,8 +32,8 @@ unsigned long max_low_pfn;
 unsigned long min_low_pfn;
 unsigned long max_pfn;
 
-static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
-					u64 goal, u64 limit)
+static void * __init ___alloc_memory_core_early(int nid, u64 size, u64 align,
+					u64 goal, u64 limit, int zeroed)
 {
 	void *ptr;
 	u64 addr;
@@ -46,7 +46,8 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 		return NULL;
 
 	ptr = phys_to_virt(addr);
-	memset(ptr, 0, size);
+	if (zeroed)
+		memset(ptr, 0, size);
 	memblock_reserve(addr, size);
 	/*
 	 * The min_count is set to 0 so that bootmem allocated blocks
@@ -56,6 +57,12 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 	return ptr;
 }
 
+static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
+					u64 goal, u64 limit)
+{
+	return ___alloc_memory_core_early(nid, size, align, goal, limit, 1);
+}
+
 /*
  * free_bootmem_late - free bootmem pages directly to page allocator
  * @addr: starting address of the range
@@ -291,18 +298,19 @@ void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 						   unsigned long size,
 						   unsigned long align,
 						   unsigned long goal,
-						   unsigned long limit)
+						   unsigned long limit,
+						   int zeroed)
 {
 	void *ptr;
 
 again:
-	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
-					goal, limit);
+	ptr = ___alloc_memory_core_early(pgdat->node_id, size, align,
+					goal, limit, zeroed);
 	if (ptr)
 		return ptr;
 
-	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
-					goal, limit);
+	ptr = ___alloc_memory_core_early(MAX_NUMNODES, size, align,
+					goal, limit, zeroed);
 	if (ptr)
 		return ptr;
 
@@ -314,13 +322,22 @@ again:
 	return NULL;
 }
 
+void * __init __alloc_bootmem_node_nopanic_notzeroed(pg_data_t *pgdat, unsigned long size,
+				   unsigned long align, unsigned long goal)
+{
+	if (WARN_ON_ONCE(slab_is_available()))
+		return kmalloc_node(size, GFP_NOWAIT, pgdat->node_id);
+
+	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0, 0);
+}
+
 void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
 {
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
-	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
+	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0, 1);
 }
 
 void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
@@ -329,7 +346,7 @@ void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 {
 	void *ptr;
 
-	ptr = ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, limit);
+	ptr = ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, limit, 1);
 	if (ptr)
 		return ptr;
 
diff --git a/mm/sparse.c b/mm/sparse.c
index 7ca6dc8..8a1c5ad 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -281,7 +281,7 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 	nid = early_pfn_to_nid(goal >> PAGE_SHIFT);
 again:
 	p = ___alloc_bootmem_node_nopanic(NODE_DATA(nid), size,
-					  SMP_CACHE_BYTES, goal, limit);
+					  SMP_CACHE_BYTES, goal, limit, 1);
 	if (!p && limit) {
 		limit = 0;
 		goto again;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
