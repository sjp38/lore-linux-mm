Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7740A6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 03:24:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so27305491wmr.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 00:24:09 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id r185si25579379wmr.9.2016.07.20.00.24.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 00:24:06 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i5so5527049wmg.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 00:24:05 -0700 (PDT)
Date: Wed, 20 Jul 2016 09:24:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_owner: Align with pageblock_nr pages
Message-ID: <20160720072404.GD11249@dhcp22.suse.cz>
References: <1468938136-24228-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468938136-24228-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com, zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

On Tue 19-07-16 22:22:16, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> when pfn_valid(pfn) return false, pfn should be align with
> pageblock_nr_pages other than MAX_ORDER_NR_PAGES in
> init_pages_in_zone, because the skipped 2M may be valid pfn,
> as a result, early allocated count will not be accurate.

I really do not understand this changelog. I thought that
MAX_ORDER_NR_PAGES and pageblock_nr_pages are the same thing but they
might not be for HUGETLB. Should init_pages_in_zone depend on something
like HUGETLB? Is this even correct I would have expected that we should
initialize in the page block steps so MAX_ORDER_NR_PAGES. Could you
clarify Joonsoo, please?

> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/page_owner.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index c6cda3e..aa2c486 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -310,7 +310,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  	 */
>  	for (; pfn < end_pfn; ) {
>  		if (!pfn_valid(pfn)) {
> -			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
> +			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>  			continue;
>  		}
>  
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
