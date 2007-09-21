Date: Fri, 21 Sep 2007 12:10:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 10 of 24] stop useless vm trashing while we wait the
 TIF_MEMDIE task to exit
In-Reply-To: <edb3af3e0d4f2c083c8d.1187786937@v2.random>
Message-ID: <alpine.DEB.0.9999.0709211208140.11391@chino.kir.corp.google.com>
References: <edb3af3e0d4f2c083c8d.1187786937@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007, Andrea Arcangeli wrote:

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1028,6 +1028,8 @@ static unsigned long shrink_zone(int pri
>  		nr_inactive = 0;
>  
>  	while (nr_active || nr_inactive) {
> +		if (is_VM_OOM())
> +			break;
>  		if (nr_active) {
>  			nr_to_scan = min(nr_active,
>  					(unsigned long)sc->swap_cluster_max);

This will need to use the new OOM zone-locking interface.  shrink_zones() 
accepts struct zone** as one of its formals so while traversing each zone 
this would simply become a test of zone_is_oom_locked(*z).

> @@ -1138,6 +1140,17 @@ unsigned long try_to_free_pages(struct z
>  	}
>  
>  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> +		if (is_VM_OOM()) {
> +			if (!test_thread_flag(TIF_MEMDIE)) {
> +				/* get out of the way */
> +				schedule_timeout_interruptible(1);
> +				/* don't waste cpu if we're still oom */
> +				if (is_VM_OOM())
> +					goto out;
> +			} else
> +				goto out;
> +		}
> +
>  		sc.nr_scanned = 0;
>  		if (!priority)
>  			disable_swap_token();
> 

Same as above, and it becomes trivial since try_to_free_pages() also 
accepts a struct zone** formal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
