Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 15BD86B0038
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 22:48:04 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 79so146627109pgf.2
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 19:48:04 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p7si7150715pfb.260.2017.03.19.19.48.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 19:48:03 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm, swap: VMA based swap readahead
References: <20170314092538.32649-1-ying.huang@intel.com>
	<20170320010140.GA19343@linux.intel.com>
Date: Mon, 20 Mar 2017 10:47:57 +0800
In-Reply-To: <20170320010140.GA19343@linux.intel.com> (Tim Chen's message of
	"Sun, 19 Mar 2017 18:01:41 -0700")
Message-ID: <871stsbr4y.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Minchan Kim <minchan@kernel.org>, Dmitry Safonov <dsafonov@virtuozzo.com>, Mark Rutland <mark.rutland@arm.com>, Vegard Nossum <vegard.nossum@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dave Jiang <dave.jiang@intel.com>, Hugh Dickins <hughd@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi, Tim,

Tim Chen <tim.c.chen@linux.intel.com> writes:

> On Tue, Mar 14, 2017 at 05:25:29PM +0800, Huang, Ying wrote:
>> +struct page *do_swap_page_readahead(struct vm_fault *vmf,
>> +				    struct vma_swap_readahead *swap_ra,
>> +				    swp_entry_t fentry,
>> +				    struct page *fpage)
>> +{
>> +	struct blk_plug plug;
>> +	struct vm_area_struct *vma = vmf->vma;
>> +	struct page *page;
>> +	unsigned long addr;
>> +	pte_t *pte, pentry;
>> +	gfp_t gfp_mask;
>> +	swp_entry_t entry;
>> +	int i, alloc = 0, count;
>> +	bool page_allocated;
>> +
>> +	addr = vmf->address & PAGE_MASK;
>> +	blk_start_plug(&plug);
>> +	if (!fpage) {
>> +		fpage = __read_swap_cache_async(fentry, GFP_HIGHUSER_MOVABLE,
>> +						vma, addr, &page_allocated);
>> +		if (!fpage) {
>> +			blk_finish_plug(&plug);
>> +			return NULL;
>> +		}
>> +		if (page_allocated) {
>> +			alloc++;
>> +			swap_readpage(fpage);
>> +		}
>
> Do you need to add here a put_page as there's a get_page
> in __read-swap_cache_async?

I don't call put_page() here because the page will be mapped to process
page table.

> 		put_page(fpage);
>
> I think there is no put_page on the returned page when you return from
> do_swap_page_readahead.

In the original swapin_readahead(), the read_swap_cache_async() will be
called for the fault swap entry again in the end of the function, and
pug_page() is not called there.

Best Regards,
Huang, Ying

> Thanks.
>
> Tim
>
>> +	}
>> +	/* fault page has been checked */
>> +	count = 1;
>> +	addr += PAGE_SIZE * swap_ra->direction;
>> +	pte = swap_ra->ptes;
>> +	if (swap_ra->direction < 0)
>> +		pte += swap_ra->nr_pte - 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
