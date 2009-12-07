Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BD45860021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 18:36:46 -0500 (EST)
Date: Mon, 7 Dec 2009 15:35:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
Message-Id: <20091207153552.0fadf335.akpm@linux-foundation.org>
In-Reply-To: <4B1D3A3302000078000241CD@vpn.id2.novell.com>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Beulich <JBeulich@novell.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, tj@kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>
List-ID: <linux-mm.kvack.org>

(cc linux-ia64)

On Mon, 07 Dec 2009 16:24:03 +0000
"Jan Beulich" <JBeulich@novell.com> wrote:

> At least on ia64 vmalloc_end is a global variable that VMALLOC_END
> expands to. Hence having a local variable named vmalloc_end and
> initialized from VMALLOC_END won't work on such platforms. Rename
> these variables, and for consistency also rename vmalloc_start.
> 

erk.  So does 2.6.32's vmalloc() actually work correctly on ia64?

Perhaps vmalloc_end wasn't a well chosen name for an arch-specific
global variable.

arch/m68k/include/asm/pgtable_mm.h does the same thing.  Did it break too?

> ---
>  mm/vmalloc.c |   16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> --- linux-2.6.32/mm/vmalloc.c
> +++ 2.6.32-dont-use-vmalloc_end/mm/vmalloc.c
> @@ -2060,13 +2060,13 @@ static unsigned long pvm_determine_end(s
>  				       struct vmap_area **pprev,
>  				       unsigned long align)
>  {
> -	const unsigned long vmalloc_end = VMALLOC_END & ~(align - 1);
> +	const unsigned long end = VMALLOC_END & ~(align - 1);
>  	unsigned long addr;
>  
>  	if (*pnext)
> -		addr = min((*pnext)->va_start & ~(align - 1), vmalloc_end);
> +		addr = min((*pnext)->va_start & ~(align - 1), end);
>  	else
> -		addr = vmalloc_end;
> +		addr = end;
>  
>  	while (*pprev && (*pprev)->va_end > addr) {
>  		*pnext = *pprev;
> @@ -2105,8 +2105,8 @@ struct vm_struct **pcpu_get_vm_areas(con
>  				     const size_t *sizes, int nr_vms,
>  				     size_t align, gfp_t gfp_mask)
>  {
> -	const unsigned long vmalloc_start = ALIGN(VMALLOC_START, align);
> -	const unsigned long vmalloc_end = VMALLOC_END & ~(align - 1);
> +	const unsigned long vstart = ALIGN(VMALLOC_START, align);
> +	const unsigned long vend = VMALLOC_END & ~(align - 1);
>  	struct vmap_area **vas, *prev, *next;
>  	struct vm_struct **vms;
>  	int area, area2, last_area, term_area;
> @@ -2142,7 +2142,7 @@ struct vm_struct **pcpu_get_vm_areas(con
>  	}
>  	last_end = offsets[last_area] + sizes[last_area];
>  
> -	if (vmalloc_end - vmalloc_start < last_end) {
> +	if (vend - vstart < last_end) {
>  		WARN_ON(true);
>  		return NULL;
>  	}
> @@ -2167,7 +2167,7 @@ retry:
>  	end = start + sizes[area];
>  
>  	if (!pvm_find_next_prev(vmap_area_pcpu_hole, &next, &prev)) {
> -		base = vmalloc_end - last_end;
> +		base = vend - last_end;
>  		goto found;
>  	}
>  	base = pvm_determine_end(&next, &prev, align) - end;
> @@ -2180,7 +2180,7 @@ retry:
>  		 * base might have underflowed, add last_end before
>  		 * comparing.
>  		 */
> -		if (base + last_end < vmalloc_start + last_end) {
> +		if (base + last_end < vstart + last_end) {
>  			spin_unlock(&vmap_area_lock);
>  			if (!purged) {
>  				purge_vmap_area_lazy();
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
