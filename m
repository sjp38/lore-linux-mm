Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F33E6B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:09:03 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so10313101lfg.3
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:09:03 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id bs1si11512880wjc.28.2016.07.28.00.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 00:09:02 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q128so9723538wma.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:09:01 -0700 (PDT)
Date: Thu, 28 Jul 2016 09:09:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2] mm/hugetlb: Avoid soft lockup in set_max_huge_pages()
Message-ID: <20160728070900.GA31860@dhcp22.suse.cz>
References: <1469674442-14848-1-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469674442-14848-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>

On Thu 28-07-16 10:54:02, Jia He wrote:
> In powerpc servers with large memory(32TB), we watched several soft
> lockups for hugepage under stress tests.
> The call trace are as follows:
> 1.
> get_page_from_freelist+0x2d8/0xd50  
> __alloc_pages_nodemask+0x180/0xc20  
> alloc_fresh_huge_page+0xb0/0x190    
> set_max_huge_pages+0x164/0x3b0      
> 
> 2.
> prep_new_huge_page+0x5c/0x100             
> alloc_fresh_huge_page+0xc8/0x190          
> set_max_huge_pages+0x164/0x3b0
> 
> This patch is to fix such soft lockups. It is safe to call cond_resched() 
> there because it is out of spin_lock/unlock section.
> 
> Signed-off-by: Jia He <hejianet@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> 
> ---
> Changes in V2: move cond_resched to a common calling site in set_max_huge_pages
> 
>  mm/hugetlb.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index abc1c5f..9284280 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2216,6 +2216,10 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>  		 * and reducing the surplus.
>  		 */
>  		spin_unlock(&hugetlb_lock);
> +
> +		/* yield cpu to avoid soft lockup */
> +		cond_resched();
> +
>  		if (hstate_is_gigantic(h))
>  			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
>  		else
> -- 
> 2.5.0
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
