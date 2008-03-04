From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 05/10] Pageflags: Eliminate PG_xxx aliases
Date: Mon, 03 Mar 2008 16:04:57 -0800
Message-ID: <20080304000733.255900083@sgi.com>
References: <20080304000452.514878384@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758137AbYCDAJs@vger.kernel.org>
Content-Disposition: inline; filename=pageflags-eliminate-aliases
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Remove aliases of PG_xxx. We can easily drop those now and alias by specifying
the PG_xxx flag in the macro that generates the functions.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/page-flags.h |   10 +++-------
 mm/page_alloc.c            |    2 +-
 2 files changed, 4 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2008-03-03 15:51:50.832236606 -0800
+++ linux-2.6/mm/page_alloc.c	2008-03-03 15:52:35.036720645 -0800
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
--- linux-2.6.orig/include/linux/page-flags.h	2008-03-03 15:52:34.212711617 -0800
+++ linux-2.6/include/linux/page-flags.h	2008-03-03 15:52:35.036720645 -0800
@@ -77,8 +77,6 @@ enum pageflags {
 	PG_active,
 	PG_slab,
 	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
-	PG_checked = PG_owner_priv_1, /* Used by some filesystems */
-	PG_pinned = PG_owner_priv_1, /* Xen pinned pagetable */
 	PG_arch_1,
 	PG_reserved,
 	PG_private,		/* If pagecache, has fs-private data */
@@ -87,8 +85,6 @@ enum pageflags {
 	PG_swapcache,		/* Swap page: swp_entry_t in private */
 	PG_mappedtodisk,	/* Has blocks allocated on-disk */
 	PG_reclaim,		/* To be reclaimed asap */
-	/* PG_readahead is only used for file reads; PG_reclaim is only for writes */
-	PG_readahead = PG_reclaim, /* Reminder to do async read-ahead */
 	PG_buddy,		/* Page is free, on buddy lists */
 
 #if (BITS_PER_LONG > 32)
@@ -154,8 +150,8 @@ PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty,
 PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
 PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
 __PAGEFLAG(Slab, slab)
-PAGEFLAG(Checked, checked)		/* Used by some filesystems */
-PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned) /* Xen pagetable */
+PAGEFLAG(Checked, owner_priv_1)		/* Used by some filesystems */
+PAGEFLAG(Pinned, owner_priv_1) TESTSCFLAG(Pinned, owner_priv_1) /* Xen */
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(Private, private) __CLEARPAGEFLAG(Private, private)
 	__SETPAGEFLAG(Private, private)
@@ -170,7 +166,7 @@ PAGEFLAG(MappedToDisk, mappedtodisk)
 
 /* PG_readahead is only used for file reads; PG_reclaim is only for writes */
 PAGEFLAG(Reclaim, reclaim) TESTCLEARFLAG(Reclaim, reclaim)
-PAGEFLAG(Readahead, readahead)		/* Reminder to do async read-ahead */
+PAGEFLAG(Readahead, reclaim)		/* Reminder to do async read-ahead */
 
 static inline int PageHighMem(struct page *page)
 {

-- 
