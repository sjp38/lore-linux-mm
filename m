Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 73D396B0289
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:12:30 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bx7so1881374pad.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:12:30 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id l17si34904856pfi.54.2016.04.05.14.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:12:29 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id c20so18340234pfc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:12:29 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:12:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 01/31] huge tmpfs: prepare counts in meminfo, vmstat and
 SysRq-m
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051410260.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Abbreviate NR_ANON_TRANSPARENT_HUGEPAGES to NR_ANON_HUGEPAGES,
add NR_SHMEM_HUGEPAGES, NR_SHMEM_PMDMAPPED, NR_SHMEM_FREEHOLES:
to be accounted in later commits, when we shall need some visibility.

Shown in /proc/meminfo and /sys/devices/system/node/nodeN/meminfo
as AnonHugePages (as before), ShmemHugePages, ShmemPmdMapped,
ShmemFreeHoles; /proc/vmstat and /sys/devices/system/node/nodeN/vmstat
as nr_anon_transparent_hugepages (as before), nr_shmem_hugepages,
nr_shmem_pmdmapped, nr_shmem_freeholes.

Be upfront about this being Shmem, neither file nor anon: Shmem
is sometimes counted as file (as in Cached) and sometimes as anon
(as in Active(anon)); which is too confusing.  Shmem is already
shown in meminfo, so use that term, rather than tmpfs or shm.

ShmemHugePages will show that portion of Shmem which is allocated
on complete huge pages.  ShmemPmdMapped (named not to misalign the
%8lu) will show that portion of ShmemHugePages which is mapped into
userspace with huge pmds.  ShmemFreeHoles will show the wastage
from using huge pages for small, or sparsely occupied, or unrounded
files: wastage not included in Shmem or MemFree, but will be freed
under memory pressure.  (But no count for the partially occupied
portions of huge pages: seems less important, but could be added.)

Since shmem_freeholes are otherwise hidden, they ought to be shown by
show_free_areas(), in OOM-kill or ALT-SysRq-m or /proc/sysrq-trigger m.
shmem_hugepages is a subset of shmem, and shmem_pmdmapped a subset of
shmem_hugepages: there is not a strong argument for adding them here
(anon_hugepages is not shown), but include them anyway for reassurance.
Note that shmem_hugepages (and _pmdmapped and _freeholes) page counts
are shown in smallpage units, like other fields: not in hugepage units.

The lines get rather long: abbreviate thus
  mapped:19778 shmem:38 pagetables:1153 bounce:0
  shmem_hugepages:0 _pmdmapped:0 _freeholes:2044
  free:3261805 free_pcp:9444 free_cma:0
and
... shmem:92kB _hugepages:0kB _pmdmapped:0kB _freeholes:0kB ...

Tidy up the CONFIG_TRANSPARENT_HUGEPAGE printf blocks in
fs/proc/meminfo.c and drivers/base/node.c: the shorter names help.
Clarify a comment in page_remove_rmap() to refer to "hugetlbfs pages"
rather than hugepages generally.  I left arch/tile/mm/pgtable.c's
show_mem() unchanged: tile does not HAVE_ARCH_TRANSPARENT_HUGEPAGE.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 Documentation/filesystems/proc.txt |   10 ++++++++--
 drivers/base/node.c                |   20 +++++++++++---------
 fs/proc/meminfo.c                  |   11 ++++++++---
 include/linux/mmzone.h             |    5 ++++-
 mm/huge_memory.c                   |    2 +-
 mm/page_alloc.c                    |   17 +++++++++++++++++
 mm/rmap.c                          |   14 ++++++--------
 mm/vmstat.c                        |    3 +++
 8 files changed, 58 insertions(+), 24 deletions(-)

--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -853,7 +853,7 @@ Dirty:             968 kB
 Writeback:           0 kB
 AnonPages:      861800 kB
 Mapped:         280372 kB
-Shmem:             644 kB
+Shmem:           26396 kB
 Slab:           284364 kB
 SReclaimable:   159856 kB
 SUnreclaim:     124508 kB
@@ -867,6 +867,9 @@ VmallocTotal:   112216 kB
 VmallocUsed:       428 kB
 VmallocChunk:   111088 kB
 AnonHugePages:   49152 kB
+ShmemHugePages:  20480 kB
+ShmemPmdMapped:  12288 kB
+ShmemFreeHoles:      0 kB
 
     MemTotal: Total usable ram (i.e. physical ram minus a few reserved
               bits and the kernel binary code)
@@ -908,7 +911,6 @@ MemAvailable: An estimate of how much me
        Dirty: Memory which is waiting to get written back to the disk
    Writeback: Memory which is actively being written back to the disk
    AnonPages: Non-file backed pages mapped into userspace page tables
-AnonHugePages: Non-file backed huge pages mapped into userspace page tables
       Mapped: files which have been mmaped, such as libraries
        Shmem: Total memory used by shared memory (shmem) and tmpfs
         Slab: in-kernel data structures cache
@@ -949,6 +951,10 @@ Committed_AS: The amount of memory prese
 VmallocTotal: total size of vmalloc memory area
  VmallocUsed: amount of vmalloc area which is used
 VmallocChunk: largest contiguous block of vmalloc area which is free
+ AnonHugePages: Non-file backed huge pages mapped into userspace page tables
+ShmemHugePages: tmpfs-file backed huge pages completed (subset of Shmem)
+ShmemPmdMapped: tmpfs-file backed huge pages with huge mappings into userspace
+ShmemFreeHoles: Space reserved for tmpfs team pages but available to shrinker
 
 ..............................................................................
 
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -111,9 +111,6 @@ static ssize_t node_read_meminfo(struct
 		       "Node %d Slab:           %8lu kB\n"
 		       "Node %d SReclaimable:   %8lu kB\n"
 		       "Node %d SUnreclaim:     %8lu kB\n"
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		       "Node %d AnonHugePages:  %8lu kB\n"
-#endif
 			,
 		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
 		       nid, K(node_page_state(nid, NR_WRITEBACK)),
@@ -130,13 +127,18 @@ static ssize_t node_read_meminfo(struct
 		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE) +
 				node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
 		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE)),
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE))
-			, nid,
-			K(node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *
-			HPAGE_PMD_NR));
-#else
 		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	n += sprintf(buf + n,
+		"Node %d AnonHugePages:  %8lu kB\n"
+		"Node %d ShmemHugePages: %8lu kB\n"
+		"Node %d ShmemPmdMapped: %8lu kB\n"
+		"Node %d ShmemFreeHoles: %8lu kB\n",
+		nid, K(node_page_state(nid, NR_ANON_HUGEPAGES)*HPAGE_PMD_NR),
+		nid, K(node_page_state(nid, NR_SHMEM_HUGEPAGES)*HPAGE_PMD_NR),
+		nid, K(node_page_state(nid, NR_SHMEM_PMDMAPPED)*HPAGE_PMD_NR),
+		nid, K(node_page_state(nid, NR_SHMEM_FREEHOLES)));
 #endif
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -105,6 +105,9 @@ static int meminfo_proc_show(struct seq_
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		"AnonHugePages:  %8lu kB\n"
+		"ShmemHugePages: %8lu kB\n"
+		"ShmemPmdMapped: %8lu kB\n"
+		"ShmemFreeHoles: %8lu kB\n"
 #endif
 #ifdef CONFIG_CMA
 		"CmaTotal:       %8lu kB\n"
@@ -159,11 +162,13 @@ static int meminfo_proc_show(struct seq_
 		0ul, // used to be vmalloc 'used'
 		0ul  // used to be vmalloc 'largest_chunk'
 #ifdef CONFIG_MEMORY_FAILURE
-		, atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
+		, K(atomic_long_read(&num_poisoned_pages))
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		, K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
-		   HPAGE_PMD_NR)
+		, K(global_page_state(NR_ANON_HUGEPAGES) * HPAGE_PMD_NR)
+		, K(global_page_state(NR_SHMEM_HUGEPAGES) * HPAGE_PMD_NR)
+		, K(global_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR)
+		, K(global_page_state(NR_SHMEM_FREEHOLES))
 #endif
 #ifdef CONFIG_CMA
 		, K(totalcma_pages)
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -158,7 +158,10 @@ enum zone_stat_item {
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_NODERECLAIM,
-	NR_ANON_TRANSPARENT_HUGEPAGES,
+	NR_ANON_HUGEPAGES,	/* transparent anon huge pages */
+	NR_SHMEM_HUGEPAGES,	/* transparent shmem huge pages */
+	NR_SHMEM_PMDMAPPED,	/* shmem huge pages currently mapped hugely */
+	NR_SHMEM_FREEHOLES,	/* unused memory of high-order allocations */
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2943,7 +2943,7 @@ static void __split_huge_pmd_locked(stru
 
 	if (atomic_add_negative(-1, compound_mapcount_ptr(page))) {
 		/* Last compound_mapcount is gone. */
-		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		__dec_zone_page_state(page, NR_ANON_HUGEPAGES);
 		if (TestClearPageDoubleMap(page)) {
 			/* No need in mapcount reference anymore */
 			for (i = 0; i < HPAGE_PMD_NR; i++)
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3830,6 +3830,11 @@ out:
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define THPAGE_PMD_NR	HPAGE_PMD_NR
+#else
+#define THPAGE_PMD_NR	0	/* Avoid BUILD_BUG() */
+#endif
 
 static void show_migration_types(unsigned char type)
 {
@@ -3886,6 +3891,7 @@ void show_free_areas(unsigned int filter
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
+		" shmem_hugepages:%lu _pmdmapped:%lu _freeholes:%lu\n"
 		" free:%lu free_pcp:%lu free_cma:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_INACTIVE_ANON),
@@ -3903,6 +3909,9 @@ void show_free_areas(unsigned int filter
 		global_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
 		global_page_state(NR_BOUNCE),
+		global_page_state(NR_SHMEM_HUGEPAGES) * THPAGE_PMD_NR,
+		global_page_state(NR_SHMEM_PMDMAPPED) * THPAGE_PMD_NR,
+		global_page_state(NR_SHMEM_FREEHOLES),
 		global_page_state(NR_FREE_PAGES),
 		free_pcp,
 		global_page_state(NR_FREE_CMA_PAGES));
@@ -3937,6 +3946,9 @@ void show_free_areas(unsigned int filter
 			" writeback:%lukB"
 			" mapped:%lukB"
 			" shmem:%lukB"
+			" _hugepages:%lukB"
+			" _pmdmapped:%lukB"
+			" _freeholes:%lukB"
 			" slab_reclaimable:%lukB"
 			" slab_unreclaimable:%lukB"
 			" kernel_stack:%lukB"
@@ -3969,6 +3981,11 @@ void show_free_areas(unsigned int filter
 			K(zone_page_state(zone, NR_WRITEBACK)),
 			K(zone_page_state(zone, NR_FILE_MAPPED)),
 			K(zone_page_state(zone, NR_SHMEM)),
+			K(zone_page_state(zone, NR_SHMEM_HUGEPAGES) *
+							THPAGE_PMD_NR),
+			K(zone_page_state(zone, NR_SHMEM_PMDMAPPED) *
+							THPAGE_PMD_NR),
+			K(zone_page_state(zone, NR_SHMEM_FREEHOLES)),
 			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
 			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
 			zone_page_state(zone, NR_KERNEL_STACK) *
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1213,10 +1213,8 @@ void do_page_add_anon_rmap(struct page *
 		 * pte lock(a spinlock) is held, which implies preemption
 		 * disabled.
 		 */
-		if (compound) {
-			__inc_zone_page_state(page,
-					      NR_ANON_TRANSPARENT_HUGEPAGES);
-		}
+		if (compound)
+			__inc_zone_page_state(page, NR_ANON_HUGEPAGES);
 		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	}
 	if (unlikely(PageKsm(page)))
@@ -1254,7 +1252,7 @@ void page_add_new_anon_rmap(struct page
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		/* increment count (starts at -1) */
 		atomic_set(compound_mapcount_ptr(page), 0);
-		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		__inc_zone_page_state(page, NR_ANON_HUGEPAGES);
 	} else {
 		/* Anon THP always mapped first with PMD */
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
@@ -1285,7 +1283,7 @@ static void page_remove_file_rmap(struct
 {
 	lock_page_memcg(page);
 
-	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
+	/* hugetlbfs pages are not counted in NR_FILE_MAPPED for now. */
 	if (unlikely(PageHuge(page))) {
 		/* hugetlb pages are always mapped with pmds */
 		atomic_dec(compound_mapcount_ptr(page));
@@ -1317,14 +1315,14 @@ static void page_remove_anon_compound_rm
 	if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
 		return;
 
-	/* Hugepages are not counted in NR_ANON_PAGES for now. */
+	/* hugetlbfs pages are not counted in NR_ANON_PAGES for now. */
 	if (unlikely(PageHuge(page)))
 		return;
 
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
 		return;
 
-	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	__dec_zone_page_state(page, NR_ANON_HUGEPAGES);
 
 	if (TestClearPageDoubleMap(page)) {
 		/*
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -762,6 +762,9 @@ const char * const vmstat_text[] = {
 	"workingset_activate",
 	"workingset_nodereclaim",
 	"nr_anon_transparent_hugepages",
+	"nr_shmem_hugepages",
+	"nr_shmem_pmdmapped",
+	"nr_shmem_freeholes",
 	"nr_free_cma",
 
 	/* enum writeback_stat_item counters */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
