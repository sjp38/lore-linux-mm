Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06DAE6B0026
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 13:00:53 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f4-v6so3426233plr.11
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 10:00:52 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0725.outbound.protection.outlook.com. [2a01:111:f400:fe1e::725])
        by mx.google.com with ESMTPS id z190si3011218pgb.461.2018.03.21.10.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 10:00:50 -0700 (PDT)
Subject: Re: [PATCH 6/6] mm/vmscan: Don't mess with pgdat->flags in memcg
 reclaim.
References: <20180315164553.17856-1-aryabinin@virtuozzo.com>
 <20180315164553.17856-6-aryabinin@virtuozzo.com>
 <20180320152903.GA23100@dhcp22.suse.cz>
 <c3405049-222d-a045-4ce5-8e51817d89b6@virtuozzo.com>
 <20180321114301.GH23100@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <d29cdc69-718c-7c7e-bffb-d716d343a154@virtuozzo.com>
Date: Wed, 21 Mar 2018 20:01:32 +0300
MIME-Version: 1.0
In-Reply-To: <20180321114301.GH23100@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On 03/21/2018 02:43 PM, Michal Hocko wrote:
> On Wed 21-03-18 14:14:35, Andrey Ryabinin wrote:
>>
>>
>> On 03/20/2018 06:29 PM, Michal Hocko wrote:
>>
>>>> Leave all pgdat->flags manipulations to kswapd. kswapd scans the whole
>>>> pgdat, so it's reasonable to leave all decisions about node stat
>>>> to kswapd. Also add per-cgroup congestion state to avoid needlessly
>>>> burning CPU in cgroup reclaim if heavy congestion is observed.
>>>>
>>>> Currently there is no need in per-cgroup PGDAT_WRITEBACK and PGDAT_DIRTY
>>>> bits since they alter only kswapd behavior.
>>>>
>>>> The problem could be easily demonstrated by creating heavy congestion
>>>> in one cgroup:
>>>>
>>>>     echo "+memory" > /sys/fs/cgroup/cgroup.subtree_control
>>>>     mkdir -p /sys/fs/cgroup/congester
>>>>     echo 512M > /sys/fs/cgroup/congester/memory.max
>>>>     echo $$ > /sys/fs/cgroup/congester/cgroup.procs
>>>>     /* generate a lot of diry data on slow HDD */
>>>>     while true; do dd if=/dev/zero of=/mnt/sdb/zeroes bs=1M count=1024; done &
>>>>     ....
>>>>     while true; do dd if=/dev/zero of=/mnt/sdb/zeroes bs=1M count=1024; done &
>>>>
>>>> and some job in another cgroup:
>>>>
>>>>     mkdir /sys/fs/cgroup/victim
>>>>     echo 128M > /sys/fs/cgroup/victim/memory.max
>>>>
>>>>     # time cat /dev/sda > /dev/null
>>>>     real    10m15.054s
>>>>     user    0m0.487s
>>>>     sys     1m8.505s
>>>>
>>>> According to the tracepoint in wait_iff_congested(), the 'cat' spent 50%
>>>> of the time sleeping there.
>>>>
>>>> With the patch, cat don't waste time anymore:
>>>>
>>>>     # time cat /dev/sda > /dev/null
>>>>     real    5m32.911s
>>>>     user    0m0.411s
>>>>     sys     0m56.664s
>>>>
>>>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>>>> ---
>>>>  include/linux/backing-dev.h |  2 +-
>>>>  include/linux/memcontrol.h  |  2 ++
>>>>  mm/backing-dev.c            | 19 ++++------
>>>>  mm/vmscan.c                 | 84 ++++++++++++++++++++++++++++++++-------------
>>>>  4 files changed, 70 insertions(+), 37 deletions(-)
>>>
>>> This patch seems overly complicated. Why don't you simply reduce the whole
>>> pgdat_flags handling to global_reclaim()?
>>>
>>
>> In that case cgroup2 reclaim wouldn't have any way of throttling if
>> cgroup is full of congested dirty pages.
> 
> It's been some time since I've looked into the throttling code so pardon
> my ignorance. Don't cgroup v2 users get throttled in the write path to
> not dirty too many pages in the first place?
 
Yes, they do. The same as no cgroup users. Basically, cgroup v2 mimics
all that global reclaim, dirty ratelimiting, throttling stuff.
However, balance_dirty_pages() can't always protect from too much dirty problem.
E.g. you could mmap() file and start writing to it at the speed of RAM.
balance_dirty_pages() can't stop you there.


> In other words, is your patch trying to fix two different things? One is
> per-memcg reclaim influencing the global pgdat state, which is clearly
> wrng, and cgroup v2 reclaim throttling that is not pgdat based?
> 

Kinda, but the second problem is introduced by fixing the first one. Since
without fixing the first problem we have congestion throttling in cgroup v2.
Yes, it's based on global pgdat state, which is wrong, but it should throttle
cgroupv2 reclaim when memcg is congested.

I didn't try to evaluate how useful this whole congestion throttling is,
and whether it's really needed. But if we need for global reclaim, than
we probably need it in cgroup2 reclaim too.


P.S. Some observation: blk-mq seems doesn't have any congestion mechanism.
Dunno whether is this intentional or just an oversight. This means congestion
throttling never happens on such system.
