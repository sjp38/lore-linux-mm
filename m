Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 17B7E6B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 07:43:04 -0500 (EST)
Date: Tue, 30 Nov 2010 23:42:49 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH RFC] vmalloc: eagerly clear ptes on vunmap
Message-ID: <20101130124249.GB15778@amd>
References: <4CEF6B8B.8080206@goop.org>
 <20101127103656.GA6884@amd>
 <4CF40DCB.5010007@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CF40DCB.5010007@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <npiggin@kernel.dk>, "Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Bryan Schumaker <bjschuma@netapp.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 12:32:11PM -0800, Jeremy Fitzhardinge wrote:
> When unmapping a region in the vmalloc space, clear the ptes immediately.
> There's no point in deferring this because there's no amortization
> benefit.
> 
> The TLBs are left dirty, and they are flushed lazily to amortize the
> cost of the IPIs.
> 
> This specific motivation for this patch is a regression since 2.6.36 when
> using NFS under Xen, triggered by the NFS client's use of vm_map_ram()
> introduced in 56e4ebf877b6043c289bda32a5a7385b80c17dee.  XFS also uses
> vm_map_ram() and could cause similar problems.

I do wonder whether there are cache benefits from batching page table
updates, especially the batched per cpu maps (and in your version they
get double-cleared as well).  I think this patch is good, but I think
perhaps making it configurable would be nice.

So... main question, does it allow Xen to use lazy flushing and avoid
vm_unmap_aliases() calls?


> 
> Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
> Cc: Nick Piggin <npiggin@kernel.dk>
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index a3d66b3..9960644 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -566,7 +566,6 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
>  			if (va->va_end > *end)
>  				*end = va->va_end;
>  			nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
> -			unmap_vmap_area(va);
>  			list_add_tail(&va->purge_list, &valist);
>  			va->flags |= VM_LAZY_FREEING;
>  			va->flags &= ~VM_LAZY_FREE;
> @@ -616,6 +615,8 @@ static void purge_vmap_area_lazy(void)
>   */
>  static void free_unmap_vmap_area_noflush(struct vmap_area *va)
>  {
> +	unmap_vmap_area(va);
> +
>  	va->flags |= VM_LAZY_FREE;
>  	atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
>  	if (unlikely(atomic_read(&vmap_lazy_nr) > lazy_max_pages()))
> @@ -944,8 +945,10 @@ static void vb_free(const void *addr, unsigned long size)
>  		BUG_ON(vb->free);
>  		spin_unlock(&vb->lock);
>  		free_vmap_block(vb);
> -	} else
> +	} else {
>  		spin_unlock(&vb->lock);
> +		vunmap_page_range((unsigned long)addr, (unsigned long)addr + size);
> +	}
>  }
>  
>  /**
> @@ -988,7 +991,6 @@ void vm_unmap_aliases(void)
>  
>  				s = vb->va->va_start + (i << PAGE_SHIFT);
>  				e = vb->va->va_start + (j << PAGE_SHIFT);
> -				vunmap_page_range(s, e);
>  				flush = 1;
>  
>  				if (s < start)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
