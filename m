Date: Thu, 25 Jan 2007 21:42:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070126054214.10564.14145.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
References: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 4/8] Drop free_pages()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Nikita Danilov <nikita@clusterfs.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Further simplification for nr_free_pages.

nr_free_pages is now a simple access to a global variable. Make it a macro
instead of a function.

The nr_free_pages now requires vmstat.h to be included. There is one
occurrence in power management where we need to add the include. Directly
refrer to global_page_state() there to clarify why the #include was added.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc6/include/linux/swap.h
===================================================================
--- linux-2.6.20-rc6.orig/include/linux/swap.h	2007-01-25 11:18:12.000000000 -0800
+++ linux-2.6.20-rc6/include/linux/swap.h	2007-01-25 20:19:24.000000000 -0800
@@ -170,11 +170,14 @@ extern void swapin_readahead(swp_entry_t
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
 extern long nr_swap_pages;
-extern unsigned int nr_free_pages(void);
 extern unsigned int nr_free_pages_pgdat(pg_data_t *pgdat);
 extern unsigned int nr_free_buffer_pages(void);
 extern unsigned int nr_free_pagecache_pages(void);
 
+/* Definition of global_page_state not available yet */
+#define nr_free_pages() global_page_state(NR_FREE_PAGES)
+
+
 /* linux/mm/swap.c */
 extern void FASTCALL(lru_cache_add(struct page *));
 extern void FASTCALL(lru_cache_add_active(struct page *));
Index: linux-2.6.20-rc6/mm/page_alloc.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/page_alloc.c	2007-01-25 11:19:46.000000000 -0800
+++ linux-2.6.20-rc6/mm/page_alloc.c	2007-01-25 20:19:24.000000000 -0800
@@ -1441,16 +1441,6 @@ fastcall void free_pages(unsigned long a
 
 EXPORT_SYMBOL(free_pages);
 
-/*
- * Total amount of free (allocatable) RAM:
- */
-unsigned int nr_free_pages(void)
-{
-	return global_page_state(NR_FREE_PAGES);
-}
-
-EXPORT_SYMBOL(nr_free_pages);
-
 #ifdef CONFIG_NUMA
 unsigned int nr_free_pages_pgdat(pg_data_t *pgdat)
 {
Index: linux-2.6.20-rc6/kernel/power/main.c
===================================================================
--- linux-2.6.20-rc6.orig/kernel/power/main.c	2007-01-25 20:19:17.000000000 -0800
+++ linux-2.6.20-rc6/kernel/power/main.c	2007-01-25 20:19:30.000000000 -0800
@@ -20,6 +20,7 @@
 #include <linux/cpu.h>
 #include <linux/resume-trace.h>
 #include <linux/freezer.h>
+#include <linux/vmstat.h>
 
 #include "power.h"
 
@@ -72,7 +73,8 @@ static int suspend_prepare(suspend_state
 		goto Thaw;
 	}
 
-	if ((free_pages = nr_free_pages()) < FREE_PAGE_NUMBER) {
+	if ((free_pages = global_page_state(NR_FREE_PAGES))
+			< FREE_PAGE_NUMBER) {
 		pr_debug("PM: free some memory\n");
 		shrink_all_memory(FREE_PAGE_NUMBER - free_pages);
 		if (nr_free_pages() < FREE_PAGE_NUMBER) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
