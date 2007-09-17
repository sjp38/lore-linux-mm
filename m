Subject: Re: [PATCH/RFC 3/14] Reclaim Scalability:  move isolate_lru_page()
	to vmscan.c
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1189805699.5826.19.camel@lappy>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205418.6536.5921.sendpatchset@localhost>
	 <1189805699.5826.19.camel@lappy>
Content-Type: text/plain
Date: Mon, 17 Sep 2007 10:11:27 -0400
Message-Id: <1190038287.5460.30.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 23:34 +0200, Peter Zijlstra wrote:
> On Fri, 2007-09-14 at 16:54 -0400, Lee Schermerhorn wrote:
> 
> > 	Note that we now have '__isolate_lru_page()', that does
> > 	something quite different, visible outside of vmscan.c
> > 	for use with memory controller.  Methinks we need to
> > 	rationalize these names/purposes.	--lts
> > 
> 
> Actually it comes from lumpy reclaim, and does something very similar to
> what this one does. 

Sorry.  My statement was a bit ambiguous.  I meant that the visibility
of __isolate_lru_pages() outside of vmscan.c comes about from the mem
controller patches.  Lumpy reclaim did add the "isolation mode" [active,
inactive, both].

> When one looks at the mainline version one could
> write:
> 
> int isolate_lru_page(struct page *page, struct list_head *pagelist)
> {
> 	int ret = -EBUSY;
> 
> 	if (PageLRU(page)) {
> 		struct zone *zone = page_zone(page);
> 
> 		spin_lock_irq(&zone->lru_lock);
> 		ret = __isolate_lru_page(page, ISOLATE_BOTH);
> 		if (!ret) {
> 			__dec_zone_state(zone, PageActive(page) 
> 				? NR_ACTIVE : NR_INACTIVE);
> 			list_move_tail(&page->lru, pagelist);
> 		}
> 		spin_unlock_irq(&zone->lru_lock);
> 	}
> 
> 	return ret;
> }
> 

In it's initial form, yes.  Later [in the first noreclaim patch] you'll
see that I hacked both isolate_lru_page and __isolate_lru_page() to
handle non-reclaimable pages.  The former to add recognize
non-reclaimable pages and isolate them from the noreclaim list; the
latter to allow isolation of non-reclaimable pages only when scanning
the active list, but not during lumpy reclaim.  

I had to allow __isolate_lru_page() to accept non-reclaimable pages from
the active list in order to splice the noreclaim list back there when we
want to scan it--as you mentioned to me was discussed at the vm summit.
I'm not very happy with the result, and think we need to revisit how we
scan the noreclaim list for various conditions.  I plan to fork off a
separate discussion on this point, real soon now.

> Obviously the container stuff somewhat complicates mattters in -mm.
> 
> >  /*
> > - * Isolate one page from the LRU lists. If successful put it onto
> > - * the indicated list with elevated page count.
> > - *
> > - * Result:
> > - *  -EBUSY: page not on LRU list
> > - *  0: page removed from LRU list and added to the specified list.
> > - */
> > -int isolate_lru_page(struct page *page, struct list_head *pagelist)
> > -{
> > -	int ret = -EBUSY;
> > -
> > -	if (PageLRU(page)) {
> > -		struct zone *zone = page_zone(page);
> > -
> > -		spin_lock_irq(&zone->lru_lock);
> > -		if (PageLRU(page) && get_page_unless_zero(page)) {
> > -			ret = 0;
> > -			ClearPageLRU(page);
> > -			if (PageActive(page))
> > -				del_page_from_active_list(zone, page);
> > -			else
> > -				del_page_from_inactive_list(zone, page);
> > -			list_add_tail(&page->lru, pagelist);
> > -		}
> > -		spin_unlock_irq(&zone->lru_lock);
> > -	}
> > -	return ret;
> > -}
> 
> remarcable change is the dissapearance of get_page_unless_zero() in the
> new version.

Good catch!  What happened here is this"

The original version of isolate_lru_page() that Nick's patch moved had a
get_page() in the "if (PageLRU(page)" block--no get_page_unless_zero().
This was fine for Christoph's migration usage, because it was always
called in task context, holding the mm semaphore.  Mel and Kame-san want
to use migration for defragmentation and hotplug from outside task
context, so one or the other of them [not sure] removed the get_page()
and added the get_page_unless_zero() into the if condition--around
mid-June.  Apparently, during resolution of a forced patch conflict, I
managed to drop the get_page(), but not pick up the
get_page_unless_zero().  So much for following "established protocol for
handling pages on the LRU lists", huh?

<snip new, botched version>

Below is a patch to add back the get_page_unless_zero().  I'll roll this
into the move_and_rework... patch for the next posting, but in the
meantime, if anyone wants to try these, here's a quick fix.

I just tested with this and my tests ran much better.  I still managed
to push my system into OOM during mbind() migration, but I am repeatedly
locking and unlocking 16G, sometimes in 8G chunks, of an 18G anon
segment to force swapping and such.  Another test is creating 256MB anon
and private file-backed segments, binding them down and migrating them
around the platform.  Eventually, this second test dies with OOM because
of CONSTRAINT_MEMORY_POLICY--insufficient memory on the target node.

The noreclaim statistics seemed to be behaving better as well, but once
the memtoy/mlock test went OOM with locked pages, quite a few pages
remained non-reclaimable after I killed off the other tests.  Still a
lot of work to do on reviving non-reclaimable pages.

Thanks,
Lee

======================

PATCH	move and rework isolate_lru_page fix

I accidently dropped the recently added "get_page_unless_zero(page)" 
from isolate_lru_page() during resolution of a forced patch
conflict.  

Put it back!!!

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-09-17 09:06:01.000000000 -0400
+++ Linux/mm/vmscan.c	2007-09-17 09:07:37.000000000 -0400
@@ -838,7 +838,7 @@ int isolate_lru_page(struct page *page)
 		struct zone *zone = page_zone(page);
 
 		spin_lock_irq(&zone->lru_lock);
-		if (PageLRU(page)) {
+		if (PageLRU(page) && get_page_unless_zero(page)) {
 			ret = 0;
 			ClearPageLRU(page);
 			if (PageActive(page))



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
