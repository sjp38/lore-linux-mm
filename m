Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id BE4BB6B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 18:49:05 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so201292548pdb.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:49:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id in5si2670542pbd.231.2015.03.23.15.49.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 15:49:04 -0700 (PDT)
Date: Mon, 23 Mar 2015 15:49:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: New pfn_mkwrite same as page_mkwrite for
 VM_PFNMAP
Message-Id: <20150323154903.5f5263095a4f7eff59bc9bb8@linux-foundation.org>
In-Reply-To: <55100BDC.7000901@plexistor.com>
References: <55100B78.501@plexistor.com>
	<55100BDC.7000901@plexistor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On Mon, 23 Mar 2015 14:49:32 +0200 Boaz Harrosh <boaz@plexistor.com> wrote:

> From: Yigal Korman <yigal@plexistor.com>
> 
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

Looks OK to me.

> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1982,6 +1982,22 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
>  	return ret;
>  }
>  
> +static int do_pfn_mkwrite(struct vm_area_struct *vma, unsigned long address)
> +{
> +	struct vm_fault vmf;
> +
> +	if (!vma->vm_ops || !vma->vm_ops->pfn_mkwrite)
> +		return 0;
> +
> +	vmf.page = 0;
> +	vmf.pgoff = (((address & PAGE_MASK) - vma->vm_start) >> PAGE_SHIFT) +
> +			vma->vm_pgoff;
> +	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
> +	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
> +
> +	return vma->vm_ops->pfn_mkwrite(vma, &vmf);
> +}

It might be a little neater to use

	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
		struct vm_fault vmf = {
			...
		};
		...
	}

>  /*
>   * This routine handles present pages, when users try to write
>   * to a shared page. It is done by copying the page to a new address
> @@ -2025,8 +2041,17 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		 * accounting on raw pfn maps.
>  		 */
>  		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
> -				     (VM_WRITE|VM_SHARED))
> +				     (VM_WRITE|VM_SHARED)) {
> +			pte_unmap_unlock(page_table, ptl);
> +			ret = do_pfn_mkwrite(vma, address);
> +			if (ret & VM_FAULT_ERROR)
> +				return ret;
> +			page_table = pte_offset_map_lock(mm, pmd, address,
> +							 &ptl);
> +			if (!pte_same(*page_table, orig_pte))
> +				goto unlock;
>  			goto reuse;
> +		}
>  		goto gotten;

There are significant pending changes in this area.  See linux-next,
or http://ozlabs.org/~akpm/mmots/broken-out/mm-refactor-*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
