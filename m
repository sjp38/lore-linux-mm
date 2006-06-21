Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5LFkXnx030010
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 10:46:33 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5LG2n7p35969367
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 09:02:49 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5LFkWnB42445966
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:32 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1Ft4uW-0004wS-00
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:32 -0700
Date: Wed, 21 Jun 2006 08:44:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060621154440.18741.39333.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 04/14] Conversion of nr_pagecache to per zone counter
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606210846270.18960@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: conversion of nr_pagecache to per zone counter
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Martin Bligh <mbligh@google.com>, linux-mm@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Currently a single atomic variable is used to establish the size of the page
cache in the whole machine. The zoned VM counters have the same method of
implementation as the nr_pagecache code but also allow the determination of
the pagecache size per zone.

Remove the special implementation for nr_pagecache and make it a zoned
counter named NR_FILE_PAGES.

Updates of the page cache counters are always performed with interrupts off.
We can therefore use the __ variant here.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-mm1/arch/sparc64/kernel/sys_sunos32.c
===================================================================
--- linux-2.6.17-mm1.orig/arch/sparc64/kernel/sys_sunos32.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/arch/sparc64/kernel/sys_sunos32.c	2006-06-21 07:36:17.677405206 -0700
@@ -155,7 +155,7 @@ asmlinkage int sunos_brk(u32 baddr)
 	 * simple, it hopefully works in most obvious cases.. Easy to
 	 * fool it, but this should catch most mistakes.
 	 */
-	freepages = get_page_cache_size();
+	freepages = global_page_state(NR_FILE_PAGES);
 	freepages >>= 1;
 	freepages += nr_free_pages();
 	freepages += nr_swap_pages;
Index: linux-2.6.17-mm1/arch/sparc/kernel/sys_sunos.c
===================================================================
--- linux-2.6.17-mm1.orig/arch/sparc/kernel/sys_sunos.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/arch/sparc/kernel/sys_sunos.c	2006-06-21 07:36:17.678381708 -0700
@@ -196,7 +196,7 @@ asmlinkage int sunos_brk(unsigned long b
 	 * simple, it hopefully works in most obvious cases.. Easy to
 	 * fool it, but this should catch most mistakes.
 	 */
-	freepages = get_page_cache_size();
+	freepages = global_page_state(NR_FILE_PAGES);
 	freepages >>= 1;
 	freepages += nr_free_pages();
 	freepages += nr_swap_pages;
Index: linux-2.6.17-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/proc/proc_misc.c	2006-06-21 07:34:08.376833270 -0700
+++ linux-2.6.17-mm1/fs/proc/proc_misc.c	2006-06-21 07:36:17.679358210 -0700
@@ -142,7 +142,8 @@ static int meminfo_read_proc(char *page,
 	allowed = ((totalram_pages - hugetlb_total_pages())
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;
 
-	cached = get_page_cache_size() - total_swapcache_pages - i.bufferram;
+	cached = global_page_state(NR_FILE_PAGES) -
+			total_swapcache_pages - i.bufferram;
 	if (cached < 0)
 		cached = 0;
 
Index: linux-2.6.17-mm1/include/linux/pagemap.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/pagemap.h	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/include/linux/pagemap.h	2006-06-21 07:36:17.680334712 -0700
@@ -106,51 +106,6 @@ int add_to_page_cache_lru(struct page *p
 extern void remove_from_page_cache(struct page *page);
 extern void __remove_from_page_cache(struct page *page);
 
-extern atomic_t nr_pagecache;
-
-#ifdef CONFIG_SMP
-
-#define PAGECACHE_ACCT_THRESHOLD        max(16, NR_CPUS * 2)
-DECLARE_PER_CPU(long, nr_pagecache_local);
-
-/*
- * pagecache_acct implements approximate accounting for pagecache.
- * vm_enough_memory() do not need high accuracy. Writers will keep
- * an offset in their per-cpu arena and will spill that into the
- * global count whenever the absolute value of the local count
- * exceeds the counter's threshold.
- *
- * MUST be protected from preemption.
- * current protection is mapping->page_lock.
- */
-static inline void pagecache_acct(int count)
-{
-	long *local;
-
-	local = &__get_cpu_var(nr_pagecache_local);
-	*local += count;
-	if (*local > PAGECACHE_ACCT_THRESHOLD || *local < -PAGECACHE_ACCT_THRESHOLD) {
-		atomic_add(*local, &nr_pagecache);
-		*local = 0;
-	}
-}
-
-#else
-
-static inline void pagecache_acct(int count)
-{
-	atomic_add(count, &nr_pagecache);
-}
-#endif
-
-static inline unsigned long get_page_cache_size(void)
-{
-	int ret = atomic_read(&nr_pagecache);
-	if (unlikely(ret < 0))
-		ret = 0;
-	return ret;
-}
-
 /*
  * Return byte-offset into filesystem object for page.
  */
Index: linux-2.6.17-mm1/mm/filemap.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/filemap.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/mm/filemap.c	2006-06-21 07:36:17.682287716 -0700
@@ -120,7 +120,7 @@ void __remove_from_page_cache(struct pag
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
-	pagecache_acct(-1);
+	__dec_zone_page_state(page, NR_FILE_PAGES);
 }
 
 void remove_from_page_cache(struct page *page)
@@ -415,7 +415,7 @@ int add_to_page_cache(struct page *page,
 			page->mapping = mapping;
 			page->index = offset;
 			mapping->nrpages++;
-			pagecache_acct(1);
+			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
 		write_unlock_irq(&mapping->tree_lock);
 		radix_tree_preload_end();
Index: linux-2.6.17-mm1/mm/mmap.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/mmap.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/mm/mmap.c	2006-06-21 07:36:17.684240720 -0700
@@ -96,7 +96,7 @@ int __vm_enough_memory(long pages, int c
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		unsigned long n;
 
-		free = get_page_cache_size();
+		free = global_page_state(NR_FILE_PAGES);
 		free += nr_swap_pages;
 
 		/*
Index: linux-2.6.17-mm1/mm/nommu.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/nommu.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/mm/nommu.c	2006-06-21 07:36:17.684240720 -0700
@@ -1122,7 +1122,7 @@ int __vm_enough_memory(long pages, int c
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		unsigned long n;
 
-		free = get_page_cache_size();
+		free = global_page_state(NR_FILE_PAGES);
 		free += nr_swap_pages;
 
 		/*
Index: linux-2.6.17-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page_alloc.c	2006-06-21 07:34:08.379762776 -0700
+++ linux-2.6.17-mm1/mm/page_alloc.c	2006-06-21 07:36:17.686193724 -0700
@@ -2049,16 +2049,11 @@ static int page_alloc_cpu_notify(struct 
 				 unsigned long action, void *hcpu)
 {
 	int cpu = (unsigned long)hcpu;
-	long *count;
 	unsigned long *src, *dest;
 
 	if (action == CPU_DEAD) {
 		int i;
 
-		/* Drain local pagecache count. */
-		count = &per_cpu(nr_pagecache_local, cpu);
-		atomic_add(*count, &nr_pagecache);
-		*count = 0;
 		local_irq_disable();
 		__drain_pages(cpu);
 
Index: linux-2.6.17-mm1/mm/swap_state.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/swap_state.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/mm/swap_state.c	2006-06-21 07:36:17.686193724 -0700
@@ -87,7 +87,7 @@ static int __add_to_swap_cache(struct pa
 			SetPageSwapCache(page);
 			set_page_private(page, entry.val);
 			total_swapcache_pages++;
-			pagecache_acct(1);
+			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
 		write_unlock_irq(&swapper_space.tree_lock);
 		radix_tree_preload_end();
@@ -132,7 +132,7 @@ void __delete_from_swap_cache(struct pag
 	set_page_private(page, 0);
 	ClearPageSwapCache(page);
 	total_swapcache_pages--;
-	pagecache_acct(-1);
+	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
 }
 
Index: linux-2.6.17-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-21 07:34:08.377809772 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-21 07:36:17.687170225 -0700
@@ -50,7 +50,7 @@ struct zone_padding {
 enum zone_stat_item {
 	NR_FILE_MAPPED,	/* mapped into pagetables.
 			   only modified from process context */
-
+	NR_FILE_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
 struct per_cpu_pages {
Index: linux-2.6.17-mm1/arch/s390/appldata/appldata_mem.c
===================================================================
--- linux-2.6.17-mm1.orig/arch/s390/appldata/appldata_mem.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/arch/s390/appldata/appldata_mem.c	2006-06-21 07:36:17.688146727 -0700
@@ -130,7 +130,8 @@ static void appldata_get_mem_data(void *
 	mem_data->totalhigh = P2K(val.totalhigh);
 	mem_data->freehigh  = P2K(val.freehigh);
 	mem_data->bufferram = P2K(val.bufferram);
-	mem_data->cached    = P2K(atomic_read(&nr_pagecache) - val.bufferram);
+	mem_data->cached    = P2K(global_page_state(NR_FILE_PAGES)
+				- val.bufferram);
 
 	si_swapinfo(&val);
 	mem_data->totalswap = P2K(val.totalswap);
Index: linux-2.6.17-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.17-mm1.orig/drivers/base/node.c	2006-06-21 07:34:08.375856768 -0700
+++ linux-2.6.17-mm1/drivers/base/node.c	2006-06-21 07:36:17.689123229 -0700
@@ -68,6 +68,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d LowFree:      %8lu kB\n"
 		       "Node %d Dirty:        %8lu kB\n"
 		       "Node %d Writeback:    %8lu kB\n"
+		       "Node %d FilePages:    %8lu kB\n"
 		       "Node %d Mapped:       %8lu kB\n"
 		       "Node %d Slab:         %8lu kB\n",
 		       nid, K(i.totalram),
@@ -81,6 +82,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(i.freeram - i.freehigh),
 		       nid, K(ps.nr_dirty),
 		       nid, K(ps.nr_writeback),
+		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(ps.nr_slab));
 	n += hugetlb_report_node_meminfo(nid, buf + n);
Index: linux-2.6.17-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmstat.c	2006-06-21 07:34:08.382692282 -0700
+++ linux-2.6.17-mm1/mm/vmstat.c	2006-06-21 07:36:17.689123229 -0700
@@ -20,12 +20,6 @@
  */
 static DEFINE_PER_CPU(struct page_state, page_states) = {0};
 
-atomic_t nr_pagecache = ATOMIC_INIT(0);
-EXPORT_SYMBOL(nr_pagecache);
-#ifdef CONFIG_SMP
-DEFINE_PER_CPU(long, nr_pagecache_local) = 0;
-#endif
-
 static void __get_page_state(struct page_state *ret, int nr, cpumask_t *cpumask)
 {
 	unsigned cpu;
@@ -464,6 +458,7 @@ struct seq_operations fragmentation_op =
 static char *vmstat_text[] = {
 	/* Zoned VM counters */
 	"nr_mapped",
+	"nr_file_pages",
 
 	/* Page state */
 	"nr_dirty",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
