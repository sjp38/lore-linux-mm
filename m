Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F35A06B0022
	for <linux-mm@kvack.org>; Tue, 17 May 2011 03:42:57 -0400 (EDT)
Date: Tue, 17 May 2011 09:42:30 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 4/6] memcg: reclaim statistics
Message-ID: <20110517074230.GY16531@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <1305212038-15445-5-git-send-email-hannes@cmpxchg.org>
 <BANLkTi=yCyAsOc_uTQLp1kWp5w0i9gomxg@mail.gmail.com>
 <20110516231028.GV16531@cmpxchg.org>
 <BANLkTimLNZfc-jcA3yBG5D3k2u=0_JnrhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimLNZfc-jcA3yBG5D3k2u=0_JnrhQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 16, 2011 at 05:20:31PM -0700, Ying Han wrote:
> On Mon, May 16, 2011 at 4:10 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Thu, May 12, 2011 at 12:33:50PM -0700, Ying Han wrote:
> > > The stats for soft_limit reclaim from global ttfp have been merged in
> > > mmotm i believe as the following:
> > >
> > > "soft_direct_steal"
> > > "soft_direct_scan"
> > >
> > > I wonder we might want to separate that out from the other case where the
> > > reclaim is from the parent triggers its limit.
> >
> > The way I implemented soft limits in 6/6 is to increase pressure on
> > exceeding children whenever hierarchical reclaim is taking place.
> >
> > This changes soft limit from
> >
> >        Global memory pressure: reclaim from exceeding memcg(s) first
> >
> > to
> >
> >        Memory pressure on a memcg: reclaim from all its children,
> >        with increased pressure on those exceeding their soft limit
> >        (where global memory pressure means root_mem_cgroup and all
> >        existing memcgs are considered its children)
> >
> > which makes the soft limit much more generic and more powerful, as it
> > allows the admin to prioritize reclaim throughout the hierarchy, not
> > only for global memory pressure.  Consider one memcg with two
> > subgroups.  You can now prioritize reclaim to prefer one subgroup over
> > another through soft limiting.
> >
> > This is one reason why I think that the approach of maintaining a
> > global list of memcgs that exceed their soft limits is an inferior
> > approach; it does not take the hierarchy into account at all.
> >
> > This scheme would not provide a natural way of counting pages that
> > were reclaimed because of the soft limit, and thus I still oppose the
> > merging of soft limit counters.
> 
> The proposal we discussed during LSF ( implemented in the patch " memcg:
> revisit soft_limit reclaim on contention") takes consideration
> of hierarchical reclaim. The memcg is linked in the list if it exceeds the
> soft_limit, and the soft_limit reclaim per-memcg is calling
> mem_cgroup_hierarchical_reclaim().

It does hierarchical soft limit reclaim once triggered, but I meant
that soft limits themselves have no hierarchical meaning.  Say you
have the following hierarchy:

                root_mem_cgroup

             aaa               bbb

           a1  a2             b1  b2

        a1-1

Consider aaa and a1 had a soft limit.  If global memory arose, aaa and
all its children would be pushed back with the current scheme, the one
you are proposing, and the one I am proposing.

But now consider aaa hitting its hard limit.  Regular target reclaim
will be triggered, and a1, a2, and a1-1 will be scanned equally from
hierarchical reclaim.  That a1 is in excess of its soft limit is not
considered at all.

With what I am proposing, a1 and a1-1 would be pushed back more
aggressively than a2, because a1 is in excess of its soft limit and
a1-1 is contributing to that.

It would mean that given a group of siblings, you distribute the
pressure weighted by the soft limit configuration, independent of the
kind of hierarchical/external pressure (global memory scarcity or
parent hit the hard limit).

It's much easier to understand if you think of global memory pressure
to mean that root_mem_cgroup hit its hard limit, and that all existing
memcgs are hierarchically below the root_mem_cgroup.  Altough it is
technically not implemented that way, that would be the consistent
model.

My proposal is a generic and native way of enforcing soft limits: a
memcg hit its hard limit, reclaim from the hierarchy below it, prefer
those in excess of their soft limit.

While yours is special-cased to immediate descendants of the
root_mem_cgroup.

> The current "soft_steal" and "soft_scan" is counting pages being steal/scan
>  inside mem_cgroup_hierarchical_reclaim() w check_soft checking, which then
> counts pages being reclaimed because of soft_limit and also counting the
> hierarchical reclaim.

Yeah, I understand that.  What I am saying is that in my code,
everytime a hierarchy of memcgs is scanned (global memory reclaim,
target reclaim, kswapd or direct, it's all the same), a memcg that is
in excess of its soft limit is put more pressure on compared to its
siblings.

There is no stand-alone 'now, go reclaim soft limits' cycle anymore.
As such, it would be impossible to maintain that counter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
