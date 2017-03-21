Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4D96B038A
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 09:59:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n11so145059527pfg.7
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 06:59:10 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id u126si15197873pfu.306.2017.03.21.06.59.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 06:59:09 -0700 (PDT)
Message-ID: <1490104745.17719.6.camel@linux.intel.com>
Subject: Re: [PATCH] mm, swap: VMA based swap readahead
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 21 Mar 2017 09:59:05 -0400
In-Reply-To: <871stsbr4y.fsf@yhuang-dev.intel.com>
References: <20170314092538.32649-1-ying.huang@intel.com>
	 <20170320010140.GA19343@linux.intel.com>
	 <871stsbr4y.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Minchan Kim <minchan@kernel.org>, Dmitry Safonov <dsafonov@virtuozzo.com>, Mark Rutland <mark.rutland@arm.com>, Vegard Nossum <vegard.nossum@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, "Aneesh Kumar
 K.V" <aneesh.kumar@linux.vnet.ibm.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dave Jiang <dave.jiang@intel.com>, Hugh Dickins <hughd@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2017-03-20 at 10:47 +0800, Huang, Ying wrote:
> Hi, Tim,
> 
> Tim Chen <tim.c.chen@linux.intel.com> writes:
> 
> > 
> > On Tue, Mar 14, 2017 at 05:25:29PM +0800, Huang, Ying wrote:
> > > 
> > > +struct page *do_swap_page_readahead(struct vm_fault *vmf,
> > > +				A A A A struct vma_swap_readahead *swap_ra,
> > > +				A A A A swp_entry_t fentry,
> > > +				A A A A struct page *fpage)
> > > +{
> > > +	struct blk_plug plug;
> > > +	struct vm_area_struct *vma = vmf->vma;
> > > +	struct page *page;
> > > +	unsigned long addr;
> > > +	pte_t *pte, pentry;
> > > +	gfp_t gfp_mask;
> > > +	swp_entry_t entry;
> > > +	int i, alloc = 0, count;
> > > +	bool page_allocated;
> > > +
> > > +	addr = vmf->address & PAGE_MASK;
> > > +	blk_start_plug(&plug);
> > > +	if (!fpage) {
> > > +		fpage = __read_swap_cache_async(fentry, GFP_HIGHUSER_MOVABLE,
> > > +						vma, addr, &page_allocated);
> > > +		if (!fpage) {
> > > +			blk_finish_plug(&plug);
> > > +			return NULL;
> > > +		}
> > > +		if (page_allocated) {
> > > +			alloc++;
> > > +			swap_readpage(fpage);
> > > +		}
> > Do you need to add here a put_page as there's a get_page
> > in __read-swap_cache_async?
> I don't call put_page() here because the page will be mapped to process
> page table.
> 
> > 
> > 		put_page(fpage);
> > 
> > I think there is no put_page on the returned page when you return from
> > do_swap_page_readahead.
> In the original swapin_readahead(), the read_swap_cache_async() will be
> called for the fault swap entry again in the end of the function, and
> pug_page() is not called there.
> 

I missed the second call to read_swap_cache_async in swapin_readahead.
You're right that we should keep the reference on the faulted page and not call
put_page on fpage here.

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
