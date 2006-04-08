Date: Sat, 8 Apr 2006 11:25:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page Migration: Make do_swap_page redo the fault
In-Reply-To: <Pine.LNX.4.64.0604081312200.14441@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0604081058290.16914@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0604032228150.24182@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604081312200.14441@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Apr 2006, Hugh Dickins wrote:

> > do_swap_page may interpret an invalid swap entry without this patch 
> > because we do not reload the pte if we are looping back. The page 
> > migration code may already have reused the swap entry referenced by our
> > local swp_entry.
> 
> Wouldn't you better just remove that !PageSwapCache "Page migration has
> occured" block?  Isn't that case already dealt with by the old !pte_same
> check below it?

Right. Since we now replace the swap ptes with ptes pointing to pages 
before unlocking the page this is no longer necessary (if the ptes 
contents are checked later). That of course means that remove_from_swap() 
must always succeed.

Hmmm..,. There are still two other checks for !PageSwapCache after 
obtaining a page lock in shmem_getpage() and in try_to_unuse(). 
However, both are getting to the page via the swap maps. So we need to 
keep those.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2006-04-02 21:55:26.000000000 -0700
+++ linux-2.6/mm/memory.c	2006-04-08 11:08:33.000000000 -0700
@@ -1903,12 +1903,6 @@ again:
 
 	mark_page_accessed(page);
 	lock_page(page);
-	if (!PageSwapCache(page)) {
-		/* Page migration has occured */
-		unlock_page(page);
-		page_cache_release(page);
-		goto again;
-	}
 
 	/*
 	 * Back out if somebody else already faulted in this pte.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
