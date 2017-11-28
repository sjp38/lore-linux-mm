Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E08436B02B5
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 03:09:16 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id s10so1856022plj.3
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 00:09:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4si20621130plb.468.2017.11.28.00.09.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 00:09:15 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9b4d5612-24eb-4bea-7164-49e42dc76f30@suse.cz>
Date: Tue, 28 Nov 2017 09:09:11 +0100
MIME-Version: 1.0
In-Reply-To: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On 11/28/2017 07:00 AM, Kemi Wang wrote:
> The existed implementation of NUMA counters is per logical CPU along with
> zone->vm_numa_stat[] separated by zone, plus a global numa counter array
> vm_numa_stat[]. However, unlike the other vmstat counters, numa stats don't
> effect system's decision and are only read from /proc and /sys, it is a
> slow path operation and likely tolerate higher overhead. Additionally,
> usually nodes only have a single zone, except for node 0. And there isn't
> really any use where you need these hits counts separated by zone.
> 
> Therefore, we can migrate the implementation of numa stats from per-zone to
> per-node, and get rid of these global numa counters. It's good enough to
> keep everything in a per cpu ptr of type u64, and sum them up when need, as
> suggested by Andi Kleen. That's helpful for code cleanup and enhancement
> (e.g. save more than 130+ lines code).

OK.

> With this patch, we can see 1.8%(335->329) drop of CPU cycles for single
> page allocation and deallocation concurrently with 112 threads tested on a
> 2-sockets skylake platform using Jesper's page_bench03 benchmark.

To be fair, one can now avoid the overhead completely since 4518085e127d
("mm, sysctl: make NUMA stats configurable"). But if we can still
optimize it, sure.

> Benchmark provided by Jesper D Brouer(increase loop times to 10000000):
> https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/
> bench
> 
> Also, it does not cause obvious latency increase when read /proc and /sys
> on a 2-sockets skylake platform. Latency shown by time command:
>                            base             head
> /proc/vmstat            sys 0m0.001s     sys 0m0.001s
> 
> /sys/devices/system/    sys 0m0.001s     sys 0m0.000s
> node/node*/numastat

Well, here I have to point out that the coarse "time" command resolution
here means the comparison of a single read cannot be compared. You would
have to e.g. time a loop with enough iterations (which would then be all
cache-hot, but better than nothing I guess).

> We would not worry it much as it is a slow path and will not be read
> frequently.
> 
> Suggested-by: Andi Kleen <ak@linux.intel.com>
> Signed-off-by: Kemi Wang <kemi.wang@intel.com>

...

> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 1779c98..7383d66 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -118,36 +118,8 @@ static inline void vm_events_fold_cpu(int cpu)
>   * Zone and node-based page accounting with per cpu differentials.
>   */
>  extern atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS];
> -extern atomic_long_t vm_numa_stat[NR_VM_NUMA_STAT_ITEMS];
>  extern atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS];
> -
> -#ifdef CONFIG_NUMA
> -static inline void zone_numa_state_add(long x, struct zone *zone,
> -				 enum numa_stat_item item)
> -{
> -	atomic_long_add(x, &zone->vm_numa_stat[item]);
> -	atomic_long_add(x, &vm_numa_stat[item]);
> -}
> -
> -static inline unsigned long global_numa_state(enum numa_stat_item item)
> -{
> -	long x = atomic_long_read(&vm_numa_stat[item]);
> -
> -	return x;
> -}
> -
> -static inline unsigned long zone_numa_state_snapshot(struct zone *zone,
> -					enum numa_stat_item item)
> -{
> -	long x = atomic_long_read(&zone->vm_numa_stat[item]);
> -	int cpu;
> -
> -	for_each_online_cpu(cpu)
> -		x += per_cpu_ptr(zone->pageset, cpu)->vm_numa_stat_diff[item];
> -
> -	return x;
> -}
> -#endif /* CONFIG_NUMA */
> +extern u64 __percpu *vm_numa_stat;
>  
>  static inline void zone_page_state_add(long x, struct zone *zone,
>  				 enum zone_stat_item item)
> @@ -234,10 +206,39 @@ static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
>  
>  
>  #ifdef CONFIG_NUMA
> +static inline unsigned long zone_numa_state_snapshot(struct zone *zone,
> +					enum numa_stat_item item)
> +{
> +	return 0;
> +}
> +
> +static inline unsigned long node_numa_state_snapshot(int node,
> +					enum numa_stat_item item)
> +{
> +	unsigned long x = 0;
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu)

I'm worried about the "for_each_possible..." approach here and elsewhere
in the patch as it can be rather excessive compared to the online number
of cpus (we've seen BIOSes report large numbers of possible CPU's). IIRC
the general approach with vmstat is to query just online cpu's / nodes,
and if they go offline, transfer their accumulated stats to some other
"victim"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
