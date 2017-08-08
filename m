Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6C66B02FA
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:12:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e74so30660513pfd.12
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:12:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c195si734796pga.622.2017.08.08.05.12.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:12:22 -0700 (PDT)
Date: Tue, 8 Aug 2017 05:12:20 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH -mm] mm: Clear to access sub-page last when clearing huge
 page
Message-ID: <20170808121220.GA31390@bombadil.infradead.org>
References: <20170807072131.8343-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170807072131.8343-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>

On Mon, Aug 07, 2017 at 03:21:31PM +0800, Huang, Ying wrote:
> @@ -2509,7 +2509,8 @@ enum mf_action_page_type {
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
>  extern void clear_huge_page(struct page *page,
>  			    unsigned long addr,
> -			    unsigned int pages_per_huge_page);
> +			    unsigned int pages_per_huge_page,
> +			    unsigned long addr_hint);

I don't really like adding the extra argument to this function ...

> +++ b/mm/huge_memory.c
> @@ -549,7 +549,8 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
>  	struct vm_area_struct *vma = vmf->vma;
>  	struct mem_cgroup *memcg;
>  	pgtable_t pgtable;
> -	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
> +	unsigned long address = vmf->address;
> +	unsigned long haddr = address & HPAGE_PMD_MASK;
>  
>  	VM_BUG_ON_PAGE(!PageCompound(page), page);
>  
> @@ -566,7 +567,7 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
>  		return VM_FAULT_OOM;
>  	}
>  
> -	clear_huge_page(page, haddr, HPAGE_PMD_NR);
> +	clear_huge_page(page, haddr, HPAGE_PMD_NR, address);
>  	/*
>  	 * The memory barrier inside __SetPageUptodate makes sure that
>  	 * clear_huge_page writes become visible before the set_pmd_at()

How about calling:

-	clear_huge_page(page, haddr, HPAGE_PMD_NR);
+	clear_huge_page(page, address, HPAGE_PMD_NR);

> +++ b/mm/memory.c
> @@ -4363,10 +4363,10 @@ static void clear_gigantic_page(struct page *page,
>  		clear_user_highpage(p, addr + i * PAGE_SIZE);
>  	}
>  }
> -void clear_huge_page(struct page *page,
> -		     unsigned long addr, unsigned int pages_per_huge_page)
> +void clear_huge_page(struct page *page, unsigned long addr,
> +		     unsigned int pages_per_huge_page, unsigned long addr_hint)
>  {
> -	int i;
> +	int i, n, base, l;
>  
>  	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
>  		clear_gigantic_page(page, addr, pages_per_huge_page);

... and doing this:

 void clear_huge_page(struct page *page,
-		     unsigned long addr, unsigned int pages_per_huge_page)
+		     unsigned long addr_hint, unsigned int pages_per_huge_page)
 {
-	int i;
+	int i, n, base, l;
+	unsigned long addr = addr_hint &
+				(1UL << (pages_per_huge_page + PAGE_SHIFT));

> @@ -4374,9 +4374,31 @@ void clear_huge_page(struct page *page,
>  	}
>  
>  	might_sleep();
> -	for (i = 0; i < pages_per_huge_page; i++) {
> +	VM_BUG_ON(clamp(addr_hint, addr, addr +
> +			(pages_per_huge_page << PAGE_SHIFT)) != addr_hint);

... then you can ditch this check

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
