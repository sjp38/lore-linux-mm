Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 71CD96B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 03:06:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y206so12311232wmd.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 00:06:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o9si8079253wrc.547.2017.08.07.00.06.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Aug 2017 00:06:19 -0700 (PDT)
Date: Mon, 7 Aug 2017 09:06:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: vmstat: get slab statistics always from node counters
Message-ID: <20170807070616.GA32442@dhcp22.suse.cz>
References: <20170807000409.2423-1-stefan@agner.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170807000409.2423-1-stefan@agner.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Agner <stefan@agner.ch>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 06-08-17 17:04:09, Stefan Agner wrote:
> After the move of slab statistics from zone to node counters some
> users still try to get the counters from the zone counters. This has
> been caught while compiling with clang printing a warning like:
> 
>   implicit conversion from enumeration type 'enum node_stat_item' to
>   different enumeration type 'enum zone_stat_item' [-Wenum-conversion]
> 
> Fixes: 385386cff4 ("mm: vmstat: move slab statistics from zone to node counters")
> Signed-off-by: Stefan Agner <stefan@agner.ch>

Johannes has posted the fix already
http://lkml.kernel.org/r/20170801134256.5400-1-hannes@cmpxchg.org

Thanks!

> ---
>  kernel/power/snapshot.c | 2 +-
>  mm/page_alloc.c         | 8 ++++----
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
> index 222317721c5a..0972a8e09d08 100644
> --- a/kernel/power/snapshot.c
> +++ b/kernel/power/snapshot.c
> @@ -1650,7 +1650,7 @@ static unsigned long minimum_image_size(unsigned long saveable)
>  {
>  	unsigned long size;
>  
> -	size = global_page_state(NR_SLAB_RECLAIMABLE)
> +	size = global_node_page_state(NR_SLAB_RECLAIMABLE)
>  		+ global_node_page_state(NR_ACTIVE_ANON)
>  		+ global_node_page_state(NR_INACTIVE_ANON)
>  		+ global_node_page_state(NR_ACTIVE_FILE)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d30e914afb6..10aa91b58487 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4458,8 +4458,8 @@ long si_mem_available(void)
>  	 * Part of the reclaimable slab consists of items that are in use,
>  	 * and cannot be freed. Cap this estimate at the low watermark.
>  	 */
> -	available += global_page_state(NR_SLAB_RECLAIMABLE) -
> -		     min(global_page_state(NR_SLAB_RECLAIMABLE) / 2, wmark_low);
> +	available += global_node_page_state(NR_SLAB_RECLAIMABLE) -
> +		     min(global_node_page_state(NR_SLAB_RECLAIMABLE) / 2, wmark_low);
>  
>  	if (available < 0)
>  		available = 0;
> @@ -4602,8 +4602,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>  		global_node_page_state(NR_FILE_DIRTY),
>  		global_node_page_state(NR_WRITEBACK),
>  		global_node_page_state(NR_UNSTABLE_NFS),
> -		global_page_state(NR_SLAB_RECLAIMABLE),
> -		global_page_state(NR_SLAB_UNRECLAIMABLE),
> +		global_node_page_state(NR_SLAB_RECLAIMABLE),
> +		global_node_page_state(NR_SLAB_UNRECLAIMABLE),
>  		global_node_page_state(NR_FILE_MAPPED),
>  		global_node_page_state(NR_SHMEM),
>  		global_page_state(NR_PAGETABLE),
> -- 
> 2.13.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
