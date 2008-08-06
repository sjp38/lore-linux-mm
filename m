Subject: Re: Race condition between putback_lru_page and
	mem_cgroup_move_list
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <489741F8.2080104@linux.vnet.ibm.com>
References: <28c262360808040736u7f364fc0p28d7ceea7303a626@mail.gmail.com>
	 <1217863870.7065.62.camel@lts-notebook>
	 <2f11576a0808040937y70f274e0j32f6b9c98b0f992d@mail.gmail.com>
	 <489741F8.2080104@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Date: Wed, 06 Aug 2008 12:53:05 -0400
Message-Id: <1218041585.6173.45.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-08-04 at 23:22 +0530, Balbir Singh wrote:
> KOSAKI Motohiro wrote:
> > Hi
> > 
> >>> I think this is a race condition if mem_cgroup_move_lists's comment isn't right.
> >>> I am not sure that it was already known problem.
> >>>
> >>> mem_cgroup_move_lists assume the appropriate zone's lru lock is already held.
> >>> but putback_lru_page calls mem_cgroup_move_lists without holding lru_lock.
> >> Hmmm, the comment on mem_cgroup_move_lists() does say this.  Although,
> >> reading thru' the code, I can't see why it requires this.  But then it's
> >> Monday, here...
> > 
> > I also think zone's lru lock is unnecessary.
> > So, I guess below "it" indicate lock_page_cgroup, not zone lru lock.
> > 
> 
> We need zone LRU lock, since the reclaim paths hold them. Not sure if I
> understand why you call zone's LRU lock unnecessary, could you elaborate please?

Hi, Balbir:

Sorry for the delay in responding.  Distracted...

I think that perhaps the zone's LRU lock is unnecessary because I didn't
see anything in mem_cgroup_move_lists() or it's callees that needed
protection by the zone lru_lock.  

Looking at the call sites in the reclaim paths [in
shrink_[in]active_page()] and activate_page(), they are holding the zone
lru_lock because they are manipulating the lru lists and/or zone
statistics.  The places where pages are moved to a new lru list is where
you want to insert calls to mem_cgroup_move_lists(), so I think they
just happen to fall under the zone lru lock.  

Now, in a subsequent message in this thread, you ask:

"1. What happens if a global reclaim is in progress at the same time as
memory cgroup reclaim and they are both looking at the same page?"

This should not happen, I think.  Racing global and memory cgroup calls
to __isolate_lru_page() are mutually excluded by the zone lru_lock taken
in shrink_[in]active_page().  In putback_lru_page(), where we call
mem_cgroup_move_lists() without holding the zone lru_lock, we've either
queued up the page for adding to one of the [in]active lists via the
pagevecs, or we've already moved it to the unevictable list.  If
mem_cgroup_isolate_pages() finds a page on one of the mz lists before it
has been drained to the LRU, it will [rightly] skip the page because
it's "!PageLRU(page)".


In same message, you state:

"2. In the shared reclaim infrastructure, we move pages and update
statistics for pages belonging to a particular zone in a particular
cgroup."

Sorry, I don't understand your point.  Are you concerned that the stats
can get out of sync?  I suppose that, in general, if we called
mem_cgroup_move_lists() from just anywhere without zone lru_lock
protection, we could have problems.  In the case of putback_lru_page(),
again, we've already put the page back on the global unevictable list
and updated the global stats, or it's on it's way to an [in]active list
via the pagevecs.  The stats will be updated when the pagevecs are
drained.

I think we're OK without explicit zone lru locking around the call to
mem_cgroup_move_lists() and the global lru list additions in
putback_lru_page().   

> 
> >  >> But we cannot safely get to page_cgroup without it, so just try_lock it:
> > 
> > if my assumption is true, comment modifying is better.
> > 
> > 
> >>> Repeatedly, spin_[un/lock]_irq use in mem_cgroup_move_list have a big overhead
> >>> while doing list iteration.
> >>>
> >>> Do we have to use pagevec ?
> >> This shouldn't be necessary, IMO.  putback_lru_page() is used as
> >> follows:
> >>
> >> 1) in vmscan.c [shrink_*_list()] when an unevictable page is
> >> encountered.  This should be relatively rare.  Once vmscan sees an
> >> unevictable page, it parks it on the unevictable lru list where it
> >> [vmscan] won't see the page again until it becomes reclaimable.
> >>
> >> 2) as a replacement for move_to_lru() in page migration as the inverse
> >> to isolate_lru_page().  We did this to catch patches that became
> >> unevictable or, more importantly, evictable while page migration held
> >> them isolated.  move_to_lru() already grabbed and released the zone lru
> >> lock on each page migrated.
> >>
> >> 3) In m[un]lock_vma_page() and clear_page_mlock(), new with in the
> >> "mlocked pages are unevictable" series.  This one can result in a storm
> >> of zone lru traffic--e.g., mlock()ing or munlocking() a large segment or
> >> mlockall() of a task with a lot of mapped address space.  Again, this is
> >> probably a very rare event--unless you're stressing [stressing over?]
> >> mlock(), as I've been doing :)--and often involves a major fault [page
> >> allocation], per page anyway.
> >>
> >> Ii>>? originally did have a pagevec for the unevictable lru but it
> >> complicated ensuring that we don't strand evictable pages on the
> >> unevictable list.  See the retry logic in putback_lru_page().
> >>
> >> As for the !UNEVICTABLE_LRU version, the only place this should be
> >> called is from page migration as none of the other call sites are
> >> compiled in or reachable when !UNEVICTABLE_LRU.
> >>
> >> Thoughts?
> > 
> > I think both opinion is correct.
> > unevictable lru related code doesn't require pagevec.
> > 
> > but mem_cgroup_move_lists is used by active/inactive list transition too.
> > then, pagevec is necessary for keeping reclaim throuput.
> > 

Kosaki-san:

If you mean the "active/inactive list transition" in
shrink_[in]active_list(), these are already batched under zone lru_lock
with batch size determined by the 'release pages' pvec.  So, I think
we're OK here.

If you mean in "activate_page()", it appears to handle one page at a
time to keep the stats in sync.  Not sure whether it's amenable to a
pagevec approach.  In any case, the FIXME comment there asks if it can
be sped up and adding the call to mem_cgroup_move_lists() probably
didn't [speed it up, I mean].  So, have at it! :)

> 
> It's on my TODO list. I hope to get to it soon.
> 
> > Kim-san, Thank you nice point out!
> > I queued this fix to my TODO list.
> 

Yes.  Thanks for reviewing this.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
