Message-ID: <4600B216.3010505@yahoo.com.au>
Date: Wed, 21 Mar 2007 15:18:30 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated
 helper macros.
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <20070319200513.17168.52238.stgit@localhost.localdomain>
In-Reply-To: <20070319200513.17168.52238.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:
> Signed-off-by: Adam Litke <agl@us.ibm.com>
> ---
> 
>  include/linux/mm.h |   25 +++++++++++++++++++++++++
>  1 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 60e0e4a..7089323 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -98,6 +98,7 @@ struct vm_area_struct {
>  
>  	/* Function pointers to deal with this struct. */
>  	struct vm_operations_struct * vm_ops;
> +	const struct pagetable_operations_struct * pagetable_ops;
>  
>  	/* Information about our backing store: */
>  	unsigned long vm_pgoff;		/* Offset (within vm_file) in PAGE_SIZE

Can you remind me why this isn't in vm_ops?

Also, it is going to be hugepage-only, isn't it? So should the naming be
changed to reflect that? And #ifdef it...

> @@ -218,6 +219,30 @@ struct vm_operations_struct {
>  };
>  
>  struct mmu_gather;
> +
> +struct pagetable_operations_struct {
> +	int (*fault)(struct mm_struct *mm,
> +		struct vm_area_struct *vma,
> +		unsigned long address, int write_access);

I got dibs on fault ;)

My callback is a sanitised one that basically abstracts the details of the
virtual memory mapping away, so it is usable by drivers and filesystems.

You actually want to bypass the normal fault handling because it doesn't
know how to deal with your virtual memory mapping. Hmm, the best suggestion
I can come up with is handle_mm_fault... unless you can think of a better
name for me to use.

> +	int (*copy_vma)(struct mm_struct *dst, struct mm_struct *src,
> +		struct vm_area_struct *vma);
> +	int (*pin_pages)(struct mm_struct *mm, struct vm_area_struct *vma,
> +		struct page **pages, struct vm_area_struct **vmas,
> +		unsigned long *position, int *length, int i);
> +	void (*change_protection)(struct vm_area_struct *vma,
> +		unsigned long address, unsigned long end, pgprot_t newprot);
> +	unsigned long (*unmap_page_range)(struct vm_area_struct *vma,
> +		unsigned long address, unsigned long end, long *zap_work);
> +	void (*free_pgtable_range)(struct mmu_gather **tlb,
> +		unsigned long addr, unsigned long end,
> +		unsigned long floor, unsigned long ceiling);
> +};
> +
> +#define has_pt_op(vma, op) \
> +	((vma)->pagetable_ops && (vma)->pagetable_ops->op)
> +#define pt_op(vma, call) \
> +	((vma)->pagetable_ops->call)
> +
>  struct inode;
>  
>  #define page_private(page)		((page)->private)
> 
> --

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
