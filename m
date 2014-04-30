Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id D21396B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:50:18 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so1779319eek.1
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:50:18 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id g47si32088149eet.84.2014.04.30.13.50.17
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 13:50:17 -0700 (PDT)
Date: Wed, 30 Apr 2014 23:50:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3] mm/swap.c: introduce
 put_[un]refcounted_compound_page helpers for spliting put_compound_page
Message-ID: <20140430205011.GA27455@node.dhcp.inet.fi>
References: <b1987d6fb09745a5274895efbde79e37ff9557a3.1398764420.git.nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b1987d6fb09745a5274895efbde79e37ff9557a3.1398764420.git.nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com, aarcange@redhat.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 29, 2014 at 05:42:07PM +0800, Jianyu Zhan wrote:
> Currently, put_compound_page should carefully handle tricky case
> to avoid racing with compound page releasing or spliting, which
> makes it growing quite lenthy(about 200+ lines) and need deep
> tab indention, which makes it quite hard to follow and maintain.
> 
> This patch(and the next patch) tries to refactor this function.
> It is a prepared patch.
> 
> Based on the code skeleton of put_compound_page:
> 
> put_compound_pge:

Typo.

>         if !PageTail(page)
>         	put head page fastpath;
> 		return;
> 
>         /* else PageTail */
>         page_head = compound_head(page)
>         if !__compound_tail_refcounted(page_head)
> 		put head page optimal path; <---(1)
> 		return;
>         else
> 		put head page slowpath; <--- (2)
>                 return;
> 
> This patch introduces two helpers, put_[un]refcounted_compound_page,
> handling the code path (1) and code path (2), respectively. They both
> are tagged __always_inline, thus it elmiates function call overhead,
> making them operating the same way as before.
> 
> They are almost copied verbatim(except one place, a "goto out_put_single"
> is expanded), with some comments rephrasing.
> 
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
> ---
>  mm/swap.c | 142 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 142 insertions(+)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index c0cd7d0..a576449 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -79,6 +79,148 @@ static void __put_compound_page(struct page *page)
>  	(*dtor)(page);
>  }
>  
> +/**
> + * Two special cases here: we could avoid taking compound_lock_irqsave
> + * and could skip the tail refcounting(in _mapcount).
> + *
> + * 1. Hugetlbfs page:
> + *
> + *    PageHeadHuge will remain true until the compound page
> + *    is released and enters the buddy allocator, and it could
> + *    not be split by __split_huge_page_refcount().
> + *
> + *    So if we see PageHeadHuge set, and we have the tail page pin,
> + *    then we could safely put head page.
> + *
> + * 2. Slab THP page:

There's no such thing. It called Slab compound page.

> + *
> + *    PG_slab is cleared before the slab frees the head page, and
> + *    tail pin cannot be the last reference left on the head page,
> + *    because the slab code is free to reuse the compound page
> + *    after a kfree/kmem_cache_free without having to check if
> + *    there's any tail pin left.  In turn all tail pinsmust be always
> + *    released while the head is still pinned by the slab code
> + *    and so we know PG_slab will be still set too.
> + *
> + *    So if we see PageSlab set, and we have the tail page pin,
> + *    then we could safely put head page.
> + */
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
