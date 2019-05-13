Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 345EFC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 10:56:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D95C420862
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 10:56:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D95C420862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71C706B027D; Mon, 13 May 2019 06:56:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CCEE6B027E; Mon, 13 May 2019 06:56:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 595546B027F; Mon, 13 May 2019 06:56:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0792A6B027D
	for <linux-mm@kvack.org>; Mon, 13 May 2019 06:56:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g36so17402174edg.8
        for <linux-mm@kvack.org>; Mon, 13 May 2019 03:56:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BmqeuPV5NpyR/UBkl4B3SG/e1Z+h/NcNmbRTSyktMLA=;
        b=khKgPgev8fyEeVVrVN4a61qK/R1k0uhV+dMUqlj3L4arCUsXyXC2hby7d5/5PJm2FN
         2tXkaG0M8p16KuOQx67uar/hoBMHOwA6ftROeboCm0R0Iim+qIycg+vlbRE7UugvSHeW
         LLZoL1gGbMM5knC5zD3rGO807Ky1vCga3eErjlx4UeGexOpkECNmxCNonpF6JZ+B15OG
         jCa4fuw6mN2Y77WuAcrsuUipBPH7xb0lGYLVibwJkScWSbvKZG7SnBUvYfufLGyi6Mvh
         ohKoypt1Q+HxJcuDqJ+8dLdRA6M2mm5McVEwd3KWBb9kdI4Bsn0NXrSifyWlKu5qb5GB
         Om0g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVkgB7XSvU9VTn1YaUG+rdCE2Mz3i0YM3lozt0dt+VYC+7d/K1S
	attb79TOH2mR0x760RoS244wrv6Dm+On6S1oXx0lDjOvs9jwovFwU7uIQbd7OYJ2uOeQ3evBcrk
	WGyUybKBhjOlQWXDgEaagFtfX8uYInG5gIt7YbpFY0SVZynjEQNl+uO395AF6VIs=
X-Received: by 2002:aa7:c402:: with SMTP id j2mr28627162edq.165.1557745004558;
        Mon, 13 May 2019 03:56:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXNo9z5KrC/EZxAqmzdi0SR7ji0gvodL3v7cOemp8T5Qt8f+8TS+yMDl2/dEvM8F5WBwyV
X-Received: by 2002:aa7:c402:: with SMTP id j2mr28627069edq.165.1557745003256;
        Mon, 13 May 2019 03:56:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557745003; cv=none;
        d=google.com; s=arc-20160816;
        b=r1lW2h1JOYlatTCcbcQlsQL2A9Zs8ezyFyVrfu6WwoTvWMawYsH+ZY/YRY7fI4x60h
         UU5npPJh1oR42IAcHJJVeSfUmjvz3Zuw+0enl0j+QIxM2NvB6Vj1QURrnwQD4X5elzRZ
         l8IDj0QRiH/lyhhLd5ojj8zSmBjj/tgjlfRV9vyn2bNTQOQdf9a5iPNs5MalmLXzRoSF
         dGQgl3qlyboDx+FeQcHBWQHI6wqpnbjlVgYWMAEew8wM0CEDCxpKOmj8GgVHg22+PwyZ
         SkMCSZ+nlLUDknD6LcBvzFz1pzr8ml87DvK+hqiMN2qhn+T1fy8Mt/4a8xxQ13HfYkrg
         uGvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BmqeuPV5NpyR/UBkl4B3SG/e1Z+h/NcNmbRTSyktMLA=;
        b=DaqIEqIx4iSNaoEsNa0BCGAzJ3wpQypji+kI6ZyRIrQVdgEPjAJfbVIOApzudv/1Fd
         KZep4zNrJCLCeSpuNCmdob5aJgvriJyglW3nZ+/1y5hJjcNlz4kkxfdSLGpv0sqUu0ga
         tcA1sl+/X2uMUnw3pR5Bwn2CYRIV3iFSJljUt87sROXtEtlUIxZEoeThRjLO5KWF+/Pz
         2+EdE/V7dEchQWdw1/vDEQw0/u4AEFD9O+gBXvTJ9RDyfrLDXaxPeUkCr4lTa/uAO4lV
         0Tv4+qOVOzlVfrfxi3KKQB5mjfbtJPjHBhv7Z93+nEepQfYD8nCBhVXVl1Ls4j/pVjRT
         XKnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q7si9677663edc.405.2019.05.13.03.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 03:56:43 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6B183AED5;
	Mon, 13 May 2019 10:56:42 +0000 (UTC)
Date: Mon, 13 May 2019 12:56:41 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH] mm: Introduce page_size()
Message-ID: <20190513105641.GB30100@dhcp22.suse.cz>
References: <20190510181242.24580-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190510181242.24580-1-willy@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 10-05-19 11:12:42, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> It's unnecessarily hard to find out the size of a potentially large page.
> Replace 'PAGE_SIZE << compound_order(page)' with 'page_size(page)'.

I like the new helper. The conversion looks like something for
coccinelle.

> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

I haven't checked for other potential places to convert but the ones in
the patch looks ok to me.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/arm/mm/flush.c                           | 3 +--
>  arch/arm64/mm/flush.c                         | 3 +--
>  arch/ia64/mm/init.c                           | 2 +-
>  drivers/staging/android/ion/ion_system_heap.c | 4 ++--
>  drivers/target/tcm_fc/tfc_io.c                | 3 +--
>  fs/io_uring.c                                 | 2 +-
>  include/linux/hugetlb.h                       | 2 +-
>  include/linux/mm.h                            | 9 +++++++++
>  lib/iov_iter.c                                | 2 +-
>  mm/kasan/common.c                             | 8 +++-----
>  mm/nommu.c                                    | 2 +-
>  mm/page_vma_mapped.c                          | 3 +--
>  mm/rmap.c                                     | 6 ++----
>  mm/slob.c                                     | 2 +-
>  mm/slub.c                                     | 4 ++--
>  net/xdp/xsk.c                                 | 2 +-
>  16 files changed, 29 insertions(+), 28 deletions(-)
> 
> diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
> index 58469623b015..c68a120de28b 100644
> --- a/arch/arm/mm/flush.c
> +++ b/arch/arm/mm/flush.c
> @@ -207,8 +207,7 @@ void __flush_dcache_page(struct address_space *mapping, struct page *page)
>  	 * coherent with the kernels mapping.
>  	 */
>  	if (!PageHighMem(page)) {
> -		size_t page_size = PAGE_SIZE << compound_order(page);
> -		__cpuc_flush_dcache_area(page_address(page), page_size);
> +		__cpuc_flush_dcache_area(page_address(page), page_size(page));
>  	} else {
>  		unsigned long i;
>  		if (cache_is_vipt_nonaliasing()) {
> diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
> index 5c9073bace83..280fdbc3bfa5 100644
> --- a/arch/arm64/mm/flush.c
> +++ b/arch/arm64/mm/flush.c
> @@ -67,8 +67,7 @@ void __sync_icache_dcache(pte_t pte)
>  	struct page *page = pte_page(pte);
>  
>  	if (!test_and_set_bit(PG_dcache_clean, &page->flags))
> -		sync_icache_aliases(page_address(page),
> -				    PAGE_SIZE << compound_order(page));
> +		sync_icache_aliases(page_address(page), page_size(page));
>  }
>  EXPORT_SYMBOL_GPL(__sync_icache_dcache);
>  
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index d28e29103bdb..cc4061cd9899 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -63,7 +63,7 @@ __ia64_sync_icache_dcache (pte_t pte)
>  	if (test_bit(PG_arch_1, &page->flags))
>  		return;				/* i-cache is already coherent with d-cache */
>  
> -	flush_icache_range(addr, addr + (PAGE_SIZE << compound_order(page)));
> +	flush_icache_range(addr, addr + page_size(page));
>  	set_bit(PG_arch_1, &page->flags);	/* mark page as clean */
>  }
>  
> diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
> index aa8d8425be25..b83a1d16bd89 100644
> --- a/drivers/staging/android/ion/ion_system_heap.c
> +++ b/drivers/staging/android/ion/ion_system_heap.c
> @@ -120,7 +120,7 @@ static int ion_system_heap_allocate(struct ion_heap *heap,
>  		if (!page)
>  			goto free_pages;
>  		list_add_tail(&page->lru, &pages);
> -		size_remaining -= PAGE_SIZE << compound_order(page);
> +		size_remaining -= page_size(page);
>  		max_order = compound_order(page);
>  		i++;
>  	}
> @@ -133,7 +133,7 @@ static int ion_system_heap_allocate(struct ion_heap *heap,
>  
>  	sg = table->sgl;
>  	list_for_each_entry_safe(page, tmp_page, &pages, lru) {
> -		sg_set_page(sg, page, PAGE_SIZE << compound_order(page), 0);
> +		sg_set_page(sg, page, page_size(page), 0);
>  		sg = sg_next(sg);
>  		list_del(&page->lru);
>  	}
> diff --git a/drivers/target/tcm_fc/tfc_io.c b/drivers/target/tcm_fc/tfc_io.c
> index 1eb1f58e00e4..83c1ec65dbcc 100644
> --- a/drivers/target/tcm_fc/tfc_io.c
> +++ b/drivers/target/tcm_fc/tfc_io.c
> @@ -148,8 +148,7 @@ int ft_queue_data_in(struct se_cmd *se_cmd)
>  					   page, off_in_page, tlen);
>  			fr_len(fp) += tlen;
>  			fp_skb(fp)->data_len += tlen;
> -			fp_skb(fp)->truesize +=
> -					PAGE_SIZE << compound_order(page);
> +			fp_skb(fp)->truesize += page_size(page);
>  		} else {
>  			BUG_ON(!page);
>  			from = kmap_atomic(page + (mem_off >> PAGE_SHIFT));
> diff --git a/fs/io_uring.c b/fs/io_uring.c
> index fdc18321d70c..2c37da095517 100644
> --- a/fs/io_uring.c
> +++ b/fs/io_uring.c
> @@ -2891,7 +2891,7 @@ static int io_uring_mmap(struct file *file, struct vm_area_struct *vma)
>  	}
>  
>  	page = virt_to_head_page(ptr);
> -	if (sz > (PAGE_SIZE << compound_order(page)))
> +	if (sz > page_size(page))
>  		return -EINVAL;
>  
>  	pfn = virt_to_phys(ptr) >> PAGE_SHIFT;
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index edf476c8cfb9..2e909072a41f 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -472,7 +472,7 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>  static inline struct hstate *page_hstate(struct page *page)
>  {
>  	VM_BUG_ON_PAGE(!PageHuge(page), page);
> -	return size_to_hstate(PAGE_SIZE << compound_order(page));
> +	return size_to_hstate(page_size(page));
>  }
>  
>  static inline unsigned hstate_index_to_shift(unsigned index)
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0e8834ac32b7..0208f77bab63 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -772,6 +772,15 @@ static inline void set_compound_order(struct page *page, unsigned int order)
>  	page[1].compound_order = order;
>  }
>  
> +/*
> + * Returns the number of bytes in this potentially compound page.
> + * Must be called with the head page, not a tail page.
> + */
> +static inline unsigned long page_size(struct page *page)
> +{
> +	return (unsigned long)PAGE_SIZE << compound_order(page);
> +}
> +
>  void free_compound_page(struct page *page);
>  
>  #ifdef CONFIG_MMU
> diff --git a/lib/iov_iter.c b/lib/iov_iter.c
> index f74fa832f3aa..d4349c9d0c7e 100644
> --- a/lib/iov_iter.c
> +++ b/lib/iov_iter.c
> @@ -877,7 +877,7 @@ static inline bool page_copy_sane(struct page *page, size_t offset, size_t n)
>  	head = compound_head(page);
>  	v += (page - head) << PAGE_SHIFT;
>  
> -	if (likely(n <= v && v <= (PAGE_SIZE << compound_order(head))))
> +	if (likely(n <= v && v <= page_size(head)))
>  		return true;
>  	WARN_ON(1);
>  	return false;
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 36afcf64e016..dd1d3d88ac9e 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -323,8 +323,7 @@ void kasan_poison_slab(struct page *page)
>  
>  	for (i = 0; i < (1 << compound_order(page)); i++)
>  		page_kasan_tag_reset(page + i);
> -	kasan_poison_shadow(page_address(page),
> -			PAGE_SIZE << compound_order(page),
> +	kasan_poison_shadow(page_address(page), page_size(page),
>  			KASAN_KMALLOC_REDZONE);
>  }
>  
> @@ -520,7 +519,7 @@ void * __must_check kasan_kmalloc_large(const void *ptr, size_t size,
>  	page = virt_to_page(ptr);
>  	redzone_start = round_up((unsigned long)(ptr + size),
>  				KASAN_SHADOW_SCALE_SIZE);
> -	redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
> +	redzone_end = (unsigned long)ptr + page_size(page);
>  
>  	kasan_unpoison_shadow(ptr, size);
>  	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
> @@ -556,8 +555,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
>  			kasan_report_invalid_free(ptr, ip);
>  			return;
>  		}
> -		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
> -				KASAN_FREE_PAGE);
> +		kasan_poison_shadow(ptr, page_size(page), KASAN_FREE_PAGE);
>  	} else {
>  		__kasan_slab_free(page->slab_cache, ptr, ip, false);
>  	}
> diff --git a/mm/nommu.c b/mm/nommu.c
> index b492fd1fcf9f..6dbd5251b366 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -107,7 +107,7 @@ unsigned int kobjsize(const void *objp)
>  	 * The ksize() function is only guaranteed to work for pointers
>  	 * returned by kmalloc(). So handle arbitrary pointers here.
>  	 */
> -	return PAGE_SIZE << compound_order(page);
> +	return page_size(page);
>  }
>  
>  static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> index 11df03e71288..eff4b4520c8d 100644
> --- a/mm/page_vma_mapped.c
> +++ b/mm/page_vma_mapped.c
> @@ -153,8 +153,7 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
>  
>  	if (unlikely(PageHuge(pvmw->page))) {
>  		/* when pud is not present, pte will be NULL */
> -		pvmw->pte = huge_pte_offset(mm, pvmw->address,
> -					    PAGE_SIZE << compound_order(page));
> +		pvmw->pte = huge_pte_offset(mm, pvmw->address, page_size(page));
>  		if (!pvmw->pte)
>  			return false;
>  
> diff --git a/mm/rmap.c b/mm/rmap.c
> index e5dfe2ae6b0d..09ce05c481fc 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -898,8 +898,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  	 */
>  	mmu_notifier_range_init(&range, MMU_NOTIFY_PROTECTION_PAGE,
>  				0, vma, vma->vm_mm, address,
> -				min(vma->vm_end, address +
> -				    (PAGE_SIZE << compound_order(page))));
> +				min(vma->vm_end, address + page_size(page)));
>  	mmu_notifier_invalidate_range_start(&range);
>  
>  	while (page_vma_mapped_walk(&pvmw)) {
> @@ -1374,8 +1373,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	 */
>  	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, vma->vm_mm,
>  				address,
> -				min(vma->vm_end, address +
> -				    (PAGE_SIZE << compound_order(page))));
> +				min(vma->vm_end, address + page_size(page)));
>  	if (PageHuge(page)) {
>  		/*
>  		 * If sharing is possible, start and end will be adjusted
> diff --git a/mm/slob.c b/mm/slob.c
> index 510f0941d032..e7104d1ce92b 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -539,7 +539,7 @@ size_t ksize(const void *block)
>  
>  	sp = virt_to_page(block);
>  	if (unlikely(!PageSlab(sp)))
> -		return PAGE_SIZE << compound_order(sp);
> +		return page_size(sp);
>  
>  	align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
>  	m = (unsigned int *)(block - align);
> diff --git a/mm/slub.c b/mm/slub.c
> index 51453216a1ed..fe2098f95e05 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -829,7 +829,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
>  		return 1;
>  
>  	start = page_address(page);
> -	length = PAGE_SIZE << compound_order(page);
> +	length = page_size(page);
>  	end = start + length;
>  	remainder = length % s->size;
>  	if (!remainder)
> @@ -3912,7 +3912,7 @@ static size_t __ksize(const void *object)
>  
>  	if (unlikely(!PageSlab(page))) {
>  		WARN_ON(!PageCompound(page));
> -		return PAGE_SIZE << compound_order(page);
> +		return page_size(page);
>  	}
>  
>  	return slab_ksize(page->slab_cache);
> diff --git a/net/xdp/xsk.c b/net/xdp/xsk.c
> index a14e8864e4fa..1e7f5dcaefad 100644
> --- a/net/xdp/xsk.c
> +++ b/net/xdp/xsk.c
> @@ -685,7 +685,7 @@ static int xsk_mmap(struct file *file, struct socket *sock,
>  	/* Matches the smp_wmb() in xsk_init_queue */
>  	smp_rmb();
>  	qpg = virt_to_head_page(q->ring);
> -	if (size > (PAGE_SIZE << compound_order(qpg)))
> +	if (size > page_size(qpg))
>  		return -EINVAL;
>  
>  	pfn = virt_to_phys(q->ring) >> PAGE_SHIFT;
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

