Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C45D16B0069
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 05:14:42 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l22so7400079wre.11
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 02:14:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j127si10753123wma.83.2018.01.10.02.14.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jan 2018 02:14:41 -0800 (PST)
Date: Wed, 10 Jan 2018 11:14:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, hugetlb: Fix a double unlock bug in
 alloc_surplus_huge_page()
Message-ID: <20180110101439.GQ1732@dhcp22.suse.cz>
References: <20180109200559.g3iz5kvbdrz7yydp@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180109200559.g3iz5kvbdrz7yydp@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Punit Agrawal <punit.agrawal@arm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Tue 09-01-18 23:06:00, Dan Carpenter wrote:
> We aren't holding the hugetlb_lock so there is no need to unlock.
> 
> Fixes: b27f11e5e675 ("mm, hugetlb: get rid of surplus page accounting tricks")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Ups, a left over after refactoring. Andrew, could you fold this into
mm-hugetlb-further-simplify-hugetlb-allocation-api.patch please?
 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ffcae114ceed..742a929f2311 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1567,7 +1567,7 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
>  
>  	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask);
>  	if (!page)
> -		goto out_unlock;
> +		return NULL;
>  
>  	spin_lock(&hugetlb_lock);
>  	/*

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
