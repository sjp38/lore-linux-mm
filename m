Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA478E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 10:29:39 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so9176534ede.19
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:29:39 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a4-v6si387640ejt.250.2018.12.17.07.29.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 07:29:38 -0800 (PST)
Date: Mon, 17 Dec 2018 16:29:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181217152936.GR30879@dhcp22.suse.cz>
References: <20181217150651.16176-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217150651.16176-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 17-12-18 16:06:51, Oscar Salvador wrote:
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a6e7bfd18cde..18d41e85f672 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8038,11 +8038,12 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  		 * handle each tail page individually in migration.
>  		 */
>  		if (PageHuge(page)) {
> +			struct page *head = compound_head(page);
>  
> -			if (!hugepage_migration_supported(page_hstate(page)))
> +			if (!hugepage_migration_supported(page_hstate(head)))
>  				goto unmovable;

OK, this makes sense.

>  
> -			iter = round_up(iter + 1, 1<<compound_order(page)) - 1;
> +			iter = round_up(iter + 1, 1<<compound_order(head)) - 1;

but this less so. You surely do not want to move by the full hugetlb
page when you got a tail page, right? You could skip too much. You have
to consider page - head into the equation.

Btw. the reason we haven't seen before is that a) giga pages are rarely
used and b) normale hugepages should be properly aligned and they do not
span more mem sections. Maybe there is some obscure path to trigger this
for CMA but I do not see it.

>  			continue;
>  		}
>  
> -- 
> 2.13.7

-- 
Michal Hocko
SUSE Labs
