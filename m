Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 2E6496B003A
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:59:14 -0400 (EDT)
Date: Tue, 14 May 2013 10:59:06 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v5 4/8] vmalloc: introduce remap_vmalloc_range_partial
Message-ID: <20130514145906.GD16772@redhat.com>
References: <20130514015622.18697.77191.stgit@localhost6.localdomain6>
 <20130514015729.18697.88256.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130514015729.18697.88256.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, Rik Van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>

On Tue, May 14, 2013 at 10:57:29AM +0900, HATAYAMA Daisuke wrote:
> We want to allocate ELF note segment buffer on the 2nd kernel in
> vmalloc space and remap it to user-space in order to reduce the risk
> that memory allocation fails on system with huge number of CPUs and so
> with huge ELF note segment that exceeds 11-order block size.
> 
> Although there's already remap_vmalloc_range for the purpose of
> remapping vmalloc memory to user-space, we need to specify user-space
> range via vma. Mmap on /proc/vmcore needs to remap range across
> multiple objects, so the interface that requires vma to cover full
> range is problematic.
> 
> This patch introduces remap_vmalloc_range_partial that receives
> user-space range as a pair of base address and size and can be used
> for mmap on /proc/vmcore case.
> 
> remap_vmalloc_range is rewritten using remap_vmalloc_range_partial.
> 
> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>

This also needs ACK of VM folks. CCing some of them.

Thanks
Vivek

> ---
> 
>  include/linux/vmalloc.h |    4 +++
>  mm/vmalloc.c            |   63 +++++++++++++++++++++++++++++++++--------------
>  2 files changed, 48 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 7d5773a..dd0a2c8 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -82,6 +82,10 @@ extern void *vmap(struct page **pages, unsigned int count,
>  			unsigned long flags, pgprot_t prot);
>  extern void vunmap(const void *addr);
>  
> +extern int remap_vmalloc_range_partial(struct vm_area_struct *vma,
> +				       unsigned long uaddr, void *kaddr,
> +				       unsigned long size);
> +

>  extern int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
>  							unsigned long pgoff);
>  void vmalloc_sync_all(void);
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 3875fa2..d9a9f4f6 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2148,42 +2148,44 @@ finished:
>  }
>  
>  /**
> - *	remap_vmalloc_range  -  map vmalloc pages to userspace
> - *	@vma:		vma to cover (map full range of vma)
> - *	@addr:		vmalloc memory
> - *	@pgoff:		number of pages into addr before first page to map
> + *	remap_vmalloc_range_partial  -  map vmalloc pages to userspace
> + *	@vma:		vma to cover
> + *	@uaddr:		target user address to start at
> + *	@kaddr:		virtual address of vmalloc kernel memory
> + *	@size:		size of map area
>   *
>   *	Returns:	0 for success, -Exxx on failure
>   *
> - *	This function checks that addr is a valid vmalloc'ed area, and
> - *	that it is big enough to cover the vma. Will return failure if
> - *	that criteria isn't met.
> + *	This function checks that @kaddr is a valid vmalloc'ed area,
> + *	and that it is big enough to cover the range starting at
> + *	@uaddr in @vma. Will return failure if that criteria isn't
> + *	met.
>   *
>   *	Similar to remap_pfn_range() (see mm/memory.c)
>   */
> -int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
> -						unsigned long pgoff)
> +int remap_vmalloc_range_partial(struct vm_area_struct *vma, unsigned long uaddr,
> +				void *kaddr, unsigned long size)
>  {
>  	struct vm_struct *area;
> -	unsigned long uaddr = vma->vm_start;
> -	unsigned long usize = vma->vm_end - vma->vm_start;
>  
> -	if ((PAGE_SIZE-1) & (unsigned long)addr)
> +	size = PAGE_ALIGN(size);
> +
> +	if (((PAGE_SIZE-1) & (unsigned long)uaddr) ||
> +	    ((PAGE_SIZE-1) & (unsigned long)kaddr))
>  		return -EINVAL;
>  
> -	area = find_vm_area(addr);
> +	area = find_vm_area(kaddr);
>  	if (!area)
>  		return -EINVAL;
>  
>  	if (!(area->flags & VM_USERMAP))
>  		return -EINVAL;
>  
> -	if (usize + (pgoff << PAGE_SHIFT) > area->size - PAGE_SIZE)
> +	if (kaddr + size > area->addr + area->size)
>  		return -EINVAL;
>  
> -	addr += pgoff << PAGE_SHIFT;
>  	do {
> -		struct page *page = vmalloc_to_page(addr);
> +		struct page *page = vmalloc_to_page(kaddr);
>  		int ret;
>  
>  		ret = vm_insert_page(vma, uaddr, page);
> @@ -2191,14 +2193,37 @@ int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
>  			return ret;
>  
>  		uaddr += PAGE_SIZE;
> -		addr += PAGE_SIZE;
> -		usize -= PAGE_SIZE;
> -	} while (usize > 0);
> +		kaddr += PAGE_SIZE;
> +		size -= PAGE_SIZE;
> +	} while (size > 0);
>  
>  	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
>  
>  	return 0;
>  }
> +EXPORT_SYMBOL(remap_vmalloc_range_partial);
> +
> +/**
> + *	remap_vmalloc_range  -  map vmalloc pages to userspace
> + *	@vma:		vma to cover (map full range of vma)
> + *	@addr:		vmalloc memory
> + *	@pgoff:		number of pages into addr before first page to map
> + *
> + *	Returns:	0 for success, -Exxx on failure
> + *
> + *	This function checks that addr is a valid vmalloc'ed area, and
> + *	that it is big enough to cover the vma. Will return failure if
> + *	that criteria isn't met.
> + *
> + *	Similar to remap_pfn_range() (see mm/memory.c)
> + */
> +int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
> +						unsigned long pgoff)
> +{
> +	return remap_vmalloc_range_partial(vma, vma->vm_start,
> +					   addr + (pgoff << PAGE_SHIFT),
> +					   vma->vm_end - vma->vm_start);
> +}
>  EXPORT_SYMBOL(remap_vmalloc_range);
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
