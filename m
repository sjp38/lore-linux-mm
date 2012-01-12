Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 0BC046B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 03:59:19 -0500 (EST)
Date: Thu, 12 Jan 2012 09:59:04 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
Message-ID: <20120112085904.GG24386@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
 <1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
 <CALWz4izwNBN_qcSsqg-qYw-Esc9vBL3=4cv3Wsg1jf6001_fWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4izwNBN_qcSsqg-qYw-Esc9vBL3=4cv3Wsg1jf6001_fWQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 11, 2012 at 01:42:31PM -0800, Ying Han wrote:
> On Tue, Jan 10, 2012 at 7:02 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > Right now, memcg soft limits are implemented by having a sorted tree
> > of memcgs that are in excess of their limits.  Under global memory
> > pressure, kswapd first reclaims from the biggest excessor and then
> > proceeds to do regular global reclaim.  The result of this is that
> > pages are reclaimed from all memcgs, but more scanning happens against
> > those above their soft limit.
> >
> > With global reclaim doing memcg-aware hierarchical reclaim by default,
> > this is a lot easier to implement: everytime a memcg is reclaimed
> > from, scan more aggressively (per tradition with a priority of 0) if
> > it's above its soft limit.  With the same end result of scanning
> > everybody, but soft limit excessors a bit more.
> >
> > Advantages:
> >
> >  o smoother reclaim: soft limit reclaim is a separate stage before
> >    global reclaim, whose result is not communicated down the line and
> >    so overreclaim of the groups in excess is very likely.  After this
> >    patch, soft limit reclaim is fully integrated into regular reclaim
> >    and each memcg is considered exactly once per cycle.
> >
> >  o true hierarchy support: soft limits are only considered when
> >    kswapd does global reclaim, but after this patch, targetted
> >    reclaim of a memcg will mind the soft limit settings of its child
> >    groups.
> 
> Why we add soft limit reclaim into target reclaim?

	-> A hard limit 10G, usage 10G
	   -> A1 soft limit 8G, usage 5G
	   -> A2 soft limit 2G, usage 5G

When A hits its hard limit, A2 will experience more pressure than A1.

Soft limits are already applied hierarchically: the memcg that is
picked from the tree is reclaimed hierarchically.  What I wanted to
add is the soft limit also being /triggerable/ from non-global
hierarchy levels.

> Based on the discussions, my understanding is that the soft limit only
> take effect while the whole machine is under memory contention. We
> don't want to add extra pressure on a cgroup if there is free memory
> on the system even the cgroup is above its limit.

If a hierarchy is under pressure, we will reclaim that hierarchy.  We
allow groups to be prioritized under global pressure, why not allow it
for local pressure as well?

I am not quite sure what you are objecting to.

> >  o code size: soft limit reclaim requires a lot of code to maintain
> >    the per-node per-zone rb-trees to quickly find the biggest
> >    offender, dedicated paths for soft limit reclaim etc. while this
> >    new implementation gets away without all that.
> >
> > Test:
> >
> > The test consists of two concurrent kernel build jobs in separate
> > source trees, the master and the slave.  The two jobs get along nicely
> > on 600MB of available memory, so this is the zero overcommit control
> > case.  When available memory is decreased, the overcommit is
> > compensated by decreasing the soft limit of the slave by the same
> > amount, in the hope that the slave takes the hit and the master stays
> > unaffected.
> >
> >                                    600M-0M-vanilla         600M-0M-patched
> > Master walltime (s)               552.65 (  +0.00%)       552.38 (  -0.05%)
> > Master walltime (stddev)            1.25 (  +0.00%)         0.92 ( -14.66%)
> > Master major faults               204.38 (  +0.00%)       205.38 (  +0.49%)
> > Master major faults (stddev)       27.16 (  +0.00%)        13.80 ( -47.43%)
> > Master reclaim                     31.88 (  +0.00%)        37.75 ( +17.87%)
> > Master reclaim (stddev)            34.01 (  +0.00%)        75.88 (+119.59%)
> > Master scan                        31.88 (  +0.00%)        37.75 ( +17.87%)
> > Master scan (stddev)               34.01 (  +0.00%)        75.88 (+119.59%)
> > Master kswapd reclaim           33922.12 (  +0.00%)     33887.12 (  -0.10%)
> > Master kswapd reclaim (stddev)    969.08 (  +0.00%)       492.22 ( -49.16%)
> > Master kswapd scan              34085.75 (  +0.00%)     33985.75 (  -0.29%)
> > Master kswapd scan (stddev)      1101.07 (  +0.00%)       563.33 ( -48.79%)
> > Slave walltime (s)                552.68 (  +0.00%)       552.12 (  -0.10%)
> > Slave walltime (stddev)             0.79 (  +0.00%)         1.05 ( +14.76%)
> > Slave major faults                212.50 (  +0.00%)       204.50 (  -3.75%)
> > Slave major faults (stddev)        26.90 (  +0.00%)        13.17 ( -49.20%)
> > Slave reclaim                      26.12 (  +0.00%)        35.00 ( +32.72%)
> > Slave reclaim (stddev)             29.42 (  +0.00%)        74.91 (+149.55%)
> > Slave scan                         31.38 (  +0.00%)        35.00 ( +11.20%)
> > Slave scan (stddev)                33.31 (  +0.00%)        74.91 (+121.24%)
> > Slave kswapd reclaim            34259.00 (  +0.00%)     33469.88 (  -2.30%)
> > Slave kswapd reclaim (stddev)     925.15 (  +0.00%)       565.07 ( -38.88%)
> > Slave kswapd scan               34354.62 (  +0.00%)     33555.75 (  -2.33%)
> > Slave kswapd scan (stddev)        969.62 (  +0.00%)       581.70 ( -39.97%)
> >
> > In the control case, the differences in elapsed time, number of major
> > faults taken, and reclaim statistics are within the noise for both the
> > master and the slave job.
> 
> What's the soft limit setting in the controlled case?

300MB for both jobs.

> I assume it is the default RESOURCE_MAX. So both Master and Slave get
> equal pressure before/after the patch, and no differences on the stats
> should be observed.

Yes.  The control case demonstrates that both jobs can fit
comfortably, don't compete for space and that in general the patch
does not have unexpected negative impact (after all, it modifies
codepaths that were invoked regularly outside of reclaim).

> >                                     600M-280M-vanilla      600M-280M-patched
> > Master walltime (s)                  595.13 (  +0.00%)      553.19 (  -7.04%)
> > Master walltime (stddev)               8.31 (  +0.00%)        2.57 ( -61.64%)
> > Master major faults                 3729.75 (  +0.00%)      783.25 ( -78.98%)
> > Master major faults (stddev)         258.79 (  +0.00%)      226.68 ( -12.36%)
> > Master reclaim                       705.00 (  +0.00%)       29.50 ( -95.68%)
> > Master reclaim (stddev)              232.87 (  +0.00%)       44.72 ( -80.45%)
> > Master scan                          714.88 (  +0.00%)       30.00 ( -95.67%)
> > Master scan (stddev)                 237.44 (  +0.00%)       45.39 ( -80.54%)
> > Master kswapd reclaim                114.75 (  +0.00%)       50.00 ( -55.94%)
> > Master kswapd reclaim (stddev)       128.51 (  +0.00%)        9.45 ( -91.93%)
> > Master kswapd scan                   115.75 (  +0.00%)       50.00 ( -56.32%)
> > Master kswapd scan (stddev)          130.31 (  +0.00%)        9.45 ( -92.04%)
> > Slave walltime (s)                   631.18 (  +0.00%)      577.68 (  -8.46%)
> > Slave walltime (stddev)                9.89 (  +0.00%)        3.63 ( -57.47%)
> > Slave major faults                 28401.75 (  +0.00%)    14656.75 ( -48.39%)
> > Slave major faults (stddev)         2629.97 (  +0.00%)     1911.81 ( -27.30%)
> > Slave reclaim                      65400.62 (  +0.00%)     1479.62 ( -97.74%)
> > Slave reclaim (stddev)             11623.02 (  +0.00%)     1482.13 ( -87.24%)
> > Slave scan                       9050047.88 (  +0.00%)    95968.25 ( -98.94%)
> > Slave scan (stddev)              1912786.94 (  +0.00%)    93390.71 ( -95.12%)
> > Slave kswapd reclaim              327894.50 (  +0.00%)   227099.88 ( -30.74%)
> > Slave kswapd reclaim (stddev)      22289.43 (  +0.00%)    16113.14 ( -27.71%)
> > Slave kswapd scan               34987335.75 (  +0.00%)  1362367.12 ( -96.11%)
> > Slave kswapd scan (stddev)       2523642.98 (  +0.00%)   156754.74 ( -93.79%)
> >
> > Here, the available memory is limited to 320 MB, the machine is
> > overcommitted by 280 MB.  The soft limit of the master is 300 MB, that
> > of the slave merely 20 MB.
> >
> > Looking at the slave job first, it is much better off with the patched
> > kernel: direct reclaim is almost gone, kswapd reclaim is decreased by
> > a third.  The result is much fewer major faults taken, which in turn
> > lets the job finish quicker.
> 
> What's the setting of the hard limit here? Is the direct reclaim
> referring to per-memcg directly reclaim or global one.

The machine's memory is limited to 600M, the hard limits are unset.
All reclaim is a result of global memory pressure.

With the patched kernel, I could have used a dedicated parent cgroup
and let master and slave run in children of this group, the soft
limits would be taken into account just the same.  But this does not
work on the unpatched kernel, as soft limits are only recognized on
the global level there.

> > It would be a zero-sum game if the improvement happened at the cost of
> > the master but looking at the numbers, even the master performs better
> > with the patched kernel.  In fact, the master job is almost unaffected
> > on the patched kernel compared to the control case.
> 
> It makes sense since the master job get less affected by the patch
> than the slave job under the example. Under the control case, if both
> master and slave have RESOURCE_MAX soft limit setting, they are under
> equal memory pressure(priority = DEF_PRIORITY) . On the second
> example, only the slave pressure being increased by priority = 0, and
> the Master got scanned with same priority = DEF_PRIORITY pretty much.
> 
> So I would expect to see more reclaim activities happens in slave on
> the patched kernel compared to the control case. It seems match the
> testing result.

Uhm,

> > Slave reclaim                      65400.62 (  +0.00%)     1479.62 ( -97.74%)
> > Slave reclaim (stddev)             11623.02 (  +0.00%)     1482.13 ( -87.24%)
> > Slave scan                       9050047.88 (  +0.00%)    95968.25 ( -98.94%)
> > Slave scan (stddev)              1912786.94 (  +0.00%)    93390.71 ( -95.12%)
> > Slave kswapd reclaim              327894.50 (  +0.00%)   227099.88 ( -30.74%)
> > Slave kswapd reclaim (stddev)      22289.43 (  +0.00%)    16113.14 ( -27.71%)
> > Slave kswapd scan               34987335.75 (  +0.00%)  1362367.12 ( -96.11%)
> > Slave kswapd scan (stddev)       2523642.98 (  +0.00%)   156754.74 ( -93.79%)

Direct reclaim _shrunk_ by 98%, kswapd reclaim by 31%.

> > This is an odd phenomenon, as the patch does not directly change how
> > the master is reclaimed.  An explanation for this is that the severe
> > overreclaim of the slave in the unpatched kernel results in the master
> > growing bigger than in the patched case.  Combining the fact that
> > memcgs are scanned according to their size with the increased refault
> > rate of the overreclaimed slave triggering global reclaim more often
> > means that overall pressure on the master job is higher in the
> > unpatched kernel.
> 
> We can check the Master memory.usage_in_bytes while the job is running.

Yep, the plots of cache/rss over time confirmed exactly this.  The
unpatched kernel shows higher spikes in the size of the master job
followed by deeper pits when reclaim kicked in.  The patched kernel is
much smoother in that regard.

> On the other hand, I don't see why we expect the Master being less
> reclaimed in the controlled case? On the unpatched kernel, the Master
> is being reclaimed under global pressure each time anyway since we
> ignore the return value of softlimit.

I didn't expect that, I expected both jobs to perform equally in the
control case.  And in the pressurized case, the master being
unaffected and the slave taking the hit.  The patched kernel does
this, the unpatched one does not.

> > @@ -121,6 +121,7 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
> >                                                      struct zone *zone);
> >  struct zone_reclaim_stat*
> >  mem_cgroup_get_reclaim_stat_from_page(struct page *page);
> > +bool mem_cgroup_over_softlimit(struct mem_cgroup *, struct mem_cgroup *);
> 
> Maybe something like "mem_cgroup_over_soft_limit()" ?

Probably more consistent, yeah.  Will do.

> > @@ -343,7 +314,6 @@ static bool move_file(void)
> >  * limit reclaim to prevent infinite loops, if they ever occur.
> >  */
> >  #define        MEM_CGROUP_MAX_RECLAIM_LOOPS            (100)
> > -#define        MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS (2)
> 
> You might need to remove the comment above as well.

Oops, will fix.

> > @@ -1318,6 +1123,36 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
> >        return margin >> PAGE_SHIFT;
> >  }
> >
> > +/**
> > + * mem_cgroup_over_softlimit
> > + * @root: hierarchy root
> > + * @memcg: child of @root to test
> > + *
> > + * Returns %true if @memcg exceeds its own soft limit or contributes
> > + * to the soft limit excess of one of its parents up to and including
> > + * @root.
> > + */
> > +bool mem_cgroup_over_softlimit(struct mem_cgroup *root,
> > +                              struct mem_cgroup *memcg)
> > +{
> > +       if (mem_cgroup_disabled())
> > +               return false;
> > +
> > +       if (!root)
> > +               root = root_mem_cgroup;
> > +
> > +       for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> > +               /* root_mem_cgroup does not have a soft limit */
> > +               if (memcg == root_mem_cgroup)
> > +                       break;
> > +               if (res_counter_soft_limit_excess(&memcg->res))
> > +                       return true;
> > +               if (memcg == root)
> > +                       break;
> > +       }
> 
> Here it adds pressure on a cgroup if one of its parents exceeds soft
> limit, although the cgroup itself is under soft limit. It does change
> my understanding of soft limit, and might introduce regression of our
> existing use cases.
> 
> Here is an example:
> 
> Machine capacity 32G and we over-commit by 8G.
> 
> root
>   -> A (hard limit 20G, soft limit 15G, usage 16G)
>        -> A1 (soft limit 5G, usage 4G)
>        -> A2 (soft limit 10G, usage 12G)
>   -> B (hard limit 20G, soft limit 10G, usage 16G)
> 
> under global reclaim, we don't want to add pressure on A1 although its
> parent A exceeds its soft limit. Assume that if we set the soft limit
> corresponding to each cgroup's working set size (hot memory), and it
> will introduce regression to A1 in that case.
> 
> In my existing implementation, i am checking the cgroup's soft limit
> standalone w/o looking its ancestors.

Why do you set the soft limit of A in the first place if you don't
want it to be enforced?

This is not really new behaviour, soft limit reclaim has always been
operating hierarchically on the biggest excessor.  In your case, the
excess of A is smaller than the excess of A2 and so that weird "only
pick the biggest excessor" behaviour hides it, but consider this:

	-> A soft 30G, usage 39G
	   -> A1 soft 5G, usage 4G
	   -> A2 soft 10G, usage 15G
	   -> A3 soft 15G, usage 20G

Upstream would pick A from the soft limit tree and reclaim its
children with priority 0, including A1.

On the other hand, if you don't consider ancestral soft limits, you
break perfectly reasonable setups like these

	-> A soft 10G, usage 20G
	   -> A1 usage 10G
	   -> A2 usage 10G
	-> B soft 10G, usage 11G

where upstream would pick A and reclaim it recursively, but your
version would only apply higher pressure to B.

If you would just not set the soft limit of A in your case:

	-> A (hard limit 20G, usage 16G)
           -> A1 (soft limit 5G, usage 4G)
           -> A2 (soft limit 10G, usage 12G)
	-> B (hard limit 20G, soft limit 10G, usage 16G)

only A2 and B would experience higher pressure upon global pressure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
