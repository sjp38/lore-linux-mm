Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA1F6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 09:05:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b79so10233650pfk.9
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 06:05:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j11si750872pff.591.2017.10.20.06.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 06:05:30 -0700 (PDT)
Message-ID: <1508504726.5572.41.camel@kernel.org>
Subject: Re: [PATCH v3 12/13] dax: handle truncate of dma-busy pages
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Oct 2017 09:05:26 -0400
In-Reply-To: <150846720244.24336.16885325309403883980.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <150846720244.24336.16885325309403883980.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-xfs@vger.kernel.org, hch@lst.de, linux-nvdimm@lists.01.org

On Thu, 2017-10-19 at 19:40 -0700, Dan Williams wrote:
> get_user_pages() pins file backed memory pages for access by dma
> devices. However, it only pins the memory pages not the page-to-file
> offset association. If a file is truncated the pages are mapped out of
> the file and dma may continue indefinitely into a page that is owned by
> a device driver. This breaks coherency of the file vs dma, but the
> assumption is that if userspace wants the file-space truncated it does
> not matter what data is inbound from the device, it is not relevant
> anymore.
> 
> The assumptions of the truncate-page-cache model are broken by DAX where
> the target DMA page *is* the filesystem block. Leaving the page pinned
> for DMA, but truncating the file block out of the file, means that the
> filesytem is free to reallocate a block under active DMA to another
> file!
> 
> Here are some possible options for fixing this situation ('truncate' and
> 'fallocate(punch hole)' are synonymous below):
> 
>     1/ Fail truncate while any file blocks might be under dma
> 
>     2/ Block (sleep-wait) truncate while any file blocks might be under
>        dma
> 
>     3/ Remap file blocks to a "lost+found"-like file-inode where
>        dma can continue and we might see what inbound data from DMA was
>        mapped out of the original file. Blocks in this file could be
>        freed back to the filesystem when dma eventually ends.
> 
>     4/ Disable dax until option 3 or another long term solution has been
>        implemented. However, filesystem-dax is still marked experimental
>        for concerns like this.
> 
> Option 1 will throw failures where userspace has never expected them
> before, option 2 might hang the truncating process indefinitely, and
> option 3 requires per filesystem enabling to remap blocks from one inode
> to another.  Option 2 is implemented in this patch for the DAX path with
> the expectation that non-transient users of get_user_pages() (RDMA) are
> disallowed from setting up dax mappings and that the potential delay
> introduced to the truncate path is acceptable compared to the response
> time of the page cache case. This can only be seen as a stop-gap until
> we can solve the problem of safely sequestering unallocated filesystem
> blocks under active dma.
> 

FWIW, I like #3 a lot more than #2 here. I get that it's quite a bit
more work though, so no objection to this as a stop-gap fix.


> The solution introduces a new FL_ALLOCATED lease to pin the allocated
> blocks in a dax file while dma might be accessing them. It behaves
> identically to an FL_LAYOUT lease save for the fact that it is
> immediately sheduled to be reaped, and that the only path that waits for
> its removal is the truncate path. We can not reuse FL_LAYOUT directly
> since that would deadlock in the case where userspace did a direct-I/O
> operation with a target buffer backed by an mmap range of the same file.
> 
> Credit / inspiration for option 3 goes to Dave Hansen, who proposed
> something similar as an alternative way to solve the problem that
> MAP_DIRECT was trying to solve.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Jeff Layton <jlayton@poochiereds.net>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Reported-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  fs/Kconfig          |    1 
>  fs/dax.c            |  188 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/locks.c          |   17 ++++-
>  include/linux/dax.h |   23 ++++++
>  include/linux/fs.h  |   22 +++++-
>  mm/gup.c            |   27 ++++++-
>  6 files changed, 268 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 7aee6d699fd6..a7b31a96a753 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -37,6 +37,7 @@ source "fs/f2fs/Kconfig"
>  config FS_DAX
>  	bool "Direct Access (DAX) support"
>  	depends on MMU
> +	depends on FILE_LOCKING
>  	depends on !(ARM || MIPS || SPARC)
>  	select FS_IOMAP
>  	select DAX
> diff --git a/fs/dax.c b/fs/dax.c
> index b03f547b36e7..e0a3958fc5f2 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -22,6 +22,7 @@
>  #include <linux/genhd.h>
>  #include <linux/highmem.h>
>  #include <linux/memcontrol.h>
> +#include <linux/file.h>
>  #include <linux/mm.h>
>  #include <linux/mutex.h>
>  #include <linux/pagevec.h>
> @@ -1481,3 +1482,190 @@ int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
>  	}
>  }
>  EXPORT_SYMBOL_GPL(dax_iomap_fault);
> +
> +enum dax_lease_flags {
> +	DAX_LEASE_PAGES,
> +	DAX_LEASE_BREAK,
> +};
> +
> +struct dax_lease {
> +	struct page **dl_pages;
> +	unsigned long dl_nr_pages;
> +	unsigned long dl_state;
> +	struct file *dl_file;
> +	atomic_t dl_count;
> +	/*
> +	 * Once the lease is taken and the pages have references we
> +	 * start the reap_work to poll for lease release while acquiring
> +	 * fs locks that synchronize with truncate. So, either reap_work
> +	 * cleans up the dax_lease instances or truncate itself.
> +	 *
> +	 * The break_work sleepily polls for DMA completion and then
> +	 * unlocks/removes the lease.
> +	 */
> +	struct delayed_work dl_reap_work;
> +	struct delayed_work dl_break_work;
> +};
> +
> +static void put_dax_lease(struct dax_lease *dl)
> +{
> +	if (atomic_dec_and_test(&dl->dl_count)) {
> +		fput(dl->dl_file);
> +		kfree(dl);
> +	}
> +}

Any reason not to use the new refcount_t type for dl_count? Seems like a
good place for it.

> +
> +static void dax_lease_unlock_one(struct work_struct *work)
> +{
> +	struct dax_lease *dl = container_of(work, typeof(*dl),
> +			dl_break_work.work);
> +	unsigned long i;
> +
> +	/* wait for the gup path to finish recording pages in the lease */
> +	if (!test_bit(DAX_LEASE_PAGES, &dl->dl_state)) {
> +		schedule_delayed_work(&dl->dl_break_work, HZ);
> +		return;
> +	}
> +
> +	/* barrier pairs with dax_lease_set_pages() */
> +	smp_mb__after_atomic();
> +
> +	/*
> +	 * If we see all pages idle at least once we can remove the
> +	 * lease. If we happen to race with someone else taking a
> +	 * reference on a page they will have their own lease to protect
> +	 * against truncate.
> +	 */
> +	for (i = 0; i < dl->dl_nr_pages; i++)
> +		if (page_ref_count(dl->dl_pages[i]) > 1) {
> +			schedule_delayed_work(&dl->dl_break_work, HZ);
> +			return;
> +		}
> +	vfs_setlease(dl->dl_file, F_UNLCK, NULL, (void **) &dl);
> +	put_dax_lease(dl);
> +}
> +
> +static void dax_lease_reap_all(struct work_struct *work)
> +{
> +	struct dax_lease *dl = container_of(work, typeof(*dl),
> +			dl_reap_work.work);
> +	struct file *file = dl->dl_file;
> +	struct inode *inode = file_inode(file);
> +	struct address_space *mapping = inode->i_mapping;
> +
> +	if (mapping->a_ops->dax_flush_dma) {
> +		mapping->a_ops->dax_flush_dma(inode);
> +	} else {
> +		/* FIXME: dax-filesystem needs to add dax-dma support */
> +		break_allocated(inode, true);
> +	}
> +	put_dax_lease(dl);
> +}
> +
> +static bool dax_lease_lm_break(struct file_lock *fl)
> +{
> +	struct dax_lease *dl = fl->fl_owner;
> +
> +	if (!test_and_set_bit(DAX_LEASE_BREAK, &dl->dl_state)) {
> +		atomic_inc(&dl->dl_count);
> +		schedule_delayed_work(&dl->dl_break_work, HZ);
> +	}
> +

I haven't gone over this completely, but what prevents you from doing a
0->1 transition on the dl_count here, and possibly doing a use-after
free?

Ahh ok...I guess we know that we hold a reference since this is on the
flc_lease list? Fair enough. Still, might be worth a comment there as to
why that's safe.


> +	/* Tell the core lease code to wait for delayed work completion */
> +	fl->fl_break_time = 0;
> +
> +	return false;
> +}
> +
> +static int dax_lease_lm_change(struct file_lock *fl, int arg,
> +		struct list_head *dispose)
> +{
> +	struct dax_lease *dl;
> +	int rc;
> +
> +	WARN_ON(!(arg & F_UNLCK));
> +	dl = fl->fl_owner;
> +	rc = lease_modify(fl, arg, dispose);
> +	put_dax_lease(dl);
> +	return rc;
> +}
> +
> +static const struct lock_manager_operations dax_lease_lm_ops = {
> +	.lm_break = dax_lease_lm_break,
> +	.lm_change = dax_lease_lm_change,
> +};
> +
> +struct dax_lease *__dax_truncate_lease(struct vm_area_struct *vma,
> +		long nr_pages)
> +{
> +	struct file *file = vma->vm_file;
> +	struct inode *inode = file_inode(file);
> +	struct dax_lease *dl;
> +	struct file_lock *fl;
> +	int rc = -ENOMEM;
> +
> +	if (!vma_is_dax(vma))
> +		return NULL;
> +
> +	/* device-dax can not be truncated */
> +	if (!S_ISREG(inode->i_mode))
> +		return NULL;
> +
> +	dl = kzalloc(sizeof(*dl) + sizeof(struct page *) * nr_pages, GFP_KERNEL);
> +	if (!dl)
> +		return ERR_PTR(-ENOMEM);
> +
> +	fl = locks_alloc_lock();
> +	if (!fl)
> +		goto err_lock_alloc;
> +
> +	dl->dl_pages = (struct page **)(dl + 1);
> +	INIT_DELAYED_WORK(&dl->dl_break_work, dax_lease_unlock_one);
> +	INIT_DELAYED_WORK(&dl->dl_reap_work, dax_lease_reap_all);
> +	dl->dl_file = get_file(file);
> +	/* need dl alive until dax_lease_set_pages() and final put */
> +	atomic_set(&dl->dl_count, 2);
> +
> +	locks_init_lock(fl);
> +	fl->fl_lmops = &dax_lease_lm_ops;
> +	fl->fl_flags = FL_ALLOCATED;
> +	fl->fl_type = F_RDLCK;
> +	fl->fl_end = OFFSET_MAX;
> +	fl->fl_owner = dl;
> +	fl->fl_pid = current->tgid;
> +	fl->fl_file = file;
> +
> +	rc = vfs_setlease(fl->fl_file, fl->fl_type, &fl, (void **) &dl);
> +	if (rc)
> +		goto err_setlease;
> +	return dl;
> +err_setlease:
> +	locks_free_lock(fl);
> +err_lock_alloc:
> +	kfree(dl);
> +	return ERR_PTR(rc);
> +}
> +
> +void dax_lease_set_pages(struct dax_lease *dl, struct page **pages,
> +		long nr_pages)
> +{
> +	if (IS_ERR_OR_NULL(dl))
> +		return;
> +
> +	if (nr_pages <= 0) {
> +		dl->dl_nr_pages = 0;
> +		smp_mb__before_atomic();
> +		set_bit(DAX_LEASE_PAGES, &dl->dl_state);
> +		vfs_setlease(dl->dl_file, F_UNLCK, NULL, (void **) &dl);
> +		flush_delayed_work(&dl->dl_break_work);
> +		put_dax_lease(dl);
> +		return;
> +	}
> +
> +	dl->dl_nr_pages = nr_pages;
> +	memcpy(dl->dl_pages, pages, sizeof(struct page *) * nr_pages);
> +	smp_mb__before_atomic();
> +	set_bit(DAX_LEASE_PAGES, &dl->dl_state);
> +	queue_delayed_work(system_long_wq, &dl->dl_reap_work, HZ);
> +}
> +EXPORT_SYMBOL_GPL(dax_lease_set_pages);
> diff --git a/fs/locks.c b/fs/locks.c
> index 1bd71c4d663a..0a7841590b35 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -135,7 +135,7 @@
>  
>  #define IS_POSIX(fl)	(fl->fl_flags & FL_POSIX)
>  #define IS_FLOCK(fl)	(fl->fl_flags & FL_FLOCK)
> -#define IS_LEASE(fl)	(fl->fl_flags & (FL_LEASE|FL_DELEG|FL_LAYOUT))
> +#define IS_LEASE(fl)	(fl->fl_flags & (FL_LEASE|FL_DELEG|FL_LAYOUT|FL_ALLOCATED))
>  #define IS_OFDLCK(fl)	(fl->fl_flags & FL_OFDLCK)
>  #define IS_REMOTELCK(fl)	(fl->fl_pid <= 0)
>  
> @@ -1414,7 +1414,9 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
>  
>  static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
>  {
> -	if ((breaker->fl_flags & FL_LAYOUT) != (lease->fl_flags & FL_LAYOUT))
> +	/* FL_LAYOUT and FL_ALLOCATED only conflict with each other */
> +	if (!!(breaker->fl_flags & (FL_LAYOUT|FL_ALLOCATED))
> +			!= !!(lease->fl_flags & (FL_LAYOUT|FL_ALLOCATED)))
>  		return false;
>  	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
>  		return false;
> @@ -1653,7 +1655,7 @@ check_conflicting_open(const struct dentry *dentry, const long arg, int flags)
>  	int ret = 0;
>  	struct inode *inode = dentry->d_inode;
>  
> -	if (flags & FL_LAYOUT)
> +	if (flags & (FL_LAYOUT|FL_ALLOCATED))
>  		return 0;
>  
>  	if ((arg == F_RDLCK) &&
> @@ -1733,6 +1735,15 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
>  		 */
>  		if (arg == F_WRLCK)
>  			goto out;
> +
> +		/*
> +		 * Taking out a new FL_ALLOCATED lease while a previous
> +		 * one is being locked is expected since each instance
> +		 * may be responsible for a distinct range of pages.
> +		 */
> +		if (fl->fl_flags & FL_ALLOCATED)
> +			continue;
> +
>  		/*
>  		 * Modifying our existing lease is OK, but no getting a
>  		 * new lease if someone else is opening for write:
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index 122197124b9d..3ff61dc6241e 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -100,10 +100,15 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
>  int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
>  				      pgoff_t index);
>  
> +struct dax_lease;
>  #ifdef CONFIG_FS_DAX
>  int __dax_zero_page_range(struct block_device *bdev,
>  		struct dax_device *dax_dev, sector_t sector,
>  		unsigned int offset, unsigned int length);
> +struct dax_lease *__dax_truncate_lease(struct vm_area_struct *vma,
> +		long nr_pages);
> +void dax_lease_set_pages(struct dax_lease *dl, struct page **pages,
> +		long nr_pages);
>  #else
>  static inline int __dax_zero_page_range(struct block_device *bdev,
>  		struct dax_device *dax_dev, sector_t sector,
> @@ -111,8 +116,26 @@ static inline int __dax_zero_page_range(struct block_device *bdev,
>  {
>  	return -ENXIO;
>  }
> +static inline struct dax_lease *__dax_truncate_lease(struct vm_area_struct *vma,
> +		long nr_pages)
> +{
> +	return NULL;
> +}
> +
> +static inline void dax_lease_set_pages(struct dax_lease *dl,
> +		struct page **pages, long nr_pages)
> +{
> +}
>  #endif
>  
> +static inline struct dax_lease *dax_truncate_lease(struct vm_area_struct *vma,
> +		long nr_pages)
> +{
> +	if (!vma_is_dax(vma))
> +		return NULL;
> +	return __dax_truncate_lease(vma, nr_pages);
> +}
> +
>  static inline bool dax_mapping(struct address_space *mapping)
>  {
>  	return mapping->host && IS_DAX(mapping->host);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index eace2c5396a7..a3ed74833919 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -371,6 +371,9 @@ struct address_space_operations {
>  	int (*swap_activate)(struct swap_info_struct *sis, struct file *file,
>  				sector_t *span);
>  	void (*swap_deactivate)(struct file *file);
> +
> +	/* dax dma support */
> +	void (*dax_flush_dma)(struct inode *inode);
>  };
>  
>  extern const struct address_space_operations empty_aops;
> @@ -927,6 +930,7 @@ static inline struct file *get_file(struct file *f)
>  #define FL_UNLOCK_PENDING	512 /* Lease is being broken */
>  #define FL_OFDLCK	1024	/* lock is "owned" by struct file */
>  #define FL_LAYOUT	2048	/* outstanding pNFS layout */
> +#define FL_ALLOCATED	4096	/* pin allocated dax blocks against dma */
>  
>  #define FL_CLOSE_POSIX (FL_POSIX | FL_CLOSE)
>  
> @@ -2324,17 +2328,27 @@ static inline int break_deleg_wait(struct inode **delegated_inode)
>  	return ret;
>  }
>  
> -static inline int break_layout(struct inode *inode, bool wait)
> +static inline int __break_layout(struct inode *inode, bool wait,
> +		unsigned int type)
>  {
>  	struct file_lock_context *ctx = smp_load_acquire(&inode->i_flctx);
>  
>  	if (ctx && !list_empty_careful(&ctx->flc_lease))
>  		return __break_lease(inode,
>  				wait ? O_WRONLY : O_WRONLY | O_NONBLOCK,
> -				FL_LAYOUT);
> +				type);
>  	return 0;
>  }
>  
> +static inline int break_layout(struct inode *inode, bool wait)
> +{
> +	return __break_layout(inode, wait, FL_LAYOUT);
> +}
> +
> +static inline int break_allocated(struct inode *inode, bool wait)
> +{
> +	return __break_layout(inode, wait, FL_LAYOUT|FL_ALLOCATED);
> +}
>  #else /* !CONFIG_FILE_LOCKING */
>  static inline int break_lease(struct inode *inode, unsigned int mode)
>  {
> @@ -2362,6 +2376,10 @@ static inline int break_layout(struct inode *inode, bool wait)
>  	return 0;
>  }
>  
> +static inline int break_allocated(struct inode *inode, bool wait)
> +{
> +	return 0;
> +}
>  #endif /* CONFIG_FILE_LOCKING */
>  
>  /* fs/open.c */
> diff --git a/mm/gup.c b/mm/gup.c
> index 308be897d22a..6a7cf371e656 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -9,6 +9,7 @@
>  #include <linux/rmap.h>
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
> +#include <linux/dax.h>
>  
>  #include <linux/sched/signal.h>
>  #include <linux/rwsem.h>
> @@ -640,9 +641,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		unsigned int gup_flags, struct page **pages,
>  		struct vm_area_struct **vmas, int *nonblocking)
>  {
> -	long i = 0;
> +	long i = 0, result = 0;
> +	int dax_lease_once = 0;
>  	unsigned int page_mask;
>  	struct vm_area_struct *vma = NULL;
> +	struct dax_lease *dax_lease = NULL;
>  
>  	if (!nr_pages)
>  		return 0;
> @@ -693,6 +696,14 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		if (unlikely(fatal_signal_pending(current)))
>  			return i ? i : -ERESTARTSYS;
>  		cond_resched();
> +		if (pages && !dax_lease_once) {
> +			dax_lease_once = 1;
> +			dax_lease = dax_truncate_lease(vma, nr_pages);
> +			if (IS_ERR(dax_lease)) {
> +				result = PTR_ERR(dax_lease);
> +				goto out;
> +			}
> +		}
>  		page = follow_page_mask(vma, start, foll_flags, &page_mask);
>  		if (!page) {
>  			int ret;
> @@ -704,9 +715,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			case -EFAULT:
>  			case -ENOMEM:
>  			case -EHWPOISON:
> -				return i ? i : ret;
> +				result = i ? i : ret;
> +				goto out;
>  			case -EBUSY:
> -				return i;
> +				result = i;
> +				goto out;
>  			case -ENOENT:
>  				goto next_page;
>  			}
> @@ -718,7 +731,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			 */
>  			goto next_page;
>  		} else if (IS_ERR(page)) {
> -			return i ? i : PTR_ERR(page);
> +			result = i ? i : PTR_ERR(page);
> +			goto out;
>  		}
>  		if (pages) {
>  			pages[i] = page;
> @@ -738,7 +752,10 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		start += page_increm * PAGE_SIZE;
>  		nr_pages -= page_increm;
>  	} while (nr_pages);
> -	return i;
> +	result = i;
> +out:
> +	dax_lease_set_pages(dax_lease, pages, result);
> +	return result;
>  }
>  
>  static bool vma_permits_fault(struct vm_area_struct *vma,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
