Date: Thu, 27 Feb 2003 00:21:04 -0500
From: Christoph Hellwig <hch@sgi.com>
Subject: [PATCH] allow CONFIG_SWAP=n for i386
Message-ID: <20030227002104.D15352@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There's a bunch of minor fixes needed to disable the swap
code for systems with mmu.


--- 1.44/arch/i386/Kconfig	Tue Feb 25 08:13:14 2003
+++ edited/arch/i386/Kconfig	Wed Feb 26 15:03:01 2003
@@ -19,8 +19,13 @@
 	default y
 
 config SWAP
-	bool
+	bool "Support for paging of anonymous memory"
 	default y
+	help
+	  This option allows you to choose whether you want to have support
+	  for socalled swap devices or swap files in your kernel that are
+	  used to provide more virtual memory than the actual RAM present
+	  in your computer.  If unusre say Y.
 
 config SBUS
 	bool
===== arch/i386/mm/pgtable.c 1.7 vs edited =====
--- 1.7/arch/i386/mm/pgtable.c	Tue Feb  4 08:46:49 2003
+++ edited/arch/i386/mm/pgtable.c	Wed Feb 26 15:03:01 2003
@@ -11,6 +11,7 @@
 #include <linux/smp.h>
 #include <linux/highmem.h>
 #include <linux/slab.h>
+#include <linux/pagemap.h>
 
 #include <asm/system.h>
 #include <asm/pgtable.h>
--- 1.71/include/linux/swap.h	Tue Feb 18 11:29:01 2003
+++ edited/include/linux/swap.h	Wed Feb 26 15:03:01 2003
@@ -68,10 +68,11 @@
 
 #ifdef __KERNEL__
 
-struct sysinfo;
 struct address_space;
-struct zone;
+struct pte_chain;
+struct sysinfo;
 struct writeback_control;
+struct zone;
 
 /*
  * A swap extent maps a range of a swapfile's PAGE_SIZE pages onto a range of
@@ -140,6 +141,9 @@
 /* Swap 50% full? Release swapcache more aggressively.. */
 #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
 
+/* linux/mm/oom_kill.c */
+extern void out_of_memory(void);
+
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalhigh_pages;
@@ -149,13 +153,11 @@
 extern unsigned int nr_free_buffer_pages(void);
 extern unsigned int nr_free_pagecache_pages(void);
 
-/* linux/mm/filemap.c */
-extern void FASTCALL(mark_page_accessed(struct page *));
-
 /* linux/mm/swap.c */
 extern void FASTCALL(lru_cache_add(struct page *));
 extern void FASTCALL(lru_cache_add_active(struct page *));
 extern void FASTCALL(activate_page(struct page *));
+extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
 extern int rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
@@ -165,11 +167,8 @@
 extern int shrink_all_memory(int);
 extern int vm_swappiness;
 
-/* linux/mm/oom_kill.c */
-extern void out_of_memory(void);
-
 /* linux/mm/rmap.c */
-struct pte_chain;
+#ifdef CONFIG_MMU
 int FASTCALL(page_referenced(struct page *));
 struct pte_chain *FASTCALL(page_add_rmap(struct page *, pte_t *,
 					struct pte_chain *));
@@ -186,6 +185,11 @@
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 
+#else
+#define page_referenced(page) \
+	TestClearPageReferenced(page)
+#endif /* CONFIG_MMU */
+
 #ifdef CONFIG_SWAP
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct file *, struct page *);
@@ -242,8 +246,6 @@
 	page_cache_release(page)
 #define free_pages_and_swap_cache(pages, nr) \
 	release_pages((pages), (nr), 0);
-#define page_referenced(page) \
-	TestClearPageReferenced(page)
 
 #define show_swap_cache_info()			/*NOTHING*/
 #define free_swap_and_cache(swp)		/*NOTHING*/
--- 1.47/mm/swap.c	Mon Feb 24 21:51:23 2003
+++ edited/mm/swap.c	Wed Feb 26 15:03:01 2003
@@ -363,5 +363,4 @@
 	 * Right now other parts of the system means that we
 	 * _really_ don't want to cluster much more
 	 */
-	init_MUTEX(&swapper_space.i_shared_sem);
 }
--- 1.56/mm/swap_state.c	Tue Feb 11 08:22:50 2003
+++ edited/mm/swap_state.c	Wed Feb 26 15:03:01 2003
@@ -33,19 +33,20 @@
 extern struct address_space_operations swap_aops;
 
 struct address_space swapper_space = {
-	.page_tree		= RADIX_TREE_INIT(GFP_ATOMIC),
-	.page_lock		= RW_LOCK_UNLOCKED,
-	.clean_pages		= LIST_HEAD_INIT(swapper_space.clean_pages),
-	.dirty_pages		= LIST_HEAD_INIT(swapper_space.dirty_pages),
-	.io_pages		= LIST_HEAD_INIT(swapper_space.io_pages),
-	.locked_pages		= LIST_HEAD_INIT(swapper_space.locked_pages),
-	.host			= &swapper_inode,
-	.a_ops			= &swap_aops,
-	.backing_dev_info	= &swap_backing_dev_info,
-	.i_mmap			= LIST_HEAD_INIT(swapper_space.i_mmap),
-	.i_mmap_shared		= LIST_HEAD_INIT(swapper_space.i_mmap_shared),
-	.private_lock		= SPIN_LOCK_UNLOCKED,
-	.private_list		= LIST_HEAD_INIT(swapper_space.private_list),
+	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC),
+	.page_lock	= RW_LOCK_UNLOCKED,
+	.clean_pages	= LIST_HEAD_INIT(swapper_space.clean_pages),
+	.dirty_pages	= LIST_HEAD_INIT(swapper_space.dirty_pages),
+	.io_pages	= LIST_HEAD_INIT(swapper_space.io_pages),
+	.locked_pages	= LIST_HEAD_INIT(swapper_space.locked_pages),
+	.host		= &swapper_inode,
+	.a_ops		= &swap_aops,
+	.backing_dev_info = &swap_backing_dev_info,
+	.i_mmap		= LIST_HEAD_INIT(swapper_space.i_mmap),
+	.i_mmap_shared	= LIST_HEAD_INIT(swapper_space.i_mmap_shared),
+	.i_shared_sem	= __MUTEX_INITIALIZER(&swapper_space.i_shared_sem),
+	.private_lock	= SPIN_LOCK_UNLOCKED,
+	.private_list	= LIST_HEAD_INIT(swapper_space.private_list),
 };
 
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
