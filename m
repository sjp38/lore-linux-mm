Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 826406B004A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 06:01:29 -0500 (EST)
Received: by bkty12 with SMTP id y12so6897896bkt.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 03:01:27 -0800 (PST)
Message-ID: <4F437985.7060005@openvz.org>
Date: Tue, 21 Feb 2012 15:01:25 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: rework inactive_ratio logic
References: <20120215162442.13588.21790.stgit@zurg> <20120221101825.GA1676@cmpxchg.org>
In-Reply-To: <20120221101825.GA1676@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Johannes Weiner wrote:
> On Wed, Feb 15, 2012 at 08:24:42PM +0400, Konstantin Khlebnikov wrote:
>> This patch adds mem_cgroup->inactive_ratio calculated from hierarchical memory limit.
>> It updated at each limit change before shrinking cgroup to this new limit.
>> Ratios for all child cgroups are updated too, because parent limit can affect them.
>> Update precedure can be greatly optimized if its performance becomes the problem.
>> Inactive ratio for unlimited or huge limit does not matter, because we'll never hit it.
>>
>> At global reclaim always use global ratio from zone->inactive_ratio.
>> At mem-cgroup reclaim use inactive_ratio from target memory cgroup,
>> this is cgroup which hit its limit and cause this reclaimer invocation.
>>
>> Thus, global memory reclaimer will try to keep ratio for all lru lists in zone
>> above one mark, this guarantee that total ratio in this zone will be above too.
>> Meanwhile mem-cgroup will do the same thing for its lru lists in all zones, and
>> for all lru lists in all sub-cgroups in hierarchy.
>>
>> Also this patch removes some redundant code.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>
> I don't think we should take the zone ratio when we then proceed to
> scan a bunch of LRU lists that could individually be much smaller than
> the zone.  Especially since the ratio function is not a linear one.
>
> Otherwise the target ratios can be way too big for small lists, see
> the comment above mm/page_alloc.c::calculate_zone_inactive_ratio().
>
> Consequently, I also disagree on using sc->target_mem_cgroup.
>
> This whole mechanism is about balancing one specific pair of inactive
> vs. an active list according their size.  We shouldn't derive policy
> from numbers that are not correlated to this size.

Ok, maybe then we can move this inactive_ratio calculation right into
inactive_anon_is_low(). Then we can kill precalculated zone->inactive_ratio
and calculate it every time, even in non-memcg case, because zone-size also
not always correlate with anon lru size.
Looks like int_sqrt() is fast enough for this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
