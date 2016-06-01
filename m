Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0966B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 23:09:30 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id dh6so4462090obb.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 20:09:30 -0700 (PDT)
Received: from out4133-82.mail.aliyun.com (out4133-82.mail.aliyun.com. [42.120.133.82])
        by mx.google.com with ESMTP id l133si35371098itd.105.2016.05.31.20.09.28
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 20:09:29 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1464720957-15698-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1464720957-15698-1-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [PATCH] mm/hugetlb: fix huge page reserve accounting for private mappings
Date: Wed, 01 Jun 2016 11:09:23 +0800
Message-ID: <00a801d1bbb3$00980d40$01c827c0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Kirill Shutemov' <kirill.shutemov@linux.intel.com>, 'Michal Hocko' <mhocko@suse.cz>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Aneesh Kumar' <aneesh.kumar@linux.vnet.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>

> 
> When creating a private mapping of a hugetlbfs file, it is possible to
> unmap pages via ftruncate or fallocate hole punch.  If subsequent faults
> repopulate these mappings, the reserve counts will go negative.  This
> is because the code currently assumes all faults to private mappings will
> consume reserves.  The problem can be recreated as follows:
> - mmap(MAP_PRIVATE) a file in hugetlbfs filesystem
> - write fault in pages in the mapping
> - fallocate(FALLOC_FL_PUNCH_HOLE) some pages in the mapping
> - write fault in pages in the hole
> This will result in negative huge page reserve counts and negative subpool
> usage counts for the hugetlbfs.  Note that this can also be recreated with
> ftruncate, but fallocate is more straight forward.
> 
> This patch modifies the routines vma_needs_reserves and vma_has_reserves
> to examine the reserve map associated with private mappings similar to that
> for shared mappings.  However, the reserve map semantics for private and
> shared mappings are very different.  This results in subtly different code
> that is explained in the comments.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/hugetlb.c | 42 ++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 40 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 949d806..0949d0d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -831,8 +831,27 @@ static bool vma_has_reserves(struct vm_area_struct *vma, long chg)
>  	 * Only the process that called mmap() has reserves for
>  	 * private mappings.
>  	 */
> -	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
> -		return true;
> +	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> +		/*
> +		 * Like the shared case above, a hole punch or truncate
> +		 * could have been performed on the private mapping.
> +		 * Examine the value of chg to determine if reserves
> +		 * actually exist or were previously consumed.
> +		 * Very Subtle - The value of chg comes from a previous
> +		 * call to vma_needs_reserves().  The reserve map for
> +		 * private mappings has different (opposite) semantics
> +		 * than that of shared mappings.  vma_needs_reserves()
> +		 * has already taken this difference in semantics into
> +		 * account.  Therefore, the meaning of chg is the same
> +		 * as in the shared case above.  Code could easily be
> +		 * combined, but keeping it separate draws attention to
> +		 * subtle differences.
> +		 */
> +		if (chg)
> +			return false;
> +		else
> +			return true;
> +	}
> 
>  	return false;
>  }
> @@ -1815,6 +1834,25 @@ static long __vma_reservation_common(struct hstate *h,
> 
>  	if (vma->vm_flags & VM_MAYSHARE)
>  		return ret;
> +	else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER) && ret >= 0) {
> +		/*
> +		 * In most cases, reserves always exist for private mappings.
> +		 * However, a file associated with mapping could have been
> +		 * hole punched or truncated after reserves were consumed.
> +		 * As subsequent fault on such a range will not use reserves.
> +		 * Subtle - The reserve map for private mappings has the
> +		 * opposite meaning than that of shared mappings.  If NO
> +		 * entry is in the reserve map, it means a reservation exists.
> +		 * If an entry exists in the reserve map, it means the
> +		 * reservation has already been consumed.  As a result, the
> +		 * return value of this routine is the opposite of the
> +		 * value returned from reserve map manipulation routines above.
> +		 */
> +		if (ret)
> +			return 0;
> +		else
> +			return 1;
> +	}
>  	else
>  		return ret < 0 ? ret : 0;
>  }
> --
> 2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
