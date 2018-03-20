Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD626B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 11:29:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s21so1132912pfm.15
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 08:29:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z4si1448600pfb.192.2018.03.20.08.29.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 08:29:07 -0700 (PDT)
Date: Tue, 20 Mar 2018 16:29:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm/vmscan: Don't mess with pgdat->flags in memcg
 reclaim.
Message-ID: <20180320152903.GA23100@dhcp22.suse.cz>
References: <20180315164553.17856-1-aryabinin@virtuozzo.com>
 <20180315164553.17856-6-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180315164553.17856-6-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Thu 15-03-18 19:45:53, Andrey Ryabinin wrote:
> memcg reclaim may alter pgdat->flags based on the state of LRU lists
> in cgroup and its children. PGDAT_WRITEBACK may force kswapd to sleep
> congested_wait(), PGDAT_DIRTY may force kswapd to writeback filesystem
> pages. But the worst here is PGDAT_CONGESTED, since it may force all
> direct reclaims to stall in wait_iff_congested(). Note that only kswapd
> have powers to clear any of these bits. This might just never happen if
> cgroup limits configured that way. So all direct reclaims will stall
> as long as we have some congested bdi in the system.
> 
> Leave all pgdat->flags manipulations to kswapd. kswapd scans the whole
> pgdat, so it's reasonable to leave all decisions about node stat
> to kswapd. Also add per-cgroup congestion state to avoid needlessly
> burning CPU in cgroup reclaim if heavy congestion is observed.
> 
> Currently there is no need in per-cgroup PGDAT_WRITEBACK and PGDAT_DIRTY
> bits since they alter only kswapd behavior.
> 
> The problem could be easily demonstrated by creating heavy congestion
> in one cgroup:
> 
>     echo "+memory" > /sys/fs/cgroup/cgroup.subtree_control
>     mkdir -p /sys/fs/cgroup/congester
>     echo 512M > /sys/fs/cgroup/congester/memory.max
>     echo $$ > /sys/fs/cgroup/congester/cgroup.procs
>     /* generate a lot of diry data on slow HDD */
>     while true; do dd if=/dev/zero of=/mnt/sdb/zeroes bs=1M count=1024; done &
>     ....
>     while true; do dd if=/dev/zero of=/mnt/sdb/zeroes bs=1M count=1024; done &
> 
> and some job in another cgroup:
> 
>     mkdir /sys/fs/cgroup/victim
>     echo 128M > /sys/fs/cgroup/victim/memory.max
> 
>     # time cat /dev/sda > /dev/null
>     real    10m15.054s
>     user    0m0.487s
>     sys     1m8.505s
> 
> According to the tracepoint in wait_iff_congested(), the 'cat' spent 50%
> of the time sleeping there.
> 
> With the patch, cat don't waste time anymore:
> 
>     # time cat /dev/sda > /dev/null
>     real    5m32.911s
>     user    0m0.411s
>     sys     0m56.664s
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  include/linux/backing-dev.h |  2 +-
>  include/linux/memcontrol.h  |  2 ++
>  mm/backing-dev.c            | 19 ++++------
>  mm/vmscan.c                 | 84 ++++++++++++++++++++++++++++++++-------------
>  4 files changed, 70 insertions(+), 37 deletions(-)

This patch seems overly complicated. Why don't you simply reduce the whole
pgdat_flags handling to global_reclaim()?

-- 
Michal Hocko
SUSE Labs
