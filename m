Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 89F6A6B00DA
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 19:46:51 -0400 (EDT)
Date: Mon, 18 Oct 2010 16:46:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] Add vzalloc shortcut
Message-Id: <20101018164647.bc928c78.akpm@linux-foundation.org>
In-Reply-To: <20101016043331.GA3177@darkstar>
References: <20101016043331.GA3177@darkstar>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Young <hidave.darkstar@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Oct 2010 12:33:31 +0800
Dave Young <hidave.darkstar@gmail.com> wrote:

> Add vzalloc for convinience of vmalloc-then-memset-zero case 
> 
> Use __GFP_ZERO in vzalloc to zero fill the allocated memory.
> 
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
> ---
>  include/linux/vmalloc.h |    1 +
>  mm/vmalloc.c            |   13 +++++++++++++
>  2 files changed, 14 insertions(+)
> 
> --- linux-2.6.orig/include/linux/vmalloc.h	2010-08-22 15:31:38.000000000 +0800
> +++ linux-2.6/include/linux/vmalloc.h	2010-10-16 10:50:54.739996121 +0800
> @@ -53,6 +53,7 @@ static inline void vmalloc_init(void)
>  #endif
>  
>  extern void *vmalloc(unsigned long size);
> +extern void *vzalloc(unsigned long size);
>  extern void *vmalloc_user(unsigned long size);
>  extern void *vmalloc_node(unsigned long size, int node);
>  extern void *vmalloc_exec(unsigned long size);
> --- linux-2.6.orig/mm/vmalloc.c	2010-08-22 15:31:39.000000000 +0800
> +++ linux-2.6/mm/vmalloc.c	2010-10-16 10:51:57.126665918 +0800
> @@ -1604,6 +1604,19 @@ void *vmalloc(unsigned long size)
>  EXPORT_SYMBOL(vmalloc);
>  
>  /**
> + *	vzalloc  -  allocate virtually contiguous memory with zero filled

s/filled/fill/

> + *	@size:		allocation size
> + *	Allocate enough pages to cover @size from the page level
> + *	allocator and map them into contiguous kernel virtual space.
> + */
> +void *vzalloc(unsigned long size)
> +{
> +	return __vmalloc_node(size, 1, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
> +				PAGE_KERNEL, -1, __builtin_return_address(0));
> +}
> +EXPORT_SYMBOL(vzalloc);

We'd need to add the same interface to nommu, please.

Also, a slightly better implementation would be

static inline void *__vmalloc_node_flags(unsigned long size, gfp_t flags)
{
	return __vmalloc_node(size, 1, flags, PAGE_KERNEL, -1,
				__builtin_return_address(0));
}

void *vzalloc(unsigned long size)
{
	return __vmalloc_node_flags(size,
				GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO);
}

void *vmalloc(unsigned long size)
{
	return __vmalloc_node_flags(size, GFP_KERNEL | __GFP_HIGHMEM);
}

just to avoid code duplication (and possible later errors derived from it).

Perhaps it should be always_inline, so the __builtin_return_address()
can't get broken.

Or just leave it the way you had it :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
