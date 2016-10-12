Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A51C46B025E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:37:21 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id m10so66638821ith.7
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:37:21 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0251.hostedemail.com. [216.40.44.251])
        by mx.google.com with ESMTPS id 3si5263238ioc.48.2016.10.12.03.37.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 03:37:21 -0700 (PDT)
Message-ID: <1476268638.16823.5.camel@perches.com>
Subject: Re: [PATCH] mm: page_alloc: Use KERN_CONT where appropriate
From: Joe Perches <joe@perches.com>
Date: Wed, 12 Oct 2016 03:37:18 -0700
In-Reply-To: <20161012091013.GB9523@dhcp22.suse.cz>
References: 
	  <c7df37c8665134654a17aaeb8b9f6ace1d6db58b.1476239034.git.joe@perches.com>
	 <20161012091013.GB9523@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

(resending as lkml bounced)

On Wed, 2016-10-12 at 11:10 +0200, Michal Hocko wrote:
> On Tue 11-10-16 19:24:55, Joe Perches wrote:
> > Recent changes to printk require KERN_CONT uses to continue logging
> > messages.  So add KERN_CONT where necessary.
> 
> 
> 
> I was really wondering what happened when Aaron reported an allocation
> failure http://lkml.kernel.org/r/20161012065423.GA16092@aaronlu.sh.intel.com
> See the attached log got the current Linus' tree
> 
> Fixes: 4bcc595ccd80 ("printk: reinstate KERN_CONT for printing continuation lines")
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> 
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> I believe we can simplify the code a bit as well. What do you think
> about the following on top?


Hi Michal

I think the show_node to show_zone_node renaming is superfluous,
but if it makes you happy, it doesn't bother me.

This recent change to printk logging making KERN_CONT necessary to
continue a line might be reverted when it's better known just how
many instances in the kernel tree will need to be changed.

For now, I'd rather keep the KERN_CONT "\n" and trailing "\n" as
there are _very_ few missing newlines in logging messages today
and removing them now might be a bit early process-wise.

Dunno.

> --- 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6f8c356140a0..7e1b74ee79cb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4078,10 +4078,12 @@ unsigned long nr_free_pagecache_pages(void)
>  	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
>  }
>  
> -static inline void show_node(struct zone *zone)
> +static inline void show_zone_node(struct zone *zone)
>  {
>  	if (IS_ENABLED(CONFIG_NUMA))
> -		printk("Node %d ", zone_to_nid(zone));
> +		printk("Node %d %s", zone_to_nid(zone), zone->name);
> +	else
> +		printk("%s: ", zone->name);
>  }
>  
>  long si_mem_available(void)
> @@ -4329,9 +4331,8 @@ void show_free_areas(unsigned int filter)
>  		for_each_online_cpu(cpu)
>  			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
>  
> -		show_node(zone);
> +		show_zone_node(zone);
>  		printk(KERN_CONT
> -		        "%s"
>  			" free:%lukB"
>  			" min:%lukB"
>  			" low:%lukB"
> @@ -4354,7 +4355,6 @@ void show_free_areas(unsigned int filter)
>  			" local_pcp:%ukB"
>  			" free_cma:%lukB"
>  			"\n",
> -			zone->name,
>  			K(zone_page_state(zone, NR_FREE_PAGES)),
>  			K(min_wmark_pages(zone)),
>  			K(low_wmark_pages(zone)),
> @@ -4379,7 +4379,6 @@ void show_free_areas(unsigned int filter)
>  		printk("lowmem_reserve[]:");
>  		for (i = 0; i < MAX_NR_ZONES; i++)
>  			printk(KERN_CONT " %ld", zone->lowmem_reserve[i]);
> -		printk(KERN_CONT "\n");
>  	}
>  
>  	for_each_populated_zone(zone) {
> @@ -4389,8 +4388,7 @@ void show_free_areas(unsigned int filter)
>  
>  		if (skip_free_areas_node(filter, zone_to_nid(zone)))
>  			continue;
> -		show_node(zone);
> -		printk(KERN_CONT "%s: ", zone->name);
> +		show_zone_node(zone);
>  
>  		spin_lock_irqsave(&zone->lock, flags);
>  		for (order = 0; order < MAX_ORDER; order++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
