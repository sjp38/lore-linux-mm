Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 55B4E6B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 12:44:03 -0400 (EDT)
Received: by mail-yh0-f47.google.com with SMTP id 29so6320417yhl.34
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 09:44:03 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h34si25847070yhi.135.2014.04.28.09.44.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 09:44:02 -0700 (PDT)
Message-ID: <535E8549.6070106@oracle.com>
Date: Mon, 28 Apr 2014 10:43:53 -0600
From: Khalid Aziz <khalid.aziz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 1/2] mm/swap.c: split put_compound_page function
References: <c232030f96bdc60aef967b0d350208e74dc7f57d.1398605516.git.nasa4836@gmail.com>
In-Reply-To: <c232030f96bdc60aef967b0d350208e74dc7f57d.1398605516.git.nasa4836@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com, aarcange@redhat.com, mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/27/2014 07:35 AM, Jianyu Zhan wrote:
> Currently, put_compound_page should carefully handle tricky case
> to avoid racing with compound page releasing or spliting, which
> makes it growing quite lenthy(about 200+ lines) and need deep
> tab indention, which makes it quite hard to follow and maintain.
>
> This patch tries to refactor this function, by extracting out the
> fundamental logics into helper functions, making the main code path
> more compact, thus easy to read and maintain. Two helper funcitons
> are introduced, and are marked __always_inline, thus this patch
> has no functional change(actually, the output object file is the
> same size with the original one).

We recently went through a clean up of this code and it was made more 
readable. I do not particularly see any strong need to refactor at this 
point, but I am not opposed to it either.

Some comments inline below.

--
Khalid

>
> Besides, this patch rearranges/rewrites some comments(hope I don't
> do it wrong).
>
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
> ---
>   mm/swap.c | 227 ++++++++++++++++++++++++++++++++++++--------------------------
>   1 file changed, 131 insertions(+), 96 deletions(-)
>
> diff --git a/mm/swap.c b/mm/swap.c
> index c0cd7d0..0d8d891 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -79,106 +79,100 @@ static void __put_compound_page(struct page *page)
>   	(*dtor)(page);
>   }
>
> -static void put_compound_page(struct page *page)
> -{
> -	struct page *page_head;
> -
> -	if (likely(!PageTail(page))) {
> -		if (put_page_testzero(page)) {
> -			/*
> -			 * By the time all refcounts have been released
> -			 * split_huge_page cannot run anymore from under us.
> -			 */
> -			if (PageHead(page))
> -				__put_compound_page(page);
> -			else
> -				__put_single_page(page);
> -		}
> -		return;
> -	}
> -
> -	/* __split_huge_page_refcount can run under us */
> -	page_head = compound_head(page);
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
> +static __always_inline void put_unrefcounted_compound_page(struct page *head_page,
> +						struct page *page)
> +{
>   	/*
> -	 * THP can not break up slab pages so avoid taking
> -	 * compound_lock() and skip the tail page refcounting (in
> -	 * _mapcount) too. Slab performs non-atomic bit ops on
> -	 * page->flags for better performance. In particular
> -	 * slab_unlock() in slub used to be a hot path. It is still
> -	 * hot on arches that do not support
> -	 * this_cpu_cmpxchg_double().
> -	 *
> -	 * If "page" is part of a slab or hugetlbfs page it cannot be
> -	 * splitted and the head page cannot change from under us. And
> -	 * if "page" is part of a THP page under splitting, if the
> -	 * head page pointed by the THP tail isn't a THP head anymore,
> -	 * we'll find PageTail clear after smp_rmb() and we'll treat
> -	 * it as a single page.
> +	 * If @page is a THP tail, we must read the tail page
> +	 * flags after the head page flags. The
> +	 * __split_huge_page_refcount side enforces write memory barriers
> +	 * between clearing PageTail and before the head page
> +	 * can be freed and reallocated.
>   	 */
> -	if (!__compound_tail_refcounted(page_head)) {
> +	smp_rmb();
> +	if (likely(PageTail(page))) {
>   		/*
> -		 * If "page" is a THP tail, we must read the tail page
> -		 * flags after the head page flags. The
> -		 * split_huge_page side enforces write memory barriers
> -		 * between clearing PageTail and before the head page
> -		 * can be freed and reallocated.
> +		 * __split_huge_page_refcount cannot race
> +		 * here, see the comment above this function.
>   		 */
> -		smp_rmb();
> -		if (likely(PageTail(page))) {
> -			/*
> -			 * __split_huge_page_refcount cannot race
> -			 * here.
> -			 */
> -			VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
> -			VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
> -			if (put_page_testzero(page_head)) {
> -				/*
> -				 * If this is the tail of a slab
> -				 * compound page, the tail pin must
> -				 * not be the last reference held on
> -				 * the page, because the PG_slab
> -				 * cannot be cleared before all tail
> -				 * pins (which skips the _mapcount
> -				 * tail refcounting) have been
> -				 * released. For hugetlbfs the tail
> -				 * pin may be the last reference on
> -				 * the page instead, because
> -				 * PageHeadHuge will not go away until
> -				 * the compound page enters the buddy
> -				 * allocator.
> -				 */
> -				VM_BUG_ON_PAGE(PageSlab(page_head), page_head);
> -				__put_compound_page(page_head);
> -			}
> -			return;
> -		} else
> +		VM_BUG_ON_PAGE(!PageHead(head_page), head_page);

Any reason to rename page_head to head_page? page_head makes perfect 
sense. This change just causes patch to be longer.

> +		VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
> +		if (put_page_testzero(head_page)) {
>   			/*
> -			 * __split_huge_page_refcount run before us,
> -			 * "page" was a THP tail. The split page_head
> -			 * has been freed and reallocated as slab or
> -			 * hugetlbfs page of smaller order (only
> -			 * possible if reallocated as slab on x86).
> +			 * If this is the tail of a slab THP page,
> +			 * the tail pin must not be the last reference
> +			 * held on the page, because the PG_slab cannot
> +			 * be cleared before all tail pins (which skips
> +			 * the _mapcount tail refcounting) have been
> +			 * released.
> +			 *
> +			 * If this is the tail of a hugetlbfs page,
> +			 * the tail pin may be the last reference on
> +			 * the page instead, because PageHeadHuge will
> +			 * not go away until the compound page enters
> +			 * the buddy allocator.
>   			 */
> -			goto out_put_single;
> -	}
> +			VM_BUG_ON_PAGE(PageSlab(head_page), head_page);
> +			__put_compound_page(head_page);
> +		}
> +	} else
> +		/*
> +		 * __split_huge_page_refcount run before us,
> +		 * @page was a THP tail. The split @head_page
> +		 * has been freed and reallocated as slab or
> +		 * hugetlbfs page of smaller order (only
> +		 * possible if reallocated as slab on x86).
> +		 */
> +		if (put_page_testzero(page))
> +			__put_single_page(page);
> +}
>
> -	if (likely(page != page_head && get_page_unless_zero(page_head))) {
> +static __always_inline void put_refcounted_compound_page(struct page *head_page,
> +						struct page *page)
> +{
> +	if (likely(page != head_page && get_page_unless_zero(head_page))) {
>   		unsigned long flags;
>
>   		/*
> -		 * page_head wasn't a dangling pointer but it may not
> +		 * @page_head wasn't a dangling pointer but it may not
                    ^^^^^^^^^^
Your patch renames this to head_page.

>   		 * be a head page anymore by the time we obtain the
>   		 * lock. That is ok as long as it can't be freed from
>   		 * under us.
>   		 */
> -		flags = compound_lock_irqsave(page_head);
> +		flags = compound_lock_irqsave(head_page);
>   		if (unlikely(!PageTail(page))) {
>   			/* __split_huge_page_refcount run before us */
> -			compound_unlock_irqrestore(page_head, flags);
> -			if (put_page_testzero(page_head)) {
> +			compound_unlock_irqrestore(head_page, flags);
> +			if (put_page_testzero(head_page)) {
>   				/*
> -				 * The head page may have been freed
> +				 * The @head_page may have been freed
>   				 * and reallocated as a compound page
>   				 * of smaller order and then freed
>   				 * again.  All we know is that it
> @@ -186,48 +180,89 @@ static void put_compound_page(struct page *page)
>   				 * compound page of higher order, a
>   				 * tail page.  That is because we
>   				 * still hold the refcount of the
> -				 * split THP tail and page_head was
> +				 * split THP tail and head_page was
>   				 * the THP head before the split.
>   				 */
> -				if (PageHead(page_head))
> -					__put_compound_page(page_head);
> +				if (PageHead(head_page))
> +					__put_compound_page(head_page);
>   				else
> -					__put_single_page(page_head);
> +					__put_single_page(head_page);
>   			}
>   out_put_single:
>   			if (put_page_testzero(page))
>   				__put_single_page(page);
>   			return;
>   		}
> -		VM_BUG_ON_PAGE(page_head != page->first_page, page);
> +		VM_BUG_ON_PAGE(head_page != page->first_page, page);
>   		/*
>   		 * We can release the refcount taken by
>   		 * get_page_unless_zero() now that
>   		 * __split_huge_page_refcount() is blocked on the
>   		 * compound_lock.
>   		 */
> -		if (put_page_testzero(page_head))
> -			VM_BUG_ON_PAGE(1, page_head);
> +		if (put_page_testzero(head_page))
> +			VM_BUG_ON_PAGE(1, head_page);
>   		/* __split_huge_page_refcount will wait now */
>   		VM_BUG_ON_PAGE(page_mapcount(page) <= 0, page);
>   		atomic_dec(&page->_mapcount);
> -		VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0, page_head);
> +		VM_BUG_ON_PAGE(atomic_read(&head_page->_count) <= 0, head_page);
>   		VM_BUG_ON_PAGE(atomic_read(&page->_count) != 0, page);
> -		compound_unlock_irqrestore(page_head, flags);
> +		compound_unlock_irqrestore(head_page, flags);
>
> -		if (put_page_testzero(page_head)) {
> -			if (PageHead(page_head))
> -				__put_compound_page(page_head);
> +		if (put_page_testzero(head_page)) {
> +			if (PageHead(head_page))
> +				__put_compound_page(head_page);
>   			else
> -				__put_single_page(page_head);
> +				__put_single_page(head_page);
>   		}
>   	} else {
> -		/* page_head is a dangling pointer */
> +		/* @head_page is a dangling pointer */
>   		VM_BUG_ON_PAGE(PageTail(page), page);
>   		goto out_put_single;
>   	}
>   }
>
> +
> +static void put_compound_page(struct page *page)
> +{
> +	struct page *head_page;
> +
> +	/*
> +	 * We see the PageCompound set and PageTail not set, so @page maybe:
> +	 *  1. hugetlbfs head page, or
> +	 *  2. THP head page, or
> +	 */
> +	if (likely(!PageTail(page))) {
> +		if (put_page_testzero(page)) {
> +			/*
> +			 * By the time all refcounts have been released
> +			 * __split_huge_page_refcount cannot run anymore
> +			 * from under us.
> +			 */
> +			if (PageHead(page))
> +				__put_compound_page(page);
> +			else
> +				__put_single_page(page);
> +		}
> +		return;
> +	}
> +
> +	/*
> +	 * We see the PageCompound set and PageTail set, so @page maybe:
> +	 *  1. a tail hugetlbfs page, or
> +	 *  2. a tail THP page, or
> +	 *  3. a split THP page.
> +	 *
> +	 *  Case 3 is possible, as we may race with
> +	 *  __split_huge_page_refcount tearing down a THP page.
> +	 */
> +	head_page = compound_head(page);
> +	if (!__compound_tail_refcounted(head_page))
> +		put_unrefcounted_compound_page(head_page, page);
> +	else
> +		put_refcounted_compound_page(head_page, page);
> +}
> +
>   void put_page(struct page *page)
>   {
>   	if (unlikely(PageCompound(page)))
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
