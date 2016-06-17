Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6767D6B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:21:14 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g18so38874249lfg.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:21:14 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id h140si23292665wme.22.2016.06.17.05.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 05:21:13 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id 187so16328809wmz.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:21:13 -0700 (PDT)
Date: Fri, 17 Jun 2016 14:21:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix account pmd page to the process
Message-ID: <20160617122109.GE21670@dhcp22.suse.cz>
References: <1466164575-13578-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466164575-13578-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: mike.kravetz@oracle.com, akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 17-06-16 19:56:15, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> hen a process acquire a pmd table shared by other process, we
> increase the account to current process. otherwise, a race result
> in other tasks have set the pud entry. so it no need to increase it.

I have really hard time to understand (well even to parse) the
changelog. What do you think about the following?
"
huge_pmd_share accounts the number of pmds incorrectly when it races
with a parallel pud instantiation. vma_interval_tree_foreach will
increase the counter but then has to recheck the pud with the pte lock
held and the back off path should drop the increment. The previous
code would lead to an elevated pmd count which shouldn't be very
harmful (check_mm() might complain and oom_badness() might be marginally
confused) but this is worth fixing.
"

But please note that I am still not 100% sure the race is real.

> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/hugetlb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 19d0d08..3072857 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4191,7 +4191,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
>  	} else {
>  		put_page(virt_to_page(spte));
> -		mm_inc_nr_pmds(mm);
> +		mm_dec_nr_pmds(mm);
>  	}
>  	spin_unlock(ptl);
>  out:
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
