Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9859C7618F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:47:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 761C721BF6
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:47:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 761C721BF6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 254BE6B0005; Mon, 22 Jul 2019 20:47:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 209086B0007; Mon, 22 Jul 2019 20:47:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11DD28E0001; Mon, 22 Jul 2019 20:47:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB10F6B0005
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 20:47:37 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e20so24995018pfd.3
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 17:47:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nl96P91DAU6XwDDsIGG/07f01thwNlAISSN1F0l8o3M=;
        b=Mwl8SX9PTvNWUzy+/AHJ16WGjeOkGqkz3vm7sd1sBoR6/HTFFkn9brJENXTB/uqLhd
         nt+oRxKN0b6uLukK4HRFGXynMqp5VnBHf10OpEP4Kqgi1nK5StvLkAXCAl4RsagcA1CF
         Y2ednSCFc+ta8neKaGp4B4REzjlP7H+7vibO2UxBpoVgpem/fXqawC4XtKHOpBi3F82h
         xlme3mkcaVxtN1B/FvlN1nwrKkq2QS6t+8khIGdFn+DbWiWN1Myo9iKoqH9rT78uZhyl
         O5QFqPPm8xsxf7MF/o5O9RL36apfOBylL2qWW3qFVMFBuvCMlIoVLH0uOOswVO9QZ2cv
         38Dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWF60BtSupt0UK0wBvlvDYFsfkeL0WNlSOSTnQrfXnWRMkNv4vU
	ZzwSF4T4V4UPq/sN4Qr3sTi57tRR3C2+c2ws0M+sdMZYEpu0Sa7USqz+l7sPFHYPUyXr9T5jHiG
	y3rbyW0ruoOu+U72jEzhyjMYa6zoAwDmJ5Lm2mbYe4JT2EK7Q2NDc4JUsirW76h3BfQ==
X-Received: by 2002:a63:8f16:: with SMTP id n22mr3485883pgd.306.1563842857281;
        Mon, 22 Jul 2019 17:47:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUDyFdbl9nKqZ/JOZukWak3HvnrnwXX6iY8FYe3+Ewg+T0+HixcGW3cifDbCLWyLguJklk
X-Received: by 2002:a63:8f16:: with SMTP id n22mr3485836pgd.306.1563842856309;
        Mon, 22 Jul 2019 17:47:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563842856; cv=none;
        d=google.com; s=arc-20160816;
        b=Ha56LmDNtil8bRc05kLJSL8JhuTdD0TIyEL7FlneRNPgtwW93ndXBCOUxRwByZpSkT
         NuFhVMBAL4RpWlq/lYzVLP5cqyrKBYTSI7KmmC3RFFkt7/cJWdR1M2aGptrGQcPLpzeo
         tbq5yrFLtSKC0wpANura8tFCPuAeIMz/CK7lgSBiS85469K3KvS6Kj/4BkwW3innFp7m
         vVa1rPzJS/7UBMMV9B0naTJi9JIopDd2dU89pAXwhAEYAHTBvVMvRMW/YNasLTGaNbB2
         kiRR1vI6ZL6mIHf2lo7OimozyQCpkE+sCVresdumNl164kx7lVTFs4HtBbHhSKmIuQL1
         1CIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nl96P91DAU6XwDDsIGG/07f01thwNlAISSN1F0l8o3M=;
        b=EyabWDYH3/WxO66KaVO/AEP27qpkGNg6ndLL6ab1BqL1VdCRIkGhaCsqCRWsI78WtJ
         TBzCC1nOliObeqgW/8LVl2Ka/Qdhs2E1fiocRjvfy1EGI+ue2LRnf/cax+gHbRKT3ZZ/
         5o8OaRo5+EtGHEZVEReTdv49NZanlXS3YWqI2ctSgEljfHbg4y2OMHqmohHF1fYqjIFZ
         K2YPokaYoKou6d7p1CPr2vmAbZ62c6n6tF/NBgSv85jyxAW7scO3qXLWeLZp8ieNPAWq
         YyjsIaajkfn8T+1Q5ARGgCgaKQqf6JndR3bXw4euqruy/e3Yw2ekJhmh1o2HC9qsnv6U
         kyIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id h32si11121192pld.402.2019.07.22.17.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 17:47:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Jul 2019 17:46:51 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,297,1559545200"; 
   d="scan'208";a="196936023"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga002.fm.intel.com with ESMTP; 22 Jul 2019 17:46:51 -0700
Date: Mon, 22 Jul 2019 17:46:51 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: [PATCH v2 3/3] mm: Introduce compound_nr()
Message-ID: <20190723004651.GD10284@iweiny-DESK2.sc.intel.com>
References: <20190721104612.19120-1-willy@infradead.org>
 <20190721104612.19120-4-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721104612.19120-4-willy@infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 03:46:12AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox (Oracle) <willy@infradead.org>
> 
> Replace 1 << compound_order(page) with compound_nr(page).  Minor
> improvements in readability.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  arch/arm/include/asm/xen/page-coherent.h   | 3 +--
>  arch/arm/mm/flush.c                        | 4 ++--
>  arch/arm64/include/asm/xen/page-coherent.h | 3 +--
>  arch/powerpc/mm/hugetlbpage.c              | 2 +-
>  fs/proc/task_mmu.c                         | 2 +-
>  include/linux/mm.h                         | 6 ++++++
>  mm/compaction.c                            | 2 +-
>  mm/filemap.c                               | 2 +-
>  mm/gup.c                                   | 2 +-
>  mm/hugetlb_cgroup.c                        | 2 +-
>  mm/kasan/common.c                          | 2 +-
>  mm/memcontrol.c                            | 4 ++--
>  mm/memory_hotplug.c                        | 4 ++--
>  mm/migrate.c                               | 2 +-
>  mm/page_alloc.c                            | 2 +-
>  mm/rmap.c                                  | 3 +--
>  mm/shmem.c                                 | 8 ++++----
>  mm/swap_state.c                            | 2 +-
>  mm/util.c                                  | 2 +-
>  mm/vmscan.c                                | 4 ++--
>  20 files changed, 32 insertions(+), 29 deletions(-)
> 
> diff --git a/arch/arm/include/asm/xen/page-coherent.h b/arch/arm/include/asm/xen/page-coherent.h
> index 2c403e7c782d..ea39cb724ffa 100644
> --- a/arch/arm/include/asm/xen/page-coherent.h
> +++ b/arch/arm/include/asm/xen/page-coherent.h
> @@ -31,8 +31,7 @@ static inline void xen_dma_map_page(struct device *hwdev, struct page *page,
>  {
>  	unsigned long page_pfn = page_to_xen_pfn(page);
>  	unsigned long dev_pfn = XEN_PFN_DOWN(dev_addr);
> -	unsigned long compound_pages =
> -		(1<<compound_order(page)) * XEN_PFN_PER_PAGE;
> +	unsigned long compound_pages = compound_nr(page) * XEN_PFN_PER_PAGE;
>  	bool local = (page_pfn <= dev_pfn) &&
>  		(dev_pfn - page_pfn < compound_pages);
>  
> diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
> index 4c7ebe094a83..6d89db7895d1 100644
> --- a/arch/arm/mm/flush.c
> +++ b/arch/arm/mm/flush.c
> @@ -208,13 +208,13 @@ void __flush_dcache_page(struct address_space *mapping, struct page *page)
>  	} else {
>  		unsigned long i;
>  		if (cache_is_vipt_nonaliasing()) {
> -			for (i = 0; i < (1 << compound_order(page)); i++) {
> +			for (i = 0; i < compound_nr(page); i++) {
>  				void *addr = kmap_atomic(page + i);
>  				__cpuc_flush_dcache_area(addr, PAGE_SIZE);
>  				kunmap_atomic(addr);
>  			}
>  		} else {
> -			for (i = 0; i < (1 << compound_order(page)); i++) {
> +			for (i = 0; i < compound_nr(page); i++) {
>  				void *addr = kmap_high_get(page + i);
>  				if (addr) {
>  					__cpuc_flush_dcache_area(addr, PAGE_SIZE);
> diff --git a/arch/arm64/include/asm/xen/page-coherent.h b/arch/arm64/include/asm/xen/page-coherent.h
> index d88e56b90b93..b600a8ef3349 100644
> --- a/arch/arm64/include/asm/xen/page-coherent.h
> +++ b/arch/arm64/include/asm/xen/page-coherent.h
> @@ -45,8 +45,7 @@ static inline void xen_dma_map_page(struct device *hwdev, struct page *page,
>  {
>  	unsigned long page_pfn = page_to_xen_pfn(page);
>  	unsigned long dev_pfn = XEN_PFN_DOWN(dev_addr);
> -	unsigned long compound_pages =
> -		(1<<compound_order(page)) * XEN_PFN_PER_PAGE;
> +	unsigned long compound_pages = compound_nr(page) * XEN_PFN_PER_PAGE;
>  	bool local = (page_pfn <= dev_pfn) &&
>  		(dev_pfn - page_pfn < compound_pages);
>  
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index a8953f108808..73d4873fc7f8 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -667,7 +667,7 @@ void flush_dcache_icache_hugepage(struct page *page)
>  
>  	BUG_ON(!PageCompound(page));
>  
> -	for (i = 0; i < (1UL << compound_order(page)); i++) {
> +	for (i = 0; i < compound_nr(page); i++) {
>  		if (!PageHighMem(page)) {
>  			__flush_dcache_icache(page_address(page+i));
>  		} else {
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 731642e0f5a0..a9f2deb8ab79 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -461,7 +461,7 @@ static void smaps_page_accumulate(struct mem_size_stats *mss,
>  static void smaps_account(struct mem_size_stats *mss, struct page *page,
>  		bool compound, bool young, bool dirty, bool locked)
>  {
> -	int i, nr = compound ? 1 << compound_order(page) : 1;
> +	int i, nr = compound ? compound_nr(page) : 1;
>  	unsigned long size = nr * PAGE_SIZE;
>  
>  	/*
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 64762559885f..726d7f046b49 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -805,6 +805,12 @@ static inline void set_compound_order(struct page *page, unsigned int order)
>  	page[1].compound_order = order;
>  }
>  
> +/* Returns the number of pages in this potentially compound page. */
> +static inline unsigned long compound_nr(struct page *page)
> +{
> +	return 1UL << compound_order(page);
> +}
> +
>  /* Returns the number of bytes in this potentially compound page. */
>  static inline unsigned long page_size(struct page *page)
>  {
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9e1b9acb116b..78d42e2dbc64 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -967,7 +967,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  			 * is safe to read and it's 0 for tail pages.
>  			 */
>  			if (unlikely(PageCompound(page))) {
> -				low_pfn += (1UL << compound_order(page)) - 1;
> +				low_pfn += compound_nr(page) - 1;
>  				goto isolate_fail;
>  			}
>  		}
> diff --git a/mm/filemap.c b/mm/filemap.c
> index d0cf700bf201..f00f53ad383f 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -126,7 +126,7 @@ static void page_cache_delete(struct address_space *mapping,
>  	/* hugetlb pages are represented by a single entry in the xarray */
>  	if (!PageHuge(page)) {
>  		xas_set_order(&xas, page->index, compound_order(page));
> -		nr = 1U << compound_order(page);
> +		nr = compound_nr(page);
>  	}
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> diff --git a/mm/gup.c b/mm/gup.c
> index 98f13ab37bac..84a36d80dd2e 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1460,7 +1460,7 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  		 * gup may start from a tail page. Advance step by the left
>  		 * part.
>  		 */
> -		step = (1 << compound_order(head)) - (pages[i] - head);
> +		step = compound_nr(head) - (pages[i] - head);
>  		/*
>  		 * If we get a page from the CMA zone, since we are going to
>  		 * be pinning these entries, we might as well move them out
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index 68c2f2f3c05b..f1930fa0b445 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -139,7 +139,7 @@ static void hugetlb_cgroup_move_parent(int idx, struct hugetlb_cgroup *h_cg,
>  	if (!page_hcg || page_hcg != h_cg)
>  		goto out;
>  
> -	nr_pages = 1 << compound_order(page);
> +	nr_pages = compound_nr(page);
>  	if (!parent) {
>  		parent = root_h_cgroup;
>  		/* root has no limit */
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index a929a3b9444d..895dc5e2b3d5 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -319,7 +319,7 @@ void kasan_poison_slab(struct page *page)
>  {
>  	unsigned long i;
>  
> -	for (i = 0; i < (1 << compound_order(page)); i++)
> +	for (i = 0; i < compound_nr(page); i++)
>  		page_kasan_tag_reset(page + i);
>  	kasan_poison_shadow(page_address(page), page_size(page),
>  			KASAN_KMALLOC_REDZONE);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index cdbb7a84cb6e..b5c4c618d087 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6257,7 +6257,7 @@ static void uncharge_page(struct page *page, struct uncharge_gather *ug)
>  		unsigned int nr_pages = 1;
>  
>  		if (PageTransHuge(page)) {
> -			nr_pages <<= compound_order(page);
> +			nr_pages = compound_nr(page);
>  			ug->nr_huge += nr_pages;
>  		}
>  		if (PageAnon(page))
> @@ -6269,7 +6269,7 @@ static void uncharge_page(struct page *page, struct uncharge_gather *ug)
>  		}
>  		ug->pgpgout++;
>  	} else {
> -		ug->nr_kmem += 1 << compound_order(page);
> +		ug->nr_kmem += compound_nr(page);
>  		__ClearPageKmemcg(page);
>  	}
>  
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 2a9bbddb0e55..bb2ab9f58f8c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1311,7 +1311,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  		head = compound_head(page);
>  		if (page_huge_active(head))
>  			return pfn;
> -		skip = (1 << compound_order(head)) - (page - head);
> +		skip = compound_nr(head) - (page - head);
>  		pfn += skip - 1;
>  	}
>  	return 0;
> @@ -1349,7 +1349,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  
>  		if (PageHuge(page)) {
>  			struct page *head = compound_head(page);
> -			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
> +			pfn = page_to_pfn(head) + compound_nr(head) - 1;
>  			isolate_huge_page(head, &source);
>  			continue;
>  		} else if (PageTransHuge(page))
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 8992741f10aa..702115a9cf11 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1889,7 +1889,7 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>  	VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page), page);
>  
>  	/* Avoid migrating to a node that is nearly full */
> -	if (!migrate_balanced_pgdat(pgdat, 1UL << compound_order(page)))
> +	if (!migrate_balanced_pgdat(pgdat, compound_nr(page)))
>  		return 0;
>  
>  	if (isolate_lru_page(page))
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 272c6de1bf4e..d3bb601c461b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8207,7 +8207,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  			if (!hugepage_migration_supported(page_hstate(head)))
>  				goto unmovable;
>  
> -			skip_pages = (1 << compound_order(head)) - (page - head);
> +			skip_pages = compound_nr(head) - (page - head);
>  			iter += skip_pages - 1;
>  			continue;
>  		}
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 09ce05c481fc..05e41f097b1d 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1514,8 +1514,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
>  			pteval = swp_entry_to_pte(make_hwpoison_entry(subpage));
>  			if (PageHuge(page)) {
> -				int nr = 1 << compound_order(page);
> -				hugetlb_count_sub(nr, mm);
> +				hugetlb_count_sub(compound_nr(page), mm);
>  				set_huge_swap_pte_at(mm, address,
>  						     pvmw.pte, pteval,
>  						     vma_mmu_pagesize(vma));
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 626d8c74b973..fccb34aca6ea 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -594,7 +594,7 @@ static int shmem_add_to_page_cache(struct page *page,
>  {
>  	XA_STATE_ORDER(xas, &mapping->i_pages, index, compound_order(page));
>  	unsigned long i = 0;
> -	unsigned long nr = 1UL << compound_order(page);
> +	unsigned long nr = compound_nr(page);
>  
>  	VM_BUG_ON_PAGE(PageTail(page), page);
>  	VM_BUG_ON_PAGE(index != round_down(index, nr), page);
> @@ -1869,7 +1869,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  	lru_cache_add_anon(page);
>  
>  	spin_lock_irq(&info->lock);
> -	info->alloced += 1 << compound_order(page);
> +	info->alloced += compound_nr(page);
>  	inode->i_blocks += BLOCKS_PER_PAGE << compound_order(page);
>  	shmem_recalc_inode(inode);
>  	spin_unlock_irq(&info->lock);
> @@ -1910,7 +1910,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  		struct page *head = compound_head(page);
>  		int i;
>  
> -		for (i = 0; i < (1 << compound_order(head)); i++) {
> +		for (i = 0; i < compound_nr(head); i++) {
>  			clear_highpage(head + i);
>  			flush_dcache_page(head + i);
>  		}
> @@ -1937,7 +1937,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  	 * Error recovery.
>  	 */
>  unacct:
> -	shmem_inode_unacct_blocks(inode, 1 << compound_order(page));
> +	shmem_inode_unacct_blocks(inode, compound_nr(page));
>  
>  	if (PageTransHuge(page)) {
>  		unlock_page(page);
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 8368621a0fc7..f844af5f09ba 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -116,7 +116,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp)
>  	struct address_space *address_space = swap_address_space(entry);
>  	pgoff_t idx = swp_offset(entry);
>  	XA_STATE_ORDER(xas, &address_space->i_pages, idx, compound_order(page));
> -	unsigned long i, nr = 1UL << compound_order(page);
> +	unsigned long i, nr = compound_nr(page);
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(PageSwapCache(page), page);
> diff --git a/mm/util.c b/mm/util.c
> index e6351a80f248..bab284d69c8c 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -521,7 +521,7 @@ bool page_mapped(struct page *page)
>  		return true;
>  	if (PageHuge(page))
>  		return false;
> -	for (i = 0; i < (1 << compound_order(page)); i++) {
> +	for (i = 0; i < compound_nr(page); i++) {
>  		if (atomic_read(&page[i]._mapcount) >= 0)
>  			return true;
>  	}
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 44df66a98f2a..bb69bd2d9c78 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1145,7 +1145,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  		VM_BUG_ON_PAGE(PageActive(page), page);
>  
> -		nr_pages = 1 << compound_order(page);
> +		nr_pages = compound_nr(page);
>  
>  		/* Account the number of base pages even though THP */
>  		sc->nr_scanned += nr_pages;
> @@ -1701,7 +1701,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  
>  		VM_BUG_ON_PAGE(!PageLRU(page), page);
>  
> -		nr_pages = 1 << compound_order(page);
> +		nr_pages = compound_nr(page);
>  		total_scan += nr_pages;
>  
>  		if (page_zonenum(page) > sc->reclaim_idx) {
> -- 
> 2.20.1
> 

