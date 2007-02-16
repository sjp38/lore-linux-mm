Date: Thu, 15 Feb 2007 21:02:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
In-Reply-To: <Pine.LNX.4.64.0702151852140.1511@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0702152056470.2290@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
 <20070215171355.67c7e8b4.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151852140.1511@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007, Christoph Lameter wrote:

> On Thu, 15 Feb 2007, Andrew Morton wrote:
> 
> > It's nice and simple, but I think I'd prefer to wait for the existing mlock
> > changes to crash a bit less before we do this.
> 
> Sigh. My optimizations must have done me in. Drop the last two patches and 
> it will be fine. I am not sure what is going on there but things work 
> right without the optimizations.
> 
> avoid-putting-new-mlocked-anonymous-pages-on-lru.patch
> opportunistically-move-mlocked-pages-off-the-lru.patch
> 

Would you put those two patches back?


The problem is that in some circumstances a page may be freed that is 
mlocked (if one is marking a page as mlocked early). The page allocator 
will not touch the PG_mlocked bit and thus a newly allocated page may have 
PG_mlocked set. If we then try to put it on the lru then the VM_BUG_ONs 
are triggered.

The following patch detects these conditions in the page allocator and 
does the proper checks and cleanup.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/include/linux/page-flags.h
===================================================================
--- linux-2.6.20.orig/include/linux/page-flags.h	2007-02-15 20:42:42.000000000 -0800
+++ linux-2.6.20/include/linux/page-flags.h	2007-02-15 20:43:33.000000000 -0800
@@ -261,6 +261,7 @@ static inline void SetPageUptodate(struc
 #define PageMlocked(page)	test_bit(PG_mlocked, &(page)->flags)
 #define SetPageMlocked(page)	set_bit(PG_mlocked, &(page)->flags)
 #define ClearPageMlocked(page)	clear_bit(PG_mlocked, &(page)->flags)
+#define __ClearPageMlocked(page) __clear_bit(PG_mlocked, &(page)->flags)
 
 struct page;	/* forward declaration */
 
Index: linux-2.6.20/mm/page_alloc.c
===================================================================
--- linux-2.6.20.orig/mm/page_alloc.c	2007-02-15 20:42:42.000000000 -0800
+++ linux-2.6.20/mm/page_alloc.c	2007-02-15 20:55:23.000000000 -0800
@@ -203,6 +203,7 @@ static void bad_page(struct page *page)
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
+			1 << PG_mlocked |
 			1 << PG_buddy );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
@@ -442,6 +443,11 @@ static inline int free_pages_check(struc
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
+	if (PageMlocked(page)) {
+		/* Page is unused so no need to take the lru lock */
+		__ClearPageMlocked(page);
+		dec_zone_page_state(page, NR_MLOCK);
+	}
 	/*
 	 * For now, we report if PG_reserved was found set, but do not
 	 * clear it, and do not free the page.  But we shall soon need
@@ -588,6 +594,7 @@ static int prep_new_page(struct page *pa
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
+			1 << PG_mlocked |
 			1 << PG_buddy ))))
 		bad_page(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
