Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 25C294403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 05:57:09 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id b14so313490436wmb.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 02:57:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v126si30390273wmg.9.2016.01.12.02.57.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Jan 2016 02:57:07 -0800 (PST)
Date: Tue, 12 Jan 2016 11:57:16 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v8 6/9] dax: add support for fsync/msync
Message-ID: <20160112105716.GT6262@quack.suse.cz>
References: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com>
 <1452230879-18117-7-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452230879-18117-7-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

On Thu 07-01-16 22:27:56, Ross Zwisler wrote:
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
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Some comments below.

> ---
>  fs/dax.c            | 194 ++++++++++++++++++++++++++++++++++++++++++++++++++--
>  include/linux/dax.h |   2 +
>  mm/filemap.c        |   6 ++
>  3 files changed, 196 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 5b84a46..0db21ea 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -24,6 +24,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/mm.h>
>  #include <linux/mutex.h>
> +#include <linux/pagevec.h>
>  #include <linux/pmem.h>
>  #include <linux/sched.h>
>  #include <linux/uio.h>
> @@ -324,6 +325,174 @@ static int copy_user_bh(struct page *to, struct inode *inode,
>  	return 0;
>  }
>  
> +#define NO_SECTOR -1
> +
> +static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
> +		sector_t sector, bool pmd_entry, bool dirty)
> +{
> +	struct radix_tree_root *page_tree = &mapping->page_tree;
> +	int type, error = 0;
> +	void *entry;
> +
> +	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	entry = radix_tree_lookup(page_tree, index);
> +
> +	if (entry) {
> +		type = RADIX_DAX_TYPE(entry);
> +		if (WARN_ON_ONCE(type != RADIX_DAX_PTE &&
> +					type != RADIX_DAX_PMD)) {
> +			error = -EIO;
> +			goto unlock;
> +		}
> +
> +		if (!pmd_entry || type == RADIX_DAX_PMD)
> +			goto dirty;
> +		radix_tree_delete(&mapping->page_tree, index);
> +		mapping->nrexceptional--;

In theory, you can delete here DIRTY / TOWRITE PTE entry and insert a clean
PMD entry instead of it. That will cause fsync() to miss some flushes. So
you should make sure you transfer all the tags to the new entry.

> +static int dax_writeback_one(struct block_device *bdev,
> +		struct address_space *mapping, pgoff_t index, void *entry)
> +{
> +	struct radix_tree_root *page_tree = &mapping->page_tree;
> +	int type = RADIX_DAX_TYPE(entry);
> +	struct radix_tree_node *node;
> +	struct blk_dax_ctl dax;
> +	void **slot;
> +	int ret = 0;
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	/*
> +	 * Regular page slots are stabilized by the page lock even
> +	 * without the tree itself locked.  These unlocked entries
> +	 * need verification under the tree lock.
> +	 */
> +	if (!__radix_tree_lookup(page_tree, index, &node, &slot))
> +		goto unlock;
> +	if (*slot != entry)
> +		goto unlock;
> +
> +	/* another fsync thread may have already written back this entry */
> +	if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
> +		goto unlock;
> +
> +	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
> +
> +	if (WARN_ON_ONCE(type != RADIX_DAX_PTE && type != RADIX_DAX_PMD)) {
> +		ret = -EIO;
> +		goto unlock;
> +	}
> +
> +	dax.sector = RADIX_DAX_SECTOR(entry);
> +	dax.size = (type == RADIX_DAX_PMD ? PMD_SIZE : PAGE_SIZE);
> +	spin_unlock_irq(&mapping->tree_lock);

This seems to be somewhat racy as well - if there are two fsyncs running
against the same inode, one wins the race and clears TOWRITE tag, the
second then bails out and may finish before the skipped page gets flushed.

So we should clear the TOWRITE tag only after the range is flushed.  This
can result in some amount of duplicit flushing but I don't think the race
will happen that frequently in practice to be performance relevant.

And secondly: You must write-protect all mappings of the flushed range so
that you get fault when the sector gets written-to again. We spoke about
this in the past already but somehow it got lost and I forgot about it as
well. You need something like rmap_walk_file()...

> +	/*
> +	 * We cannot hold tree_lock while calling dax_map_atomic() because it
> +	 * eventually calls cond_resched().
> +	 */
> +	ret = dax_map_atomic(bdev, &dax);
> +	if (ret < 0)
> +		return ret;
> +
> +	if (WARN_ON_ONCE(ret < dax.size)) {
> +		ret = -EIO;
> +		goto unmap;
> +	}
> +
> +	wb_cache_pmem(dax.addr, dax.size);
> + unmap:
> +	dax_unmap_atomic(bdev, &dax);
> +	return ret;
> +
> + unlock:
> +	spin_unlock_irq(&mapping->tree_lock);
> +	return ret;
> +}

...

> @@ -791,15 +976,12 @@ EXPORT_SYMBOL_GPL(dax_pmd_fault);
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
> +	dax_radix_entry(file->f_mapping, vmf->pgoff, NO_SECTOR, false, true);

Why is NO_SECTOR argument correct here?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
