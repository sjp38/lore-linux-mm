Date: Tue, 2 Dec 2008 13:34:53 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v2] vmscan: protect zone rotation stats by lru lock
Message-ID: <20081202123453.GB6170@cmpxchg.org>
References: <E1L6y5T-0003q3-M3@cmpxchg.org> <20081201134112.24c647ff.akpm@linux-foundation.org> <49345B3B.30703@redhat.com> <1228169385.18834.136.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1228169385.18834.136.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 05:09:45PM -0500, Lee Schermerhorn wrote:
> On Mon, 2008-12-01 at 16:46 -0500, Rik van Riel wrote:
> > Andrew Morton wrote:
> > > On Mon, 01 Dec 2008 03:00:35 +0100
> > > Johannes Weiner <hannes@saeurebad.de> wrote:
> > > 
> > >> The zone's rotation statistics must not be accessed without the
> > >> corresponding LRU lock held.  Fix an unprotected write in
> > >> shrink_active_list().
> > >>
> > > 
> > > I don't think it really matters.  It's quite common in that code to do
> > > unlocked, racy update to statistics such as this.  Because on those
> > > rare occasions where a race does happen, there's a small glitch in the
> > > reclaim logic which nobody will notice anyway.
> > > 
> > > Of course, this does need to be done with some care, to ensure the
> > > glitch _will_ be small.
> > 
> > Processing at most SWAP_CLUSTER_MAX pages at once probably
> > ensures that glitches will be small most of the time.
> > 
> > The only way this could be a big problem is if we end up
> > racing with the divide-by-two logic in get_scan_ratio,
> > leaving the rotated pages a factor two higher than they
> > should be.
> > 
> > Putting all the writes to the stats under the LRU lock
> > should ensure that never happens.
> 
> And he's not actually adding a lock.  Just moving the exiting one up to
> include the stats update.  The intervening pagevec, pgmoved and lru
> initializations don't need to be under the lock, but that's probably not
> a big deal?

I did it like this to keep the diff as simple as possible and to not
change existing code flow.

Here is an alternate version that moves the safe stuff out of the
locked region.

tbh, I think it's worse.

	Hannes

---

The zone's rotation statistics must not be modified without the
corresponding LRU lock held.  Fix an unprotected write in
shrink_active_list().

---
 mm/vmscan.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1249,21 +1249,21 @@ static void shrink_active_list(unsigned 
 	}
 
 	/*
+	 * Move the pages to the [file or anon] inactive list.
+	 */
+
+	pagevec_init(&pvec, 1);
+	lru = LRU_BASE + file * LRU_FILE;
+
+	spin_lock_irq(&zone->lru_lock);
+	/*
 	 * Count referenced pages from currently used mappings as
 	 * rotated, even though they are moved to the inactive list.
 	 * This helps balance scan pressure between file and anonymous
 	 * pages in get_scan_ratio.
 	 */
 	zone->recent_rotated[!!file] += pgmoved;
-
-	/*
-	 * Move the pages to the [file or anon] inactive list.
-	 */
-	pagevec_init(&pvec, 1);
-
 	pgmoved = 0;
-	lru = LRU_BASE + file * LRU_FILE;
-	spin_lock_irq(&zone->lru_lock);
 	while (!list_empty(&l_inactive)) {
 		page = lru_to_page(&l_inactive);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
