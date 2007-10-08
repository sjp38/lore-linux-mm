Message-ID: <391803633.20978@ustc.edu.cn>
Date: Mon, 8 Oct 2007 08:33:49 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [PATCH] remove throttle_vm_writeout()
Message-ID: <20071008003349.GA5455@mail.ustc.edu.cn>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu> <1191501626.22357.14.camel@twins> <E1IdQJn-0002Cv-00@dorka.pomaz.szeredi.hu> <1191504186.22357.20.camel@twins> <E1IdR58-0002Fq-00@dorka.pomaz.szeredi.hu> <1191516427.5574.7.camel@lappy> <20071004104650.d158121f.akpm@linux-foundation.org> <20071005123028.GA10372@mail.ustc.edu.cn> <20071007235433.GW995458@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071007235433.GW995458@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Miklos Szeredi <miklos@szeredi.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 08, 2007 at 09:54:33AM +1000, David Chinner wrote:
> On Fri, Oct 05, 2007 at 08:30:28PM +0800, Fengguang Wu wrote:
> > The improvement could be:
> > - kswapd is now explicitly preferred to do the writeout;
> 
> Careful. kswapd is much less efficient at writeout than pdflush
> because it does not do low->high offset writeback per address space.
> It just flushes the pages in LRU order and that turns writeback into
> a non-sequential mess. I/O sizes decrease substantially and
> throughput falls through the floor.
> 
> So if you want kswapd to take over all the writeback, it needs to do
> writeback in the same manner as the background flushes. i.e.  by
> grabbing page->mapping and flushing that in sequential order rather
> than just the page on the end of the LRU....
> 
> I documented the effect of kswapd taking over writeback in this
> paper (section 5.3):
> 
> http://oss.sgi.com/projects/xfs/papers/ols2006/ols-2006-paper.pdf

Ah, indeed. That means introducing a new "really congested" threshold
for kswapd is *dangerous*. I realized this later on, and am now
heading for another direction.

The basic idea is to
- rotate pdflush issued writeback pages for kswapd;
- use the more precise zone_rotate_wait() to throttle kswapd.

The code is a quick hack and not tested yet.
Early comments are more than welcome.

Fengguang
---
 include/linux/mmzone.h |    1 +
 mm/filemap.c           |    5 ++++-
 mm/page_alloc.c        |    1 +
 mm/swap.c              |   13 +++++++++++++
 mm/vmscan.c            |   12 ++++++++++--
 5 files changed, 29 insertions(+), 3 deletions(-)

--- linux-2.6.23-rc8-mm2.orig/include/linux/mmzone.h
+++ linux-2.6.23-rc8-mm2/include/linux/mmzone.h
@@ -316,6 +316,7 @@ struct zone {
 	wait_queue_head_t	* wait_table;
 	unsigned long		wait_table_hash_nr_entries;
 	unsigned long		wait_table_bits;
+	wait_queue_head_t	wait_rotate;
 
 	/*
 	 * Discontig memory support fields.
--- linux-2.6.23-rc8-mm2.orig/mm/filemap.c
+++ linux-2.6.23-rc8-mm2/mm/filemap.c
@@ -558,12 +558,15 @@ EXPORT_SYMBOL(unlock_page);
  */
 void end_page_writeback(struct page *page)
 {
-	if (!TestClearPageReclaim(page) || rotate_reclaimable_page(page)) {
+	int r = 1;
+	if (!TestClearPageReclaim(page) || (r = rotate_reclaimable_page(page))) {
 		if (!test_clear_page_writeback(page))
 			BUG();
 	}
 	smp_mb__after_clear_bit();
 	wake_up_page(page, PG_writeback);
+	if (!r)
+		wake_up(&page_zone(page)->wait_rotate);
 }
 EXPORT_SYMBOL(end_page_writeback);
 
--- linux-2.6.23-rc8-mm2.orig/mm/page_alloc.c
+++ linux-2.6.23-rc8-mm2/mm/page_alloc.c
@@ -3482,6 +3482,7 @@ static void __meminit free_area_init_cor
 		zone->prev_priority = DEF_PRIORITY;
 
 		zone_pcp_init(zone);
+		init_waitqueue_head(&zone->wait_rotate);
 		INIT_LIST_HEAD(&zone->active_list);
 		INIT_LIST_HEAD(&zone->inactive_list);
 		zone->nr_scan_active = 0;
--- linux-2.6.23-rc8-mm2.orig/mm/vmscan.c
+++ linux-2.6.23-rc8-mm2/mm/vmscan.c
@@ -50,6 +50,7 @@
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
+	unsigned long nr_dirty_writeback;
 
 	/* This context's GFP mask */
 	gfp_t gfp_mask;
@@ -558,8 +559,10 @@ static unsigned long shrink_page_list(st
 			case PAGE_ACTIVATE:
 				goto activate_locked;
 			case PAGE_SUCCESS:
-				if (PageWriteback(page) || PageDirty(page))
+				if (PageWriteback(page) || PageDirty(page)) {
+					sc->nr_dirty_writeback++;
 					goto keep;
+				}
 				/*
 				 * A synchronous write - probably a ramdisk.  Go
 				 * ahead and try to reclaim the page.
@@ -620,6 +623,10 @@ keep_locked:
 keep:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page));
+		if (PageLocked(page) && PageWriteback(page)) {
+			SetPageReclaim(page);
+			sc->nr_dirty_writeback++;
+		}
 	}
 	list_splice(&ret_pages, page_list);
 	if (pagevec_count(&freed_pvec))
@@ -1184,7 +1191,8 @@ static unsigned long shrink_zone(int pri
 		}
 	}
 
-	throttle_vm_writeout(sc->gfp_mask);
+	if (!nr_reclaimed && sc->nr_dirty_writeback)
+		zone_rotate_wait(zone, HZ/100);
 	return nr_reclaimed;
 }
 
--- linux-2.6.23-rc8-mm2.orig/mm/swap.c
+++ linux-2.6.23-rc8-mm2/mm/swap.c
@@ -174,6 +174,19 @@ int rotate_reclaimable_page(struct page 
 	return 0;
 }
 
+long zone_rotate_wait(struct zone* z, long timeout)
+{
+	long ret;
+	DEFINE_WAIT(wait);
+	wait_queue_head_t *wqh = &z->wait_rotate;
+
+	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
+	ret = io_schedule_timeout(timeout);
+	finish_wait(wqh, &wait);
+	return ret;
+}
+EXPORT_SYMBOL(zone_rotate_wait);
+
 /*
  * FIXME: speed this up?
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
