Date: Mon, 10 Apr 2006 13:19:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page Migration: Make do_swap_page redo the fault
In-Reply-To: <Pine.LNX.4.64.0604101933400.26478@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0604101303350.24029@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0604032228150.24182@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604081312200.14441@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604081058290.16914@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604082022170.12196@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604081430280.17911@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604090357350.5312@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604101933400.26478@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Apr 2006, Hugh Dickins wrote:

> I have now checked through, and I'm relieved to conclude that neither
> of those other two PageSwapCache rechecks are necessary; and the rules
> are much as before.

Note that the removal of the check in do_swap_page does only work
since the remove_from_swap() changes the pte. Without that pte change 
do_swap_page could retrieve the old page via the swap map. It would wait 
until page migration finished its migration and then find that the page is 
not in the pagecache anymore. Note that Lee Schermerhorn's lazy page 
migration may rely on disabling remove_from_swap() for his migration 
scheme. Lee? Looks like we are putting new barriers in front of you?

> In the try_to_unuse case, it's quite possible that !PageSwapCache there,
> because of a racing delete_from_swap_cache; but that case is correctly
> handled in the code that follows.

Ah. I see a later check 

if ((*swap_map > 1) && PageDirty(page) && PageSwapCache(page)) {

> So I believe we can safely remove these other two
> "Page migration has occured" blocks - can't we?

Hmmm... The increased count is also an argument against having to check 
for the race in do_swap_page(). So maybe Lee's lazy migration patchset 
should also be fine without these checks and there is actually no need
to rely on the ptes not being the same.


Remove two unnecessary PageSwapCache checks. The page refcount is raised
and therefore page migration cannot occur in both functions.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2006-04-08 11:14:20.000000000 -0700
+++ linux-2.6/mm/shmem.c	2006-04-10 13:13:43.000000000 -0700
@@ -1079,14 +1079,6 @@ repeat:
 			page_cache_release(swappage);
 			goto repeat;
 		}
-		if (!PageSwapCache(swappage)) {
-			/* Page migration has occured */
-			shmem_swp_unmap(entry);
-			spin_unlock(&info->lock);
-			unlock_page(swappage);
-			page_cache_release(swappage);
-			goto repeat;
-		}
 		if (PageWriteback(swappage)) {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c	2006-04-02 21:55:26.000000000 -0700
+++ linux-2.6/mm/swapfile.c	2006-04-10 13:13:01.000000000 -0700
@@ -751,12 +751,6 @@ again:
 		wait_on_page_locked(page);
 		wait_on_page_writeback(page);
 		lock_page(page);
-		if (!PageSwapCache(page)) {
-			/* Page migration has occured */
-			unlock_page(page);
-			page_cache_release(page);
-			goto again;
-		}
 		wait_on_page_writeback(page);
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
