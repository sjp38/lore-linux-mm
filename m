Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 4D82B6B0082
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 05:38:36 -0400 (EDT)
Received: by mail-oa0-f45.google.com with SMTP id o6so7083201oag.4
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 02:38:35 -0700 (PDT)
Message-ID: <5163E194.3080600@gmail.com>
Date: Tue, 09 Apr 2013 17:38:28 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm, slub: count freed pages via rcu as this task's
 reclaimed_slab
References: <1365470478-645-1-git-send-email-iamjoonsoo.kim@lge.com> <1365470478-645-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1365470478-645-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

Hi Joonsoo,
On 04/09/2013 09:21 AM, Joonsoo Kim wrote:
> Currently, freed pages via rcu is not counted for reclaimed_slab, because
> it is freed in rcu context, not current task context. But, this free is
> initiated by this task, so counting this into this task's reclaimed_slab
> is meaningful to decide whether we continue reclaim, or not.
> So change code to count these pages for this task's reclaimed_slab.
>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 4aec537..16fd2d5 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1409,8 +1409,6 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
>   
>   	memcg_release_pages(s, order);
>   	page_mapcount_reset(page);
> -	if (current->reclaim_state)
> -		current->reclaim_state->reclaimed_slab += pages;
>   	__free_memcg_kmem_pages(page, order);
>   }
>   
> @@ -1431,6 +1429,8 @@ static void rcu_free_slab(struct rcu_head *h)
>   
>   static void free_slab(struct kmem_cache *s, struct page *page)
>   {
> +	int pages = 1 << compound_order(page);

One question irrelevant this patch. Why slab cache can use compound 
page(hugetlbfs pages/thp pages)? They are just used by app to optimize 
tlb miss, is it?

> +
>   	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU)) {
>   		struct rcu_head *head;
>   
> @@ -1450,6 +1450,9 @@ static void free_slab(struct kmem_cache *s, struct page *page)
>   		call_rcu(head, rcu_free_slab);
>   	} else
>   		__free_slab(s, page);
> +
> +	if (current->reclaim_state)
> +		current->reclaim_state->reclaimed_slab += pages;
>   }
>   
>   static void discard_slab(struct kmem_cache *s, struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
