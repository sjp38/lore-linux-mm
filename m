Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 62BEA6B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 07:46:20 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id f185so25482427vkb.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 04:46:20 -0700 (PDT)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id l80si46072275qhc.132.2016.04.19.04.46.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 04:46:19 -0700 (PDT)
Received: by mail-qg0-x22f.google.com with SMTP id v14so6769743qge.0
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 04:46:19 -0700 (PDT)
Date: Tue, 19 Apr 2016 07:46:09 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 17/18] dax: Use radix tree entry lock to protect cow
 faults
Message-ID: <20160419114609.GA13932@gmail.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-18-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461015341-20153-18-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Mon, Apr 18, 2016 at 11:35:40PM +0200, Jan Kara wrote:
> When doing cow faults, we cannot directly fill in PTE as we do for other
> faults as we rely on generic code to do proper accounting of the cowed page.
> We also have no page to lock to protect against races with truncate as
> other faults have and we need the protection to extend until the moment
> generic code inserts cowed page into PTE thus at that point we have no
> protection of fs-specific i_mmap_sem. So far we relied on using
> i_mmap_lock for the protection however that is completely special to cow
> faults. To make fault locking more uniform use DAX entry lock instead.
> 
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/dax.c            | 12 +++++-------
>  include/linux/dax.h |  7 +++++++
>  include/linux/mm.h  |  7 +++++++
>  mm/memory.c         | 38 ++++++++++++++++++--------------------
>  4 files changed, 37 insertions(+), 27 deletions(-)
> 

[...]

> diff --git a/mm/memory.c b/mm/memory.c
> index 93897f23cc11..f09cdb8d48fa 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -63,6 +63,7 @@
>  #include <linux/dma-debug.h>
>  #include <linux/debugfs.h>
>  #include <linux/userfaultfd_k.h>
> +#include <linux/dax.h>
>  
>  #include <asm/io.h>
>  #include <asm/mmu_context.h>
> @@ -2785,7 +2786,8 @@ oom:
>   */
>  static int __do_fault(struct vm_area_struct *vma, unsigned long address,
>  			pgoff_t pgoff, unsigned int flags,
> -			struct page *cow_page, struct page **page)
> +			struct page *cow_page, struct page **page,
> +			void **entry)
>  {
>  	struct vm_fault vmf;
>  	int ret;
> @@ -2800,8 +2802,10 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
>  	ret = vma->vm_ops->fault(vma, &vmf);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		return ret;
> -	if (!vmf.page)
> -		goto out;

Removing the above sounds seriously bogus to me as it means that below
if (unlikely(PageHWPoison(vmf.page))) could dereference a NULL pointer.


> +	if (ret & VM_FAULT_DAX_LOCKED) {
> +		*entry = vmf.entry;
> +		return ret;
> +	}

I see that below you call __do_fault() with NULL for entry, if i am
properly understanding you will never get VM_FAULT_DAX_LOCKED set in
those case so this should be fine but maybe a BUG_ON() might be worth
it.

>  
>  	if (unlikely(PageHWPoison(vmf.page))) {
>  		if (ret & VM_FAULT_LOCKED)
> @@ -2815,7 +2819,6 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
>  	else
>  		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
>  
> - out:
>  	*page = vmf.page;
>  	return ret;
>  }
> @@ -2987,7 +2990,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		pte_unmap_unlock(pte, ptl);
>  	}
>  
> -	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
> +	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page, NULL);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		return ret;
>  
> @@ -3010,6 +3013,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
>  {
>  	struct page *fault_page, *new_page;
> +	void *fault_entry;
>  	struct mem_cgroup *memcg;
>  	spinlock_t *ptl;
>  	pte_t *pte;
> @@ -3027,26 +3031,24 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		return VM_FAULT_OOM;
>  	}
>  
> -	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page);
> +	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page,
> +			 &fault_entry);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		goto uncharge_out;
>  
> -	if (fault_page)
> +	if (!(ret & VM_FAULT_DAX_LOCKED))
>  		copy_user_highpage(new_page, fault_page, address, vma);

Again removing check for non NULL page looks bogus to me, i think there are
still cases where you will get !(ret & VM_FAULT_DAX_LOCKED) and a fault_page
== NULL, for instance from device file mapping. To me it seems that what you
want is fault_page = NULL when VM_FAULT_DAX_LOCKED is set.

>  	__SetPageUptodate(new_page);
>  
>  	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
>  	if (unlikely(!pte_same(*pte, orig_pte))) {
>  		pte_unmap_unlock(pte, ptl);
> -		if (fault_page) {
> +		if (!(ret & VM_FAULT_DAX_LOCKED)) {

Same as above.

>  			unlock_page(fault_page);
>  			put_page(fault_page);
>  		} else {
> -			/*
> -			 * The fault handler has no page to lock, so it holds
> -			 * i_mmap_lock for read to protect against truncate.
> -			 */
> -			i_mmap_unlock_read(vma->vm_file->f_mapping);
> +			dax_unlock_mapping_entry(vma->vm_file->f_mapping,
> +						 pgoff);
>  		}
>  		goto uncharge_out;
>  	}
> @@ -3054,15 +3056,11 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	mem_cgroup_commit_charge(new_page, memcg, false, false);
>  	lru_cache_add_active_or_unevictable(new_page, vma);
>  	pte_unmap_unlock(pte, ptl);
> -	if (fault_page) {
> +	if (!(ret & VM_FAULT_DAX_LOCKED)) {

Again fault_page might be NULL while VM_FAULT_DAX_LOCKED is not set.

>  		unlock_page(fault_page);
>  		put_page(fault_page);
>  	} else {
> -		/*
> -		 * The fault handler has no page to lock, so it holds
> -		 * i_mmap_lock for read to protect against truncate.
> -		 */
> -		i_mmap_unlock_read(vma->vm_file->f_mapping);
> +		dax_unlock_mapping_entry(vma->vm_file->f_mapping, pgoff);
>  	}
>  	return ret;
>  uncharge_out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
