Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 562556B04C4
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 21:42:51 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e9so367499884pgc.5
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 18:42:51 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id d1si20180278pga.74.2016.11.20.18.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 18:42:50 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id i88so17201288pfk.2
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 18:42:50 -0800 (PST)
Subject: Re: [HMM v13 09/18] mm/hmm/mirror: mirror process address space on
 device with HMM helpers
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-10-git-send-email-jglisse@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <e6389bd7-de09-e765-58a5-b594d063e276@gmail.com>
Date: Mon, 21 Nov 2016 13:42:43 +1100
MIME-Version: 1.0
In-Reply-To: <1479493107-982-10-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>



On 19/11/16 05:18, JA(C)rA'me Glisse wrote:
> This is a heterogeneous memory management (HMM) process address space
> mirroring. In a nutshell this provide an API to mirror process address
> space on a device. This boils down to keeping CPU and device page table
> synchronize (we assume that both device and CPU are cache coherent like
> PCIe device can be).
> 
> This patch provide a simple API for device driver to achieve address
> space mirroring thus avoiding each device driver to grow its own CPU
> page table walker and its own CPU page table synchronization mechanism.
> 
> This is usefull for NVidia GPU >= Pascal, Mellanox IB >= mlx5 and more
	   useful
> hardware in the future.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> ---
>  include/linux/hmm.h |  97 +++++++++++++++++++++++++++++++
>  mm/hmm.c            | 160 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 257 insertions(+)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 54dd529..f44e270 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -88,6 +88,7 @@
>  
>  #if IS_ENABLED(CONFIG_HMM)
>  
> +struct hmm;
>  
>  /*
>   * hmm_pfn_t - HMM use its own pfn type to keep several flags per page
> @@ -127,6 +128,102 @@ static inline hmm_pfn_t hmm_pfn_from_pfn(unsigned long pfn)
>  }
>  
>  
> +/*
> + * Mirroring: how to use synchronize device page table with CPU page table ?
> + *
> + * Device driver must always synchronize with CPU page table update, for this
> + * they can either directly use mmu_notifier API or they can use the hmm_mirror
> + * API. Device driver can decide to register one mirror per device per process
> + * or just one mirror per process for a group of device. Pattern is :
> + *
> + *      int device_bind_address_space(..., struct mm_struct *mm, ...)
> + *      {
> + *          struct device_address_space *das;
> + *          int ret;
> + *          // Device driver specific initialization, and allocation of das
> + *          // which contain an hmm_mirror struct as one of its field.
> + *          ret = hmm_mirror_register(&das->mirror, mm, &device_mirror_ops);
> + *          if (ret) {
> + *              // Cleanup on error
> + *              return ret;
> + *          }
> + *          // Other device driver specific initialization
> + *      }
> + *
> + * Device driver must not free the struct containing hmm_mirror struct before
> + * calling hmm_mirror_unregister() expected usage is to do that when device
> + * driver is unbinding from an address space.
> + *
> + *      void device_unbind_address_space(struct device_address_space *das)
> + *      {
> + *          // Device driver specific cleanup
> + *          hmm_mirror_unregister(&das->mirror);
> + *          // Other device driver specific cleanup and now das can be free
> + *      }
> + *
> + * Once an hmm_mirror is register for an address space, device driver will get
> + * callback through the update() operation (see hmm_mirror_ops struct).
> + */
> +
> +struct hmm_mirror;
> +
> +/*
> + * enum hmm_update - type of update
> + * @HMM_UPDATE_INVALIDATE: invalidate range (no indication as to why)
> + */
> +enum hmm_update {
> +	HMM_UPDATE_INVALIDATE,
> +};
> +
> +/*
> + * struct hmm_mirror_ops - HMM mirror device operations callback
> + *
> + * @update: callback to update range on a device
> + */
> +struct hmm_mirror_ops {
> +	/* update() - update virtual address range of memory
> +	 *
> +	 * @mirror: pointer to struct hmm_mirror
> +	 * @update: update's type (turn read only, unmap, ...)
> +	 * @start: virtual start address of the range to update
> +	 * @end: virtual end address of the range to update
> +	 *
> +	 * This callback is call when the CPU page table is updated, the device
> +	 * driver must update device page table accordingly to update's action.
> +	 *
> +	 * Device driver callback must wait until device have fully updated its
> +	 * view for the range. Note we plan to make this asynchronous in later
> +	 * patches. So that multiple devices can schedule update to their page
> +	 * table and once all device have schedule the update then we wait for
> +	 * them to propagate.
> +	 */
> +	void (*update)(struct hmm_mirror *mirror,
> +		       enum hmm_update action,
> +		       unsigned long start,
> +		       unsigned long end);
> +};
> +
> +/*
> + * struct hmm_mirror - mirror struct for a device driver
> + *
> + * @hmm: pointer to struct hmm (which is unique per mm_struct)
> + * @ops: device driver callback for HMM mirror operations
> + * @list: for list of mirrors of a given mm
> + *
> + * Each address space (mm_struct) being mirrored by a device must register one
> + * of hmm_mirror struct with HMM. HMM will track list of all mirrors for each
> + * mm_struct (or each process).
> + */
> +struct hmm_mirror {
> +	struct hmm			*hmm;
> +	const struct hmm_mirror_ops	*ops;
> +	struct list_head		list;
> +};
> +
> +int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
> +void hmm_mirror_unregister(struct hmm_mirror *mirror);
> +
> +
>  /* Below are for HMM internal use only ! Not to be use by device driver ! */
>  void hmm_mm_destroy(struct mm_struct *mm);
>  
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 342b596..3594785 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -21,14 +21,27 @@
>  #include <linux/hmm.h>
>  #include <linux/slab.h>
>  #include <linux/sched.h>
> +#include <linux/mmu_notifier.h>
>  
>  /*
>   * struct hmm - HMM per mm struct
>   *
>   * @mm: mm struct this HMM struct is bound to
> + * @lock: lock protecting mirrors list
> + * @mirrors: list of mirrors for this mm
> + * @wait_queue: wait queue
> + * @sequence: we track update to CPU page table with a sequence number
> + * @mmu_notifier: mmu notifier to track update to CPU page table
> + * @notifier_count: number of currently active notifier count
>   */
>  struct hmm {
>  	struct mm_struct	*mm;
> +	spinlock_t		lock;
> +	struct list_head	mirrors;
> +	atomic_t		sequence;
> +	wait_queue_head_t	wait_queue;
> +	struct mmu_notifier	mmu_notifier;
> +	atomic_t		notifier_count;
>  };
>  
>  /*
> @@ -48,6 +61,12 @@ static struct hmm *hmm_register(struct mm_struct *mm)
>  		hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
>  		if (!hmm)
>  			return NULL;
> +		init_waitqueue_head(&hmm->wait_queue);
> +		atomic_set(&hmm->notifier_count, 0);
> +		INIT_LIST_HEAD(&hmm->mirrors);
> +		atomic_set(&hmm->sequence, 0);
> +		hmm->mmu_notifier.ops = NULL;
> +		spin_lock_init(&hmm->lock);
>  		hmm->mm = mm;
>  	}
>  
> @@ -84,3 +103,144 @@ void hmm_mm_destroy(struct mm_struct *mm)
>  
>  	kfree(hmm);
>  }
> +
> +
> +
> +static void hmm_invalidate_range(struct hmm *hmm,
> +				 enum hmm_update action,
> +				 unsigned long start,
> +				 unsigned long end)
> +{
> +	struct hmm_mirror *mirror;
> +
> +	/*
> +	 * Mirror being added or remove is a rare event so list traversal isn't
> +	 * protected by a lock, we rely on simple rules. All list modification
> +	 * are done using list_add_rcu() and list_del_rcu() under a spinlock to
> +	 * protect from concurrent addition or removal but not traversal.
> +	 *
> +	 * Because hmm_mirror_unregister() wait for all running invalidation to
> +	 * complete (and thus all list traversal to finish). None of the mirror
> +	 * struct can be freed from under us while traversing the list and thus
> +	 * it is safe to dereference their list pointer even if they were just
> +	 * remove.
> +	 */
> +	list_for_each_entry (mirror, &hmm->mirrors, list)
> +		mirror->ops->update(mirror, action, start, end);
> +}
> +
> +static void hmm_invalidate_page(struct mmu_notifier *mn,
> +				struct mm_struct *mm,
> +				unsigned long addr)
> +{
> +	unsigned long start = addr & PAGE_MASK;
> +	unsigned long end = start + PAGE_SIZE;
> +	struct hmm *hmm = mm->hmm;
> +
> +	VM_BUG_ON(!hmm);
> +
> +	atomic_inc(&hmm->notifier_count);
> +	atomic_inc(&hmm->sequence);
> +	hmm_invalidate_range(mm->hmm, HMM_UPDATE_INVALIDATE, start, end);
> +	atomic_dec(&hmm->notifier_count);
> +	wake_up(&hmm->wait_queue);
> +}
> +
> +static void hmm_invalidate_range_start(struct mmu_notifier *mn,
> +				       struct mm_struct *mm,
> +				       unsigned long start,
> +				       unsigned long end)
> +{
> +	struct hmm *hmm = mm->hmm;
> +
> +	VM_BUG_ON(!hmm);
> +
> +	atomic_inc(&hmm->notifier_count);
> +	atomic_inc(&hmm->sequence);
> +	hmm_invalidate_range(mm->hmm, HMM_UPDATE_INVALIDATE, start, end);
> +}
> +
> +static void hmm_invalidate_range_end(struct mmu_notifier *mn,
> +				     struct mm_struct *mm,
> +				     unsigned long start,
> +				     unsigned long end)
> +{
> +	struct hmm *hmm = mm->hmm;
> +
> +	VM_BUG_ON(!hmm);
> +
> +	/* Reverse order here because we are getting out of invalidation */
> +	atomic_dec(&hmm->notifier_count);
> +	wake_up(&hmm->wait_queue);
> +}
> +
> +static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
> +	.invalidate_page	= hmm_invalidate_page,
> +	.invalidate_range_start	= hmm_invalidate_range_start,
> +	.invalidate_range_end	= hmm_invalidate_range_end,
> +};
> +
> +/*
> + * hmm_mirror_register() - register a mirror against an mm
> + *
> + * @mirror: new mirror struct to register
> + * @mm: mm to register against
> + *
> + * To start mirroring a process address space device driver must register an
> + * HMM mirror struct.
> + */
> +int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
> +{
> +	/* Sanity check */
> +	if (!mm || !mirror || !mirror->ops)
> +		return -EINVAL;
> +
> +	mirror->hmm = hmm_register(mm);
> +	if (!mirror->hmm)
> +		return -ENOMEM;
> +
> +	/* Register mmu_notifier if not already, use mmap_sem for locking */
> +	if (!mirror->hmm->mmu_notifier.ops) {
> +		struct hmm *hmm = mirror->hmm;
> +		down_write(&mm->mmap_sem);
> +		if (!hmm->mmu_notifier.ops) {
> +			hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
> +			if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
> +				hmm->mmu_notifier.ops = NULL;
> +				up_write(&mm->mmap_sem);
> +				return -ENOMEM;
> +			}
> +		}
> +		up_write(&mm->mmap_sem);
> +	}

Does everything get mirrored, every update to the PTE (clear dirty, clear
accessed bit, etc) or does the driver decide?

> +
> +	spin_lock(&mirror->hmm->lock);
> +	list_add_rcu(&mirror->list, &mirror->hmm->mirrors);
> +	spin_unlock(&mirror->hmm->lock);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(hmm_mirror_register);
> +
> +/*
> + * hmm_mirror_unregister() - unregister a mirror
> + *
> + * @mirror: new mirror struct to register
> + *
> + * Stop mirroring a process address space and cleanup.
> + */
> +void hmm_mirror_unregister(struct hmm_mirror *mirror)
> +{
> +	struct hmm *hmm = mirror->hmm;
> +
> +	spin_lock(&hmm->lock);
> +	list_del_rcu(&mirror->list);
> +	spin_unlock(&hmm->lock);
> +
> +	/*
> +	 * Wait for all active notifier so that it is safe to traverse mirror
> +	 * list without any lock.
> +	 */
> +	wait_event(hmm->wait_queue, !atomic_read(&hmm->notifier_count));
> +}
> +EXPORT_SYMBOL(hmm_mirror_unregister);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
