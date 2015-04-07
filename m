Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4EB6B006C
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 09:17:43 -0400 (EDT)
Received: by widdi4 with SMTP id di4so17054102wid.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 06:17:43 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id h3si12776349wix.93.2015.04.07.06.17.41
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 06:17:41 -0700 (PDT)
Date: Tue, 7 Apr 2015 16:17:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3 v6] mm(v4.1): New pfn_mkwrite same as page_mkwrite
 for VM_PFNMAP
Message-ID: <20150407131700.GA13946@node.dhcp.inet.fi>
References: <55239645.9000507@plexistor.com>
 <552397E6.5030506@plexistor.com>
 <5523D43C.1060708@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5523D43C.1060708@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>, Stable Tree <stable@vger.kernel.org>

On Tue, Apr 07, 2015 at 03:57:32PM +0300, Boaz Harrosh wrote:
> 
> [v4]
> Kirill's comments about splitting out a new wp_pfn_shared().
> Add Documentation/filesystems/Locking text about pfn_mkwrite.
> 
> [v3]
> Kirill's comments about use of linear_page_index()
> 
> [v2]
> Based on linux-next/akpm [3dc4623]. For v4.1 merge window
> Incorporated comments from Andrew And Kirill
> 
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
> CC: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> CC: Matthew Wilcox <matthew.r.wilcox@intel.com>
> CC: Jan Kara <jack@suse.cz>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Hugh Dickins <hughd@google.com>
> CC: Mel Gorman <mgorman@suse.de>
> CC: linux-mm@kvack.org
> 
> Signed-off-by: Yigal Korman <yigal@plexistor.com>
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> ---
>  Documentation/filesystems/Locking |  8 ++++++++
>  include/linux/mm.h                |  3 +++
>  mm/memory.c                       | 40 +++++++++++++++++++++++++++++++++++----
>  3 files changed, 47 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
> index f91926f..25f36e6 100644
> --- a/Documentation/filesystems/Locking
> +++ b/Documentation/filesystems/Locking
> @@ -525,6 +525,7 @@ prototypes:
>  	void (*close)(struct vm_area_struct*);
>  	int (*fault)(struct vm_area_struct*, struct vm_fault *);
>  	int (*page_mkwrite)(struct vm_area_struct *, struct vm_fault *);
> +	int (*pfn_mkwrite)(struct vm_area_struct *, struct vm_fault *);
>  	int (*access)(struct vm_area_struct *, unsigned long, void*, int, int);
>  
>  locking rules:
> @@ -534,6 +535,7 @@ close:		yes
>  fault:		yes		can return with page locked
>  map_pages:	yes
>  page_mkwrite:	yes		can return with page locked
> +pfn_mkwrite:	yes
>  access:		yes
>  
>  	->fault() is called when a previously not present pte is about
> @@ -560,6 +562,12 @@ the page has been truncated, the filesystem should not look up a new page
>  like the ->fault() handler, but simply return with VM_FAULT_NOPAGE, which
>  will cause the VM to retry the fault.
>  
> +	->pfn_mkwrite() is the same as page_mkwrite but when the pte is
> +VM_PFNMAP or VM_MIXEDMAP with a page-less entry. Expected return is
> +VM_FAULT_NOPAGE. Or one of the VM_FAULT_ERROR types. The default behavior
> +after this call is to make the pte read-write, unless pfn_mkwrite()
> +already touched the pte, in that case it is untouched.
> +
>  	->access() is called when get_user_pages() fails in
>  access_process_vm(), typically used to debug a process through
>  /proc/pid/mem or ptrace.  This function is needed only for
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
> index 59f6268..67b1ee8 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2181,6 +2181,39 @@ oom:
>  	return VM_FAULT_OOM;
>  }
>  
> +/*
> + * Handle write page faults for VM_MIXEDMAP or VM_PFNMAP for a VM_SHARED
> + * mapping
> + */
> +static int wp_pfn_shared(struct mm_struct *mm,
> +			struct vm_area_struct *vma, unsigned long address,
> +			pte_t *page_table, spinlock_t *ptl, pte_t orig_pte,
> +			pmd_t *pmd)
> +{
> +	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
> +		struct vm_fault vmf = {
> +			.page = NULL,
> +			.pgoff = linear_page_index(vma, address),
> +			.virtual_address = (void __user *)(address & PAGE_MASK),
> +			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
> +		};
> +		int ret;
> +
> +		pte_unmap_unlock(page_table, ptl);
> +		ret = vma->vm_ops->pfn_mkwrite(vma, &vmf);
> +		if (ret & VM_FAULT_ERROR)
> +			return ret;
> +		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> +		/* Did pfn_mkwrite already fixed up the pte */
> +		if (!pte_same(*page_table, orig_pte)) {
> +			pte_unmap_unlock(page_table, ptl);
> +			return ret;

This should be "return 0;", shouldn't it?

VM_FAULT_NOPAGE would imply you've installed new pte, but you did not.

> +		}
> +	}
> +	return wp_page_reuse(mm, vma, address, page_table, ptl, orig_pte,
> +			     NULL, 0, 0);
> +}
> +
>  static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
>  			  unsigned long address, pte_t *page_table,
>  			  pmd_t *pmd, spinlock_t *ptl, pte_t orig_pte,
> @@ -2259,13 +2292,12 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		 * VM_PFNMAP VMA.
>  		 *
>  		 * We should not cow pages in a shared writeable mapping.
> -		 * Just mark the pages writable as we can't do any dirty
> -		 * accounting on raw pfn maps.
> +		 * Just mark the pages writable and/or call ops->pfn_mkwrite.
>  		 */
>  		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
>  				     (VM_WRITE|VM_SHARED))
> -			return wp_page_reuse(mm, vma, address, page_table, ptl,
> -					     orig_pte, old_page, 0, 0);
> +			return wp_pfn_shared(mm, vma, address, page_table, ptl,
> +					     orig_pte, pmd);
>  
>  		pte_unmap_unlock(page_table, ptl);
>  		return wp_page_copy(mm, vma, address, page_table, pmd,
> -- 
> 1.9.3
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
