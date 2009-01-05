Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D44D86B00A6
	for <linux-mm@kvack.org>; Mon,  5 Jan 2009 11:41:41 -0500 (EST)
Date: Mon, 5 Jan 2009 17:41:35 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: fix lockless pagecache reordering bug (was Re: BUG: soft lockup - is this XFS problem?)
Message-ID: <20090105164135.GC32675@wotan.suse.de>
References: <gifgp1$8ic$1@ger.gmane.org> <20081223171259.GA11945@infradead.org> <20081230042333.GC27679@wotan.suse.de> <20090103214443.GA6612@infradead.org> <20090105014821.GA367@wotan.suse.de> <20090105041959.GC367@wotan.suse.de> <20090105064838.GA5209@wotan.suse.de> <49623384.2070801@aon.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49623384.2070801@aon.at>
Sender: owner-linux-mm@kvack.org
To: Peter Klotz <peter.klotz@aon.at>, Linus Torvalds <torvalds@linux-foundation.org>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>
Cc: Christoph Hellwig <hch@infradead.org>, Roman Kononov <kernel@kononov.ftml.net>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

This patch should be applied to 2.6.29 and 27/28 stable kernels, please.
--

Peter Klotz and Roman Kononov both reported a bug where in XFS workloads where
they were seeing softlockups in find_get_pages
(http://oss.sgi.com/bugzilla/show_bug.cgi?id=805).

Basically it would go into an "infinite" loop, although it would sometimes be
able to break out of the loop depending on the phase of the moon.

This turns out to be a bug in the lockless pagecache patch. There is a missing
compiler barrier in the "increment reference count unless it was zero" failure
case of the lockless pagecache protocol in the gang lookup functions.

This would cause the compiler to use a cached value of struct page pointer to
retry the operation with, rather than reload it. So the page might have been
removed from pagecache and freed (refcount==0) but the lookup would not correctly
notice the page is no longer in pagecache, and keep attempting to increment the
refcount and failing, until the page gets reallocated for something else. This
isn't a data corruption because the condition will be properly handled if the
page does get reallocated. However it can result in a lockup. 

Add a the required compiler barrier and comment to fix this.

Assembly snippet from find_get_pages, before:
.L220:
        movq    (%rbx), %rax    #* ivtmp.1162, tmp82
        movq    (%rax), %rdi    #, prephitmp.1149
.L218:
        testb   $1, %dil        #, prephitmp.1149
        jne     .L217   #,
        testq   %rdi, %rdi      # prephitmp.1149
        je      .L203   #,
        cmpq    $-1, %rdi       #, prephitmp.1149
        je      .L217   #,
        movl    8(%rdi), %esi   # <variable>._count.counter, c
        testl   %esi, %esi      # c
        je      .L218   #,

after:
.L212:
        movq    (%rbx), %rax    #* ivtmp.1109, tmp81
        movq    (%rax), %rdi    #, ret
        testb   $1, %dil        #, ret
        jne     .L211   #,
        testq   %rdi, %rdi      # ret
        je      .L197   #,
        cmpq    $-1, %rdi       #, ret
        je      .L211   #,
        movl    8(%rdi), %esi   # <variable>._count.counter, c
        testl   %esi, %esi      # c
        je      .L212   #,

(notice the obvious infinite loop in the first example, if page->count remains 0)

The problem was noticed and resolved on 2.6.27 stable kernels, and also applies
upstream (where I was able to reproduce it and verify the fix).

Reported-by: Peter Klotz <peter.klotz@aon.at>
Reported-by: Roman Kononov <kononov@ftml.net>
Tested-by: Peter Klotz <peter.klotz@aon.at>
Tested-by: Roman Kononov <kononov@ftml.net>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2009-01-05 17:22:57.000000000 +1100
+++ linux-2.6/mm/filemap.c	2009-01-05 17:28:40.000000000 +1100
@@ -794,8 +794,19 @@ repeat:
 		if (unlikely(page == RADIX_TREE_RETRY))
 			goto restart;
 
-		if (!page_cache_get_speculative(page))
+		if (!page_cache_get_speculative(page)) {
+			/*
+			 * A failed page_cache_get_speculative operation does
+			 * not imply any barriers (Documentation/atomic_ops.txt),
+			 * and as such, we must force the compiler to deref the
+			 * radix-tree slot again rather than using the cached
+			 * value (because we need to give up if the page has been
+			 * removed from the radix-tree, rather than looping until
+			 * it gets reused for something else).
+			 */
+			barrier();
 			goto repeat;
+		}
 
 		/* Has the page moved? */
 		if (unlikely(page != *((void **)pages[i]))) {
@@ -850,8 +861,11 @@ repeat:
 		if (page->mapping == NULL || page->index != index)
 			break;
 
-		if (!page_cache_get_speculative(page))
+		if (!page_cache_get_speculative(page)) {
+			/* barrier: see find_get_pages() */
+			barrier();
 			goto repeat;
+		}
 
 		/* Has the page moved? */
 		if (unlikely(page != *((void **)pages[i]))) {
@@ -904,8 +918,11 @@ repeat:
 		if (unlikely(page == RADIX_TREE_RETRY))
 			goto restart;
 
-		if (!page_cache_get_speculative(page))
+		if (!page_cache_get_speculative(page)) {
+			/* barrier: see find_get_pages() */
+			barrier();
 			goto repeat;
+		}
 
 		/* Has the page moved? */
 		if (unlikely(page != *((void **)pages[i]))) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
