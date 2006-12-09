Message-ID: <457AF156.8070606@cern.ch>
Date: Sat, 09 Dec 2006 18:24:38 +0100
From: Ramiro Voicu <Ramiro.Voicu@cern.ch>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 7645] New: Kernel BUG at mm/memory.c:1124
References: <200612070355.kB73tGf4021820@fire-2.osdl.org> <20061206201246.be7fb860.akpm@osdl.org> <4577A36B.6090803@cern.ch> <20061206230338.b0bf2b9e.akpm@osdl.org> <45782B32.6040401@cern.ch> <Pine.LNX.4.64.0612072101120.27573@blonde.wat.veritas.com> <20061208155200.0e2794a1.akpm@osdl.org> <Pine.LNX.4.64.0612090427180.3684@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0612090427180.3684@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>

It seems that this patch fixed the problem. I tested on my desktop and
the problem seems gone.

Based on what Hugh supposed, I was able to have a small java program to
test it ... and indeed it is very possible that there was a race in the
initial app

I will try to test it tomorrow on the other machine ( it is unable to
boot now after a hard reboot ), but I think the bug can be closed now.

Thank you very much for your support!

Cheers,
Ramiro

Hugh Dickins wrote:
> On Fri, 8 Dec 2006, Andrew Morton wrote:
>> On Thu, 7 Dec 2006 21:22:57 +0000 (GMT)
>> Hugh Dickins <hugh@veritas.com> wrote:
>>> Please try the simple patch below: I expect it to fix your problem.
>>> Whether it's the right patch, I'm not quite sure: we do commonly use
>>> zap_page_range and zeromap_page_range with mmap_sem held for write,
>>> but perhaps we'd want to avoid such serialization in this case?
>> Ramiro, have you had a chance to test this yet?
> 
> Here's a bigger but better patch: if you wouldn't mind,
> please try this one instead, Ramiro - thanks.
> 
> 
> Ramiro Voicu hits the BUG_ON(!pte_none(*pte)) in zeromap_pte_range:
> kernel bugzilla 7645.  Right: read_zero_pagealigned uses down_read of
> mmap_sem, but another thread's racing read of /dev/zero, or a normal
> fault, can easily set that pte again, in between zap_page_range and
> zeromap_page_range getting there.  It's been wrong ever since 2.4.3.
> 
> The simple fix is to use down_write instead, but that would serialize
> reads of /dev/zero more than at present: perhaps some app would be
> badly affected.  So instead let zeromap_page_range return the error
> instead of BUG_ON, and read_zero_pagealigned break to the slower
> clear_user loop in that case - there's no need to optimize for it.
> 
> Use -EEXIST for when a pte is found: BUG_ON in mmap_zero (the other
> user of zeromap_page_range), though it really isn't interesting there.
> And since mmap_zero wants -EAGAIN for out-of-memory, the zeromaps
> better return that than -ENOMEM.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> 
>  drivers/char/mem.c |   12 ++++++++----
>  mm/memory.c        |   32 +++++++++++++++++++++-----------
>  2 files changed, 29 insertions(+), 15 deletions(-)
> 
> --- 2.6.19/drivers/char/mem.c	2006-11-29 21:57:37.000000000 +0000
> +++ linux/drivers/char/mem.c	2006-12-08 14:09:51.000000000 +0000
> @@ -646,7 +646,8 @@ static inline size_t read_zero_pagealign
>  			count = size;
>  
>  		zap_page_range(vma, addr, count, NULL);
> -        	zeromap_page_range(vma, addr, count, PAGE_COPY);
> +        	if (zeromap_page_range(vma, addr, count, PAGE_COPY))
> +			break;
>  
>  		size -= count;
>  		buf += count;
> @@ -713,11 +714,14 @@ out:
>  
>  static int mmap_zero(struct file * file, struct vm_area_struct * vma)
>  {
> +	int err;
> +
>  	if (vma->vm_flags & VM_SHARED)
>  		return shmem_zero_setup(vma);
> -	if (zeromap_page_range(vma, vma->vm_start, vma->vm_end - vma->vm_start, vma->vm_page_prot))
> -		return -EAGAIN;
> -	return 0;
> +	err = zeromap_page_range(vma, vma->vm_start,
> +			vma->vm_end - vma->vm_start, vma->vm_page_prot);
> +	BUG_ON(err == -EEXIST);
> +	return err;
>  }
>  #else /* CONFIG_MMU */
>  static ssize_t read_zero(struct file * file, char * buf, 
> --- 2.6.19/mm/memory.c	2006-11-29 21:57:37.000000000 +0000
> +++ linux/mm/memory.c	2006-12-08 14:09:51.000000000 +0000
> @@ -1110,23 +1110,29 @@ static int zeromap_pte_range(struct mm_s
>  {
>  	pte_t *pte;
>  	spinlock_t *ptl;
> +	int err = 0;
>  
>  	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
>  	if (!pte)
> -		return -ENOMEM;
> +		return -EAGAIN;
>  	arch_enter_lazy_mmu_mode();
>  	do {
>  		struct page *page = ZERO_PAGE(addr);
>  		pte_t zero_pte = pte_wrprotect(mk_pte(page, prot));
> +
> +		if (unlikely(!pte_none(*pte))) {
> +			err = -EEXIST;
> +			pte++;
> +			break;
> +		}
>  		page_cache_get(page);
>  		page_add_file_rmap(page);
>  		inc_mm_counter(mm, file_rss);
> -		BUG_ON(!pte_none(*pte));
>  		set_pte_at(mm, addr, pte, zero_pte);
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	arch_leave_lazy_mmu_mode();
>  	pte_unmap_unlock(pte - 1, ptl);
> -	return 0;
> +	return err;
>  }
>  
>  static inline int zeromap_pmd_range(struct mm_struct *mm, pud_t *pud,
> @@ -1134,16 +1140,18 @@ static inline int zeromap_pmd_range(stru
>  {
>  	pmd_t *pmd;
>  	unsigned long next;
> +	int err;
>  
>  	pmd = pmd_alloc(mm, pud, addr);
>  	if (!pmd)
> -		return -ENOMEM;
> +		return -EAGAIN;
>  	do {
>  		next = pmd_addr_end(addr, end);
> -		if (zeromap_pte_range(mm, pmd, addr, next, prot))
> -			return -ENOMEM;
> +		err = zeromap_pte_range(mm, pmd, addr, next, prot);
> +		if (err)
> +			break;
>  	} while (pmd++, addr = next, addr != end);
> -	return 0;
> +	return err;
>  }
>  
>  static inline int zeromap_pud_range(struct mm_struct *mm, pgd_t *pgd,
> @@ -1151,16 +1159,18 @@ static inline int zeromap_pud_range(stru
>  {
>  	pud_t *pud;
>  	unsigned long next;
> +	int err;
>  
>  	pud = pud_alloc(mm, pgd, addr);
>  	if (!pud)
> -		return -ENOMEM;
> +		return -EAGAIN;
>  	do {
>  		next = pud_addr_end(addr, end);
> -		if (zeromap_pmd_range(mm, pud, addr, next, prot))
> -			return -ENOMEM;
> +		err = zeromap_pmd_range(mm, pud, addr, next, prot);
> +		if (err)
> +			break;
>  	} while (pud++, addr = next, addr != end);
> -	return 0;
> +	return err;
>  }
>  
>  int zeromap_page_range(struct vm_area_struct *vma,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
