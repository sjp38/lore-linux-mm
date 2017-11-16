Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE90280259
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 08:23:16 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q126so27159027pgq.7
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 05:23:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bc7si885553plb.428.2017.11.16.05.23.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 05:23:15 -0800 (PST)
Date: Thu, 16 Nov 2017 14:23:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv3 1/2] x86/mm: Prevent non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
Message-ID: <20171116132312.foifkzsrh7dllssx@dhcp22.suse.cz>
References: <20171115143607.81541-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115143607.81541-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 15-11-17 17:36:06, Kirill A. Shutemov wrote:
> In case of 5-level paging, the kernel does not place any mapping above
> 47-bit, unless userspace explicitly asks for it.
> 
> Userspace can request an allocation from the full address space by
> specifying the mmap address hint above 47-bit.
> 
> Nicholas noticed that the current implementation violates this interface:
> 
>   If user space requests a mapping at the end of the 47-bit address space
>   with a length which causes the mapping to cross the 47-bit border
>   (DEFAULT_MAP_WINDOW), then the vma is partially in the address space
>   below and above.
> 
> Sanity check the mmap address hint so that start and end of the resulting
> vma are on the same side of the 47-bit border. If that's not the case fall
> back to the code path which ignores the address hint and allocate from the
> regular address space below 47-bit.
> 
> [ tglx: Moved the address check to a function and massaged comment and
>   	changelog ]
> 
> Reported-by: Nicholas Piggin <npiggin@gmail.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

FWIW
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/x86/include/asm/elf.h   |  1 +
>  arch/x86/kernel/sys_x86_64.c | 10 +++++++---
>  arch/x86/mm/hugetlbpage.c    | 11 ++++++++---
>  arch/x86/mm/mmap.c           | 46 ++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 62 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
> index 3a091cea36c5..0d157d2a1e2a 100644
> --- a/arch/x86/include/asm/elf.h
> +++ b/arch/x86/include/asm/elf.h
> @@ -309,6 +309,7 @@ static inline int mmap_is_ia32(void)
>  extern unsigned long task_size_32bit(void);
>  extern unsigned long task_size_64bit(int full_addr_space);
>  extern unsigned long get_mmap_base(int is_legacy);
> +extern bool mmap_address_hint_valid(unsigned long addr, unsigned long len);
>  
>  #ifdef CONFIG_X86_32
>  
> diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
> index a63fe77b3217..676774b9bb8d 100644
> --- a/arch/x86/kernel/sys_x86_64.c
> +++ b/arch/x86/kernel/sys_x86_64.c
> @@ -188,6 +188,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  	if (len > TASK_SIZE)
>  		return -ENOMEM;
>  
> +	/* No address checking. See comment at mmap_address_hint_valid() */
>  	if (flags & MAP_FIXED)
>  		return addr;
>  
> @@ -197,12 +198,15 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  
>  	/* requesting a specific address */
>  	if (addr) {
> -		addr = PAGE_ALIGN(addr);
> +		addr &= PAGE_MASK;
> +		if (!mmap_address_hint_valid(addr, len))
> +			goto get_unmapped_area;
> +
>  		vma = find_vma(mm, addr);
> -		if (TASK_SIZE - len >= addr &&
> -				(!vma || addr + len <= vm_start_gap(vma)))
> +		if (!vma || addr + len <= vm_start_gap(vma))
>  			return addr;
>  	}
> +get_unmapped_area:
>  
>  	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
>  	info.length = len;
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index 8ae0000cbdb3..00b296617ca4 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -158,6 +158,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>  	if (len > TASK_SIZE)
>  		return -ENOMEM;
>  
> +	/* No address checking. See comment at mmap_address_hint_valid() */
>  	if (flags & MAP_FIXED) {
>  		if (prepare_hugepage_range(file, addr, len))
>  			return -EINVAL;
> @@ -165,12 +166,16 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>  	}
>  
>  	if (addr) {
> -		addr = ALIGN(addr, huge_page_size(h));
> +		addr &= huge_page_mask(h);
> +		if (!mmap_address_hint_valid(addr, len))
> +			goto get_unmapped_area;
> +
>  		vma = find_vma(mm, addr);
> -		if (TASK_SIZE - len >= addr &&
> -		    (!vma || addr + len <= vm_start_gap(vma)))
> +		if (!vma || addr + len <= vm_start_gap(vma))
>  			return addr;
>  	}
> +
> +get_unmapped_area:
>  	if (mm->get_unmapped_area == arch_get_unmapped_area)
>  		return hugetlb_get_unmapped_area_bottomup(file, addr, len,
>  				pgoff, flags);
> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
> index a99679826846..62285fe77b0f 100644
> --- a/arch/x86/mm/mmap.c
> +++ b/arch/x86/mm/mmap.c
> @@ -174,3 +174,49 @@ const char *arch_vma_name(struct vm_area_struct *vma)
>  		return "[mpx]";
>  	return NULL;
>  }
> +
> +/**
> + * mmap_address_hint_valid - Validate the address hint of mmap
> + * @addr:	Address hint
> + * @len:	Mapping length
> + *
> + * Check whether @addr and @addr + @len result in a valid mapping.
> + *
> + * On 32bit this only checks whether @addr + @len is <= TASK_SIZE.
> + *
> + * On 64bit with 5-level page tables another sanity check is required
> + * because mappings requested by mmap(@addr, 0) which cross the 47-bit
> + * virtual address boundary can cause the following theoretical issue:
> + *
> + *  An application calls mmap(addr, 0), i.e. without MAP_FIXED, where @addr
> + *  is below the border of the 47-bit address space and @addr + @len is
> + *  above the border.
> + *
> + *  With 4-level paging this request succeeds, but the resulting mapping
> + *  address will always be within the 47-bit virtual address space, because
> + *  the hint address does not result in a valid mapping and is
> + *  ignored. Hence applications which are not prepared to handle virtual
> + *  addresses above 47-bit work correctly.
> + *
> + *  With 5-level paging this request would be granted and result in a
> + *  mapping which crosses the border of the 47-bit virtual address
> + *  space. If the application cannot handle addresses above 47-bit this
> + *  will lead to misbehaviour and hard to diagnose failures.
> + *
> + * Therefore ignore address hints which would result in a mapping crossing
> + * the 47-bit virtual address boundary.
> + *
> + * Note, that in the same scenario with MAP_FIXED the behaviour is
> + * different. The request with @addr < 47-bit and @addr + @len > 47-bit
> + * fails on a 4-level paging machine but succeeds on a 5-level paging
> + * machine. It is reasonable to expect that an application does not rely on
> + * the failure of such a fixed mapping request, so the restriction is not
> + * applied.
> + */
> +bool mmap_address_hint_valid(unsigned long addr, unsigned long len)
> +{
> +	if (TASK_SIZE - len < addr)
> +		return false;
> +
> +	return (addr > DEFAULT_MAP_WINDOW) == (addr + len > DEFAULT_MAP_WINDOW);
> +}
> -- 
> 2.15.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
