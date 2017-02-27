Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 334946B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 01:05:01 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x17so3077921pgi.3
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 22:05:01 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id a191si1399400pfa.23.2017.02.26.22.04.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Feb 2017 22:05:00 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id s67so11809028pgb.1
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 22:04:59 -0800 (PST)
Subject: Re: [PATCH v2] mm/vmscan: fix high cpu usage of kswapd if there are
 no reclaimable pages
References: <1487918992-7515-1-git-send-email-hejianet@gmail.com>
 <20170224084949.GA19161@dhcp22.suse.cz> <20170224165105.GB20092@cmpxchg.org>
From: hejianet <hejianet@gmail.com>
Message-ID: <0c2cebb4-5fcd-6e07-5ba0-3d80ed2866e5@gmail.com>
Date: Mon, 27 Feb 2017 14:04:49 +0800
MIME-Version: 1.0
In-Reply-To: <20170224165105.GB20092@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>


Hi
Tested-by: Jia He <hejianet@gmail.com>

cat /proc/meminfo
[...]
CmaFree:               0 kB
HugePages_Total:    1831
HugePages_Free:     1831
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:      16384 kB

top - 06:50:29 up  1:26,  1 user,  load average: 0.00, 0.00, 0.00
Tasks:   1 total,   0 running,   1 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.2 sy,  0.0 ni, 99.6 id,  0.2 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem:  31371520 total, 30577664 used,   793856 free,      256 buffers
KiB Swap:  6284224 total,      128 used,  6284096 free.   281280 cached Mem

   PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
    79 root      20   0       0      0      0 S 0.000 0.000   0:00.00 kswapd3


On 25/02/2017 12:51 AM, Johannes Weiner wrote:
> On Fri, Feb 24, 2017 at 09:49:50AM +0100, Michal Hocko wrote:
>> I believe we should pursue the proposal from Johannes which is more
>> generic and copes with corner cases much better.
>
> Jia, can you try this? I'll put the cleanups in follow-up patches.
>
> ---
>
>>From 29fefdca148e28830e0934d4e6cceb95ed2ee36e Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Fri, 24 Feb 2017 10:56:32 -0500
> Subject: [PATCH] mm: vmscan: disable kswapd on unreclaimable nodes
>
> Jia He reports a problem with kswapd spinning at 100% CPU when
> requesting more hugepages than memory available in the system:
>
> $ echo 4000 >/proc/sys/vm/nr_hugepages
>
> top - 13:42:59 up  3:37,  1 user,  load average: 1.09, 1.03, 1.01
> Tasks:   1 total,   1 running,   0 sleeping,   0 stopped,   0 zombie
> %Cpu(s):  0.0 us, 12.5 sy,  0.0 ni, 85.5 id,  2.0 wa,  0.0 hi,  0.0 si,  0.0 st
> KiB Mem:  31371520 total, 30915136 used,   456384 free,      320 buffers
> KiB Swap:  6284224 total,   115712 used,  6168512 free.    48192 cached Mem
>
>   PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
>    76 root      20   0       0      0      0 R 100.0 0.000 217:17.29 kswapd3
>
> At that time, there are no reclaimable pages left in the node, but as
> kswapd fails to restore the high watermarks it refuses to go to sleep.
>
> Kswapd needs to back away from nodes that fail to balance. Up until
> 1d82de618ddd ("mm, vmscan: make kswapd reclaim in terms of nodes")
> kswapd had such a mechanism. It considered zones whose theoretically
> reclaimable pages it had reclaimed six times over as unreclaimable and
> backed away from them. This guard was erroneously removed as the patch
> changed the definition of a balanced node.
>
> However, simply restoring this code wouldn't help in the case reported
> here: there *are* no reclaimable pages that could be scanned until the
> threshold is met. Kswapd would stay awake anyway.
>
> Introduce a new and much simpler way of backing off. If kswapd runs
> through MAX_RECLAIM_RETRIES (16) cycles without reclaiming a single
> page, make it back off from the node. This is the same number of shots
> direct reclaim takes before declaring OOM. Kswapd will go to sleep on
> that node until a direct reclaimer manages to reclaim some pages, thus
> proving the node reclaimable again.
>
> Reported-by: Jia He <hejianet@gmail.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/mmzone.h |  2 ++
>  include/linux/swap.h   |  1 +
>  mm/page_alloc.c        |  6 ------
>  mm/vmscan.c            | 20 ++++++++++++++++++++
>  4 files changed, 23 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 8e02b3750fe0..d2c50ab6ae40 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -630,6 +630,8 @@ typedef struct pglist_data {
>  	int kswapd_order;
>  	enum zone_type kswapd_classzone_idx;
>
> +	int kswapd_failures;		/* Number of 'reclaimed == 0' runs */
> +
>  #ifdef CONFIG_COMPACTION
>  	int kcompactd_max_order;
>  	enum zone_type kcompactd_classzone_idx;
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 45e91dd6716d..5c06581a730b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -288,6 +288,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
>  						struct vm_area_struct *vma);
>
>  /* linux/mm/vmscan.c */
> +#define MAX_RECLAIM_RETRIES 16
>  extern unsigned long zone_reclaimable_pages(struct zone *zone);
>  extern unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat);
>  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 614cd0397ce3..83f0442f07fa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3516,12 +3516,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  }
>
>  /*
> - * Maximum number of reclaim retries without any progress before OOM killer
> - * is consider as the only way to move forward.
> - */
> -#define MAX_RECLAIM_RETRIES 16
> -
> -/*
>   * Checks whether it makes sense to retry the reclaim to make a forward progress
>   * for the given allocation request.
>   * The reclaim feedback represented by did_some_progress (any progress during
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 26c3b405ef34..8e9bdd172182 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2626,6 +2626,15 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
>  					 sc->nr_scanned - nr_scanned, sc));
>
> +	/*
> +	 * Kswapd gives up on balancing particular nodes after too
> +	 * many failures to reclaim anything from them. If reclaim
> +	 * progress happens, reset the failure counter. A successful
> +	 * direct reclaim run will knock a stuck kswapd loose again.
> +	 */
> +	if (reclaimable)
> +		pgdat->kswapd_failures = 0;
> +
>  	return reclaimable;
>  }
>
> @@ -3134,6 +3143,10 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
>  	if (waitqueue_active(&pgdat->pfmemalloc_wait))
>  		wake_up_all(&pgdat->pfmemalloc_wait);
>
> +	/* Hopeless node, leave it to direct reclaim */
> +	if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES)
> +		return true;
> +
>  	for (i = 0; i <= classzone_idx; i++) {
>  		struct zone *zone = pgdat->node_zones + i;
>
> @@ -3316,6 +3329,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			sc.priority--;
>  	} while (sc.priority >= 1);
>
> +	if (!sc.nr_reclaimed)
> +		pgdat->kswapd_failures++;
> +
>  out:
>  	/*
>  	 * Return the order kswapd stopped reclaiming at as
> @@ -3515,6 +3531,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>  	if (!waitqueue_active(&pgdat->kswapd_wait))
>  		return;
>
> +	/* Hopeless node, leave it to direct reclaim */
> +	if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES)
> +		return;
> +
>  	/* Only wake kswapd if all zones are unbalanced */
>  	for (z = 0; z <= classzone_idx; z++) {
>  		zone = pgdat->node_zones + z;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
