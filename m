Date: Thu, 25 Jan 2007 21:43:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] Track mlock()ed pages
Message-ID: <Pine.LNX.4.64.0701252141570.10629@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

Add NR_MLOCK

Track mlocked pages via a ZVC

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc6/include/linux/mmzone.h
===================================================================
--- linux-2.6.20-rc6.orig/include/linux/mmzone.h	2007-01-25 20:29:58.000000000 -0800
+++ linux-2.6.20-rc6/include/linux/mmzone.h	2007-01-25 20:31:23.000000000 -0800
@@ -58,6 +58,7 @@ enum zone_stat_item {
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
 	/* Second 128 byte cacheline */
+	NR_MLOCK,		/* Mlocked pages */
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,		/* used for pagetables */
Index: linux-2.6.20-rc6/mm/rmap.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/rmap.c	2007-01-25 20:18:38.000000000 -0800
+++ linux-2.6.20-rc6/mm/rmap.c	2007-01-25 20:31:23.000000000 -0800
@@ -551,6 +551,8 @@ void page_add_new_anon_rmap(struct page 
 {
 	atomic_set(&page->_mapcount, 0); /* elevate count by 1 (starts at -1) */
 	__page_set_anon_rmap(page, vma, address);
+	if (vma->vm_flags & VM_LOCKED)
+		__inc_zone_page_state(page, NR_MLOCK);
 }
 
 /**
@@ -565,6 +567,16 @@ void page_add_file_rmap(struct page *pag
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
 }
 
+/*
+ * Add an rmap in a known vma. This allows us to update the mlock counter.
+ */
+void page_add_file_rmap_vma(struct page *page, struct vm_area_struct *vma)
+{
+	page_add_file_rmap(page);
+	if (vma->vm_flags & VM_LOCKED)
+		__inc_zone_page_state(page, NR_MLOCK);
+}
+
 /**
  * page_remove_rmap - take down pte mapping from a page
  * @page: page to remove mapping from
@@ -602,6 +614,8 @@ void page_remove_rmap(struct page *page,
 		__dec_zone_page_state(page,
 				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
 	}
+	if (vma->vm_flags & VM_LOCKED)
+		__dec_zone_page_state(page, NR_MLOCK);
 }
 
 /*
Index: linux-2.6.20-rc6/include/linux/rmap.h
===================================================================
--- linux-2.6.20-rc6.orig/include/linux/rmap.h	2007-01-25 20:18:38.000000000 -0800
+++ linux-2.6.20-rc6/include/linux/rmap.h	2007-01-25 20:31:23.000000000 -0800
@@ -72,6 +72,7 @@ void __anon_vma_link(struct vm_area_stru
 void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_file_rmap(struct page *);
+void page_add_file_rmap_vma(struct page *, struct vm_area_struct *);
 void page_remove_rmap(struct page *, struct vm_area_struct *);
 
 /**
Index: linux-2.6.20-rc6/mm/fremap.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/fremap.c	2007-01-25 20:18:38.000000000 -0800
+++ linux-2.6.20-rc6/mm/fremap.c	2007-01-25 20:31:23.000000000 -0800
@@ -81,7 +81,7 @@ int install_page(struct mm_struct *mm, s
 	flush_icache_page(vma, page);
 	pte_val = mk_pte(page, prot);
 	set_pte_at(mm, addr, pte, pte_val);
-	page_add_file_rmap(page);
+	page_add_file_rmap_vma(page, vma);
 	update_mmu_cache(vma, addr, pte_val);
 	lazy_mmu_prot_update(pte_val);
 	err = 0;
Index: linux-2.6.20-rc6/mm/memory.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/memory.c	2007-01-25 20:18:38.000000000 -0800
+++ linux-2.6.20-rc6/mm/memory.c	2007-01-25 20:31:23.000000000 -0800
@@ -2256,7 +2256,7 @@ retry:
 			page_add_new_anon_rmap(new_page, vma, address);
 		} else {
 			inc_mm_counter(mm, file_rss);
-			page_add_file_rmap(new_page);
+			page_add_file_rmap_vma(new_page, vma);
 			if (write_access) {
 				dirty_page = new_page;
 				get_page(dirty_page);
Index: linux-2.6.20-rc6/drivers/base/node.c
===================================================================
--- linux-2.6.20-rc6.orig/drivers/base/node.c	2007-01-25 20:30:17.000000000 -0800
+++ linux-2.6.20-rc6/drivers/base/node.c	2007-01-25 20:31:23.000000000 -0800
@@ -60,6 +60,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d FilePages:    %8lu kB\n"
 		       "Node %d Mapped:       %8lu kB\n"
 		       "Node %d AnonPages:    %8lu kB\n"
+		       "Node %d Mlock:        %8lu KB\n"
 		       "Node %d PageTables:   %8lu kB\n"
 		       "Node %d NFS_Unstable: %8lu kB\n"
 		       "Node %d Bounce:       %8lu kB\n"
@@ -82,6 +83,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
+		       nid, K(node_page_state(nid, NR_MLOCK)),
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
 		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
 		       nid, K(node_page_state(nid, NR_BOUNCE)),
Index: linux-2.6.20-rc6/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.20-rc6.orig/fs/proc/proc_misc.c	2007-01-25 20:30:21.000000000 -0800
+++ linux-2.6.20-rc6/fs/proc/proc_misc.c	2007-01-25 20:31:23.000000000 -0800
@@ -166,6 +166,7 @@ static int meminfo_read_proc(char *page,
 		"Writeback:    %8lu kB\n"
 		"AnonPages:    %8lu kB\n"
 		"Mapped:       %8lu kB\n"
+		"Mlock:        %8lu KB\n"
 		"Slab:         %8lu kB\n"
 		"SReclaimable: %8lu kB\n"
 		"SUnreclaim:   %8lu kB\n"
@@ -196,6 +197,7 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_WRITEBACK)),
 		K(global_page_state(NR_ANON_PAGES)),
 		K(global_page_state(NR_FILE_MAPPED)),
+		K(global_page_state(NR_MLOCK)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE) +
 				global_page_state(NR_SLAB_UNRECLAIMABLE)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE)),
Index: linux-2.6.20-rc6/mm/vmstat.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/vmstat.c	2007-01-25 20:30:21.000000000 -0800
+++ linux-2.6.20-rc6/mm/vmstat.c	2007-01-25 20:31:23.000000000 -0800
@@ -433,6 +433,7 @@ static const char * const vmstat_text[] 
 	"nr_file_pages",
 	"nr_dirty",
 	"nr_writeback",
+	"nr_mlock",
 	"nr_slab_reclaimable",
 	"nr_slab_unreclaimable",
 	"nr_page_table_pages",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
