Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A13276B0038
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 07:58:35 -0400 (EDT)
Received: by wgso17 with SMTP id o17so78119093wgs.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 04:58:35 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id b2si13594941wix.117.2015.04.13.04.58.33
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 04:58:34 -0700 (PDT)
Date: Mon, 13 Apr 2015 14:58:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RESEND PATCH v3 1/2] mm: Introducing arch_remap hook
Message-ID: <20150413115811.GA12354@node.dhcp.inet.fi>
References: <cover.1428916945.git.ldufour@linux.vnet.ibm.com>
 <9d827fc618a718830b2c47aa87e8be546914c897.1428916945.git.ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9d827fc618a718830b2c47aa87e8be546914c897.1428916945.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@kernel.org>, linuxppc-dev@lists.ozlabs.org, cov@codeaurora.org, criu@openvz.org

On Mon, Apr 13, 2015 at 11:56:27AM +0200, Laurent Dufour wrote:
> Some architecture would like to be triggered when a memory area is moved
> through the mremap system call.
> 
> This patch is introducing a new arch_remap mm hook which is placed in the
> path of mremap, and is called before the old area is unmapped (and the
> arch_unmap hook is called).
> 
> The architectures which need to call this hook should define
> __HAVE_ARCH_REMAP in their asm/mmu_context.h and provide the arch_remap
> service with the following prototype:
> void arch_remap(struct mm_struct *mm,
>                 unsigned long old_start, unsigned long old_end,
>                 unsigned long new_start, unsigned long new_end);
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Reviewed-by: Ingo Molnar <mingo@kernel.org>
> ---
>  mm/mremap.c | 19 +++++++++++++------
>  1 file changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 2dc44b1cb1df..009db5565893 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -25,6 +25,7 @@
>  
>  #include <asm/cacheflush.h>
>  #include <asm/tlbflush.h>
> +#include <asm/mmu_context.h>
>  
>  #include "internal.h"
>  
> @@ -286,13 +287,19 @@ static unsigned long move_vma(struct vm_area_struct *vma,
>  		old_len = new_len;
>  		old_addr = new_addr;
>  		new_addr = -ENOMEM;
> -	} else if (vma->vm_file && vma->vm_file->f_op->mremap) {
> -		err = vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
> -		if (err < 0) {
> -			move_page_tables(new_vma, new_addr, vma, old_addr,
> -					 moved_len, true);
> -			return err;
> +	} else {
> +		if (vma->vm_file && vma->vm_file->f_op->mremap) {
> +			err = vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
> +			if (err < 0) {
> +				move_page_tables(new_vma, new_addr, vma,
> +						  old_addr, moved_len, true);
> +				return err;
> +			}
>  		}
> +#ifdef __HAVE_ARCH_REMAP

It would be cleaner to provide dummy arch_remap() for !__HAVE_ARCH_REMAP
in some generic header.


> +		arch_remap(mm, old_addr, old_addr+old_len,
> +			   new_addr, new_addr+new_len);

Spaces around '+'?

> +#endif
>  	}
>  
>  	/* Conceal VM_ACCOUNT so old reservation is not undone */
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
