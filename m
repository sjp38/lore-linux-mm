Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C69D06B0038
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 07:37:53 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c55so2651568wrc.22
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 04:37:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 18si7706056wmf.85.2017.04.12.04.37.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 04:37:52 -0700 (PDT)
Subject: Re: [PATCH 1/4] thp: reduce indentation level in change_huge_pmd()
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
 <20170302151034.27829-2-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a33e10b7-9785-1c92-f12d-d56713835d10@suse.cz>
Date: Wed, 12 Apr 2017 13:37:51 +0200
MIME-Version: 1.0
In-Reply-To: <20170302151034.27829-2-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/02/2017 04:10 PM, Kirill A. Shutemov wrote:
> Restructure code in preparation for a fix.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/huge_memory.c | 52 ++++++++++++++++++++++++++--------------------------
>  1 file changed, 26 insertions(+), 26 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 71e3dede95b4..e7ce73b2b208 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1722,37 +1722,37 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	spinlock_t *ptl;
> -	int ret = 0;
> +	pmd_t entry;
> +	bool preserve_write;
> +	int ret;
>  
>  	ptl = __pmd_trans_huge_lock(pmd, vma);
> -	if (ptl) {
> -		pmd_t entry;
> -		bool preserve_write = prot_numa && pmd_write(*pmd);
> -		ret = 1;
> +	if (!ptl)
> +		return 0;
>  
> -		/*
> -		 * Avoid trapping faults against the zero page. The read-only
> -		 * data is likely to be read-cached on the local CPU and
> -		 * local/remote hits to the zero page are not interesting.
> -		 */
> -		if (prot_numa && is_huge_zero_pmd(*pmd)) {
> -			spin_unlock(ptl);
> -			return ret;
> -		}
> +	preserve_write = prot_numa && pmd_write(*pmd);
> +	ret = 1;
>  
> -		if (!prot_numa || !pmd_protnone(*pmd)) {
> -			entry = pmdp_huge_get_and_clear_notify(mm, addr, pmd);
> -			entry = pmd_modify(entry, newprot);
> -			if (preserve_write)
> -				entry = pmd_mk_savedwrite(entry);
> -			ret = HPAGE_PMD_NR;
> -			set_pmd_at(mm, addr, pmd, entry);
> -			BUG_ON(vma_is_anonymous(vma) && !preserve_write &&
> -					pmd_write(entry));
> -		}
> -		spin_unlock(ptl);
> -	}
> +	/*
> +	 * Avoid trapping faults against the zero page. The read-only
> +	 * data is likely to be read-cached on the local CPU and
> +	 * local/remote hits to the zero page are not interesting.
> +	 */
> +	if (prot_numa && is_huge_zero_pmd(*pmd))
> +		goto unlock;
>  
> +	if (prot_numa && pmd_protnone(*pmd))
> +		goto unlock;
> +
> +	entry = pmdp_huge_get_and_clear_notify(mm, addr, pmd);
> +	entry = pmd_modify(entry, newprot);
> +	if (preserve_write)
> +		entry = pmd_mk_savedwrite(entry);
> +	ret = HPAGE_PMD_NR;
> +	set_pmd_at(mm, addr, pmd, entry);
> +	BUG_ON(vma_is_anonymous(vma) && !preserve_write && pmd_write(entry));
> +unlock:
> +	spin_unlock(ptl);
>  	return ret;
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
