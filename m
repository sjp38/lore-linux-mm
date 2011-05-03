Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 12BB86B0022
	for <linux-mm@kvack.org>; Tue,  3 May 2011 02:12:14 -0400 (EDT)
Date: Tue, 3 May 2011 08:11:56 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: memcg: fix fatal livelock in kswapd
Message-ID: <20110503061156.GC10278@cmpxchg.org>
References: <1304366849.15370.27.camel@mulgrave.site>
 <20110502224838.GB10278@cmpxchg.org>
 <BANLkTikDyL9-XLpwyLwUQNuUfkBwbUBcZg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikDyL9-XLpwyLwUQNuUfkBwbUBcZg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, Balbir Singh <balbir@linux.vnet.ibm.com>

On Mon, May 02, 2011 at 04:14:09PM -0700, Ying Han wrote:
> On Mon, May 2, 2011 at 3:48 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > Hi,
> >
> > On Mon, May 02, 2011 at 03:07:29PM -0500, James Bottomley wrote:
> >> The fatal livelock in kswapd, reported in this thread:
> >>
> >> http://marc.info/?t=130392066000001
> >>
> >> Is mitigateable if we prevent the cgroups code being so aggressive in
> >> its zone shrinking (by reducing it's default shrink from 0 [everything]
> >> to DEF_PRIORITY [some things]).  This will have an obvious knock on
> >> effect to cgroup accounting, but it's better than hanging systems.
> >
> > Actually, it's not that obvious.  At least not to me.  I added Balbir,
> > who added said comment and code in the first place, to CC: Here is the
> > comment in full quote:
> >
> >        /*
> >         * NOTE: Although we can get the priority field, using it
> >         * here is not a good idea, since it limits the pages we can scan.
> >         * if we don't reclaim here, the shrink_zone from balance_pgdat
> >         * will pick up pages from other mem cgroup's as well. We hack
> >         * the priority and make it zero.
> >         */
> >
> > The idea is that if one memcg is above its softlimit, we prefer
> > reducing pages from this memcg over reclaiming random other pages,
> > including those of other memcgs.
> >
> > But the code flow looks like this:
> >
> >        balance_pgdat
> >          mem_cgroup_soft_limit_reclaim
> >            mem_cgroup_shrink_node_zone
> >              shrink_zone(0, zone, &sc)
> >          shrink_zone(prio, zone, &sc)
> >
> > so the success of the inner memcg shrink_zone does at least not
> > explicitely result in the outer, global shrink_zone steering clear of
> > other memcgs' pages.  It just tries to move the pressure of balancing
> > the zones to the memcg with the biggest soft limit excess.  That can
> > only really work if the memcg is a large enough contributor to the
> > zone's total number of lru pages, though, and looks very likely to hit
> > the exceeding memcg too hard in other cases.
> yes, the logic is selecting one memcg(the one exceeding the most) and
> starting hierarchical reclaim on it. It will looping until the the
> following condition becomes true:
> 1. memcg usage is below its soft_limit
> 2. looping 100 times
> 3. reclaimed pages equal or greater than (excess >>2) where excess is
> the (usage - soft_limit)

There is no need to loop if we beat up the memcg in question with a
hammer during the first iteration ;-)

That is, we already did the aggressive scan when all these conditions
are checked.

> hmm, the worst case i can think of is the memcg only has one page
> allocate on the zone, and we end up looping 100 time each time and not
> contributing much to the global reclaim.

Good point, it should probably bail earlier on a zone that does not
really contribute to the soft limit excess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
