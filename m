Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 27BDB6B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 10:54:45 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so4889769eei.5
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 07:54:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si23419394eer.147.2014.04.28.07.54.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 07:54:43 -0700 (PDT)
Date: Mon, 28 Apr 2014 16:54:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC 2/2] mm: introdule compound_head_by_tail()
Message-ID: <20140428145440.GB7839@dhcp22.suse.cz>
References: <c232030f96bdc60aef967b0d350208e74dc7f57d.1398605516.git.nasa4836@gmail.com>
 <2c87e00d633153ba7b710bab12710cc3a58704dd.1398605516.git.nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2c87e00d633153ba7b710bab12710cc3a58704dd.1398605516.git.nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com, liuj97@gmail.com, peterz@infradead.org, hannes@cmpxchg.org, mgorman@suse.de, aarcange@redhat.com, sasha.levin@oracle.com, liwanp@linux.vnet.ibm.com, khalid.aziz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 27-04-14 21:36:24, Jianyu Zhan wrote:
> In put_comound_page(), we call compound_head() after !PageTail
> check fails, so in compound_head() PageTail is quite likely to
> be true, but instead it is checked with:
> 
>    if (unlikely(PageTail(page)))
> 
> in this case, this unlikely macro is a negative hint for compiler.
> 
> So this patch introduce compound_head_by_tail() which deal with
> a possible tail page(though it could be spilt by a racy thread),
> and make compound_head() a wrapper on it.
> 
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>

I really fail to see how that helps. compound_head is inlined and the
compiler should be clever enough to optimize the code properly. I
haven't tried that to be honest but this looks like it only adds a code
without any good reason. And I really hate the new name as well. What
does it suppose to mean?

> ---
>  include/linux/mm.h | 34 ++++++++++++++++++++++------------
>  mm/swap.c          |  2 +-
>  2 files changed, 23 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index bf9811e..1bc7baf 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -405,20 +405,30 @@ static inline void compound_unlock_irqrestore(struct page *page,
>  #endif
>  }
>  
> +/**
> + * Note: this function must be called on a possible tail page,
> + * this tail page may not be tail anymore upon we calling this funciton,
> + * because we may race with __split_huge_page_refcount tearing down it.
> + */
> +static inline struct page *compound_head_by_tail(struct page *page)
> +{
> +	struct page *head = page->first_page;
> +
> +	/*
> +	 * page->first_page may be a dangling pointer to an old
> +	 * compound page, so recheck that it is still a tail
> +	 * page before returning.
> +	 */
> +	smp_rmb();
> +	if (likely(PageTail(page)))
> +		return head;
> +	return page;
> +}
> +
>  static inline struct page *compound_head(struct page *page)
>  {
> -	if (unlikely(PageTail(page))) {
> -		struct page *head = page->first_page;
> -
> -		/*
> -		 * page->first_page may be a dangling pointer to an old
> -		 * compound page, so recheck that it is still a tail
> -		 * page before returning.
> -		 */
> -		smp_rmb();
> -		if (likely(PageTail(page)))
> -			return head;
> -	}
> +	if (unlikely(PageTail(page)))
> +		return compound_head_by_tail(page);
>  	return page;
>  }
>  
> diff --git a/mm/swap.c b/mm/swap.c
> index 0d8d891..0b05355 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -256,7 +256,7 @@ static void put_compound_page(struct page *page)
>  	 *  Case 3 is possible, as we may race with
>  	 *  __split_huge_page_refcount tearing down a THP page.
>  	 */
> -	head_page = compound_head(page);
> +	head_page = compound_head_by_tail(page);
>  	if (!__compound_tail_refcounted(head_page))
>  		put_unrefcounted_compound_page(head_page, page);
>  	else
> -- 
> 2.0.0-rc1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
