Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 633C76B0038
	for <linux-mm@kvack.org>; Thu, 11 May 2017 04:39:12 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j27so4429579wre.3
        for <linux-mm@kvack.org>; Thu, 11 May 2017 01:39:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v132si7098258wmd.134.2017.05.11.01.39.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 May 2017 01:39:10 -0700 (PDT)
Date: Thu, 11 May 2017 10:39:08 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/4] dax: Fix PMD data corruption when fault races with
 write
Message-ID: <20170511083908.GA5956@quack2.suse.cz>
References: <20170510085419.27601-5-jack@suse.cz>
 <20170510172700.18991-1-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510172700.18991-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed 10-05-17 11:27:00, Ross Zwisler wrote:
> This is based on a patch from Jan Kara that fixed the equivalent race in
> the DAX PTE fault path.
> 
> Currently DAX PMD read fault can race with write(2) in the following way:
> 
> CPU1 - write(2)                 CPU2 - read fault
>                                 dax_iomap_pmd_fault()
>                                   ->iomap_begin() - sees hole
> 
> dax_iomap_rw()
>   iomap_apply()
>     ->iomap_begin - allocates blocks
>     dax_iomap_actor()
>       invalidate_inode_pages2_range()
>         - there's nothing to invalidate
> 
>                                   grab_mapping_entry()
> 				  - we add huge zero page to the radix tree
> 				    and map it to page tables
> 
> The result is that hole page is mapped into page tables (and thus zeros
> are seen in mmap) while file has data written in that place.
> 
> Fix the problem by locking exception entry before mapping blocks for the
> fault. That way we are sure invalidate_inode_pages2_range() call for
> racing write will either block on entry lock waiting for the fault to
> finish (and unmap stale page tables after that) or read fault will see
> already allocated blocks by write(2).
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Fixes: 9f141d6ef6258a3a37a045842d9ba7e68f368956
> CC: stable@vger.kernel.org
> ---
> 
> Jan, I just realized that we need an equivalent fix in the PMD path.  Let's
> keep this with the rest of your series so they get applied together,
> applied to stable together, etc.
> 
> This applies cleanly to the current linux/master (56868a460b83) + the four
> patches from Jan's series.  I've run it through xfstests and some targeted
> testing for the PMD path.

Ah, right. Thanks for fixing it up. The patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/dax.c | 28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 32f020c..93ae872 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1388,6 +1388,16 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
>  		goto fallback;
>  
>  	/*
> +	 * grab_mapping_entry() will make sure we get a 2M empty entry, a DAX
> +	 * PMD or a HZP entry.  If it can't (because a 4k page is already in
> +	 * the tree, for instance), it will return -EEXIST and we just fall
> +	 * back to 4k entries.
> +	 */
> +	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
> +	if (IS_ERR(entry))
> +		goto fallback;
> +
> +	/*
>  	 * Note that we don't use iomap_apply here.  We aren't doing I/O, only
>  	 * setting up a mapping, so really we're using iomap_begin() as a way
>  	 * to look up our filesystem block.
> @@ -1395,21 +1405,11 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
>  	pos = (loff_t)pgoff << PAGE_SHIFT;
>  	error = ops->iomap_begin(inode, pos, PMD_SIZE, iomap_flags, &iomap);
>  	if (error)
> -		goto fallback;
> +		goto unlock_entry;
>  
>  	if (iomap.offset + iomap.length < pos + PMD_SIZE)
>  		goto finish_iomap;
>  
> -	/*
> -	 * grab_mapping_entry() will make sure we get a 2M empty entry, a DAX
> -	 * PMD or a HZP entry.  If it can't (because a 4k page is already in
> -	 * the tree, for instance), it will return -EEXIST and we just fall
> -	 * back to 4k entries.
> -	 */
> -	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
> -	if (IS_ERR(entry))
> -		goto finish_iomap;
> -
>  	switch (iomap.type) {
>  	case IOMAP_MAPPED:
>  		result = dax_pmd_insert_mapping(vmf, &iomap, pos, &entry);
> @@ -1417,7 +1417,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
>  	case IOMAP_UNWRITTEN:
>  	case IOMAP_HOLE:
>  		if (WARN_ON_ONCE(write))
> -			goto unlock_entry;
> +			break;
>  		result = dax_pmd_load_hole(vmf, &iomap, &entry);
>  		break;
>  	default:
> @@ -1425,8 +1425,6 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
>  		break;
>  	}
>  
> - unlock_entry:
> -	put_locked_mapping_entry(mapping, pgoff, entry);
>   finish_iomap:
>  	if (ops->iomap_end) {
>  		int copied = PMD_SIZE;
> @@ -1442,6 +1440,8 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
>  		ops->iomap_end(inode, pos, PMD_SIZE, copied, iomap_flags,
>  				&iomap);
>  	}
> + unlock_entry:
> +	put_locked_mapping_entry(mapping, pgoff, entry);
>   fallback:
>  	if (result == VM_FAULT_FALLBACK) {
>  		split_huge_pmd(vma, vmf->pmd, vmf->address);
> -- 
> 2.9.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
