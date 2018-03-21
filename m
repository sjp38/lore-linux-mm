Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB9E16B0003
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 07:13:55 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g13-v6so689330pln.13
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 04:13:55 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0132.outbound.protection.outlook.com. [104.47.0.132])
        by mx.google.com with ESMTPS id c5-v6si3615324pll.90.2018.03.21.04.13.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 04:13:54 -0700 (PDT)
Subject: Re: [PATCH 6/6] mm/vmscan: Don't mess with pgdat->flags in memcg
 reclaim.
References: <20180315164553.17856-1-aryabinin@virtuozzo.com>
 <20180315164553.17856-6-aryabinin@virtuozzo.com>
 <20180320152903.GA23100@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <c3405049-222d-a045-4ce5-8e51817d89b6@virtuozzo.com>
Date: Wed, 21 Mar 2018 14:14:35 +0300
MIME-Version: 1.0
In-Reply-To: <20180320152903.GA23100@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org



On 03/20/2018 06:29 PM, Michal Hocko wrote:

>> Leave all pgdat->flags manipulations to kswapd. kswapd scans the whole
>> pgdat, so it's reasonable to leave all decisions about node stat
>> to kswapd. Also add per-cgroup congestion state to avoid needlessly
>> burning CPU in cgroup reclaim if heavy congestion is observed.
>>
>> Currently there is no need in per-cgroup PGDAT_WRITEBACK and PGDAT_DIRTY
>> bits since they alter only kswapd behavior.
>>
>> The problem could be easily demonstrated by creating heavy congestion
>> in one cgroup:
>>
>>     echo "+memory" > /sys/fs/cgroup/cgroup.subtree_control
>>     mkdir -p /sys/fs/cgroup/congester
>>     echo 512M > /sys/fs/cgroup/congester/memory.max
>>     echo $$ > /sys/fs/cgroup/congester/cgroup.procs
>>     /* generate a lot of diry data on slow HDD */
>>     while true; do dd if=/dev/zero of=/mnt/sdb/zeroes bs=1M count=1024; done &
>>     ....
>>     while true; do dd if=/dev/zero of=/mnt/sdb/zeroes bs=1M count=1024; done &
>>
>> and some job in another cgroup:
>>
>>     mkdir /sys/fs/cgroup/victim
>>     echo 128M > /sys/fs/cgroup/victim/memory.max
>>
>>     # time cat /dev/sda > /dev/null
>>     real    10m15.054s
>>     user    0m0.487s
>>     sys     1m8.505s
>>
>> According to the tracepoint in wait_iff_congested(), the 'cat' spent 50%
>> of the time sleeping there.
>>
>> With the patch, cat don't waste time anymore:
>>
>>     # time cat /dev/sda > /dev/null
>>     real    5m32.911s
>>     user    0m0.411s
>>     sys     0m56.664s
>>
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> ---
>>  include/linux/backing-dev.h |  2 +-
>>  include/linux/memcontrol.h  |  2 ++
>>  mm/backing-dev.c            | 19 ++++------
>>  mm/vmscan.c                 | 84 ++++++++++++++++++++++++++++++++-------------
>>  4 files changed, 70 insertions(+), 37 deletions(-)
> 
> This patch seems overly complicated. Why don't you simply reduce the whole
> pgdat_flags handling to global_reclaim()?
> 

In that case cgroup2 reclaim wouldn't have any way of throttling if cgroup is full of congested dirty pages.
