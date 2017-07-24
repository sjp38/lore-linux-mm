Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B40916B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 08:38:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 79so10816751wmg.4
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 05:38:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 60si9456721wrq.87.2017.07.24.05.38.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 05:38:50 -0700 (PDT)
Date: Mon, 24 Jul 2017 14:38:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm, page_owner: make init_pages_in_zone() faster
Message-ID: <20170724123843.GH25221@dhcp22.suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
 <20170720134029.25268-2-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170720134029.25268-2-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>

On Thu 20-07-17 15:40:26, Vlastimil Babka wrote:
> In init_pages_in_zone() we currently use the generic set_page_owner() function
> to initialize page_owner info for early allocated pages. This means we
> needlessly do lookup_page_ext() twice for each page, and more importantly
> save_stack(), which has to unwind the stack and find the corresponding stack
> depot handle. Because the stack is always the same for the initialization,
> unwind it once in init_pages_in_zone() and reuse the handle. Also avoid the
> repeated lookup_page_ext().

Yes this looks like an improvement but I have to admit that I do not
really get why we even do save_stack at all here. Those pages might
got allocated from anywhere so we could very well provide a statically
allocated "fake" stack trace, no?

Memory allocated for the stackdepot storage can be tracked inside
depot_alloc_stack as well I guess (again with a statically preallocated
storage).
 
> This can significantly reduce boot times with page_owner=on on large machines,
> especially for kernels built without frame pointer, where the stack unwinding
> is noticeably slower.

Some numbders would be really nice here

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/page_owner.c | 19 ++++++++++++++++++-
>  1 file changed, 18 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 401feb070335..5aa21ca237d9 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -183,6 +183,20 @@ noinline void __set_page_owner(struct page *page, unsigned int order,
>  	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
>  }
>  
> +static void __set_page_owner_init(struct page_ext *page_ext,
> +					depot_stack_handle_t handle)
> +{
> +	struct page_owner *page_owner;
> +
> +	page_owner = get_page_owner(page_ext);
> +	page_owner->handle = handle;
> +	page_owner->order = 0;
> +	page_owner->gfp_mask = 0;
> +	page_owner->last_migrate_reason = -1;
> +
> +	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
> +}

Do we need to duplicated a part of __set_page_owner? Can we pull out
both owner and handle out __set_page_owner?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
