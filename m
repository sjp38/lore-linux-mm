Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2866E6B004D
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 08:22:46 -0400 (EDT)
Date: Sat, 29 Aug 2009 14:22:18 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH mmotm] vmscan move pgdeactivate modification to shrink_active_list fix
Message-ID: <20090829122217.GA17448@cmpxchg.org>
References: <Pine.LNX.4.64.0908282034240.19475@sister.anvils> <2f11576a0908290300h155596e1y730c355ade7a671e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f11576a0908290300h155596e1y730c355ade7a671e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 29, 2009 at 07:00:47PM +0900, KOSAKI Motohiro wrote:
> Hi Hugh
> 
> 2009/8/29 Hugh Dickins <hugh.dickins@tiscali.co.uk>:
> > mmotm 2009-08-27-16-51 lets the OOM killer loose on my loads even
> > quicker than last time: one bug fixed but another bug introduced.
> > vmscan-move-pgdeactivate-modification-to-shrink_active_list.patch
> > forgot to add NR_LRU_BASE to lru index to make zone_page_state index.
> >
> > Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> Can I use your test case?
> Currently LRU_BASE is 0. it mean
> 
> LRU_BASE == NR_INACTIVE_ANON == 0
> LRU_ACTIVE == NR_ACTIVE_ANON == 1

The zone counters are

	NR_FREE_PAGES = 0
	NR_INACTIVE_ANON = NR_LRU_BASE = 1
	NR_ACTIVE_ANON = 2
	...,

and NR_LRU_BASE is the offset of the LRU items within the zone stat
items.  You missed this offset, so accounting to LRU_BASE + 0 *
LRU_FILE actually accounts to NR_FREE_PAGES, not to NR_INACTIVE_ANON.

I get the feeling we should make this thing more robust...

	Hannes

> Therefore, I doubt there are another issue in current mmotm.
> Can I join your strange oom fixing works?
> 
> 
> > ---
> >
> > A mm/vmscan.c | A  A 6 ++++--
> > A 1 file changed, 4 insertions(+), 2 deletions(-)
> >
> > --- mmotm/mm/vmscan.c A  2009-08-28 10:07:57.000000000 +0100
> > +++ linux/mm/vmscan.c A  2009-08-28 18:30:33.000000000 +0100
> > @@ -1381,8 +1381,10 @@ static void shrink_active_list(unsigned
> > A  A  A  A reclaim_stat->recent_rotated[file] += nr_rotated;
> > A  A  A  A __count_vm_events(PGDEACTIVATE, nr_deactivated);
> > A  A  A  A __mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
> > - A  A  A  __mod_zone_page_state(zone, LRU_ACTIVE + file * LRU_FILE, nr_rotated);
> > - A  A  A  __mod_zone_page_state(zone, LRU_BASE + file * LRU_FILE, nr_deactivated);
> > + A  A  A  __mod_zone_page_state(zone, NR_ACTIVE_ANON + file * LRU_FILE,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  nr_rotated);
> > + A  A  A  __mod_zone_page_state(zone, NR_INACTIVE_ANON + file * LRU_FILE,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  nr_deactivated);
> > A  A  A  A spin_unlock_irq(&zone->lru_lock);
> > A }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
