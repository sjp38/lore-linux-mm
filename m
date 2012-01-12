Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 5C7576B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 04:17:36 -0500 (EST)
Date: Thu, 12 Jan 2012 10:17:21 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm: memcg: per-memcg reclaim statistics
Message-ID: <20120112091721.GH24386@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
 <1326207772-16762-2-git-send-email-hannes@cmpxchg.org>
 <CALWz4izbTw4+7zbfiED9Lx=6RwiqxE11g5-fNRHTh=mcP=vQ2Q@mail.gmail.com>
 <20120111003020.GD24386@cmpxchg.org>
 <CALWz4iy4hw9jQ++w4oiZG_hih-x9iieuEmnRBfxYKriAKSoOgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iy4hw9jQ++w4oiZG_hih-x9iieuEmnRBfxYKriAKSoOgw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 11, 2012 at 02:33:59PM -0800, Ying Han wrote:
> On Tue, Jan 10, 2012 at 4:30 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Tue, Jan 10, 2012 at 03:54:05PM -0800, Ying Han wrote:
> >> Thank you for the patch and the stats looks reasonable to me, few
> >> questions as below:
> >>
> >> On Tue, Jan 10, 2012 at 7:02 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >> > With the single per-zone LRU gone and global reclaim scanning
> >> > individual memcgs, it's straight-forward to collect meaningful and
> >> > accurate per-memcg reclaim statistics.
> >> >
> >> > This adds the following items to memory.stat:
> >>
> >> Some of the previous discussions including patches have similar stats
> >> in memory.vmscan_stat API, which collects all the per-memcg vmscan
> >> stats. I would like to understand more why we add into memory.stat
> >> instead, and do we have plan to keep extending memory.stat for those
> >> vmstat like stats?
> >
> > I think they were put into an extra file in particular to be able to
> > write to this file to reset the statistics.  But in my opinion, it's
> > trivial to calculate a delta from before and after running a workload,
> > so I didn't really like adding kernel code for that.
> >
> > Did you have another reason for a separate file in mind?
> 
> Another reason I had them in separate file is easier to extend. I
> don't know if we have plan to have something like memory.vmstat, or
> just keep adding stuff into memory.stat. In general, I wanted to keep
> the memory.stat being reasonable size including only the basic
> statistics. In my existing vmscan_stat path, i have breakdowns of
> reclaim stats into file/anon which will make the memory.stat even
> larger.

Do you think it's a problem of presentation, where we want to allow
admins to figure out the memcg parameters at a glance when looking at
memory.stat but be able to debug malfunction by looking at the more
extensive vmstat file?

> >> > aReclaim activity from kswapd due to the memcg's own limit. aOnly
> >> > aapplicable to the root memcg for now since kswapd is only triggered
> >> > aby physical limits, but kswapd-style reclaim based on memcg hard
> >> > alimits is being developped.
> >> >
> >> > hierarchy_pgreclaim
> >> > hierarchy_pgscan
> >> > hierarchy_kswapd_pgreclaim
> >> > hierarchy_kswapd_pgscan
> >>
> >> "pgsteal_hierarchy"
> >> "pgsteal_kswapd_hierarchy"
> >> ..
> >>
> >> No strong option on the naming, but try to make it more consistent to
> >> existing API.
> >
> > I swear I tried, but the existing naming is pretty screwed up :(
> >
> > For example, pgscan_direct_* and pgscan_kswapd_* allow you to compare
> > scan rates of direct reclaim vs. kswapd reclaim.  To get the total
> > number of pages reclaimed, you sum them up.
> >
> > On the other hand, pgsteal_* does not differentiate between direct
> > reclaim and kswapd, so to get direct reclaim numbers, you add up the
> > pgsteal_* counters and subtract kswapd_steal (notice the lack of pg?),
> > which is in turn not available at zone granularity.
> 
> agree and that always confuses me.

I just have scripts that present it as 'Direct page reclaimed' and
'Kswapd page reclaimed' when evaluating data so I don't have to
remember anymore :-)

But I think the wish for consistency is a bit misguided when we end up
with something like pgpgin that means something completely different
in memcg than it does on the global level.  Likewise, I don't want to
use pgsteal_* and pgsteal_kswapd_* because of their similarity to
/proc/vmstat while the numbers represent something different.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
