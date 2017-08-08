Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3C06B02F4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 19:06:55 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y129so49201377pgy.1
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 16:06:55 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id t3si1639029plm.534.2017.08.08.16.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 16:06:54 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm: Clear to access sub-page last when clearing huge page
References: <20170807072131.8343-1-ying.huang@intel.com>
	<20170808121220.GA31390@bombadil.infradead.org>
Date: Wed, 09 Aug 2017 07:06:48 +0800
In-Reply-To: <20170808121220.GA31390@bombadil.infradead.org> (Matthew Wilcox's
	message of "Tue, 8 Aug 2017 05:12:20 -0700")
Message-ID: <87y3qt64mv.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>

Matthew Wilcox <willy@infradead.org> writes:

> On Mon, Aug 07, 2017 at 03:21:31PM +0800, Huang, Ying wrote:
>> @@ -2509,7 +2509,8 @@ enum mf_action_page_type {
>>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
>>  extern void clear_huge_page(struct page *page,
>>  			    unsigned long addr,
>> -			    unsigned int pages_per_huge_page);
>> +			    unsigned int pages_per_huge_page,
>> +			    unsigned long addr_hint);
>
> I don't really like adding the extra argument to this function ...
>
>> +++ b/mm/huge_memory.c
>> @@ -549,7 +549,8 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
>>  	struct vm_area_struct *vma = vmf->vma;
>>  	struct mem_cgroup *memcg;
>>  	pgtable_t pgtable;
>> -	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
>> +	unsigned long address = vmf->address;
>> +	unsigned long haddr = address & HPAGE_PMD_MASK;
>>  
>>  	VM_BUG_ON_PAGE(!PageCompound(page), page);
>>  
>> @@ -566,7 +567,7 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
>>  		return VM_FAULT_OOM;
>>  	}
>>  
>> -	clear_huge_page(page, haddr, HPAGE_PMD_NR);
>> +	clear_huge_page(page, haddr, HPAGE_PMD_NR, address);
>>  	/*
>>  	 * The memory barrier inside __SetPageUptodate makes sure that
>>  	 * clear_huge_page writes become visible before the set_pmd_at()
>
> How about calling:
>
> -	clear_huge_page(page, haddr, HPAGE_PMD_NR);
> +	clear_huge_page(page, address, HPAGE_PMD_NR);
>
>> +++ b/mm/memory.c
>> @@ -4363,10 +4363,10 @@ static void clear_gigantic_page(struct page *page,
>>  		clear_user_highpage(p, addr + i * PAGE_SIZE);
>>  	}
>>  }
>> -void clear_huge_page(struct page *page,
>> -		     unsigned long addr, unsigned int pages_per_huge_page)
>> +void clear_huge_page(struct page *page, unsigned long addr,
>> +		     unsigned int pages_per_huge_page, unsigned long addr_hint)
>>  {
>> -	int i;
>> +	int i, n, base, l;
>>  
>>  	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
>>  		clear_gigantic_page(page, addr, pages_per_huge_page);
>
> ... and doing this:
>
>  void clear_huge_page(struct page *page,
> -		     unsigned long addr, unsigned int pages_per_huge_page)
> +		     unsigned long addr_hint, unsigned int pages_per_huge_page)
>  {
> -	int i;
> +	int i, n, base, l;
> +	unsigned long addr = addr_hint &
> +				(1UL << (pages_per_huge_page + PAGE_SHIFT));
>
>> @@ -4374,9 +4374,31 @@ void clear_huge_page(struct page *page,
>>  	}
>>  
>>  	might_sleep();
>> -	for (i = 0; i < pages_per_huge_page; i++) {
>> +	VM_BUG_ON(clamp(addr_hint, addr, addr +
>> +			(pages_per_huge_page << PAGE_SHIFT)) != addr_hint);
>
> ... then you can ditch this check

Yes.  This looks good for me.  If there is no objection, I will go this
way in the next version.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
