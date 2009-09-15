Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C2D5F6B005C
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:39:06 -0400 (EDT)
Date: Tue, 15 Sep 2009 21:38:21 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 4/4] mm: move highest_memmap_pfn
In-Reply-To: <Pine.LNX.4.64.0909152127240.22199@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909152137240.22199@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
 <Pine.LNX.4.64.0909152127240.22199@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Move highest_memmap_pfn __read_mostly from page_alloc.c next to
zero_pfn __read_mostly in memory.c: to help them share a cacheline,
since they're very often tested together in vm_normal_page().

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/internal.h   |    3 ++-
 mm/memory.c     |    1 +
 mm/page_alloc.c |    1 -
 3 files changed, 3 insertions(+), 2 deletions(-)

--- mm3/mm/internal.h	2009-09-14 16:34:37.000000000 +0100
+++ mm4/mm/internal.h	2009-09-15 17:32:27.000000000 +0100
@@ -37,6 +37,8 @@ static inline void __put_page(struct pag
 	atomic_dec(&page->_count);
 }
 
+extern unsigned long highest_memmap_pfn;
+
 /*
  * in mm/vmscan.c:
  */
@@ -46,7 +48,6 @@ extern void putback_lru_page(struct page
 /*
  * in mm/page_alloc.c
  */
-extern unsigned long highest_memmap_pfn;
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
 
--- mm3/mm/memory.c	2009-09-15 17:32:19.000000000 +0100
+++ mm4/mm/memory.c	2009-09-15 17:32:27.000000000 +0100
@@ -108,6 +108,7 @@ static int __init disable_randmaps(char
 __setup("norandmaps", disable_randmaps);
 
 unsigned long zero_pfn __read_mostly;
+unsigned long highest_memmap_pfn __read_mostly;
 
 /*
  * CONFIG_MMU architectures set up ZERO_PAGE in their paging_init()
--- mm3/mm/page_alloc.c	2009-09-14 16:34:37.000000000 +0100
+++ mm4/mm/page_alloc.c	2009-09-15 17:32:27.000000000 +0100
@@ -72,7 +72,6 @@ EXPORT_SYMBOL(node_states);
 
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
-unsigned long highest_memmap_pfn __read_mostly;
 int percpu_pagelist_fraction;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
