Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 617D160023A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 07:51:54 -0400 (EDT)
Date: Wed, 17 Mar 2010 11:51:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
Message-ID: <20100317115133.GG12388@csn.ul.ie>
References: <1268657329.1889.4.camel@barrios-desktop> <20100315142124.GL18274@csn.ul.ie> <20100317104734.4C8E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100317104734.4C8E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 17, 2010 at 11:03:05AM +0900, KOSAKI Motohiro wrote:
> > mm,migration: Do not try to migrate unmapped anonymous pages
> > 
> > rmap_walk_anon() was triggering errors in memory compaction that look like
> > use-after-free errors. The problem is that between the page being isolated
> > from the LRU and rcu_read_lock() being taken, the mapcount of the page
> > dropped to 0 and the anon_vma gets freed. This can happen during memory
> > compaction if pages being migrated belong to a process that exits before
> > migration completes. Hence, the use-after-free race looks like
> > 
> >  1. Page isolated for migration
> >  2. Process exits
> >  3. page_mapcount(page) drops to zero so anon_vma was no longer reliable
> >  4. unmap_and_move() takes the rcu_lock but the anon_vma is already garbage
> >  4. call try_to_unmap, looks up tha anon_vma and "locks" it but the lock
> >     is garbage.
> > 
> > This patch checks the mapcount after the rcu lock is taken. If the
> > mapcount is zero, the anon_vma is assumed to be freed and no further
> > action is taken.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > ---
> >  mm/migrate.c |   13 +++++++++++++
> >  1 files changed, 13 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 98eaaf2..6eb1efe 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -603,6 +603,19 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> >  	 */
> >  	if (PageAnon(page)) {
> >  		rcu_read_lock();
> > +
> > +		/*
> > +		 * If the page has no mappings any more, just bail. An
> > +		 * unmapped anon page is likely to be freed soon but worse,
> > +		 * it's possible its anon_vma disappeared between when
> > +		 * the page was isolated and when we reached here while
> > +		 * the RCU lock was not held
> > +		 */
> > +		if (!page_mapcount(page)) {
> > +			rcu_read_unlock();
> > +			goto uncharge;
> > +		}
> 
> I haven't understand what prevent this check. Why don't we need following scenario?
> 
>  1. Page isolated for migration
>  2. Passed this if (!page_mapcount(page)) check
>  3. Process exits
>  4. page_mapcount(page) drops to zero so anon_vma was no longer reliable
> 
> 
> Traditionally, page migration logic is, it can touch garbarge of anon_vma, but
> SLAB_DESTROY_BY_RCU prevent any disaster. Is this broken concept?
> 

The check is made within the RCU read lock. If the count is positive at
that point but goes to zero due to a process exiting, the anon_vma will
still be valid until rcu_read_unlock() is called.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
