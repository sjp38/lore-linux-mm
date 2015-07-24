Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5279003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 03:00:05 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so15072165wib.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 00:00:05 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id p4si2598856wiz.100.2015.07.24.00.00.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 00:00:02 -0700 (PDT)
Received: by wicmv11 with SMTP id mv11so52306114wic.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 00:00:01 -0700 (PDT)
Date: Fri, 24 Jul 2015 08:59:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] hugetlb: cond_resched for set_max_huge_pages and
 follow_hugetlb_page
Message-ID: <20150724065959.GB4622@dhcp22.suse.cz>
References: <1437688476-3399-1-git-send-email-sbaugh@catern.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437688476-3399-1-git-send-email-sbaugh@catern.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Spencer Baugh <sbaugh@catern.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>, Luiz Capitulino <lcapitulino@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Joern Engel <joern@purestorage.com>, Spencer Baugh <Spencer.baugh@purestorage.com>, Joern Engel <joern@logfs.org>

On Thu 23-07-15 14:54:31, Spencer Baugh wrote:
> From: Joern Engel <joern@logfs.org>
> 
> ~150ms scheduler latency for both observed in the wild.

This is way to vague. Could you describe your problem somehow more,
please?
There are schduling points in the page allocator (when it triggers the
reclaim), why are those not sufficient? Or do you manage to allocate
many hugetlb pages without performing the reclaim and that leads to
soft lockups?

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
> @@ -3521,6 +3522,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  				spin_unlock(ptl);
>  			ret = hugetlb_fault(mm, vma, vaddr,
>  				(flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
> +			cond_resched();
>  			if (!(ret & VM_FAULT_ERROR))
>  				continue;
>  
> -- 
> 2.5.0.rc3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
