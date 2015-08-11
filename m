Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 31A6C6B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 04:19:16 -0400 (EDT)
Received: by wijp15 with SMTP id p15so165802522wij.0
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 01:19:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h4si2168998wiv.50.2015.08.11.01.19.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Aug 2015 01:19:14 -0700 (PDT)
Date: Tue, 11 Aug 2015 10:19:09 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH, RFC 2/2] dax: use range_lock instead of i_mmap_lock
Message-ID: <20150811081909.GD2650@quack.suse.cz>
References: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439219664-88088-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439219664-88088-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Jan Kara <jack@suse.cz>

On Mon 10-08-15 18:14:24, Kirill A. Shutemov wrote:
> As we don't have struct pages for DAX memory, Matthew had to find an
> replacement for lock_page() to avoid fault vs. truncate races.
> i_mmap_lock was used for that.
> 
> Recently, Matthew had to convert locking to exclusive to address fault
> vs. fault races. And this kills scalability completely.
> 
> The patch below tries to recover some scalability for DAX by introducing
> per-mapping range lock.

So this grows noticeably (3 longs if I'm right) struct address_space and
thus struct inode just for DAX. That looks like a waste but I don't see an
easy solution.

OTOH filesystems in normal mode might want to use the range lock as well to
provide truncate / punch hole vs page fault exclusion (XFS already has a
private rwsem for this and ext4 needs something as well) and at that point
growing generic struct inode would be acceptable for me.

My grand plan was to use the range lock to also simplify locking rules for
read, write and esp. direct IO but that has issues with mmap_sem ordering
because filesystems get called under mmap_sem in page fault path. So
probably just fixing the worst issue with punch hole vs page fault would be
good for now.

Also for a patch set like this, it would be good to show some numbers - how
big hit do you take in the single-threaded case (the lock is more
expensive) and how much scalability do you get in the multithreaded case?

								Honza

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  fs/dax.c           | 30 +++++++++++++++++-------------
>  fs/inode.c         |  1 +
>  include/linux/fs.h |  2 ++
>  mm/memory.c        | 35 +++++++++++++++++++++++------------
>  mm/rmap.c          |  1 +
>  5 files changed, 44 insertions(+), 25 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index ed54efedade6..27a68eca698e 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -333,6 +333,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  	struct inode *inode = mapping->host;
>  	struct page *page;
>  	struct buffer_head bh;
> +	struct range_lock mapping_lock;
>  	unsigned long vaddr = (unsigned long)vmf->virtual_address;
>  	unsigned blkbits = inode->i_blkbits;
>  	sector_t block;
> @@ -348,6 +349,11 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
>  	bh.b_size = PAGE_SIZE;
>  
> +	/* do_cow_fault() takes the lock */
> +	if (!vmf->cow_page) {
> +		range_lock_init(&mapping_lock, vmf->pgoff, vmf->pgoff);
> +		range_lock(&mapping->mapping_lock, &mapping_lock);
> +	}
>   repeat:
>  	page = find_get_page(mapping, vmf->pgoff);
>  	if (page) {
> @@ -369,8 +375,6 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  			error = -EIO;
>  			goto unlock;
>  		}
> -	} else {
> -		i_mmap_lock_write(mapping);
>  	}
>  
>  	error = get_block(inode, block, &bh, 0);
> @@ -390,8 +394,9 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  			if (error)
>  				goto unlock;
>  		} else {
> -			i_mmap_unlock_write(mapping);
> -			return dax_load_hole(mapping, page, vmf);
> +			error =  dax_load_hole(mapping, page, vmf);
> +			range_unlock(&mapping->mapping_lock, &mapping_lock);
> +			return error;
>  		}
>  	}
>  
> @@ -446,9 +451,9 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  			WARN_ON_ONCE(!(vmf->flags & FAULT_FLAG_WRITE));
>  	}
>  
> -	if (!page)
> -		i_mmap_unlock_write(mapping);
>   out:
> +	if (!vmf->cow_page)
> +		range_unlock(&mapping->mapping_lock, &mapping_lock);
>  	if (error == -ENOMEM)
>  		return VM_FAULT_OOM | major;
>  	/* -EBUSY is fine, somebody else faulted on the same PTE */
> @@ -460,10 +465,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  	if (page) {
>  		unlock_page(page);
>  		page_cache_release(page);
> -	} else {
> -		i_mmap_unlock_write(mapping);
>  	}
> -
>  	goto out;
>  }
>  EXPORT_SYMBOL(__dax_fault);
> @@ -510,6 +512,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  	struct address_space *mapping = file->f_mapping;
>  	struct inode *inode = mapping->host;
>  	struct buffer_head bh;
> +	struct range_lock mapping_lock;
>  	unsigned blkbits = inode->i_blkbits;
>  	unsigned long pmd_addr = address & PMD_MASK;
>  	bool write = flags & FAULT_FLAG_WRITE;
> @@ -541,7 +544,8 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
>  
>  	bh.b_size = PMD_SIZE;
> -	i_mmap_lock_write(mapping);
> +	range_lock_init(&mapping_lock, pgoff, pgoff + HPAGE_PMD_NR - 1);
> +	range_lock(&mapping->mapping_lock, &mapping_lock);
>  	length = get_block(inode, block, &bh, write);
>  	if (length)
>  		return VM_FAULT_SIGBUS;
> @@ -568,9 +572,9 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  	 * zero pages covering this hole
>  	 */
>  	if (buffer_new(&bh)) {
> -		i_mmap_unlock_write(mapping);
> +		range_unlock(&mapping->mapping_lock, &mapping_lock);
>  		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
> -		i_mmap_lock_write(mapping);
> +		range_lock(&mapping->mapping_lock, &mapping_lock);
>  	}
>  
>  	/*
> @@ -624,7 +628,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  	if (buffer_unwritten(&bh))
>  		complete_unwritten(&bh, !(result & VM_FAULT_ERROR));
>  
> -	i_mmap_unlock_write(mapping);
> +	range_unlock(&mapping->mapping_lock, &mapping_lock);
>  
>  	return result;
>  
> diff --git a/fs/inode.c b/fs/inode.c
> index e560535706ff..6a24144d679f 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -343,6 +343,7 @@ void address_space_init_once(struct address_space *mapping)
>  	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
>  	spin_lock_init(&mapping->tree_lock);
>  	init_rwsem(&mapping->i_mmap_rwsem);
> +	range_lock_tree_init(&mapping->mapping_lock);
>  	INIT_LIST_HEAD(&mapping->private_list);
>  	spin_lock_init(&mapping->private_lock);
>  	mapping->i_mmap = RB_ROOT;
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index b6361e2e2a26..368e7208d4f2 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -30,6 +30,7 @@
>  #include <linux/lockdep.h>
>  #include <linux/percpu-rwsem.h>
>  #include <linux/blk_types.h>
> +#include <linux/range_lock.h>
>  
>  #include <asm/byteorder.h>
>  #include <uapi/linux/fs.h>
> @@ -429,6 +430,7 @@ struct address_space {
>  	atomic_t		i_mmap_writable;/* count VM_SHARED mappings */
>  	struct rb_root		i_mmap;		/* tree of private and shared mappings */
>  	struct rw_semaphore	i_mmap_rwsem;	/* protect tree, count, list */
> +	struct range_lock_tree	mapping_lock;	/* lock_page() replacement for DAX */
>  	/* Protected by tree_lock together with the radix tree */
>  	unsigned long		nrpages;	/* number of total pages */
>  	unsigned long		nrshadows;	/* number of shadow entries */
> diff --git a/mm/memory.c b/mm/memory.c
> index 7f6a9563d5a6..b4898db7e4c4 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2409,6 +2409,7 @@ void unmap_mapping_range(struct address_space *mapping,
>  		loff_t const holebegin, loff_t const holelen, int even_cows)
>  {
>  	struct zap_details details;
> +	struct range_lock mapping_lock;
>  	pgoff_t hba = holebegin >> PAGE_SHIFT;
>  	pgoff_t hlen = (holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
>  
> @@ -2426,10 +2427,17 @@ void unmap_mapping_range(struct address_space *mapping,
>  	if (details.last_index < details.first_index)
>  		details.last_index = ULONG_MAX;
>  
> +	if (IS_DAX(mapping->host)) {
> +		/* Exclude fault under us */
> +		range_lock_init(&mapping_lock, hba, hba + hlen - 1);
> +		range_lock(&mapping->mapping_lock, &mapping_lock);
> +	}
>  	i_mmap_lock_write(mapping);
>  	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
>  		unmap_mapping_range_tree(&mapping->i_mmap, &details);
>  	i_mmap_unlock_write(mapping);
> +	if (IS_DAX(mapping->host))
> +		range_unlock(&mapping->mapping_lock, &mapping_lock);
>  }
>  EXPORT_SYMBOL(unmap_mapping_range);
>  
> @@ -2978,6 +2986,8 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		unsigned long address, pmd_t *pmd,
>  		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
>  {
> +	struct address_space *mapping = vma->vm_file->f_mapping;
> +	struct range_lock mapping_lock;
>  	struct page *fault_page, *new_page;
>  	struct mem_cgroup *memcg;
>  	spinlock_t *ptl;
> @@ -2996,6 +3006,15 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		return VM_FAULT_OOM;
>  	}
>  
> +	if (IS_DAX(file_inode(vma->vm_file))) {
> +		/*
> +		 * The fault handler has no page to lock, so it holds
> +		 * mapping->mapping_lock to protect against truncate.
> +		 */
> +		range_lock_init(&mapping_lock, pgoff, pgoff);
> +		range_unlock(&mapping->mapping_lock, &mapping_lock);
> +	}
> +
>  	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		goto uncharge_out;
> @@ -3010,12 +3029,6 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		if (fault_page) {
>  			unlock_page(fault_page);
>  			page_cache_release(fault_page);
> -		} else {
> -			/*
> -			 * The fault handler has no page to lock, so it holds
> -			 * i_mmap_lock for write to protect against truncate.
> -			 */
> -			i_mmap_unlock_write(vma->vm_file->f_mapping);
>  		}
>  		goto uncharge_out;
>  	}
> @@ -3026,15 +3039,13 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (fault_page) {
>  		unlock_page(fault_page);
>  		page_cache_release(fault_page);
> -	} else {
> -		/*
> -		 * The fault handler has no page to lock, so it holds
> -		 * i_mmap_lock for write to protect against truncate.
> -		 */
> -		i_mmap_unlock_write(vma->vm_file->f_mapping);
>  	}
> +	if (IS_DAX(file_inode(vma->vm_file)))
> +		range_unlock(&mapping->mapping_lock, &mapping_lock);
>  	return ret;
>  uncharge_out:
> +	if (IS_DAX(file_inode(vma->vm_file)))
> +		range_unlock(&mapping->mapping_lock, &mapping_lock);
>  	mem_cgroup_cancel_charge(new_page, memcg);
>  	page_cache_release(new_page);
>  	return ret;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index dcaad464aab0..3d509326d354 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -22,6 +22,7 @@
>   *
>   * inode->i_mutex	(while writing or truncating, not reading or faulting)
>   *   mm->mmap_sem
> + *    mapping->mapping_lock
>   *     page->flags PG_locked (lock_page)
>   *       mapping->i_mmap_rwsem
>   *         anon_vma->rwsem
> -- 
> 2.5.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
