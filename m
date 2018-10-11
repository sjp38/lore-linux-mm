Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58C136B000A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 20:30:24 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 8-v6so6399716pfr.0
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 17:30:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q10-v6si1207746pls.344.2018.10.10.17.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 17:30:23 -0700 (PDT)
Date: Wed, 10 Oct 2018 17:30:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix warning in insert_pfn()
Message-Id: <20181010173015.ecb7c7ed1b2df729f058e346@linux-foundation.org>
In-Reply-To: <20180824154542.26872-1-jack@suse.cz>
References: <20180824154542.26872-1-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Dave Jiang <dave.jiang@intel.com>

On Fri, 24 Aug 2018 17:45:42 +0200 Jan Kara <jack@suse.cz> wrote:

> In DAX mode a write pagefault can race with write(2) in the following
> way:
> 
> CPU0                            CPU1
>                                 write fault for mapped zero page (hole)
> dax_iomap_rw()
>   iomap_apply()
>     xfs_file_iomap_begin()
>       - allocates blocks
>     dax_iomap_actor()
>       invalidate_inode_pages2_range()
>         - invalidates radix tree entries in given range
>                                 dax_iomap_pte_fault()
>                                   grab_mapping_entry()
>                                     - no entry found, creates empty
>                                   ...
>                                   xfs_file_iomap_begin()
>                                     - finds already allocated block
>                                   ...
>                                   vmf_insert_mixed_mkwrite()
>                                     - WARNs and does nothing because there
>                                       is still zero page mapped in PTE
>         unmap_mapping_pages()
> 
> This race results in WARN_ON from insert_pfn() and is occasionally
> triggered by fstest generic/344. Note that the race is otherwise
> harmless as before write(2) on CPU0 is finished, we will invalidate page
> tables properly and thus user of mmap will see modified data from
> write(2) from that point on. So just restrict the warning only to the
> case when the PFN in PTE is not zero page.
> 
> ...
>
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1787,10 +1787,15 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  			 * in may not match the PFN we have mapped if the
>  			 * mapped PFN is a writeable COW page.  In the mkwrite
>  			 * case we are creating a writable PTE for a shared
> -			 * mapping and we expect the PFNs to match.
> +			 * mapping and we expect the PFNs to match. If they
> +			 * don't match, we are likely racing with block
> +			 * allocation and mapping invalidation so just skip the
> +			 * update.
>  			 */
> -			if (WARN_ON_ONCE(pte_pfn(*pte) != pfn_t_to_pfn(pfn)))
> +			if (pte_pfn(*pte) != pfn_t_to_pfn(pfn)) {
> +				WARN_ON_ONCE(!is_zero_pfn(pte_pfn(*pte)));
>  				goto out_unlock;
> +			}
>  			entry = *pte;

Shouldn't we just remove the warning?  We know it happens and we know
why it happens and we know it's harmless.  What's the point in scaring
people?
