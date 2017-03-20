Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2A196B0388
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 21:02:08 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id x75so32667527vke.5
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 18:02:08 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o2si15594966pga.229.2017.03.19.18.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 18:02:08 -0700 (PDT)
Date: Sun, 19 Mar 2017 18:01:41 -0700
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH] mm, swap: VMA based swap readahead
Message-ID: <20170320010140.GA19343@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
References: <20170314092538.32649-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170314092538.32649-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Minchan Kim <minchan@kernel.org>, Dmitry Safonov <dsafonov@virtuozzo.com>, Mark Rutland <mark.rutland@arm.com>, Vegard Nossum <vegard.nossum@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dave Jiang <dave.jiang@intel.com>, Hugh Dickins <hughd@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 14, 2017 at 05:25:29PM +0800, Huang, Ying wrote:
> +struct page *do_swap_page_readahead(struct vm_fault *vmf,
> +				    struct vma_swap_readahead *swap_ra,
> +				    swp_entry_t fentry,
> +				    struct page *fpage)
> +{
> +	struct blk_plug plug;
> +	struct vm_area_struct *vma = vmf->vma;
> +	struct page *page;
> +	unsigned long addr;
> +	pte_t *pte, pentry;
> +	gfp_t gfp_mask;
> +	swp_entry_t entry;
> +	int i, alloc = 0, count;
> +	bool page_allocated;
> +
> +	addr = vmf->address & PAGE_MASK;
> +	blk_start_plug(&plug);
> +	if (!fpage) {
> +		fpage = __read_swap_cache_async(fentry, GFP_HIGHUSER_MOVABLE,
> +						vma, addr, &page_allocated);
> +		if (!fpage) {
> +			blk_finish_plug(&plug);
> +			return NULL;
> +		}
> +		if (page_allocated) {
> +			alloc++;
> +			swap_readpage(fpage);
> +		}

Do you need to add here a put_page as there's a get_page
in __read-swap_cache_async?

		put_page(fpage);

I think there is no put_page on the returned page when you return from
do_swap_page_readahead.

Thanks.

Tim

> +	}
> +	/* fault page has been checked */
> +	count = 1;
> +	addr += PAGE_SIZE * swap_ra->direction;
> +	pte = swap_ra->ptes;
> +	if (swap_ra->direction < 0)
> +		pte += swap_ra->nr_pte - 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
