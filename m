From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 10/10] Pageflags: Land grab
Date: Mon, 03 Mar 2008 16:05:02 -0800
Message-ID: <20080304000734.383475547@sgi.com>
References: <20080304000452.514878384@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763654AbYCDALb@vger.kernel.org>
Content-Disposition: inline; filename=pageflags_land_grab
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Grab 5 page flags for some upcoming VM projects and convert the Compound
page flag handling to use 2 bits (necessary so that page cache flag use
does no longer overlap with compound flags).


This makes us use 24 page flags (plus one additional flag for 64bit)

On a 64 bit system 32 bits are used for page flags. Of those we use
25 flags. So 7 flags are still available.

The rest applies only to 32 bit systems:

In non NUMA configurations we need 2 bits for the zoneid. Meaning
30 bits are left. Of those 24 are used for page flags. So 6 flags
are still available.

In NUMA configuration these 6 bits could be used for node numbers
which would result in the ability to support 64 nodes.
However, the highest number of suported nodes on 32 bit is NUMAQ with
16 nodes. This means we need to use only 4 bits. So 2 page flags
are still available.


32bit Sparsemem without vmemmap:

The page flags situation becomes very tight. The remaining 6 bits must then
be used as section ids. Via a lookup table we can determine the node ids from
the section id. So it would work.

However, we would have no page flags left. Any additional page flag will
reduce the number of available sparsemem sections to half.

It may be good if we could phase out sparsemem w/o vmemmap for 32 bit
systems. It is likely that most of memory is backed by contiguous RAM given
currently available memory sizes.

Without the 32bit sparsemem issues we would still have 2 page flags available.
Which would be the same situation as before this patchset and the page flag
land grab.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/page-flags.h |   41 ++++++++++++++---------------------------
 1 file changed, 14 insertions(+), 27 deletions(-)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2008-03-03 15:29:48.734135117 -0800
+++ linux-2.6/include/linux/page-flags.h	2008-03-03 15:32:05.200548999 -0800
@@ -81,11 +81,16 @@ enum pageflags {
 	PG_reserved,
 	PG_private,		/* If pagecache, has fs-private data */
 	PG_writeback,		/* Page is under writeback */
-	PG_compound,		/* A compound page */
 	PG_swapcache,		/* Swap page: swp_entry_t in private */
 	PG_mappedtodisk,	/* Has blocks allocated on-disk */
 	PG_reclaim,		/* To be reclaimed asap */
 	PG_buddy,		/* Page is free, on buddy lists */
+	PG_mlock,		/* Page cannot be swapped out */
+	PG_pin,			/* Page cannot be moved in memory */
+	PG_tail,		/* Tail of a compound page */
+	PG_head,		/* Head of a compound page */
+	PG_vcompound,		/* Compound page is virtually mapped */
+	PG_filebacked,		/* Page is backed by an actual disk (not RAM) */
 
 #if (BITS_PER_LONG > 32)
 /*
@@ -248,34 +253,16 @@ static inline void set_page_writeback(st
 	test_set_page_writeback(page);
 }
 
-TESTPAGEFLAG(Compound, compound)
-__PAGEFLAG(Head, compound)
+__PAGEFLAG(Head, head)
+__PAGEFLAG(Tail, tail)
+__PAGEFLAG(Vcompound, vcompound)
+__PAGEFLAG(Mlock, mlock)
+__PAGEFLAG(Pin, pin)
+__PAGEFLAG(FileBacked, filebacked)
 
-/*
- * PG_reclaim is used in combination with PG_compound to mark the
- * head and tail of a compound page. This saves one page flag
- * but makes it impossible to use compound pages for the page cache.
- * The PG_reclaim bit would have to be used for reclaim or readahead
- * if compound pages enter the page cache.
- *
- * PG_compound & PG_reclaim	=> Tail page
- * PG_compound & ~PG_reclaim	=> Head page
- */
-#define PG_head_tail_mask ((1L << PG_compound) | (1L << PG_reclaim))
-
-static inline int PageTail(struct page *page)
-{
-	return ((page->flags & PG_head_tail_mask) == PG_head_tail_mask);
-}
-
-static inline void __SetPageTail(struct page *page)
-{
-	page->flags |= PG_head_tail_mask;
-}
-
-static inline void __ClearPageTail(struct page *page)
+static inline int PageCompound(struct page *page)
 {
-	page->flags &= ~PG_head_tail_mask;
+	return (page->flags & ((1 << PG_tail) | (1 << PG_head))) != 0;
 }
 
 #endif	/* PAGE_FLAGS_H */

-- 
