Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 976F48D003B
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 13:52:03 -0400 (EDT)
Date: Thu, 2 Jun 2011 19:51:42 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
Message-ID: <20110602175142.GH28684@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
 <BANLkTi=sYtLGk2_VQLejEU2rQ0JBgg_ZmQ@mail.gmail.com>
 <20110602075028.GB20630@cmpxchg.org>
 <BANLkTi=AZG4LKUdeODB0uP=_CVBRnGs_Nw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTi=AZG4LKUdeODB0uP=_CVBRnGs_Nw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 02, 2011 at 08:51:39AM -0700, Ying Han wrote:
> On Thu, Jun 2, 2011 at 12:50 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Wed, Jun 01, 2011 at 09:05:18PM -0700, Ying Han wrote:
> >> On Wed, Jun 1, 2011 at 4:52 PM, Hiroyuki Kamezawa
> >> <kamezawa.hiroyuki@gmail.com> wrote:
> >> > 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> >> >> Hi,
> >> >>
> >> >> this is the second version of the memcg naturalization series.  The
> >> >> notable changes since the first submission are:
> >> >>
> >> >>    o the hierarchy walk is now intermittent and will abort and
> >> >>      remember the last scanned child after sc->nr_to_reclaim pages
> >> >>      have been reclaimed during the walk in one zone (Rik)
> >> >>
> >> >>    o the global lru lists are never scanned when memcg is enabled
> >> >>      after #2 'memcg-aware global reclaim', which makes this patch
> >> >>      self-sufficient and complete without requiring the per-memcg lru
> >> >>      lists to be exclusive (Michal)
> >> >>
> >> >>    o renamed sc->memcg and sc->current_memcg to sc->target_mem_cgroup
> >> >>      and sc->mem_cgroup and fixed their documentation, I hope this is
> >> >>      better understandable now (Rik)
> >> >>
> >> >>    o the reclaim statistic counters have been renamed.  there is no
> >> >>      more distinction between 'pgfree' and 'pgsteal', it is now
> >> >>      'pgreclaim' in both cases; 'kswapd' has been replaced by
> >> >>      'background'
> >> >>
> >> >>    o fixed a nasty crash in the hierarchical soft limit check that
> >> >>      happened during global reclaim in memcgs that are hierarchical
> >> >>      but have no hierarchical parents themselves
> >> >>
> >> >>    o properly implemented the memcg-aware unevictable page rescue
> >> >>      scanner, there were several blatant bugs in there
> >> >>
> >> >>    o documentation on new public interfaces
> >> >>
> >> >> Thanks for your input on the first version.
> >> >>
> >> >> I ran microbenchmarks (sparse file catting, essentially) to stress
> >> >> reclaim and LRU operations.  There is no measurable overhead for
> >> >> !CONFIG_MEMCG, memcg disabled during boot, memcg enabled but no
> >> >> configured groups, and hard limit reclaim.
> >> >>
> >> >> I also ran single-threaded kernbenchs in four unlimited memcgs in
> >> >> parallel, contained in a hard-limited hierarchical parent that put
> >> >> constant pressure on the workload.  There is no measurable difference
> >> >> in runtime, the pgpgin/pgpgout counters, and fairness among memcgs in
> >> >> this test compared to an unpatched kernel.  Needs more evaluation,
> >> >> especially with a higher number of memcgs.
> >> >>
> >> >> The soft limit changes are also proven to work in so far that it is
> >> >> possible to prioritize between children in a hierarchy under pressure
> >> >> and that runtime differences corresponded directly to the soft limit
> >> >> settings in the previously described kernbench setup with staggered
> >> >> soft limits on the groups, but this needs quantification.
> >> >>
> >> >> Based on v2.6.39.
> >> >>
> >> >
> >> > Hmm, I welcome and will review this patches but.....some points I want to say.
> >> >
> >> > 1. No more conflict with Ying's work ?
> >> >    Could you explain what she has and what you don't in this v2 ?
> >> >    If Ying's one has something good to be merged to your set, please
> >> > include it.
> >>
> >> My patch I sent out last time was doing rework of soft_limit reclaim.
> >> It convert the RB-tree based to
> >> a linked list round-robin fashion of all memcgs across their soft
> >> limit per-zone.
> >>
> >> I will apply this patch and try to test it. After that i will get
> >> better idea whether or not it is being covered here.
> >
> > Thanks!!
> >
> >> > 4. This work can be splitted into some small works.
> >> >     a) fix for current code and clean ups
> >>
> >> >     a') statistics
> >>
> >> >     b) soft limit rework
> >>
> >> >     c) change global reclaim
> >>
> >> My last patchset starts with a patch reverting the RB-tree
> >> implementation of the soft_limit
> >> reclaim, and then the new round-robin implementation comes on the
> >> following patches.
> >>
> >> I like the ordering here, and that is consistent w/ the plan we
> >> discussed earlier in LSF. Changing
> >> the global reclaim would be the last step when the changes before that
> >> have been well understood
> >> and tested.
> >>
> >> Sorry If that is how it is done here. I will read through the patchset.
> >
> > It's not.  The way I implemented soft limits depends on global reclaim
> > performing hierarchical reclaim.  I don't see how I can reverse the
> > order with this dependency.
> 
> That is something I don't quite get yet, and maybe need a closer look
> into the patchset. The current design of
> soft_limit doesn't do reclaim hierarchically but instead links the
> memcgs together on per-zone basis.
> 
> However on this patchset, we changed that design and doing
> hierarchy_walk of the memcg tree. Can we clarify more on why we made
> the design change? I can see the current design provides a efficient
> way to pick the one memcg over-their-soft-limit under shrink_zone().

The question is whether we even want it to work that way.  I outlined
that in the changelog of the soft limit rework patch.

As I see it, the soft limit should not exist solely to punish a memcg,
but to prioritize memcgs in case hierarchical pressure exists.  I am
arguing that the focus should be on relieving the pressure, rather
than beating the living crap out of the single-biggest offender.  Keep
in mind the scenarios where the biggest offender has a lot of dirty,
hard-to-reclaim pages while there are other, unsoftlimited groups that
have large amounts of easily reclaimable cache of questionable future
value.  I believe only going for soft-limit excessors is too extreme,
only for the single-biggest one outright nuts.

The second point I made last time already is that there is no
hierarchy support with that current scheme.  If you have a group with
two subgroups, it makes sense to soft limit one subgroup against the
other when the parent hits its limit.  This is not possible otherwise.

The third point was that the amount of code to actually support the
questionable behaviour of picking the biggest offender is gigantic
compared to naturally hooking soft limit reclaim into regular reclaim.

The implementation is not proven to be satisfactory, I only sent it
out so early and with this particular series because I wanted people
to stop merging reclaim statistics that may not even be supportable in
the long run.

I agree with Andrew: we either need to prove it's the way to go, or
prove that we never want to do it like this.  Before we start adding
statistics that commit us to one way or the other.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
