Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 66DD06B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:13:20 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so4435342eek.4
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:13:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n46si14845834eeo.7.2014.04.22.03.13.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 03:13:18 -0700 (PDT)
Date: Tue, 22 Apr 2014 12:13:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + mm-disable-zone_reclaim_mode-by-default.patch added to -mm tree
Message-ID: <20140422101315.GF29311@dhcp22.suse.cz>
References: <535185cd./jfAC9DnY3vEWVmh%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <535185cd./jfAC9DnY3vEWVmh%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, zhangyanfei@cn.fujitsu.com, hannes@cmpxchg.org, mgorman@suse.de, linux-mm@kvack.org

On Fri 18-04-14 13:06:37, Andrew Morton wrote:
> Subject: + mm-disable-zone_reclaim_mode-by-default.patch added to -mm tree
> To: mgorman@suse.de,hannes@cmpxchg.org,mhocko@suse.cz,zhangyanfei@cn.fujitsu.com
> From: akpm@linux-foundation.org
> Date: Fri, 18 Apr 2014 13:06:37 -0700
> 
> 
> The patch titled
>      Subject: mm: disable zone_reclaim_mode by default
> has been added to the -mm tree.  Its filename is
>      mm-disable-zone_reclaim_mode-by-default.patch
> 
> This patch should soon appear at
>     http://ozlabs.org/~akpm/mmots/broken-out/mm-disable-zone_reclaim_mode-by-default.patch
> and later at
>     http://ozlabs.org/~akpm/mmotm/broken-out/mm-disable-zone_reclaim_mode-by-default.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Mel Gorman <mgorman@suse.de>
> Subject: mm: disable zone_reclaim_mode by default
> 
> When it was introduced, zone_reclaim_mode made sense as NUMA distances
> punished and workloads were generally partitioned to fit into a NUMA node.
>  NUMA machines are now common but few of the workloads are NUMA-aware and
> it's routine to see major performance due to zone_reclaim_mode being
> enabled but relatively few can identify the problem.
> 
> Those that require zone_reclaim_mode are likely to be able to detect when
> it needs to be enabled and tune appropriately so lets have a sensible
> default for the bulk of users.
> 
> 
> 
> This patch (of 2):
> 
> zone_reclaim_mode causes processes to prefer reclaiming memory from local
> node instead of spilling over to other nodes. This made sense initially when
> NUMA machines were almost exclusively HPC and the workload was partitioned
> into nodes. The NUMA penalties were sufficiently high to justify reclaiming
> the memory. On current machines and workloads it is often the case that
> zone_reclaim_mode destroys performance but not all users know how to detect
> this. Favour the common case and disable it by default. Users that are
> sophisticated enough to know they need zone_reclaim_mode will detect it.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

FWIW
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
>  Documentation/sysctl/vm.txt         |   17 +++++++++--------
>  arch/ia64/include/asm/topology.h    |    3 ++-
>  arch/powerpc/include/asm/topology.h |    8 ++------
>  include/linux/topology.h            |    3 ++-
>  mm/page_alloc.c                     |    2 --
>  5 files changed, 15 insertions(+), 18 deletions(-)
> 
> diff -puN Documentation/sysctl/vm.txt~mm-disable-zone_reclaim_mode-by-default Documentation/sysctl/vm.txt
> --- a/Documentation/sysctl/vm.txt~mm-disable-zone_reclaim_mode-by-default
> +++ a/Documentation/sysctl/vm.txt
> @@ -772,16 +772,17 @@ This is value ORed together of
>  2	= Zone reclaim writes dirty pages out
>  4	= Zone reclaim swaps pages
>  
> -zone_reclaim_mode is set during bootup to 1 if it is determined that pages
> -from remote zones will cause a measurable performance reduction. The
> -page allocator will then reclaim easily reusable pages (those page
> -cache pages that are currently not used) before allocating off node pages.
> -
> -It may be beneficial to switch off zone reclaim if the system is
> -used for a file server and all of memory should be used for caching files
> -from disk. In that case the caching effect is more important than
> +zone_reclaim_mode is disabled by default.  For file servers or workloads
> +that benefit from having their data cached, zone_reclaim_mode should be
> +left disabled as the caching effect is likely to be more important than
>  data locality.
>  
> +zone_reclaim may be enabled if it's known that the workload is partitioned
> +such that each partition fits within a NUMA node and that accessing remote
> +memory would cause a measurable performance reduction.  The page allocator
> +will then reclaim easily reusable pages (those page cache pages that are
> +currently not used) before allocating off node pages.
> +
>  Allowing zone reclaim to write out pages stops processes that are
>  writing large amounts of data from dirtying pages on other nodes. Zone
>  reclaim will write out dirty pages if a zone fills up and so effectively
> diff -puN arch/ia64/include/asm/topology.h~mm-disable-zone_reclaim_mode-by-default arch/ia64/include/asm/topology.h
> --- a/arch/ia64/include/asm/topology.h~mm-disable-zone_reclaim_mode-by-default
> +++ a/arch/ia64/include/asm/topology.h
> @@ -21,7 +21,8 @@
>  #define PENALTY_FOR_NODE_WITH_CPUS 255
>  
>  /*
> - * Distance above which we begin to use zone reclaim
> + * Nodes within this distance are eligible for reclaim by zone_reclaim() when
> + * zone_reclaim_mode is enabled.
>   */
>  #define RECLAIM_DISTANCE 15
>  
> diff -puN arch/powerpc/include/asm/topology.h~mm-disable-zone_reclaim_mode-by-default arch/powerpc/include/asm/topology.h
> --- a/arch/powerpc/include/asm/topology.h~mm-disable-zone_reclaim_mode-by-default
> +++ a/arch/powerpc/include/asm/topology.h
> @@ -9,12 +9,8 @@ struct device_node;
>  #ifdef CONFIG_NUMA
>  
>  /*
> - * Before going off node we want the VM to try and reclaim from the local
> - * node. It does this if the remote distance is larger than RECLAIM_DISTANCE.
> - * With the default REMOTE_DISTANCE of 20 and the default RECLAIM_DISTANCE of
> - * 20, we never reclaim and go off node straight away.
> - *
> - * To fix this we choose a smaller value of RECLAIM_DISTANCE.
> + * If zone_reclaim_mode is enabled, a RECLAIM_DISTANCE of 10 will mean that
> + * all zones on all nodes will be eligible for zone_reclaim().
>   */
>  #define RECLAIM_DISTANCE 10
>  
> diff -puN include/linux/topology.h~mm-disable-zone_reclaim_mode-by-default include/linux/topology.h
> --- a/include/linux/topology.h~mm-disable-zone_reclaim_mode-by-default
> +++ a/include/linux/topology.h
> @@ -58,7 +58,8 @@ int arch_update_cpu_topology(void);
>  /*
>   * If the distance between nodes in a system is larger than RECLAIM_DISTANCE
>   * (in whatever arch specific measurement units returned by node_distance())
> - * then switch on zone reclaim on boot.
> + * and zone_reclaim_mode is enabled then the VM will only call zone_reclaim()
> + * on nodes within this distance.
>   */
>  #define RECLAIM_DISTANCE 30
>  #endif
> diff -puN mm/page_alloc.c~mm-disable-zone_reclaim_mode-by-default mm/page_alloc.c
> --- a/mm/page_alloc.c~mm-disable-zone_reclaim_mode-by-default
> +++ a/mm/page_alloc.c
> @@ -1860,8 +1860,6 @@ static void __paginginit init_zone_allow
>  	for_each_node_state(i, N_MEMORY)
>  		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
>  			node_set(i, NODE_DATA(nid)->reclaim_nodes);
> -		else
> -			zone_reclaim_mode = 1;
>  }
>  
>  #else	/* CONFIG_NUMA */
> _
> 
> Patches currently in -mm which might be from mgorman@suse.de are
> 
> mm-use-paravirt-friendly-ops-for-numa-hinting-ptes.patch
> thp-close-race-between-split-and-zap-huge-pages.patch
> x86-require-x86-64-for-automatic-numa-balancing.patch
> x86-define-_page_numa-by-reusing-software-bits-on-the-pmd-and-pte-levels.patch
> x86-define-_page_numa-by-reusing-software-bits-on-the-pmd-and-pte-levels-fix-2.patch
> mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
> mm-compactionc-isolate_freepages_block-small-tuneup.patch
> mm-only-force-scan-in-reclaim-when-none-of-the-lrus-are-big-enough.patch
> mm-huge_memoryc-complete-conversion-to-pr_foo.patch
> mm-disable-zone_reclaim_mode-by-default.patch
> mm-page_alloc-do-not-cache-reclaim-distances.patch
> do_shared_fault-check-that-mmap_sem-is-held.patch
> linux-next.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
