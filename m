Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 9234C6B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 00:10:11 -0400 (EDT)
Received: by yenm8 with SMTP id m8so293226yen.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 21:10:10 -0700 (PDT)
Date: Tue, 1 May 2012 21:09:58 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH next 00/12] mm: replace struct mem_cgroup_zone with struct
 lruvec
In-Reply-To: <4F9A4E8E.4040700@openvz.org>
Message-ID: <alpine.LSU.2.00.1205012005390.1293@eggly.anvils>
References: <20120426074632.18961.17803.stgit@zurg> <20120426162546.90991b7c.akpm@linux-foundation.org> <4F9A4E8E.4040700@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 27 Apr 2012, Konstantin Khlebnikov wrote:
> Andrew Morton wrote:
> > On Thu, 26 Apr 2012 11:53:44 +0400
> > Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
> > 
> > > This patchset depends on Johannes Weiner's patch
> > > "mm: memcg: count pte references from every member of the reclaimed
> > > hierarchy".
> > > 
> > > bloat-o-meter delta for patches 2..12
> > > 
> > > add/remove: 6/6 grow/shrink: 6/14 up/down: 4414/-4625 (-211)
> > 
> > That's the sole effect and intent of the patchset?  To save 211 bytes?

I am surprised it's not more: it feels like more.

> 
> This is almost last bunch of cleanups for lru_lock splitting,
> code reducing is only nice side-effect.
> Also this patchset removes many redundant lruvec relookups.
> 
> Now mostly all page-to-lruvec translations are located at the same level
> as zone->lru_lock locking. So lru-lock splitting patchset can something like
> this:
> 
> -zone = page_zone(page)
> -spin_lock_irq(&zone->lru_lock)
> -lruvec = mem_cgroup_page_lruvec(page)
> +lruvec = lock_page_lruvec_irq(page)
> 
> > 
> > > ...
> > > 
> > >   include/linux/memcontrol.h |   16 +--
> > >   include/linux/mmzone.h     |   14 ++
> > >   mm/memcontrol.c            |   33 +++--
> > >   mm/mmzone.c                |   14 ++
> > >   mm/page_alloc.c            |    8 -
> > >   mm/vmscan.c                |  277
> > > ++++++++++++++++++++------------------------
> > >   6 files changed, 177 insertions(+), 185 deletions(-)
> > 
> > If so, I'm not sure that it is worth the risk and effort?

I'm pretty sure that it is worth the effort, and see very little risk.

It's close to my "[PATCH 3/10] mm/memcg: add zone pointer into lruvec"
posted 20 Feb (after Konstantin posted his set a few days earlier),
which Kamezawa-san Acked with "I like this cleanup".  But this goes
a little further (e.g. 01/12 saving an arg by moving priority into sc,
that's nice; and v2 05/12 removing update_isolated_counts(), great).

Konstantin and I came independently to this simplification, or
generalization, from zone to lruvec: we're confident that it is the
right direction, that it's a good basis for further work.  Certainly
neither of us have yet posted numbers to justify per-memcg per-zone
locking (and I expect split zone locking to need more justification
than it's had); but we both think these patches are a worthwhile
cleanup on their own.

I don't think it was particularly useful to split this into all of
12 pieces!  But never mind, that's a trivial detail, not worth undoing.
There's a few by-the-by bits and pieces I liked in my version that are
not here, but nothing important: if I care enough, I can always send a
little cleanup afterwards.

The only change I'd ask for is in the commit comment on 02/12: it
puzzlingly says "page_zone()" where it means to say "lruvec_zone()".
I think if I'd been doing 04/12, I'd have resented passing "zone" to
shrink_page_list(), would have deleted its VM_BUG_ON, and used a
page_zone() for ZONE_CONGESTED: but that's just me being mean.

I've gone through and compared the result of these 12 against my own
tree updated to next-20120427.  We come out much the same: the only
divergence which worried me was that my mem_cgroup_zone_lruvec() says
	IF (!memcg || mem_cgroup_disabled())
		return &zone->lruvec;
and although I'm sure I had a reason for adding that "!memcg || ",
I cannot now see why.  Maybe it was for some intermediate use that went
away (but I mention it in the hope that Konstantin will double check).

To each one of the 12 (with lruvec_zone in 02/12, and v2 of 05/12):
Acked-by: Hugh Dickins <hughd@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
