Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 58DCE6B01DA
	for <linux-mm@kvack.org>; Thu, 14 May 2009 12:24:19 -0400 (EDT)
Date: Thu, 14 May 2009 18:22:01 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case of no swap space V3
Message-ID: <20090514162201.GA2361@cmpxchg.org>
References: <20090514231555.f52c81eb.minchan.kim@gmail.com> <2f11576a0905140727j5ba02b07t94826f57dd99839c@mail.gmail.com> <44c63dc40905140739n271d3d2w2e0cc364c0012d71@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <44c63dc40905140739n271d3d2w2e0cc364c0012d71@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <barrioskmc@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, MinChan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 11:39:49PM +0900, Minchan Kim wrote:
> On Thu, May 14, 2009 at 11:27 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> A mm/vmscan.c | A  A 2 +-
> >> A 1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 2f9d555..621708f 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -1577,7 +1577,7 @@ static void shrink_zone(int priority, struct zone *zone,
> >> A  A  A  A  * Even if we did not try to evict anon pages at all, we want to
> >> A  A  A  A  * rebalance the anon lru active/inactive ratio.
> >> A  A  A  A  */
> >> - A  A  A  if (inactive_anon_is_low(zone, sc))
> >> + A  A  A  if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
> >> A  A  A  A  A  A  A  A shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> >
> >
> > A  A  A  if (nr_swap_pages > 0 && inactive_anon_is_low(zone, sc))
> >
> > is better?
> > compiler can't swap evaluate order around &&.
> 
> If GCC optimizes away that branch with CONFIG_SWAP=n as Rik mentioned,
> we don't have a concern.

It can only optimize it away when the condition is a compile time
constant.

But inactive_anon_is_low() contains atomic operations which the
compiler is not allowed to drop and so the && semantics lead to

	atomic_read() && 0

emitting the read while still knowing the whole expression is 0 at
compile-time, optimizing away only the branch itself but leaving the
read in place!

Compared to

	0 && atomic_read()

where the && short-circuitry leads to atomic_read() not being
executed.  And since the 0 is a compile time constant, no code has to
be emitted for the read.

So KOSAKI-san's is right.  Your version results in bigger object code.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
