Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D193160021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 19:39:18 -0400 (EDT)
Date: Sat, 3 Oct 2009 01:38:37 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 3/3] mm: munlock COW pages on truncation unmap
Message-ID: <20091002233837.GA3638@cmpxchg.org>
References: <1254344964-8124-1-git-send-email-hannes@cmpxchg.org> <1254344964-8124-3-git-send-email-hannes@cmpxchg.org> <20091002100838.5F5A.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091002100838.5F5A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Hello KOSAKI-san,

On Fri, Oct 02, 2009 at 11:40:34AM +0900, KOSAKI Motohiro wrote:
> > @@ -835,6 +835,43 @@ static unsigned long zap_pte_range(struc
> >  				    (page->index < details->first_index ||
> >  				     page->index > details->last_index))
> >  					continue;
> > +				/*
> > +				 * When truncating, private COW pages may be
> > +				 * mlocked in VM_LOCKED VMAs, so they need
> > +				 * munlocking here before getting freed.
> > +				 *
> > +				 * Skip them completely if we don't have the
> > +				 * anon_vma locked.  We will get it the second
> > +				 * time.  When page cache is truncated, no more
> > +				 * private pages can show up against this VMA
> > +				 * and the anon_vma is either present or will
> > +				 * never be.
> > +				 *
> > +				 * Otherwise, we still have to synchronize
> > +				 * against concurrent reclaimers.  We can not
> > +				 * grab the page lock, but with correct
> > +				 * ordering of page flag accesses we can get
> > +				 * away without it.
> > +				 *
> > +				 * A concurrent isolator may add the page to
> > +				 * the unevictable list, set PG_lru and then
> > +				 * recheck PG_mlocked to verify it chose the
> > +				 * right list and conditionally move it again.
> > +				 *
> > +				 * TestClearPageMlocked() provides one half of
> > +				 * the barrier: when we do not see the page on
> > +				 * the LRU and fail isolation, the isolator
> > +				 * must see PG_mlocked cleared and move the
> > +				 * page on its own back to the evictable list.
> > +				 */
> > +				if (private && !details->anon_vma)
> > +					continue;
> > +				if (private && TestClearPageMlocked(page)) {
> > +					dec_zone_page_state(page, NR_MLOCK);
> > +					count_vm_event(UNEVICTABLE_PGCLEARED);
> > +					if (!isolate_lru_page(page))
> > +						putback_lru_page(page);
> > +				}
> >  			}
> >  			ptent = ptep_get_and_clear_full(mm, addr, pte,
> >  							tlb->fullmm);
> 
> Umm..
> I haven't understand this.
> 
> (1) unmap_mapping_range() is called twice.
> 
> 	unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
> 	truncate_inode_pages(mapping, new);
> 	unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
> 
> (2) PG_mlock is turned on from mlock() and vmscan.
> (3) vmscan grab anon_vma, but mlock don't grab anon_vma.

You are right, I was so focused on the LRU side that I missed an
obvious window here: an _explicit_ mlock can still happen between the
PG_mlocked clearing section and releasing the page.

If we race with it, the put_page() in __mlock_vma_pages_range() might
free the freshly mlocked page.

> (4) after truncate_inode_pages(), we don't need to think vs-COW, because
>     find_get_page() never success. but first unmap_mapping_range()
>     have vs-COW racing.

Yes, we can race with COW breaking, but I can not see a problem there.
It clears the old page's mlock, but also with an atomic
TestClearPageMlocked().  And the new page is mapped and mlocked under
pte lock and only if we didn't clear the pte in the meantime.

> So, Is anon_vma grabbing really sufficient?

No, the explicit mlocking race exists, I think.

> Or, you intent to the following?
> 
> 	unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 0);
> 	truncate_inode_pages(mapping, new);
> 	unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);

As mentioned above, I don't see how it would make a difference.

> > @@ -544,6 +544,13 @@ redo:
> >  		 */
> >  		lru = LRU_UNEVICTABLE;
> >  		add_page_to_unevictable_list(page);
> > +		/*
> > +		 * See the TestClearPageMlocked() in zap_pte_range():
> > +		 * if a racing unmapper did not see the above setting
> > +		 * of PG_lru, we must see its clearing of PG_locked
> > +		 * and move the page back to the evictable list.
> > +		 */
> > +		smp_mb();
> >  	}
> 
> add_page_to_unevictable() have a spin lock. Why do we need additionl
> explicit memory barrier?

It sets PG_lru under spinlock and tests PG_mlocked after the unlock.
The following sections from memory-barriers.txt made me nervous:

 (5) LOCK operations.

     This acts as a one-way permeable barrier.  It guarantees that all memory
     operations after the LOCK operation will appear to happen after the LOCK
     operation with respect to the other components of the system.

 (6) UNLOCK operations.

     This also acts as a one-way permeable barrier.  It guarantees that all
     memory operations before the UNLOCK operation will appear to happen before
     the UNLOCK operation with respect to the other components of the system.

     Memory operations that occur after an UNLOCK operation may appear to
     happen before it completes.

So the only garuantee this gives us is that both PG_lru setting and
PG_mlocked testing happen after LOCK and PG_lru setting finishes
before UNLOCK, no?  I wanted to make sure this does not happen:

	LOCK, test PG_mlocked, set PG_lru, UNLOCK

I don't know whether there is a data dependency between those two
operations.  They go to the same word, but I could also imagine
setting one bit is independent of reading another one.  Humm.  Help.

Thanks,
	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
