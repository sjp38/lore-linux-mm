Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7254D6B025E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 03:47:11 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b80so10495300wme.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 00:47:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dt17si25902013wjb.192.2016.10.19.00.47.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 00:47:10 -0700 (PDT)
Date: Wed, 19 Oct 2016 09:47:07 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 07/10] mm: replace get_user_pages_remote() write/force
 parameters with gup_flags
Message-ID: <20161019074707.GO29967@quack2.suse.cz>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-8-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013002020.3062-8-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Thu 13-10-16 01:20:17, Lorenzo Stoakes wrote:
> This patch removes the write and force parameters from get_user_pages_remote()
> and replaces them with a gup_flags parameter to make the use of FOLL_FORCE
> explicit in callers as use of this flag can result in surprising behaviour (and
> hence bugs) within the mm subsystem.
> 
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  drivers/gpu/drm/etnaviv/etnaviv_gem.c   |  7 +++++--
>  drivers/gpu/drm/i915/i915_gem_userptr.c |  6 +++++-
>  drivers/infiniband/core/umem_odp.c      |  7 +++++--
>  fs/exec.c                               |  9 +++++++--
>  include/linux/mm.h                      |  2 +-
>  kernel/events/uprobes.c                 |  6 ++++--
>  mm/gup.c                                | 22 +++++++---------------
>  mm/memory.c                             |  6 +++++-
>  security/tomoyo/domain.c                |  2 +-
>  9 files changed, 40 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> index 5ce3603..0370b84 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> @@ -748,19 +748,22 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
>  	int ret = 0, pinned, npages = etnaviv_obj->base.size >> PAGE_SHIFT;
>  	struct page **pvec;
>  	uintptr_t ptr;
> +	unsigned int flags = 0;
>  
>  	pvec = drm_malloc_ab(npages, sizeof(struct page *));
>  	if (!pvec)
>  		return ERR_PTR(-ENOMEM);
>  
> +	if (!etnaviv_obj->userptr.ro)
> +		flags |= FOLL_WRITE;
> +
>  	pinned = 0;
>  	ptr = etnaviv_obj->userptr.ptr;
>  
>  	down_read(&mm->mmap_sem);
>  	while (pinned < npages) {
>  		ret = get_user_pages_remote(task, mm, ptr, npages - pinned,
> -					    !etnaviv_obj->userptr.ro, 0,
> -					    pvec + pinned, NULL);
> +					    flags, pvec + pinned, NULL);
>  		if (ret < 0)
>  			break;
>  
> diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
> index e537930..c6f780f 100644
> --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> @@ -508,6 +508,10 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
>  	pvec = drm_malloc_gfp(npages, sizeof(struct page *), GFP_TEMPORARY);
>  	if (pvec != NULL) {
>  		struct mm_struct *mm = obj->userptr.mm->mm;
> +		unsigned int flags = 0;
> +
> +		if (!obj->userptr.read_only)
> +			flags |= FOLL_WRITE;
>  
>  		ret = -EFAULT;
>  		if (atomic_inc_not_zero(&mm->mm_users)) {
> @@ -517,7 +521,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
>  					(work->task, mm,
>  					 obj->userptr.ptr + pinned * PAGE_SIZE,
>  					 npages - pinned,
> -					 !obj->userptr.read_only, 0,
> +					 flags,
>  					 pvec + pinned, NULL);
>  				if (ret < 0)
>  					break;
> diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
> index 75077a0..1f0fe32 100644
> --- a/drivers/infiniband/core/umem_odp.c
> +++ b/drivers/infiniband/core/umem_odp.c
> @@ -527,6 +527,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
>  	u64 off;
>  	int j, k, ret = 0, start_idx, npages = 0;
>  	u64 base_virt_addr;
> +	unsigned int flags = 0;
>  
>  	if (access_mask == 0)
>  		return -EINVAL;
> @@ -556,6 +557,9 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
>  		goto out_put_task;
>  	}
>  
> +	if (access_mask & ODP_WRITE_ALLOWED_BIT)
> +		flags |= FOLL_WRITE;
> +
>  	start_idx = (user_virt - ib_umem_start(umem)) >> PAGE_SHIFT;
>  	k = start_idx;
>  
> @@ -574,8 +578,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
>  		 */
>  		npages = get_user_pages_remote(owning_process, owning_mm,
>  				user_virt, gup_num_pages,
> -				access_mask & ODP_WRITE_ALLOWED_BIT,
> -				0, local_page_list, NULL);
> +				flags, local_page_list, NULL);
>  		up_read(&owning_mm->mmap_sem);
>  
>  		if (npages < 0)
> diff --git a/fs/exec.c b/fs/exec.c
> index 6fcfb3f..4e497b9 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -191,6 +191,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
>  {
>  	struct page *page;
>  	int ret;
> +	unsigned int gup_flags = FOLL_FORCE;
>  
>  #ifdef CONFIG_STACK_GROWSUP
>  	if (write) {
> @@ -199,12 +200,16 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
>  			return NULL;
>  	}
>  #endif
> +
> +	if (write)
> +		gup_flags |= FOLL_WRITE;
> +
>  	/*
>  	 * We are doing an exec().  'current' is the process
>  	 * doing the exec and bprm->mm is the new process's mm.
>  	 */
> -	ret = get_user_pages_remote(current, bprm->mm, pos, 1, write,
> -			1, &page, NULL);
> +	ret = get_user_pages_remote(current, bprm->mm, pos, 1, gup_flags,
> +			&page, NULL);
>  	if (ret <= 0)
>  		return NULL;
>  
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 686a477..2a481d3 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1276,7 +1276,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		      struct vm_area_struct **vmas, int *nonblocking);
>  long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
>  			    unsigned long start, unsigned long nr_pages,
> -			    int write, int force, struct page **pages,
> +			    unsigned int gup_flags, struct page **pages,
>  			    struct vm_area_struct **vmas);
>  long get_user_pages(unsigned long start, unsigned long nr_pages,
>  			    unsigned int gup_flags, struct page **pages,
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index d4129bb..f9ec9ad 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -300,7 +300,8 @@ int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr,
>  
>  retry:
>  	/* Read the page with vaddr into memory */
> -	ret = get_user_pages_remote(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
> +	ret = get_user_pages_remote(NULL, mm, vaddr, 1, FOLL_FORCE, &old_page,
> +			&vma);
>  	if (ret <= 0)
>  		return ret;
>  
> @@ -1710,7 +1711,8 @@ static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr)
>  	 * but we treat this as a 'remote' access since it is
>  	 * essentially a kernel access to the memory.
>  	 */
> -	result = get_user_pages_remote(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
> +	result = get_user_pages_remote(NULL, mm, vaddr, 1, FOLL_FORCE, &page,
> +			NULL);
>  	if (result < 0)
>  		return result;
>  
> diff --git a/mm/gup.c b/mm/gup.c
> index dc91303..0deecf3 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -905,9 +905,7 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
>   * @mm:		mm_struct of target mm
>   * @start:	starting user address
>   * @nr_pages:	number of pages from start to pin
> - * @write:	whether pages will be written to by the caller
> - * @force:	whether to force access even when user mapping is currently
> - *		protected (but never forces write access to shared mapping).
> + * @gup_flags:	flags modifying lookup behaviour
>   * @pages:	array that receives pointers to the pages pinned.
>   *		Should be at least nr_pages long. Or NULL, if caller
>   *		only intends to ensure the pages are faulted in.
> @@ -936,9 +934,9 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
>   * or similar operation cannot guarantee anything stronger anyway because
>   * locks can't be held over the syscall boundary.
>   *
> - * If write=0, the page must not be written to. If the page is written to,
> - * set_page_dirty (or set_page_dirty_lock, as appropriate) must be called
> - * after the page is finished with, and before put_page is called.
> + * If gup_flags & FOLL_WRITE == 0, the page must not be written to. If the page
> + * is written to, set_page_dirty (or set_page_dirty_lock, as appropriate) must
> + * be called after the page is finished with, and before put_page is called.
>   *
>   * get_user_pages is typically used for fewer-copy IO operations, to get a
>   * handle on the memory by some means other than accesses via the user virtual
> @@ -955,18 +953,12 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
>   */
>  long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
>  		unsigned long start, unsigned long nr_pages,
> -		int write, int force, struct page **pages,
> +		unsigned int gup_flags, struct page **pages,
>  		struct vm_area_struct **vmas)
>  {
> -	unsigned int flags = FOLL_TOUCH | FOLL_REMOTE;
> -
> -	if (write)
> -		flags |= FOLL_WRITE;
> -	if (force)
> -		flags |= FOLL_FORCE;
> -
>  	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
> -				       NULL, false, flags);
> +				       NULL, false,
> +				       gup_flags | FOLL_TOUCH | FOLL_REMOTE);
>  }
>  EXPORT_SYMBOL(get_user_pages_remote);
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index fc1987d..20a9adb 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3873,6 +3873,10 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
>  {
>  	struct vm_area_struct *vma;
>  	void *old_buf = buf;
> +	unsigned int flags = FOLL_FORCE;
> +
> +	if (write)
> +		flags |= FOLL_WRITE;
>  
>  	down_read(&mm->mmap_sem);
>  	/* ignore errors, just check how much was successfully transferred */
> @@ -3882,7 +3886,7 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
>  		struct page *page = NULL;
>  
>  		ret = get_user_pages_remote(tsk, mm, addr, 1,
> -				write, 1, &page, &vma);
> +				flags, &page, &vma);
>  		if (ret <= 0) {
>  #ifndef CONFIG_HAVE_IOREMAP_PROT
>  			break;
> diff --git a/security/tomoyo/domain.c b/security/tomoyo/domain.c
> index ade7c6c..682b73a 100644
> --- a/security/tomoyo/domain.c
> +++ b/security/tomoyo/domain.c
> @@ -881,7 +881,7 @@ bool tomoyo_dump_page(struct linux_binprm *bprm, unsigned long pos,
>  	 * the execve().
>  	 */
>  	if (get_user_pages_remote(current, bprm->mm, pos, 1,
> -				0, 1, &page, NULL) <= 0)
> +				FOLL_FORCE, &page, NULL) <= 0)
>  		return false;
>  #else
>  	page = bprm->page[pos / PAGE_SIZE];
> -- 
> 2.10.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
