Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1725E6B0031
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 01:23:06 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so7617468pdi.4
        for <linux-mm@kvack.org>; Sun, 29 Jun 2014 22:23:05 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id xx7si21867278pac.35.2014.06.29.22.23.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 29 Jun 2014 22:23:04 -0700 (PDT)
Date: Sun, 29 Jun 2014 22:22:57 -0700
From: John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 3/6] mmu_notifier: add event information to address
 invalidation v2
In-Reply-To: <1403920822-14488-4-git-send-email-j.glisse@gmail.com>
Message-ID: <alpine.DEB.2.10.1406292122020.21595@blueforge.nvidia.com>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com> <1403920822-14488-4-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="279739828-505577760-1404105783=:21595"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <j.glisse@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hpa@zytor.com, peterz@infraread.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, torvalds@linux-foundation.org, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

--279739828-505577760-1404105783=:21595
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT

On Fri, 27 Jun 2014, JA(C)rA'me Glisse wrote:

> From: JA(C)rA'me Glisse <jglisse@redhat.com>
> 
> The event information will be usefull for new user of mmu_notifier API.
> The event argument differentiate between a vma disappearing, a page
> being write protected or simply a page being unmaped. This allow new
> user to take different path for different event for instance on unmap
> the resource used to track a vma are still valid and should stay around.
> While if the event is saying that a vma is being destroy it means that any
> resources used to track this vma can be free.
> 
> Changed since v1:
>   - renamed action into event (updated commit message too).
>   - simplified the event names and clarified their intented usage
>     also documenting what exceptation the listener can have in
>     respect to each event.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> ---
>  drivers/gpu/drm/i915/i915_gem_userptr.c |   3 +-
>  drivers/iommu/amd_iommu_v2.c            |  14 ++--
>  drivers/misc/sgi-gru/grutlbpurge.c      |   9 ++-
>  drivers/xen/gntdev.c                    |   9 ++-
>  fs/proc/task_mmu.c                      |   6 +-
>  include/linux/hugetlb.h                 |   7 +-
>  include/linux/mmu_notifier.h            | 117 ++++++++++++++++++++++++++------
>  kernel/events/uprobes.c                 |  10 ++-
>  mm/filemap_xip.c                        |   2 +-
>  mm/huge_memory.c                        |  51 ++++++++------
>  mm/hugetlb.c                            |  25 ++++---
>  mm/ksm.c                                |  18 +++--
>  mm/memory.c                             |  27 +++++---
>  mm/migrate.c                            |   9 ++-
>  mm/mmu_notifier.c                       |  28 +++++---
>  mm/mprotect.c                           |  33 ++++++---
>  mm/mremap.c                             |   6 +-
>  mm/rmap.c                               |  24 +++++--
>  virt/kvm/kvm_main.c                     |  12 ++--
>  19 files changed, 291 insertions(+), 119 deletions(-)
> 
> diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
> index 21ea928..ed6f35e 100644
> --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> @@ -56,7 +56,8 @@ struct i915_mmu_object {
>  static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
>  						       struct mm_struct *mm,
>  						       unsigned long start,
> -						       unsigned long end)
> +						       unsigned long end,
> +						       enum mmu_event event)
>  {
>  	struct i915_mmu_notifier *mn = container_of(_mn, struct i915_mmu_notifier, mn);
>  	struct interval_tree_node *it = NULL;
> diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
> index 499b436..2bb9771 100644
> --- a/drivers/iommu/amd_iommu_v2.c
> +++ b/drivers/iommu/amd_iommu_v2.c
> @@ -414,21 +414,25 @@ static int mn_clear_flush_young(struct mmu_notifier *mn,
>  static void mn_change_pte(struct mmu_notifier *mn,
>  			  struct mm_struct *mm,
>  			  unsigned long address,
> -			  pte_t pte)
> +			  pte_t pte,
> +			  enum mmu_event event)
>  {
>  	__mn_flush_page(mn, address);
>  }
>  
>  static void mn_invalidate_page(struct mmu_notifier *mn,
>  			       struct mm_struct *mm,
> -			       unsigned long address)
> +			       unsigned long address,
> +			       enum mmu_event event)
>  {
>  	__mn_flush_page(mn, address);
>  }
>  
>  static void mn_invalidate_range_start(struct mmu_notifier *mn,
>  				      struct mm_struct *mm,
> -				      unsigned long start, unsigned long end)
> +				      unsigned long start,
> +				      unsigned long end,
> +				      enum mmu_event event)
>  {
>  	struct pasid_state *pasid_state;
>  	struct device_state *dev_state;
> @@ -449,7 +453,9 @@ static void mn_invalidate_range_start(struct mmu_notifier *mn,
>  
>  static void mn_invalidate_range_end(struct mmu_notifier *mn,
>  				    struct mm_struct *mm,
> -				    unsigned long start, unsigned long end)
> +				    unsigned long start,
> +				    unsigned long end,
> +				    enum mmu_event event)
>  {
>  	struct pasid_state *pasid_state;
>  	struct device_state *dev_state;
> diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
> index 2129274..e67fed1 100644
> --- a/drivers/misc/sgi-gru/grutlbpurge.c
> +++ b/drivers/misc/sgi-gru/grutlbpurge.c
> @@ -221,7 +221,8 @@ void gru_flush_all_tlb(struct gru_state *gru)
>   */
>  static void gru_invalidate_range_start(struct mmu_notifier *mn,
>  				       struct mm_struct *mm,
> -				       unsigned long start, unsigned long end)
> +				       unsigned long start, unsigned long end,
> +				       enum mmu_event event)
>  {
>  	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
>  						 ms_notifier);
> @@ -235,7 +236,8 @@ static void gru_invalidate_range_start(struct mmu_notifier *mn,
>  
>  static void gru_invalidate_range_end(struct mmu_notifier *mn,
>  				     struct mm_struct *mm, unsigned long start,
> -				     unsigned long end)
> +				     unsigned long end,
> +				     enum mmu_event event)
>  {
>  	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
>  						 ms_notifier);
> @@ -248,7 +250,8 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
>  }
>  
>  static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
> -				unsigned long address)
> +				unsigned long address,
> +				enum mmu_event event)
>  {
>  	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
>  						 ms_notifier);
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index 073b4a1..fe9da94 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -428,7 +428,9 @@ static void unmap_if_in_range(struct grant_map *map,
>  
>  static void mn_invl_range_start(struct mmu_notifier *mn,
>  				struct mm_struct *mm,
> -				unsigned long start, unsigned long end)
> +				unsigned long start,
> +				unsigned long end,
> +				enum mmu_event event)
>  {
>  	struct gntdev_priv *priv = container_of(mn, struct gntdev_priv, mn);
>  	struct grant_map *map;
> @@ -445,9 +447,10 @@ static void mn_invl_range_start(struct mmu_notifier *mn,
>  
>  static void mn_invl_page(struct mmu_notifier *mn,
>  			 struct mm_struct *mm,
> -			 unsigned long address)
> +			 unsigned long address,
> +			 enum mmu_event event)
>  {
> -	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE);
> +	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE, event);
>  }
>  
>  static void mn_release(struct mmu_notifier *mn,
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index cfa63ee..e9e79f7 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -830,7 +830,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  		};
>  		down_read(&mm->mmap_sem);
>  		if (type == CLEAR_REFS_SOFT_DIRTY)
> -			mmu_notifier_invalidate_range_start(mm, 0, -1);
> +			mmu_notifier_invalidate_range_start(mm, 0,
> +							    -1, MMU_STATUS);
>  		for (vma = mm->mmap; vma; vma = vma->vm_next) {
>  			cp.vma = vma;
>  			if (is_vm_hugetlb_page(vma))
> @@ -858,7 +859,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  					&clear_refs_walk);
>  		}
>  		if (type == CLEAR_REFS_SOFT_DIRTY)
> -			mmu_notifier_invalidate_range_end(mm, 0, -1);
> +			mmu_notifier_invalidate_range_end(mm, 0,
> +							  -1, MMU_STATUS);
>  		flush_tlb_mm(mm);
>  		up_read(&mm->mmap_sem);
>  		mmput(mm);
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 6a836ef..d7e512f 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -6,6 +6,7 @@
>  #include <linux/fs.h>
>  #include <linux/hugetlb_inline.h>
>  #include <linux/cgroup.h>
> +#include <linux/mmu_notifier.h>
>  #include <linux/list.h>
>  #include <linux/kref.h>
>  
> @@ -103,7 +104,8 @@ struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
>  int pmd_huge(pmd_t pmd);
>  int pud_huge(pud_t pmd);
>  unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
> -		unsigned long address, unsigned long end, pgprot_t newprot);
> +		unsigned long address, unsigned long end, pgprot_t newprot,
> +		enum mmu_event event);
>  
>  #else /* !CONFIG_HUGETLB_PAGE */
>  
> @@ -148,7 +150,8 @@ static inline bool isolate_huge_page(struct page *page, struct list_head *list)
>  #define is_hugepage_active(x)	false
>  
>  static inline unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
> -		unsigned long address, unsigned long end, pgprot_t newprot)
> +		unsigned long address, unsigned long end, pgprot_t newprot,
> +		enum mmu_event event)
>  {
>  	return 0;
>  }
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index deca874..82e9577 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -9,6 +9,52 @@
>  struct mmu_notifier;
>  struct mmu_notifier_ops;
>  
> +/* Event report finer informations to the callback allowing the event listener
> + * to take better action. There are only few kinds of events :
> + *
> + *   - MMU_MIGRATE memory is migrating from one page to another thus all write
> + *     access must stop after invalidate_range_start callback returns. And no
> + *     read access should be allowed either as new page can be remapped with
> + *     write access before the invalidate_range_end callback happen and thus
> + *     any read access to old page might access outdated informations. Several
> + *     source to this event like page moving to swap (for various reasons like
> + *     page reclaim), outcome of mremap syscall, migration for numa reasons,
> + *     balancing memory pool, write fault on read only page trigger a new page
> + *     to be allocated and used, ...
> + *   - MMU_MPROT_NONE memory access protection is change, no page in the range
> + *     can be accessed in either read or write mode but the range of address
> + *     is still valid. All access are still fine until invalidate_range_end
> + *     callback returns.
> + *   - MMU_MPROT_RONLY memory access proctection is changing to read only.
> + *     All access are still fine until invalidate_range_end callback returns.
> + *   - MMU_MPROT_RANDW memory access proctection is changing to read an write.
> + *     All access are still fine until invalidate_range_end callback returns.
> + *   - MMU_MPROT_WONLY memory access proctection is changing to write only.
> + *     All access are still fine until invalidate_range_end callback returns.
> + *   - MMU_MUNMAP the range is being unmaped (outcome of a munmap syscall). It
> + *     is fine to still have read/write access until the invalidate_range_end
> + *     callback returns. This also imply that secondary page table can be trim
> + *     as the address range is no longer valid.
> + *   - MMU_WB memory is being write back to disk, all write access must stop
> + *     after invalidate_range_start callback returns. Read access are still
> + *     allowed.
> + *   - MMU_STATUS memory status change, like soft dirty.
> + *
> + * In doubt when adding a new notifier caller use MMU_MIGRATE it will always
> + * result in expected behavior but will not allow listener a chance to optimize
> + * its events.
> + */

Here is a pass at tightening up that documentation:

/* MMU Events report fine-grained information to the callback routine, allowing
 * the event listener to make a more informed decision as to what action to
 * take. The event types are:
 *
 *   - MMU_MIGRATE: memory is migrating from one page to another, thus all write
 *     access must stop after invalidate_range_start callback returns.
 *     Furthermore, no read access should be allowed either, as a new page can
 *     be remapped with write access before the invalidate_range_end callback
 *     happens and thus any read access to old page might read stale data. There
 *     are several sources for this event, including:
 *
 *         - A page moving to swap (for various reasons, including page
 *           reclaim),
 *         - An mremap syscall,
 *         - migration for NUMA reasons,
 *         - balancing the memory pool,
 *         - write fault on a read-only page triggers a new page to be allocated
 *           and used,
 *         - and more that are not listed here.
 *
 *   - MMU_MPROT_NONE: memory access protection is changing to "none": no page
 *     in the range can be accessed in either read or write mode but the range
 *     of addresses is still valid. However, access is still allowed, up until
 *     invalidate_range_end callback returns.
 *
 *   - MMU_MPROT_RONLY: memory access proctection is changing to read only.
 *     However, access is still allowed, up until invalidate_range_end callback
 *     returns.
 *
 *   - MMU_MPROT_RANDW: memory access proctection is changing to read and write.
 *     However, access is still allowed, up until invalidate_range_end callback
 *     returns.
 *
 *   - MMU_MPROT_WONLY: memory access proctection is changing to write only.
 *     However, access is still allowed, up until invalidate_range_end callback
 *     returns.
 *
 *   - MMU_MUNMAP: the range is being unmapped (outcome of a munmap syscall).
 *     However, access is still allowed, up until invalidate_range_end callback
 *     returns. This also implies that the secondary page table can be trimmed,
 *     because the address range is no longer valid.
 *
 *   - MMU_WB: memory is being written back to disk, all write accesses must
 *     stop after invalidate_range_start callback returns. Read access are still
 *     allowed.
 *
 *   - MMU_STATUS memory status change, like soft dirty, or huge page 
 *     splitting (in place).
 *
 * If in doubt when adding a new notifier caller, please use MMU_MIGRATE,
 * because it will always lead to reasonable behavior, but will not allow the
 * listener a chance to optimize its events.
 */

Mostly just cleaning up the wording, except that I did add "huge page 
splitting" to the cases that could cause an MMU_STATUS to fire.

> +enum mmu_event {
> +	MMU_MIGRATE = 0,
> +	MMU_MPROT_NONE,
> +	MMU_MPROT_RONLY,
> +	MMU_MPROT_RANDW,
> +	MMU_MPROT_WONLY,
> +	MMU_MUNMAP,
> +	MMU_STATUS,
> +	MMU_WB,
> +};
> +
>  #ifdef CONFIG_MMU_NOTIFIER
>  
>  /*
> @@ -79,7 +125,8 @@ struct mmu_notifier_ops {
>  	void (*change_pte)(struct mmu_notifier *mn,
>  			   struct mm_struct *mm,
>  			   unsigned long address,
> -			   pte_t pte);
> +			   pte_t pte,
> +			   enum mmu_event event);
>  
>  	/*
>  	 * Before this is invoked any secondary MMU is still ok to
> @@ -90,7 +137,8 @@ struct mmu_notifier_ops {
>  	 */
>  	void (*invalidate_page)(struct mmu_notifier *mn,
>  				struct mm_struct *mm,
> -				unsigned long address);
> +				unsigned long address,
> +				enum mmu_event event);
>  
>  	/*
>  	 * invalidate_range_start() and invalidate_range_end() must be
> @@ -137,10 +185,14 @@ struct mmu_notifier_ops {
>  	 */
>  	void (*invalidate_range_start)(struct mmu_notifier *mn,
>  				       struct mm_struct *mm,
> -				       unsigned long start, unsigned long end);
> +				       unsigned long start,
> +				       unsigned long end,
> +				       enum mmu_event event);
>  	void (*invalidate_range_end)(struct mmu_notifier *mn,
>  				     struct mm_struct *mm,
> -				     unsigned long start, unsigned long end);
> +				     unsigned long start,
> +				     unsigned long end,
> +				     enum mmu_event event);
>  };
>  
>  /*
> @@ -177,13 +229,20 @@ extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
>  extern int __mmu_notifier_test_young(struct mm_struct *mm,
>  				     unsigned long address);
>  extern void __mmu_notifier_change_pte(struct mm_struct *mm,
> -				      unsigned long address, pte_t pte);
> +				      unsigned long address,
> +				      pte_t pte,
> +				      enum mmu_event event);
>  extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
> -					  unsigned long address);
> +					  unsigned long address,
> +					  enum mmu_event event);
>  extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end);
> +						  unsigned long start,
> +						  unsigned long end,
> +						  enum mmu_event event);
>  extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end);
> +						unsigned long start,
> +						unsigned long end,
> +						enum mmu_event event);
>  
>  static inline void mmu_notifier_release(struct mm_struct *mm)
>  {
> @@ -208,31 +267,38 @@ static inline int mmu_notifier_test_young(struct mm_struct *mm,
>  }
>  
>  static inline void mmu_notifier_change_pte(struct mm_struct *mm,
> -					   unsigned long address, pte_t pte)
> +					   unsigned long address,
> +					   pte_t pte,
> +					   enum mmu_event event)
>  {
>  	if (mm_has_notifiers(mm))
> -		__mmu_notifier_change_pte(mm, address, pte);
> +		__mmu_notifier_change_pte(mm, address, pte, event);
>  }
>  
>  static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
> -					  unsigned long address)
> +						unsigned long address,
> +						enum mmu_event event)
>  {
>  	if (mm_has_notifiers(mm))
> -		__mmu_notifier_invalidate_page(mm, address);
> +		__mmu_notifier_invalidate_page(mm, address, event);
>  }
>  
>  static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +						       unsigned long start,
> +						       unsigned long end,
> +						       enum mmu_event event)
>  {
>  	if (mm_has_notifiers(mm))
> -		__mmu_notifier_invalidate_range_start(mm, start, end);
> +		__mmu_notifier_invalidate_range_start(mm, start, end, event);
>  }
>  
>  static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +						     unsigned long start,
> +						     unsigned long end,
> +						     enum mmu_event event)
>  {
>  	if (mm_has_notifiers(mm))
> -		__mmu_notifier_invalidate_range_end(mm, start, end);
> +		__mmu_notifier_invalidate_range_end(mm, start, end, event);
>  }
>  
>  static inline void mmu_notifier_mm_init(struct mm_struct *mm)
> @@ -278,13 +344,13 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
>   * old page would remain mapped readonly in the secondary MMUs after the new
>   * page is already writable by some CPU through the primary MMU.
>   */
> -#define set_pte_at_notify(__mm, __address, __ptep, __pte)		\
> +#define set_pte_at_notify(__mm, __address, __ptep, __pte, __event)	\
>  ({									\
>  	struct mm_struct *___mm = __mm;					\
>  	unsigned long ___address = __address;				\
>  	pte_t ___pte = __pte;						\
>  									\
> -	mmu_notifier_change_pte(___mm, ___address, ___pte);		\
> +	mmu_notifier_change_pte(___mm, ___address, ___pte, __event);	\
>  	set_pte_at(___mm, ___address, __ptep, ___pte);			\
>  })
>  
> @@ -307,22 +373,29 @@ static inline int mmu_notifier_test_young(struct mm_struct *mm,
>  }
>  
>  static inline void mmu_notifier_change_pte(struct mm_struct *mm,
> -					   unsigned long address, pte_t pte)
> +					   unsigned long address,
> +					   pte_t pte,
> +					   enum mmu_event event)
>  {
>  }
>  
>  static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
> -					  unsigned long address)
> +						unsigned long address,
> +						enum mmu_event event)
>  {
>  }
>  
>  static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +						       unsigned long start,
> +						       unsigned long end,
> +						       enum mmu_event event)
>  {
>  }
>  
>  static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +						     unsigned long start,
> +						     unsigned long end,
> +						     enum mmu_event event)
>  {
>  }
>  
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index 32b04dc..296f81e 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -177,7 +177,8 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  	/* For try_to_free_swap() and munlock_vma_page() below */
>  	lock_page(page);
>  
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_MIGRATE);
>  	err = -EAGAIN;
>  	ptep = page_check_address(page, mm, addr, &ptl, 0);
>  	if (!ptep)
> @@ -195,7 +196,9 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  
>  	flush_cache_page(vma, addr, pte_pfn(*ptep));
>  	ptep_clear_flush(vma, addr, ptep);
> -	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
> +	set_pte_at_notify(mm, addr, ptep,
> +			  mk_pte(kpage, vma->vm_page_prot),
> +			  MMU_MIGRATE);
>  
>  	page_remove_rmap(page);
>  	if (!page_mapped(page))
> @@ -209,7 +212,8 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  	err = 0;
>   unlock:
>  	mem_cgroup_cancel_charge(kpage, memcg);
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_MIGRATE);
>  	unlock_page(page);
>  	return err;
>  }
> diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
> index d8d9fe3..a2b3f09 100644
> --- a/mm/filemap_xip.c
> +++ b/mm/filemap_xip.c
> @@ -198,7 +198,7 @@ retry:
>  			BUG_ON(pte_dirty(pteval));
>  			pte_unmap_unlock(pte, ptl);
>  			/* must invalidate_page _before_ freeing the page */
> -			mmu_notifier_invalidate_page(mm, address);
> +			mmu_notifier_invalidate_page(mm, address, MMU_MIGRATE);
>  			page_cache_release(page);
>  		}
>  	}
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 5d562a9..fa30857 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1020,6 +1020,11 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
>  		set_page_private(pages[i], (unsigned long)memcg);
>  	}
>  
> +	mmun_start = haddr;
> +	mmun_end   = haddr + HPAGE_PMD_SIZE;
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_MIGRATE);
> +
>  	for (i = 0; i < HPAGE_PMD_NR; i++) {
>  		copy_user_highpage(pages[i], page + i,
>  				   haddr + PAGE_SIZE * i, vma);
> @@ -1027,10 +1032,6 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
>  		cond_resched();
>  	}
>  
> -	mmun_start = haddr;
> -	mmun_end   = haddr + HPAGE_PMD_SIZE;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> -
>  	ptl = pmd_lock(mm, pmd);
>  	if (unlikely(!pmd_same(*pmd, orig_pmd)))
>  		goto out_free_pages;

So, that looks like you are fixing a pre-existing bug here? The 
invalidate_range call is now happening *before* we copy pages. That seems 
correct, although this is starting to get into code I'm less comfortable 
with (huge pages).  But I think it's worth mentioning in the commit 
message.

> @@ -1063,7 +1064,8 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
>  	page_remove_rmap(page);
>  	spin_unlock(ptl);
>  
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_MIGRATE);
>  
>  	ret |= VM_FAULT_WRITE;
>  	put_page(page);
> @@ -1073,7 +1075,8 @@ out:
>  
>  out_free_pages:
>  	spin_unlock(ptl);
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_MIGRATE);
>  	for (i = 0; i < HPAGE_PMD_NR; i++) {
>  		memcg = (void *)page_private(pages[i]);
>  		set_page_private(pages[i], 0);
> @@ -1157,16 +1160,17 @@ alloc:
>  
>  	count_vm_event(THP_FAULT_ALLOC);
>  
> +	mmun_start = haddr;
> +	mmun_end   = haddr + HPAGE_PMD_SIZE;
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_MIGRATE);
> +
>  	if (!page)
>  		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
>  	else
>  		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
>  	__SetPageUptodate(new_page);
>  
> -	mmun_start = haddr;
> -	mmun_end   = haddr + HPAGE_PMD_SIZE;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> -

Another bug fix, OK.

>  	spin_lock(ptl);
>  	if (page)
>  		put_user_huge_page(page);
> @@ -1197,7 +1201,8 @@ alloc:
>  	}
>  	spin_unlock(ptl);
>  out_mn:
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_MIGRATE);
>  out:
>  	return ret;
>  out_unlock:
> @@ -1632,7 +1637,8 @@ static int __split_huge_page_splitting(struct page *page,
>  	const unsigned long mmun_start = address;
>  	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
>  
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_STATUS);

OK, just to be sure: we are not moving the page contents at this point, 
right? Just changing the page table from a single "huge" entry, into lots 
of little 4K page entries? If so, than MMU_STATUS seems correct, but we 
should add that case to the "Event types" documentation above.

>  	pmd = page_check_address_pmd(page, mm, address,
>  			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
>  	if (pmd) {
> @@ -1647,7 +1653,8 @@ static int __split_huge_page_splitting(struct page *page,
>  		ret = 1;
>  		spin_unlock(ptl);
>  	}
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_STATUS);
>  
>  	return ret;
>  }
> @@ -2446,7 +2453,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>  
>  	mmun_start = address;
>  	mmun_end   = address + HPAGE_PMD_SIZE;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_MIGRATE);
>  	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
>  	/*
>  	 * After this gup_fast can't run anymore. This also removes
> @@ -2456,7 +2464,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	 */
>  	_pmd = pmdp_clear_flush(vma, address, pmd);
>  	spin_unlock(pmd_ptl);
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_MIGRATE);
>  
>  	spin_lock(pte_ptl);
>  	isolated = __collapse_huge_page_isolate(vma, address, pte);
> @@ -2845,24 +2854,28 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
>  	mmun_start = haddr;
>  	mmun_end   = haddr + HPAGE_PMD_SIZE;
>  again:
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_MIGRATE);

Just checking: this is MMU_MIGRATE, instead of MMU_STATUS, because we are 
actually moving data? (The pages backing the page table?)

>  	ptl = pmd_lock(mm, pmd);
>  	if (unlikely(!pmd_trans_huge(*pmd))) {
>  		spin_unlock(ptl);
> -		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +		mmu_notifier_invalidate_range_end(mm, mmun_start,
> +						  mmun_end, MMU_MIGRATE);
>  		return;
>  	}
>  	if (is_huge_zero_pmd(*pmd)) {
>  		__split_huge_zero_page_pmd(vma, haddr, pmd);
>  		spin_unlock(ptl);
> -		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +		mmu_notifier_invalidate_range_end(mm, mmun_start,
> +						  mmun_end, MMU_MIGRATE);
>  		return;
>  	}
>  	page = pmd_page(*pmd);
>  	VM_BUG_ON_PAGE(!page_count(page), page);
>  	get_page(page);
>  	spin_unlock(ptl);
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_MIGRATE);
>  
>  	split_huge_page(page);
>  
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7faab71..73e1576 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2565,7 +2565,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  	mmun_start = vma->vm_start;
>  	mmun_end = vma->vm_end;
>  	if (cow)
> -		mmu_notifier_invalidate_range_start(src, mmun_start, mmun_end);
> +		mmu_notifier_invalidate_range_start(src, mmun_start,
> +						    mmun_end, MMU_MIGRATE);
>  
>  	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
>  		spinlock_t *src_ptl, *dst_ptl;
> @@ -2615,7 +2616,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  	}
>  
>  	if (cow)
> -		mmu_notifier_invalidate_range_end(src, mmun_start, mmun_end);
> +		mmu_notifier_invalidate_range_end(src, mmun_start,
> +						  mmun_end, MMU_MIGRATE);
>  
>  	return ret;
>  }
> @@ -2641,7 +2643,8 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  	BUG_ON(end & ~huge_page_mask(h));
>  
>  	tlb_start_vma(tlb, vma);
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_MIGRATE);
>  again:
>  	for (address = start; address < end; address += sz) {
>  		ptep = huge_pte_offset(mm, address);
> @@ -2712,7 +2715,8 @@ unlock:
>  		if (address < end && !ref_page)
>  			goto again;
>  	}
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_MIGRATE);
>  	tlb_end_vma(tlb, vma);
>  }
>  
> @@ -2899,7 +2903,8 @@ retry_avoidcopy:
>  
>  	mmun_start = address & huge_page_mask(h);
>  	mmun_end = mmun_start + huge_page_size(h);
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_MIGRATE);
>  	/*
>  	 * Retake the page table lock to check for racing updates
>  	 * before the page tables are altered
> @@ -2919,7 +2924,8 @@ retry_avoidcopy:
>  		new_page = old_page;
>  	}
>  	spin_unlock(ptl);
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_MIGRATE);
>  	page_cache_release(new_page);
>  	page_cache_release(old_page);
>  
> @@ -3344,7 +3350,8 @@ same_page:
>  }
>  
>  unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
> -		unsigned long address, unsigned long end, pgprot_t newprot)
> +		unsigned long address, unsigned long end, pgprot_t newprot,
> +		enum mmu_event event)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	unsigned long start = address;
> @@ -3356,7 +3363,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  	BUG_ON(address >= end);
>  	flush_cache_range(vma, address, end);
>  
> -	mmu_notifier_invalidate_range_start(mm, start, end);
> +	mmu_notifier_invalidate_range_start(mm, start, end, event);
>  	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
>  	for (; address < end; address += huge_page_size(h)) {
>  		spinlock_t *ptl;
> @@ -3386,7 +3393,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  	 */
>  	flush_tlb_range(vma, start, end);
>  	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> -	mmu_notifier_invalidate_range_end(mm, start, end);
> +	mmu_notifier_invalidate_range_end(mm, start, end, event);
>  
>  	return pages << h->order;
>  }
> diff --git a/mm/ksm.c b/mm/ksm.c
> index cb1e976..4b659f1 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -873,7 +873,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
>  
>  	mmun_start = addr;
>  	mmun_end   = addr + PAGE_SIZE;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_MPROT_RONLY);
>  
>  	ptep = page_check_address(page, mm, addr, &ptl, 0);
>  	if (!ptep)
> @@ -905,7 +906,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
>  		if (pte_dirty(entry))
>  			set_page_dirty(page);
>  		entry = pte_mkclean(pte_wrprotect(entry));
> -		set_pte_at_notify(mm, addr, ptep, entry);
> +		set_pte_at_notify(mm, addr, ptep, entry, MMU_MPROT_RONLY);
>  	}
>  	*orig_pte = *ptep;
>  	err = 0;
> @@ -913,7 +914,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
>  out_unlock:
>  	pte_unmap_unlock(ptep, ptl);
>  out_mn:
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_MPROT_RONLY);
>  out:
>  	return err;
>  }
> @@ -949,7 +951,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
>  
>  	mmun_start = addr;
>  	mmun_end   = addr + PAGE_SIZE;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_MIGRATE);
>  
>  	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
>  	if (!pte_same(*ptep, orig_pte)) {
> @@ -962,7 +965,9 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
>  
>  	flush_cache_page(vma, addr, pte_pfn(*ptep));
>  	ptep_clear_flush(vma, addr, ptep);
> -	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
> +	set_pte_at_notify(mm, addr, ptep,
> +			  mk_pte(kpage, vma->vm_page_prot),
> +			  MMU_MIGRATE);
>  
>  	page_remove_rmap(page);
>  	if (!page_mapped(page))
> @@ -972,7 +977,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
>  	pte_unmap_unlock(ptep, ptl);
>  	err = 0;
>  out_mn:
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_MIGRATE);
>  out:
>  	return err;
>  }
> diff --git a/mm/memory.c b/mm/memory.c
> index 09e2cd0..d3908f0 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1050,7 +1050,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	mmun_end   = end;
>  	if (is_cow)
>  		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
> -						    mmun_end);
> +						    mmun_end, MMU_MIGRATE);
>  
>  	ret = 0;
>  	dst_pgd = pgd_offset(dst_mm, addr);
> @@ -1067,7 +1067,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
>  
>  	if (is_cow)
> -		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end);
> +		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end,
> +						  MMU_MIGRATE);
>  	return ret;
>  }
>  
> @@ -1371,10 +1372,12 @@ void unmap_vmas(struct mmu_gather *tlb,
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  
> -	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
> +	mmu_notifier_invalidate_range_start(mm, start_addr,
> +					    end_addr, MMU_MUNMAP);
>  	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
>  		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
> -	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
> +	mmu_notifier_invalidate_range_end(mm, start_addr,
> +					  end_addr, MMU_MUNMAP);
>  }
>  
>  /**
> @@ -1396,10 +1399,10 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
>  	lru_add_drain();
>  	tlb_gather_mmu(&tlb, mm, start, end);
>  	update_hiwater_rss(mm);
> -	mmu_notifier_invalidate_range_start(mm, start, end);
> +	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MUNMAP);
>  	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
>  		unmap_single_vma(&tlb, vma, start, end, details);
> -	mmu_notifier_invalidate_range_end(mm, start, end);
> +	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MUNMAP);
>  	tlb_finish_mmu(&tlb, start, end);
>  }
>  
> @@ -1422,9 +1425,9 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
>  	lru_add_drain();
>  	tlb_gather_mmu(&tlb, mm, address, end);
>  	update_hiwater_rss(mm);
> -	mmu_notifier_invalidate_range_start(mm, address, end);
> +	mmu_notifier_invalidate_range_start(mm, address, end, MMU_MUNMAP);
>  	unmap_single_vma(&tlb, vma, address, end, details);
> -	mmu_notifier_invalidate_range_end(mm, address, end);
> +	mmu_notifier_invalidate_range_end(mm, address, end, MMU_MUNMAP);
>  	tlb_finish_mmu(&tlb, address, end);
>  }
>  
> @@ -2208,7 +2211,8 @@ gotten:
>  
>  	mmun_start  = address & PAGE_MASK;
>  	mmun_end    = mmun_start + PAGE_SIZE;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_MIGRATE);
>  
>  	/*
>  	 * Re-check the pte - we dropped the lock
> @@ -2240,7 +2244,7 @@ gotten:
>  		 * mmu page tables (such as kvm shadow page tables), we want the
>  		 * new page to be mapped directly into the secondary page table.
>  		 */
> -		set_pte_at_notify(mm, address, page_table, entry);
> +		set_pte_at_notify(mm, address, page_table, entry, MMU_MIGRATE);
>  		update_mmu_cache(vma, address, page_table);
>  		if (old_page) {
>  			/*
> @@ -2279,7 +2283,8 @@ gotten:
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
>  	if (mmun_end > mmun_start)
> -		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +		mmu_notifier_invalidate_range_end(mm, mmun_start,
> +						  mmun_end, MMU_MIGRATE);
>  	if (old_page) {
>  		/*
>  		 * Don't let another task, with possibly unlocked vma,
> diff --git a/mm/migrate.c b/mm/migrate.c
> index ab43fbf..b526c72 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1820,12 +1820,14 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  	WARN_ON(PageLRU(new_page));
>  
>  	/* Recheck the target PMD */
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
> +					    mmun_end, MMU_MIGRATE);
>  	ptl = pmd_lock(mm, pmd);
>  	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
>  fail_putback:
>  		spin_unlock(ptl);
> -		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +		mmu_notifier_invalidate_range_end(mm, mmun_start,
> +						  mmun_end, MMU_MIGRATE);
>  
>  		/* Reverse changes made by migrate_page_copy() */
>  		if (TestClearPageActive(new_page))
> @@ -1878,7 +1880,8 @@ fail_putback:
>  	page_remove_rmap(page);
>  
>  	spin_unlock(ptl);
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
> +					  mmun_end, MMU_MIGRATE);
>  
>  	/* Take an "isolate" reference and put new page on the LRU. */
>  	get_page(new_page);
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 41cefdf..9decb88 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -122,8 +122,10 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
>  	return young;
>  }
>  
> -void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
> -			       pte_t pte)
> +void __mmu_notifier_change_pte(struct mm_struct *mm,
> +			       unsigned long address,
> +			       pte_t pte,
> +			       enum mmu_event event)
>  {
>  	struct mmu_notifier *mn;
>  	int id;
> @@ -131,13 +133,14 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
>  	id = srcu_read_lock(&srcu);
>  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>  		if (mn->ops->change_pte)
> -			mn->ops->change_pte(mn, mm, address, pte);
> +			mn->ops->change_pte(mn, mm, address, pte, event);
>  	}
>  	srcu_read_unlock(&srcu, id);
>  }
>  
>  void __mmu_notifier_invalidate_page(struct mm_struct *mm,
> -					  unsigned long address)
> +				    unsigned long address,
> +				    enum mmu_event event)
>  {
>  	struct mmu_notifier *mn;
>  	int id;
> @@ -145,13 +148,16 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
>  	id = srcu_read_lock(&srcu);
>  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>  		if (mn->ops->invalidate_page)
> -			mn->ops->invalidate_page(mn, mm, address);
> +			mn->ops->invalidate_page(mn, mm, address, event);
>  	}
>  	srcu_read_unlock(&srcu, id);
>  }
>  
>  void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +					   unsigned long start,
> +					   unsigned long end,
> +					   enum mmu_event event)
> +
>  {
>  	struct mmu_notifier *mn;
>  	int id;
> @@ -159,14 +165,17 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>  	id = srcu_read_lock(&srcu);
>  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>  		if (mn->ops->invalidate_range_start)
> -			mn->ops->invalidate_range_start(mn, mm, start, end);
> +			mn->ops->invalidate_range_start(mn, mm, start,
> +							end, event);
>  	}
>  	srcu_read_unlock(&srcu, id);
>  }
>  EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
>  
>  void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +					 unsigned long start,
> +					 unsigned long end,
> +					 enum mmu_event event)
>  {
>  	struct mmu_notifier *mn;
>  	int id;
> @@ -174,7 +183,8 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>  	id = srcu_read_lock(&srcu);
>  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>  		if (mn->ops->invalidate_range_end)
> -			mn->ops->invalidate_range_end(mn, mm, start, end);
> +			mn->ops->invalidate_range_end(mn, mm, start,
> +						      end, event);
>  	}
>  	srcu_read_unlock(&srcu, id);
>  }
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index c43d557..6ce6c23 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -137,7 +137,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  
>  static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		pud_t *pud, unsigned long addr, unsigned long end,
> -		pgprot_t newprot, int dirty_accountable, int prot_numa)
> +		pgprot_t newprot, int dirty_accountable, int prot_numa,
> +		enum mmu_event event)
>  {
>  	pmd_t *pmd;
>  	struct mm_struct *mm = vma->vm_mm;
> @@ -157,7 +158,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		/* invoke the mmu notifier if the pmd is populated */
>  		if (!mni_start) {
>  			mni_start = addr;
> -			mmu_notifier_invalidate_range_start(mm, mni_start, end);
> +			mmu_notifier_invalidate_range_start(mm, mni_start,
> +							    end, event);
>  		}
>  
>  		if (pmd_trans_huge(*pmd)) {
> @@ -185,7 +187,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  	} while (pmd++, addr = next, addr != end);
>  
>  	if (mni_start)
> -		mmu_notifier_invalidate_range_end(mm, mni_start, end);
> +		mmu_notifier_invalidate_range_end(mm, mni_start, end, event);
>  
>  	if (nr_huge_updates)
>  		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
> @@ -194,7 +196,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  
>  static inline unsigned long change_pud_range(struct vm_area_struct *vma,
>  		pgd_t *pgd, unsigned long addr, unsigned long end,
> -		pgprot_t newprot, int dirty_accountable, int prot_numa)
> +		pgprot_t newprot, int dirty_accountable, int prot_numa,
> +		enum mmu_event event)
>  {
>  	pud_t *pud;
>  	unsigned long next;
> @@ -206,7 +209,7 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma,
>  		if (pud_none_or_clear_bad(pud))
>  			continue;
>  		pages += change_pmd_range(vma, pud, addr, next, newprot,
> -				 dirty_accountable, prot_numa);
> +				 dirty_accountable, prot_numa, event);
>  	} while (pud++, addr = next, addr != end);
>  
>  	return pages;
> @@ -214,7 +217,7 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma,
>  
>  static unsigned long change_protection_range(struct vm_area_struct *vma,
>  		unsigned long addr, unsigned long end, pgprot_t newprot,
> -		int dirty_accountable, int prot_numa)
> +		int dirty_accountable, int prot_numa, enum mmu_event event)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	pgd_t *pgd;
> @@ -231,7 +234,7 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
>  		if (pgd_none_or_clear_bad(pgd))
>  			continue;
>  		pages += change_pud_range(vma, pgd, addr, next, newprot,
> -				 dirty_accountable, prot_numa);
> +				 dirty_accountable, prot_numa, event);
>  	} while (pgd++, addr = next, addr != end);
>  
>  	/* Only flush the TLB if we actually modified any entries: */
> @@ -247,11 +250,23 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
>  		       int dirty_accountable, int prot_numa)
>  {
>  	unsigned long pages;
> +	enum mmu_event event = MMU_MPROT_NONE;
> +
> +	/* At this points vm_flags is updated. */
> +	if ((vma->vm_flags & VM_READ) && (vma->vm_flags & VM_WRITE))
> +		event = MMU_MPROT_RANDW;
> +	else if (vma->vm_flags & VM_WRITE)
> +		event = MMU_MPROT_WONLY;
> +	else if (vma->vm_flags & VM_READ)
> +		event = MMU_MPROT_RONLY;

hmmm, shouldn't we be checking against the newprot argument, instead of 
against vm->vm_flags?  The calling code, mprotect_fixup for example, can 
set flags *other* than VM_READ or RM_WRITE, and that could leave to a 
confusing or even inaccurate event. We could have a case where the event 
type is MMU_MPROT_RONLY, but the page might have been read-only the entire 
time, and some other flag was actually getting set.

I'm also starting to wonder if this event is adding much value here (for 
protection changes), if the newprot argument contains the same 
information. Although it is important to have a unified sort of reporting 
system for HMM, so that's probably good enough reason to do this.

>  
>  	if (is_vm_hugetlb_page(vma))
> -		pages = hugetlb_change_protection(vma, start, end, newprot);
> +		pages = hugetlb_change_protection(vma, start, end,
> +						  newprot, event);
>  	else
> -		pages = change_protection_range(vma, start, end, newprot, dirty_accountable, prot_numa);
> +		pages = change_protection_range(vma, start, end, newprot,
> +						dirty_accountable,
> +						prot_numa, event);
>  
>  	return pages;
>  }
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 05f1180..6827d2f 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -177,7 +177,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  
>  	mmun_start = old_addr;
>  	mmun_end   = old_end;
> -	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start,
> +					    mmun_end, MMU_MIGRATE);
>  
>  	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
>  		cond_resched();
> @@ -228,7 +229,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  	if (likely(need_flush))
>  		flush_tlb_range(vma, old_end-len, old_addr);
>  
> -	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start,
> +					  mmun_end, MMU_MIGRATE);
>  
>  	return len + old_addr - old_end;	/* how much done */
>  }
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 7928ddd..bd7e6d7 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -840,7 +840,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  	pte_unmap_unlock(pte, ptl);
>  
>  	if (ret) {
> -		mmu_notifier_invalidate_page(mm, address);
> +		mmu_notifier_invalidate_page(mm, address, MMU_WB);
>  		(*cleaned)++;
>  	}
>  out:
> @@ -1128,6 +1128,10 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	spinlock_t *ptl;
>  	int ret = SWAP_AGAIN;
>  	enum ttu_flags flags = (enum ttu_flags)arg;
> +	enum mmu_event event = MMU_MIGRATE;
> +
> +	if (flags & TTU_MUNLOCK)
> +		event = MMU_STATUS;
>  
>  	pte = page_check_address(page, mm, address, &ptl, 0);
>  	if (!pte)
> @@ -1233,7 +1237,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  out_unmap:
>  	pte_unmap_unlock(pte, ptl);
>  	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
> -		mmu_notifier_invalidate_page(mm, address);
> +		mmu_notifier_invalidate_page(mm, address, event);
>  out:
>  	return ret;
>  
> @@ -1287,7 +1291,9 @@ out_mlock:
>  #define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
>  
>  static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
> -		struct vm_area_struct *vma, struct page *check_page)
> +				struct vm_area_struct *vma,
> +				struct page *check_page,
> +				enum ttu_flags flags)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	pmd_t *pmd;
> @@ -1301,6 +1307,10 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>  	unsigned long end;
>  	int ret = SWAP_AGAIN;
>  	int locked_vma = 0;
> +	enum mmu_event event = MMU_MIGRATE;
> +
> +	if (flags & TTU_MUNLOCK)
> +		event = MMU_STATUS;
>  
>  	address = (vma->vm_start + cursor) & CLUSTER_MASK;
>  	end = address + CLUSTER_SIZE;
> @@ -1315,7 +1325,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>  
>  	mmun_start = address;
>  	mmun_end   = end;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, event);
>  
>  	/*
>  	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
> @@ -1380,7 +1390,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>  		(*mapcount)--;
>  	}
>  	pte_unmap_unlock(pte - 1, ptl);
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, event);
>  	if (locked_vma)
>  		up_read(&vma->vm_mm->mmap_sem);
>  	return ret;
> @@ -1436,7 +1446,9 @@ static int try_to_unmap_nonlinear(struct page *page,
>  			while (cursor < max_nl_cursor &&
>  				cursor < vma->vm_end - vma->vm_start) {
>  				if (try_to_unmap_cluster(cursor, &mapcount,
> -						vma, page) == SWAP_MLOCK)
> +							 vma, page,
> +							 (enum ttu_flags)arg)
> +							 == SWAP_MLOCK)
>  					ret = SWAP_MLOCK;
>  				cursor += CLUSTER_SIZE;
>  				vma->vm_private_data = (void *) cursor;
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 4b6c01b..6e1992f 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -262,7 +262,8 @@ static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
>  
>  static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
>  					     struct mm_struct *mm,
> -					     unsigned long address)
> +					     unsigned long address,
> +					     enum mmu_event event)
>  {
>  	struct kvm *kvm = mmu_notifier_to_kvm(mn);
>  	int need_tlb_flush, idx;
> @@ -301,7 +302,8 @@ static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
>  static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
>  					struct mm_struct *mm,
>  					unsigned long address,
> -					pte_t pte)
> +					pte_t pte,
> +					enum mmu_event event)
>  {
>  	struct kvm *kvm = mmu_notifier_to_kvm(mn);
>  	int idx;
> @@ -317,7 +319,8 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
>  static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
>  						    struct mm_struct *mm,
>  						    unsigned long start,
> -						    unsigned long end)
> +						    unsigned long end,
> +						    enum mmu_event event)
>  {
>  	struct kvm *kvm = mmu_notifier_to_kvm(mn);
>  	int need_tlb_flush = 0, idx;
> @@ -343,7 +346,8 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
>  static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
>  						  struct mm_struct *mm,
>  						  unsigned long start,
> -						  unsigned long end)
> +						  unsigned long end,
> +						  enum mmu_event event)
>  {
>  	struct kvm *kvm = mmu_notifier_to_kvm(mn);
>  
> -- 
> 1.9.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

thanks,
John H.
--279739828-505577760-1404105783=:21595--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
