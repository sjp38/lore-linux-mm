Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id B26B982BDA
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 01:27:47 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y10so839498pdj.9
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 22:27:47 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id km1si3301241pbc.143.2014.10.23.22.27.45
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 22:27:46 -0700 (PDT)
Date: Fri, 24 Oct 2014 14:28:50 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 4/4] (CMA_AGGRESSIVE) Update page alloc function
Message-ID: <20141024052849.GF15243@js1304-P5Q-DELUXE>
References: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com>
 <1413430551-22392-5-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413430551-22392-5-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: rjw@rjwysocki.net, len.brown@intel.com, pavel@ucw.cz, m.szyprowski@samsung.com, akpm@linux-foundation.org, mina86@mina86.com, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, minchan@kernel.org, nasa4836@gmail.com, ddstreet@ieee.org, hughd@google.com, mingo@kernel.org, rientjes@google.com, peterz@infradead.org, keescook@chromium.org, atomlin@redhat.com, raistlin@linux.it, axboe@fb.com, paulmck@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, k.khlebnikov@samsung.com, msalter@redhat.com, deller@gmx.de, tangchen@cn.fujitsu.com, ben@decadent.org.uk, akinobu.mita@gmail.com, lauraa@codeaurora.org, vbabka@suse.cz, sasha.levin@oracle.com, vdavydov@parallels.com, suleiman@google.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 16, 2014 at 11:35:51AM +0800, Hui Zhu wrote:
> If page alloc function __rmqueue try to get pages from MIGRATE_MOVABLE and
> conditions (cma_alloc_counter, cma_aggressive_free_min, cma_alloc_counter)
> allow, MIGRATE_CMA will be allocated as MIGRATE_MOVABLE first.
> 
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> ---
>  mm/page_alloc.c | 42 +++++++++++++++++++++++++++++++-----------
>  1 file changed, 31 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 736d8e1..87bc326 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -65,6 +65,10 @@
>  #include <asm/div64.h>
>  #include "internal.h"
>  
> +#ifdef CONFIG_CMA_AGGRESSIVE
> +#include <linux/cma.h>
> +#endif
> +
>  /* prevent >1 _updater_ of zone percpu pageset ->high and ->batch fields */
>  static DEFINE_MUTEX(pcp_batch_high_lock);
>  #define MIN_PERCPU_PAGELIST_FRACTION	(8)
> @@ -1189,20 +1193,36 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
>  {
>  	struct page *page;
>  
> -retry_reserve:
> +#ifdef CONFIG_CMA_AGGRESSIVE
> +	if (cma_aggressive_switch
> +	    && migratetype == MIGRATE_MOVABLE
> +	    && atomic_read(&cma_alloc_counter) == 0
> +	    && global_page_state(NR_FREE_CMA_PAGES) > cma_aggressive_free_min
> +							+ (1 << order))
> +		migratetype = MIGRATE_CMA;
> +#endif
> +retry:

I don't get it why cma_alloc_counter should be tested.
When cma alloc is progress, pageblock is isolated so that pages on that
pageblock cannot be allocated. Why should we prevent aggressive
allocation in this case?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
