Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 058456B0005
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:46:10 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id bg4so56594pad.40
        for <linux-mm@kvack.org>; Tue, 26 Feb 2013 16:46:10 -0800 (PST)
Date: Tue, 26 Feb 2013 16:46:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, show_mem: suppress page counts in non-blockable
 contexts
Message-ID: <alpine.DEB.2.02.1302261642520.11109@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On large systems with a lot of memory, walking all RAM to determine page 
types may take a half second or even more.

In non-blockable contexts, the page allocator will emit a page allocation 
failure warning unless __GFP_NOWARN is specified.  In such contexts, irqs 
are typically disabled and such a lengthy delay may result in soft 
lockups.

To fix this, suppress the page walk in such contexts when printing the 
page allocation failure warning.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 arch/arm/mm/init.c       | 3 +++
 arch/ia64/mm/contig.c    | 2 ++
 arch/ia64/mm/discontig.c | 2 ++
 arch/parisc/mm/init.c    | 2 ++
 arch/unicore32/mm/init.c | 3 +++
 include/linux/mm.h       | 3 ++-
 lib/show_mem.c           | 3 +++
 mm/page_alloc.c          | 7 +++++++
 8 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -99,6 +99,9 @@ void show_mem(unsigned int filter)
 	printk("Mem-info:\n");
 	show_free_areas(filter);
 
+	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
+		return;
+
 	for_each_bank (i, mi) {
 		struct membank *bank = &mi->bank[i];
 		unsigned int pfn1, pfn2;
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -47,6 +47,8 @@ void show_mem(unsigned int filter)
 	printk(KERN_INFO "Mem-info:\n");
 	show_free_areas(filter);
 	printk(KERN_INFO "Node memory in pages:\n");
+	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
+		return;
 	for_each_online_pgdat(pgdat) {
 		unsigned long present;
 		unsigned long flags;
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -623,6 +623,8 @@ void show_mem(unsigned int filter)
 
 	printk(KERN_INFO "Mem-info:\n");
 	show_free_areas(filter);
+	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
+		return;
 	printk(KERN_INFO "Node memory in pages:\n");
 	for_each_online_pgdat(pgdat) {
 		unsigned long present;
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -697,6 +697,8 @@ void show_mem(unsigned int filter)
 
 	printk(KERN_INFO "Mem-info:\n");
 	show_free_areas(filter);
+	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
+		return;
 #ifndef CONFIG_DISCONTIGMEM
 	i = max_mapnr;
 	while (i-- > 0) {
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -66,6 +66,9 @@ void show_mem(unsigned int filter)
 	printk(KERN_DEFAULT "Mem-info:\n");
 	show_free_areas(filter);
 
+	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
+		return;
+
 	for_each_bank(i, mi) {
 		struct membank *bank = &mi->bank[i];
 		unsigned int pfn1, pfn2;
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -898,7 +898,8 @@ extern void pagefault_out_of_memory(void);
  * Flags passed to show_mem() and show_free_areas() to suppress output in
  * various contexts.
  */
-#define SHOW_MEM_FILTER_NODES	(0x0001u)	/* filter disallowed nodes */
+#define SHOW_MEM_FILTER_NODES		(0x0001u)	/* disallowed nodes */
+#define SHOW_MEM_FILTER_PAGE_COUNT	(0x0002u)	/* page type count */
 
 extern void show_free_areas(unsigned int flags);
 extern bool skip_free_areas_node(unsigned int flags, int nid);
diff --git a/lib/show_mem.c b/lib/show_mem.c
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -18,6 +18,9 @@ void show_mem(unsigned int filter)
 	printk("Mem-Info:\n");
 	show_free_areas(filter);
 
+	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
+		return;
+
 	for_each_online_pgdat(pgdat) {
 		unsigned long i, flags;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2009,6 +2009,13 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 		return;
 
 	/*
+	 * Walking all memory to count page types is very expensive and should
+	 * be inhibited in non-blockable contexts.
+	 */
+	if (!(gfp_mask & __GFP_WAIT))
+		filter |= SHOW_MEM_FILTER_PAGE_COUNT;
+
+	/*
 	 * This documents exceptions given to allocations in certain
 	 * contexts that are allowed to allocate outside current's set
 	 * of allowed nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
