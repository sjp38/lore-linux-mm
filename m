Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3OCYJWk116540
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 12:34:19 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3OCZOGv100762
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:35:24 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3OCYJ39005330
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:34:19 +0200
Date: Mon, 24 Apr 2006 14:34:23 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 1/8] Page host virtual assist: unused / free pages.
Message-ID: <20060424123423.GB15817@skybase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

[patch 1/8] Page host virtual assist: unused / free pages.

A very simple but already quite effective improvement in the handling
of guest memory vs. host memory is to tell the host when pages are
free. That allows the host to avoid the paging of guest pages without
meaningful content. The host can "forget" the page content and provide
a fresh frame containing zeroes instead.

To communicate the two page states "unused" and "stable" to the host
two architecture defined primitives page_hva_set_unused() and
page_hva_set_stable() are introduced, which are used in the page
allocator.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/linux/mm.h       |    2 ++
 include/linux/page_hva.h |   28 ++++++++++++++++++++++++++++
 mm/page_alloc.c          |   14 +++++++++++---
 3 files changed, 41 insertions(+), 3 deletions(-)

diff -urpN linux-2.6/include/linux/mm.h linux-2.6-patched/include/linux/mm.h
--- linux-2.6/include/linux/mm.h	2006-04-24 12:51:20.000000000 +0200
+++ linux-2.6-patched/include/linux/mm.h	2006-04-24 12:51:24.000000000 +0200
@@ -298,6 +298,8 @@ struct page {
  * routine so they can be sure the page doesn't go away from under them.
  */
 
+#include <linux/page_hva.h>
+
 /*
  * Drop a ref, return true if the logical refcount fell to zero (the page has
  * no users)
diff -urpN linux-2.6/include/linux/page_hva.h linux-2.6-patched/include/linux/page_hva.h
--- linux-2.6/include/linux/page_hva.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6-patched/include/linux/page_hva.h	2006-04-24 12:51:24.000000000 +0200
@@ -0,0 +1,28 @@
+#ifndef _LINUX_PAGE_HVA_H
+#define _LINUX_PAGE_HVA_H
+
+/*
+ * include/linux/page_hva.h
+ *
+ * (C) Copyright IBM Corp. 2005, 2006
+ *
+ * Host virtual assist functions.
+ *
+ * Authors: Martin Schwidefsky <schwidefsky@de.ibm.com>
+ *          Hubertus Franke <frankeh@watson.ibm.com>
+ *          Himanshu Raj <rhim@cc.gatech.edu>
+ */
+#if defined(CONFIG_PAGE_HVA)
+
+#include <asm/page_hva.h>
+
+#else
+
+#define page_hva_enabled()			(0)
+
+#define page_hva_set_unused(_page)		do { } while (0)
+#define page_hva_set_stable(_page)		do { } while (0)
+
+#endif
+
+#endif /* _LINUX_PAGE_HVA_H */
diff -urpN linux-2.6/mm/page_alloc.c linux-2.6-patched/mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c	2006-04-24 12:51:20.000000000 +0200
+++ linux-2.6-patched/mm/page_alloc.c	2006-04-24 12:51:24.000000000 +0200
@@ -457,8 +457,13 @@ static void __free_pages_ok(struct page 
 		debug_check_no_locks_freed(page_address(page),
 					   PAGE_SIZE<<order);
 
-	for (i = 0 ; i < (1 << order) ; ++i)
-		reserved += free_pages_check(page + i);
+	for (i = 0 ; i < (1 << order) ; ++i) {
+		if (free_pages_check(page + i)) {
+			reserved++;
+			continue;
+		}
+		page_hva_set_unused(page+i);
+	}
 	if (reserved)
 		return;
 
@@ -753,6 +758,7 @@ static void fastcall free_hot_cold_page(
 		page->mapping = NULL;
 	if (free_pages_check(page))
 		return;
+	page_hva_set_unused(page);
 
 	kernel_map_pages(page, 1, 0);
 
@@ -808,7 +814,7 @@ static struct page *buffered_rmqueue(str
 	unsigned long flags;
 	struct page *page;
 	int cold = !!(gfp_flags & __GFP_COLD);
-	int cpu;
+	int cpu, i;
 
 again:
 	cpu  = get_cpu();
@@ -840,6 +846,8 @@ again:
 	put_cpu();
 
 	VM_BUG_ON(bad_range(zone, page));
+	for (i = 0 ; i < (1 << order) ; ++i)
+		page_hva_set_stable(page+i);
 	if (prep_new_page(page, order, gfp_flags))
 		goto again;
 	return page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
