Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by relay2.corp.sgi.com (Postfix) with ESMTP id AE76130406F
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:14 -0800 (PST)
Received: from clameter by schroedinger.engr.sgi.com with local (Exim 3.36 #1 (Debian))
	id 1JVJ1C-0004WP-00
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:14 -0800
Message-Id: <20080301040814.438625436@sgi.com>
References: <20080301040755.268426038@sgi.com>
Date: Fri, 29 Feb 2008 20:07:59 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 04/10] Pageflags: Eliminate PG_readahead
Content-Disposition: inline; filename=pageflags-elimiate_pg_readahead
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

PG_readahead is an alias of PG_reclaim. We can easily drop that now and
alias by specifying PG_reclaim in the macro that generates the functions
for PageReadahead().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/page-flags.h |    4 +---
 mm/page_alloc.c            |    2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2008-02-29 19:13:56.000000000 -0800
+++ linux-2.6/mm/page_alloc.c	2008-02-29 19:20:11.000000000 -0800
@@ -623,7 +623,7 @@ static int prep_new_page(struct page *pa
 	if (PageReserved(page))
 		return 1;
 
-	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_readahead |
+	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_reclaim |
 			1 << PG_referenced | 1 << PG_arch_1 |
 			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
 	set_page_private(page, 0);
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2008-02-29 19:20:03.000000000 -0800
+++ linux-2.6/include/linux/page-flags.h	2008-02-29 19:20:11.000000000 -0800
@@ -85,8 +85,6 @@ enum pageflags {
 	PG_swapcache,		/* Swap page: swp_entry_t in private */
 	PG_mappedtodisk,	/* Has blocks allocated on-disk */
 	PG_reclaim,		/* To be reclaimed asap */
-	/* PG_readahead is only used for file reads; PG_reclaim is only for writes */
-	PG_readahead = PG_reclaim, /* Reminder to do async read-ahead */
 	PG_buddy,		/* Page is free, on buddy lists */
 	NR_PAGEFLAGS,		/* For verification purposes */
 
@@ -168,7 +166,7 @@ PAGEFLAG(MappedToDisk, mappedtodisk)
 
 /* PG_readahead is only used for file reads; PG_reclaim is only for writes */
 PAGEFLAG(Reclaim, reclaim) TESTCLEARFLAG(Reclaim, reclaim)
-PAGEFLAG(Readahead, readahead)		/* Reminder to do async read-ahead */
+PAGEFLAG(Readahead, reclaim)		/* Reminder to do async read-ahead */
 
 #ifdef CONFIG_HIGHMEM
 #define PageHighMem(page)	is_highmem(page_zone(page))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
