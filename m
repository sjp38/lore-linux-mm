Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 758536B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 02:16:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id c195so4677904itb.5
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 23:16:29 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id l133si726810ith.158.2017.09.13.23.16.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 23:16:27 -0700 (PDT)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <302be94d-7e44-001d-286c-2b0cd6098f7b@huawei.com>
 <20170911145020.fat456njvyagcomu@docker>
 <57e95ad2-81d8-bf83-3e78-1313daa1bb80@canonical.com>
 <431e2567-7600-3186-1489-93b855c395bd@huawei.com>
 <20170912143636.avc3ponnervs43kj@docker>
 <20170912181303.aqjj5ri3mhscw63t@docker>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <689b2f87-46c5-b4be-67e0-a6639c420191@huawei.com>
Date: Thu, 14 Sep 2017 14:15:25 +0800
MIME-Version: 1.0
In-Reply-To: <20170912181303.aqjj5ri3mhscw63t@docker>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, x86@kernel.org

Hi Tycho,

On 2017/9/13 2:13, Tycho Andersen wrote:
> Hi Yisheng,
> 
>> On Tue, Sep 12, 2017 at 04:05:22PM +0800, Yisheng Xie wrote:
>>> IMO, before a page is allocated, it is in buddy system, which means it is free
>>> and no other 'map' on the page except direct map. Then if the page is allocated
>>> to user, XPFO should unmap the direct map. otherwise the ret2dir may works at
>>> this window before it is freed. Or maybe I'm still missing anything.
>>
>> I agree that it seems broken. I'm just not sure why the test doesn't
>> fail. It's certainly worth understanding.
> 
> Ok, so I think what's going on is that the page *is* mapped and unmapped by the
> kernel as Juerg described, but only in certain cases. See prep_new_page(),
> which has the following:
> 
> 	if (!free_pages_prezeroed() && (gfp_flags & __GFP_ZERO))
> 		for (i = 0; i < (1 << order); i++)
> 			clear_highpage(page + i);
> 
> clear_highpage() maps and unmaps the pages, so that's why xpfo works with this
> set.
Oh, I really missed this point. For we need zero the memory before user get them.

Thanks a lot for figuring out.

> 
> I tried with CONFIG_PAGE_POISONING_ZERO=y and page_poison=y, and the
> XPFO_READ_USER test does not fail, i.e. the read succeeds. So, I think we need
> to include this zeroing condition in xpfo_alloc_pages(), something like the
> patch below. Unfortunately, this fails to boot for me, probably for an
> unrelated reason that I'll look into.
Yes, seems need to fix in this case, and I also a litter puzzle about why boot fail.

Thanks
Yisheng Xie

> 
> Thanks a lot!
> 
> Tycho
> 
> 
>>From bfc21a6438cf8c56741af94cac939f1b0f63752c Mon Sep 17 00:00:00 2001
> From: Tycho Andersen <tycho@docker.com>
> Date: Tue, 12 Sep 2017 12:06:41 -0600
> Subject: [PATCH] draft of unmapping patch
> 
> Signed-off-by: Tycho Andersen <tycho@docker.com>
> ---
>  include/linux/xpfo.h |  5 +++--
>  mm/compaction.c      |  2 +-
>  mm/internal.h        |  2 +-
>  mm/page_alloc.c      | 10 ++++++----
>  mm/xpfo.c            | 10 ++++++++--
>  5 files changed, 19 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
> index b24be9ac4a2d..c991bf7f051d 100644
> --- a/include/linux/xpfo.h
> +++ b/include/linux/xpfo.h
> @@ -29,7 +29,7 @@ void xpfo_flush_kernel_tlb(struct page *page, int order);
>  
>  void xpfo_kmap(void *kaddr, struct page *page);
>  void xpfo_kunmap(void *kaddr, struct page *page);
> -void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp);
> +void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp, bool will_map);
>  void xpfo_free_pages(struct page *page, int order);
>  
>  bool xpfo_page_is_unmapped(struct page *page);
> @@ -49,7 +49,8 @@ void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
>  
>  static inline void xpfo_kmap(void *kaddr, struct page *page) { }
>  static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
> -static inline void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp) { }
> +static inline void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp,
> +				    bool will_map) { }
>  static inline void xpfo_free_pages(struct page *page, int order) { }
>  
>  static inline bool xpfo_page_is_unmapped(struct page *page) { return false; }
> diff --git a/mm/compaction.c b/mm/compaction.c
> index fb548e4c7bd4..9a222258e65c 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -76,7 +76,7 @@ static void map_pages(struct list_head *list)
>  		order = page_private(page);
>  		nr_pages = 1 << order;
>  
> -		post_alloc_hook(page, order, __GFP_MOVABLE);
> +		post_alloc_hook(page, order, __GFP_MOVABLE, false);
>  		if (order)
>  			split_page(page, order);
>  
> diff --git a/mm/internal.h b/mm/internal.h
> index 4ef49fc55e58..1a0331ec2b2d 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -165,7 +165,7 @@ extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
>  					unsigned int order);
>  extern void prep_compound_page(struct page *page, unsigned int order);
>  extern void post_alloc_hook(struct page *page, unsigned int order,
> -					gfp_t gfp_flags);
> +					gfp_t gfp_flags, bool will_map);
>  extern int user_min_free_kbytes;
>  
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 09fdf1bad21f..f73809847c58 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1750,7 +1750,7 @@ static bool check_new_pages(struct page *page, unsigned int order)
>  }
>  
>  inline void post_alloc_hook(struct page *page, unsigned int order,
> -				gfp_t gfp_flags)
> +				gfp_t gfp_flags, bool will_map)
>  {
>  	set_page_private(page, 0);
>  	set_page_refcounted(page);
> @@ -1759,18 +1759,20 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
>  	kernel_map_pages(page, 1 << order, 1);
>  	kernel_poison_pages(page, 1 << order, 1);
>  	kasan_alloc_pages(page, order);
> -	xpfo_alloc_pages(page, order, gfp_flags);
> +	xpfo_alloc_pages(page, order, gfp_flags, will_map);
>  	set_page_owner(page, order, gfp_flags);
>  }
>  
> +extern bool xpfo_test;
>  static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>  							unsigned int alloc_flags)
>  {
>  	int i;
> +	bool needs_zero = !free_pages_prezeroed() && (gfp_flags & __GFP_ZERO);
>  
> -	post_alloc_hook(page, order, gfp_flags);
> +	post_alloc_hook(page, order, gfp_flags, needs_zero);
>  
> -	if (!free_pages_prezeroed() && (gfp_flags & __GFP_ZERO))
> +	if (needs_zero)
>  		for (i = 0; i < (1 << order); i++)
>  			clear_highpage(page + i);
>  
> diff --git a/mm/xpfo.c b/mm/xpfo.c
> index ca5d4d1838f9..dd25e24213fe 100644
> --- a/mm/xpfo.c
> +++ b/mm/xpfo.c
> @@ -86,7 +86,7 @@ static inline struct xpfo *lookup_xpfo(struct page *page)
>  	return (void *)page_ext + page_xpfo_ops.offset;
>  }
>  
> -void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
> +void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp, bool will_map)
>  {
>  	int i, flush_tlb = 0;
>  	struct xpfo *xpfo;
> @@ -116,8 +116,14 @@ void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
>  			 * Tag the page as a user page and flush the TLB if it
>  			 * was previously allocated to the kernel.
>  			 */
> -			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
> +			bool was_user = !test_and_set_bit(XPFO_PAGE_USER,
> +							  &xpfo->flags);
> +
> +			if (was_user || !will_map) {
> +				set_kpte(page_address(page + i), page + i,
> +					 __pgprot(0));
>  				flush_tlb = 1;
> +			}
>  		} else {
>  			/* Tag the page as a non-user (kernel) page */
>  			clear_bit(XPFO_PAGE_USER, &xpfo->flags);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
