Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E58D46B02F4
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:02:38 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f49so12178178wrf.5
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 05:02:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g132si3890875wme.105.2017.06.23.05.02.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 05:02:37 -0700 (PDT)
Date: Fri, 23 Jun 2017 14:02:33 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, swap: don't disable preemption while taking the
 per-CPU cache
Message-ID: <20170623120233.GR5308@dhcp22.suse.cz>
References: <20170623101254.k4zzbf3dfoukoxkq@linutronix.de>
 <20170623103423.GJ5308@dhcp22.suse.cz>
 <20170623114755.2ebxdysacvgxzott@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170623114755.2ebxdysacvgxzott@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, tglx@linutronix.de, ying.huang@intel.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri 23-06-17 13:47:55, Sebastian Andrzej Siewior wrote:
> get_cpu_var() disables preemption and returns the per-CPU version of the
> variable. Disabling preemption is useful to ensure atomic access to the
> variable within the critical section.
> In this case however, after the per-CPU version of the variable is
> obtained the ->free_lock is acquired. For that reason it seems the raw
> accessor could be used. It only seems that ->slots_ret should be
> retested (because with disabled preemption this variable can not be set
> to NULL otherwise).
> This popped up during PREEMPT-RT testing because it tries to take
> spinlocks in a preempt disabled section.

Ohh, because the spinlock can sleep with PREEMPT-RT right? Don't we have
much more places like that? It is perfectly valid to take a spinlock
while the preemption is disabled. E.g. we do take ptl lock inside
kmap_atomic sections which disables preemption on 32b systems.

> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> On 2017-06-23 12:34:23 [+0200], Michal Hocko wrote:
> > The changelog doesn't explain, why does this change matter. Disabling
> > preemption shortly before taking a spinlock shouldn't make much
> > difference. I suspect you care because of RT, right? In that case spell
> > that in the changelog and explain why it matters.
> 
> yes, it is bad for RT. I added the RT pieces as explanation.
> 
> > Other than hat the patch looks good to me.
> 
> Thank you. +akpm.
> 
>  mm/swap_slots.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/swap_slots.c b/mm/swap_slots.c
> index 58f6c78f1dad..51c304477482 100644
> --- a/mm/swap_slots.c
> +++ b/mm/swap_slots.c
> @@ -272,11 +272,11 @@ int free_swap_slot(swp_entry_t entry)
>  {
>  	struct swap_slots_cache *cache;
>  
> -	cache = &get_cpu_var(swp_slots);
> +	cache = raw_cpu_ptr(&swp_slots);
>  	if (use_swap_slot_cache && cache->slots_ret) {
>  		spin_lock_irq(&cache->free_lock);
>  		/* Swap slots cache may be deactivated before acquiring lock */
> -		if (!use_swap_slot_cache) {
> +		if (!use_swap_slot_cache || !cache->slots_ret) {
>  			spin_unlock_irq(&cache->free_lock);
>  			goto direct_free;
>  		}
> @@ -296,7 +296,6 @@ int free_swap_slot(swp_entry_t entry)
>  direct_free:
>  		swapcache_free_entries(&entry, 1);
>  	}
> -	put_cpu_var(swp_slots);
>  
>  	return 0;
>  }
> -- 
> 2.13.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
