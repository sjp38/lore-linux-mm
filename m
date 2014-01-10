Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id C11E56B0037
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 03:49:48 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so4186932pbb.4
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 00:49:48 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id pu3si6473701pbc.30.2014.01.10.00.49.46
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 00:49:47 -0800 (PST)
Date: Fri, 10 Jan 2014 17:50:05 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/7] mm/cma: fix cma free page accounting
Message-ID: <20140110085005.GB22058@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1389251087-10224-3-git-send-email-iamjoonsoo.kim@lge.com>
 <52CF1045.30903@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52CF1045.30903@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 09, 2014 at 01:10:29PM -0800, Laura Abbott wrote:
> On 1/8/2014 11:04 PM, Joonsoo Kim wrote:
> >Cma pages can be allocated by not only order 0 request but also high order
> >request. So, we should consider to account free cma page in the both
> >places.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index b36aa5a..1489c301 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -1091,6 +1091,12 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
> >  							  start_migratetype,
> >  							  migratetype);
> >
> >+			/* CMA pages cannot be stolen */
> >+			if (is_migrate_cma(migratetype)) {
> >+				__mod_zone_page_state(zone,
> >+					NR_FREE_CMA_PAGES, -(1 << order));
> >+			}
> >+
> >  			/* Remove the page from the freelists */
> >  			list_del(&page->lru);
> >  			rmv_page_order(page);
> >@@ -1175,9 +1181,6 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
> >  		}
> >  		set_freepage_migratetype(page, mt);
> >  		list = &page->lru;
> >-		if (is_migrate_cma(mt))
> >-			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> >-					      -(1 << order));
> >  	}
> >  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> >  	spin_unlock(&zone->lock);
> >
> 
> Wouldn't this result in double counting? in the buffered_rmqueue non
> zero ordered request we call __mod_zone_freepage_state which already
> accounts for CMA pages if the migrate type is CMA so it seems like
> we would get hit twice:
> 
> buffered_rmqueue
>    __rmqueue
>        __rmqueue_fallback
>            decrement
>    __mod_zone_freepage_state
>       decrement
> 

Hello, Laura.

You are right. I missed it. I will drop this patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
