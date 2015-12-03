Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id B6B9E6B025B
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 11:27:21 -0500 (EST)
Received: by wmww144 with SMTP id w144so28393298wmw.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 08:27:21 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id x11si6061043wju.95.2015.12.03.08.27.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 08:27:20 -0800 (PST)
Received: by wmww144 with SMTP id w144so28392724wmw.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 08:27:20 -0800 (PST)
Date: Thu, 3 Dec 2015 17:27:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memcontrol.c: use list_{first,next}_entry
Message-ID: <20151203162718.GK9264@dhcp22.suse.cz>
References: <9e62e3006561653fcbf0c49cf0b9c2b653a8ed0e.1449152124.git.geliangtang@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e62e3006561653fcbf0c49cf0b9c2b653a8ed0e.1449152124.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-12-15 22:16:55, Geliang Tang wrote:
> To make the intention clearer, use list_{first,next}_entry instead
> of list_entry.

Does this really help readability? This function simply uncharges the
given list of pages. Why cannot we simply use list_for_each_entry
instead...

> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  mm/memcontrol.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 79a29d5..a6301ea 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5395,16 +5395,12 @@ static void uncharge_list(struct list_head *page_list)
>  	unsigned long nr_file = 0;
>  	unsigned long nr_huge = 0;
>  	unsigned long pgpgout = 0;
> -	struct list_head *next;
>  	struct page *page;
>  
> -	next = page_list->next;
> +	page = list_first_entry(page_list, struct page, lru);
>  	do {
>  		unsigned int nr_pages = 1;
>  
> -		page = list_entry(next, struct page, lru);
> -		next = page->lru.next;
> -
>  		VM_BUG_ON_PAGE(PageLRU(page), page);
>  		VM_BUG_ON_PAGE(page_count(page), page);
>  
> @@ -5440,7 +5436,8 @@ static void uncharge_list(struct list_head *page_list)
>  		page->mem_cgroup = NULL;
>  
>  		pgpgout++;
> -	} while (next != page_list);
> +	} while (!list_is_last(&page->lru, page_list) &&
> +		 (page = list_next_entry(page, lru)));
>  
>  	if (memcg)
>  		uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
> -- 
> 2.5.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
