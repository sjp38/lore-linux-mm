Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D0C546B025F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 18:09:01 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so2736624pac.3
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 15:09:01 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id e4si15027750pdn.255.2015.07.23.15.09.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 15:09:01 -0700 (PDT)
Received: by padck2 with SMTP id ck2so2809938pad.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 15:09:00 -0700 (PDT)
Date: Thu, 23 Jul 2015 15:08:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] hugetlb: cond_resched for set_max_huge_pages and
 follow_hugetlb_page
In-Reply-To: <1437688476-3399-1-git-send-email-sbaugh@catern.com>
Message-ID: <alpine.DEB.2.10.1507231506050.6965@chino.kir.corp.google.com>
References: <1437688476-3399-1-git-send-email-sbaugh@catern.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Spencer Baugh <sbaugh@catern.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>, Luiz Capitulino <lcapitulino@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Joern Engel <joern@purestorage.com>, Spencer Baugh <Spencer.baugh@purestorage.com>, Joern Engel <joern@logfs.org>

On Thu, 23 Jul 2015, Spencer Baugh wrote:

> From: Joern Engel <joern@logfs.org>
> 
> ~150ms scheduler latency for both observed in the wild.
> 
> Signed-off-by: Joern Engel <joern@logfs.org>
> Signed-off-by: Spencer Baugh <sbaugh@catern.com>
> ---
>  mm/hugetlb.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a8c3087..2eb6919 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1836,6 +1836,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>  			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
>  		else
>  			ret = alloc_fresh_huge_page(h, nodes_allowed);
> +		cond_resched();
>  		spin_lock(&hugetlb_lock);
>  		if (!ret)
>  			goto out;

This is wrong, you'd want to do any cond_resched() before the page 
allocation to avoid racing with an update to h->nr_huge_pages or 
h->surplus_huge_pages while hugetlb_lock was dropped that would result in 
the page having been uselessly allocated.

> @@ -3521,6 +3522,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  				spin_unlock(ptl);
>  			ret = hugetlb_fault(mm, vma, vaddr,
>  				(flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
> +			cond_resched();
>  			if (!(ret & VM_FAULT_ERROR))
>  				continue;
>  

This is almost certainly the wrong placement as well since it's inserted 
inside a conditional inside a while loop and there's no reason to 
hugetlb_fault(), schedule, and then check the return value.  You need to 
insert your cond_resched()'s in legitimate places.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
