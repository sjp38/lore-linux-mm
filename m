Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B86296B0008
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 09:15:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m45-v6so18597991edc.2
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 06:15:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dt1-v6si11878123ejb.243.2018.10.18.06.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 06:15:05 -0700 (PDT)
Date: Thu, 18 Oct 2018 15:15:04 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: get pfn by page_to_pfn() instead of save in
 page->private
Message-ID: <20181018131504.GC18839@dhcp22.suse.cz>
References: <20181018130429.37837-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018130429.37837-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Thu 18-10-18 21:04:29, Wei Yang wrote:
> This is not necessary to save the pfn to page->private.
> 
> The pfn could be retrieved by page_to_pfn() directly.

Yes it can, but a cursory look at the commit which has introduced this
suggests that this is a micro-optimization. Mel would know more of
course. There are some memory models where page_to_pfn is close to free.

If that is the case I am not really sure it is measurable or worth it.
In any case any change to this code should have a proper justification.
In other words, is this change really needed? Does it help in any
aspect? Possibly readability? The only thing I can guess from this
changelog is that you read the code and stumble over this. If that is
the case I would recommend asking author for the motivation and
potentially add a comment to explain it better rather than shoot a patch
rightaway.

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
> Maybe I missed some critical reason to save pfn to private.
> 
> Thanks in advance if someone could reveal the special reason.
> ---
>  mm/page_alloc.c | 13 ++++---------
>  1 file changed, 4 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 15ea511fb41c..a398eafbae46 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2793,24 +2793,19 @@ void free_unref_page(struct page *page)
>  void free_unref_page_list(struct list_head *list)
>  {
>  	struct page *page, *next;
> -	unsigned long flags, pfn;
> +	unsigned long flags;
>  	int batch_count = 0;
>  
>  	/* Prepare pages for freeing */
> -	list_for_each_entry_safe(page, next, list, lru) {
> -		pfn = page_to_pfn(page);
> -		if (!free_unref_page_prepare(page, pfn))
> +	list_for_each_entry_safe(page, next, list, lru)
> +		if (!free_unref_page_prepare(page, page_to_pfn(page)))
>  			list_del(&page->lru);
> -		set_page_private(page, pfn);
> -	}
>  
>  	local_irq_save(flags);
>  	list_for_each_entry_safe(page, next, list, lru) {
> -		unsigned long pfn = page_private(page);
> -
>  		set_page_private(page, 0);
>  		trace_mm_page_free_batched(page);
> -		free_unref_page_commit(page, pfn);
> +		free_unref_page_commit(page, page_to_pfn(page));
>  
>  		/*
>  		 * Guard against excessive IRQ disabled times when we get
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
