Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id DF9086B005C
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 19:30:46 -0500 (EST)
Date: Wed, 11 Jan 2012 01:30:20 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm: memcg: per-memcg reclaim statistics
Message-ID: <20120111003020.GD24386@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
 <1326207772-16762-2-git-send-email-hannes@cmpxchg.org>
 <CALWz4izbTw4+7zbfiED9Lx=6RwiqxE11g5-fNRHTh=mcP=vQ2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4izbTw4+7zbfiED9Lx=6RwiqxE11g5-fNRHTh=mcP=vQ2Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 10, 2012 at 03:54:05PM -0800, Ying Han wrote:
> Thank you for the patch and the stats looks reasonable to me, few
> questions as below:
> 
> On Tue, Jan 10, 2012 at 7:02 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > With the single per-zone LRU gone and global reclaim scanning
> > individual memcgs, it's straight-forward to collect meaningful and
> > accurate per-memcg reclaim statistics.
> >
> > This adds the following items to memory.stat:
> 
> Some of the previous discussions including patches have similar stats
> in memory.vmscan_stat API, which collects all the per-memcg vmscan
> stats. I would like to understand more why we add into memory.stat
> instead, and do we have plan to keep extending memory.stat for those
> vmstat like stats?

I think they were put into an extra file in particular to be able to
write to this file to reset the statistics.  But in my opinion, it's
trivial to calculate a delta from before and after running a workload,
so I didn't really like adding kernel code for that.

Did you have another reason for a separate file in mind?

> > pgreclaim
> 
> Not sure if we want to keep this more consistent to /proc/vmstat, then
> it will be "pgsteal"?

The problem with that was that we didn't like to call pages stolen
when they were reclaimed from within the cgroup, so we had pgfree for
inner reclaim and pgsteal for outer reclaim, respectively.

I found it cleaner to just go with pgreclaim, it's unambiguous and
straight-forward.  Outer reclaim is designated by the hierarchy_
prefix.

> > pgscan
> >
> >  Number of pages reclaimed/scanned from that memcg due to its own
> >  hard limit (or physical limit in case of the root memcg) by the
> >  allocating task.
> >
> > kswapd_pgreclaim
> > kswapd_pgscan
> 
> we have "pgscan_kswapd_*" in vmstat, so maybe ?
> "pgsteal_kswapd"
> "pgscan_kswapd"
> 
> >  Reclaim activity from kswapd due to the memcg's own limit.  Only
> >  applicable to the root memcg for now since kswapd is only triggered
> >  by physical limits, but kswapd-style reclaim based on memcg hard
> >  limits is being developped.
> >
> > hierarchy_pgreclaim
> > hierarchy_pgscan
> > hierarchy_kswapd_pgreclaim
> > hierarchy_kswapd_pgscan
> 
> "pgsteal_hierarchy"
> "pgsteal_kswapd_hierarchy"
> ..
> 
> No strong option on the naming, but try to make it more consistent to
> existing API.

I swear I tried, but the existing naming is pretty screwed up :(

For example, pgscan_direct_* and pgscan_kswapd_* allow you to compare
scan rates of direct reclaim vs. kswapd reclaim.  To get the total
number of pages reclaimed, you sum them up.

On the other hand, pgsteal_* does not differentiate between direct
reclaim and kswapd, so to get direct reclaim numbers, you add up the
pgsteal_* counters and subtract kswapd_steal (notice the lack of pg?),
which is in turn not available at zone granularity.

> > +#define MEM_CGROUP_EVENTS_KSWAPD 2
> > +#define MEM_CGROUP_EVENTS_HIERARCHY 4

These two function as namespaces, that's why I put hierarchy_ and
kswapd_ at the beginning of the names.

Given that we have kswapd_steal, would you be okay with doing it like
this?  I mean, at least my naming conforms to ONE of the standards in
/proc/vmstat, right? ;-)

> > @@ -91,12 +91,23 @@ enum mem_cgroup_stat_index {
> >        MEM_CGROUP_STAT_NSTATS,
> >  };
> >
> > +#define MEM_CGROUP_EVENTS_KSWAPD 2
> > +#define MEM_CGROUP_EVENTS_HIERARCHY 4
> > +
> >  enum mem_cgroup_events_index {
> >        MEM_CGROUP_EVENTS_PGPGIN,       /* # of pages paged in */
> >        MEM_CGROUP_EVENTS_PGPGOUT,      /* # of pages paged out */
> >        MEM_CGROUP_EVENTS_COUNT,        /* # of pages paged in/out */
> >        MEM_CGROUP_EVENTS_PGFAULT,      /* # of page-faults */
> >        MEM_CGROUP_EVENTS_PGMAJFAULT,   /* # of major page-faults */
> > +       MEM_CGROUP_EVENTS_PGRECLAIM,
> > +       MEM_CGROUP_EVENTS_PGSCAN,
> > +       MEM_CGROUP_EVENTS_KSWAPD_PGRECLAIM,
> > +       MEM_CGROUP_EVENTS_KSWAPD_PGSCAN,
> > +       MEM_CGROUP_EVENTS_HIERARCHY_PGRECLAIM,
> > +       MEM_CGROUP_EVENTS_HIERARCHY_PGSCAN,
> > +       MEM_CGROUP_EVENTS_HIERARCHY_KSWAPD_PGRECLAIM,
> > +       MEM_CGROUP_EVENTS_HIERARCHY_KSWAPD_PGSCAN,
> 
> missing comment here?

As if the lines weren't long enough already ;-) I'll add some.

> >        MEM_CGROUP_EVENTS_NSTATS,
> >  };
> >  /*
> > @@ -889,6 +900,38 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
> >        return (memcg == root_mem_cgroup);
> >  }
> >
> > +/**
> > + * mem_cgroup_account_reclaim - update per-memcg reclaim statistics
> > + * @root: memcg that triggered reclaim
> > + * @memcg: memcg that is actually being scanned
> > + * @nr_reclaimed: number of pages reclaimed from @memcg
> > + * @nr_scanned: number of pages scanned from @memcg
> > + * @kswapd: whether reclaiming task is kswapd or allocator itself
> > + */
> > +void mem_cgroup_account_reclaim(struct mem_cgroup *root,
> > +                               struct mem_cgroup *memcg,
> > +                               unsigned long nr_reclaimed,
> > +                               unsigned long nr_scanned,
> > +                               bool kswapd)
> > +{
> > +       unsigned int offset = 0;
> > +
> > +       if (!root)
> > +               root = root_mem_cgroup;
> > +
> > +       if (kswapd)
> > +               offset += MEM_CGROUP_EVENTS_KSWAPD;
> > +       if (root != memcg)
> > +               offset += MEM_CGROUP_EVENTS_HIERARCHY;
> 
> Just to be clear, here root cgroup has hierarchy_* stats always 0 ?

That's correct, there can't be any hierarchical pressure on the
topmost parent.

> Also, we might want to consider renaming the root here, something like
> target? The root is confusing with root_mem_cgroup.

It's the same naming scheme I used for the iterator functions
(mem_cgroup_iter() and friends), so if we change it, I'd like to
change it consistently.

Having target and memcg as parameters is even more confusing and
non-descriptive, IMO.

Other places use mem_over_limit, which is a bit better, but quite
long.

Any other ideas for great names for parameters that designate a
hierarchy root and a memcg in that hierarchy?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
