Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77BFE6B02F4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:58:21 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g32so664428wrd.8
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 02:58:21 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id e90si1035345wmi.209.2017.08.15.02.58.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 02:58:20 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id C53D9992D4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 09:58:19 +0000 (UTC)
Date: Tue, 15 Aug 2017 10:58:19 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm: Update NUMA counter threshold size
Message-ID: <20170815095819.5kjh4rrhkye3lgf2@techsingularity.net>
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <1502786736-21585-3-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1502786736-21585-3-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, Aug 15, 2017 at 04:45:36PM +0800, Kemi Wang wrote:
>  Threshold   CPU cycles    Throughput(88 threads)
>      32          799         241760478
>      64          640         301628829
>      125         537         358906028 <==> system by default (base)
>      256         468         412397590
>      512         428         450550704
>      4096        399         482520943
>      20000       394         489009617
>      30000       395         488017817
>      32765       394(-26.6%) 488932078(+36.2%) <==> with this patchset
>      N/A         342(-36.3%) 562900157(+56.8%) <==> disable zone_statistics
> 
> Signed-off-by: Kemi Wang <kemi.wang@intel.com>
> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> Suggested-by: Ying Huang <ying.huang@intel.com>
> ---
>  include/linux/mmzone.h |  4 ++--
>  include/linux/vmstat.h |  6 +++++-
>  mm/vmstat.c            | 23 ++++++++++-------------
>  3 files changed, 17 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 0b11ba7..7eaf0e8 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -282,8 +282,8 @@ struct per_cpu_pageset {
>  	struct per_cpu_pages pcp;
>  #ifdef CONFIG_NUMA
>  	s8 expire;
> -	s8 numa_stat_threshold;
> -	s8 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];
> +	s16 numa_stat_threshold;
> +	s16 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];

I'm fairly sure this pushes the size of that structure into the next
cache line which is not welcome.

vm_numa_stat_diff is an always incrementing field. How much do you gain
if this becomes a u8 code and remove any code that deals with negative
values? That would double the threshold without consuming another cache line.

Furthermore, the stats in question are only ever incremented by one.
That means that any calcluation related to overlap can be removed and
special cased that it'll never overlap by more than 1. That potentially
removes code that is required for other stats but not locality stats.
This may give enough savings to avoid moving to s16.

Very broadly speaking, I like what you're doing but I would like to see
more work on reducing any unnecessary code in that path (such as dealing
with overlaps for single increments) and treat incrasing the cache footprint
only as a very last resort.

>  #endif
>  #ifdef CONFIG_SMP
>  	s8 stat_threshold;
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 1e19379..d97cc34 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -125,10 +125,14 @@ static inline unsigned long global_numa_state(enum zone_numa_stat_item item)
>  	return x;
>  }
>  
> -static inline unsigned long zone_numa_state(struct zone *zone,
> +static inline unsigned long zone_numa_state_snapshot(struct zone *zone,
>  					enum zone_numa_stat_item item)
>  {
>  	long x = atomic_long_read(&zone->vm_numa_stat[item]);
> +	int cpu;
> +
> +	for_each_online_cpu(cpu)
> +		x += per_cpu_ptr(zone->pageset, cpu)->vm_numa_stat_diff[item];
>  
>  	return x;
>  }

This does not appear to be related to the current patch. It either
should be merged with the previous patch or stand on its own.

> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 5a7fa30..c7f50ed 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -30,6 +30,8 @@
>  
>  #include "internal.h"
>  
> +#define NUMA_STAT_THRESHOLD  32765
> +

This should be expressed in terms of the type and not a hard-coded value.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
