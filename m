Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.7/8.13.7) with ESMTP id k7GAt9En021510
	for <linux-mm@kvack.org>; Wed, 16 Aug 2006 10:55:09 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7GAv1SL105728
	for <linux-mm@kvack.org>; Wed, 16 Aug 2006 11:57:01 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7GAt8HP011026
	for <linux-mm@kvack.org>; Wed, 16 Aug 2006 11:55:09 +0100
Date: Wed, 16 Aug 2006 13:55:07 +0300
From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: [PATCH 2/2] Simple shared page tables
Message-ID: <20060816105507.GE3067@rhun.haifa.ibm.com>
References: <20060815225607.17433.32727.sendpatch@wildcat> <20060815225618.17433.84777.sendpatch@wildcat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060815225618.17433.84777.sendpatch@wildcat>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Arjan van de Ven <arjan@infradead.org>, Diego Calleja <diegocg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 15, 2006 at 05:56:18PM -0500, Dave McCracken wrote:

> The actual shared page table patches

Some stylistic nits I ran into while reading these:

> +#else /* CONFIG_PTSHARE */
> +#define pt_is_shared(page)	(0)
> +#define pt_is_shared_pte(pmdval)	(0)
> +#define pt_increment_share(page)
> +#define pt_decrement_share(page)
> +#define	pt_share_pte(vma, pmd, address)	pte_alloc_map(vma->vm_mm, pmd, address)
> +#define pt_unshare_range(mm, address, end)
> +#define pt_check_unshare_pte(mm, address, pmd)	(0)
> +#endif /* CONFIG_PTSHARE */

ISTR empty statements gave warnings with some compilers, perhaps use
do {} while (0) here?

> @@ -144,8 +147,9 @@ mprotect_fixup(struct vm_area_struct *vm
>  	if (newflags & VM_WRITE) {
>  		if (!(oldflags & (VM_ACCOUNT|VM_WRITE|VM_SHARED))) {
>  			charged = nrpages;
> -			if (security_vm_enough_memory(charged))
> +			if (security_vm_enough_memory(charged)) {
>  				return -ENOMEM;
> +			}

Superflous {}

>  			newflags |= VM_ACCOUNT;
>  		}
>  	}
> @@ -182,7 +186,7 @@ success:
>  	if (vma->vm_ops && vma->vm_ops->page_mkwrite)
>  		mask &= ~VM_SHARED;
>  
> -	newprot = protection_map[newflags & mask];
> + 	newprot = protection_map[newflags & mask];

Whitespace damaged

Cheers,
Muli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
