Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 98E226B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 11:33:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k7so7101247pga.8
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:33:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bi10si3589977plb.824.2017.10.19.08.33.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 08:33:26 -0700 (PDT)
Date: Thu, 19 Oct 2017 17:33:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/swap: Use page flags to determine LRU list in
 __activate_page()
Message-ID: <20171019153322.c4uqalws7l7fdzcx@dhcp22.suse.cz>
References: <20171019145657.11199-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019145657.11199-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, shli@kernel.org

On Thu 19-10-17 20:26:57, Anshuman Khandual wrote:
> Its already assumed that the PageActive flag is clear on the input
> page, hence page_lru(page) will pick the base LRU for the page. In
> the same way page_lru(page) will pick active base LRU, once the
> flag PageActive is set on the page. This change of LRU list should
> happen implicitly through the page flags instead of being hard
> coded.

The patch description tells what but it doesn't explain _why_? Does the
resulting code is better, more optimized or is this a pure readability
thing?

All I can see is that page_lru is more complex and a large part of it
can be optimized away which has been done manually here. I suspect the
compiler can deduce the same thing.

> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  mm/swap.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index fcd82bc..494276b 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -275,12 +275,10 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
>  {
>  	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
>  		int file = page_is_file_cache(page);
> -		int lru = page_lru_base_type(page);
>  
> -		del_page_from_lru_list(page, lruvec, lru);
> +		del_page_from_lru_list(page, lruvec, page_lru(page));
>  		SetPageActive(page);
> -		lru += LRU_ACTIVE;
> -		add_page_to_lru_list(page, lruvec, lru);
> +		add_page_to_lru_list(page, lruvec, page_lru(page));
>  		trace_mm_lru_activate(page);
>  
>  		__count_vm_event(PGACTIVATE);
> -- 
> 1.8.5.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
