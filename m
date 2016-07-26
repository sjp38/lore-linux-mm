Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E476E6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 02:24:33 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id l89so132787405lfi.3
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 23:24:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m80si21151258wmi.50.2016.07.25.23.24.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 23:24:32 -0700 (PDT)
Subject: Re: [PATCH] mm: walk the zone in pageblock_nr_pages steps
References: <1469502526-24486-1-git-send-email-zhongjiang@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7fcafdb1-86fa-9245-674b-db1ae53d1c77@suse.cz>
Date: Tue, 26 Jul 2016 08:24:29 +0200
MIME-Version: 1.0
In-Reply-To: <1469502526-24486-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 07/26/2016 05:08 AM, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>
> when walking the zone, we can happens to the holes. we should not
> align MAX_ORDER_NR_PAGES, so it can skip the normal memory.
>
> In addition, pagetypeinfo_showmixedcount_print reflect fragmentization.
> we hope to get more accurate data. therefore, I decide to fix it.

Can't say I'm happy with another random half-fix. What's the real 
granularity of holes for CONFIG_HOLES_IN_ZONE systems? I suspect it can 
be below pageblock_nr_pages. The pfn_valid_within() mechanism seems 
rather insufficient... it does prevent running unexpectedly into holes 
in the middle of pageblock/MAX_ORDER block, but together with the large 
skipping it doesn't guarantee that we cover all non-holes.

I think in a robust solution, functions such as these should use 
something like PAGE_HOLE_GRANULARITY which equals MAX_ORDER_NR_PAGES for 
!CONFIG_HOLES_IN_ZONE and some arch/config/system specific value for 
CONFIG_HOLES_IN_ZONE. This would then be used in the ALIGN() part.
It could be also used together with pfn_valid_within() in the inner loop 
to skip over holes more quickly (if it's worth).

Also I just learned there's also CONFIG_ARCH_HAS_HOLES_MEMORYMODEL that 
affects a function called memmap_valid_within(). But that one has only 
one caller - pagetypeinfo_showblockcount_print(). Why is it needed there 
and not in pagetypeinfo_showmixedcount_print() (or anywhere else?)

> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/vmstat.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index cb2a67b..3508f74 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1033,7 +1033,7 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
>  	 */
>  	for (; pfn < end_pfn; ) {
>  		if (!pfn_valid(pfn)) {
> -			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
> +			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>  			continue;
>  		}
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
