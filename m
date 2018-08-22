Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5EC46B2644
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 17:13:55 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r2-v6so1680230pgp.3
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 14:13:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7-v6sor794809pgl.245.2018.08.22.14.13.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 14:13:54 -0700 (PDT)
Date: Thu, 23 Aug 2018 00:05:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180822210507.lvb26bghqmt6c5fw@kshutemo-mobl1>
References: <20180821205902.21223-2-mike.kravetz@oracle.com>
 <201808220831.eM0je51n%fengguang.wu@intel.com>
 <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Tue, Aug 21, 2018 at 06:10:42PM -0700, Mike Kravetz wrote:
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3103099f64fd..f085019a4724 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4555,6 +4555,9 @@ static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
>  
>  	/*
>  	 * check on proper vm_flags and page table alignment
> +	 *
> +	 * Note that this is the same check used in huge_pmd_sharing_possible.
> +	 * If you change one, consider changing both.

Should we have helper to isolate the check in one place?

>  	 */
>  	if (vma->vm_flags & VM_MAYSHARE &&
>  	    vma->vm_start <= base && end <= vma->vm_end)
> @@ -4562,6 +4565,43 @@ static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
>  	return false;
>  }
>  
> +/*
> + * Determine if start,end range within vma could be mapped by shared pmd.
> + * If yes, adjust start and end to cover range associated with possible
> + * shared pmd mappings.
> + */
> +bool huge_pmd_sharing_possible(struct vm_area_struct *vma,
> +				unsigned long *start, unsigned long *end)
> +{
> +	unsigned long check_addr = *start;
> +	bool ret = false;
> +
> +	if (!(vma->vm_flags & VM_MAYSHARE))
> +		return ret;

Do we ever use return value? I don't see it.

And in this case function name is not really work...

> +	for (check_addr = *start; check_addr < *end; check_addr += PUD_SIZE) {
> +		unsigned long a_start = check_addr & PUD_MASK;
> +		unsigned long a_end = a_start + PUD_SIZE;
> +
> +		/*
> +		 * If sharing is possible, adjust start/end if necessary.
> +		 *
> +		 * Note that this is the same check used in vma_shareable.  If
> +		 * you change one, consider changing both.
> +		 */
> +		if (vma->vm_start <= a_start && a_end <= vma->vm_end) {
> +			if (a_start < *start)
> +				*start = a_start;
> +			if (a_end > *end)
> +				*end = a_end;
> +
> +			ret = true;
> +		}
> +	}
> +
> +	return ret;
> +}
> +

-- 
 Kirill A. Shutemov
