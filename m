Date: Wed, 12 Sep 2007 05:59:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 16 of 24] avoid some lock operation in vm fast path
Message-Id: <20070912055952.bd5c99d6.akpm@linux-foundation.org>
In-Reply-To: <b343d1056f356d60de86.1187786943@v2.random>
References: <patchbomb.1187786927@v2.random>
	<b343d1056f356d60de86.1187786943@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 14:49:03 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@suse.de>
> # Date 1187778125 -7200
> # Node ID b343d1056f356d60de868bd92422b33290e3c514
> # Parent  94686cfcd27347e83a6aa145c77457ca6455366d
> avoid some lock operation in vm fast path
> 
> Let's not bloat the kernel for numa. Not nice, but at least this way
> perhaps somebody will clean it up instead of hiding the inefficiency in
> there.
> 
> Signed-off-by: Andrea Arcangeli <andrea@suse.de>
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -232,8 +232,10 @@ struct zone {
>  	unsigned long		pages_scanned;	   /* since last reclaim */
>  	int			all_unreclaimable; /* All pages pinned */
>  
> +#ifdef CONFIG_NUMA
>  	/* A count of how many reclaimers are scanning this zone */
>  	atomic_t		reclaim_in_progress;
> +#endif
>  
>  	/* Zone statistics */
>  	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2960,7 +2960,9 @@ static void __meminit free_area_init_cor
>  		INIT_LIST_HEAD(&zone->active_list);
>  		INIT_LIST_HEAD(&zone->inactive_list);
>  		zap_zone_vm_stats(zone);
> +#ifdef CONFIG_NUMA
>  		atomic_set(&zone->reclaim_in_progress, 0);
> +#endif
>  		if (!size)
>  			continue;
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1014,7 +1014,9 @@ static unsigned long shrink_zone(int pri
>  	unsigned long nr_to_scan;
>  	unsigned long nr_reclaimed = 0;
>  
> +#ifdef CONFIG_NUMA
>  	atomic_inc(&zone->reclaim_in_progress);
> +#endif
>  
>  	/*
>  	 * Add one to `nr_to_scan' just to make sure that the kernel will
> @@ -1050,7 +1052,9 @@ static unsigned long shrink_zone(int pri
>  
>  	throttle_vm_writeout(sc->gfp_mask);
>  
> +#ifdef CONFIG_NUMA
>  	atomic_dec(&zone->reclaim_in_progress);
> +#endif
>  	return nr_reclaimed;
>  }

OK, but we'd normally do this via some little wrapper functions which are
empty-if-not-numa.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
