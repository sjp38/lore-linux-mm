Date: Wed, 12 Sep 2007 06:02:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 17 of 24] apply the anti deadlock features only to
 global oom
Message-Id: <20070912060202.dc0cc7ab.akpm@linux-foundation.org>
In-Reply-To: <efd1da1efb392cc4e015.1187786944@v2.random>
References: <patchbomb.1187786927@v2.random>
	<efd1da1efb392cc4e015.1187786944@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 14:49:04 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@suse.de>
> # Date 1187778125 -7200
> # Node ID efd1da1efb392cc4e015740d088ea9c6235901e0
> # Parent  b343d1056f356d60de868bd92422b33290e3c514
> apply the anti deadlock features only to global oom
> 
> Cc: Christoph Lameter <clameter@sgi.com>
> The local numa oom will keep killing the current task hoping that's it's
> not an innocent task and it won't alter the behavior of the rest of the
> VM. The global oom will not wait for TIF_MEMDIE tasks anymore, so this
> will be a really local event, not like before when the local-TIF_MEMDIE
> was effectively a global flag that the global oom would depend on too.
> 

ok, I'm starting to get lost here.  Let's apply it unreviewed and if it
breaks, that'll teach the numa weenies about the value of code review ;)

> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -387,9 +387,6 @@ void out_of_memory(struct zonelist *zone
>  		/* Got some memory back in the last second. */
>  		return;
>  
> -	if (down_trylock(&OOM_lock))
> -		return;
> -
>  	if (sysctl_panic_on_oom == 2)
>  		panic("out of memory. Compulsory panic_on_oom is selected.\n");
>  
> @@ -399,32 +396,39 @@ void out_of_memory(struct zonelist *zone
>  	 */
>  	constraint = constrained_alloc(zonelist, gfp_mask);
>  	cpuset_lock();
> -	read_lock(&tasklist_lock);
> -
> -	/*
> -	 * This holds the down(OOM_lock)+read_lock(tasklist_lock), so it's
> -	 * equivalent to write_lock_irq(tasklist_lock) as far as VM_is_OOM
> -	 * is concerned.
> -	 */
> -	if (unlikely(test_bit(0, &VM_is_OOM))) {
> -		if (time_before(jiffies, last_tif_memdie_jiffies + 10*HZ))
> -			goto out;
> -		printk("detected probable OOM deadlock, so killing another task\n");
> -		last_tif_memdie_jiffies = jiffies;
> -	}
>  
>  	switch (constraint) {
>  	case CONSTRAINT_MEMORY_POLICY:
> +		read_lock(&tasklist_lock);
>  		oom_kill_process(current, points,
>  				 "No available memory (MPOL_BIND)", gfp_mask, order);
> +		read_unlock(&tasklist_lock);
>  		break;
>  
>  	case CONSTRAINT_CPUSET:
> +		read_lock(&tasklist_lock);
>  		oom_kill_process(current, points,
>  				 "No available memory in cpuset", gfp_mask, order);
> +		read_unlock(&tasklist_lock);
>  		break;
>  
>  	case CONSTRAINT_NONE:
> +		if (down_trylock(&OOM_lock))
> +			break;
> +		read_lock(&tasklist_lock);
> +
> +		/*
> +		 * This holds the down(OOM_lock)+read_lock(tasklist_lock),
> +		 * so it's equivalent to write_lock_irq(tasklist_lock) as
> +		 * far as VM_is_OOM is concerned.
> +		 */
> +		if (unlikely(test_bit(0, &VM_is_OOM))) {

We have a helper macro-should-be-function for that.

> +			if (time_before(jiffies, last_tif_memdie_jiffies + 10*HZ))
> +				goto out;
> +			printk("detected probable OOM deadlock, so killing another task\n");
> +			last_tif_memdie_jiffies = jiffies;
> +		}
> +
>  		if (sysctl_panic_on_oom)
>  			panic("out of memory. panic_on_oom is selected\n");
>  retry:
> @@ -443,12 +447,11 @@ retry:
>  		if (oom_kill_process(p, points, "Out of memory", gfp_mask, order))
>  			goto retry;
>  
> +	out:
> +		read_unlock(&tasklist_lock);
> +		up(&OOM_lock);
>  		break;
>  	}
>  
> -out:
> -	read_unlock(&tasklist_lock);
>  	cpuset_unlock();
> -
> -	up(&OOM_lock);
> -}
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
