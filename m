Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id B39936B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:56:15 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id k48so4317093wev.12
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 05:56:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cj1si2417731wib.56.2014.07.25.05.56.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 05:56:14 -0700 (PDT)
Date: Fri, 25 Jul 2014 13:56:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V4 14/15] mm, compaction: try to capture the just-created
 high-order freepage
Message-ID: <20140725125608.GI10819@suse.de>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
 <1405518503-27687-15-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1405518503-27687-15-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, Jul 16, 2014 at 03:48:22PM +0200, Vlastimil Babka wrote:
> Compaction uses watermark checking to determine if it succeeded in creating
> a high-order free page. My testing has shown that this is quite racy and it
> can happen that watermark checking in compaction succeeds, and moments later
> the watermark checking in page allocation fails, even though the number of
> free pages has increased meanwhile.
> 
> It should be more reliable if direct compaction captured the high-order free
> page as soon as it detects it, and pass it back to allocation. This would
> also reduce the window for somebody else to allocate the free page.
> 
> Capture has been implemented before by 1fb3f8ca0e92 ("mm: compaction: capture
> a suitable high-order page immediately when it is made available"), but later
> reverted by 8fb74b9f ("mm: compaction: partially revert capture of suitable
> high-order page") due to a bug.
> 
> This patch differs from the previous attempt in two aspects:
> 
> 1) The previous patch scanned free lists to capture the page. In this patch,
>    only the cc->order aligned block that the migration scanner just finished
>    is considered, but only if pages were actually isolated for migration in
>    that block. Tracking cc->order aligned blocks also has benefits for the
>    following patch that skips blocks where non-migratable pages were found.
> 
> 2) The operations done in buffered_rmqueue() and get_page_from_freelist() are
>    closely followed so that page capture mimics normal page allocation as much
>    as possible. This includes operations such as prep_new_page() and
>    page->pfmemalloc setting (that was missing in the previous attempt), zone
>    statistics are updated etc. Due to subtleties with IRQ disabling and
>    enabling this cannot be simply factored out from the normal allocation
>    functions without affecting the fastpath.
> 
> This patch has tripled compaction success rates (as recorded in vmstat) in
> stress-highalloc mmtests benchmark, although allocation success rates increased
> only by a few percent. Closer inspection shows that due to the racy watermark
> checking and lack of lru_add_drain(), the allocations that resulted in direct
> compactions were often failing, but later allocations succeeeded in the fast
> path. So the benefit of the patch to allocation success rates may be limited,
> but it improves the fairness in the sense that whoever spent the time
> compacting has a higher change of benefitting from it, and also can stop
> compacting sooner, as page availability is detected immediately. With better
> success detection, the contribution of compaction to high-order allocation
> success success rates is also no longer understated by the vmstats.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> <SNIP>
> @@ -2279,14 +2307,43 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	count_vm_event(COMPACTSTALL);
>  
> -	/* Page migration frees to the PCP lists but we want merging */
> -	drain_pages(get_cpu());
> -	put_cpu();
> +	/* Did we capture a page? */
> +	if (page) {
> +		struct zone *zone;
> +		unsigned long flags;
> +		/*
> +		 * Mimic what buffered_rmqueue() does and capture_new_page()
> +		 * has not yet done.
> +		 */
> +		zone = page_zone(page);
> +
> +		local_irq_save(flags);
> +		zone_statistics(preferred_zone, zone, gfp_mask);
> +		local_irq_restore(flags);
>  
> -	page = get_page_from_freelist(gfp_mask, nodemask,
> -			order, zonelist, high_zoneidx,
> -			alloc_flags & ~ALLOC_NO_WATERMARKS,
> -			preferred_zone, classzone_idx, migratetype);
> +		VM_BUG_ON_PAGE(bad_range(zone, page), page);
> +		if (!prep_new_page(page, order, gfp_mask))
> +			/* This is normally done in get_page_from_freelist() */
> +			page->pfmemalloc = !!(alloc_flags &
> +					ALLOC_NO_WATERMARKS);
> +		else
> +			page = NULL;
> +	}
> +
> +	/* No capture but let's try allocating anyway */
> +	if (!page) {
> +		/*
> +		 * Page migration frees to the PCP lists but we want
> +		 * merging
> +		 */
> +		drain_pages(get_cpu());
> +		put_cpu();
> +

Would the attempted capture not drained already? Not a big deal so

Acked-by: Mel Gorman <mgorman@suse.de>


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
