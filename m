Message-ID: <4896A197.3090004@sgi.com>
Date: Mon, 04 Aug 2008 16:28:39 +1000
From: Lachlan McIlroy <lachlan@sgi.com>
Reply-To: lachlan@sgi.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 3/3] xfs: use new vmap API
References: <20080728123438.GA13926@wotan.suse.de> <20080728123703.GC13926@wotan.suse.de>
In-Reply-To: <20080728123703.GC13926@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, xfs@oss.sgi.com, xen-devel@lists.xensource.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dri-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Looks good to me.

Nick Piggin wrote:
> Implement XFS's large buffer support with the new vmap APIs. See the vmap
> rewrite patch for some numbers.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> 
> Index: linux-2.6/fs/xfs/linux-2.6/xfs_buf.c
> ===================================================================
> --- linux-2.6.orig/fs/xfs/linux-2.6/xfs_buf.c
> +++ linux-2.6/fs/xfs/linux-2.6/xfs_buf.c
> @@ -265,7 +265,7 @@ xfs_buf_free(
>  		uint		i;
>  
>  		if ((bp->b_flags & XBF_MAPPED) && (bp->b_page_count > 1))
> -			vunmap(bp->b_addr - bp->b_offset);
> +			vm_unmap_ram(bp->b_addr - bp->b_offset, bp->b_page_count);
>  
>  		for (i = 0; i < bp->b_page_count; i++) {
>  			struct page	*page = bp->b_pages[i];
> @@ -387,8 +387,8 @@ _xfs_buf_map_pages(
>  		bp->b_addr = page_address(bp->b_pages[0]) + bp->b_offset;
>  		bp->b_flags |= XBF_MAPPED;
>  	} else if (flags & XBF_MAPPED) {
> -		bp->b_addr = vmap(bp->b_pages, bp->b_page_count,
> -					VM_MAP, PAGE_KERNEL);
> +		bp->b_addr = vm_map_ram(bp->b_pages, bp->b_page_count,
> +					-1, PAGE_KERNEL);
>  		if (unlikely(bp->b_addr == NULL))
>  			return -ENOMEM;
>  		bp->b_addr += bp->b_offset;
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
