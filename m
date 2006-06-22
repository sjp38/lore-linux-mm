Date: Thu, 22 Jun 2006 09:40:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060622164051.28809.2207.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
References: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 09/14] Conversion of nr_pagetables to per zone counter
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: conversion of nr_pagetable to per zone counter
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Conversion of nr_page_table_pages to a per zone counter

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-mm1/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.17-mm1.orig/arch/i386/mm/pgtable.c	2006-06-22 08:23:00.263168234 -0700
+++ linux-2.6.17-mm1/arch/i386/mm/pgtable.c	2006-06-22 08:37:08.449894359 -0700
@@ -63,7 +63,8 @@ void show_mem(void)
 	printk(KERN_INFO "%lu pages writeback\n", ps.nr_writeback);
 	printk(KERN_INFO "%lu pages mapped\n", global_page_state(NR_FILE_MAPPED));
 	printk(KERN_INFO "%lu pages slab\n", global_page_state(NR_SLAB));
-	printk(KERN_INFO "%lu pages pagetables\n", ps.nr_page_table_pages);
+	printk(KERN_INFO "%lu pages pagetables\n",
+					global_page_state(NR_PAGETABLE));
 }
 
 /*
Index: linux-2.6.17-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/proc/proc_misc.c	2006-06-22 08:23:00.265121238 -0700
+++ linux-2.6.17-mm1/fs/proc/proc_misc.c	2006-06-22 08:37:08.450870861 -0700
@@ -171,9 +171,9 @@ static int meminfo_read_proc(char *page,
 		"AnonPages:    %8lu kB\n"
 		"Mapped:       %8lu kB\n"
 		"Slab:         %8lu kB\n"
+		"PageTables:   %8lu kB\n"
 		"CommitLimit:  %8lu kB\n"
 		"Committed_AS: %8lu kB\n"
-		"PageTables:   %8lu kB\n"
 		"VmallocTotal: %8lu kB\n"
 		"VmallocUsed:  %8lu kB\n"
 		"VmallocChunk: %8lu kB\n",
@@ -195,9 +195,9 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_ANON_PAGES)),
 		K(global_page_state(NR_FILE_MAPPED)),
 		K(global_page_state(NR_SLAB)),
+		K(global_page_state(NR_PAGETABLE)),
 		K(allowed),
 		K(committed),
-		K(ps.nr_page_table_pages),
 		(unsigned long)VMALLOC_TOTAL >> 10,
 		vmi.used >> 10,
 		vmi.largest_chunk >> 10
Index: linux-2.6.17-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-22 08:23:00.266097740 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-22 08:37:08.451847363 -0700
@@ -53,6 +53,7 @@ enum zone_stat_item {
 			   only modified from process context */
 	NR_FILE_PAGES,
 	NR_SLAB,	/* Pages used by slab allocator */
+	NR_PAGETABLE,	/* used for pagetables */
 	NR_VM_ZONE_STAT_ITEMS };
 
 struct per_cpu_pages {
Index: linux-2.6.17-mm1/mm/memory.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/memory.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/mm/memory.c	2006-06-22 08:37:08.452823865 -0700
@@ -126,7 +126,7 @@ static void free_pte_range(struct mmu_ga
 	pmd_clear(pmd);
 	pte_lock_deinit(page);
 	pte_free_tlb(tlb, page);
-	dec_page_state(nr_page_table_pages);
+	dec_zone_page_state(page, NR_PAGETABLE);
 	tlb->mm->nr_ptes--;
 }
 
@@ -311,7 +311,7 @@ int __pte_alloc(struct mm_struct *mm, pm
 		pte_free(new);
 	} else {
 		mm->nr_ptes++;
-		inc_page_state(nr_page_table_pages);
+		inc_zone_page_state(new, NR_PAGETABLE);
 		pmd_populate(mm, pmd, new);
 	}
 	spin_unlock(&mm->page_table_lock);
Index: linux-2.6.17-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page_alloc.c	2006-06-22 08:23:00.267074242 -0700
+++ linux-2.6.17-mm1/mm/page_alloc.c	2006-06-22 08:37:08.454776869 -0700
@@ -1315,7 +1315,7 @@ void show_free_areas(void)
 		nr_free_pages(),
 		global_page_state(NR_SLAB),
 		global_page_state(NR_FILE_MAPPED),
-		ps.nr_page_table_pages);
+		global_page_state(NR_PAGETABLE));
 
 	for_each_zone(zone) {
 		int i;
Index: linux-2.6.17-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.17-mm1.orig/drivers/base/node.c	2006-06-22 08:23:00.264144736 -0700
+++ linux-2.6.17-mm1/drivers/base/node.c	2006-06-22 08:37:08.455753371 -0700
@@ -69,6 +69,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d FilePages:    %8lu kB\n"
 		       "Node %d Mapped:       %8lu kB\n"
 		       "Node %d AnonPages:    %8lu kB\n"
+		       "Node %d PageTables:   %8lu kB\n"
 		       "Node %d Slab:         %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
@@ -84,6 +85,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
+		       nid, K(node_page_state(nid, NR_PAGETABLE)),
 		       nid, K(node_page_state(nid, NR_SLAB)));
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
Index: linux-2.6.17-mm1/arch/um/kernel/skas/mmu.c
===================================================================
--- linux-2.6.17-mm1.orig/arch/um/kernel/skas/mmu.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/arch/um/kernel/skas/mmu.c	2006-06-22 08:37:08.456729873 -0700
@@ -152,7 +152,7 @@ void destroy_context_skas(struct mm_stru
 		free_page(mmu->id.stack);
 		pte_lock_deinit(virt_to_page(mmu->last_page_table));
 		pte_free_kernel((pte_t *) mmu->last_page_table);
-                dec_page_state(nr_page_table_pages);
+		dec_zone_page_state(virt_to_page(mmu->last_page_table), NR_PAGETABLE);
 #ifdef CONFIG_3_LEVEL_PGTABLES
 		pmd_free((pmd_t *) mmu->last_pmd);
 #endif
Index: linux-2.6.17-mm1/arch/arm/mm/mm-armv.c
===================================================================
--- linux-2.6.17-mm1.orig/arch/arm/mm/mm-armv.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/arch/arm/mm/mm-armv.c	2006-06-22 08:37:08.456729873 -0700
@@ -227,7 +227,7 @@ void free_pgd_slow(pgd_t *pgd)
 
 	pte = pmd_page(*pmd);
 	pmd_clear(pmd);
-	dec_page_state(nr_page_table_pages);
+	dec_zone_page_state(virt_to_page((unsigned long *)pgd), NR_PAGETABLE);
 	pte_lock_deinit(pte);
 	pte_free(pte);
 	pmd_free(pmd);
Index: linux-2.6.17-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmstat.c	2006-06-22 08:23:00.270003748 -0700
+++ linux-2.6.17-mm1/mm/vmstat.c	2006-06-22 08:37:08.457706375 -0700
@@ -461,12 +461,12 @@ static char *vmstat_text[] = {
 	"nr_mapped",
 	"nr_file_pages",
 	"nr_slab",
+	"nr_page_table_pages",
 
 	/* Page state */
 	"nr_dirty",
 	"nr_writeback",
 	"nr_unstable",
-	"nr_page_table_pages",
 
 	"pgpgin",
 	"pgpgout",
Index: linux-2.6.17-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/vmstat.h	2006-06-22 08:23:17.482805961 -0700
+++ linux-2.6.17-mm1/include/linux/vmstat.h	2006-06-22 08:37:27.048350906 -0700
@@ -24,8 +24,7 @@ struct page_state {
 	unsigned long nr_dirty;		/* Dirty writeable pages */
 	unsigned long nr_writeback;	/* Pages under writeback */
 	unsigned long nr_unstable;	/* NFS unstable pages */
-	unsigned long nr_page_table_pages;/* Pages used for pagetables */
-#define GET_PAGE_STATE_LAST nr_page_table_pages
+#define GET_PAGE_STATE_LAST nr_unstable
 
 	/*
 	 * The below are zeroed by get_page_state().  Use get_full_page_state()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
