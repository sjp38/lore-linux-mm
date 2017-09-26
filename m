Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0636B0253
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:35:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m127so11889846wmm.3
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:35:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k57si7260796wrk.37.2017.09.26.06.35.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 06:35:26 -0700 (PDT)
Date: Tue, 26 Sep 2017 15:35:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm: move function alloc_pages_exact_nid out of
 __meminit
Message-ID: <20170926133525.2h55vfa25gjiu5ts@dhcp22.suse.cz>
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
 <20170921085922.11659-2-ganapatrao.kulkarni@cavium.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170921085922.11659-2-ganapatrao.kulkarni@cavium.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, Will.Deacon@arm.com, robin.murphy@arm.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, joro@8bytes.org, vbabka@suse.cz, akpm@linux-foundation.org, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com, gklkml16@gmail.com

On Thu 21-09-17 14:29:19, Ganapatrao Kulkarni wrote:
> This function can be used on NUMA systems in place of alloc_pages_exact
> Adding code to export and to remove __meminit section tagging.

It is usually better to fold such a change into a patch which adds a new
user. Other than that I do not have any objections.

> Signed-off-by: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/gfp.h | 2 +-
>  mm/page_alloc.c     | 3 ++-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index f780718..a4bd234 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -528,7 +528,7 @@ extern unsigned long get_zeroed_page(gfp_t gfp_mask);
>  
>  void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
>  void free_pages_exact(void *virt, size_t size);
> -void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
> +void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
>  
>  #define __get_free_page(gfp_mask) \
>  		__get_free_pages((gfp_mask), 0)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c841af8..7975870 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4442,7 +4442,7 @@ EXPORT_SYMBOL(alloc_pages_exact);
>   * Like alloc_pages_exact(), but try to allocate on node nid first before falling
>   * back.
>   */
> -void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
> +void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
>  {
>  	unsigned int order = get_order(size);
>  	struct page *p = alloc_pages_node(nid, gfp_mask, order);
> @@ -4450,6 +4450,7 @@ void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
>  		return NULL;
>  	return make_alloc_exact((unsigned long)page_address(p), order, size);
>  }
> +EXPORT_SYMBOL(alloc_pages_exact_nid);
>  
>  /**
>   * free_pages_exact - release memory allocated via alloc_pages_exact()
> -- 
> 2.9.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
