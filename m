Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id D5C216B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 16:31:17 -0500 (EST)
Received: by qadb10 with SMTP id b10so26611qad.14
        for <linux-mm@kvack.org>; Fri, 13 Jan 2012 13:31:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120112085904.GG24386@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
	<1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
	<CALWz4izwNBN_qcSsqg-qYw-Esc9vBL3=4cv3Wsg1jf6001_fWQ@mail.gmail.com>
	<20120112085904.GG24386@cmpxchg.org>
Date: Fri, 13 Jan 2012 13:31:16 -0800
Message-ID: <CALWz4iz3sQX+pCr19rE3_SwV+pRFhDJ7Lq-uJuYBq6u3mRU3AQ@mail.gmail.com>
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 12, 2012 at 12:59 AM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> On Wed, Jan 11, 2012 at 01:42:31PM -0800, Ying Han wrote:
>> On Tue, Jan 10, 2012 at 7:02 AM, Johannes Weiner <hannes@cmpxchg.org> wr=
ote:
>> > Right now, memcg soft limits are implemented by having a sorted tree
>> > of memcgs that are in excess of their limits. =A0Under global memory
>> > pressure, kswapd first reclaims from the biggest excessor and then
>> > proceeds to do regular global reclaim. =A0The result of this is that
>> > pages are reclaimed from all memcgs, but more scanning happens against
>> > those above their soft limit.
>> >
>> > With global reclaim doing memcg-aware hierarchical reclaim by default,
>> > this is a lot easier to implement: everytime a memcg is reclaimed
>> > from, scan more aggressively (per tradition with a priority of 0) if
>> > it's above its soft limit. =A0With the same end result of scanning
>> > everybody, but soft limit excessors a bit more.
>> >
>> > Advantages:
>> >
>> > =A0o smoother reclaim: soft limit reclaim is a separate stage before
>> > =A0 =A0global reclaim, whose result is not communicated down the line =
and
>> > =A0 =A0so overreclaim of the groups in excess is very likely. =A0After=
 this
>> > =A0 =A0patch, soft limit reclaim is fully integrated into regular recl=
aim
>> > =A0 =A0and each memcg is considered exactly once per cycle.
>> >
>> > =A0o true hierarchy support: soft limits are only considered when
>> > =A0 =A0kswapd does global reclaim, but after this patch, targetted
>> > =A0 =A0reclaim of a memcg will mind the soft limit settings of its chi=
ld
>> > =A0 =A0groups.
>>
>> Why we add soft limit reclaim into target reclaim?
>
> =A0 =A0 =A0 =A0-> A hard limit 10G, usage 10G
> =A0 =A0 =A0 =A0 =A0 -> A1 soft limit 8G, usage 5G
> =A0 =A0 =A0 =A0 =A0 -> A2 soft limit 2G, usage 5G
>
> When A hits its hard limit, A2 will experience more pressure than A1.
>
> Soft limits are already applied hierarchically: the memcg that is
> picked from the tree is reclaimed hierarchically. =A0What I wanted to
> add is the soft limit also being /triggerable/ from non-global
> hierarchy levels.
>
>> Based on the discussions, my understanding is that the soft limit only
>> take effect while the whole machine is under memory contention. We
>> don't want to add extra pressure on a cgroup if there is free memory
>> on the system even the cgroup is above its limit.
>
> If a hierarchy is under pressure, we will reclaim that hierarchy. =A0We
> allow groups to be prioritized under global pressure, why not allow it
> for local pressure as well?
>
> I am not quite sure what you are objecting to.

>
>> > =A0o code size: soft limit reclaim requires a lot of code to maintain
>> > =A0 =A0the per-node per-zone rb-trees to quickly find the biggest
>> > =A0 =A0offender, dedicated paths for soft limit reclaim etc. while thi=
s
>> > =A0 =A0new implementation gets away without all that.
>> >
>> > Test:
>> >
>> > The test consists of two concurrent kernel build jobs in separate
>> > source trees, the master and the slave. =A0The two jobs get along nice=
ly
>> > on 600MB of available memory, so this is the zero overcommit control
>> > case. =A0When available memory is decreased, the overcommit is
>> > compensated by decreasing the soft limit of the slave by the same
>> > amount, in the hope that the slave takes the hit and the master stays
>> > unaffected.
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0600M-0M-vanilla =A0 =A0 =A0 =A0 600M-0M-patched
>> > Master walltime (s) =A0 =A0 =A0 =A0 =A0 =A0 =A0 552.65 ( =A0+0.00%) =
=A0 =A0 =A0 552.38 ( =A0-0.05%)
>> > Master walltime (stddev) =A0 =A0 =A0 =A0 =A0 =A01.25 ( =A0+0.00%) =A0 =
=A0 =A0 =A0 0.92 ( -14.66%)
>> > Master major faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 204.38 ( =A0+0.00%) =
=A0 =A0 =A0 205.38 ( =A0+0.49%)
>> > Master major faults (stddev) =A0 =A0 =A0 27.16 ( =A0+0.00%) =A0 =A0 =
=A0 =A013.80 ( -47.43%)
>> > Master reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 31.88 ( =A0+0.0=
0%) =A0 =A0 =A0 =A037.75 ( +17.87%)
>> > Master reclaim (stddev) =A0 =A0 =A0 =A0 =A0 =A034.01 ( =A0+0.00%) =A0 =
=A0 =A0 =A075.88 (+119.59%)
>> > Master scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A031.88 ( =A0=
+0.00%) =A0 =A0 =A0 =A037.75 ( +17.87%)
>> > Master scan (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0 34.01 ( =A0+0.00%) =
=A0 =A0 =A0 =A075.88 (+119.59%)
>> > Master kswapd reclaim =A0 =A0 =A0 =A0 =A0 33922.12 ( =A0+0.00%) =A0 =
=A0 33887.12 ( =A0-0.10%)
>> > Master kswapd reclaim (stddev) =A0 =A0969.08 ( =A0+0.00%) =A0 =A0 =A0 =
492.22 ( -49.16%)
>> > Master kswapd scan =A0 =A0 =A0 =A0 =A0 =A0 =A034085.75 ( =A0+0.00%) =
=A0 =A0 33985.75 ( =A0-0.29%)
>> > Master kswapd scan (stddev) =A0 =A0 =A01101.07 ( =A0+0.00%) =A0 =A0 =
=A0 563.33 ( -48.79%)
>> > Slave walltime (s) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0552.68 ( =A0+0.00%) =
=A0 =A0 =A0 552.12 ( =A0-0.10%)
>> > Slave walltime (stddev) =A0 =A0 =A0 =A0 =A0 =A0 0.79 ( =A0+0.00%) =A0 =
=A0 =A0 =A0 1.05 ( +14.76%)
>> > Slave major faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0212.50 ( =A0+0.00%) =
=A0 =A0 =A0 204.50 ( =A0-3.75%)
>> > Slave major faults (stddev) =A0 =A0 =A0 =A026.90 ( =A0+0.00%) =A0 =A0 =
=A0 =A013.17 ( -49.20%)
>> > Slave reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A026.12 ( =A0+0=
.00%) =A0 =A0 =A0 =A035.00 ( +32.72%)
>> > Slave reclaim (stddev) =A0 =A0 =A0 =A0 =A0 =A0 29.42 ( =A0+0.00%) =A0 =
=A0 =A0 =A074.91 (+149.55%)
>> > Slave scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 31.38 ( =A0=
+0.00%) =A0 =A0 =A0 =A035.00 ( +11.20%)
>> > Slave scan (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A033.31 ( =A0+0.00%) =
=A0 =A0 =A0 =A074.91 (+121.24%)
>> > Slave kswapd reclaim =A0 =A0 =A0 =A0 =A0 =A034259.00 ( =A0+0.00%) =A0 =
=A0 33469.88 ( =A0-2.30%)
>> > Slave kswapd reclaim (stddev) =A0 =A0 925.15 ( =A0+0.00%) =A0 =A0 =A0 =
565.07 ( -38.88%)
>> > Slave kswapd scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 34354.62 ( =A0+0.00%) =
=A0 =A0 33555.75 ( =A0-2.33%)
>> > Slave kswapd scan (stddev) =A0 =A0 =A0 =A0969.62 ( =A0+0.00%) =A0 =A0 =
=A0 581.70 ( -39.97%)
>> >
>> > In the control case, the differences in elapsed time, number of major
>> > faults taken, and reclaim statistics are within the noise for both the
>> > master and the slave job.
>>
>> What's the soft limit setting in the controlled case?
>
> 300MB for both jobs.
>
>> I assume it is the default RESOURCE_MAX. So both Master and Slave get
>> equal pressure before/after the patch, and no differences on the stats
>> should be observed.
>
> Yes. =A0The control case demonstrates that both jobs can fit
> comfortably, don't compete for space and that in general the patch
> does not have unexpected negative impact (after all, it modifies
> codepaths that were invoked regularly outside of reclaim).
>
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 600M-280M-vanilla =A0 =A0 =A0600M-280M-patched
>> > Master walltime (s) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0595.13 ( =A0+0.=
00%) =A0 =A0 =A0553.19 ( =A0-7.04%)
>> > Master walltime (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0 8.31 ( =A0+0.00%)=
 =A0 =A0 =A0 =A02.57 ( -61.64%)
>> > Master major faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3729.75 ( =A0+0.00=
%) =A0 =A0 =A0783.25 ( -78.98%)
>> > Master major faults (stddev) =A0 =A0 =A0 =A0 258.79 ( =A0+0.00%) =A0 =
=A0 =A0226.68 ( -12.36%)
>> > Master reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 705.00 ( =
=A0+0.00%) =A0 =A0 =A0 29.50 ( -95.68%)
>> > Master reclaim (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0232.87 ( =A0+0.00%)=
 =A0 =A0 =A0 44.72 ( -80.45%)
>> > Master scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0714.88 =
( =A0+0.00%) =A0 =A0 =A0 30.00 ( -95.67%)
>> > Master scan (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 237.44 ( =A0+0.00=
%) =A0 =A0 =A0 45.39 ( -80.54%)
>> > Master kswapd reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0114.75 ( =A0+0.00=
%) =A0 =A0 =A0 50.00 ( -55.94%)
>> > Master kswapd reclaim (stddev) =A0 =A0 =A0 128.51 ( =A0+0.00%) =A0 =A0=
 =A0 =A09.45 ( -91.93%)
>> > Master kswapd scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 115.75 ( =A0+0.=
00%) =A0 =A0 =A0 50.00 ( -56.32%)
>> > Master kswapd scan (stddev) =A0 =A0 =A0 =A0 =A0130.31 ( =A0+0.00%) =A0=
 =A0 =A0 =A09.45 ( -92.04%)
>> > Slave walltime (s) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 631.18 ( =A0+0.=
00%) =A0 =A0 =A0577.68 ( =A0-8.46%)
>> > Slave walltime (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A09.89 ( =A0+0.00=
%) =A0 =A0 =A0 =A03.63 ( -57.47%)
>> > Slave major faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 28401.75 ( =A0+0.00=
%) =A0 =A014656.75 ( -48.39%)
>> > Slave major faults (stddev) =A0 =A0 =A0 =A0 2629.97 ( =A0+0.00%) =A0 =
=A0 1911.81 ( -27.30%)
>> > Slave reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A065400.62 ( =
=A0+0.00%) =A0 =A0 1479.62 ( -97.74%)
>> > Slave reclaim (stddev) =A0 =A0 =A0 =A0 =A0 =A0 11623.02 ( =A0+0.00%) =
=A0 =A0 1482.13 ( -87.24%)
>> > Slave scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 9050047.88 ( =
=A0+0.00%) =A0 =A095968.25 ( -98.94%)
>> > Slave scan (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A01912786.94 ( =A0+0.00%)=
 =A0 =A093390.71 ( -95.12%)
>> > Slave kswapd reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0327894.50 ( =A0+0.00%)=
 =A0 227099.88 ( -30.74%)
>> > Slave kswapd reclaim (stddev) =A0 =A0 =A022289.43 ( =A0+0.00%) =A0 =A0=
16113.14 ( -27.71%)
>> > Slave kswapd scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 34987335.75 ( =A0+0.00%)=
 =A01362367.12 ( -96.11%)
>> > Slave kswapd scan (stddev) =A0 =A0 =A0 2523642.98 ( =A0+0.00%) =A0 156=
754.74 ( -93.79%)
>> >
>> > Here, the available memory is limited to 320 MB, the machine is
>> > overcommitted by 280 MB. =A0The soft limit of the master is 300 MB, th=
at
>> > of the slave merely 20 MB.
>> >
>> > Looking at the slave job first, it is much better off with the patched
>> > kernel: direct reclaim is almost gone, kswapd reclaim is decreased by
>> > a third. =A0The result is much fewer major faults taken, which in turn
>> > lets the job finish quicker.
>>
>> What's the setting of the hard limit here? Is the direct reclaim
>> referring to per-memcg directly reclaim or global one.
>
> The machine's memory is limited to 600M, the hard limits are unset.
> All reclaim is a result of global memory pressure.
>
> With the patched kernel, I could have used a dedicated parent cgroup
> and let master and slave run in children of this group, the soft
> limits would be taken into account just the same. =A0But this does not
> work on the unpatched kernel, as soft limits are only recognized on
> the global level there.
>
>> > It would be a zero-sum game if the improvement happened at the cost of
>> > the master but looking at the numbers, even the master performs better
>> > with the patched kernel. =A0In fact, the master job is almost unaffect=
ed
>> > on the patched kernel compared to the control case.
>>
>> It makes sense since the master job get less affected by the patch
>> than the slave job under the example. Under the control case, if both
>> master and slave have RESOURCE_MAX soft limit setting, they are under
>> equal memory pressure(priority =3D DEF_PRIORITY) . On the second
>> example, only the slave pressure being increased by priority =3D 0, and
>> the Master got scanned with same priority =3D DEF_PRIORITY pretty much.
>>
>> So I would expect to see more reclaim activities happens in slave on
>> the patched kernel compared to the control case. It seems match the
>> testing result.
>
> Uhm,
>
>> > Slave reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A065400.62 ( =
=A0+0.00%) =A0 =A0 1479.62 ( -97.74%)
>> > Slave reclaim (stddev) =A0 =A0 =A0 =A0 =A0 =A0 11623.02 ( =A0+0.00%) =
=A0 =A0 1482.13 ( -87.24%)
>> > Slave scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 9050047.88 ( =
=A0+0.00%) =A0 =A095968.25 ( -98.94%)
>> > Slave scan (stddev) =A0 =A0 =A0 =A0 =A0 =A0 =A01912786.94 ( =A0+0.00%)=
 =A0 =A093390.71 ( -95.12%)
>> > Slave kswapd reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0327894.50 ( =A0+0.00%)=
 =A0 227099.88 ( -30.74%)
>> > Slave kswapd reclaim (stddev) =A0 =A0 =A022289.43 ( =A0+0.00%) =A0 =A0=
16113.14 ( -27.71%)
>> > Slave kswapd scan =A0 =A0 =A0 =A0 =A0 =A0 =A0 34987335.75 ( =A0+0.00%)=
 =A01362367.12 ( -96.11%)
>> > Slave kswapd scan (stddev) =A0 =A0 =A0 2523642.98 ( =A0+0.00%) =A0 156=
754.74 ( -93.79%)
>
> Direct reclaim _shrunk_ by 98%, kswapd reclaim by 31%.
>
>> > This is an odd phenomenon, as the patch does not directly change how
>> > the master is reclaimed. =A0An explanation for this is that the severe
>> > overreclaim of the slave in the unpatched kernel results in the master
>> > growing bigger than in the patched case. =A0Combining the fact that
>> > memcgs are scanned according to their size with the increased refault
>> > rate of the overreclaimed slave triggering global reclaim more often
>> > means that overall pressure on the master job is higher in the
>> > unpatched kernel.
>>
>> We can check the Master memory.usage_in_bytes while the job is running.
>
> Yep, the plots of cache/rss over time confirmed exactly this. =A0The
> unpatched kernel shows higher spikes in the size of the master job
> followed by deeper pits when reclaim kicked in. =A0The patched kernel is
> much smoother in that regard.
>
>> On the other hand, I don't see why we expect the Master being less
>> reclaimed in the controlled case? On the unpatched kernel, the Master
>> is being reclaimed under global pressure each time anyway since we
>> ignore the return value of softlimit.
>
> I didn't expect that, I expected both jobs to perform equally in the
> control case. =A0And in the pressurized case, the master being
> unaffected and the slave taking the hit. =A0The patched kernel does
> this, the unpatched one does not.
>
>> > @@ -121,6 +121,7 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_s=
tat(struct mem_cgroup *memcg,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone *zone);
>> > =A0struct zone_reclaim_stat*
>> > =A0mem_cgroup_get_reclaim_stat_from_page(struct page *page);
>> > +bool mem_cgroup_over_softlimit(struct mem_cgroup *, struct mem_cgroup=
 *);
>>
>> Maybe something like "mem_cgroup_over_soft_limit()" ?
>
> Probably more consistent, yeah. =A0Will do.
>
>> > @@ -343,7 +314,6 @@ static bool move_file(void)
>> > =A0* limit reclaim to prevent infinite loops, if they ever occur.
>> > =A0*/
>> > =A0#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_RECLAIM_LOOPS =A0 =A0 =A0 =A0=
 =A0 =A0(100)
>> > -#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS (2)
>>
>> You might need to remove the comment above as well.
>
> Oops, will fix.
>
>> > @@ -1318,6 +1123,36 @@ static unsigned long mem_cgroup_margin(struct m=
em_cgroup *memcg)
>> > =A0 =A0 =A0 =A0return margin >> PAGE_SHIFT;
>> > =A0}
>> >
>> > +/**
>> > + * mem_cgroup_over_softlimit
>> > + * @root: hierarchy root
>> > + * @memcg: child of @root to test
>> > + *
>> > + * Returns %true if @memcg exceeds its own soft limit or contributes
>> > + * to the soft limit excess of one of its parents up to and including
>> > + * @root.
>> > + */
>> > +bool mem_cgroup_over_softlimit(struct mem_cgroup *root,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct me=
m_cgroup *memcg)
>> > +{
>> > + =A0 =A0 =A0 if (mem_cgroup_disabled())
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
>> > +
>> > + =A0 =A0 =A0 if (!root)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 root =3D root_mem_cgroup;
>> > +
>> > + =A0 =A0 =A0 for (; memcg; memcg =3D parent_mem_cgroup(memcg)) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* root_mem_cgroup does not have a soft =
limit */
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memcg =3D=3D root_mem_cgroup)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (res_counter_soft_limit_excess(&memcg=
->res))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memcg =3D=3D root)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> > + =A0 =A0 =A0 }
>>
>> Here it adds pressure on a cgroup if one of its parents exceeds soft
>> limit, although the cgroup itself is under soft limit. It does change
>> my understanding of soft limit, and might introduce regression of our
>> existing use cases.
>>
>> Here is an example:
>>
>> Machine capacity 32G and we over-commit by 8G.
>>
>> root
>> =A0 -> A (hard limit 20G, soft limit 15G, usage 16G)
>> =A0 =A0 =A0 =A0-> A1 (soft limit 5G, usage 4G)
>> =A0 =A0 =A0 =A0-> A2 (soft limit 10G, usage 12G)
>> =A0 -> B (hard limit 20G, soft limit 10G, usage 16G)
>>
>> under global reclaim, we don't want to add pressure on A1 although its
>> parent A exceeds its soft limit. Assume that if we set the soft limit
>> corresponding to each cgroup's working set size (hot memory), and it
>> will introduce regression to A1 in that case.
>>
>> In my existing implementation, i am checking the cgroup's soft limit
>> standalone w/o looking its ancestors.
>
> Why do you set the soft limit of A in the first place if you don't
> want it to be enforced?

The soft limit should be enforced under certain condition, not always.
The soft limit of A is set to be enforced when the parent of A and B
is under memory pressure. For example:

Machine capacity 32G and we over-commit by 8G

root
-> A (hard limit 20G, soft limit 12G, usage 20G)
=A0 =A0 =A0 =A0-> A1 (soft limit 2G, usage 1G)
=A0 =A0 =A0 =A0-> A2 (soft limit 10G, usage 19G)
-> B (hard limit 20G, soft limit 10G, usage 0G)

Now, A is under memory pressure since the total usage is hitting its
hard limit. Then we start hierarchical reclaim under A, and each
cgroup under A also takes consideration of soft limit. In this case,
we should only set priority =3D 0 to A2 since it contributes to A's
charge as well as exceeding its own soft limit. Why punishing A1 (set
priority =3D 0) also which has usage under its soft limit ? I can
imagine it will introduce regression to existing environment which the
soft limit is set based on the working set size of the cgroup.

To answer the question why we set soft limit to A, it is used to
over-commit the host while sharing the resource with its sibling (B in
this case). If the machine is under memory contention, we would like
to push down memory to A or B depends on their usage and soft limit.

--Ying

>
> This is not really new behaviour, soft limit reclaim has always been
> operating hierarchically on the biggest excessor. =A0In your case, the
> excess of A is smaller than the excess of A2 and so that weird "only
> pick the biggest excessor" behaviour hides it, but consider this:
>
> =A0 =A0 =A0 =A0-> A soft 30G, usage 39G
> =A0 =A0 =A0 =A0 =A0 -> A1 soft 5G, usage 4G
> =A0 =A0 =A0 =A0 =A0 -> A2 soft 10G, usage 15G
> =A0 =A0 =A0 =A0 =A0 -> A3 soft 15G, usage 20G
>
> Upstream would pick A from the soft limit tree and reclaim its
> children with priority 0, including A1.
>
> On the other hand, if you don't consider ancestral soft limits, you
> break perfectly reasonable setups like these
>
> =A0 =A0 =A0 =A0-> A soft 10G, usage 20G
> =A0 =A0 =A0 =A0 =A0 -> A1 usage 10G
> =A0 =A0 =A0 =A0 =A0 -> A2 usage 10G
> =A0 =A0 =A0 =A0-> B soft 10G, usage 11G
>
> where upstream would pick A and reclaim it recursively, but your
> version would only apply higher pressure to B.
>
> If you would just not set the soft limit of A in your case:
>
> =A0 =A0 =A0 =A0-> A (hard limit 20G, usage 16G)
> =A0 =A0 =A0 =A0 =A0 -> A1 (soft limit 5G, usage 4G)
> =A0 =A0 =A0 =A0 =A0 -> A2 (soft limit 10G, usage 12G)
> =A0 =A0 =A0 =A0-> B (hard limit 20G, soft limit 10G, usage 16G)
>
> only A2 and B would experience higher pressure upon global pressure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
