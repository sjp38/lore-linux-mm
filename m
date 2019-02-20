Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C3A9C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 19:24:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BB7921848
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 19:24:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BB7921848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A9178E002C; Wed, 20 Feb 2019 14:24:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 730188E0002; Wed, 20 Feb 2019 14:24:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D0EA8E002C; Wed, 20 Feb 2019 14:24:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1654C8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:24:08 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id i3so19542830pfj.4
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 11:24:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pkfe4FMFDh4ctZK2ZVVu7bwPv+keQYbC48NpcJikSvE=;
        b=ZJ+r0/oRF04WDRJRhTSk1aWoej9U0/rE2AFgNt2+6Bc22AKcuirvE51VFBMg6vh6fP
         +zxwC7Vyu7dURP327CEdvQOIimiL3F+0nhBH7ltnfyrkcf+fhPJXhMFoglVeBhzVMfx3
         OtKo675KO0Ihz0DAgd5agL9nmkQTidivfVzwAaDXRp6EegJmJCNFP4vvYipHl/5gQv7I
         oOTwpJGkkoMvgq22ERO+ECmE3Lo/P6O2eL7Cz4YOtdKe52qtAZXHwg0KBwSzQIilBcPV
         fRKb55M+Y4rVy2zQlAAyojIi25HdsVIRzCCnQXF4X6SwlXmPrnKVYh2FVc0Yv1tSgfF5
         paRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaqjVJFjeaZ7XH8GAbZfO/QaHQDh4xHXO1pJASyZomBSfu7jDh/
	i4BlaSF1ga29/Ix3MlId/UAO1YRNhtgH1F8nILba/vtw68usHrQ6m1zyYXptpea2Y59bndMBocL
	tfDZdmJsdQm98iwhcw57CsKy8fEai91QFaUOqBFi7LSEKRBReVsKp3Y33ZNifQq57Tg==
X-Received: by 2002:a17:902:24e7:: with SMTP id l36mr38503873plg.61.1550690647687;
        Wed, 20 Feb 2019 11:24:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJU1llqPYpVF0cZ8y4T684t/NN44ZsFstKAL1lFBgBLtMOrZcT8Jpc5427glePzQLzsKo8
X-Received: by 2002:a17:902:24e7:: with SMTP id l36mr38503802plg.61.1550690646538;
        Wed, 20 Feb 2019 11:24:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550690646; cv=none;
        d=google.com; s=arc-20160816;
        b=OtqB92G4JaJ58BC3e85Bde/Wa7YJtQl38QrdOIHJXrx0kubg3GFq9XGnqZDkYpzrSq
         HQXN8b0qxC4LKX7K4Wa8AAYF9V4ftfK/dSl9vZVSKYUA57agBWxhCMobGlJIF3nI9WD/
         W5Gn8xL6zmi/ThPcdSXQIfiEoLlq/8n477KqziuWT3a1XWnBIW3hiYeBmXSIloG7Z2NZ
         z2SD++iMzkbCLkN9EtIoIP8X0Ar6DY77P0f8xPduhtSxgIdPTE4ueVNv/LnCl4/cWQQX
         VoID6bb7iDopuigKy/1TJKOsohrZ8ls1avQOk1IrfA3tZLZlitw+4BFp4J9i7nGZpqSy
         xJAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pkfe4FMFDh4ctZK2ZVVu7bwPv+keQYbC48NpcJikSvE=;
        b=G+7GRgwzC4xsdzmhQXkeB7HWnjiU5B4qalF6s0lUunkH+oC5rdLPRPLNsFK75eKAPR
         qbG3rPbh8agxVMugn2iXbh2VCZVOq7TIZeNVM3/ltAhCKk7nAznkAnA7kpGhpbpV9ZU0
         RVvtRwzbAFYaA7cpV52kd3Y/3pCVJs18wlwVMvtZOOCzu1lqWfNvZMxaDlZT4M22toNj
         HZuVMfLUY30vSSHhMyKIPf2dNZvVoD46af87NPsUzmZysBzHk1+10p/Gmp2dyL4BhNcG
         akBirIroxk1tUN9HpxiE5AtJoviHp4oouA7XOe98uc6Gfae3RBYnIdeLZiKcDhEgO7DX
         4PxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y8si14389625plr.237.2019.02.20.11.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 11:24:06 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Feb 2019 11:24:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,392,1544515200"; 
   d="scan'208";a="127998904"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 20 Feb 2019 11:24:04 -0800
Date: Wed, 20 Feb 2019 11:24:05 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 4/6] mm/gup: track gup-pinned pages
Message-ID: <20190220192405.GA12114@iweiny-DESK2.sc.intel.com>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
 <20190204052135.25784-5-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190204052135.25784-5-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 03, 2019 at 09:21:33PM -0800, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 

[snip]

>  
> +/*
> + * GUP_PIN_COUNTING_BIAS, and the associated functions that use it, overload
> + * the page's refcount so that two separate items are tracked: the original page
> + * reference count, and also a new count of how many get_user_pages() calls were
> + * made against the page. ("gup-pinned" is another term for the latter).
> + *
> + * With this scheme, get_user_pages() becomes special: such pages are marked
> + * as distinct from normal pages. As such, the new put_user_page() call (and
> + * its variants) must be used in order to release gup-pinned pages.
> + *
> + * Choice of value:
> + *
> + * By making GUP_PIN_COUNTING_BIAS a power of two, debugging of page reference
> + * counts with respect to get_user_pages() and put_user_page() becomes simpler,
> + * due to the fact that adding an even power of two to the page refcount has
> + * the effect of using only the upper N bits, for the code that counts up using
> + * the bias value. This means that the lower bits are left for the exclusive
> + * use of the original code that increments and decrements by one (or at least,
> + * by much smaller values than the bias value).
> + *
> + * Of course, once the lower bits overflow into the upper bits (and this is
> + * OK, because subtraction recovers the original values), then visual inspection
> + * no longer suffices to directly view the separate counts. However, for normal
> + * applications that don't have huge page reference counts, this won't be an
> + * issue.
> + *
> + * This has to work on 32-bit as well as 64-bit systems. In the more constrained
> + * 32-bit systems, the 10 bit value of the bias value leaves 22 bits for the
> + * upper bits. Therefore, only about 4M calls to get_user_page() may occur for
> + * a page.
> + *
> + * Locking: the lockless algorithm described in page_cache_gup_pin_speculative()
> + * and page_cache_gup_pin_speculative() provides safe operation for

Did you mean:

page_cache_gup_pin_speculative and __ page_cache_get_speculative __?

Just found this while looking at your branch.

Sorry,
Ira

> + * get_user_pages and page_mkclean and other calls that race to set up page
> + * table entries.
> + */
> +#define GUP_PIN_COUNTING_BIAS (1UL << 10)
> +
> +int get_gup_pin_page(struct page *page);
> +
> +void put_user_page(struct page *page);
> +void put_user_pages_dirty(struct page **pages, unsigned long npages);
> +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
> +void put_user_pages(struct page **pages, unsigned long npages);
> +
> +/**
> + * page_gup_pinned() - report if a page is gup-pinned (pinned by a call to
> + *			get_user_pages).
> + * @page:	pointer to page to be queried.
> + * @Returns:	True, if it is likely that the page has been "gup-pinned".
> + *		False, if the page is definitely not gup-pinned.
> + */
> +static inline bool page_gup_pinned(struct page *page)
> +{
> +	return (page_ref_count(page)) > GUP_PIN_COUNTING_BIAS;
> +}
> +
>  static inline void get_page(struct page *page)
>  {
>  	page = compound_head(page);
> @@ -993,30 +1050,6 @@ static inline void put_page(struct page *page)
>  		__put_page(page);
>  }
>  
> -/**
> - * put_user_page() - release a gup-pinned page
> - * @page:            pointer to page to be released
> - *
> - * Pages that were pinned via get_user_pages*() must be released via
> - * either put_user_page(), or one of the put_user_pages*() routines
> - * below. This is so that eventually, pages that are pinned via
> - * get_user_pages*() can be separately tracked and uniquely handled. In
> - * particular, interactions with RDMA and filesystems need special
> - * handling.
> - *
> - * put_user_page() and put_page() are not interchangeable, despite this early
> - * implementation that makes them look the same. put_user_page() calls must
> - * be perfectly matched up with get_user_page() calls.
> - */
> -static inline void put_user_page(struct page *page)
> -{
> -	put_page(page);
> -}
> -
> -void put_user_pages_dirty(struct page **pages, unsigned long npages);
> -void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
> -void put_user_pages(struct page **pages, unsigned long npages);
> -
>  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
>  #define SECTION_IN_PAGE_FLAGS
>  #endif
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 5c8a9b59cbdc..5f5b72ba595f 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -209,6 +209,11 @@ static inline int page_cache_add_speculative(struct page *page, int count)
>  	return __page_cache_add_speculative(page, count);
>  }
>  
> +static inline int page_cache_gup_pin_speculative(struct page *page)
> +{
> +	return __page_cache_add_speculative(page, GUP_PIN_COUNTING_BIAS);
> +}
> +
>  #ifdef CONFIG_NUMA
>  extern struct page *__page_cache_alloc(gfp_t gfp);
>  #else
> diff --git a/mm/gup.c b/mm/gup.c
> index 05acd7e2eb22..3291da342f9c 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -25,6 +25,26 @@ struct follow_page_context {
>  	unsigned int page_mask;
>  };
>  
> +/**
> + * get_gup_pin_page() - mark a page as being used by get_user_pages().
> + * @page:	pointer to page to be marked
> + * @Returns:	0 for success, -EOVERFLOW if the page refcount would have
> + *		overflowed.
> + *
> + */
> +int get_gup_pin_page(struct page *page)
> +{
> +	page = compound_head(page);
> +
> +	if (page_ref_count(page) >= (UINT_MAX - GUP_PIN_COUNTING_BIAS)) {
> +		WARN_ONCE(1, "get_user_pages pin count overflowed");
> +		return -EOVERFLOW;
> +	}
> +
> +	page_ref_add(page, GUP_PIN_COUNTING_BIAS);
> +	return 0;
> +}
> +
>  static struct page *no_page_table(struct vm_area_struct *vma,
>  		unsigned int flags)
>  {
> @@ -157,8 +177,14 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
>  		goto retry;
>  	}
>  
> -	if (flags & FOLL_GET)
> -		get_page(page);
> +	if (flags & FOLL_GET) {
> +		int ret = get_gup_pin_page(page);
> +
> +		if (ret) {
> +			page = ERR_PTR(ret);
> +			goto out;
> +		}
> +	}
>  	if (flags & FOLL_TOUCH) {
>  		if ((flags & FOLL_WRITE) &&
>  		    !pte_dirty(pte) && !PageDirty(page))
> @@ -497,7 +523,10 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
>  		if (is_device_public_page(*page))
>  			goto unmap;
>  	}
> -	get_page(*page);
> +
> +	ret = get_gup_pin_page(*page);
> +	if (ret)
> +		goto unmap;
>  out:
>  	ret = 0;
>  unmap:
> @@ -1429,11 +1458,11 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>  		page = pte_page(pte);
>  		head = compound_head(page);
>  
> -		if (!page_cache_get_speculative(head))
> +		if (!page_cache_gup_pin_speculative(head))
>  			goto pte_unmap;
>  
>  		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
> -			put_page(head);
> +			put_user_page(head);
>  			goto pte_unmap;
>  		}
>  
> @@ -1488,7 +1517,11 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
>  		}
>  		SetPageReferenced(page);
>  		pages[*nr] = page;
> -		get_page(page);
> +		if (get_gup_pin_page(page)) {
> +			undo_dev_pagemap(nr, nr_start, pages);
> +			return 0;
> +		}
> +
>  		(*nr)++;
>  		pfn++;
>  	} while (addr += PAGE_SIZE, addr != end);
> @@ -1569,15 +1602,14 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
>  	} while (addr += PAGE_SIZE, addr != end);
>  
>  	head = compound_head(pmd_page(orig));
> -	if (!page_cache_add_speculative(head, refs)) {
> +	if (!page_cache_gup_pin_speculative(head)) {
>  		*nr -= refs;
>  		return 0;
>  	}
>  
>  	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
>  		*nr -= refs;
> -		while (refs--)
> -			put_page(head);
> +		put_user_page(head);
>  		return 0;
>  	}
>  
> @@ -1607,15 +1639,14 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
>  	} while (addr += PAGE_SIZE, addr != end);
>  
>  	head = compound_head(pud_page(orig));
> -	if (!page_cache_add_speculative(head, refs)) {
> +	if (!page_cache_gup_pin_speculative(head)) {
>  		*nr -= refs;
>  		return 0;
>  	}
>  
>  	if (unlikely(pud_val(orig) != pud_val(*pudp))) {
>  		*nr -= refs;
> -		while (refs--)
> -			put_page(head);
> +		put_user_page(head);
>  		return 0;
>  	}
>  
> @@ -1644,15 +1675,14 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
>  	} while (addr += PAGE_SIZE, addr != end);
>  
>  	head = compound_head(pgd_page(orig));
> -	if (!page_cache_add_speculative(head, refs)) {
> +	if (!page_cache_gup_pin_speculative(head)) {
>  		*nr -= refs;
>  		return 0;
>  	}
>  
>  	if (unlikely(pgd_val(orig) != pgd_val(*pgdp))) {
>  		*nr -= refs;
> -		while (refs--)
> -			put_page(head);
> +		put_user_page(head);
>  		return 0;
>  	}
>  
> diff --git a/mm/swap.c b/mm/swap.c
> index 7c42ca45bb89..39b0ddd35933 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -133,6 +133,27 @@ void put_pages_list(struct list_head *pages)
>  }
>  EXPORT_SYMBOL(put_pages_list);
>  
> +/**
> + * put_user_page() - release a gup-pinned page
> + * @page:            pointer to page to be released
> + *
> + * Pages that were pinned via get_user_pages*() must be released via
> + * either put_user_page(), or one of the put_user_pages*() routines
> + * below. This is so that eventually, pages that are pinned via
> + * get_user_pages*() can be separately tracked and uniquely handled. In
> + * particular, interactions with RDMA and filesystems need special
> + * handling.
> + */
> +void put_user_page(struct page *page)
> +{
> +	page = compound_head(page);
> +
> +	VM_BUG_ON_PAGE(page_ref_count(page) < GUP_PIN_COUNTING_BIAS, page);
> +
> +	page_ref_sub(page, GUP_PIN_COUNTING_BIAS);
> +}
> +EXPORT_SYMBOL(put_user_page);
> +
>  typedef int (*set_dirty_func)(struct page *page);
>  
>  static void __put_user_pages_dirty(struct page **pages,
> -- 
> 2.20.1
> 

