Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 063336B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 08:17:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w79so13143193wme.7
        for <linux-mm@kvack.org>; Mon, 29 May 2017 05:17:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v27si9747751edi.164.2017.05.29.05.17.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 May 2017 05:17:50 -0700 (PDT)
Date: Mon, 29 May 2017 14:17:47 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] dax: improve fix for colliding PMD & PTE entries
Message-ID: <20170529121747.GH3608@quack2.suse.cz>
References: <20170522215749.23516-2-ross.zwisler@linux.intel.com>
 <20170526195932.32178-1-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170526195932.32178-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pawel Lebioda <pawel.lebioda@intel.com>, Dave Jiang <dave.jiang@intel.com>, Xiong Zhou <xzhou@redhat.com>, Eryu Guan <eguan@redhat.com>, stable@vger.kernel.org

On Fri 26-05-17 13:59:32, Ross Zwisler wrote:
> This commit, which has not yet made it upstream but is in the -mm tree:
> 
>     dax: Fix race between colliding PMD & PTE entries
> 
> fixed a pair of race conditions where racing DAX PTE and PMD faults could
> corrupt page tables.  This fix had two shortcomings which are addressed by
> this patch:
> 
> 1) In the PTE fault handler we only checked for a collision using
> pmd_devmap().  The pmd_devmap() check will trigger when we have raced with
> a PMD that has real DAX storage, but to account for the case where we
> collide with a huge zero page entry we also need to check for
> pmd_trans_huge().
> 
> 2) In the PMD fault handler we only continued with the fault if no PMD at
> all was present (pmd_none()).  This is the case when we are faulting in a
> PMD for the first time, but there are two other cases to consider.  The
> first is that we are servicing a write fault over a PMD huge zero page,
> which we detect with pmd_trans_huge().  The second is that we are servicing
> a write fault over a DAX PMD with real storage, which we address with
> pmd_devmap().
> 
> Fix both of these, and instead of manually triggering a fallback in the PMD
> collision case instead be consistent with the other collision detection
> code in the fault handlers and just retry.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: stable@vger.kernel.org

Ugh, right. I forgot zero page in page tables will not pass the devmap
check... You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
> 
> For both the -mm tree and for stable, feel free to squash this with the
> original commit if you think that is appropriate.
> 
> This has passed targeted testing and an xfstests run.
> ---
>  fs/dax.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index fc62f36..2a6889b 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1160,7 +1160,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
>  	 * the PTE we need to set up.  If so just return and the fault will be
>  	 * retried.
>  	 */
> -	if (pmd_devmap(*vmf->pmd)) {
> +	if (pmd_trans_huge(*vmf->pmd) || pmd_devmap(*vmf->pmd)) {
>  		vmf_ret = VM_FAULT_NOPAGE;
>  		goto unlock_entry;
>  	}
> @@ -1411,11 +1411,14 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
>  	/*
>  	 * It is possible, particularly with mixed reads & writes to private
>  	 * mappings, that we have raced with a PTE fault that overlaps with
> -	 * the PMD we need to set up.  If so we just fall back to a PTE fault
> -	 * ourselves.
> +	 * the PMD we need to set up.  If so just return and the fault will be
> +	 * retried.
>  	 */
> -	if (!pmd_none(*vmf->pmd))
> +	if (!pmd_none(*vmf->pmd) && !pmd_trans_huge(*vmf->pmd) &&
> +			!pmd_devmap(*vmf->pmd)) {
> +		result = 0;
>  		goto unlock_entry;
> +	}
>  
>  	/*
>  	 * Note that we don't use iomap_apply here.  We aren't doing I/O, only
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
