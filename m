Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id EBC1D6B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 17:58:11 -0500 (EST)
Received: by pacej9 with SMTP id ej9so82322480pac.2
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 14:58:11 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id gh4si52991338pac.134.2015.11.16.14.58.09
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 14:58:11 -0800 (PST)
Date: Tue, 17 Nov 2015 09:58:07 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 08/11] dax: add support for fsync/sync
Message-ID: <20151116225807.GX19199@dastard>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
 <1447459610-14259-9-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447459610-14259-9-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, Nov 13, 2015 at 05:06:47PM -0700, Ross Zwisler wrote:
> To properly handle fsync/msync in an efficient way DAX needs to track dirty
> pages so it is able to flush them durably to media on demand.
> 
> The tracking of dirty pages is done via the radix tree in struct
> address_space.  This radix tree is already used by the page writeback
> infrastructure for tracking dirty pages associated with an open file, and
> it already has support for exceptional (non struct page*) entries.  We
> build upon these features to add exceptional entries to the radix tree for
> DAX dirty PMD or PTE pages at fault time.
> 
> When called as part of the msync/fsync flush path DAX queries the radix
> tree for dirty entries, flushing them and then marking the PTE or PMD page
> table entries as clean.  The step of cleaning the PTE or PMD entries is
> necessary so that on subsequent writes to the same page we get a new write
> fault allowing us to once again dirty the DAX tag in the radix tree.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/dax.c            | 140 +++++++++++++++++++++++++++++++++++++++++++++++++---
>  include/linux/dax.h |   1 +
>  mm/huge_memory.c    |  14 +++---
>  3 files changed, 141 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 131fd35a..9ce6d1b 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -24,7 +24,9 @@
>  #include <linux/memcontrol.h>
>  #include <linux/mm.h>
>  #include <linux/mutex.h>
> +#include <linux/pagevec.h>
>  #include <linux/pmem.h>
> +#include <linux/rmap.h>
>  #include <linux/sched.h>
>  #include <linux/uio.h>
>  #include <linux/vmstat.h>
> @@ -287,6 +289,53 @@ static int copy_user_bh(struct page *to, struct buffer_head *bh,
>  	return 0;
>  }
>  
> +static int dax_dirty_pgoff(struct address_space *mapping, unsigned long pgoff,
> +		void __pmem *addr, bool pmd_entry)
> +{
> +	struct radix_tree_root *page_tree = &mapping->page_tree;
> +	int error = 0;
> +	void *entry;
> +
> +	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	entry = radix_tree_lookup(page_tree, pgoff);
> +	if (addr == NULL) {
> +		if (entry)
> +			goto dirty;
> +		else {
> +			WARN(1, "DAX pfn_mkwrite failed to find an entry");
> +			goto out;
> +		}
> +	}
> +
> +	if (entry) {
> +		if (pmd_entry && RADIX_DAX_TYPE(entry) == RADIX_DAX_PTE) {
> +			radix_tree_delete(&mapping->page_tree, pgoff);
> +			mapping->nrdax--;
> +		} else
> +			goto dirty;
> +	}

Logic is pretty spagettied here. Perhaps:

	entry = radix_tree_lookup(page_tree, pgoff);
	if (entry) {
		if (!pmd_entry || RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD))
			goto dirty;
		radix_tree_delete(&mapping->page_tree, pgoff);
		mapping->nrdax--;
	} else {
		WARN_ON(!addr);
		goto out_unlock;
	}
....

> +
> +	BUG_ON(RADIX_DAX_TYPE(addr));
> +	if (pmd_entry)
> +		error = radix_tree_insert(page_tree, pgoff,
> +				RADIX_DAX_PMD_ENTRY(addr));
> +	else
> +		error = radix_tree_insert(page_tree, pgoff,
> +				RADIX_DAX_PTE_ENTRY(addr));
> +
> +	if (error)
> +		goto out;
> +
> +	mapping->nrdax++;
> + dirty:
> +	radix_tree_tag_set(page_tree, pgoff, PAGECACHE_TAG_DIRTY);
> + out:
> +	spin_unlock_irq(&mapping->tree_lock);

label should be "out_unlock" rather "out" to indicate in the code
that we are jumping to the correct spot in the error stack...

> +			goto fallback;
>  	}
>  
>   out:
> @@ -689,15 +746,12 @@ EXPORT_SYMBOL_GPL(dax_pmd_fault);
>   * dax_pfn_mkwrite - handle first write to DAX page
>   * @vma: The virtual memory area where the fault occurred
>   * @vmf: The description of the fault
> - *
>   */
>  int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
> -	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
> +	struct file *file = vma->vm_file;
>  
> -	sb_start_pagefault(sb);
> -	file_update_time(vma->vm_file);
> -	sb_end_pagefault(sb);
> +	dax_dirty_pgoff(file->f_mapping, vmf->pgoff, NULL, false);
>  	return VM_FAULT_NOPAGE;

This seems wrong - it's dropping the freeze protection on fault, and
now the inode timestamp won't get updated, either.

>  }
>  EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
> @@ -772,3 +826,77 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
>  	return dax_zero_page_range(inode, from, length, get_block);
>  }
>  EXPORT_SYMBOL_GPL(dax_truncate_page);
> +
> +static void dax_sync_entry(struct address_space *mapping, pgoff_t pgoff,
> +		void *entry)
> +{

dax_writeback_pgoff() seems like a more consistent name (consider
dax_dirty_pgoff), and that we are actually doing a writeback
operation, not a "sync" operation.

> +	struct radix_tree_root *page_tree = &mapping->page_tree;
> +	int type = RADIX_DAX_TYPE(entry);
> +	size_t size;
> +
> +	BUG_ON(type != RADIX_DAX_PTE && type != RADIX_DAX_PMD);
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	if (!radix_tree_tag_get(page_tree, pgoff, PAGECACHE_TAG_TOWRITE)) {
> +		/* another fsync thread already wrote back this entry */
> +		spin_unlock_irq(&mapping->tree_lock);
> +		return;
> +	}
> +	radix_tree_tag_clear(page_tree, pgoff, PAGECACHE_TAG_TOWRITE);
> +	radix_tree_tag_clear(page_tree, pgoff, PAGECACHE_TAG_DIRTY);
> +	spin_unlock_irq(&mapping->tree_lock);
> +
> +	if (type == RADIX_DAX_PMD)
> +		size = PMD_SIZE;
> +	else
> +		size = PAGE_SIZE;
> +
> +	wb_cache_pmem(RADIX_DAX_ADDR(entry), size);
> +	pgoff_mkclean(pgoff, mapping);

This looks racy w.r.t. another operation setting the radix tree
dirty tags. i.e. there is no locking to serialise marking the
vma/pte clean and another operation marking the radix tree dirty.

> +}
> +
> +/*
> + * Flush the mapping to the persistent domain within the byte range of (start,
> + * end). This is required by data integrity operations to ensure file data is on
> + * persistent storage prior to completion of the operation. It also requires us
> + * to clean the mappings (i.e. write -> RO) so that we'll get a new fault when
> + * the file is written to again so we have an indication that we need to flush
> + * the mapping if a data integrity operation takes place.
> + *
> + * We don't need commits to storage here - the filesystems will issue flushes
> + * appropriately at the conclusion of the data integrity operation via REQ_FUA
> + * writes or blkdev_issue_flush() commands.  This requires the DAX block device
> + * to implement persistent storage domain fencing/commits on receiving a
> + * REQ_FLUSH or REQ_FUA request so that this works as expected by the higher
> + * layers.
> + */
> +void dax_fsync(struct address_space *mapping, loff_t start, loff_t end)
> +{

dax_writeback_mapping_range()

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
