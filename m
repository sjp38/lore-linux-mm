Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 99EA36B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 00:14:44 -0500 (EST)
Received: by pfdd184 with SMTP id d184so5962033pfd.3
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 21:14:44 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id cm4si2556431pad.81.2015.12.07.21.14.43
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 21:14:43 -0800 (PST)
Date: Tue, 8 Dec 2015 13:14:39 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC 0/3] reduce latency of direct async compaction
Message-ID: <20151208051439.GA20797@aaronlu.sh.intel.com>
References: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
 <20151203092525.GA20945@aaronlu.sh.intel.com>
 <56600DAA.4050208@suse.cz>
 <20151203113508.GA23780@aaronlu.sh.intel.com>
 <20151203115255.GA24773@aaronlu.sh.intel.com>
 <56618841.2080808@suse.cz>
 <20151207073523.GA27292@js1304-P5Q-DELUXE>
 <20151207085956.GA16783@aaronlu.sh.intel.com>
 <20151208004118.GA4325@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="5mCyUwZo2JvN/JJP"
Content-Disposition: inline
In-Reply-To: <20151208004118.GA4325@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Dec 08, 2015 at 09:41:18AM +0900, Joonsoo Kim wrote:
> On Mon, Dec 07, 2015 at 04:59:56PM +0800, Aaron Lu wrote:
> > On Mon, Dec 07, 2015 at 04:35:24PM +0900, Joonsoo Kim wrote:
> > > It looks like overhead still remain. I guess that migration scanner
> > > would call pageblock_pfn_to_page() for more extended range so
> > > overhead still remain.
> > > 
> > > I have an idea to solve his problem. Aaron, could you test following patch
> > > on top of base? It tries to skip calling pageblock_pfn_to_page()
> > 
> > It doesn't apply on top of 25364a9e54fb8296837061bf684b76d20eec01fb
> > cleanly, so I made some changes to make it apply and the result is:
> > https://github.com/aaronlu/linux/commit/cb8d05829190b806ad3948ff9b9e08c8ba1daf63
> 
> Yes, that's okay. I made it on my working branch but it will not result in
> any problem except applying.
> 
> > 
> > There is a problem occured right after the test starts:
> > [   58.080962] BUG: unable to handle kernel paging request at ffffea0082000018
> > [   58.089124] IP: [<ffffffff81193f29>] compaction_alloc+0xf9/0x270
> > [   58.096109] PGD 107ffd6067 PUD 207f7d5067 PMD 0
> > [   58.101569] Oops: 0000 [#1] SMP 
> 
> I did some mistake. Please test following patch. It is also made
> on my working branch so you need to resolve conflict but it would be
> trivial.
> 
> I inserted some logs to check whether zone is contiguous or not.
> Please check that normal zone is set to contiguous after testing.

Yes it is contiguous, but unfortunately, the problem remains:
[   56.536930] check_zone_contiguous: Normal
[   56.543467] check_zone_contiguous: Normal: contiguous
[   56.549640] BUG: unable to handle kernel paging request at ffffea0082000018
[   56.557717] IP: [<ffffffff81193f29>] compaction_alloc+0xf9/0x270
[   56.564719] PGD 107ffd6067 PUD 207f7d5067 PMD 0

Full dmesg attached.

Thanks,
Aaron

> 
> Thanks.
> 
> ------>8------
> From 4a1a08d8ab3fb165b87ad2ec0a2000ff6892330f Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Mon, 7 Dec 2015 14:51:42 +0900
> Subject: [PATCH] mm/compaction: Optimize pageblock_pfn_to_page() for
>  contiguous zone
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/mmzone.h |  1 +
>  mm/compaction.c        | 54 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 54 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e23a9e7..573f9a9 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -521,6 +521,7 @@ struct zone {
>  #endif
>  
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> +       int                     contiguous;
>         /* Set to true when the PG_migrate_skip bits should be cleared */
>         bool                    compact_blockskip_flush;
>  #endif
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 67b8d90..cb5c7a2 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -88,7 +88,7 @@ static inline bool migrate_async_suitable(int migratetype)
>   * the first and last page of a pageblock and avoid checking each individual
>   * page in a pageblock.
>   */
> -static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> +static struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
>                                 unsigned long end_pfn, struct zone *zone)
>  {
>         struct page *start_page;
> @@ -114,6 +114,56 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
>         return start_page;
>  }
>  
> +static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> +                               unsigned long end_pfn, struct zone *zone)
> +{
> +       if (zone->contiguous == 1)
> +               return pfn_to_page(start_pfn);
> +
> +       return __pageblock_pfn_to_page(start_pfn, end_pfn, zone);
> +}
> +
> +static void check_zone_contiguous(struct zone *zone)
> +{
> +       unsigned long block_start_pfn = zone->zone_start_pfn;
> +       unsigned long block_end_pfn;
> +       unsigned long pfn;
> +
> +       /* Already checked */
> +       if (zone->contiguous)
> +               return;
> +
> +       printk("%s: %s\n", __func__, zone->name);
> +       block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
> +       for (; block_start_pfn < zone_end_pfn(zone);
> +               block_start_pfn = block_end_pfn,
> +               block_end_pfn += pageblock_nr_pages) {
> +
> +               block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
> +
> +               if (!__pageblock_pfn_to_page(block_start_pfn,
> +                                       block_end_pfn, zone)) {
> +                       /* We have hole */
> +                       zone->contiguous = -1;
> +                       printk("%s: %s: uncontiguous\n", __func__, zone->name);
> +                       return;
> +               }
> +
> +               /* Check validity of pfn within pageblock */
> +               for (pfn = block_start_pfn; pfn < block_end_pfn; pfn++) {
> +                       if (!pfn_valid_within(pfn)) {
> +                               zone->contiguous = -1;
> +                               printk("%s: %s: uncontiguous\n", __func__, zone->name);
> +                               return;
> +                       }
> +               }
> +       }
> +
> +       /* We don't have hole */
> +       zone->contiguous = 1;
> +       printk("%s: %s: contiguous\n", __func__, zone->name);
> +}
> +
>  #ifdef CONFIG_COMPACTION
>  
>  /* Do not skip compaction more than 64 times */
> @@ -1353,6 +1403,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>                 ;
>         }
>  
> +       check_zone_contiguous(zone);
> +
>         /*
>          * Clear pageblock skip if there were failures recently and compaction
>          * is about to be retried after being deferred. kswapd does not do
> -- 
> 1.9.1
> 

--5mCyUwZo2JvN/JJP
Content-Type: application/x-xz
Content-Disposition: attachment; filename="dmesg.xz"
Content-Transfer-Encoding: base64

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
WVo=

--5mCyUwZo2JvN/JJP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
