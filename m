Date: Fri, 25 Aug 2006 18:25:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: ZVC: Support NR_SLAB_RECLAIMABLE / NR_SLAB_UNRECLAIMABLE
Message-ID: <Pine.LNX.4.64.0608251824310.11715@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove the atomic counter for slab_reclaim_pages and replace
the counter and NR_SLAB with two ZVC counter that account
for unreclaimable and reclaimable slab pages: NR_SLAB_RECLAIMABLE
and NR_SLAB_UNRECLAIMABLE.

Change the check in vmscan.c to refer to to NR_SLAB_RECLAIMABLE.
The intend seems to be to check for slab pages that could be freed.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4-mm2/mm/mmap.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/mmap.c	2006-08-23 12:37:01.836055970 -0700
+++ linux-2.6.18-rc4-mm2/mm/mmap.c	2006-08-25 17:59:08.262240345 -0700
@@ -112,7 +112,7 @@ int __vm_enough_memory(long pages, int c
 		 * which are reclaimable, under pressure.  The dentry
 		 * cache and most inode caches should fall into this
 		 */
-		free += atomic_read(&slab_reclaim_pages);
+		free += global_page_state(NR_SLAB_RECLAIMABLE);
 
 		/*
 		 * Leave the last 3% for root
Index: linux-2.6.18-rc4-mm2/mm/slab.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/slab.c	2006-08-23 12:37:01.858515518 -0700
+++ linux-2.6.18-rc4-mm2/mm/slab.c	2006-08-25 17:59:08.264193349 -0700
@@ -738,14 +738,6 @@ static DEFINE_MUTEX(cache_chain_mutex);
 static struct list_head cache_chain;
 
 /*
- * vm_enough_memory() looks at this to determine how many slab-allocated pages
- * are possibly freeable under pressure
- *
- * SLAB_RECLAIM_ACCOUNT turns this on per-slab
- */
-atomic_t slab_reclaim_pages;
-
-/*
  * chicken and egg problem: delay the per-cpu array allocation
  * until the general caches are up.
  */
@@ -1582,8 +1574,11 @@ static void *kmem_getpages(struct kmem_c
 
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
-		atomic_add(nr_pages, &slab_reclaim_pages);
-	add_zone_page_state(page_zone(page), NR_SLAB, nr_pages);
+		add_zone_page_state(page_zone(page),
+			NR_SLAB_RECLAIMABLE, nr_pages);
+	else
+		add_zone_page_state(page_zone(page),
+			NR_SLAB_UNRECLAIMABLE, nr_pages);
 	for (i = 0; i < nr_pages; i++)
 		__SetPageSlab(page + i);
 	return page_address(page);
@@ -1598,7 +1593,12 @@ static void kmem_freepages(struct kmem_c
 	struct page *page = virt_to_page(addr);
 	const unsigned long nr_freed = i;
 
-	sub_zone_page_state(page_zone(page), NR_SLAB, nr_freed);
+	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
+		sub_zone_page_state(page_zone(page),
+				NR_SLAB_RECLAIMABLE, nr_freed);
+	else
+		sub_zone_page_state(page_zone(page),
+				NR_SLAB_UNRECLAIMABLE, nr_freed);
 	while (i--) {
 		BUG_ON(!PageSlab(page));
 		__ClearPageSlab(page);
@@ -1607,8 +1607,6 @@ static void kmem_freepages(struct kmem_c
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
 	free_pages((unsigned long)addr, cachep->gfporder);
-	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
-		atomic_sub(1 << cachep->gfporder, &slab_reclaim_pages);
 }
 
 static void kmem_rcu_free(struct rcu_head *head)
Index: linux-2.6.18-rc4-mm2/mm/slob.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/slob.c	2006-08-06 11:20:11.000000000 -0700
+++ linux-2.6.18-rc4-mm2/mm/slob.c	2006-08-25 17:59:08.265169851 -0700
@@ -340,9 +340,6 @@ void kmem_cache_init(void)
 	mod_timer(&slob_timer, jiffies + HZ);
 }
 
-atomic_t slab_reclaim_pages = ATOMIC_INIT(0);
-EXPORT_SYMBOL(slab_reclaim_pages);
-
 #ifdef CONFIG_SMP
 
 void *__alloc_percpu(size_t size)
Index: linux-2.6.18-rc4-mm2/mm/nommu.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/nommu.c	2006-08-06 11:20:11.000000000 -0700
+++ linux-2.6.18-rc4-mm2/mm/nommu.c	2006-08-25 17:59:08.265169851 -0700
@@ -1133,7 +1133,7 @@ int __vm_enough_memory(long pages, int c
 		 * which are reclaimable, under pressure.  The dentry
 		 * cache and most inode caches should fall into this
 		 */
-		free += atomic_read(&slab_reclaim_pages);
+		free += global_page_state(NR_SLAB_RECLAIMABLE);
 
 		/*
 		 * Leave the last 3% for root
Index: linux-2.6.18-rc4-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.18-rc4-mm2.orig/include/linux/slab.h	2006-08-23 12:37:01.493303726 -0700
+++ linux-2.6.18-rc4-mm2/include/linux/slab.h	2006-08-25 17:59:08.267122856 -0700
@@ -291,8 +291,6 @@ extern kmem_cache_t	*fs_cachep;
 extern kmem_cache_t	*sighand_cachep;
 extern kmem_cache_t	*bio_cachep;
 
-extern atomic_t slab_reclaim_pages;
-
 #endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_SLAB_H */
Index: linux-2.6.18-rc4-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.18-rc4-mm2.orig/include/linux/mmzone.h	2006-08-25 17:59:06.494771301 -0700
+++ linux-2.6.18-rc4-mm2/include/linux/mmzone.h	2006-08-25 17:59:08.267122856 -0700
@@ -51,7 +51,8 @@ enum zone_stat_item {
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
-	NR_SLAB,	/* Pages used by slab allocator */
+	NR_SLAB_RECLAIMABLE,
+	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,	/* used for pagetables */
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
Index: linux-2.6.18-rc4-mm2/mm/vmstat.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/vmstat.c	2006-08-23 12:37:01.866327535 -0700
+++ linux-2.6.18-rc4-mm2/mm/vmstat.c	2006-08-25 18:11:54.858478358 -0700
@@ -394,7 +394,8 @@ static char *vmstat_text[] = {
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
-	"nr_slab",
+	"nr_slab_reclaimable",
+	"nr_slab_unreclaimable",
 	"nr_page_table_pages",
 	"nr_dirty",
 	"nr_writeback",
Index: linux-2.6.18-rc4-mm2/mm/swap_prefetch.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/swap_prefetch.c	2006-08-23 12:37:01.860468523 -0700
+++ linux-2.6.18-rc4-mm2/mm/swap_prefetch.c	2006-08-25 17:59:08.268099358 -0700
@@ -392,7 +392,8 @@ static int prefetch_suitable(void)
 		 * would be expensive to fix and not of great significance.
 		 */
 		limit = node_page_state(node, NR_FILE_PAGES);
-		limit += node_page_state(node, NR_SLAB);
+		limit += node_page_state(node, NR_SLAB_UNRECLAIMABLE);
+		limit += node_page_state(node, NR_SLAB_RECLAIMABLE);
 		limit += node_page_state(node, NR_FILE_DIRTY);
 		limit += node_page_state(node, NR_UNSTABLE_NFS);
 		limit += total_swapcache_pages;
Index: linux-2.6.18-rc4-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/vmscan.c	2006-08-25 17:59:06.493794799 -0700
+++ linux-2.6.18-rc4-mm2/mm/vmscan.c	2006-08-25 17:59:08.269075860 -0700
@@ -1386,7 +1386,7 @@ unsigned long shrink_all_memory(unsigned
 	for_each_zone(zone)
 		lru_pages += zone->nr_active + zone->nr_inactive;
 
-	nr_slab = global_page_state(NR_SLAB);
+	nr_slab = global_page_state(NR_SLAB_RECLAIMABLE);
 	/* If slab caches are huge, it's better to hit them first */
 	while (nr_slab >= lru_pages) {
 		reclaim_state.reclaimed_slab = 0;
Index: linux-2.6.18-rc4-mm2/drivers/base/node.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/drivers/base/node.c	2006-08-23 12:36:56.875425210 -0700
+++ linux-2.6.18-rc4-mm2/drivers/base/node.c	2006-08-25 17:59:08.270052362 -0700
@@ -68,7 +68,9 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d PageTables:   %8lu kB\n"
 		       "Node %d NFS Unstable: %8lu kB\n"
 		       "Node %d Bounce:       %8lu kB\n"
-		       "Node %d Slab:         %8lu kB\n",
+		       "Node %d Slab:         %8lu kB\n"
+		       "Node %d SReclaimable: %8lu kB\n"
+		       "Node %d SUnreclaim:   %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
@@ -88,7 +90,10 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
 		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
 		       nid, K(node_page_state(nid, NR_BOUNCE)),
-		       nid, K(node_page_state(nid, NR_SLAB)));
+		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE) +
+				node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
+		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE)),
+		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
 }
Index: linux-2.6.18-rc4-mm2/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/fs/proc/proc_misc.c	2006-08-23 12:36:59.772706994 -0700
+++ linux-2.6.18-rc4-mm2/fs/proc/proc_misc.c	2006-08-25 17:59:08.271028865 -0700
@@ -171,6 +171,8 @@ static int meminfo_read_proc(char *page,
 		"AnonPages:    %8lu kB\n"
 		"Mapped:       %8lu kB\n"
 		"Slab:         %8lu kB\n"
+		"SReclaimable: %8lu kB\n"
+		"SUnreclaim:   %8lu kB\n"
 		"PageTables:   %8lu kB\n"
 		"NFS Unstable: %8lu kB\n"
 		"Bounce:       %8lu kB\n"
@@ -198,7 +200,10 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_WRITEBACK)),
 		K(global_page_state(NR_ANON_PAGES)),
 		K(global_page_state(NR_FILE_MAPPED)),
-		K(global_page_state(NR_SLAB)),
+		K(global_page_state(NR_SLAB_RECLAIMABLE) +
+				global_page_state(NR_SLAB_UNRECLAIMABLE)),
+		K(global_page_state(NR_SLAB_RECLAIMABLE)),
+		K(global_page_state(NR_SLAB_UNRECLAIMABLE)),
 		K(global_page_state(NR_PAGETABLE)),
 		K(global_page_state(NR_UNSTABLE_NFS)),
 		K(global_page_state(NR_BOUNCE)),
Index: linux-2.6.18-rc4-mm2/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/arch/i386/mm/pgtable.c	2006-08-23 12:36:55.853027492 -0700
+++ linux-2.6.18-rc4-mm2/arch/i386/mm/pgtable.c	2006-08-25 17:59:08.272005367 -0700
@@ -61,7 +61,9 @@ void show_mem(void)
 	printk(KERN_INFO "%lu pages writeback\n",
 					global_page_state(NR_WRITEBACK));
 	printk(KERN_INFO "%lu pages mapped\n", global_page_state(NR_FILE_MAPPED));
-	printk(KERN_INFO "%lu pages slab\n", global_page_state(NR_SLAB));
+	printk(KERN_INFO "%lu pages slab\n",
+		global_page_state(NR_SLAB_RECLAIMABLE) +
+		global_page_state(NR_SLAB_UNRECLAIMABLE));
 	printk(KERN_INFO "%lu pages pagetables\n",
 					global_page_state(NR_PAGETABLE));
 }
Index: linux-2.6.18-rc4-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/page_alloc.c	2006-08-25 17:59:06.496724306 -0700
+++ linux-2.6.18-rc4-mm2/mm/page_alloc.c	2006-08-25 17:59:08.273958371 -0700
@@ -1402,7 +1402,8 @@ void show_free_areas(void)
 		global_page_state(NR_WRITEBACK),
 		global_page_state(NR_UNSTABLE_NFS),
 		nr_free_pages(),
-		global_page_state(NR_SLAB),
+		global_page_state(NR_SLAB_RECLAIMABLE) +
+			global_page_state(NR_SLAB_UNRECLAIMABLE),
 		global_page_state(NR_FILE_MAPPED),
 		global_page_state(NR_PAGETABLE));
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
