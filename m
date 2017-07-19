Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E446A6B02C3
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 09:33:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 65so26971wmf.2
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 06:33:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s12si278884wra.514.2017.07.19.06.33.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 06:33:33 -0700 (PDT)
Subject: Re: [PATCH 4/9] mm, memory_hotplug: drop zone from
 build_all_zonelists
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-5-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d32539e9-8ac3-7536-a205-8953d436b301@suse.cz>
Date: Wed, 19 Jul 2017 15:33:32 +0200
MIME-Version: 1.0
In-Reply-To: <20170714080006.7250-5-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Wen Congyang <wency@cn.fujitsu.com>

On 07/14/2017 10:00 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> build_all_zonelists gets a zone parameter to initialize zone's
> pagesets. There is only a single user which gives a non-NULL
> zone parameter and that one doesn't really need the rest of the
> build_all_zonelists (see 6dcd73d7011b ("memory-hotplug: allocate zone's
> pcp before onlining pages")).
> 
> Therefore remove setup_zone_pageset from build_all_zonelists and call it
> from its only user directly. This will also remove a pointless zonlists
> rebuilding which is always good.
> 
> Cc: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

with a small point below

...

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ebc3311555b1..00e117922b3f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5065,7 +5065,6 @@ static void build_zonelists(pg_data_t *pgdat)
>  static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch);
>  static DEFINE_PER_CPU(struct per_cpu_pageset, boot_pageset);
>  static DEFINE_PER_CPU(struct per_cpu_nodestat, boot_nodestats);
> -static void setup_zone_pageset(struct zone *zone);
>  
>  /*
>   * Global mutex to protect against size modification of zonelists
> @@ -5146,19 +5145,14 @@ build_all_zonelists_init(void)
>   * unless system_state == SYSTEM_BOOTING.
>   *
>   * __ref due to (1) call of __meminit annotated setup_zone_pageset

Isn't the whole (1) in the comment invalid now?

> - * [we're only called with non-NULL zone through __meminit paths] and
> - * (2) call of __init annotated helper build_all_zonelists_init
> + * and (2) call of __init annotated helper build_all_zonelists_init
>   * [protected by SYSTEM_BOOTING].
>   */
> -void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
> +void __ref build_all_zonelists(pg_data_t *pgdat)
>  {
>  	if (system_state == SYSTEM_BOOTING) {
>  		build_all_zonelists_init();
>  	} else {
> -#ifdef CONFIG_MEMORY_HOTPLUG
> -		if (zone)
> -			setup_zone_pageset(zone);
> -#endif
>  		/* we have to stop all cpus to guarantee there is no user
>  		   of zonelist */
>  		stop_machine_cpuslocked(__build_all_zonelists, pgdat, NULL);
> @@ -5432,7 +5426,7 @@ static void __meminit zone_pageset_init(struct zone *zone, int cpu)
>  	pageset_set_high_and_batch(zone, pcp);
>  }
>  
> -static void __meminit setup_zone_pageset(struct zone *zone)
> +void __meminit setup_zone_pageset(struct zone *zone)
>  {
>  	int cpu;
>  	zone->pageset = alloc_percpu(struct per_cpu_pageset);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
