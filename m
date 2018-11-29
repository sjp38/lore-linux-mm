Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E72B6B517A
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 03:17:07 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t2so688633edb.22
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 00:17:07 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8-v6si740883ejj.94.2018.11.29.00.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 00:17:05 -0800 (PST)
Date: Thu, 29 Nov 2018 09:17:03 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, show_mem: drop pgdat_resize_lock in show_mem()
Message-ID: <20181129081703.GN6923@dhcp22.suse.cz>
References: <20181128210815.2134-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181128210815.2134-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, jweiner@fb.com, linux-mm@kvack.org

On Thu 29-11-18 05:08:15, Wei Yang wrote:
> Function show_mem() is used to print system memory status when user
> requires or fail to allocate memory. Generally, this is a best effort
> information and not willing to affect core mm subsystem.

I would drop the part after and

> The data protected by pgdat_resize_lock is mostly correct except there is:
> 
>    * page struct defer init
>    * memory hotplug

This is more confusing than helpful. I would just drop it.

The changelog doesn't explain what is done and why. The second one is
much more important. I would say this

"
Function show_mem() is used to print system memory status when user
requires or fail to allocate memory. Generally, this is a best effort
information so any races with memory hotplug (or very theoretically an
early initialization) should be toleratable and the worst that could
happen is to print an imprecise node state.

Drop the resize lock because this is the only place which might hold the
lock from the interrupt context and so all other callers might use a
simple spinlock. Even though this doesn't solve any real issue it makes
the code easier to follow and tiny more effective.
"

> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  lib/show_mem.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/lib/show_mem.c b/lib/show_mem.c
> index 0beaa1d899aa..1d996e5771ab 100644
> --- a/lib/show_mem.c
> +++ b/lib/show_mem.c
> @@ -21,7 +21,6 @@ void show_mem(unsigned int filter, nodemask_t *nodemask)
>  		unsigned long flags;

btw. you want to drop flags.
>  		int zoneid;
>  
> -		pgdat_resize_lock(pgdat, &flags);
>  		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
>  			struct zone *zone = &pgdat->node_zones[zoneid];
>  			if (!populated_zone(zone))
> @@ -33,7 +32,6 @@ void show_mem(unsigned int filter, nodemask_t *nodemask)
>  			if (is_highmem_idx(zoneid))
>  				highmem += zone->present_pages;
>  		}
> -		pgdat_resize_unlock(pgdat, &flags);
>  	}
>  
>  	printk("%lu pages RAM\n", total);
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
