Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A15AA6B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 18:19:54 -0400 (EDT)
Date: Tue, 8 Sep 2009 15:18:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] mm: Introduce revoke_file_mappings.
Message-Id: <20090908151853.d313c834.akpm@linux-foundation.org>
In-Reply-To: <m1bplqwlzr.fsf@fess.ebiederm.org>
References: <m1fxb2wm0z.fsf@fess.ebiederm.org>
	<m1bplqwlzr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, adobriyan@gmail.com, gregkh@suse.de, tj@kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 04 Sep 2009 12:25:28 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> 
> When the backing store of a file becomes inaccessible we need a
> function to remove that file from the page tables and arrange for page
> faults to receive SIGBUS until the file is unmapped.
> 
> The current implementation in sysfs almost gets this correct by
> intercepting vm_ops, but fails to call vm_ops->close on revoke and in
> fact does not have quite enough information available to do so.  Which
> can result in leaks for any vm_ops that depend on close to drop
> reference counts.
> 
> It turns out that revoke_file_mapping is less code and a more straight
> forward solution to the problem (except for the locking), as well as
> being a general solution that can work for any mmapped and is not
> limited to sysfs.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
> ---
>  include/linux/mm.h |    2 +
>  mm/memory.c        |  140 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 142 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 9a72cc7..eb6cecb 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -790,6 +790,8 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
>  	unmap_mapping_range(mapping, holebegin, holelen, 0);
>  }
>  
> +extern void revoke_file_mappings(struct file *file);
> +
>  extern int vmtruncate(struct inode * inode, loff_t offset);
>  extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index aede2ce..4b47116 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c

mm/memory.c is large, messy and ill-defined.  I think this new code
would fit nicely into a new mm/revoke.c?

> @@ -55,6 +55,7 @@
>  #include <linux/kallsyms.h>
>  #include <linux/swapops.h>
>  #include <linux/elf.h>
> +#include <linux/file.h>
>  
>  #include <asm/pgalloc.h>
>  #include <asm/uaccess.h>
> @@ -2410,6 +2411,145 @@ void unmap_mapping_range(struct address_space *mapping,
>  }
>  EXPORT_SYMBOL(unmap_mapping_range);
>  
> +static int revoked_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> +{
> +	return VM_FAULT_SIGBUS;
> +}
> +
> +static struct vm_operations_struct revoked_vm_ops = {
> +	.fault	= revoked_fault,
> +};
> +
> +static void revoke_one_file_vma(struct file *file,
> +	struct mm_struct *mm, unsigned long vma_addr)

It'd be nice to have a comment explaining what this function does, how
it does it, etc.

> +{
> +	unsigned long start_addr, end_addr, size;
> +	struct vm_area_struct *vma;
> +
> +	/*
> +	 * Must be called with mmap_sem held for write.
> +	 *
> +	 * Holding the mmap_sem prevents all vm_ops operations from
> +	 * being called as well as preventing all other kinds of
> +	 * modifications to the mm.

Does it?  I'm surprised that we'd have 100% coverage for a rule this
broad.

> +	 */
> +
> +	/* Lookup a vma for my file address */
> +	vma = find_vma(mm, vma_addr);
> +	if (vma->vm_file != file)

What does it mean when this comparison failed?

> +		return;
> +
> +	start_addr = vma->vm_start;
> +	end_addr   = vma->vm_end;
> +	size	   = end_addr - start_addr;
> +
> +	/* Unlock the pages */

A "locked page" in the kernel has a specific meaning, and "being in a
VMA which has VM_LOCKED set" isn't it ;)

> +	if (mm->locked_vm && (vma->vm_flags & VM_LOCKED)) {
> +		mm->locked_vm -= vma_pages(vma);
> +		vma->vm_flags &= ~VM_LOCKED;

So if ->locked_vm happens to be zero, we don't clear VM_LOCKED.  Is
that a bug?

> +	}
> +
> +	/* Unmap the vma */

"Unmap the pages within the vma"

> +	zap_page_range(vma, start_addr, size, NULL);
> +
> +	/* Unlink the vma from the file */
> +	unlink_file_vma(vma);
> +
> +	/* Close the vma */
> +	if (vma->vm_ops && vma->vm_ops->close)
> +		vma->vm_ops->close(vma);
> +	fput(vma->vm_file);
> +	vma->vm_file = NULL;
> +	if (vma->vm_flags & VM_EXECUTABLE)
> +		removed_exe_file_vma(vma->vm_mm);
> +
> +	/* Repurpose the vma  */
> +	vma->vm_private_data = NULL;
> +	vma->vm_ops = &revoked_vm_ops;
> +	vma->vm_flags &= ~(VM_NONLINEAR | VM_CAN_NONLINEAR | VM_PFNMAP);

geeze, where did this decision come from?  Needs explanatory comments?

> +}
> +
> +void revoke_file_mappings(struct file *file)

Again, the semantics and intent of this code can only be divined by
reverse-engineering the implementation.  This makes it hard to review
and harder to maintainer.

> +{
> +	/* After a file has been marked dead update the vmas */
> +	struct address_space *mapping = file->f_mapping;
> +	struct vm_area_struct *vma;
> +	struct prio_tree_iter iter;
> +	unsigned long start_address;
> +	struct mm_struct *mm;
> +	int mm_users;
> +
> +	/*
> +	 * The locking here is a bit complex.
> +	 *
> +	 * - revoke_one_file_vma needs to be able to sleep so it can
> +         *   call vm_ops->close().

whitespace went funny.

> +	 *
> +	 * - i_mmap_lock needs to be held to iterate the list of vmas
> +	 *   for a file.
> +	 *
> +	 * - The mm can be exiting when we find the vma on our list.
> +	 *
> +	 * - This function can not return until we can guarantee for
> +	 *   all vmas associated with file that no vm_ops method will
> +	 *   be called.
> +	 *
> +	 * This code increments mm_users to ensure that the mm will
> +	 * not go away after it drops i_mmap_lock, and then grabs
> +	 * mmap_sem for write to block all other modifications to the
> +	 * mm, before refinding the the vma and removing it.
> +	 *
> +	 * If mm_users is already 0 indicated that exit_mmap is
> +	 * running on the mm the code simply drop the locks and sleeps
> +	 * giving exit_mmap a chance to finish.  If exit_mmap has not
> +	 * freed our vma when we rescan the list we repeat until it has.
> +	 */

All the above makes one wonder "in what contexts can this function be
called" and "what are its calling preconditions".


> +	spin_lock(&mapping->i_mmap_lock);
> +restart_tree:
> +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, ULONG_MAX) {
> +		/* Skip quickly over vmas that do not need to be touched */
> +		if (vma->vm_file != file)
> +			continue;

We check this again in revoke_one_file_vma().  How come?  Avoiding
races perhaps?  I don't know, and I don't know how to find out.

> +		start_address = vma->vm_start;
> +		mm = vma->vm_mm;
> +		mm_users = atomic_inc_not_zero(&mm->mm_users);
> +		spin_unlock(&mapping->i_mmap_lock);
> +		if (mm_users) {
> +			down_write(&mm->mmap_sem);
> +			revoke_one_file_vma(file, mm, start_address);
> +			up_write(&mm->mmap_sem);
> +			mmput(mm);
> +		} else {
> +			schedule(); /* wait for exit_mmap to remove the vma */

This doesn't "wait" for anything.  It's a no-op unless need_resched()
happens to be true.

> +		}
> +		spin_lock(&mapping->i_mmap_lock);
> +		goto restart_tree;
> +	}
> +
> +restart_list:
> +	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list) {
> +		/* Skip quickly over vmas that do not need to be touched */
> +		if (vma->vm_file != file)
> +			continue;
> +		start_address = vma->vm_start;
> +		mm = vma->vm_mm;
> +		mm_users = atomic_inc_not_zero(&mm->mm_users);
> +		spin_unlock(&mapping->i_mmap_lock);
> +		if (mm_users) {
> +			down_write(&mm->mmap_sem);
> +			revoke_one_file_vma(file, mm, start_address);
> +			up_write(&mm->mmap_sem);
> +			mmput(mm);
> +		} else {
> +			schedule(); /* wait for exit_mmap to remove the vma */
> +		}
> +		spin_lock(&mapping->i_mmap_lock);
> +		goto restart_list;
> +	}
> +
> +	spin_unlock(&mapping->i_mmap_lock);
> +}
> +
>  /**
>   * vmtruncate - unmap mappings "freed" by truncate() syscall
>   * @inode: inode of the file used

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
