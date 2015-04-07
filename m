Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7F54B6B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 05:06:16 -0400 (EDT)
Received: by widdi4 with SMTP id di4so9358022wid.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 02:06:16 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id vp5si11649346wjc.127.2015.04.07.02.06.14
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 02:06:14 -0700 (PDT)
Date: Tue, 7 Apr 2015 12:03:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3] mm(v4.1): New pfn_mkwrite same as page_mkwrite for
 VM_PFNMAP
Message-ID: <20150407090335.GA12664@node.dhcp.inet.fi>
References: <55239645.9000507@plexistor.com>
 <552397E6.5030506@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <552397E6.5030506@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>, Stable Tree <stable@vger.kernel.org>

On Tue, Apr 07, 2015 at 11:40:06AM +0300, Boaz Harrosh wrote:
> 
> [v2]
> Based on linux-next/akpm [3dc4623]. For v4.1 merge window
> Incorporated comments from Andrew And Kirill

Not really. You've ignored most of them. See below.

> [v1]
> This will allow FS that uses VM_PFNMAP | VM_MIXEDMAP (no page structs)
> to get notified when access is a write to a read-only PFN.
> 
> This can happen if we mmap() a file then first mmap-read from it
> to page-in a read-only PFN, than we mmap-write to the same page.
> 
> We need this functionality to fix a DAX bug, where in the scenario
> above we fail to set ctime/mtime though we modified the file.
> An xfstest is attached to this patchset that shows the failure
> and the fix. (A DAX patch will follow)
> 
> This functionality is extra important for us, because upon
> dirtying of a pmem page we also want to RDMA the page to a
> remote cluster node.
> 
> We define a new pfn_mkwrite and do not reuse page_mkwrite because
>   1 - The name ;-)
>   2 - But mainly because it would take a very long and tedious
>       audit of all page_mkwrite functions of VM_MIXEDMAP/VM_PFNMAP
>       users. To make sure they do not now CRASH. For example current
>       DAX code (which this is for) would crash.
>       If we would want to reuse page_mkwrite, We will need to first
>       patch all users, so to not-crash-on-no-page. Then enable this
>       patch. But even if I did that I would not sleep so well at night.
>       Adding a new vector is the safest thing to do, and is not that
>       expensive. an extra pointer at a static function vector per driver.
>       Also the new vector is better for performance, because else we
>       Will call all current Kernel vectors, so to:
> 	check-ha-no-page-do-nothing and return.
> 
> No need to call it from do_shared_fault because do_wp_page is called to
> change pte permissions anyway.
> 
> CC: Matthew Wilcox <matthew.r.wilcox@intel.com>
> CC: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> CC: Jan Kara <jack@suse.cz>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Hugh Dickins <hughd@google.com>
> CC: Mel Gorman <mgorman@suse.de>
> CC: linux-mm@kvack.org
> 
> Signed-off-by: Yigal Korman <yigal@plexistor.com>
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> ---
>  include/linux/mm.h |  3 +++
>  mm/memory.c        | 35 +++++++++++++++++++++++++++++++----

Please, document it in Documentation/filesystems/Locking.

>  2 files changed, 34 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index d584b95..70c47f2 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -251,6 +251,9 @@ struct vm_operations_struct {
>  	 * writable, if an error is returned it will cause a SIGBUS */
>  	int (*page_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
>  
> +	/* same as page_mkwrite when using VM_PFNMAP|VM_MIXEDMAP */
> +	int (*pfn_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
> +
>  	/* called by access_process_vm when get_user_pages() fails, typically
>  	 * for use by special VMAs that can switch between memory and hardware
>  	 */
> diff --git a/mm/memory.c b/mm/memory.c
> index 59f6268..6e8f3f6 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1982,6 +1982,19 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
>  	return ret;
>  }
>  
> +static int do_pfn_mkwrite(struct vm_area_struct *vma, unsigned long address)
> +{
> +	struct vm_fault vmf = {
> +		.page = 0,

.page = NULL,

> +		.pgoff = (((address & PAGE_MASK) - vma->vm_start)
> +					>> PAGE_SHIFT) + vma->vm_pgoff,

.pgoff = linear_page_index(vma, address),

> +		.virtual_address = (void __user *)(address & PAGE_MASK),
> +		.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
> +	};
> +
> +	return vma->vm_ops->pfn_mkwrite(vma, &vmf);
> +}
> +
>  /*
>   * Handle write page faults for pages that can be reused in the current vma
>   *
> @@ -2259,14 +2272,28 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		 * VM_PFNMAP VMA.
>  		 *
>  		 * We should not cow pages in a shared writeable mapping.
> -		 * Just mark the pages writable as we can't do any dirty
> -		 * accounting on raw pfn maps.
> +		 * Just mark the pages writable and/or call ops->pfn_mkwrite.
>  		 */
>  		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
> -				     (VM_WRITE|VM_SHARED))
> +				     (VM_WRITE|VM_SHARED)) {

Let's move this case in separate function -- wp_pfn_shared(). As we do for
wp_page_shared().

> +			if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
> +				int ret;
> +
> +				pte_unmap_unlock(page_table, ptl);
> +				ret = do_pfn_mkwrite(vma, address);
> +				if (ret & VM_FAULT_ERROR)
> +					return ret;
> +				page_table = pte_offset_map_lock(mm, pmd,
> +								 address, &ptl);
> +				/* Did pfn_mkwrite already fixed up the pte */
> +				if (!pte_same(*page_table, orig_pte)) {
> +					pte_unmap_unlock(page_table, ptl);
> +					return ret;
> +				}
> +			}
>  			return wp_page_reuse(mm, vma, address, page_table, ptl,
>  					     orig_pte, old_page, 0, 0);
> -
> +		}
>  		pte_unmap_unlock(page_table, ptl);
>  		return wp_page_copy(mm, vma, address, page_table, pmd,
>  				    orig_pte, old_page);
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
