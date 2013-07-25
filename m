Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 16D466B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 10:01:09 -0400 (EDT)
Date: Thu, 25 Jul 2013 16:01:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Fix potential NULL pointer dereference
Message-ID: <20130725140106.GJ12818@dhcp22.suse.cz>
References: <1374637699-25704-1-git-send-email-huawei.libin@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374637699-25704-1-git-send-email-huawei.libin@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Libin <huawei.libin@huawei.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, xiaoguangrong@linux.vnet.ibm.com, wujianguo@huawei.com

On Wed 24-07-13 11:48:19, Libin wrote:
> find_vma may return NULL, thus check the return
> value to avoid NULL pointer dereference.

Please add a note that the check matters only because
khugepaged_alloc_page drops mmap_sem.

> Signed-off-by: Libin <huawei.libin@huawei.com>

Other than that
Reviewed-by: Michal Hocko <mhocko@suse.cz>

+ I guess this is worth backporting to the stable trees. This goes back
to when khugepaged was introduced AFAICS.

> ---
>  mm/huge_memory.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 243e710..d4423f4 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2294,6 +2294,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>  		goto out;
>  
>  	vma = find_vma(mm, address);
> +	if (!vma)
> +		goto out;
>  	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
>  	hend = vma->vm_end & HPAGE_PMD_MASK;
>  	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
> -- 
> 1.8.2.1
> 
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
