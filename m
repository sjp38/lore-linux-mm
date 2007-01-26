Date: Thu, 25 Jan 2007 21:42:34 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070126054234.10564.56909.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
References: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 8/8] Fix writeback calculation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Nikita Danilov <nikita@clusterfs.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

We can use the global ZVC counters to establish the exact size of the LRU
and the free pages. This allows a more accurate determination of the dirty
ratio.

This patch will fix the broken ratio calculations if large amounts of memory
are allocated to huge pags or other consumers that do not put the pages on
to the LRU.

However, we are unable to use the accurate base in the case of HIGHMEM and
an allocation excluding HIGHMEM pages. In that case just fall back to the
old scheme.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc6/mm/page-writeback.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/page-writeback.c	2007-01-25 10:53:56.000000000 -0800
+++ linux-2.6.20-rc6/mm/page-writeback.c	2007-01-25 11:03:47.000000000 -0800
@@ -128,7 +128,9 @@ get_dirty_limits(long *pbackground, long
 	int unmapped_ratio;
 	long background;
 	long dirty;
-	unsigned long available_memory = vm_total_pages;
+	unsigned long available_memory = global_page_state(NR_FREE_PAGES) +
+			global_page_state(NR_INACTIVE) +
+			global_page_state(NR_ACTIVE);
 	struct task_struct *tsk;
 
 #ifdef CONFIG_HIGHMEM
@@ -137,7 +139,12 @@ get_dirty_limits(long *pbackground, long
 	 * we exclude high memory from our count.
 	 */
 	if (mapping && !(mapping_gfp_mask(mapping) & __GFP_HIGHMEM))
-		available_memory -= totalhigh_pages;
+		/*
+		 * This is not as accurate as the non highmem calculation
+		 * but it has worked for years. So let it be as it was.
+		 * People know how to deal with it it seems.
+		 */
+		available_memory = vm_total_pages - totalhigh_pages;
 #endif
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
