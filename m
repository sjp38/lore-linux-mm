Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 742606B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 05:59:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y106so15307107wrb.14
        for <linux-mm@kvack.org>; Tue, 23 May 2017 02:59:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o18si326491wmg.87.2017.05.23.02.59.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 May 2017 02:59:56 -0700 (PDT)
Date: Tue, 23 May 2017 11:59:52 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/2] dax: Fix race between colliding PMD & PTE entries
Message-ID: <20170523095952.GD1119@quack2.suse.cz>
References: <20170522215749.23516-1-ross.zwisler@linux.intel.com>
 <20170522215749.23516-2-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170522215749.23516-2-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pawel Lebioda <pawel.lebioda@intel.com>, Dave Jiang <dave.jiang@intel.com>, Xiong Zhou <xzhou@redhat.com>, Eryu Guan <eguan@redhat.com>, stable@vger.kernel.org

On Mon 22-05-17 15:57:49, Ross Zwisler wrote:
> We currently have two related PMD vs PTE races in the DAX code.  These can
> both be easily triggered by having two threads reading and writing
> simultaneously to the same private mapping, with the key being that private
> mapping reads can be handled with PMDs but private mapping writes are
> always handled with PTEs so that we can COW.
> 
> Here is the first race:
> 
> CPU 0					CPU 1
> 
> (private mapping write)
> __handle_mm_fault()
>   create_huge_pmd() - FALLBACK
>   handle_pte_fault()
>     passes check for pmd_devmap()
> 
> 					(private mapping read)
> 					__handle_mm_fault()
> 					  create_huge_pmd()
> 					    dax_iomap_pmd_fault() inserts PMD
> 
>     dax_iomap_pte_fault() does a PTE fault, but we already have a DAX PMD
>     			  installed in our page tables at this spot.
> 
> Here's the second race:
> 
> CPU 0					CPU 1
> 
> (private mapping read)
> __handle_mm_fault()
>   passes check for pmd_none()
>   create_huge_pmd()
>     dax_iomap_pmd_fault() inserts PMD
> 
> (private mapping write)
> __handle_mm_fault()
>   create_huge_pmd() - FALLBACK
> 					(private mapping read)
> 					__handle_mm_fault()
> 					  passes check for pmd_none()
> 					  create_huge_pmd()
> 
>   handle_pte_fault()
>     dax_iomap_pte_fault() inserts PTE
> 					    dax_iomap_pmd_fault() inserts PMD,
> 					       but we already have a PTE at
> 					       this spot.
> 
> The core of the issue is that while there is isolation between faults to
> the same range in the DAX fault handlers via our DAX entry locking, there
> is no isolation between faults in the code in mm/memory.c.  This means for
> instance that this code in __handle_mm_fault() can run:
> 
> 	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
> 		ret = create_huge_pmd(&vmf);
> 
> But by the time we actually get to run the fault handler called by
> create_huge_pmd(), the PMD is no longer pmd_none() because a racing PTE
> fault has installed a normal PMD here as a parent.  This is the cause of
> the 2nd race.  The first race is similar - there is the following check in
> handle_pte_fault():
> 
> 	} else {
> 		/* See comment in pte_alloc_one_map() */
> 		if (pmd_devmap(*vmf->pmd) || pmd_trans_unstable(vmf->pmd))
> 			return 0;
> 
> So if a pmd_devmap() PMD (a DAX PMD) has been installed at vmf->pmd, we
> will bail and retry the fault.  This is correct, but there is nothing
> preventing the PMD from being installed after this check but before we
> actually get to the DAX PTE fault handlers.
> 
> In my testing these races result in the following types of errors:
> 
>  BUG: Bad rss-counter state mm:ffff8800a817d280 idx:1 val:1
>  BUG: non-zero nr_ptes on freeing mm: 15
> 
> Fix this issue by having the DAX fault handlers verify that it is safe to
> continue their fault after they have taken an entry lock to block other
> racing faults.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reported-by: Pawel Lebioda <pawel.lebioda@intel.com>
> Cc: stable@vger.kernel.org

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza


> ---
> 
> Changes from v1:
>  - Handle the failure case in dax_iomap_pte_fault() by retrying the fault
>    (Jan).
> 
> This series has survived my new xfstest (generic/437) and full xfstest
> regression testing runs.
> ---
>  fs/dax.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index c22eaf1..fc62f36 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1155,6 +1155,17 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
>  	}
>  
>  	/*
> +	 * It is possible, particularly with mixed reads & writes to private
> +	 * mappings, that we have raced with a PMD fault that overlaps with
> +	 * the PTE we need to set up.  If so just return and the fault will be
> +	 * retried.
> +	 */
> +	if (pmd_devmap(*vmf->pmd)) {
> +		vmf_ret = VM_FAULT_NOPAGE;
> +		goto unlock_entry;
> +	}
> +
> +	/*
>  	 * Note that we don't bother to use iomap_apply here: DAX required
>  	 * the file system block size to be equal the page size, which means
>  	 * that we never have to deal with more than a single extent here.
> @@ -1398,6 +1409,15 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
>  		goto fallback;
>  
>  	/*
> +	 * It is possible, particularly with mixed reads & writes to private
> +	 * mappings, that we have raced with a PTE fault that overlaps with
> +	 * the PMD we need to set up.  If so we just fall back to a PTE fault
> +	 * ourselves.
> +	 */
> +	if (!pmd_none(*vmf->pmd))
> +		goto unlock_entry;
> +
> +	/*
>  	 * Note that we don't use iomap_apply here.  We aren't doing I/O, only
>  	 * setting up a mapping, so really we're using iomap_begin() as a way
>  	 * to look up our filesystem block.
> -- 
> 2.9.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
