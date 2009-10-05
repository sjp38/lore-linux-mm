Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF836B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 15:32:07 -0400 (EDT)
Date: Mon, 5 Oct 2009 21:32:00 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 3/3] mm: munlock COW pages on truncation unmap
Message-ID: <20091005193200.GA13040@cmpxchg.org>
References: <1254344964-8124-1-git-send-email-hannes@cmpxchg.org> <1254344964-8124-3-git-send-email-hannes@cmpxchg.org> <20091002100838.5F5A.A69D9226@jp.fujitsu.com> <20091002233837.GA3638@cmpxchg.org> <2f11576a0910030656l73c9811w18e0f224fb3d98af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f11576a0910030656l73c9811w18e0f224fb3d98af@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Oct 03, 2009 at 10:56:55PM +0900, KOSAKI Motohiro wrote:
> >> Umm..
> >> I haven't understand this.
> >>
> >> (1) unmap_mapping_range() is called twice.
> >>
> >>       unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
> >>       truncate_inode_pages(mapping, new);
> >>       unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
> >>
> >> (2) PG_mlock is turned on from mlock() and vmscan.
> >> (3) vmscan grab anon_vma, but mlock don't grab anon_vma.
> >
> > You are right, I was so focused on the LRU side that I missed an
> > obvious window here: an _explicit_ mlock can still happen between the
> > PG_mlocked clearing section and releasing the page.

Okay, so what are the opinions on this?  Would you consider my patches
to fix the most likely issues?  Dropping them in favor of looking for
a complete fix?  Revert the warning on freeing PG_mlocked pages?

> >> > @@ -544,6 +544,13 @@ redo:
> >> >              */
> >> >             lru = LRU_UNEVICTABLE;
> >> >             add_page_to_unevictable_list(page);
> >> > +           /*
> >> > +            * See the TestClearPageMlocked() in zap_pte_range():
> >> > +            * if a racing unmapper did not see the above setting
> >> > +            * of PG_lru, we must see its clearing of PG_locked
> >> > +            * and move the page back to the evictable list.
> >> > +            */
> >> > +           smp_mb();
> >> >     }
> >>
> >> add_page_to_unevictable() have a spin lock. Why do we need additionl
> >> explicit memory barrier?
> >
> > It sets PG_lru under spinlock and tests PG_mlocked after the unlock.
> > The following sections from memory-barriers.txt made me nervous:
> >
> >  (5) LOCK operations.
> >
> >     This acts as a one-way permeable barrier.  It guarantees that all memory
> >     operations after the LOCK operation will appear to happen after the LOCK
> >     operation with respect to the other components of the system.
> >
> >  (6) UNLOCK operations.
> >
> >     This also acts as a one-way permeable barrier.  It guarantees that all
> >     memory operations before the UNLOCK operation will appear to happen before
> >     the UNLOCK operation with respect to the other components of the system.
> >
> >     Memory operations that occur after an UNLOCK operation may appear to
> >     happen before it completes.
> >
> > So the only garuantee this gives us is that both PG_lru setting and
> > PG_mlocked testing happen after LOCK and PG_lru setting finishes
> > before UNLOCK, no?  I wanted to make sure this does not happen:
> >
> >        LOCK, test PG_mlocked, set PG_lru, UNLOCK
> >
> > I don't know whether there is a data dependency between those two
> > operations.  They go to the same word, but I could also imagine
> > setting one bit is independent of reading another one.  Humm.  Help.
> 
> Ahh, Yes! you are right.
> We really need this barrier.
> 
> However, I think this issue doesn't depend on zap_pte_range patch.
> Other TestClearPageMlocked(page) caller have the same problem, because
> putback_lru_page() doesn't have any exclusion, right?

You are right, it's an issue on its own.  Please find a stand-alone
patch below.

Thanks,

	Hannes

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: mm: order evictable rescue in LRU putback

Isolators putting a page back to the LRU do not hold the page lock,
and if the page is mlocked, another thread might munlock it
concurrently.

Expecting this, the putback code re-checks the evictability of a page
when it just moved it to the unevictable list in order to correct its
decision.

The problem, however, is that ordering is not garuanteed between
setting PG_lru when moving the page to the list and checking
PG_mlocked afterwards:

	#0 putback			#1 munlock

	spin_lock()
					if (TestClearPageMlocked())
					  if (PageLRU())
					    move to evictable list
	SetPageLRU()
	spin_unlock()
	if (!PageMlocked())
	  move to evictable list

The PageMlocked() reading may get reordered before SetPageLRU() in #0,
resulting in #0 not moving the still mlocked page, and in #1 failing
to isolate and move the page as well.  The evictable page is now
stranded on the unevictable list.

TestClearPageMlocked() in #1 already provides full memory barrier
semantics.

This patch adds an explicit full barrier to force ordering between
SetPageLRU() and PageMlocked() in #0 so that either one of the
competitors rescues the page.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/vmscan.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -544,6 +544,16 @@ redo:
 		 */
 		lru = LRU_UNEVICTABLE;
 		add_page_to_unevictable_list(page);
+		/*
+		 * When racing with an mlock clearing (page is
+		 * unlocked), make sure that if the other thread does
+		 * not observe our setting of PG_lru and fails
+		 * isolation, we see PG_mlocked cleared below and move
+		 * the page back to the evictable list.
+		 *
+		 * The other side is TestClearPageMlocked().
+		 */
+		smp_mb();
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
