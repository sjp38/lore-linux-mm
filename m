Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9ADBF6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 03:29:51 -0500 (EST)
Received: by ioir85 with SMTP id r85so79516110ioi.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 00:29:51 -0800 (PST)
Received: from us-alimail-mta2.hst.scl.en.alidc.net (mail113-251.mail.alibaba.com. [205.204.113.251])
        by mx.google.com with ESMTP id wf4si2817545pab.231.2015.11.26.00.29.48
        for <linux-mm@kvack.org>;
        Thu, 26 Nov 2015 00:29:50 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1448524936-10501-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1448524936-10501-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: hugetlb: call huge_pte_alloc() only if ptep is null
Date: Thu, 26 Nov 2015 16:29:30 +0800
Message-ID: <00d301d12824$932eda30$b98c8e90$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'David Rientjes' <rientjes@google.com>, 'Hugh Dickins' <hughd@google.com>, 'Dave Hansen' <dave.hansen@intel.com>, 'Mel Gorman' <mgorman@suse.de>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Naoya Horiguchi' <nao.horiguchi@gmail.com>

> 
> Currently at the beginning of hugetlb_fault(), we call huge_pte_offset()
> and check whether the obtained *ptep is a migration/hwpoison entry or not.
> And if not, then we get to call huge_pte_alloc(). This is racy because the
> *ptep could turn into migration/hwpoison entry after the huge_pte_offset()
> check. This race results in BUG_ON in huge_pte_alloc().
> 
> We don't have to call huge_pte_alloc() when the huge_pte_offset() returns
> non-NULL, so let's fix this bug with moving the code into else block.
> 
> Note that the *ptep could turn into a migration/hwpoison entry after
> this block, but that's not a problem because we have another !pte_present
> check later (we never go into hugetlb_no_page() in that case.)
> 
> Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: <stable@vger.kernel.org> [2.6.36+]
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/hugetlb.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git next-20151123/mm/hugetlb.c next-20151123_patched/mm/hugetlb.c
> index 1101ccd..6ad5e91 100644
> --- next-20151123/mm/hugetlb.c
> +++ next-20151123_patched/mm/hugetlb.c
> @@ -3696,12 +3696,12 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
>  			return VM_FAULT_HWPOISON_LARGE |
>  				VM_FAULT_SET_HINDEX(hstate_index(h));
> +	} else {
> +		ptep = huge_pte_alloc(mm, address, huge_page_size(h));
> +		if (!ptep)
> +			return VM_FAULT_OOM;
>  	}
> 
> -	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
> -	if (!ptep)
> -		return VM_FAULT_OOM;
> -
>  	mapping = vma->vm_file->f_mapping;
>  	idx = vma_hugecache_offset(h, vma, address);
> 
> --
> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
