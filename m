Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C2B356B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 17:40:03 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so1584337pdj.4
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 14:40:03 -0700 (PDT)
Date: Wed, 16 Oct 2013 23:39:56 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 23/26] ib: Convert qib_get_user_pages() to
 get_user_pages_unlocked()
Message-ID: <20131016213956.GA4595@quack.suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-24-git-send-email-jack@suse.cz>
 <32E1700B9017364D9B60AED9960492BC211B0176@FMSMSX107.amr.corp.intel.com>
 <20131004183315.GA19557@quack.suse.cz>
 <32E1700B9017364D9B60AED9960492BC211B07B7@FMSMSX107.amr.corp.intel.com>
 <20131007172604.GD30441@quack.suse.cz>
 <20131008190604.GB14223@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131008190604.GB14223@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Marciniszyn, Mike" <mike.marciniszyn@intel.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, infinipath <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>

On Tue 08-10-13 21:06:04, Jan Kara wrote:
> On Mon 07-10-13 19:26:04, Jan Kara wrote:
> > On Mon 07-10-13 15:38:24, Marciniszyn, Mike wrote:
> > > > > This patch and the sibling ipath patch will nominally take the mmap_sem
> > > > > twice where the old routine only took it once.   This is a performance
> > > > > issue.
> > > >   It will take mmap_sem only once during normal operation. Only if
> > > > get_user_pages_unlocked() fail, we have to take mmap_sem again to undo
> > > > the change of mm->pinned_vm.
> > > > 
> > > > > Is the intent here to deprecate get_user_pages()?
> > > 
> > > The old code looked like:
> > > __qib_get_user_pages()
> > > 	(broken) ulimit test
> > >              for (...)
> > > 		get_user_pages()
> > > 
> > > qib_get_user_pages()
> > > 	mmap_sem lock
> > > 	__qib_get_user_pages()
> > >              mmap_sem() unlock
> > > 
> > > The new code is:
> > > 
> > > get_user_pages_unlocked()
> > > 	mmap_sem  lock
> > > 	get_user_pages()
> > > 	mmap_sem unlock
> > > 
> > > qib_get_user_pages()
> > > 	mmap_sem lock
> > >              ulimit test and locked pages maintenance
> > >              mmap_sem unlock
> > > 	for (...)
> > > 		get_user_pages_unlocked()
> > > 
> > > I count an additional pair of mmap_sem transactions in the normal case.
> >   Ah, sorry, you are right.
> > 
> > > > > Could the lock limit test be pushed into another version of the
> > > > > wrapper so that there is only one set of mmap_sem transactions?
> > > >   I'm sorry, I don't understand what you mean here...
> > > > 
> > > 
> > > This is what I had in mind:
> > > 
> > > get_user_pages_ulimit_unlocked()
> > > 	mmap_sem  lock
> > > 	ulimit test and locked pages maintenance (from qib/ipath)
> > >              for (...)
> > > 	       get_user_pages_unlocked()	
> > > 	mmap_sem unlock
> > > 	
> > > qib_get_user_pages()
> > > 	get_user_pages_ulimit_unlocked()
> > > 
> > > This really pushes the code into a new wrapper common to ipath/qib and
> > > any others that might want to combine locking with ulimit enforcement.
> >   We could do that but frankly, I'd rather change ulimit enforcement to not
> > require mmap_sem and use atomic counter instead. I'll see what I can do.
>   OK, so something like the attached patch (compile tested only). What do
> you think? I'm just not 100% sure removing mmap_sem surrounding stuff like
> __ipath_release_user_pages() is safe. I don't see a reason why it shouldn't
> be - we have references to the pages and we only mark them dirty and put the
> reference - but maybe I miss something subtle...
  Ping? Any opinion on this?

								Honza

> From 44fe90e8303b293370f077ae665d6e43846cf277 Mon Sep 17 00:00:00 2001
> From: Jan Kara <jack@suse.cz>
> Date: Tue, 8 Oct 2013 14:16:24 +0200
> Subject: [PATCH] mm: Switch mm->pinned_vm to atomic_long_t
> 
> Currently updates to mm->pinned_vm were protected by mmap_sem.
> kernel/events/core.c actually held it only for reading so that may have
> been racy. The only other user - Infiniband - used mmap_sem for writing
> but it caused quite some complications to it.
> 
> So switch mm->pinned_vm and convert all the places using it. This allows
> quite some simplifications to Infiniband code and it now doesn't have to
> care about mmap_sem at all.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  drivers/infiniband/core/umem.c                 | 56 +++------------------
>  drivers/infiniband/core/uverbs_cmd.c           |  1 -
>  drivers/infiniband/core/uverbs_main.c          |  2 -
>  drivers/infiniband/hw/ipath/ipath_file_ops.c   |  2 +-
>  drivers/infiniband/hw/ipath/ipath_kernel.h     |  1 -
>  drivers/infiniband/hw/ipath/ipath_user_pages.c | 70 +++-----------------------
>  drivers/infiniband/hw/qib/qib_user_pages.c     | 20 ++------
>  fs/proc/task_mmu.c                             |  2 +-
>  include/linux/mm_types.h                       |  2 +-
>  include/rdma/ib_umem.h                         |  3 --
>  include/rdma/ib_verbs.h                        |  1 -
>  kernel/events/core.c                           | 13 +++--
>  12 files changed, 29 insertions(+), 144 deletions(-)
> 
> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
> index 0640a89021a9..294d2e468177 100644
> --- a/drivers/infiniband/core/umem.c
> +++ b/drivers/infiniband/core/umem.c
> @@ -80,6 +80,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
>  {
>  	struct ib_umem *umem;
>  	struct page **page_list;
> +	struct mm_struct *mm = current->mm;
>  	struct ib_umem_chunk *chunk;
>  	unsigned long locked;
>  	unsigned long lock_limit;
> @@ -126,20 +127,13 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
>  
>  	npages = PAGE_ALIGN(size + umem->offset) >> PAGE_SHIFT;
>  
> -	down_write(&current->mm->mmap_sem);
> -
>  	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>  	locked = npages;
> -	if (npages + current->mm->pinned_vm > lock_limit &&
> +	if (atomic_long_add_return(&mm->pinned_vm, npages) > lock_limit &&
>  	    !capable(CAP_IPC_LOCK)) {
> -		up_write(&current->mm->mmap_sem);
> -		kfree(umem);
> -		free_page((unsigned long) page_list);
> -		return ERR_PTR(-ENOMEM);
> +		ret = -ENOMEM;
> +		goto out;
>  	}
> -	current->mm->pinned_vm += npages;
> -
> -	up_write(&current->mm->mmap_sem);
>  
>  	cur_base = addr & PAGE_MASK;
>  
> @@ -201,9 +195,7 @@ out:
>  	if (ret < 0) {
>  		__ib_umem_release(context->device, umem, 0);
>  		kfree(umem);
> -		down_write(&current->mm->mmap_sem);
> -		current->mm->pinned_vm -= locked;
> -		up_write(&current->mm->mmap_sem);
> +		atomic_long_sub(&mm->pinned_vm, locked);
>  	}
>  	free_page((unsigned long) page_list);
>  
> @@ -211,17 +203,6 @@ out:
>  }
>  EXPORT_SYMBOL(ib_umem_get);
>  
> -static void ib_umem_account(struct work_struct *work)
> -{
> -	struct ib_umem *umem = container_of(work, struct ib_umem, work);
> -
> -	down_write(&umem->mm->mmap_sem);
> -	umem->mm->pinned_vm -= umem->diff;
> -	up_write(&umem->mm->mmap_sem);
> -	mmput(umem->mm);
> -	kfree(umem);
> -}
> -
>  /**
>   * ib_umem_release - release memory pinned with ib_umem_get
>   * @umem: umem struct to release
> @@ -234,37 +215,14 @@ void ib_umem_release(struct ib_umem *umem)
>  
>  	__ib_umem_release(umem->context->device, umem, 1);
>  
> -	mm = get_task_mm(current);
> +	mm = current->mm;
>  	if (!mm) {
>  		kfree(umem);
>  		return;
>  	}
>  
>  	diff = PAGE_ALIGN(umem->length + umem->offset) >> PAGE_SHIFT;
> -
> -	/*
> -	 * We may be called with the mm's mmap_sem already held.  This
> -	 * can happen when a userspace munmap() is the call that drops
> -	 * the last reference to our file and calls our release
> -	 * method.  If there are memory regions to destroy, we'll end
> -	 * up here and not be able to take the mmap_sem.  In that case
> -	 * we defer the vm_locked accounting to the system workqueue.
> -	 */
> -	if (context->closing) {
> -		if (!down_write_trylock(&mm->mmap_sem)) {
> -			INIT_WORK(&umem->work, ib_umem_account);
> -			umem->mm   = mm;
> -			umem->diff = diff;
> -
> -			queue_work(ib_wq, &umem->work);
> -			return;
> -		}
> -	} else
> -		down_write(&mm->mmap_sem);
> -
> -	current->mm->pinned_vm -= diff;
> -	up_write(&mm->mmap_sem);
> -	mmput(mm);
> +	atomic_long_sub(&mm->pinned_vm, diff);
>  	kfree(umem);
>  }
>  EXPORT_SYMBOL(ib_umem_release);
> diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
> index f2b81b9ee0d6..16381c6eae77 100644
> --- a/drivers/infiniband/core/uverbs_cmd.c
> +++ b/drivers/infiniband/core/uverbs_cmd.c
> @@ -332,7 +332,6 @@ ssize_t ib_uverbs_get_context(struct ib_uverbs_file *file,
>  	INIT_LIST_HEAD(&ucontext->ah_list);
>  	INIT_LIST_HEAD(&ucontext->xrcd_list);
>  	INIT_LIST_HEAD(&ucontext->rule_list);
> -	ucontext->closing = 0;
>  
>  	resp.num_comp_vectors = file->device->num_comp_vectors;
>  
> diff --git a/drivers/infiniband/core/uverbs_main.c b/drivers/infiniband/core/uverbs_main.c
> index 75ad86c4abf8..8fdc9ca62c27 100644
> --- a/drivers/infiniband/core/uverbs_main.c
> +++ b/drivers/infiniband/core/uverbs_main.c
> @@ -196,8 +196,6 @@ static int ib_uverbs_cleanup_ucontext(struct ib_uverbs_file *file,
>  	if (!context)
>  		return 0;
>  
> -	context->closing = 1;
> -
>  	list_for_each_entry_safe(uobj, tmp, &context->ah_list, list) {
>  		struct ib_ah *ah = uobj->object;
>  
> diff --git a/drivers/infiniband/hw/ipath/ipath_file_ops.c b/drivers/infiniband/hw/ipath/ipath_file_ops.c
> index 6d7f453b4d05..f219f15ad1cf 100644
> --- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
> +++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
> @@ -2025,7 +2025,7 @@ static void unlock_expected_tids(struct ipath_portdata *pd)
>  		dd->ipath_pageshadow[i] = NULL;
>  		pci_unmap_page(dd->pcidev, dd->ipath_physshadow[i],
>  			PAGE_SIZE, PCI_DMA_FROMDEVICE);
> -		ipath_release_user_pages_on_close(&ps, 1);
> +		ipath_release_user_pages(&ps, 1);
>  		cnt++;
>  		ipath_stats.sps_pageunlocks++;
>  	}
> diff --git a/drivers/infiniband/hw/ipath/ipath_kernel.h b/drivers/infiniband/hw/ipath/ipath_kernel.h
> index 6559af60bffd..afc2f868541b 100644
> --- a/drivers/infiniband/hw/ipath/ipath_kernel.h
> +++ b/drivers/infiniband/hw/ipath/ipath_kernel.h
> @@ -1083,7 +1083,6 @@ static inline void ipath_sdma_desc_unreserve(struct ipath_devdata *dd, u16 cnt)
>  
>  int ipath_get_user_pages(unsigned long, size_t, struct page **);
>  void ipath_release_user_pages(struct page **, size_t);
> -void ipath_release_user_pages_on_close(struct page **, size_t);
>  int ipath_eeprom_read(struct ipath_devdata *, u8, void *, int);
>  int ipath_eeprom_write(struct ipath_devdata *, u8, const void *, int);
>  int ipath_tempsense_read(struct ipath_devdata *, u8 regnum);
> diff --git a/drivers/infiniband/hw/ipath/ipath_user_pages.c b/drivers/infiniband/hw/ipath/ipath_user_pages.c
> index a89af9654112..8081e76fa72c 100644
> --- a/drivers/infiniband/hw/ipath/ipath_user_pages.c
> +++ b/drivers/infiniband/hw/ipath/ipath_user_pages.c
> @@ -68,26 +68,22 @@ int ipath_get_user_pages(unsigned long start_page, size_t num_pages,
>  			 struct page **p)
>  {
>  	unsigned long lock_limit;
> +	struct mm_struct *mm = current->mm;
>  	size_t got;
>  	int ret;
>  
> -	down_write(&current->mm->mmap_sem);
>  	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> -
> -	if (current->mm->pinned_vm + num_pages > lock_limit && 
> +	if (atomic_long_add_return(&mm->pinned_vm, num_pages) > lock_limit &&
>  	    !capable(CAP_IPC_LOCK)) {
> -		up_write(&current->mm->mmap_sem);
>  		ret = -ENOMEM;
> -		goto bail;
> +		goto bail_sub;
>  	}
> -	current->mm->pinned_vm += num_pages;
> -	up_write(&current->mm->mmap_sem);
>  
>  	ipath_cdbg(VERBOSE, "pin %lx pages from vaddr %lx\n",
>  		   (unsigned long) num_pages, start_page);
>  
>  	for (got = 0; got < num_pages; got += ret) {
> -		ret = get_user_pages_unlocked(current, current->mm,
> +		ret = get_user_pages_unlocked(current, mm,
>  					      start_page + got * PAGE_SIZE,
>  					      num_pages - got, 1, 1,
>  					      p + got);
> @@ -101,9 +97,8 @@ int ipath_get_user_pages(unsigned long start_page, size_t num_pages,
>  
>  bail_release:
>  	__ipath_release_user_pages(p, got, 0);
> -	down_write(&current->mm->mmap_sem);
> -	current->mm->pinned_vm -= num_pages;
> -	up_write(&current->mm->mmap_sem);
> +bail_sub:
> +	atomic_long_sub(&mm->pinned_vm, num_pages);
>  bail:
>  	return ret;
>  }
> @@ -166,56 +161,7 @@ dma_addr_t ipath_map_single(struct pci_dev *hwdev, void *ptr, size_t size,
>  
>  void ipath_release_user_pages(struct page **p, size_t num_pages)
>  {
> -	down_write(&current->mm->mmap_sem);
> -
> -	__ipath_release_user_pages(p, num_pages, 1);
> -
> -	current->mm->pinned_vm -= num_pages;
> -
> -	up_write(&current->mm->mmap_sem);
> -}
> -
> -struct ipath_user_pages_work {
> -	struct work_struct work;
> -	struct mm_struct *mm;
> -	unsigned long num_pages;
> -};
> -
> -static void user_pages_account(struct work_struct *_work)
> -{
> -	struct ipath_user_pages_work *work =
> -		container_of(_work, struct ipath_user_pages_work, work);
> -
> -	down_write(&work->mm->mmap_sem);
> -	work->mm->pinned_vm -= work->num_pages;
> -	up_write(&work->mm->mmap_sem);
> -	mmput(work->mm);
> -	kfree(work);
> -}
> -
> -void ipath_release_user_pages_on_close(struct page **p, size_t num_pages)
> -{
> -	struct ipath_user_pages_work *work;
> -	struct mm_struct *mm;
> -
>  	__ipath_release_user_pages(p, num_pages, 1);
> -
> -	mm = get_task_mm(current);
> -	if (!mm)
> -		return;
> -
> -	work = kmalloc(sizeof(*work), GFP_KERNEL);
> -	if (!work)
> -		goto bail_mm;
> -
> -	INIT_WORK(&work->work, user_pages_account);
> -	work->mm = mm;
> -	work->num_pages = num_pages;
> -
> -	queue_work(ib_wq, &work->work);
> -	return;
> -
> -bail_mm:
> -	mmput(mm);
> -	return;
> +	if (current->mm)
> +		atomic_long_sub(&current->mm->pinned_vm, num_pages);
>  }
> diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
> index 57ce83c2d1d9..049ab8db5f32 100644
> --- a/drivers/infiniband/hw/qib/qib_user_pages.c
> +++ b/drivers/infiniband/hw/qib/qib_user_pages.c
> @@ -68,16 +68,13 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
>  	int ret;
>  	struct mm_struct *mm = current->mm;
>  
> -	down_write(&mm->mmap_sem);
>  	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>  
> -	if (mm->pinned_vm + num_pages > lock_limit && !capable(CAP_IPC_LOCK)) {
> -		up_write(&mm->mmap_sem);
> +	if (atomic_long_add_return(&mm->pinned_vm, num_pages) > lock_limit &&
> +	    !capable(CAP_IPC_LOCK)) {
>  		ret = -ENOMEM;
>  		goto bail;
>  	}
> -	mm->pinned_vm += num_pages;
> -	up_write(&mm->mmap_sem);
>  
>  	for (got = 0; got < num_pages; got += ret) {
>  		ret = get_user_pages_unlocked(current, mm,
> @@ -94,9 +91,7 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
>  
>  bail_release:
>  	__qib_release_user_pages(p, got, 0);
> -	down_write(&mm->mmap_sem);
> -	mm->pinned_vm -= num_pages;
> -	up_write(&mm->mmap_sem);
> +	atomic_long_sub(&mm->pinned_vm, num_pages);
>  bail:
>  	return ret;
>  }
> @@ -135,13 +130,8 @@ dma_addr_t qib_map_page(struct pci_dev *hwdev, struct page *page,
>  
>  void qib_release_user_pages(struct page **p, size_t num_pages)
>  {
> -	if (current->mm) /* during close after signal, mm can be NULL */
> -		down_write(&current->mm->mmap_sem);
> -
>  	__qib_release_user_pages(p, num_pages, 1);
>  
> -	if (current->mm) {
> -		current->mm->pinned_vm -= num_pages;
> -		up_write(&current->mm->mmap_sem);
> -	}
> +	if (current->mm)
> +		atomic_long_sub(&current->mm->pinned_vm, num_pages);
>  }
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 7366e9d63cee..9123bfef1dea 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -57,7 +57,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  		hiwater_vm << (PAGE_SHIFT-10),
>  		total_vm << (PAGE_SHIFT-10),
>  		mm->locked_vm << (PAGE_SHIFT-10),
> -		mm->pinned_vm << (PAGE_SHIFT-10),
> +		atomic_long_read(&mm->pinned_vm) << (PAGE_SHIFT-10),
>  		hiwater_rss << (PAGE_SHIFT-10),
>  		total_rss << (PAGE_SHIFT-10),
>  		data << (PAGE_SHIFT-10),
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index d9851eeb6e1d..f2bf72a86b70 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -355,7 +355,7 @@ struct mm_struct {
>  
>  	unsigned long total_vm;		/* Total pages mapped */
>  	unsigned long locked_vm;	/* Pages that have PG_mlocked set */
> -	unsigned long pinned_vm;	/* Refcount permanently increased */
> +	atomic_long_t pinned_vm;	/* Refcount permanently increased */
>  	unsigned long shared_vm;	/* Shared pages (files) */
>  	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
>  	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
> diff --git a/include/rdma/ib_umem.h b/include/rdma/ib_umem.h
> index 9ee0d2e51b16..2dbbd2c56074 100644
> --- a/include/rdma/ib_umem.h
> +++ b/include/rdma/ib_umem.h
> @@ -47,9 +47,6 @@ struct ib_umem {
>  	int                     writable;
>  	int                     hugetlb;
>  	struct list_head	chunk_list;
> -	struct work_struct	work;
> -	struct mm_struct       *mm;
> -	unsigned long		diff;
>  };
>  
>  struct ib_umem_chunk {
> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index e393171e2fac..bce6d2b91ec7 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -961,7 +961,6 @@ struct ib_ucontext {
>  	struct list_head	ah_list;
>  	struct list_head	xrcd_list;
>  	struct list_head	rule_list;
> -	int			closing;
>  };
>  
>  struct ib_uobject {
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index dd236b66ca3a..80d2ba7bd51c 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -3922,7 +3922,7 @@ again:
>  	 */
>  
>  	atomic_long_sub((size >> PAGE_SHIFT) + 1, &mmap_user->locked_vm);
> -	vma->vm_mm->pinned_vm -= mmap_locked;
> +	atomic_long_sub(&vma->vm_mm->pinned_vm, mmap_locked);
>  	free_uid(mmap_user);
>  
>  	ring_buffer_put(rb); /* could be last */
> @@ -3944,7 +3944,7 @@ static int perf_mmap(struct file *file, struct vm_area_struct *vma)
>  	struct ring_buffer *rb;
>  	unsigned long vma_size;
>  	unsigned long nr_pages;
> -	long user_extra, extra;
> +	long user_extra, extra = 0;
>  	int ret = 0, flags = 0;
>  
>  	/*
> @@ -4006,16 +4006,14 @@ again:
>  
>  	user_locked = atomic_long_read(&user->locked_vm) + user_extra;
>  
> -	extra = 0;
>  	if (user_locked > user_lock_limit)
>  		extra = user_locked - user_lock_limit;
>  
>  	lock_limit = rlimit(RLIMIT_MEMLOCK);
>  	lock_limit >>= PAGE_SHIFT;
> -	locked = vma->vm_mm->pinned_vm + extra;
>  
> -	if ((locked > lock_limit) && perf_paranoid_tracepoint_raw() &&
> -		!capable(CAP_IPC_LOCK)) {
> +	if (atomic_long_add_return(&vma->vm_mm->pinned_vm, extra) > lock_limit &&
> +	    perf_paranoid_tracepoint_raw() && !capable(CAP_IPC_LOCK)) {
>  		ret = -EPERM;
>  		goto unlock;
>  	}
> @@ -4039,7 +4037,6 @@ again:
>  	rb->mmap_user = get_current_user();
>  
>  	atomic_long_add(user_extra, &user->locked_vm);
> -	vma->vm_mm->pinned_vm += extra;
>  
>  	ring_buffer_attach(event, rb);
>  	rcu_assign_pointer(event->rb, rb);
> @@ -4049,6 +4046,8 @@ again:
>  unlock:
>  	if (!ret)
>  		atomic_inc(&event->mmap_count);
> +	else if (extra)
> +		atomic_long_sub(&vma->vm_mm->pinned_vm, extra);
>  	mutex_unlock(&event->mmap_mutex);
>  
>  	/*
> -- 
> 1.8.1.4
> 

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
