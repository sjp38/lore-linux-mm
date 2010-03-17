Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E61E56B00A9
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 08:07:56 -0400 (EDT)
Date: Wed, 17 Mar 2010 12:07:35 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
Message-ID: <20100317120734.GH12388@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-3-git-send-email-mel@csn.ul.ie> <28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com> <20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com> <20100315112829.GI18274@csn.ul.ie> <1268657329.1889.4.camel@barrios-desktop> <20100315142124.GL18274@csn.ul.ie> <20100316084934.3798576c.kamezawa.hiroyu@jp.fujitsu.com> <20100317111234.d224f3fd.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100317111234.d224f3fd.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 17, 2010 at 11:12:34AM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 16 Mar 2010 08:49:34 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Mon, 15 Mar 2010 14:21:24 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > On Mon, Mar 15, 2010 at 09:48:49PM +0900, Minchan Kim wrote:
> > > > On Mon, 2010-03-15 at 11:28 +0000, Mel Gorman wrote:
> > > > > The use after free looks like
> > > > > 
> > > > > 1. page_mapcount(page) was zero so anon_vma was no longer reliable
> > > > > 2. rcu lock taken but the anon_vma at this point can already be garbage because the
> > > > >    process exited
> > > > > 3. call try_to_unmap, looks up tha anon_vma and locks it. This causes problems
> > > > > 
> > > > > I thought the race would be closed but there is still a very tiny window there all
> > > > > right. The following alternative should close it. What do you think?
> > > > > 
> > > > >         if (PageAnon(page)) {
> > > > > 		rcu_read_lock();
> > > > > 
> > > > >                 /*
> > > > >                  * If the page has no mappings any more, just bail. An
> > > > >                  * unmapped anon page is likely to be freed soon but worse,
> > > > >                  * it's possible its anon_vma disappeared between when
> > > > >                  * the page was isolated and when we reached here while
> > > > >                  * the RCU lock was not held
> > > > >                  */
> > > > >                 if (!page_mapcount(page)) {
> > > > > 			rcu_read_unlock();
> > > > >                         goto uncharge;
> > > > > 		}
> > > > > 
> > > > >                 rcu_locked = 1;
> > > > >                 anon_vma = page_anon_vma(page);
> > > > >                 atomic_inc(&anon_vma->external_refcount);
> > > > >         }
> > > > > 
> > > > > The rcu_unlock label is not used here because the reference counts were not taken in
> > > > > the case where page_mapcount == 0.
> > > > > 
> > > > 
> > > > Please, repost above code with your use-after-free scenario comment.
> > > > 
> > > 
> > > This will be the replacement patch so.
> > > 
> > > ==== CUT HERE ====
> > > mm,migration: Do not try to migrate unmapped anonymous pages
> > > 
> > > rmap_walk_anon() was triggering errors in memory compaction that look like
> > > use-after-free errors. The problem is that between the page being isolated
> > > from the LRU and rcu_read_lock() being taken, the mapcount of the page
> > > dropped to 0 and the anon_vma gets freed. This can happen during memory
> > > compaction if pages being migrated belong to a process that exits before
> > > migration completes. Hence, the use-after-free race looks like
> > > 
> > >  1. Page isolated for migration
> > >  2. Process exits
> > >  3. page_mapcount(page) drops to zero so anon_vma was no longer reliable
> > >  4. unmap_and_move() takes the rcu_lock but the anon_vma is already garbage
> > >  4. call try_to_unmap, looks up tha anon_vma and "locks" it but the lock
> > >     is garbage.
> > > 
> > > This patch checks the mapcount after the rcu lock is taken. If the
> > > mapcount is zero, the anon_vma is assumed to be freed and no further
> > > action is taken.
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > Acked-by: Rik van Riel <riel@redhat.com>
> > 
> > Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> 
> BTW, I doubt freeing anon_vma can happen even when we check mapcount.
> 

Bear in mind that without this patch, then compaction can trigger
bad-dereference-bugs fairly trivially. Each time it's related to taking
anon_vma->lock. It's not being caught by sl*b or page-alloc use-after-free 
debugging. It's somewhat detected by lockdep which recognises the lock
it's trying to track is screwy.

> "unmap" is 2-stage operation.
> 	1. unmap_vmas() => modify ptes, free pages, etc.
> 	2. free_pgtables() => free pgtables, unlink vma and free it.
> 
> Then, if migration is enough slow. 
> 
> 	Migration():				Exit():
> 	check mapcount
> 	rcu_read_lock
> 	pte_lock				
> 	replace pte with migration pte		
> 	pte_unlock
> 						pte_lock
> 	copy page etc...			zap pte (clear pte)
> 						pte_unlock
> 						free_pgtables
> 						->free vma
> 						->free anon_vma
> 	pte_lock
> 	remap pte with new pfn(fail)
> 	pte_unlock
> 
> 	lock anon_vma->lock		# modification after free.

But the anon_vma is still valid. Minimally, it shouldn't be destroyed
until after the rcu_read_unlock but it's also protected by the refcount
taken by migration.

Look at anon_vma_unlink(). It checks for the anon_vma being empty with

empty = list_empty(&anon_vma->head) && !anonvma_external_refcount(anon_vma);

So though the vmas have been unmapped, the anon_vma should still not
have been freed until migration is completed. We drop our reference, see
the list is empty, free the anon_vma and call rcu_read_unlock().

> 	check list is empty
> 	unlock anon_vma->lock
> 	free anon_vma
> 	rcu_read_unlock
> 
> Hmm. IIUC, anon_vma is allocated as SLAB_DESTROY_BY_RCU. Then, while
> rcu_read_lock() is taken, anon_vma is anon_vma even if freed. But it
> may reused as anon_vma for someone else.
> (IOW, it may be reused but never pushed back to general purpose memory
>  until RCU grace period.)

I don't think it can be reused because we took the external_refcount
preventing it being freed.

> Then, touching anon_vma->lock never cause any corruption.
> 

It would be bad if the anon_vma is reused. We'd decrement the wrong
counter potentially leaking the anon_vma structure.

> Does use-after-free check for SLAB_DESTROY_BY_RCU correct behavior ?
> Above case is not use-after-free. It's safe and expected sequence.
> 

I don't think it's RCU that guarantees the correct behaviour here, it's
the external_refcount.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
