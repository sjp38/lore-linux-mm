Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 2505F6B0006
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 21:37:34 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id tp5so5702185ieb.36
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 18:37:33 -0700 (PDT)
Message-ID: <5160CDD8.3050908@gmail.com>
Date: Sun, 07 Apr 2013 09:37:28 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/page_alloc: factor out setting of pcp->high and
 pcp->batch.
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-2-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365194030-28939-2-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Cody,
On 04/06/2013 04:33 AM, Cody P Schafer wrote:
> Creates pageset_set_batch() for use in setup_pageset().
> pageset_set_batch() imitates the functionality of
> setup_pagelist_highmark(), but uses the boot time
> (percpu_pagelist_fraction == 0) calculations for determining ->high

Why need adjust pcp->high, pcp->batch during system running? What's the 
requirement?

> based on ->batch.
>
> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
> ---
>   mm/page_alloc.c | 12 +++++++++---
>   1 file changed, 9 insertions(+), 3 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8fcced7..5877cf0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4004,6 +4004,14 @@ static int __meminit zone_batchsize(struct zone *zone)
>   #endif
>   }
>   
> +/* a companion to setup_pagelist_highmark() */
> +static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
> +{
> +	struct per_cpu_pages *pcp = &p->pcp;
> +	pcp->high = 6 * batch;
> +	pcp->batch = max(1UL, 1 * batch);
> +}
> +
>   static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
>   {
>   	struct per_cpu_pages *pcp;
> @@ -4013,8 +4021,7 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
>   
>   	pcp = &p->pcp;
>   	pcp->count = 0;
> -	pcp->high = 6 * batch;
> -	pcp->batch = max(1UL, 1 * batch);
> +	pageset_set_batch(p, batch);
>   	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
>   		INIT_LIST_HEAD(&pcp->lists[migratetype]);
>   }
> @@ -4023,7 +4030,6 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
>    * setup_pagelist_highmark() sets the high water mark for hot per_cpu_pagelist
>    * to the value high for the pageset p.
>    */
> -
>   static void setup_pagelist_highmark(struct per_cpu_pageset *p,
>   				unsigned long high)
>   {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
