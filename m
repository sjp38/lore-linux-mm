Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 330356B0253
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 08:37:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n14so5159724pfh.15
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 05:37:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v14si3402186pgc.214.2017.11.02.05.37.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 05:37:51 -0700 (PDT)
Date: Thu, 2 Nov 2017 13:37:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: drop hotplug lock from lru_add_drain_all
Message-ID: <20171102123749.zwnlsvpoictnmp53@dhcp22.suse.cz>
References: <20171102093613.3616-1-mhocko@kernel.org>
 <20171102093613.3616-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171102093613.3616-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 02-11-17 10:36:13, Michal Hocko wrote:
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 67330a438525..8c6e9c6d194c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6830,8 +6830,12 @@ void __init free_area_init(unsigned long *zones_size)
>  
>  static int page_alloc_cpu_dead(unsigned int cpu)
>  {
> +	unsigned long flags;
>  
> +	local_irq_save(flags);
>  	lru_add_drain_cpu(cpu);
> +	local_irq_restore(flags);
> +
>  	drain_pages(cpu);
  
I was staring into the hotplug code and tried to understand the context
this callback runs in and AFAIU IRQ disabling is not needed at all
because cpuhp_thread_fun runs with IRQ disabled when offlining an online
cpu. I have a bit hard time to follow the code due to all the
indirection so please correct me if I am wrong.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
