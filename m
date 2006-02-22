Date: Wed, 22 Feb 2006 15:33:57 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: pcp stats
Message-ID: <20060222143357.GJ15546@wotan.suse.de>
References: <20060222143217.GI15546@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060222143217.GI15546@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Following patch offers some stats about pageset activity.

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -720,6 +720,7 @@ static void fastcall free_hot_cold_page(
 	pset = zone_pcp(zone, get_cpu());
 	local_irq_save(flags);
 	__inc_page_state(pgfree);
+	__inc_page_state(pcpfree);
 	pset->count++;
 	if (cold) {
 		pset->cold_count++;
@@ -733,6 +734,7 @@ static void fastcall free_hot_cold_page(
 		free_pages_bulk(zone, count, &pset->list, 0);
 		pset->cold_count -= min(count, pset->cold_count);
 		pset->count -= count;
+		__mod_page_state(pcpspill, count);
 	}
 	local_irq_restore(flags);
 	put_cpu();
@@ -794,8 +796,10 @@ again:
 				goto failed;
 			pset->count += count;
 			pset->cold_count += count;
+			__mod_page_state(pcpfill, count);
 		}
 
+		__inc_page_state(pcpalloc);
 		pset->count--;
 		if (cold) {
 			page = list_entry(pset->list.prev, struct page, lru);
@@ -2319,6 +2323,10 @@ static char *vmstat_text[] = {
 	"pgalloc_dma",
 
 	"pgfree",
+	"pcpalloc",
+	"pcpfree",
+	"pcpfill",
+	"pcpspill",
 	"pgactivate",
 	"pgdeactivate",
 
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -117,6 +117,10 @@ struct page_state {
 	unsigned long pgalloc_dma;
 
 	unsigned long pgfree;		/* page freeings */
+	unsigned long pcpalloc;		/* pages allocated from pcp lists */
+	unsigned long pcpfree;		/* pages freed into pcp lists */
+	unsigned long pcpfill;		/* pages allocated into pcp lists */
+	unsigned long pcpspill;		/* pages freed from pcp lists */
 	unsigned long pgactivate;	/* pages moved inactive->active */
 	unsigned long pgdeactivate;	/* pages moved active->inactive */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
