Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A034CC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 11:34:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F3BE20844
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 11:34:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F3BE20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4DD88E0002; Wed, 30 Jan 2019 06:34:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFF658E0001; Wed, 30 Jan 2019 06:34:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEDA08E0002; Wed, 30 Jan 2019 06:34:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8368E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 06:34:45 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s27so16141686pgm.4
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:34:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=lD1B27lkKnEmSZuh42qovztLBs3GuXWcSD6heOz7zTY=;
        b=ZXCDfS+7VJuMsDWiYDARXkSpt/FzVzhvVGW2/oIJfre3az5MYiHD03xyM0geZQwX+y
         E5KBkcnSgNhwD/+craEmzvCVy71DnRf1UuEPu2y4/H3JFN1qbDQ13BweJtQMQ6l35Qpu
         y1/YJIeruiwd96QJZFmkBs3Lj0LSyKI4VgaKP81CUqbOSgG0ML0ahBPawP2sASwIVJ2+
         E6OYpxPbEybHI6EBdY1vh0m4EW31lQciPotlDWuob8Dqhj62kiYJXfj3EHIhuzFral7c
         h4gE1EMoO53E9/EYYoJ1rXvJB8NLV57APFJzO6IkdhRVsHGu6ksrvRjsD/DPZ7JPsoUQ
         amXg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukdxxDUbIyG3YTlrBJJULS/bo8sSVrr+TCrM7ddW3WGsFbC5XAkp
	CXBfR2tO1KsVWuRG/dEyZNfTBrZlv+848h/UEF9QlCzVkyYybrN6yGD5AnPan1+tFtVFl2WbWef
	l7qxWAwfsVr1e0ALuuq8OeAgjBGWc0s/6dTKzlK3B+XNiwdeGad0TbIblgw7ccBY=
X-Received: by 2002:a63:cd11:: with SMTP id i17mr27433095pgg.345.1548848085117;
        Wed, 30 Jan 2019 03:34:45 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5jIzHrj6tjIw7bx7lolYzXjzAJ/i/oeqgup1L3ARDN2Sg0mTvYtm8hRS0mvkaxV7R8KpmX
X-Received: by 2002:a63:cd11:: with SMTP id i17mr27433038pgg.345.1548848084031;
        Wed, 30 Jan 2019 03:34:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548848084; cv=none;
        d=google.com; s=arc-20160816;
        b=dM1rPUv1zRtUmEcsJQ7rCXKydzYqoZW7s7RrC99NUqfqS2VPlup2DLQYUCdQjrcaa7
         25tLEXru37hgujWf9rXEqHcFEU2Db8ONcS9dLON6D3iPd6bAFz2QcO2nytUWiRAPqd5t
         GvfrweMcsBkE5AusqPShcxORYwRDjRThAFxe8QicJz/hiuJ7+7YK+SJHYr4dPy/SISOF
         iCM6mKBEDg7FvZD6cN5hsu9Qv8v3TQbDvG9Vkc1cASFwU1KahveTh4r7khqZIqCYAFCU
         N12hXGs7NkEYYFdo1pEwYYRHvs5Bp/0AoULtzYnUpleEWg54nXdvWb7uHREk1q+8TX8Z
         R1tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=lD1B27lkKnEmSZuh42qovztLBs3GuXWcSD6heOz7zTY=;
        b=CYnqgwpU5rkVFZn12tbj4GECFf56HoJV7ljRuhJDHWTRauacAUNK4EUYSXjfI+2m+f
         SeIlcohm1Kb35xbNetTKpct0l67kySZe8n+Tu9vwM9eR4aRzFi+3nzt61YHTTPbcTSSp
         BvxIkHBYPD+2KxUqYA1VR0S7jnb4oGaXq2h6CjyRT7gWIBOcn6zr+vusnEMRhVQo3zMd
         lM8cAjWlF/9M/YTQmkBrbT0sqgkzf/WO0JQVkD0lTch5MDLHhMwsO91N+M5btQ1fhEMv
         ArHsDyPKxyG8V+eyMgquQf1Ue9dGkYcMnikH0Vmq9wf7i83eaxrPqTEpU5hjQbyYeQL7
         DUIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id 33si1337247plt.228.2019.01.30.03.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 03:34:43 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43qLqz6kSCz9s6w;
	Wed, 30 Jan 2019 22:34:39 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V7 3/4] powerpc/mm/iommu: Allow migration of cma allocated pages during mm_iommu_do_alloc
In-Reply-To: <20190114095438.32470-5-aneesh.kumar@linux.ibm.com>
References: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com> <20190114095438.32470-5-aneesh.kumar@linux.ibm.com>
Date: Wed, 30 Jan 2019 22:34:39 +1100
Message-ID: <874l9qqsz4.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> The current code doesn't do page migration if the page allocated is a compound page.
> With HugeTLB migration support, we can end up allocating hugetlb pages from
> CMA region. Also, THP pages can be allocated from CMA region. This patch updates
> the code to handle compound pages correctly. The patch also switches to a single
> get_user_pages with the right count, instead of doing one get_user_pages per page.
> That avoids reading page table multiple times.

It's not very obvious from the above description that the migration
logic is now being done by get_user_pages_longterm(), it just looks like
it's all being deleted in this patch. Would be good to mention that.

> Since these page reference updates are long term pin, switch to
> get_user_pages_longterm. That makes sure we fail correctly if the guest RAM
> is backed by DAX pages.

Can you explain that in more detail?

> The patch also converts the hpas member of mm_iommu_table_group_mem_t to a union.
> We use the same storage location to store pointers to struct page. We cannot
> update all the code path use struct page *, because we access hpas in real mode
> and we can't do that struct page * to pfn conversion in real mode.

That's a pain, it's asking for bugs mixing two different values in the
same array. But I guess it's the least worst option.

It sounds like that's a separate change you could do in a separate
patch. But it's not, because it's tied to the fact that we're doing a
single GUP call.


> diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
> index a712a650a8b6..f11a2f15071f 100644
> --- a/arch/powerpc/mm/mmu_context_iommu.c
> +++ b/arch/powerpc/mm/mmu_context_iommu.c
> @@ -21,6 +21,7 @@
>  #include <linux/sizes.h>
>  #include <asm/mmu_context.h>
>  #include <asm/pte-walk.h>
> +#include <linux/mm_inline.h>
>  
>  static DEFINE_MUTEX(mem_list_mutex);
>  
> @@ -34,8 +35,18 @@ struct mm_iommu_table_group_mem_t {
>  	atomic64_t mapped;
>  	unsigned int pageshift;
>  	u64 ua;			/* userspace address */
> -	u64 entries;		/* number of entries in hpas[] */
> -	u64 *hpas;		/* vmalloc'ed */
> +	u64 entries;		/* number of entries in hpas/hpages[] */
> +	/*
> +	 * in mm_iommu_get we temporarily use this to store
> +	 * struct page address.
> +	 *
> +	 * We need to convert ua to hpa in real mode. Make it
> +	 * simpler by storing physical address.
> +	 */
> +	union {
> +		struct page **hpages;	/* vmalloc'ed */
> +		phys_addr_t *hpas;
> +	};
>  #define MM_IOMMU_TABLE_INVALID_HPA	((uint64_t)-1)
>  	u64 dev_hpa;		/* Device memory base address */
>  };
> @@ -80,64 +91,15 @@ bool mm_iommu_preregistered(struct mm_struct *mm)
>  }
>  EXPORT_SYMBOL_GPL(mm_iommu_preregistered);
>  
> -/*
> - * Taken from alloc_migrate_target with changes to remove CMA allocations
> - */
> -struct page *new_iommu_non_cma_page(struct page *page, unsigned long private)
> -{
> -	gfp_t gfp_mask = GFP_USER;
> -	struct page *new_page;
> -
> -	if (PageCompound(page))
> -		return NULL;
> -
> -	if (PageHighMem(page))
> -		gfp_mask |= __GFP_HIGHMEM;
> -
> -	/*
> -	 * We don't want the allocation to force an OOM if possibe
> -	 */
> -	new_page = alloc_page(gfp_mask | __GFP_NORETRY | __GFP_NOWARN);
> -	return new_page;
> -}
> -
> -static int mm_iommu_move_page_from_cma(struct page *page)
> -{
> -	int ret = 0;
> -	LIST_HEAD(cma_migrate_pages);
> -
> -	/* Ignore huge pages for now */
> -	if (PageCompound(page))
> -		return -EBUSY;
> -
> -	lru_add_drain();
> -	ret = isolate_lru_page(page);
> -	if (ret)
> -		return ret;
> -
> -	list_add(&page->lru, &cma_migrate_pages);
> -	put_page(page); /* Drop the gup reference */
> -
> -	ret = migrate_pages(&cma_migrate_pages, new_iommu_non_cma_page,
> -				NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE);
> -	if (ret) {
> -		if (!list_empty(&cma_migrate_pages))
> -			putback_movable_pages(&cma_migrate_pages);
> -	}
> -
> -	return 0;
> -}
> -
>  static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
> -		unsigned long entries, unsigned long dev_hpa,
> -		struct mm_iommu_table_group_mem_t **pmem)
> +			      unsigned long entries, unsigned long dev_hpa,
> +			      struct mm_iommu_table_group_mem_t **pmem)
>  {
>  	struct mm_iommu_table_group_mem_t *mem;
> -	long i, j, ret = 0, locked_entries = 0;
> +	long i, ret = 0, locked_entries = 0;

I'd prefer we didn't initialise ret here.

>  	unsigned int pageshift;
>  	unsigned long flags;
>  	unsigned long cur_ua;
> -	struct page *page = NULL;
>  
>  	mutex_lock(&mem_list_mutex);
>  
> @@ -187,41 +149,27 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
>  		goto unlock_exit;
>  	}
>  
> +	down_read(&mm->mmap_sem);
> +	ret = get_user_pages_longterm(ua, entries, FOLL_WRITE, mem->hpages, NULL);
> +	up_read(&mm->mmap_sem);
> +	if (ret != entries) {
> +		/* free the reference taken */
> +		for (i = 0; i < ret; i++)
> +			put_page(mem->hpages[i]);
> +
> +		vfree(mem->hpas);
> +		kfree(mem);
> +		ret = -EFAULT;
> +		goto unlock_exit;
> +	} else {
> +		ret = 0;

Or here.

Instead it should be set to 0 at good_exit.

> +	}
> +
> +	pageshift = PAGE_SHIFT;
>  	for (i = 0; i < entries; ++i) {
> +		struct page *page = mem->hpages[i];
> +
>  		cur_ua = ua + (i << PAGE_SHIFT);
> -		if (1 != get_user_pages_fast(cur_ua,
> -					1/* pages */, 1/* iswrite */, &page)) {
> -			ret = -EFAULT;
> -			for (j = 0; j < i; ++j)
> -				put_page(pfn_to_page(mem->hpas[j] >>
> -						PAGE_SHIFT));
> -			vfree(mem->hpas);
> -			kfree(mem);
> -			goto unlock_exit;
> -		}
> -		/*
> -		 * If we get a page from the CMA zone, since we are going to
> -		 * be pinning these entries, we might as well move them out
> -		 * of the CMA zone if possible. NOTE: faulting in + migration
> -		 * can be expensive. Batching can be considered later
> -		 */
> -		if (is_migrate_cma_page(page)) {
> -			if (mm_iommu_move_page_from_cma(page))
> -				goto populate;
> -			if (1 != get_user_pages_fast(cur_ua,
> -						1/* pages */, 1/* iswrite */,
> -						&page)) {
> -				ret = -EFAULT;
> -				for (j = 0; j < i; ++j)
> -					put_page(pfn_to_page(mem->hpas[j] >>
> -								PAGE_SHIFT));
> -				vfree(mem->hpas);
> -				kfree(mem);
> -				goto unlock_exit;
> -			}
> -		}
> -populate:
> -		pageshift = PAGE_SHIFT;
>  		if (mem->pageshift > PAGE_SHIFT && PageCompound(page)) {
>  			pte_t *pte;
>  			struct page *head = compound_head(page);
> @@ -239,6 +187,10 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
>  			local_irq_restore(flags);
>  		}
>  		mem->pageshift = min(mem->pageshift, pageshift);
> +		/*
> +		 * We don't need struct page reference any more, switch
> +		 * to physical address.
> +		 */
>  		mem->hpas[i] = page_to_pfn(page) << PAGE_SHIFT;
>  	}

I'm not any sort of expert on this code, but I don't see anything wrong.

Reviewed-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

