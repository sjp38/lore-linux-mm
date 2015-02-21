Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3463D6B0038
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:01:55 -0500 (EST)
Received: by pdev10 with SMTP id v10so11956408pde.10
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:01:54 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id ki9si1802441pdb.160.2015.02.20.20.01.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:01:54 -0800 (PST)
Received: by pdjz10 with SMTP id z10so11938944pdj.12
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:01:54 -0800 (PST)
Date: Fri, 20 Feb 2015 20:01:52 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 06/24] huge tmpfs: prepare counts in meminfo, vmstat and
 SysRq-m
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202000270.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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

The lines get rather long: abbreviate thus
  mapped:19778 shmem:38 pagetables:1153 bounce:0
  shmem_hugepages:0 _pmdmapped:0 _freeholes:2044
  free_cma:0
and
... shmem:92kB _hugepages:0kB _pmdmapped:0kB _freeholes:0kB ...

Tidy up the CONFIG_TRANSPARENT_HUGEPAGE printf blocks in
fs/proc/meminfo.c and drivers/base/node.c: the shorter names help.
Clarify a comment in page_remove_rmap() to refer to "hugetlbfs pages"
rather than hugepages generally.  I left arch/tile/mm/pgtable.c's
show_mem() unchanged: tile does not HAVE_ARCH_TRANSPARENT_HUGEPAGE.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 drivers/base/node.c    |   20 +++++++++++---------
 fs/proc/meminfo.c      |   11 ++++++++---
 include/linux/mmzone.h |    5 ++++-
 mm/huge_memory.c       |    2 +-
 mm/page_alloc.c        |   13 +++++++++++--
 mm/rmap.c              |    9 ++++-----
 mm/vmstat.c            |    3 +++
 7 files changed, 42 insertions(+), 21 deletions(-)

--- thpfs.orig/drivers/base/node.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/drivers/base/node.c	2015-02-20 19:33:51.488038441 -0800
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
--- thpfs.orig/fs/proc/meminfo.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/fs/proc/meminfo.c	2015-02-20 19:33:51.488038441 -0800
@@ -140,6 +140,9 @@ static int meminfo_proc_show(struct seq_
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		"AnonHugePages:  %8lu kB\n"
+		"ShmemHugePages: %8lu kB\n"
+		"ShmemPmdMapped: %8lu kB\n"
+		"ShmemFreeHoles: %8lu kB\n"
 #endif
 #ifdef CONFIG_CMA
 		"CmaTotal:       %8lu kB\n"
@@ -194,11 +197,13 @@ static int meminfo_proc_show(struct seq_
 		vmi.used >> 10,
 		vmi.largest_chunk >> 10
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
--- thpfs.orig/include/linux/mmzone.h	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/include/linux/mmzone.h	2015-02-20 19:33:51.492038431 -0800
@@ -155,7 +155,10 @@ enum zone_stat_item {
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
 
--- thpfs.orig/mm/huge_memory.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/huge_memory.c	2015-02-20 19:33:51.492038431 -0800
@@ -1747,7 +1747,7 @@ static void __split_huge_page_refcount(s
 	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
-	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
+	__mod_zone_page_state(zone, NR_ANON_HUGEPAGES, -1);
 
 	ClearPageCompound(page);
 	compound_unlock(page);
--- thpfs.orig/mm/page_alloc.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/page_alloc.c	2015-02-20 19:33:51.492038431 -0800
@@ -3279,10 +3279,10 @@ void show_free_areas(unsigned int filter
 
 	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
 		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
-		" unevictable:%lu"
-		" dirty:%lu writeback:%lu unstable:%lu\n"
+		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
+		" shmem_hugepages:%lu _pmdmapped:%lu _freeholes:%lu\n"
 		" free_cma:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_INACTIVE_ANON),
@@ -3301,6 +3301,9 @@ void show_free_areas(unsigned int filter
 		global_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
 		global_page_state(NR_BOUNCE),
+		global_page_state(NR_SHMEM_HUGEPAGES),
+		global_page_state(NR_SHMEM_PMDMAPPED),
+		global_page_state(NR_SHMEM_FREEHOLES),
 		global_page_state(NR_FREE_CMA_PAGES));
 
 	for_each_populated_zone(zone) {
@@ -3328,6 +3331,9 @@ void show_free_areas(unsigned int filter
 			" writeback:%lukB"
 			" mapped:%lukB"
 			" shmem:%lukB"
+			" _hugepages:%lukB"
+			" _pmdmapped:%lukB"
+			" _freeholes:%lukB"
 			" slab_reclaimable:%lukB"
 			" slab_unreclaimable:%lukB"
 			" kernel_stack:%lukB"
@@ -3358,6 +3364,9 @@ void show_free_areas(unsigned int filter
 			K(zone_page_state(zone, NR_WRITEBACK)),
 			K(zone_page_state(zone, NR_FILE_MAPPED)),
 			K(zone_page_state(zone, NR_SHMEM)),
+			K(zone_page_state(zone, NR_SHMEM_HUGEPAGES)),
+			K(zone_page_state(zone, NR_SHMEM_PMDMAPPED)),
+			K(zone_page_state(zone, NR_SHMEM_FREEHOLES)),
 			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
 			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
 			zone_page_state(zone, NR_KERNEL_STACK) *
--- thpfs.orig/mm/rmap.c	2015-02-20 19:33:35.676074594 -0800
+++ thpfs/mm/rmap.c	2015-02-20 19:33:51.496038422 -0800
@@ -1038,8 +1038,7 @@ void do_page_add_anon_rmap(struct page *
 		 * disabled.
 		 */
 		if (PageTransHuge(page))
-			__inc_zone_page_state(page,
-					      NR_ANON_TRANSPARENT_HUGEPAGES);
+			__inc_zone_page_state(page, NR_ANON_HUGEPAGES);
 		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
 				hpage_nr_pages(page));
 	}
@@ -1071,7 +1070,7 @@ void page_add_new_anon_rmap(struct page
 	__SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (PageTransHuge(page))
-		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		__inc_zone_page_state(page, NR_ANON_HUGEPAGES);
 	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
 			hpage_nr_pages(page));
 	__page_set_anon_rmap(page, vma, address, 1);
@@ -1109,7 +1108,7 @@ static void page_remove_file_rmap(struct
 	if (!atomic_add_negative(-1, &page->_mapcount))
 		goto out;
 
-	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
+	/* hugetlbfs pages are not counted in NR_FILE_MAPPED for now. */
 	if (unlikely(PageHuge(page)))
 		goto out;
 
@@ -1154,7 +1153,7 @@ void page_remove_rmap(struct page *page)
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
 	if (PageTransHuge(page))
-		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		__dec_zone_page_state(page, NR_ANON_HUGEPAGES);
 
 	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
 			      -hpage_nr_pages(page));
--- thpfs.orig/mm/vmstat.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/vmstat.c	2015-02-20 19:33:51.496038422 -0800
@@ -795,6 +795,9 @@ const char * const vmstat_text[] = {
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
