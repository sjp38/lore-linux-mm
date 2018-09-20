Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 881F78E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 07:05:49 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 186-v6so3995972pgc.12
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 04:05:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a79-v6sor3742329pfj.60.2018.09.20.04.05.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Sep 2018 04:05:48 -0700 (PDT)
Date: Thu, 20 Sep 2018 14:05:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Recheck page table entry with page table lock held
Message-ID: <20180920110538.rlcpw75eabkqudkl@kshutemo-mobl1>
References: <20180920092408.9128-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180920092408.9128-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 20, 2018 at 02:54:08PM +0530, Aneesh Kumar K.V wrote:
> We clear the pte temporarily during read/modify/write update of the pte. If we
> take a page fault while the pte is cleared, the application can get SIGBUS. One
> such case is with remap_pfn_range without a backing vm_ops->fault callback.
> do_fault will return SIGBUS in that case.

It would be nice to show the path that clears pte temporarily.

> Fix this by taking page table lock and rechecking for pte_none.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  mm/memory.c | 31 +++++++++++++++++++++++++++----
>  1 file changed, 27 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index c467102a5cbc..c2f933184303 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3745,10 +3745,33 @@ static vm_fault_t do_fault(struct vm_fault *vmf)
>  	struct vm_area_struct *vma = vmf->vma;
>  	vm_fault_t ret;
>  
> -	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
> -	if (!vma->vm_ops->fault)
> -		ret = VM_FAULT_SIGBUS;
> -	else if (!(vmf->flags & FAULT_FLAG_WRITE))
> +	/*
> +	 * The VMA was not fully populated on mmap() or missing VM_DONTEXPAND
> +	 */
> +	if (!vma->vm_ops->fault) {
> +
> +		/*
> +		 * pmd entries won't be marked none during a R/M/W cycle.
> +		 */
> +		if (unlikely(pmd_none(*vmf->pmd)))
> +			ret = VM_FAULT_SIGBUS;
> +		else {
> +			vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> +			/*
> +			 * Make sure this is not a temporary clearing of pte
> +			 * by holding ptl and checking again. A R/M/W update
> +			 * of pte involves: take ptl, clearing the pte so that
> +			 * we don't have concurrent modification by hardware
> +			 * followed by an update.
> +			 */
> +			spin_lock(vmf->ptl);
> +			if (unlikely(pte_none(*vmf->pte)))
> +				ret = VM_FAULT_SIGBUS;
> +			else
> +				ret = VM_FAULT_NOPAGE;

We return 0 if we did nothing in fault path.

-- 
 Kirill A. Shutemov
