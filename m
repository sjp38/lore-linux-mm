Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id AB1F96B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:15:56 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl13so523917pab.32
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:15:55 -0700 (PDT)
Date: Wed, 10 Apr 2013 14:15:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Print the correct method to disable automatic numa
 migration
In-Reply-To: <1365622514-26614-1-git-send-email-andi@firstfloor.org>
Message-ID: <alpine.DEB.2.02.1304101410160.25932@chino.kir.corp.google.com>
References: <1365622514-26614-1-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, mgorman@suse.de

On Wed, 10 Apr 2013, Andi Kleen wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> When the "default y" CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is enabled,
> the message it prints refers to a sysctl to disable it again.
> But that sysctl doesn't exist.
> 
> Document the correct (highly obscure method) through debugfs.
> 
> This should be also in Documentation/* but isn't.
> 
> Also fix the checkpatch problems.
> 
> BTW I think the "default y" is highly dubious for such a
> experimential feature.
> 

CONFIG_NUMA_BALANCING should be default n on everything, but probably for 
unknown reasons: ARCH_WANT_NUMA_VARIABLE_LOCALITY isn't default n and 
nothing on x86 actually disables it.

> Cc: mgorman@suse.de
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  mm/mempolicy.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 7431001..8a4dc29 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2530,8 +2530,8 @@ static void __init check_numabalancing_enable(void)
>  		numabalancing_default = true;
>  
>  	if (nr_node_ids > 1 && !numabalancing_override) {
> -		printk(KERN_INFO "Enabling automatic NUMA balancing. "
> -			"Configure with numa_balancing= or sysctl");
> +		pr_info("Enabling automatic NUMA balancing.\n");
> +		pr_info("Change with numa_balancing= or echo -NUMA >/sys/kernel/debug/sched_features\n");
>  		set_numabalancing_state(numabalancing_default);
>  	}
>  }

Shouldn't this be echo NO_NUMA?

/sys/kernel/debug/sched_features only exists for CONFIG_SCHED_DEBUG, so
perhaps suppress this pointer for configs where it's not helpful?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
