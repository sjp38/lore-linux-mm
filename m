Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 789A76B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 02:54:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2956A3EE0C5
	for <linux-mm@kvack.org>; Mon,  9 May 2011 15:54:36 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0670045DE68
	for <linux-mm@kvack.org>; Mon,  9 May 2011 15:54:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CDD5645DE4D
	for <linux-mm@kvack.org>; Mon,  9 May 2011 15:54:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C19D91DB803A
	for <linux-mm@kvack.org>; Mon,  9 May 2011 15:54:35 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D18F1DB803E
	for <linux-mm@kvack.org>; Mon,  9 May 2011 15:54:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
In-Reply-To: <1593977838.225469.1304473119444.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
References: <4D72580D.4000208@gmail.com> <1593977838.225469.1304473119444.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-Id: <20110509155612.1648.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  9 May 2011 15:54:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>

> 
> 
> ----- Original Message -----
> > On 03/05/2011 06:20 PM, Minchan Kim wrote:
> > > On Sat, Mar 05, 2011 at 02:44:16PM +0300, Andrey Vagin wrote:
> > >> Check zone->all_unreclaimable in all_unreclaimable(), otherwise the
> > >> kernel may hang up, because shrink_zones() will do nothing, but
> > >> all_unreclaimable() will say, that zone has reclaimable pages.
> > >>
> > >> do_try_to_free_pages()
> > >> 	shrink_zones()
> > >> 		 for_each_zone
> > >> 			if (zone->all_unreclaimable)
> > >> 				continue
> > >> 	if !all_unreclaimable(zonelist, sc)
> > >> 		return 1
> > >>
> > >> __alloc_pages_slowpath()
> > >> retry:
> > >> 	did_some_progress = do_try_to_free_pages(page)
> > >> 	...
> > >> 	if (!page&& did_some_progress)
> > >> 		retry;
> > >>
> > >> Signed-off-by: Andrey Vagin<avagin@openvz.org>
> > >> ---
> > >>   mm/vmscan.c | 2 ++
> > >>   1 files changed, 2 insertions(+), 0 deletions(-)
> > >>
> > >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> > >> index 6771ea7..1c056f7 100644
> > >> --- a/mm/vmscan.c
> > >> +++ b/mm/vmscan.c
> > >> @@ -2002,6 +2002,8 @@ static bool all_unreclaimable(struct zonelist
> > >> *zonelist,
> > >>
> > >>   	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > >>   			gfp_zone(sc->gfp_mask), sc->nodemask) {
> > >> + if (zone->all_unreclaimable)
> > >> + continue;
> > >>   		if (!populated_zone(zone))
> > >>   			continue;
> > >>   		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> > >
> > > zone_reclaimable checks it. Isn't it enough?
> > I sent one more patch [PATCH] mm: skip zombie in OOM-killer.
> > This two patches are enough.
> > > Does the hang up really happen or see it by code review?
> > Yes. You can reproduce it for help the attached python program. It's
> > not
> > very clever:)
> > It make the following actions in loop:
> > 1. fork
> > 2. mmap
> > 3. touch memory
> > 4. read memory
> > 5. munmmap
> > 
> > >> --
> > >> 1.7.1
> I have tested this for the latest mainline kernel using the reproducer
> attached, the system just hung or deadlock after oom. The whole oom
> trace is here.
> http://people.redhat.com/qcai/oom.log
> 
> Did I miss anything?

Can you please try commit 929bea7c714220fc76ce3f75bef9056477c28e74?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
