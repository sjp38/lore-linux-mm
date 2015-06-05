Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f53.google.com (mail-vn0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2CEE0900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 11:27:00 -0400 (EDT)
Received: by vnbg129 with SMTP id g129so9434495vnb.11
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 08:27:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id yn14si13883424vdb.73.2015.06.05.08.26.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 08:26:59 -0700 (PDT)
Message-ID: <5571BFBE.3070209@redhat.com>
Date: Fri, 05 Jun 2015 08:26:54 -0700
From: Laura Abbott <labbott@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] cma: allow concurrent cma pages allocation for multi-cma
 areas
References: <"000001d09f66$056b67f0$104237d0$@yang"@samsung.com>
In-Reply-To: <"000001d09f66$056b67f0$104237d0$@yang"@samsung.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>, iamjoonsoo.kim@lge.com
Cc: mina86@mina86.com, m.szyprowski@samsung.com, 'Andrew Morton' <akpm@linux-foundation.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/05/2015 01:01 AM, Weijie Yang wrote:
> Currently we have to hold the single cma_mutex when alloc cma pages,
> it is ok when there is only one cma area in system.
> However, when there are several cma areas, such as in our Android smart
> phone, the single cma_mutex prevents concurrent cma page allocation.
>
> This patch removes the single cma_mutex and uses per-cma area alloc_lock,
> this allows concurrent cma pages allocation for different cma areas while
> protects access to the same pageblocks.
>
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Last I knew alloc_contig_range needed to be serialized which is why we
still had the global CMA mutex. https://lkml.org/lkml/2014/2/18/462

So NAK unless something has changed to allow this.

Laura

> ---
>   mm/cma.c |    6 +++---
>   mm/cma.h |    1 +
>   2 files changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index 3a7a67b..eaf1afe 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -41,7 +41,6 @@
>
>   struct cma cma_areas[MAX_CMA_AREAS];
>   unsigned cma_area_count;
> -static DEFINE_MUTEX(cma_mutex);
>
>   phys_addr_t cma_get_base(const struct cma *cma)
>   {
> @@ -128,6 +127,7 @@ static int __init cma_activate_area(struct cma *cma)
>   	} while (--i);
>
>   	mutex_init(&cma->lock);
> +	mutex_init(&cma->alloc_lock);
>
>   #ifdef CONFIG_CMA_DEBUGFS
>   	INIT_HLIST_HEAD(&cma->mem_head);
> @@ -398,9 +398,9 @@ struct page *cma_alloc(struct cma *cma, unsigned int count, unsigned int align)
>   		mutex_unlock(&cma->lock);
>
>   		pfn = cma->base_pfn + (bitmap_no << cma->order_per_bit);
> -		mutex_lock(&cma_mutex);
> +		mutex_lock(&cma->alloc_lock);
>   		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
> -		mutex_unlock(&cma_mutex);
> +		mutex_unlock(&cma->alloc_lock);
>   		if (ret == 0) {
>   			page = pfn_to_page(pfn);
>   			break;
> diff --git a/mm/cma.h b/mm/cma.h
> index 1132d73..2084c9f 100644
> --- a/mm/cma.h
> +++ b/mm/cma.h
> @@ -7,6 +7,7 @@ struct cma {
>   	unsigned long   *bitmap;
>   	unsigned int order_per_bit; /* Order of pages represented by one bit */
>   	struct mutex    lock;
> +	struct mutex    alloc_lock;
>   #ifdef CONFIG_CMA_DEBUGFS
>   	struct hlist_head mem_head;
>   	spinlock_t mem_head_lock;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
