Date: Wed, 12 Sep 2007 05:42:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10 of 24] stop useless vm trashing while we wait the
 TIF_MEMDIE task to exit
Message-Id: <20070912054229.1073f55d.akpm@linux-foundation.org>
In-Reply-To: <edb3af3e0d4f2c083c8d.1187786937@v2.random>
References: <patchbomb.1187786927@v2.random>
	<edb3af3e0d4f2c083c8d.1187786937@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 14:48:57 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@suse.de>
> # Date 1187778125 -7200
> # Node ID edb3af3e0d4f2c083c8ddd9857073a3c8393ab8e
> # Parent  9bf6a66eab3c52327daa831ef101d7802bc71791
> stop useless vm trashing while we wait the TIF_MEMDIE task to exit
> 
> There's no point in trying to free memory if we're oom.
> 
> Signed-off-by: Andrea Arcangeli <andrea@suse.de>
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -159,6 +159,8 @@ struct swap_list_t {
>  #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
>  
>  /* linux/mm/oom_kill.c */
> +extern unsigned long VM_is_OOM;
> +#define is_VM_OOM() unlikely(test_bit(0, &VM_is_OOM))

argh!  Why didn't the first patch do this?

Now we have open-coded test_bit(&VM_is_OOM) calls in exit.c and oom_kill.c
which could use this "function".

Please prefer to use inline C functions where possible.  I think it's
possible here...

>  extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
>  extern int register_oom_notifier(struct notifier_block *nb);
>  extern int unregister_oom_notifier(struct notifier_block *nb);
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
> @@ -1138,6 +1140,17 @@ unsigned long try_to_free_pages(struct z
>  	}
>  
>  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> +		if (is_VM_OOM()) {
> +			if (!test_thread_flag(TIF_MEMDIE)) {
> +				/* get out of the way */
> +				schedule_timeout_interruptible(1);

If the calling task has signal_pending(), this sleep won't do anything.

> +				/* don't waste cpu if we're still oom */
> +				if (is_VM_OOM())
> +					goto out;
> +			} else
> +				goto out;
> +		}
> +

The change kinda makes sense, but what if, say, a great bunch of writes
just completed?  Then memory becomes reclaimable.

Also, what if the oom-killing was due to a shortage in a particular zone,
but there's plenty of reclaimable memory in other zones, memory which this
task can use?

Also, the oom-killer is cpuset aware.  Won't this change cause an
oom-killing in cpuset A to needlessly disrupt processes running in cpuset
B?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
