Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35C29C7618F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:43:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B927C218DA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:43:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B927C218DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 035876B0003; Mon, 22 Jul 2019 20:43:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2B3F6B0005; Mon, 22 Jul 2019 20:43:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E16D08E0001; Mon, 22 Jul 2019 20:43:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A6B256B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 20:43:10 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so24991836pfv.18
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 17:43:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4J6XE+3+ougO3j/FsjfY9d0Qn3a6oexVJc6FlCfNWWk=;
        b=U9IS+Hz5c8KRskVtwmt+D5tgPBOetMWcWvoGFgCARhhR0hnGRjrO0OmEvO9fbTOZNi
         IhsX44XGcvciDU8TDB3QnjrbS/iFO6DT7MpUOgYkVDdpYM1Hk9tdTySUp91Ga/rFherz
         x/DfN920n87oHSkSXIJdbO0EG490psgspmpGLdloXAXEVn5kCVwscRYM1Wg+1V1gGrNi
         P4yq1OBDESdgEZhuSV/XAzxiqSBq1rrT7Qe4ItAjDaVaA3vYPVnpZIVNtF4IjGfncFui
         EtnJOtBt+/ecYkFc+/6kmyfSSggRb5R+q/Tgvjx3oEcKnzFmxm2AG8yCEBLwWrRNAM/7
         Jh4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXZuBKe3MoqxvrY3MqxrAHb6uMog/Uv8FGKRH1ZveV8xbB8nEHa
	VBlN+kzh0ESY5ky5WRSah81cMpyJ6zl/M5f7OpxDDFBM/on9UqLux07/RKg+bHi2r02JrIFq7Tj
	9phyu8MQu8dL3cKS3vRWhbAgAtCB+zHqnkc+yZ+YeqLFvKNb0r7BYZgyP3x3otgRF0Q==
X-Received: by 2002:aa7:8d88:: with SMTP id i8mr2995741pfr.28.1563842590192;
        Mon, 22 Jul 2019 17:43:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzl+2MBmuSe9LE4WQebEMaiUkl7JkJY0p5+PGIP0+sVz8mk7LWMK4V5K1sk8MtxuW0LjHx3
X-Received: by 2002:aa7:8d88:: with SMTP id i8mr2995666pfr.28.1563842588805;
        Mon, 22 Jul 2019 17:43:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563842588; cv=none;
        d=google.com; s=arc-20160816;
        b=jy96A+V3Q7geUljYD3j2CVmR8D4iRmlc295vSzKOXnnX8V7o0TGuU2vHQwRVsPtBk7
         4aRLaay7j4lpxdFCGNK+7GtQnWM4VPLgorRMoZLg3B15WizFOetvS2ROO434+REqimpj
         DrtihgcOK2bGCK6MO1CFOTcRSF9nc7DKwCD2ib/KLnBPaUzNQOyhlQFoY8RktICA84Sn
         ZtfUGsh66+YBmRUB6Ov+m+vY5g6PC8NcT5rn+PbhH6RhJmKtVBbwwej+fSQ2W6I45RsK
         m4xyDM9QpTgaK9IhYGeViCk2yOIU8KiMHswxCbbzfI1ethgXIyR2a5bxWNw5yPWSjdsj
         7SOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4J6XE+3+ougO3j/FsjfY9d0Qn3a6oexVJc6FlCfNWWk=;
        b=bgvFcodlTW0iA55iUVZAWq56oYpHZ+rnBaKM+7Pp+sKd0JUldy5VVSCGfExk6hBW/V
         b5sKA1a7FFj0PK/NDMUE93/J4so7qJ0/A2TFxVg/LkEk6QcBPNjY+of24loBgJmRlZKu
         mWdTnjAFd/dQoElGF/gBzWlKIh8cU+GijfNWI3kCFY52I+QEZGKi7BPt2twbuU2PjyMI
         xbixbbPpfgyQq5V7R9Pf/aT2Zhjt+DhcA+GS/Xi5gWCWvA9MsNJGItOzRiBRfm3NBVvA
         OW3DI/+aBo2eaB4B2K3c/KBsEE2XbEb0nCyuXrzZpaIxBYpnstNi71MFD/ZgLs2yeYxG
         YymQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id x61si11185992plb.336.2019.07.22.17.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 17:43:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Jul 2019 17:43:08 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,297,1559545200"; 
   d="scan'208";a="188721625"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 22 Jul 2019 17:43:08 -0700
Date: Mon, 22 Jul 2019 17:43:07 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2 1/3] mm: Introduce page_size()
Message-ID: <20190723004307.GB10284@iweiny-DESK2.sc.intel.com>
References: <20190721104612.19120-1-willy@infradead.org>
 <20190721104612.19120-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721104612.19120-2-willy@infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 03:46:10AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox (Oracle) <willy@infradead.org>
> 
> It's unnecessarily hard to find out the size of a potentially huge page.
> Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/arm/mm/flush.c                           |  3 +--
>  arch/arm64/mm/flush.c                         |  3 +--
>  arch/ia64/mm/init.c                           |  2 +-
>  drivers/crypto/chelsio/chtls/chtls_io.c       |  5 ++---
>  drivers/staging/android/ion/ion_system_heap.c |  4 ++--
>  drivers/target/tcm_fc/tfc_io.c                |  3 +--
>  fs/io_uring.c                                 |  2 +-
>  include/linux/hugetlb.h                       |  2 +-
>  include/linux/mm.h                            |  6 ++++++
>  lib/iov_iter.c                                |  2 +-
>  mm/kasan/common.c                             |  8 +++-----
>  mm/nommu.c                                    |  2 +-
>  mm/page_vma_mapped.c                          |  3 +--
>  mm/rmap.c                                     |  6 ++----
>  mm/slob.c                                     |  2 +-
>  mm/slub.c                                     | 18 +++++++++---------
>  net/xdp/xsk.c                                 |  2 +-
>  17 files changed, 35 insertions(+), 38 deletions(-)
> 
> diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
> index 6ecbda87ee46..4c7ebe094a83 100644
> --- a/arch/arm/mm/flush.c
> +++ b/arch/arm/mm/flush.c
> @@ -204,8 +204,7 @@ void __flush_dcache_page(struct address_space *mapping, struct page *page)
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
> index dc19300309d2..ac485163a4a7 100644
> --- a/arch/arm64/mm/flush.c
> +++ b/arch/arm64/mm/flush.c
> @@ -56,8 +56,7 @@ void __sync_icache_dcache(pte_t pte)
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
> index aae75fd7b810..e97e24816bd4 100644
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
> diff --git a/drivers/crypto/chelsio/chtls/chtls_io.c b/drivers/crypto/chelsio/chtls/chtls_io.c
> index 551bca6fef24..925be5942895 100644
> --- a/drivers/crypto/chelsio/chtls/chtls_io.c
> +++ b/drivers/crypto/chelsio/chtls/chtls_io.c
> @@ -1078,7 +1078,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>  			bool merge;
>  
>  			if (page)
> -				pg_size <<= compound_order(page);
> +				pg_size = page_size(page);
>  			if (off < pg_size &&
>  			    skb_can_coalesce(skb, i, page, off)) {
>  				merge = 1;
> @@ -1105,8 +1105,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>  							   __GFP_NORETRY,
>  							   order);
>  					if (page)
> -						pg_size <<=
> -							compound_order(page);
> +						pg_size <<= order;

Looking at the code I see pg_size should be PAGE_SIZE right before this so why
not just use the new call and remove the initial assignment?

Regardless it should be fine.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

>  				}
>  				if (!page) {
>  					page = alloc_page(gfp);
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
> index a254792d882c..1354a157e9af 100644
> --- a/drivers/target/tcm_fc/tfc_io.c
> +++ b/drivers/target/tcm_fc/tfc_io.c
> @@ -136,8 +136,7 @@ int ft_queue_data_in(struct se_cmd *se_cmd)
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
> index e2a66e12fbc6..c55d8b411d2a 100644
> --- a/fs/io_uring.c
> +++ b/fs/io_uring.c
> @@ -3084,7 +3084,7 @@ static int io_uring_mmap(struct file *file, struct vm_area_struct *vma)
>  	}
>  
>  	page = virt_to_head_page(ptr);
> -	if (sz > (PAGE_SIZE << compound_order(page)))
> +	if (sz > page_size(page))
>  		return -EINVAL;
>  
>  	pfn = virt_to_phys(ptr) >> PAGE_SHIFT;
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index edfca4278319..53fc34f930d0 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -454,7 +454,7 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>  static inline struct hstate *page_hstate(struct page *page)
>  {
>  	VM_BUG_ON_PAGE(!PageHuge(page), page);
> -	return size_to_hstate(PAGE_SIZE << compound_order(page));
> +	return size_to_hstate(page_size(page));
>  }
>  
>  static inline unsigned hstate_index_to_shift(unsigned index)
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0334ca97c584..899dfcf7c23d 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -805,6 +805,12 @@ static inline void set_compound_order(struct page *page, unsigned int order)
>  	page[1].compound_order = order;
>  }
>  
> +/* Returns the number of bytes in this potentially compound page. */
> +static inline unsigned long page_size(struct page *page)
> +{
> +	return PAGE_SIZE << compound_order(page);
> +}
> +
>  void free_compound_page(struct page *page);
>  
>  #ifdef CONFIG_MMU
> diff --git a/lib/iov_iter.c b/lib/iov_iter.c
> index f1e0569b4539..639d5e7014c1 100644
> --- a/lib/iov_iter.c
> +++ b/lib/iov_iter.c
> @@ -878,7 +878,7 @@ static inline bool page_copy_sane(struct page *page, size_t offset, size_t n)
>  	head = compound_head(page);
>  	v += (page - head) << PAGE_SHIFT;
>  
> -	if (likely(n <= v && v <= (PAGE_SIZE << compound_order(head))))
> +	if (likely(n <= v && v <= (page_size(head))))
>  		return true;
>  	WARN_ON(1);
>  	return false;
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 2277b82902d8..a929a3b9444d 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -321,8 +321,7 @@ void kasan_poison_slab(struct page *page)
>  
>  	for (i = 0; i < (1 << compound_order(page)); i++)
>  		page_kasan_tag_reset(page + i);
> -	kasan_poison_shadow(page_address(page),
> -			PAGE_SIZE << compound_order(page),
> +	kasan_poison_shadow(page_address(page), page_size(page),
>  			KASAN_KMALLOC_REDZONE);
>  }
>  
> @@ -518,7 +517,7 @@ void * __must_check kasan_kmalloc_large(const void *ptr, size_t size,
>  	page = virt_to_page(ptr);
>  	redzone_start = round_up((unsigned long)(ptr + size),
>  				KASAN_SHADOW_SCALE_SIZE);
> -	redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
> +	redzone_end = (unsigned long)ptr + page_size(page);
>  
>  	kasan_unpoison_shadow(ptr, size);
>  	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
> @@ -554,8 +553,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
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
> index fed1b6e9c89b..99b7ec318824 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -108,7 +108,7 @@ unsigned int kobjsize(const void *objp)
>  	 * The ksize() function is only guaranteed to work for pointers
>  	 * returned by kmalloc(). So handle arbitrary pointers here.
>  	 */
> -	return PAGE_SIZE << compound_order(page);
> +	return page_size(page);
>  }
>  
>  /**
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
> index 7f421d0ca9ab..cf377beab962 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -539,7 +539,7 @@ size_t __ksize(const void *block)
>  
>  	sp = virt_to_page(block);
>  	if (unlikely(!PageSlab(sp)))
> -		return PAGE_SIZE << compound_order(sp);
> +		return page_size(sp);
>  
>  	align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
>  	m = (unsigned int *)(block - align);
> diff --git a/mm/slub.c b/mm/slub.c
> index e6c030e47364..1e8e20a99660 100644
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
> @@ -1074,13 +1074,14 @@ static void setup_object_debug(struct kmem_cache *s, struct page *page,
>  	init_tracking(s, object);
>  }
>  
> -static void setup_page_debug(struct kmem_cache *s, void *addr, int order)
> +static
> +void setup_page_debug(struct kmem_cache *s, struct page *page, void *addr)
>  {
>  	if (!(s->flags & SLAB_POISON))
>  		return;
>  
>  	metadata_access_enable();
> -	memset(addr, POISON_INUSE, PAGE_SIZE << order);
> +	memset(addr, POISON_INUSE, page_size(page));
>  	metadata_access_disable();
>  }
>  
> @@ -1340,8 +1341,8 @@ slab_flags_t kmem_cache_flags(unsigned int object_size,
>  #else /* !CONFIG_SLUB_DEBUG */
>  static inline void setup_object_debug(struct kmem_cache *s,
>  			struct page *page, void *object) {}
> -static inline void setup_page_debug(struct kmem_cache *s,
> -			void *addr, int order) {}
> +static inline
> +void setup_page_debug(struct kmem_cache *s, struct page *page, void *addr) {}
>  
>  static inline int alloc_debug_processing(struct kmem_cache *s,
>  	struct page *page, void *object, unsigned long addr) { return 0; }
> @@ -1635,7 +1636,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	struct kmem_cache_order_objects oo = s->oo;
>  	gfp_t alloc_gfp;
>  	void *start, *p, *next;
> -	int idx, order;
> +	int idx;
>  	bool shuffle;
>  
>  	flags &= gfp_allowed_mask;
> @@ -1669,7 +1670,6 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  
>  	page->objects = oo_objects(oo);
>  
> -	order = compound_order(page);
>  	page->slab_cache = s;
>  	__SetPageSlab(page);
>  	if (page_is_pfmemalloc(page))
> @@ -1679,7 +1679,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  
>  	start = page_address(page);
>  
> -	setup_page_debug(s, start, order);
> +	setup_page_debug(s, page, start);
>  
>  	shuffle = shuffle_freelist(s, page);
>  
> @@ -3926,7 +3926,7 @@ size_t __ksize(const void *object)
>  
>  	if (unlikely(!PageSlab(page))) {
>  		WARN_ON(!PageCompound(page));
> -		return PAGE_SIZE << compound_order(page);
> +		return page_size(page);
>  	}
>  
>  	return slab_ksize(page->slab_cache);
> diff --git a/net/xdp/xsk.c b/net/xdp/xsk.c
> index 59b57d708697..44bfb76fbad9 100644
> --- a/net/xdp/xsk.c
> +++ b/net/xdp/xsk.c
> @@ -739,7 +739,7 @@ static int xsk_mmap(struct file *file, struct socket *sock,
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
> 

