Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 104656B004D
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 11:39:14 -0400 (EDT)
Date: Sat, 27 Jun 2009 17:36:30 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090627153630.GA6803@cmpxchg.org>
References: <20090624023251.GA16483@localhost> <20090620043303.GA19855@localhost> <32411.1245336412@redhat.com> <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com> <20090618095729.d2f27896.akpm@linux-foundation.org> <7561.1245768237@redhat.com> <26537.1246086769@redhat.com> <20090627125412.GA1667@cmpxchg.org> <28c262360906270650v6c276591u417d64573ecfba29@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360906270650v6c276591u417d64573ecfba29@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: David Howells <dhowells@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, Jun 27, 2009 at 10:50:25PM +0900, Minchan Kim wrote:
> Hi, Hannes.
> 
> On Sat, Jun 27, 2009 at 9:54 PM, Johannes Weiner<hannes@cmpxchg.org> wrote:
> > On Sat, Jun 27, 2009 at 08:12:49AM +0100, David Howells wrote:
> >>
> >> I've managed to bisect things to find the commit that causes the OOMs. A It's:
> >>
> >> A  A  A  commit 69c854817566db82c362797b4a6521d0b00fe1d8
> >> A  A  A  Author: MinChan Kim <minchan.kim@gmail.com>
> >> A  A  A  Date: A  Tue Jun 16 15:32:44 2009 -0700
> >>
> >> A  A  A  A  A  vmscan: prevent shrinking of active anon lru list in case of no swap space V3
> >>
> >> A  A  A  A  A  shrink_zone() can deactivate active anon pages even if we don't have a
> >> A  A  A  A  A  swap device. A Many embedded products don't have a swap device. A So the
> >> A  A  A  A  A  deactivation of anon pages is unnecessary.
> >>
> >> A  A  A  A  A  This patch prevents unnecessary deactivation of anon lru pages. A But, it
> >> A  A  A  A  A  don't prevent aging of anon pages to swap out.
> >>
> >> A  A  A  A  A  Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> >> A  A  A  A  A  Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >> A  A  A  A  A  Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> A  A  A  A  A  Acked-by: Rik van Riel <riel@redhat.com>
> >> A  A  A  A  A  Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >> A  A  A  A  A  Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> >>
> >> This exhibits the problem. A The previous commit:
> >>
> >> A  A  A  commit 35282a2de4e5e4e173ab61aa9d7015886021a821
> >> A  A  A  Author: Brice Goglin <Brice.Goglin@ens-lyon.org>
> >> A  A  A  Date: A  Tue Jun 16 15:32:43 2009 -0700
> >>
> >> A  A  A  A  A  migration: only migrate_prep() once per move_pages()
> >>
> >> survives 16 iterations of the LTP syscall testsuite without exhibiting the
> >> problem.
> >
> > Here is the patch in question:
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 7592d8e..879d034 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1570,7 +1570,7 @@ static void shrink_zone(int priority, struct zone *zone,
> > A  A  A  A  * Even if we did not try to evict anon pages at all, we want to
> > A  A  A  A  * rebalance the anon lru active/inactive ratio.
> > A  A  A  A  */
> > - A  A  A  if (inactive_anon_is_low(zone, sc))
> > + A  A  A  if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
> > A  A  A  A  A  A  A  A shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> >
> > A  A  A  A throttle_vm_writeout(sc->gfp_mask);
> >
> > When this was discussed, I think we missed that nr_swap_pages can
> > actually get zero on swap systems as well and this should have been
> > total_swap_pages - otherwise we also stop balancing the two anon lists
> > when swap is _full_ which was not the intention of this change at all.
> 
> At that time we considered it so that we didn't prevent anon list
> aging for background reclaim.
> Do you think it is not enough ?

With a heavy multiprocess anon load, direct reclaimers will likely
reuse the reclaimed pages for anon mappings, so you have a handful of
processes shuffling pages on the active list and only one thread that
tries to balance.  I can imagine that it can not keep up for long.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
