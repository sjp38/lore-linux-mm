From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061007105807.14024.67270.sendpatchset@linux.site>
In-Reply-To: <20061007105758.14024.70048.sendpatchset@linux.site>
References: <20061007105758.14024.70048.sendpatchset@linux.site>
Subject: [patch 1/3] mm: arch_free_page fix
Date: Sat,  7 Oct 2006 15:05:46 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

After the PG_reserved check was added, arch_free_page was being called in the
wrong place (it could be called for a page we don't actually want to free).
Fix that.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-08-05 18:38:50.000000000 +1000
+++ linux-2.6/mm/page_alloc.c	2006-09-17 17:19:32.000000000 +1000
@@ -443,7 +443,6 @@ static void __free_pages_ok(struct page 
 	int i;
 	int reserved = 0;
 
-	arch_free_page(page, order);
 	if (!PageHighMem(page))
 		debug_check_no_locks_freed(page_address(page),
 					   PAGE_SIZE<<order);
@@ -453,7 +452,9 @@ static void __free_pages_ok(struct page 
 	if (reserved)
 		return;
 
+	arch_free_page(page, order);
 	kernel_map_pages(page, 1 << order, 0);
+
 	local_irq_save(flags);
 	__count_vm_events(PGFREE, 1 << order);
 	free_one_page(page_zone(page), page, order);
@@ -717,13 +718,12 @@ static void fastcall free_hot_cold_page(
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 
-	arch_free_page(page, 0);
-
 	if (PageAnon(page))
 		page->mapping = NULL;
 	if (free_pages_check(page))
 		return;
 
+	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
 	pcp = &zone_pcp(zone, get_cpu())->pcp[cold];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
