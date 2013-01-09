Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id F24FF6B005D
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 21:15:54 -0500 (EST)
Message-ID: <1357697739.4838.30.camel@pasglop>
Subject: Re: [PATCH 7/8] mm: use vm_unmapped_area() on powerpc architecture
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 09 Jan 2013 13:15:39 +1100
In-Reply-To: <1357694895-520-8-git-send-email-walken@google.com>
References: <1357694895-520-1-git-send-email-walken@google.com>
	 <1357694895-520-8-git-send-email-walken@google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 2013-01-08 at 17:28 -0800, Michel Lespinasse wrote:
> Update the powerpc slice_get_unmapped_area function to make use of
> vm_unmapped_area() instead of implementing a brute force search.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>
> 
> ---
>  arch/powerpc/mm/slice.c |  128 +++++++++++++++++++++++++++++-----------------
>  1 files changed, 81 insertions(+), 47 deletions(-)

That doesn't look good ... the resulting code is longer than the
original, which makes me wonder how it is an improvement...

Now it could just be a matter of how the code is factored, I see
quite a bit of duplication of the whole slice mask test...

Cheers,
Ben.

> diff --git a/arch/powerpc/mm/slice.c b/arch/powerpc/mm/slice.c
> index 999a74f25ebe..048346b7eed5 100644
> --- a/arch/powerpc/mm/slice.c
> +++ b/arch/powerpc/mm/slice.c
> @@ -242,31 +242,51 @@ static unsigned long slice_find_area_bottomup(struct mm_struct *mm,
>  					      struct slice_mask available,
>  					      int psize)
>  {
> -	struct vm_area_struct *vma;
> -	unsigned long addr;
> -	struct slice_mask mask;
>  	int pshift = max_t(int, mmu_psize_defs[psize].shift, PAGE_SHIFT);
> +	unsigned long addr, found, slice;
> +	struct vm_unmapped_area_info info;
>  
> -	addr = TASK_UNMAPPED_BASE;
> +	info.flags = 0;
> +	info.length = len;
> +	info.align_mask = PAGE_MASK & ((1ul << pshift) - 1);
> +	info.align_offset = 0;
>  
> -	for (;;) {
> -		addr = _ALIGN_UP(addr, 1ul << pshift);
> -		if ((TASK_SIZE - len) < addr)
> -			break;
> -		vma = find_vma(mm, addr);
> -		BUG_ON(vma && (addr >= vma->vm_end));
> +	addr = TASK_UNMAPPED_BASE;
> +	while (addr < TASK_SIZE) {
> +		info.low_limit = addr;
> +		if (addr < SLICE_LOW_TOP) {
> +			slice = GET_LOW_SLICE_INDEX(addr);
> +			addr = (slice + 1) << SLICE_LOW_SHIFT;
> +			if (!(available.low_slices & (1u << slice)))
> +				continue;
> +		} else {
> +			slice = GET_HIGH_SLICE_INDEX(addr);
> +			addr = (slice + 1) << SLICE_HIGH_SHIFT;
> +			if (!(available.high_slices & (1u << slice)))
> +				continue;
> +		}
>  
> -		mask = slice_range_to_mask(addr, len);
> -		if (!slice_check_fit(mask, available)) {
> -			if (addr < SLICE_LOW_TOP)
> -				addr = _ALIGN_UP(addr + 1,  1ul << SLICE_LOW_SHIFT);
> -			else
> -				addr = _ALIGN_UP(addr + 1,  1ul << SLICE_HIGH_SHIFT);
> -			continue;
> + next_slice:
> +		if (addr >= TASK_SIZE)
> +			addr = TASK_SIZE;
> +		else if (addr < SLICE_LOW_TOP) {
> +			slice = GET_LOW_SLICE_INDEX(addr);
> +			if (available.low_slices & (1u << slice)) {
> +				addr = (slice + 1) << SLICE_LOW_SHIFT;
> +				goto next_slice;
> +			}
> +		} else {
> +			slice = GET_HIGH_SLICE_INDEX(addr);
> +			if (available.high_slices & (1u << slice)) {
> +				addr = (slice + 1) << SLICE_HIGH_SHIFT;
> +				goto next_slice;
> +			}
>  		}
> -		if (!vma || addr + len <= vma->vm_start)
> -			return addr;
> -		addr = vma->vm_end;
> +		info.high_limit = addr;
> +
> +		found = vm_unmapped_area(&info);
> +		if (!(found & ~PAGE_MASK))
> +			return found;
>  	}
>  
>  	return -ENOMEM;
> @@ -277,39 +297,53 @@ static unsigned long slice_find_area_topdown(struct mm_struct *mm,
>  					     struct slice_mask available,
>  					     int psize)
>  {
> -	struct vm_area_struct *vma;
> -	unsigned long addr;
> -	struct slice_mask mask;
>  	int pshift = max_t(int, mmu_psize_defs[psize].shift, PAGE_SHIFT);
> +	unsigned long addr, found, slice;
> +	struct vm_unmapped_area_info info;
>  
> -	addr = mm->mmap_base;
> -	while (addr > len) {
> -		/* Go down by chunk size */
> -		addr = _ALIGN_DOWN(addr - len, 1ul << pshift);
> +	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
> +	info.length = len;
> +	info.align_mask = PAGE_MASK & ((1ul << pshift) - 1);
> +	info.align_offset = 0;
>  
> -		/* Check for hit with different page size */
> -		mask = slice_range_to_mask(addr, len);
> -		if (!slice_check_fit(mask, available)) {
> -			if (addr < SLICE_LOW_TOP)
> -				addr = _ALIGN_DOWN(addr, 1ul << SLICE_LOW_SHIFT);
> -			else if (addr < (1ul << SLICE_HIGH_SHIFT))
> -				addr = SLICE_LOW_TOP;
> -			else
> -				addr = _ALIGN_DOWN(addr, 1ul << SLICE_HIGH_SHIFT);
> -			continue;
> +	addr = mm->mmap_base;
> +	while (addr > PAGE_SIZE) {
> +		info.high_limit = addr;
> +                if (addr < SLICE_LOW_TOP) {
> +			slice = GET_LOW_SLICE_INDEX(addr - 1);
> +			addr = slice << SLICE_LOW_SHIFT;
> +			if (!(available.low_slices & (1u << slice)))
> +				continue;
> +		} else {
> +			slice = GET_HIGH_SLICE_INDEX(addr - 1);
> +			addr = slice ? (slice << SLICE_HIGH_SHIFT) :
> +								SLICE_LOW_TOP;
> +			if (!(available.high_slices & (1u << slice)))
> +				continue;
>  		}
>  
> -		/*
> -		 * Lookup failure means no vma is above this address,
> -		 * else if new region fits below vma->vm_start,
> -		 * return with success:
> -		 */
> -		vma = find_vma(mm, addr);
> -		if (!vma || (addr + len) <= vma->vm_start)
> -			return addr;
> + next_slice:
> +		if (addr < PAGE_SIZE)
> +			addr = PAGE_SIZE;
> +		else if (addr < SLICE_LOW_TOP) {
> +			slice = GET_LOW_SLICE_INDEX(addr - 1);
> +			if (available.low_slices & (1u << slice)) {
> +				addr = slice << SLICE_LOW_SHIFT;
> +				goto next_slice;
> +			}
> +		} else {
> +			slice = GET_HIGH_SLICE_INDEX(addr - 1);
> +			if (available.high_slices & (1u << slice)) {
> +				addr = slice ? (slice << SLICE_HIGH_SHIFT) :
> +								SLICE_LOW_TOP;
> +				goto next_slice;
> +			}
> +		}
> +		info.low_limit = addr;
>  
> -		/* try just below the current vma->vm_start */
> -		addr = vma->vm_start;
> +		found = vm_unmapped_area(&info);
> +		if (!(found & ~PAGE_MASK))
> +			return found;
>  	}
>  
>  	/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
