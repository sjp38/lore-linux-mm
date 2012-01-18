Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id D666F6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:02:03 -0500 (EST)
Received: by wgbdr13 with SMTP id dr13so2287702wgb.26
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 06:02:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120118134053.GD31112@tiehlicka.suse.cz>
References: <CAJd=RBBdDriMhfetM2AWGzgxiJ1DDs-W4Ff9_1Z8DUgbyQmSkA@mail.gmail.com>
	<20120117131601.GB14907@tiehlicka.suse.cz>
	<CAJd=RBBcL5RuW1wC_Yh=gy2Ja8wqJ6jhf28zNi1n6MJ=+0=m2Q@mail.gmail.com>
	<20120117140712.GC14907@tiehlicka.suse.cz>
	<CAJd=RBAyqPwKERQL4JyCO38gjE=y8_qasHTbLtMGWqtZ1JFnUg@mail.gmail.com>
	<20120118134053.GD31112@tiehlicka.suse.cz>
Date: Wed, 18 Jan 2012 22:01:57 +0800
Message-ID: <CAJd=RBAs3_ic+0UbZ_Bn4tBp_t2-HuohcRrWD1d6M2oSYRNYmQ@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: remove checking reclaim order in soft limit reclaim
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>

On Wed, Jan 18, 2012 at 9:40 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Wed 18-01-12 20:30:41, Hillf Danton wrote:
>> On Tue, Jan 17, 2012 at 10:07 PM, Michal Hocko <mhocko@suse.cz> wrote:
>> > On Tue 17-01-12 21:29:52, Hillf Danton wrote:
>> >> On Tue, Jan 17, 2012 at 9:16 PM, Michal Hocko <mhocko@suse.cz> wrote:
>> >> > Hi,
>> >> >
>> >> > On Tue 17-01-12 20:47:59, Hillf Danton wrote:
>> >> >> If async order-O reclaim expected here, it is settled down when setting up scan
>> >> >> control, with scan priority hacked to be zero. Other than that, deny of reclaim
>> >> >> should be removed.
>> >> >
>> >> > Maybe I have misunderstood you but this is not right. The check is to
>> >> > protect from the _global_ reclaim with order > 0 when we prevent from
>> >> > memcg soft reclaim.
>> >> >
>> >> need to bear mm hog in this way?
>> >
>> > Could you be more specific? Are you trying to fix any particular
>> > problem?
>> >
>> My thought is simple, the outcome of softlimit reclaim depends little on the
>> value of reclaim order, zero or not, and only exceeding is reclaimed, so
>> selective response to swapd's request is incorrect.
>
> OK, got your point, finally. Let's add Balbir (the proposed patch can
> be found at https://lkml.org/lkml/2012/1/17/166) to the CC list because
> this seems to be a design decision.
>
> I always thought that this is because we want non-userspace (high order)
> mem pressure to be handled by the global reclaim only. And it makes some
> sense to me because it is little bit strange to reclaim for order-0
> while the request is for an higher order. I guess this might lead to an
> extensive and pointless reclaiming because we might end up with many
> free pages which cannot satisfy higher order allocation.
>
> On the other hand, it is true that the documentation says that the soft
> limit is considered when "the system detects memory contention or low
> memory" which doesn't say that the contention comes from memcg accounted
> memory.
>
> Anyway this changes the current behavior so it would better come with
> much better justification which shows that over reclaim doesn't happen
> and that we will not see higher latencies with higher order allocations.
>

As the function shows, the checked reclaim order is not used, but the
scan control is prepared with order(= 0), which is called async order-0
reclaim in my tern, then your worries on over reclaim and higher latencies
could be removed, I think 8-)

Thanks
Hillf

unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
						gfp_t gfp_mask, bool noswap,
						struct zone *zone,
						unsigned long *nr_scanned)
{
	struct scan_control sc = {
		.nr_scanned = 0,
		.nr_to_reclaim = SWAP_CLUSTER_MAX,
		.may_writepage = !laptop_mode,
		.may_unmap = 1,
		.may_swap = !noswap,
		.order = 0,
		.target_mem_cgroup = memcg,
	};
	struct mem_cgroup_zone mz = {
		.mem_cgroup = memcg,
		.zone = zone,
	};

	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);

	trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
						      sc.may_writepage,
						      sc.gfp_mask);

	/*
	 * NOTE: Although we can get the priority field, using it
	 * here is not a good idea, since it limits the pages we can scan.
	 * if we don't reclaim here, the shrink_zone from balance_pgdat
	 * will pick up pages from other mem cgroup's as well. We hack
	 * the priority and make it zero.
	 */
	shrink_mem_cgroup_zone(0, &mz, &sc);

	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);

	*nr_scanned = sc.nr_scanned;
	return sc.nr_reclaimed;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
