Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 906D06B0038
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 12:07:12 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x24so607664pgv.5
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 09:07:12 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g8si325519pgu.667.2017.12.05.09.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 09:07:10 -0800 (PST)
Date: Tue, 5 Dec 2017 10:07:09 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] dax: fix potential overflow on 32bit machine
Message-ID: <20171205170709.GA21010@linux.intel.com>
References: <20171205033210.38338-1-yi.zhang@huawei.com>
 <20171205052407.GA20757@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205052407.GA20757@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "zhangyi (F)" <yi.zhang@huawei.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, viro@zeniv.linux.org.uk, miaoxie@huawei.com

On Mon, Dec 04, 2017 at 09:24:07PM -0800, Matthew Wilcox wrote:
> On Tue, Dec 05, 2017 at 11:32:10AM +0800, zhangyi (F) wrote:
> > On 32bit machine, when mmap2 a large enough file with pgoff more than
> > ULONG_MAX >> PAGE_SHIFT, it will trigger offset overflow and lead to
> > unmap the wrong page in dax_insert_mapping_entry(). This patch cast
> > pgoff to 64bit to prevent the overflow.
> 
> You're quite correct, and you've solved this problem the same way as the
> other half-dozen users in the kernel with the problem, so good job.
> 
> I think we can do better though.  How does this look?
> 
> From 9f8f30197eba970c82eea909624299c86b2c5f7e Mon Sep 17 00:00:00 2001
> From: Matthew Wilcox <mawilcox@microsoft.com>
> Date: Tue, 5 Dec 2017 00:15:54 -0500
> Subject: [PATCH] mm: Add unmap_mapping_pages
> 
> Several users of unmap_mapping_range() would much prefer to express
> their range in pages rather than bytes.  This leads to four places
> in the current tree where there are bugs on 32-bit kernels because of
> missing casts.
> 
> Conveniently, unmap_mapping_range() actually converts from bytes into
> pages, so hoist the guts of unmap_mapping_range() into a new function
> unmap_mapping_pages() and convert the callers.

Yep, this interface is much nicer than all the casting and shifting we
currently have for unmap_mapping_range().

> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Reported-by: "zhangyi (F)" <yi.zhang@huawei.com>
> ---
>  fs/dax.c           | 19 ++++++-------------
>  include/linux/mm.h |  2 ++
>  mm/khugepaged.c    |  3 +--
>  mm/memory.c        | 41 +++++++++++++++++++++++++++++------------
>  mm/truncate.c      | 23 +++++++----------------
>  5 files changed, 45 insertions(+), 43 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 95981591977a..6dd481f8216c 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -44,6 +44,7 @@
>  
>  /* The 'colour' (ie low bits) within a PMD of a page offset.  */
>  #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
> +#define PG_PMD_NR	(PMD_SIZE >> PAGE_SHIFT)

I wonder if it's confusing that PG_PMD_COLOUR is a mask, but PG_PMD_NR is a
count?  Would "PAGES_PER_PMD" be clearer, in the spirit of
PTRS_PER_{PGD,PMD,PTE}? 

Also, can we use the same define both in fs/dax.c and in mm/truncate.c,
instead of the latter using HPAGE_PMD_NR?

>  static wait_queue_head_t wait_table[DAX_WAIT_TABLE_ENTRIES];
>  
> @@ -375,8 +376,8 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
>  		 * unmapped.
>  		 */
>  		if (pmd_downgrade && dax_is_zero_entry(entry))
> -			unmap_mapping_range(mapping,
> -				(index << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
> +			unmap_mapping_pages(mapping, index & ~PG_PMD_COLOUR,
> +							PG_PMD_NR, 0);
>  
>  		err = radix_tree_preload(
>  				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
> @@ -538,12 +539,10 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
>  	if (dax_is_zero_entry(entry) && !(flags & RADIX_DAX_ZERO_PAGE)) {
>  		/* we are replacing a zero page with block mapping */
>  		if (dax_is_pmd_entry(entry))
> -			unmap_mapping_range(mapping,
> -					(vmf->pgoff << PAGE_SHIFT) & PMD_MASK,
> -					PMD_SIZE, 0);
> +			unmap_mapping_pages(mapping, vmf->pgoff & PG_PMD_COLOUR,

I think you need: 						 ~PG_PMD_COLOUR,

> +							PG_PMD_NR, 0);
>  		else /* pte entry */
> -			unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
> -					PAGE_SIZE, 0);
> +			unmap_mapping_pages(mapping, vmf->pgoff, 1, 0);
>  	}
>  
>  	spin_lock_irq(&mapping->tree_lock);
> @@ -1269,12 +1268,6 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
>  }
>  
>  #ifdef CONFIG_FS_DAX_PMD
> -/*
> - * The 'colour' (ie low bits) within a PMD of a page offset.  This comes up
> - * more often than one might expect in the below functions.
> - */
> -#define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)

Yay!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
