Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 31F526B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 02:19:42 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id fs12so103108lab.36
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 23:19:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1365550099-6795-4-git-send-email-cody@linux.vnet.ibm.com>
References: <1365550099-6795-1-git-send-email-cody@linux.vnet.ibm.com>
	<1365550099-6795-4-git-send-email-cody@linux.vnet.ibm.com>
Date: Wed, 10 Apr 2013 09:19:40 +0300
Message-ID: <CAOtvUMdXJSzV5V3WQpDrU1DqzFk4G4RtBLdrgJyGR-AZhY6RNw@mail.gmail.com>
Subject: Re: [PATCH v2 03/10] mm/page_alloc: insert memory barriers to allow
 async update of pcp batch and high
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 10, 2013 at 2:28 AM, Cody P Schafer <cody@linux.vnet.ibm.com> wrote:
> In pageset_set_batch() and setup_pagelist_highmark(), ensure that batch
> is always set to a safe value (1) prior to updating high, and ensure
> that high is fully updated before setting the real value of batch.
>
> Suggested by Gilad Ben-Yossef <gilad@benyossef.com> in this thread:
>
>         https://lkml.org/lkml/2013/4/9/23
>
> Also reproduces his proposed comment.
>
> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
> ---
>  mm/page_alloc.c | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d259599..a07bd4c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4007,11 +4007,26 @@ static int __meminit zone_batchsize(struct zone *zone)
>  #endif
>  }
>
> +static void pageset_update_prep(struct per_cpu_pages *pcp)
> +{
> +       /*
> +        * We're about to mess with PCP in an non atomic fashion.  Put an
> +        * intermediate safe value of batch and make sure it is visible before
> +        * any other change
> +        */
> +       pcp->batch = 1;
> +       smp_wmb();
> +}
> +
>  /* a companion to setup_pagelist_highmark() */
>  static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
>  {
>         struct per_cpu_pages *pcp = &p->pcp;
> +       pageset_update_prep(pcp);
> +
>         pcp->high = 6 * batch;
> +       smp_wmb();
> +
>         pcp->batch = max(1UL, 1 * batch);
>  }
>
> @@ -4039,7 +4054,11 @@ static void setup_pagelist_highmark(struct per_cpu_pageset *p,
>         struct per_cpu_pages *pcp;
>
>         pcp = &p->pcp;
> +       pageset_update_prep(pcp);
> +
>         pcp->high = high;
> +       smp_wmb();
> +
>         pcp->batch = max(1UL, high/4);
>         if ((high/4) > (PAGE_SHIFT * 8))
>                 pcp->batch = PAGE_SHIFT * 8;
> --
> 1.8.2
>

That is very good.
However, now we've created a "protocol" for updating ->high and ->batch:

1. Call pageset_update_prep(pcp)
2. Update ->high
3. smp_wmb()
4. Update ->batch

But that protocol is not documented anywhere and someone  that reads
the code two
years from now will not be aware of it or why it is done like that.

How about if we create:

/*
* pcp->high and pcp->batch values are related and dependent on one another:
* ->batch must never be higher then ->high.
* The following function updates them in a safe manner without a
costly atomic transaction.
*/
static void pageset_update(struct per_cpu_pages *pcp, unsigned int
high, unsigned int batch)
{
       /* start with a fail safe value for batch */
       pcp->batch = 1;
       smp_wmb();

       /* Update high, then batch, in order */
       pcp->high = high;
       smp_wmb();
       pcp->batch = batch;
}

And use that at the update sites? then the protocol becomes explicit.

Thanks,
Gilad.

-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
