Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E98346B0304
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:58:30 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c82so1067059wme.8
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:58:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l15si1013730wrb.144.2017.12.05.16.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:58:29 -0800 (PST)
Date: Tue, 5 Dec 2017 16:58:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm] mm/page_owner: align with pageblock_nr_pages
Message-Id: <20171205165826.aed52f6b6e5ca4cd7994ce31@linux-foundation.org>
In-Reply-To: <1512395284-13588-1-git-send-email-zhongjiang@huawei.com>
References: <1512395284-13588-1-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: mhocko@kernel.org, vbabka@suse.cz, linux-mm@kvack.org

On Mon, 4 Dec 2017 21:48:04 +0800 zhong jiang <zhongjiang@huawei.com> wrote:

> Currently, init_pages_in_zone walk the zone in pageblock_nr_pages
> steps.  MAX_ORDER_NR_PAGES is possible to have holes when
> CONFIG_HOLES_IN_ZONE is set. it is likely to be different between
> MAX_ORDER_NR_PAGES and pageblock_nr_pages. if we skip the size of
> MAX_ORDER_NR_PAGES, it will result in the second 2M memroy leak.
> 
> meanwhile, the change will make the code consistent. because the
> entire function is based on the pageblock_nr_pages steps.
> 
> ...
>
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -527,7 +527,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  	 */
>  	for (; pfn < end_pfn; ) {
>  		if (!pfn_valid(pfn)) {
> -			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
> +			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>  			continue;
>  		}

I *think* Michal and Vlastimil will be OK with this as-newly-presented.
Guys, can you please have another think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
