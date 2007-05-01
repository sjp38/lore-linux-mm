Date: Tue, 1 May 2007 14:07:11 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page migration: Only migrate pages if allocation in the highest
 zone is possible
In-Reply-To: <Pine.LNX.4.64.0704301210580.7691@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705011405440.12797@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0704292316040.3036@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704301228580.26531@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0704301210580.7691@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007, Christoph Lameter wrote:
> 
> page migration: Only migrate pages if allocation in the highest zone is possible
> 
> Address spaces contain an allocation flag that specifies restriction on
> the zone for pages placed in the mapping. I.e. some device may require pages
> to be allocated from a DMA zone. Block devices may not be able to use pages
> from HIGHMEM.
> 
> Memory policies and the common use of page migration works only on the
> highest zone. If the address space does not allow allocation from the
> highest zone then the pages in the address space are not migratable simply
> because we can only allocate memory for a specified node if we allow
> allocation for the highest zone on each node.
> 
> Cc: Hugh Dickins <hugh@veritas.com>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Thanks, Christoph:
Acked-by: Hugh Dickins <hugh@veritas.com>

> 
> ---
>  include/linux/migrate.h |   11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> Index: linux-2.6.21-rc7-mm2/include/linux/migrate.h
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/include/linux/migrate.h	2007-04-29 23:58:47.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/include/linux/migrate.h	2007-04-30 12:18:41.000000000 -0700
> @@ -2,6 +2,8 @@
>  #define _LINUX_MIGRATE_H
>  
>  #include <linux/mm.h>
> +#include <linux/mempolicy.h>
> +#include <linux/pagemap.h>
>  
>  typedef struct page *new_page_t(struct page *, unsigned long private, int **);
>  
> @@ -10,6 +12,15 @@ static inline int vma_migratable(struct 
>  {
>  	if (vma->vm_flags & (VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
>  		return 0;
> +	/*
> +	 * Migration allocates pages in the highest zone. If we cannot
> +	 * do so then migration (at least from node to node) is not
> +	 * possible.
> +	 */
> +	if (vma->vm_file &&
> +		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
> +								< policy_zone)
> +			return 0;
>  	return 1;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
