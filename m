Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C49ED6B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 01:01:01 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so131108pad.3
        for <linux-mm@kvack.org>; Sun, 06 Sep 2015 22:01:01 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id b16si18013363pbu.61.2015.09.06.22.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Sep 2015 22:01:00 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so82768533pad.1
        for <linux-mm@kvack.org>; Sun, 06 Sep 2015 22:01:00 -0700 (PDT)
Subject: Re: [PATCHv5 1/7] mm: drop page->slab_page
References: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1441283758-92774-2-git-send-email-kirill.shutemov@linux.intel.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Message-ID: <55ED1A09.3040409@gmail.com>
Date: Sun, 6 Sep 2015 22:00:57 -0700
MIME-Version: 1.0
In-Reply-To: <1441283758-92774-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <ak@linux.intel.com>

On 09/03/2015 05:35 AM, Kirill A. Shutemov wrote:
> Since 8456a648cf44 ("slab: use struct page for slab management") nobody
> uses slab_page field in struct page.
>
> Let's drop it.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andi Kleen <ak@linux.intel.com>
> ---
>   include/linux/mm_types.h |  1 -
>   mm/slab.c                | 17 +++--------------
>   2 files changed, 3 insertions(+), 15 deletions(-)
>
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 0038ac7466fd..58620ac7f15c 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -140,7 +140,6 @@ struct page {
>   #endif
>   		};
>   
> -		struct slab *slab_page; /* slab fields */
>   		struct rcu_head rcu_head;	/* Used by SLAB
>   						 * when destroying via RCU
>   						 */
> diff --git a/mm/slab.c b/mm/slab.c
> index 200e22412a16..649044f26e5d 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1888,21 +1888,10 @@ static void slab_destroy(struct kmem_cache *cachep, struct page *page)
>   
>   	freelist = page->freelist;
>   	slab_destroy_debugcheck(cachep, page);
> -	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {
> -		struct rcu_head *head;
> -
> -		/*
> -		 * RCU free overloads the RCU head over the LRU.
> -		 * slab_page has been overloeaded over the LRU,
> -		 * however it is not used from now on so that
> -		 * we can use it safely.
> -		 */
> -		head = (void *)&page->rcu_head;
> -		call_rcu(head, kmem_rcu_free);
> -
> -	} else {
> +	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
> +		call_rcu(&page->rcu_head, kmem_rcu_free);
> +	else
>   		kmem_freepages(cachep, page);
> -	}
>   
>   	/*
>   	 * From now on, we don't use freelist

This second piece looks like it belongs in patch 2, not patch 1 based on 
the descriptions.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
