Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1C54B6B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 11:51:38 -0400 (EDT)
Received: by pdrw1 with SMTP id w1so16406599pdr.0
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 08:51:37 -0700 (PDT)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id hl6si19958371pdb.172.2015.03.31.08.51.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 31 Mar 2015 08:51:36 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 1 Apr 2015 01:51:31 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 5DC8C3578053
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 02:51:25 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2VFpHDC30539932
	for <linux-mm@kvack.org>; Wed, 1 Apr 2015 02:51:25 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2VFopHV027206
	for <linux-mm@kvack.org>; Wed, 1 Apr 2015 02:50:51 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 20/24] mm, thp: remove compound_lock
In-Reply-To: <1425486792-93161-21-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-21-git-send-email-kirill.shutemov@linux.intel.com>
Date: Tue, 31 Mar 2015 21:20:31 +0530
Message-ID: <87r3s5b1yw.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


....
....

  static void put_compound_page(struct page *page)
>  {
>  	struct page *page_head;
> -	unsigned long flags;
>
>  	if (likely(!PageTail(page))) {
>  		if (put_page_testzero(page)) {
> @@ -108,58 +101,33 @@ static void put_compound_page(struct page *page)
>  	/* __split_huge_page_refcount can run under us */
>  	page_head = compound_head(page);
>
> -	if (!compound_lock_needed(page_head)) {
> -		/*
> -		 * If "page" is a THP tail, we must read the tail page flags
> -		 * after the head page flags. The split_huge_page side enforces
> -		 * write memory barriers between clearing PageTail and before
> -		 * the head page can be freed and reallocated.
> -		 */
> -		smp_rmb();
> -		if (likely(PageTail(page))) {
> -			/* __split_huge_page_refcount cannot race here. */
> -			VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
> -			VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
> -			if (put_page_testzero(page_head)) {
> -				/*
> -				 * If this is the tail of a slab compound page,
> -				 * the tail pin must not be the last reference
> -				 * held on the page, because the PG_slab cannot
> -				 * be cleared before all tail pins (which skips
> -				 * the _mapcount tail refcounting) have been
> -				 * released. For hugetlbfs the tail pin may be
> -				 * the last reference on the page instead,
> -				 * because PageHeadHuge will not go away until
> -				 * the compound page enters the buddy
> -				 * allocator.
> -				 */
> -				VM_BUG_ON_PAGE(PageSlab(page_head), page_head);
> -				__put_compound_page(page_head);
> -			}
> -		} else if (put_page_testzero(page))
> -			__put_single_page(page);
> -		return;
> -	}
> -
> -	flags = compound_lock_irqsave(page_head);
> -	/* here __split_huge_page_refcount won't run anymore */
> -	if (likely(page != page_head && PageTail(page))) {
> -		bool free;
> -
> -		free = put_page_testzero(page_head);
> -		compound_unlock_irqrestore(page_head, flags);
> -		if (free) {
> -			if (PageHead(page_head))
> -				__put_compound_page(page_head);
> -			else
> -				__put_single_page(page_head);
> +	/*
> +	 * If "page" is a THP tail, we must read the tail page flags after the
> +	 * head page flags. The split_huge_page side enforces write memory
> +	 * barriers between clearing PageTail and before the head page can be
> +	 * freed and reallocated.
> +	 */
> +	smp_rmb();
> +	if (likely(PageTail(page))) {
> +		/* __split_huge_page_refcount cannot race here. */
> +		VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
> +		if (put_page_testzero(page_head)) {
> +			/*
> +			 * If this is the tail of a slab compound page, the
> +			 * tail pin must not be the last reference held on the
> +			 * page, because the PG_slab cannot be cleared before
> +			 * all tail pins (which skips the _mapcount tail
> +			 * refcounting) have been released. For hugetlbfs the
> +			 * tail pin may be the last reference on the page
> +			 * instead, because PageHeadHuge will not go away until
> +			 * the compound page enters the buddy allocator.
> +			 */
> +			VM_BUG_ON_PAGE(PageSlab(page_head), page_head);
> +			__put_compound_page(page_head);
>  		}


The comment may need an update ? For THP also a tail pin may be the last
reference on the page right ?


> -	} else {
> -		compound_unlock_irqrestore(page_head, flags);
> -		VM_BUG_ON_PAGE(PageTail(page), page);
> -		if (put_page_testzero(page))
> -			__put_single_page(page);
> -	}
> +	} else if (put_page_testzero(page))
> +		__put_single_page(page);
> +	return;
>  }
>
>  void put_page(struct page *page)
> @@ -178,42 +146,29 @@ EXPORT_SYMBOL(put_page);
>  void __get_page_tail(struct page *page)
>  {
>  	struct page *page_head = compound_head(page);

.....
....

> +	smp_rmb();
> +	if (likely(PageTail(page))) {
> +		/*
> +		 * This is a hugetlbfs page or a slab page.
> +		 * __split_huge_page_refcount cannot race here.
> +		 */

This comment also need an update. This can be a THP tail page right ?

> +		VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
> +		VM_BUG_ON(page_head != page->first_page);
> +		VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0,
> +				page);
> +		atomic_inc(&page_head->_count);
> +	} else {
> +		/*
> +		 * __split_huge_page_refcount run before us, "page" was
> +		 * a thp tail. the split page_head has been freed and
> +		 * reallocated as slab or hugetlbfs page of smaller
> +		 * order (only possible if reallocated as slab on x86).
> +		 */
>  		VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
>  		atomic_inc(&page->_count);
>  	}
> -	compound_unlock_irqrestore(page_head, flags);
> +	return;
>  }
>  EXPORT_SYMBOL(__get_page_tail);
>
> -- 
> 2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
