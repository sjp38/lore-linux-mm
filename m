Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 64EA76B003B
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 12:27:21 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id wy17so1139184pbc.39
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 09:27:21 -0800 (PST)
Received: from psmtp.com ([74.125.245.181])
        by mx.google.com with SMTP id v7si3644773pbi.188.2013.11.14.09.27.13
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 09:27:14 -0800 (PST)
Message-ID: <528507BA.9010101@intel.com>
Date: Thu, 14 Nov 2013 09:26:18 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/4] mm/vmalloc.c: Treat the entire kernel virtual
 space as vmalloc
References: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org> <1384212412-21236-5-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1384212412-21236-5-git-send-email-lauraa@codeaurora.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: Neeti Desai <neetid@codeaurora.org>

On 11/11/2013 03:26 PM, Laura Abbott wrote:
> With CONFIG_ENABLE_VMALLOC_SAVINGS, all lowmem is tracked in
> vmalloc. This means that all the kernel virtual address space
> can be treated as part of the vmalloc region. Allow vm areas
> to be allocated from the full kernel address range.
> 
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> Signed-off-by: Neeti Desai <neetid@codeaurora.org>
> ---
>  mm/vmalloc.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index c7b138b..181247d 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1385,16 +1385,27 @@ struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
>   */
>  struct vm_struct *get_vm_area(unsigned long size, unsigned long flags)
>  {
> +#ifdef CONFIG_ENABLE_VMALLOC_SAVING
> +	return __get_vm_area_node(size, 1, flags, PAGE_OFFSET, VMALLOC_END,
> +				  NUMA_NO_NODE, GFP_KERNEL,
> +				  __builtin_return_address(0));
> +#else
>  	return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
>  				  NUMA_NO_NODE, GFP_KERNEL,
>  				  __builtin_return_address(0));
> +#endif
>  }
>  
>  struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
>  				const void *caller)
>  {
> +#ifdef CONFIG_ENABLE_VMALLOC_SAVING
> +	return __get_vm_area_node(size, 1, flags, PAGE_OFFSET, VMALLOC_END,
> +				  NUMA_NO_NODE, GFP_KERNEL, caller);
> +#else
>  	return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
>  				  NUMA_NO_NODE, GFP_KERNEL, caller);
> +#endif
>  }

Couple of nits: first of all, there's no reason to copy, paste, and
#ifdef this much code.  This just invites one of the copies to bitrot.
I'd much rather see this:

#ifdef CONFIG_ENABLE_VMALLOC_SAVING
#define LOWEST_VMALLOC_VADDR PAGE_OFFSET
#else
#define LOWEST_VMALLOC_VADDR VMALLOC_START
#endif

Then just replace the PAGE_OFFSET in the function arguments with
LOWEST_VMALLOC_VADDR.

Have you done any audits to make sure that the rest of the code that
deals with vmalloc addresses in the kernel is using is_vmalloc_addr()?
I'd be a bit worried that we might have picked up an assumption or two
that *all* vmalloc addresses are _above_ VMALLOC_START.

The percpu.c code looks like it might do this, and maybe the kcore code.
 The vmalloc.c code itself has this in get_vmalloc_info():

>                 /*
>                  * Some archs keep another range for modules in vmalloc space
>                  */
>                 if (addr < VMALLOC_START)
>                         continue;

Seems like that would break as well.

With this patch, VMALLOC_START loses enough of its meaning that I wonder
if we should even keep it around.  It's the start of the _dedicated_
vmalloc space, but it's mostly useless and obscure enough that maybe we
should get rid of its use in common code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
