Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDB76B0047
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 18:14:35 -0500 (EST)
Date: Fri, 29 Jan 2010 15:14:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] change anon_vma linking to fix multi-process server
 scalability issue
Message-Id: <20100129151423.8b71b88e.akpm@linux-foundation.org>
In-Reply-To: <20100128002000.2bf5e365@annuminas.surriel.com>
References: <20100128002000.2bf5e365@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jan 2010 00:20:00 -0500
Rik van Riel <riel@redhat.com> wrote:

> The old anon_vma code can lead to scalability issues with heavily
> forking workloads.  Specifically, each anon_vma will be shared
> between the parent process and all its child processes.
> 
> In a workload with 1000 child processes and a VMA with 1000 anonymous
> pages per process that get COWed, this leads to a system with a million
> anonymous pages in the same anon_vma, each of which is mapped in just
> one of the 1000 processes.  However, the current rmap code needs to
> walk them all, leading to O(N) scanning complexity for each page.
> 
> This can result in systems where one CPU is walking the page tables
> of 1000 processes in page_referenced_one, while all other CPUs are
> stuck on the anon_vma lock.  This leads to catastrophic failure for
> a benchmark like AIM7, where the total number of processes can reach
> in the tens of thousands.  Real workloads are still a factor 10 less
> process intensive than AIM7, but they are catching up.
> 
> This patch changes the way anon_vmas and VMAs are linked, which
> allows us to associate multiple anon_vmas with a VMA.  At fork
> time, each child process gets its own anon_vmas, in which its
> COWed pages will be instantiated.  The parents' anon_vma is also
> linked to the VMA, because non-COWed pages could be present in
> any of the children.
> 
> This reduces rmap scanning complexity to O(1) for the pages of
> the 1000 child processes, with O(N) complexity for at most 1/N
> pages in the system.  This reduces the average scanning cost in
> heavily forking workloads from O(N) to 2.
> 
> The only real complexity in this patch stems from the fact that
> linking a VMA to anon_vmas now involves memory allocations. This
> means vma_adjust can fail, if it needs to attach a VMA to anon_vma
> structures. This in turn means error handling needs to be added
> to the calling functions.
> 
> A second source of complexity is that, because there can be
> multiple anon_vmas, the anon_vma linking in vma_adjust can
> no longer be done under "the" anon_vma lock.  To prevent the
> rmap code from walking up an incomplete VMA, this patch
> introduces the VM_LOCK_RMAP VMA flag.  This bit flag uses
> the same slot as the NOMMU VM_MAPPED_COPY, with an ifdef
> in mm.h to make sure it is impossible to compile a kernel
> that needs both symbolic values for the same bitflag.
> 
>
> ...
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -96,7 +96,11 @@ extern unsigned int kobjsize(const void *objp);
>  #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
>  #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
>  #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
> +#ifdef CONFIG_MMU
> +#define VM_LOCK_RMAP	0x01000000	/* Do not follow this rmap (mmu mmap) */
> +#else
>  #define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
> +#endif

What's the locking for vma_area_struct.vm_flags?  It's somewhat
unobvious what that is, and whether the code here observes it.


>  #define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
>  #define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
>  
> @@ -1108,7 +1112,7 @@ static inline void vma_nonlinear_insert(struct vm_area_struct *vma,
>  
>  /* mmap.c */
>  extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
> -extern void vma_adjust(struct vm_area_struct *vma, unsigned long start,
> +extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
>  extern struct vm_area_struct *vma_merge(struct mm_struct *,
>  	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 84a524a..2a06fe1 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -167,7 +167,7 @@ struct vm_area_struct {
>  	 * can only be in the i_mmap tree.  An anonymous MAP_PRIVATE, stack
>  	 * or brk vma (with NULL file) can only be in an anon_vma list.
>  	 */
> -	struct list_head anon_vma_node;	/* Serialized by anon_vma->lock */
> +	struct list_head anon_vma_chain; /* Serialized by mmap_sem & friends */

Can we be a bit more explicit than "and friends"?

>  	struct anon_vma *anon_vma;	/* Serialized by page_table_lock */
>  
>  	/* Function pointers to deal with this struct. */
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index b019ae6..c0a6056 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -37,7 +37,27 @@ struct anon_vma {
>  	 * is serialized by a system wide lock only visible to
>  	 * mm_take_all_locks() (mm_all_locks_mutex).
>  	 */
> -	struct list_head head;	/* List of private "related" vmas */
> +	struct list_head head;	/* Chain of private "related" vmas */
> +};
> +
> +/*
> + * The copy-on-write semantics of fork mean that an anon_vma
> + * can become associated with multiple processes. Furthermore,
> + * each child process will have its own anon_vma, where new
> + * pages for that process are instantiated.
> + *
> + * This structure allows us to find the anon_vmas associated
> + * with a VMA, or the VMAs associated with an anon_vma.
> + * The "same_vma" list contains the anon_vma_chains linking
> + * all the anon_vmas associated with this VMA.
> + * The "same_anon_vma" list contains the anon_vma_chains
> + * which link all the VMAs associated with this anon_vma.
> + */
> +struct anon_vma_chain {
> +	struct vm_area_struct *vma;
> +	struct anon_vma *anon_vma;
> +	struct list_head same_vma;	/* locked by mmap_sem & friends */

"friends"?

> +	struct list_head same_anon_vma;	/* locked by anon_vma->lock */
>  };
>  
>  #ifdef CONFIG_MMU
> @@ -89,12 +109,19 @@ static inline void anon_vma_unlock(struct vm_area_struct *vma)
>   */
>  void anon_vma_init(void);	/* create anon_vma_cachep */
>  int  anon_vma_prepare(struct vm_area_struct *);
> -void __anon_vma_merge(struct vm_area_struct *, struct vm_area_struct *);
> -void anon_vma_unlink(struct vm_area_struct *);
> -void anon_vma_link(struct vm_area_struct *);
> +void unlink_anon_vmas(struct vm_area_struct *);
> +int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
> +int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
>  void __anon_vma_link(struct vm_area_struct *);
>  void anon_vma_free(struct anon_vma *);
>  
>
> ...
>
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -328,15 +328,17 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>  		if (!tmp)
>  			goto fail_nomem;
>  		*tmp = *mpnt;
> +		INIT_LIST_HEAD(&tmp->anon_vma_chain);
>  		pol = mpol_dup(vma_policy(mpnt));
>  		retval = PTR_ERR(pol);
>  		if (IS_ERR(pol))
>  			goto fail_nomem_policy;
>  		vma_set_policy(tmp, pol);
> +		if (anon_vma_fork(tmp, mpnt))
> +			goto fail_nomem_anon_vma_fork;

Didn't we just leak `pol'?

>  		tmp->vm_flags &= ~VM_LOCKED;
>  		tmp->vm_mm = mm;
>  		tmp->vm_next = NULL;
> -		anon_vma_link(tmp);
>  		file = tmp->vm_file;
>  		if (file) {
>  			struct inode *inode = file->f_path.dentry->d_inode;
>
> ...
>
> @@ -542,6 +541,29 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		}
>  	}
>  
> +	/*
> +	 * When changing only vma->vm_end, we don't really need
> +	 * anon_vma lock.
> +	 */
> +	if (vma->anon_vma && (insert || importer || start != vma->vm_start))
> +		anon_vma = vma->anon_vma;
> +	if (anon_vma) {
> +		/*
> +		 * Easily overlooked: when mprotect shifts the boundary,
> +		 * make sure the expanding vma has anon_vma set if the
> +		 * shrinking vma had, to cover any anon pages imported.
> +		 */
> +		if (importer && !importer->anon_vma) {
> +			/* Block reverse map lookups until things are set up. */

Here, it'd be nice to explain the _reason_ for doing this.

> 			importer->vm_flags |= VM_LOCK_RMAP;
> +			if (anon_vma_clone(importer, vma)) {
> +				importer->vm_flags &= ~VM_LOCK_RMAP;
> +				return -ENOMEM;
> +			}
> +			importer->anon_vma = anon_vma;
> +		}
> +	}
> +
>  	if (file) {
>  		mapping = file->f_mapping;
>  		if (!(vma->vm_flags & VM_NONLINEAR))
> @@ -567,25 +589,6 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		}
>  	}
>  
> -	/*
> -	 * When changing only vma->vm_end, we don't really need
> -	 * anon_vma lock.
> -	 */
> -	if (vma->anon_vma && (insert || importer || start != vma->vm_start))
> -		anon_vma = vma->anon_vma;
> -	if (anon_vma) {
> -		spin_lock(&anon_vma->lock);
> -		/*
> -		 * Easily overlooked: when mprotect shifts the boundary,
> -		 * make sure the expanding vma has anon_vma set if the
> -		 * shrinking vma had, to cover any anon pages imported.
> -		 */
> -		if (importer && !importer->anon_vma) {
> -			importer->anon_vma = anon_vma;
> -			__anon_vma_link(importer);
> -		}
> -	}
> -
>  	if (root) {
>  		flush_dcache_mmap_lock(mapping);
>  		vma_prio_tree_remove(vma, root);
> @@ -616,8 +619,11 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		__vma_unlink(mm, next, vma);
>  		if (file)
>  			__remove_shared_vm_struct(next, file, mapping);
> -		if (next->anon_vma)
> -			__anon_vma_merge(vma, next);
> +		/*
> +		 * This VMA is now dead, no need for rmap to follow it.
> +		 * Call anon_vma_merge below, outside of i_mmap_lock.
> +		 */
> +		next->vm_flags |= VM_LOCK_RMAP;
>  	} else if (insert) {
>  		/*
>  		 * split_vma has split insert from vma, and needs
> @@ -627,17 +633,25 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		__insert_vm_struct(mm, insert);
>  	}
>  
> -	if (anon_vma)
> -		spin_unlock(&anon_vma->lock);
>  	if (mapping)
>  		spin_unlock(&mapping->i_mmap_lock);
>  
> +	/*
> +	 * The current VMA has been set up. It is now safe for the
> +	 * rmap code to get from the pages to the ptes.
> +	 */
> +	if (anon_vma && importer)
> +		importer->vm_flags &= ~VM_LOCK_RMAP;

This clears a flag which this function might not have set - the
(importer->anon_vma != NULL) case.

Seems a bit messy at least.  Perhaps a local i_need_to_clear_the_bit
bool would be more robust.

>  	if (remove_next) {
>  		if (file) {
>  			fput(file);
>  			if (next->vm_flags & VM_EXECUTABLE)
>  				removed_exe_file_vma(mm);
>  		}
> +		/* Protected by mmap_sem and VM_LOCK_RMAP. */
> +		if (next->anon_vma)
> +			anon_vma_merge(vma, next);
>  		mm->map_count--;
>  		mpol_put(vma_policy(next));
>  		kmem_cache_free(vm_area_cachep, next);
>
> ...
>
> @@ -1868,11 +1893,14 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
>  
>  	pol = mpol_dup(vma_policy(vma));
>  	if (IS_ERR(pol)) {
> -		kmem_cache_free(vm_area_cachep, new);
> -		return PTR_ERR(pol);
> +		err = PTR_ERR(pol);
> +		goto out_free_vma;
>  	}
>  	vma_set_policy(new, pol);
>  
> +	if (anon_vma_clone(new, vma))
> +		goto out_free_mpol;

The handling of `err' in this function is a bit tricksy.  It's correct,
but not obviously so and we might break it in the future.  One way to
address that would be to sprinkle `err = -ENOMEM' everywhere and
wouldn't be very nice.  Ho hum.

>  	if (new->vm_file) {
>  		get_file(new->vm_file);
>  		if (vma->vm_flags & VM_EXECUTABLE)
> @@ -1883,12 +1911,28 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
>  		new->vm_ops->open(new);
>  
>  	if (new_below)
> -		vma_adjust(vma, addr, vma->vm_end, vma->vm_pgoff +
> +		err = vma_adjust(vma, addr, vma->vm_end, vma->vm_pgoff +
>  			((addr - new->vm_start) >> PAGE_SHIFT), new);
>  	else
> -		vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
> +		err = vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
>  
> -	return 0;
> +	/* Success. */
> +	if (!err)
> +		return 0;
> +
> +	/* Clean everything up if vma_adjust failed. */
> +	new->vm_ops->close(new);
> +	if (new->vm_file) {
> +		if (vma->vm_flags & VM_EXECUTABLE)
> +			removed_exe_file_vma(mm);
> +		fput(new->vm_file);
> +	}

Did the above path get tested?

> + out_free_mpol:
> +	mpol_put(pol);
> + out_free_vma:
> +	kmem_cache_free(vm_area_cachep, new);
> + out_err:
> +	return err;
>  }
>  
>  /*
>
> ...
>
> +int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
>  {
> -	struct anon_vma *anon_vma = vma->anon_vma;
> +	struct anon_vma_chain *avc;
> +	struct anon_vma *anon_vma;
>  
> -	if (anon_vma) {
> -		spin_lock(&anon_vma->lock);
> -		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
> -		spin_unlock(&anon_vma->lock);
> -	}
> +	/* Don't bother if the parent process has no anon_vma here. */
> +	if (!pvma->anon_vma)
> +		return 0;
> +
> +	/*
> +	 * First, attach the new VMA to the parent VMA's anon_vmas,
> +	 * so rmap can find non-COWed pages in child processes.
> +	 */
> +	if (anon_vma_clone(vma, pvma))
> +		return -ENOMEM;
> +
> +	/* Then add our own anon_vma. */
> +	anon_vma = anon_vma_alloc();
> +	if (!anon_vma)
> +		goto out_error;
> +	avc = anon_vma_chain_alloc();
> +	if (!avc)
> +		goto out_error_free_anon_vma;

The error paths here don't undo the results of anon_vma_clone().  I
guess all those anon_vma_chains get unlinked and freed later on? 
free/exit()?

> +	anon_vma_chain_link(vma, avc, anon_vma);
> +	/* Mark this anon_vma as the one where our new (COWed) pages go. */
> +	vma->anon_vma = anon_vma;
> +
> +	return 0;
> +
> + out_error_free_anon_vma:
> +	anon_vma_free(anon_vma);
> + out_error:
> +	return -ENOMEM;
>  }
>  
>
> ...
>
> @@ -192,6 +280,9 @@ void __init anon_vma_init(void)
>  {
>  	anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
>  			0, SLAB_DESTROY_BY_RCU|SLAB_PANIC, anon_vma_ctor);
> +	anon_vma_chain_cachep = kmem_cache_create("anon_vma_chain",
> +			sizeof(struct anon_vma_chain), 0,
> +			SLAB_PANIC, NULL);

Could use KMEM_CACHE() here.

>  }
>  
>  /*
>
> ...
>

Trivial touchups:

 fs/exec.c           |    2 +-
 mm/memory-failure.c |    5 +++--
 mm/mmap.c           |    3 +--
 mm/rmap.c           |    9 +++++----
 4 files changed, 10 insertions(+), 9 deletions(-)

diff -puN fs/exec.c~mm-change-anon_vma-linking-to-fix-multi-process-server-scalability-issue-fix fs/exec.c
--- a/fs/exec.c~mm-change-anon_vma-linking-to-fix-multi-process-server-scalability-issue-fix
+++ a/fs/exec.c
@@ -549,7 +549,7 @@ static int shift_arg_pages(struct vm_are
 	tlb_finish_mmu(tlb, new_end, old_end);
 
 	/*
-	 * shrink the vma to just the new range.  always succeeds.
+	 * Shrink the vma to just the new range.  Always succeeds.
 	 */
 	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
 
diff -puN mm/memory-failure.c~mm-change-anon_vma-linking-to-fix-multi-process-server-scalability-issue-fix mm/memory-failure.c
--- a/mm/memory-failure.c~mm-change-anon_vma-linking-to-fix-multi-process-server-scalability-issue-fix
+++ a/mm/memory-failure.c
@@ -375,7 +375,6 @@ static void collect_procs_anon(struct pa
 			      struct to_kill **tkc)
 {
 	struct vm_area_struct *vma;
-	struct anon_vma_chain *vmac;
 	struct task_struct *tsk;
 	struct anon_vma *av;
 
@@ -384,9 +383,11 @@ static void collect_procs_anon(struct pa
 	if (av == NULL)	/* Not actually mapped anymore */
 		goto out;
 	for_each_process (tsk) {
+		struct anon_vma_chain *vmac;
+
 		if (!task_early_kill(tsk))
 			continue;
-		list_for_each_entry (vmac, &av->head, same_anon_vma) {
+		list_for_each_entry(vmac, &av->head, same_anon_vma) {
 			vma = vmac->vma;
 			if (!page_mapped_in_vma(page, vma))
 				continue;
diff -puN mm/mmap.c~mm-change-anon_vma-linking-to-fix-multi-process-server-scalability-issue-fix mm/mmap.c
--- a/mm/mmap.c~mm-change-anon_vma-linking-to-fix-multi-process-server-scalability-issue-fix
+++ a/mm/mmap.c
@@ -542,8 +542,7 @@ again:			remove_next = 1 + (end > next->
 	}
 
 	/*
-	 * When changing only vma->vm_end, we don't really need
-	 * anon_vma lock.
+	 * When changing only vma->vm_end, we don't really need anon_vma lock.
 	 */
 	if (vma->anon_vma && (insert || importer || start != vma->vm_start))
 		anon_vma = vma->anon_vma;
diff -puN mm/rmap.c~mm-change-anon_vma-linking-to-fix-multi-process-server-scalability-issue-fix mm/rmap.c
--- a/mm/rmap.c~mm-change-anon_vma-linking-to-fix-multi-process-server-scalability-issue-fix
+++ a/mm/rmap.c
@@ -331,17 +331,18 @@ vma_address(struct page *page, struct vm
 		/* page should be within @vma mapping range */
 		return -EFAULT;
 	}
-	if (unlikely(vma->vm_flags & VM_LOCK_RMAP))
+	if (unlikely(vma->vm_flags & VM_LOCK_RMAP)) {
 		/*
-		 * This VMA is being unlinked or not yet linked into the
+		 * This VMA is being unlinked or is not yet linked into the
 		 * VMA tree.  Do not try to follow this rmap.  This race
-		 * condition can result in page_referenced ignoring a
-		 * reference or try_to_unmap failing to unmap a page.
+		 * condition can result in page_referenced() ignoring a
+		 * reference or in try_to_unmap() failing to unmap a page.
 		 * The VMA cannot be freed under us because we hold the
 		 * anon_vma->lock, which the munmap code takes while
 		 * unlinking the anon_vmas from the VMA.
 		 */
 		return -EFAULT;
+	}
 	return address;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
