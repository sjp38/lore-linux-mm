Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6E06B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 06:15:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u16-v6so8482908pfm.15
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 03:15:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g9-v6si762454pgu.294.2018.07.02.03.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 03:15:44 -0700 (PDT)
Date: Mon, 2 Jul 2018 12:15:42 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 6/6] mm: page_mkclean, ttu: handle pinned pages
Message-ID: <20180702101542.fi7ndfkg5fpzodey@quack2.suse.cz>
References: <20180702005654.20369-1-jhubbard@nvidia.com>
 <20180702005654.20369-7-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702005654.20369-7-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Sun 01-07-18 17:56:54, john.hubbard@gmail.com wrote:
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 9d142b9b86dc..c4bc8d216746 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -931,6 +931,7 @@ static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  	int kill = 1, forcekill;
>  	struct page *hpage = *hpagep;
>  	bool mlocked = PageMlocked(hpage);
> +	bool skip_pinned_pages = false;

I'm not sure we can afford to wait for page pins when handling page
poisoning. In an ideal world we should but... But I guess this is for
someone understanding memory poisoning better to judge.

> diff --git a/mm/rmap.c b/mm/rmap.c
> index 6db729dc4c50..c137c43eb2ad 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -879,6 +879,26 @@ int page_referenced(struct page *page,
>  	return pra.referenced;
>  }
>  
> +/* Must be called with pinned_dma_lock held. */
> +static void wait_for_dma_pinned_to_clear(struct page *page)
> +{
> +	struct zone *zone = page_zone(page);
> +
> +	while (PageDmaPinnedFlags(page)) {
> +		spin_unlock(zone_gup_lock(zone));
> +
> +		schedule();
> +
> +		spin_lock(zone_gup_lock(zone));
> +	}
> +}

Ouch, we definitely need something better here. Either reuse the
page_waitqueue() mechanism or create at least a global wait queue for this
(I don't expect too much contention on the waitqueue and even if there
eventually is, we can switch to page_waitqueue() when we find it).  But
this is a no-go...

> +
> +struct page_mkclean_info {
> +	int cleaned;
> +	int skipped;
> +	bool skip_pinned_pages;
> +};
> +
>  static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  			    unsigned long address, void *arg)
>  {
> @@ -889,7 +909,24 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  		.flags = PVMW_SYNC,
>  	};
>  	unsigned long start = address, end;
> -	int *cleaned = arg;
> +	struct page_mkclean_info *mki = (struct page_mkclean_info *)arg;
> +	bool is_dma_pinned;
> +	struct zone *zone = page_zone(page);
> +
> +	/* Serialize with get_user_pages: */
> +	spin_lock(zone_gup_lock(zone));
> +	is_dma_pinned = PageDmaPinned(page);

Hum, why do you do this for each page table this is mapped in? Also the
locking is IMHO going to hurt a lot and we need to avoid it.

What I think needs to happen is that in page_mkclean(), after you've
cleared all the page tables, you check PageDmaPinned() and wait if needed.
Page cannot be faulted in again as we hold page lock and so races with
concurrent GUP are fairly limited. So with some careful ordering & memory
barriers you should be able to get away without any locking. Ditto for the
unmap path...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
