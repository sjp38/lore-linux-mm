Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA926B006C
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 11:08:28 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so31284047pdb.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 08:08:28 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id pm7si4107163pdb.71.2015.03.25.08.08.26
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 08:08:27 -0700 (PDT)
Message-ID: <5512CF68.5040509@intel.com>
Date: Wed, 25 Mar 2015 08:08:24 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: New pfn_mkwrite same as page_mkwrite for VM_PFNMAP
References: <5512B961.8070409@plexistor.com> <5512BA5D.8070609@plexistor.com>
In-Reply-To: <5512BA5D.8070609@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On 03/25/2015 06:38 AM, Boaz Harrosh wrote:
>  /*
>   * This routine handles present pages, when users try to write
>   * to a shared page. It is done by copying the page to a new address
> @@ -2025,8 +2042,17 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
>  	}

This adds a lock release/reacquire in a place where the lock was
previously just held.  Could you explain a bit why this is safe?

Also, that pte_same() check looks a bit fragile.  It seems like it would
fail if the hardware, for instance, set the accessed bit in here
somewhere.  Is that what we want?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
