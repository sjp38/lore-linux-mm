Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 950ED6B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 21:32:08 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so1852098pdj.15
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 18:32:08 -0700 (PDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so1599247pbc.16
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 18:32:05 -0700 (PDT)
Date: Wed, 16 Oct 2013 18:32:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 1/8] mm: pcp: rename percpu pageset functions
In-Reply-To: <20131015203538.35606A47@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.02.1310161831090.15575@chino.kir.corp.google.com>
References: <20131015203536.1475C2BE@viggo.jf.intel.com> <20131015203538.35606A47@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cody P Schafer <cody@linux.vnet.ibm.com>, Andi Kleen <ak@linux.intel.com>, cl@gentwo.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

On Tue, 15 Oct 2013, Dave Hansen wrote:

> diff -puN mm/page_alloc.c~rename-pageset-functions mm/page_alloc.c
> --- linux.git/mm/page_alloc.c~rename-pageset-functions	2013-10-15 09:57:05.870612107 -0700
> +++ linux.git-davehans/mm/page_alloc.c	2013-10-15 09:57:05.875612329 -0700
> @@ -4136,10 +4136,18 @@ static void pageset_update(struct per_cp
>  	pcp->batch = batch;
>  }
>  
> -/* a companion to pageset_set_high() */
> -static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
> +/*
> + * Set the batch size for hot per_cpu_pagelist, and derive
> + * the high water mark from the batch size.
> + */
> +static void pageset_setup_from_batch_size(struct per_cpu_pageset *p,
> +					unsigned long batch)
>  {
> -	pageset_update(&p->pcp, 6 * batch, max(1UL, 1 * batch));
> +	unsigned long high;
> +	high = 6 * batch;
> +	if (!batch)
> +		batch = 1;

high = 6 * batch should be here?

> +	pageset_update(&p->pcp, high, batch);
>  }
>  
>  static void pageset_init(struct per_cpu_pageset *p)
> @@ -4158,15 +4166,15 @@ static void pageset_init(struct per_cpu_
>  static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
>  {
>  	pageset_init(p);
> -	pageset_set_batch(p, batch);
> +	pageset_setup_from_batch_size(p, batch);
>  }
>  
>  /*
> - * pageset_set_high() sets the high water mark for hot per_cpu_pagelist
> - * to the value high for the pageset p.
> + * Set the high water mark for the per_cpu_pagelist, and derive
> + * the batch size from this high mark.
>   */
> -static void pageset_set_high(struct per_cpu_pageset *p,
> -				unsigned long high)
> +static void pageset_setup_from_high_mark(struct per_cpu_pageset *p,
> +					unsigned long high)
>  {
>  	unsigned long batch = max(1UL, high / 4);
>  	if ((high / 4) > (PAGE_SHIFT * 8))
> @@ -4179,11 +4187,11 @@ static void __meminit pageset_set_high_a
>  		struct per_cpu_pageset *pcp)
>  {
>  	if (percpu_pagelist_fraction)
> -		pageset_set_high(pcp,
> +		pageset_setup_from_high_mark(pcp,
>  			(zone->managed_pages /
>  				percpu_pagelist_fraction));
>  	else
> -		pageset_set_batch(pcp, zone_batchsize(zone));
> +		pageset_setup_from_batch_size(pcp, zone_batchsize(zone));
>  }
>  
>  static void __meminit zone_pageset_init(struct zone *zone, int cpu)
> @@ -5781,8 +5789,9 @@ int percpu_pagelist_fraction_sysctl_hand
>  		unsigned long  high;
>  		high = zone->managed_pages / percpu_pagelist_fraction;
>  		for_each_possible_cpu(cpu)
> -			pageset_set_high(per_cpu_ptr(zone->pageset, cpu),
> -					 high);
> +			pageset_setup_from_high_mark(
> +					per_cpu_ptr(zone->pageset, cpu),
> +					high);
>  	}
>  	mutex_unlock(&pcp_batch_high_lock);
>  	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
