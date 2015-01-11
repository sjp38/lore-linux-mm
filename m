Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B8D276B006C
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 07:40:06 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so25881822pdj.0
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 04:40:06 -0800 (PST)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bon0133.outbound.protection.outlook.com. [157.56.111.133])
        by mx.google.com with ESMTPS id wp13si20000419pac.230.2015.01.11.04.40.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 11 Jan 2015 04:40:04 -0800 (PST)
Message-ID: <54B26F0E.4020901@amd.com>
Date: Sun, 11 Jan 2015 14:39:42 +0200
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] mmu_notifier: add event information to address invalidation
 v6
References: <1420497889-10088-1-git-send-email-j.glisse@gmail.com>
 <1420497889-10088-2-git-send-email-j.glisse@gmail.com>
 <54B26B61.9070400@amd.com>
In-Reply-To: <54B26B61.9070400@amd.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes
 Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van
 Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron
 Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul
 Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xp?= =?UTF-8?B?c3Nl?= <jglisse@redhat.com>



On 01/11/2015 02:24 PM, Oded Gabbay wrote:
>=20
>=20
> On 01/06/2015 12:44 AM, j.glisse@gmail.com wrote:
>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>
>> The event information will be useful for new user of mmu_notifier API.
>> The event argument differentiate between a vma disappearing, a page
>> being write protected or simply a page being unmaped. This allow new
>> user to take different path for different event for instance on unmap
>> the resource used to track a vma are still valid and should stay aroun=
d.
>> While if the event is saying that a vma is being destroy it means that=
 any
>> resources used to track this vma can be free.
>>
>> Changed since v1:
>>   - renamed action into event (updated commit message too).
>>   - simplified the event names and clarified their usage
>>     also documenting what exceptation the listener can have in
>>     respect to each event.
>>
>> Changed since v2:
>>   - Avoid crazy name.
>>   - Do not move code that do not need to move.
>>
>> Changed since v3:
>>   - Separate hugue page split from mlock/munlock and softdirty.
>>
>> Changed since v4:
>>   - Rebase (no other changes).
>>
>> Changed since v5:
>>   - Typo fix.
>>   - Changed zap_page_range from MMU_MUNMAP to MMU_MIGRATE to reflect t=
he
>>     fact that the address range is still valid just the page backing i=
t
>>     are no longer.
>>
>> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> Reviewed-by: Rik van Riel <riel@redhat.com>
>> ---
>>  drivers/gpu/drm/i915/i915_gem_userptr.c |   3 +-
>>  drivers/gpu/drm/radeon/radeon_mn.c      |   3 +-
>>  drivers/infiniband/core/umem_odp.c      |   9 ++-
>>  drivers/iommu/amd_iommu_v2.c            |   3 +-
>>  drivers/misc/sgi-gru/grutlbpurge.c      |   9 ++-
>>  drivers/xen/gntdev.c                    |   9 ++-
>>  fs/proc/task_mmu.c                      |   6 +-
>>  include/linux/mmu_notifier.h            | 131 +++++++++++++++++++++++=
+++------
>>  kernel/events/uprobes.c                 |  10 ++-
>>  mm/filemap_xip.c                        |   2 +-
>>  mm/huge_memory.c                        |  39 ++++++----
>>  mm/hugetlb.c                            |  23 +++---
>>  mm/ksm.c                                |  18 +++--
>>  mm/madvise.c                            |   4 +-
>>  mm/memory.c                             |  27 ++++---
>>  mm/migrate.c                            |   9 ++-
>>  mm/mmu_notifier.c                       |  28 ++++---
>>  mm/mprotect.c                           |   6 +-
>>  mm/mremap.c                             |   6 +-
>>  mm/rmap.c                               |  24 ++++--
>>  virt/kvm/kvm_main.c                     |  12 ++-
>>  21 files changed, 274 insertions(+), 107 deletions(-)
>>
>> diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm=
/i915/i915_gem_userptr.c
>> index d182058..20dbd26 100644
>> --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
>> +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
>> @@ -129,7 +129,8 @@ restart:
>>  static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_not=
ifier *_mn,
>>  						       struct mm_struct *mm,
>>  						       unsigned long start,
>> -						       unsigned long end)
>> +						       unsigned long end,
>> +						       enum mmu_event event)
>>  {
>>  	struct i915_mmu_notifier *mn =3D container_of(_mn, struct i915_mmu_n=
otifier, mn);
>>  	struct interval_tree_node *it =3D NULL;
>> diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/rade=
on/radeon_mn.c
>> index a69bd44..daf53d3 100644
>> --- a/drivers/gpu/drm/radeon/radeon_mn.c
>> +++ b/drivers/gpu/drm/radeon/radeon_mn.c
>> @@ -109,7 +109,8 @@ static void radeon_mn_release(struct mmu_notifier =
*mn,
>>  static void radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
>>  					     struct mm_struct *mm,
>>  					     unsigned long start,
>> -					     unsigned long end)
>> +					     unsigned long end,
>> +					     enum mmu_event event)
>>  {
>>  	struct radeon_mn *rmn =3D container_of(mn, struct radeon_mn, mn);
>>  	struct interval_tree_node *it;
>> diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/c=
ore/umem_odp.c
>> index 6095872..bc36e8c 100644
>> --- a/drivers/infiniband/core/umem_odp.c
>> +++ b/drivers/infiniband/core/umem_odp.c
>> @@ -165,7 +165,8 @@ static int invalidate_page_trampoline(struct ib_um=
em *item, u64 start,
>> =20
>>  static void ib_umem_notifier_invalidate_page(struct mmu_notifier *mn,
>>  					     struct mm_struct *mm,
>> -					     unsigned long address)
>> +					     unsigned long address,
>> +					     enum mmu_event event)
>>  {
>>  	struct ib_ucontext *context =3D container_of(mn, struct ib_ucontext,=
 mn);
>> =20
>> @@ -192,7 +193,8 @@ static int invalidate_range_start_trampoline(struc=
t ib_umem *item, u64 start,
>>  static void ib_umem_notifier_invalidate_range_start(struct mmu_notifi=
er *mn,
>>  						    struct mm_struct *mm,
>>  						    unsigned long start,
>> -						    unsigned long end)
>> +						    unsigned long end,
>> +						    enum mmu_event event)
>>  {
>>  	struct ib_ucontext *context =3D container_of(mn, struct ib_ucontext,=
 mn);
>> =20
>> @@ -217,7 +219,8 @@ static int invalidate_range_end_trampoline(struct =
ib_umem *item, u64 start,
>>  static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier=
 *mn,
>>  						  struct mm_struct *mm,
>>  						  unsigned long start,
>> -						  unsigned long end)
>> +						  unsigned long end,
>> +						  enum mmu_event event)
>>  {
>>  	struct ib_ucontext *context =3D container_of(mn, struct ib_ucontext,=
 mn);
>> =20
>> diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2=
.c
>> index 90f70d0..31acb07 100644
>> --- a/drivers/iommu/amd_iommu_v2.c
>> +++ b/drivers/iommu/amd_iommu_v2.c
>> @@ -402,7 +402,8 @@ static int mn_clear_flush_young(struct mmu_notifie=
r *mn,
>> =20
>>  static void mn_invalidate_page(struct mmu_notifier *mn,
>>  			       struct mm_struct *mm,
>> -			       unsigned long address)
>> +			       unsigned long address,
>> +			       enum mmu_event event)
>>  {
>>  	__mn_flush_page(mn, address);
>>  }
>> diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru=
/grutlbpurge.c
>> index 2129274..e67fed1 100644
>> --- a/drivers/misc/sgi-gru/grutlbpurge.c
>> +++ b/drivers/misc/sgi-gru/grutlbpurge.c
>> @@ -221,7 +221,8 @@ void gru_flush_all_tlb(struct gru_state *gru)
>>   */
>>  static void gru_invalidate_range_start(struct mmu_notifier *mn,
>>  				       struct mm_struct *mm,
>> -				       unsigned long start, unsigned long end)
>> +				       unsigned long start, unsigned long end,
>> +				       enum mmu_event event)
>>  {
>>  	struct gru_mm_struct *gms =3D container_of(mn, struct gru_mm_struct,
>>  						 ms_notifier);
>> @@ -235,7 +236,8 @@ static void gru_invalidate_range_start(struct mmu_=
notifier *mn,
>> =20
>>  static void gru_invalidate_range_end(struct mmu_notifier *mn,
>>  				     struct mm_struct *mm, unsigned long start,
>> -				     unsigned long end)
>> +				     unsigned long end,
>> +				     enum mmu_event event)
>>  {
>>  	struct gru_mm_struct *gms =3D container_of(mn, struct gru_mm_struct,
>>  						 ms_notifier);
>> @@ -248,7 +250,8 @@ static void gru_invalidate_range_end(struct mmu_no=
tifier *mn,
>>  }
>> =20
>>  static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_st=
ruct *mm,
>> -				unsigned long address)
>> +				unsigned long address,
>> +				enum mmu_event event)
>>  {
>>  	struct gru_mm_struct *gms =3D container_of(mn, struct gru_mm_struct,
>>  						 ms_notifier);
>> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
>> index 073b4a1..fe9da94 100644
>> --- a/drivers/xen/gntdev.c
>> +++ b/drivers/xen/gntdev.c
>> @@ -428,7 +428,9 @@ static void unmap_if_in_range(struct grant_map *ma=
p,
>> =20
>>  static void mn_invl_range_start(struct mmu_notifier *mn,
>>  				struct mm_struct *mm,
>> -				unsigned long start, unsigned long end)
>> +				unsigned long start,
>> +				unsigned long end,
>> +				enum mmu_event event)
>>  {
>>  	struct gntdev_priv *priv =3D container_of(mn, struct gntdev_priv, mn=
);
>>  	struct grant_map *map;
>> @@ -445,9 +447,10 @@ static void mn_invl_range_start(struct mmu_notifi=
er *mn,
>> =20
>>  static void mn_invl_page(struct mmu_notifier *mn,
>>  			 struct mm_struct *mm,
>> -			 unsigned long address)
>> +			 unsigned long address,
>> +			 enum mmu_event event)
>>  {
>> -	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE);
>> +	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE, event);
>>  }
>> =20
>>  static void mn_release(struct mmu_notifier *mn,
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index 246eae8..8a79a74 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -875,7 +875,8 @@ static ssize_t clear_refs_write(struct file *file,=
 const char __user *buf,
>>  				downgrade_write(&mm->mmap_sem);
>>  				break;
>>  			}
>> -			mmu_notifier_invalidate_range_start(mm, 0, -1);
>> +			mmu_notifier_invalidate_range_start(mm, 0,
>> +							    -1, MMU_ISDIRTY);
>>  		}
>>  		for (vma =3D mm->mmap; vma; vma =3D vma->vm_next) {
>>  			cp.vma =3D vma;
>> @@ -900,7 +901,8 @@ static ssize_t clear_refs_write(struct file *file,=
 const char __user *buf,
>>  					&clear_refs_walk);
>>  		}
>>  		if (type =3D=3D CLEAR_REFS_SOFT_DIRTY)
>> -			mmu_notifier_invalidate_range_end(mm, 0, -1);
>> +			mmu_notifier_invalidate_range_end(mm, 0,
>> +							  -1, MMU_ISDIRTY);
>>  		flush_tlb_mm(mm);
>>  		up_read(&mm->mmap_sem);
>>  		mmput(mm);
>> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier=
.h
>> index 95243d2..ac2a121 100644
>> --- a/include/linux/mmu_notifier.h
>> +++ b/include/linux/mmu_notifier.h
>> @@ -9,6 +9,66 @@
>>  struct mmu_notifier;
>>  struct mmu_notifier_ops;
>> =20
>> +/* MMU Events report fine-grained information to the callback routine=
, allowing
>> + * the event listener to make a more informed decision as to what act=
ion to
>> + * take. The event types are:
>> + *
>> + *   - MMU_HSPLIT huge page split, the memory is the same only the pa=
ge table
>> + *     structure is updated (level added or removed).
>> + *
>> + *   - MMU_ISDIRTY need to update the dirty bit of the page table so =
proper
>> + *     dirty accounting can happen.
>> + *
>> + *   - MMU_MIGRATE: memory is migrating from one page to another, thu=
s all write
>> + *     access must stop after invalidate_range_start callback returns=
.
>> + *     Furthermore, no read access should be allowed either, as a new=
 page can
>> + *     be remapped with write access before the invalidate_range_end =
callback
>> + *     happens and thus any read access to old page might read stale =
data. There
>> + *     are several sources for this event, including:
>> + *
>> + *         - A page moving to swap (various reasons, including page r=
eclaim),
>> + *         - An mremap syscall,
>> + *         - migration for NUMA reasons,
>> + *         - balancing the memory pool,
>> + *         - write fault on COW page,
>> + *         - and more that are not listed here.
>> + *
>> + *   - MMU_MPROT: memory access protection is changing. Refer to the =
vma to get
>> + *     the new access protection. All memory access are still valid u=
ntil the
>> + *     invalidate_range_end callback.
>> + *
>> + *   - MMU_MUNLOCK: unlock memory. Content of page table stays the sa=
me but
>> + *     page are unlocked.
>> + *
>> + *   - MMU_MUNMAP: the range is being unmapped (outcome of a munmap s=
yscall or
>> + *     process destruction). However, access is still allowed, up unt=
il the
>> + *     invalidate_range_free_pages callback. This also implies that s=
econdary
>> + *     page table can be trimmed, because the address range is no lon=
ger valid.
>> + *
>> + *   - MMU_WRITE_BACK: memory is being written back to disk, all writ=
e accesses
>> + *     must stop after invalidate_range_start callback returns. Read =
access are
>> + *     still allowed.
>> + *
>> + *   - MMU_WRITE_PROTECT: memory is being write protected (ie should =
be mapped
>> + *     read only no matter what the vma memory protection allows). Al=
l write
>> + *     accesses must stop after invalidate_range_start callback retur=
ns. Read
>> + *     access are still allowed.
>> + *
>> + * If in doubt when adding a new notifier caller, please use MMU_MIGR=
ATE,
>> + * because it will always lead to reasonable behavior, but will not a=
llow the
>> + * listener a chance to optimize its events.
>> + */
>> +enum mmu_event {
>> +	MMU_HSPLIT =3D 0,
>> +	MMU_ISDIRTY,
>> +	MMU_MIGRATE,
>> +	MMU_MPROT,
>> +	MMU_MUNLOCK,
>> +	MMU_MUNMAP,
>> +	MMU_WRITE_BACK,
>> +	MMU_WRITE_PROTECT,
>> +};
>> +
>>  #ifdef CONFIG_MMU_NOTIFIER
>> =20
>>  /*
>> @@ -82,7 +142,8 @@ struct mmu_notifier_ops {
>>  	void (*change_pte)(struct mmu_notifier *mn,
>>  			   struct mm_struct *mm,
>>  			   unsigned long address,
>> -			   pte_t pte);
>> +			   pte_t pte,
>> +			   enum mmu_event event);
>> =20
>>  	/*
>>  	 * Before this is invoked any secondary MMU is still ok to
>> @@ -93,7 +154,8 @@ struct mmu_notifier_ops {
>>  	 */
>>  	void (*invalidate_page)(struct mmu_notifier *mn,
>>  				struct mm_struct *mm,
>> -				unsigned long address);
>> +				unsigned long address,
>> +				enum mmu_event event);
>> =20
>>  	/*
>>  	 * invalidate_range_start() and invalidate_range_end() must be
>> @@ -140,10 +202,14 @@ struct mmu_notifier_ops {
>>  	 */
>>  	void (*invalidate_range_start)(struct mmu_notifier *mn,
>>  				       struct mm_struct *mm,
>> -				       unsigned long start, unsigned long end);
>> +				       unsigned long start,
>> +				       unsigned long end,
>> +				       enum mmu_event event);
>>  	void (*invalidate_range_end)(struct mmu_notifier *mn,
>>  				     struct mm_struct *mm,
>> -				     unsigned long start, unsigned long end);
>> +				     unsigned long start,
>> +				     unsigned long end,
>> +				     enum mmu_event event);
>> =20
>>  	/*
>>  	 * invalidate_range() is either called between
>> @@ -206,13 +272,20 @@ extern int __mmu_notifier_clear_flush_young(stru=
ct mm_struct *mm,
>>  extern int __mmu_notifier_test_young(struct mm_struct *mm,
>>  				     unsigned long address);
>>  extern void __mmu_notifier_change_pte(struct mm_struct *mm,
>> -				      unsigned long address, pte_t pte);
>> +				      unsigned long address,
>> +				      pte_t pte,
>> +				      enum mmu_event event);
>>  extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
>> -					  unsigned long address);
>> +					  unsigned long address,
>> +					  enum mmu_event event);
>>  extern void __mmu_notifier_invalidate_range_start(struct mm_struct *m=
m,
>> -				  unsigned long start, unsigned long end);
>> +						  unsigned long start,
>> +						  unsigned long end,
>> +						  enum mmu_event event);
>>  extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>> -				  unsigned long start, unsigned long end);
>> +						unsigned long start,
>> +						unsigned long end,
>> +						enum mmu_event event);
>>  extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
>>  				  unsigned long start, unsigned long end);
>> =20
>> @@ -240,31 +313,38 @@ static inline int mmu_notifier_test_young(struct=
 mm_struct *mm,
>>  }
>> =20
>>  static inline void mmu_notifier_change_pte(struct mm_struct *mm,
>> -					   unsigned long address, pte_t pte)
>> +					   unsigned long address,
>> +					   pte_t pte,
>> +					   enum mmu_event event)
>>  {
>>  	if (mm_has_notifiers(mm))
>> -		__mmu_notifier_change_pte(mm, address, pte);
>> +		__mmu_notifier_change_pte(mm, address, pte, event);
>>  }
>> =20
>>  static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
>> -					  unsigned long address)
>> +						unsigned long address,
>> +						enum mmu_event event)
>>  {
>>  	if (mm_has_notifiers(mm))
>> -		__mmu_notifier_invalidate_page(mm, address);
>> +		__mmu_notifier_invalidate_page(mm, address, event);
>>  }
>> =20
>>  static inline void mmu_notifier_invalidate_range_start(struct mm_stru=
ct *mm,
>> -				  unsigned long start, unsigned long end)
>> +						       unsigned long start,
>> +						       unsigned long end,
>> +						       enum mmu_event event)
>>  {
>>  	if (mm_has_notifiers(mm))
>> -		__mmu_notifier_invalidate_range_start(mm, start, end);
>> +		__mmu_notifier_invalidate_range_start(mm, start, end, event);
>>  }
>> =20
>>  static inline void mmu_notifier_invalidate_range_end(struct mm_struct=
 *mm,
>> -				  unsigned long start, unsigned long end)
>> +						     unsigned long start,
>> +						     unsigned long end,
>> +						     enum mmu_event event)
>>  {
>>  	if (mm_has_notifiers(mm))
>> -		__mmu_notifier_invalidate_range_end(mm, start, end);
>> +		__mmu_notifier_invalidate_range_end(mm, start, end, event);
>>  }
>> =20
>>  static inline void mmu_notifier_invalidate_range(struct mm_struct *mm=
,
>> @@ -359,13 +439,13 @@ static inline void mmu_notifier_mm_destroy(struc=
t mm_struct *mm)
>>   * old page would remain mapped readonly in the secondary MMUs after =
the new
>>   * page is already writable by some CPU through the primary MMU.
>>   */
>> -#define set_pte_at_notify(__mm, __address, __ptep, __pte)		\
>> +#define set_pte_at_notify(__mm, __address, __ptep, __pte, __event)	\
>>  ({									\
>>  	struct mm_struct *___mm =3D __mm;					\
>>  	unsigned long ___address =3D __address;				\
>>  	pte_t ___pte =3D __pte;						\
>>  									\
>> -	mmu_notifier_change_pte(___mm, ___address, ___pte);		\
>> +	mmu_notifier_change_pte(___mm, ___address, ___pte, __event);	\
>>  	set_pte_at(___mm, ___address, __ptep, ___pte);			\
>>  })
>> =20
>> @@ -393,22 +473,29 @@ static inline int mmu_notifier_test_young(struct=
 mm_struct *mm,
>>  }
>> =20
>>  static inline void mmu_notifier_change_pte(struct mm_struct *mm,
>> -					   unsigned long address, pte_t pte)
>> +					   unsigned long address,
>> +					   pte_t pte,
>> +					   enum mmu_event event)
>>  {
>>  }
>> =20
>>  static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
>> -					  unsigned long address)
>> +						unsigned long address,
>> +						enum mmu_event event)
>>  {
>>  }
>> =20
>>  static inline void mmu_notifier_invalidate_range_start(struct mm_stru=
ct *mm,
>> -				  unsigned long start, unsigned long end)
>> +						       unsigned long start,
>> +						       unsigned long end,
>> +						       enum mmu_event event)
>>  {
>>  }
>> =20
>>  static inline void mmu_notifier_invalidate_range_end(struct mm_struct=
 *mm,
>> -				  unsigned long start, unsigned long end)
>> +						     unsigned long start,
>> +						     unsigned long end,
>> +						     enum mmu_event event)
>>  {
>>  }
>> =20
>> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
>> index cb346f2..802828a 100644
>> --- a/kernel/events/uprobes.c
>> +++ b/kernel/events/uprobes.c
>> @@ -176,7 +176,8 @@ static int __replace_page(struct vm_area_struct *v=
ma, unsigned long addr,
>>  	/* For try_to_free_swap() and munlock_vma_page() below */
>>  	lock_page(page);
>> =20
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
>> +					    mmun_end, MMU_MIGRATE);
>>  	err =3D -EAGAIN;
>>  	ptep =3D page_check_address(page, mm, addr, &ptl, 0);
>>  	if (!ptep)
>> @@ -194,7 +195,9 @@ static int __replace_page(struct vm_area_struct *v=
ma, unsigned long addr,
>> =20
>>  	flush_cache_page(vma, addr, pte_pfn(*ptep));
>>  	ptep_clear_flush_notify(vma, addr, ptep);
>> -	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
>> +	set_pte_at_notify(mm, addr, ptep,
>> +			  mk_pte(kpage, vma->vm_page_prot),
>> +			  MMU_MIGRATE);
>> =20
>>  	page_remove_rmap(page);
>>  	if (!page_mapped(page))
>> @@ -208,7 +211,8 @@ static int __replace_page(struct vm_area_struct *v=
ma, unsigned long addr,
>>  	err =3D 0;
>>   unlock:
>>  	mem_cgroup_cancel_charge(kpage, memcg);
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +					  mmun_end, MMU_MIGRATE);
>>  	unlock_page(page);
>>  	return err;
>>  }
>> diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
>> index 0d105ae..fb97c7c 100644
>> --- a/mm/filemap_xip.c
>> +++ b/mm/filemap_xip.c
>> @@ -193,7 +193,7 @@ retry:
>>  			BUG_ON(pte_dirty(pteval));
>>  			pte_unmap_unlock(pte, ptl);
>>  			/* must invalidate_page _before_ freeing the page */
>> -			mmu_notifier_invalidate_page(mm, address);
>> +			mmu_notifier_invalidate_page(mm, address, MMU_MIGRATE);
>>  			page_cache_release(page);
>>  		}
>>  	}
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index cf3b67b..75eb651 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1028,7 +1028,8 @@ static int do_huge_pmd_wp_page_fallback(struct m=
m_struct *mm,
>> =20
>>  	mmun_start =3D haddr;
>>  	mmun_end   =3D haddr + HPAGE_PMD_SIZE;
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
>> +					    MMU_MIGRATE);
>> =20
>>  	ptl =3D pmd_lock(mm, pmd);
>>  	if (unlikely(!pmd_same(*pmd, orig_pmd)))
>> @@ -1062,7 +1063,8 @@ static int do_huge_pmd_wp_page_fallback(struct m=
m_struct *mm,
>>  	page_remove_rmap(page);
>>  	spin_unlock(ptl);
>> =20
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +					  mmun_end, MMU_MIGRATE);
>> =20
>>  	ret |=3D VM_FAULT_WRITE;
>>  	put_page(page);
>> @@ -1072,7 +1074,8 @@ out:
>> =20
>>  out_free_pages:
>>  	spin_unlock(ptl);
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +					  mmun_end, MMU_MIGRATE);
>>  	for (i =3D 0; i < HPAGE_PMD_NR; i++) {
>>  		memcg =3D (void *)page_private(pages[i]);
>>  		set_page_private(pages[i], 0);
>> @@ -1164,7 +1167,8 @@ alloc:
>> =20
>>  	mmun_start =3D haddr;
>>  	mmun_end   =3D haddr + HPAGE_PMD_SIZE;
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
>> +					    MMU_MIGRATE);
>> =20
>>  	spin_lock(ptl);
>>  	if (page)
>> @@ -1196,7 +1200,8 @@ alloc:
>>  	}
>>  	spin_unlock(ptl);
>>  out_mn:
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +					  mmun_end, MMU_MIGRATE);
>>  out:
>>  	return ret;
>>  out_unlock:
>> @@ -1667,7 +1672,8 @@ static int __split_huge_page_splitting(struct pa=
ge *page,
>>  	const unsigned long mmun_start =3D address;
>>  	const unsigned long mmun_end   =3D address + HPAGE_PMD_SIZE;
>> =20
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
>> +					    mmun_end, MMU_HSPLIT);
>>  	pmd =3D page_check_address_pmd(page, mm, address,
>>  			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
>>  	if (pmd) {
>> @@ -1683,7 +1689,8 @@ static int __split_huge_page_splitting(struct pa=
ge *page,
>>  		ret =3D 1;
>>  		spin_unlock(ptl);
>>  	}
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +					  mmun_end, MMU_HSPLIT);
>> =20
>>  	return ret;
>>  }
>> @@ -2504,7 +2511,8 @@ static void collapse_huge_page(struct mm_struct =
*mm,
>> =20
>>  	mmun_start =3D address;
>>  	mmun_end   =3D address + HPAGE_PMD_SIZE;
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
>> +					    mmun_end, MMU_MIGRATE);
>>  	pmd_ptl =3D pmd_lock(mm, pmd); /* probably unnecessary */
>>  	/*
>>  	 * After this gup_fast can't run anymore. This also removes
>> @@ -2514,7 +2522,8 @@ static void collapse_huge_page(struct mm_struct =
*mm,
>>  	 */
>>  	_pmd =3D pmdp_clear_flush(vma, address, pmd);
>>  	spin_unlock(pmd_ptl);
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +					  mmun_end, MMU_MIGRATE);
>> =20
>>  	spin_lock(pte_ptl);
>>  	isolated =3D __collapse_huge_page_isolate(vma, address, pte);
>> @@ -2905,24 +2914,28 @@ void __split_huge_page_pmd(struct vm_area_stru=
ct *vma, unsigned long address,
>>  	mmun_start =3D haddr;
>>  	mmun_end   =3D haddr + HPAGE_PMD_SIZE;
>>  again:
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
>> +					    mmun_end, MMU_MIGRATE);
>>  	ptl =3D pmd_lock(mm, pmd);
>>  	if (unlikely(!pmd_trans_huge(*pmd))) {
>>  		spin_unlock(ptl);
>> -		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +		mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +						  mmun_end, MMU_MIGRATE);
>>  		return;
>>  	}
>>  	if (is_huge_zero_pmd(*pmd)) {
>>  		__split_huge_zero_page_pmd(vma, haddr, pmd);
>>  		spin_unlock(ptl);
>> -		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +		mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +						  mmun_end, MMU_MIGRATE);
>>  		return;
>>  	}
>>  	page =3D pmd_page(*pmd);
>>  	VM_BUG_ON_PAGE(!page_count(page), page);
>>  	get_page(page);
>>  	spin_unlock(ptl);
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +					  mmun_end, MMU_MIGRATE);
>> =20
>>  	split_huge_page(page);
>> =20
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 85032de..b4770c4 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -2560,7 +2560,8 @@ int copy_hugetlb_page_range(struct mm_struct *ds=
t, struct mm_struct *src,
>>  	mmun_start =3D vma->vm_start;
>>  	mmun_end =3D vma->vm_end;
>>  	if (cow)
>> -		mmu_notifier_invalidate_range_start(src, mmun_start, mmun_end);
>> +		mmu_notifier_invalidate_range_start(src, mmun_start,
>> +						    mmun_end, MMU_MIGRATE);
>> =20
>>  	for (addr =3D vma->vm_start; addr < vma->vm_end; addr +=3D sz) {
>>  		spinlock_t *src_ptl, *dst_ptl;
>> @@ -2614,7 +2615,8 @@ int copy_hugetlb_page_range(struct mm_struct *ds=
t, struct mm_struct *src,
>>  	}
>> =20
>>  	if (cow)
>> -		mmu_notifier_invalidate_range_end(src, mmun_start, mmun_end);
>> +		mmu_notifier_invalidate_range_end(src, mmun_start,
>> +						  mmun_end, MMU_MIGRATE);
>> =20
>>  	return ret;
>>  }
>> @@ -2640,7 +2642,8 @@ void __unmap_hugepage_range(struct mmu_gather *t=
lb, struct vm_area_struct *vma,
>>  	BUG_ON(end & ~huge_page_mask(h));
>> =20
>>  	tlb_start_vma(tlb, vma);
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
>> +					    mmun_end, MMU_MIGRATE);
>>  	address =3D start;
>>  again:
>>  	for (; address < end; address +=3D sz) {
>> @@ -2713,7 +2716,8 @@ unlock:
>>  		if (address < end && !ref_page)
>>  			goto again;
>>  	}
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +					  mmun_end, MMU_MIGRATE);
>>  	tlb_end_vma(tlb, vma);
>>  }
>> =20
>> @@ -2891,8 +2895,8 @@ retry_avoidcopy:
>> =20
>>  	mmun_start =3D address & huge_page_mask(h);
>>  	mmun_end =3D mmun_start + huge_page_size(h);
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> -
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
>> +					    MMU_MIGRATE);
>>  	/*
>>  	 * Retake the page table lock to check for racing updates
>>  	 * before the page tables are altered
>> @@ -2913,7 +2917,8 @@ retry_avoidcopy:
>>  		new_page =3D old_page;
>>  	}
>>  	spin_unlock(ptl);
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
>> +					  MMU_MIGRATE);
>>  out_release_all:
>>  	page_cache_release(new_page);
>>  out_release_old:
>> @@ -3351,7 +3356,7 @@ unsigned long hugetlb_change_protection(struct v=
m_area_struct *vma,
>>  	BUG_ON(address >=3D end);
>>  	flush_cache_range(vma, address, end);
>> =20
>> -	mmu_notifier_invalidate_range_start(mm, start, end);
>> +	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MPROT);
>>  	i_mmap_lock_write(vma->vm_file->f_mapping);
>>  	for (; address < end; address +=3D huge_page_size(h)) {
>>  		spinlock_t *ptl;
>> @@ -3382,7 +3387,7 @@ unsigned long hugetlb_change_protection(struct v=
m_area_struct *vma,
>>  	flush_tlb_range(vma, start, end);
>>  	mmu_notifier_invalidate_range(mm, start, end);
>>  	i_mmap_unlock_write(vma->vm_file->f_mapping);
>> -	mmu_notifier_invalidate_range_end(mm, start, end);
>> +	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MPROT);
>> =20
>>  	return pages << h->order;
>>  }
>> diff --git a/mm/ksm.c b/mm/ksm.c
>> index d247efa..8c3a892 100644
>> --- a/mm/ksm.c
>> +++ b/mm/ksm.c
>> @@ -872,7 +872,8 @@ static int write_protect_page(struct vm_area_struc=
t *vma, struct page *page,
>> =20
>>  	mmun_start =3D addr;
>>  	mmun_end   =3D addr + PAGE_SIZE;
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
>> +					    MMU_WRITE_PROTECT);
>> =20
>>  	ptep =3D page_check_address(page, mm, addr, &ptl, 0);
>>  	if (!ptep)
>> @@ -904,7 +905,7 @@ static int write_protect_page(struct vm_area_struc=
t *vma, struct page *page,
>>  		if (pte_dirty(entry))
>>  			set_page_dirty(page);
>>  		entry =3D pte_mkclean(pte_wrprotect(entry));
>> -		set_pte_at_notify(mm, addr, ptep, entry);
>> +		set_pte_at_notify(mm, addr, ptep, entry, MMU_WRITE_PROTECT);
>>  	}
>>  	*orig_pte =3D *ptep;
>>  	err =3D 0;
>> @@ -912,7 +913,8 @@ static int write_protect_page(struct vm_area_struc=
t *vma, struct page *page,
>>  out_unlock:
>>  	pte_unmap_unlock(ptep, ptl);
>>  out_mn:
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
>> +					  MMU_WRITE_PROTECT);
>>  out:
>>  	return err;
>>  }
>> @@ -948,7 +950,8 @@ static int replace_page(struct vm_area_struct *vma=
, struct page *page,
>> =20
>>  	mmun_start =3D addr;
>>  	mmun_end   =3D addr + PAGE_SIZE;
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
>> +					    MMU_MIGRATE);
>> =20
>>  	ptep =3D pte_offset_map_lock(mm, pmd, addr, &ptl);
>>  	if (!pte_same(*ptep, orig_pte)) {
>> @@ -961,7 +964,9 @@ static int replace_page(struct vm_area_struct *vma=
, struct page *page,
>> =20
>>  	flush_cache_page(vma, addr, pte_pfn(*ptep));
>>  	ptep_clear_flush_notify(vma, addr, ptep);
>> -	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
>> +	set_pte_at_notify(mm, addr, ptep,
>> +			  mk_pte(kpage, vma->vm_page_prot),
>> +			  MMU_MIGRATE);
>> =20
>>  	page_remove_rmap(page);
>>  	if (!page_mapped(page))
>> @@ -971,7 +976,8 @@ static int replace_page(struct vm_area_struct *vma=
, struct page *page,
>>  	pte_unmap_unlock(ptep, ptl);
>>  	err =3D 0;
>>  out_mn:
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
>> +					  MMU_MIGRATE);
>>  out:
>>  	return err;
>>  }
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index 6fc9b82..d7ac37a 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -376,9 +376,9 @@ static int madvise_free_single_vma(struct vm_area_=
struct *vma,
>>  	tlb_gather_mmu(&tlb, mm, start, end);
>>  	update_hiwater_rss(mm);
>> =20
>> -	mmu_notifier_invalidate_range_start(mm, start, end);
>> +	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MUNMAP);
>>  	madvise_free_page_range(&tlb, vma, start, end);
>> -	mmu_notifier_invalidate_range_end(mm, start, end);
>> +	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MUNMAP);
>>  	tlb_finish_mmu(&tlb, start, end);
>> =20
>>  	return 0;
>> diff --git a/mm/memory.c b/mm/memory.c
>> index eacfafc..c184ee9 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1050,7 +1050,7 @@ int copy_page_range(struct mm_struct *dst_mm, st=
ruct mm_struct *src_mm,
>>  	mmun_end   =3D end;
>>  	if (is_cow)
>>  		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
>> -						    mmun_end);
>> +						    mmun_end, MMU_MIGRATE);
>> =20
>>  	ret =3D 0;
>>  	dst_pgd =3D pgd_offset(dst_mm, addr);
>> @@ -1067,7 +1067,8 @@ int copy_page_range(struct mm_struct *dst_mm, st=
ruct mm_struct *src_mm,
>>  	} while (dst_pgd++, src_pgd++, addr =3D next, addr !=3D end);
>> =20
>>  	if (is_cow)
>> -		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end);
>> +		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end,
>> +						  MMU_MIGRATE);
>>  	return ret;
>>  }
>> =20
>> @@ -1360,10 +1361,12 @@ void unmap_vmas(struct mmu_gather *tlb,
>>  {
>>  	struct mm_struct *mm =3D vma->vm_mm;
>> =20
>> -	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
>> +	mmu_notifier_invalidate_range_start(mm, start_addr,
>> +					    end_addr, MMU_MUNMAP);
>>  	for ( ; vma && vma->vm_start < end_addr; vma =3D vma->vm_next)
>>  		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
>> -	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
>> +	mmu_notifier_invalidate_range_end(mm, start_addr,
>> +					  end_addr, MMU_MUNMAP);
>>  }
>> =20
>>  /**
>> @@ -1385,10 +1388,10 @@ void zap_page_range(struct vm_area_struct *vma=
, unsigned long start,
>>  	lru_add_drain();
>>  	tlb_gather_mmu(&tlb, mm, start, end);
>>  	update_hiwater_rss(mm);
>> -	mmu_notifier_invalidate_range_start(mm, start, end);
>> +	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MIGRATE);
>>  	for ( ; vma && vma->vm_start < end; vma =3D vma->vm_next)
>>  		unmap_single_vma(&tlb, vma, start, end, details);
>> -	mmu_notifier_invalidate_range_end(mm, start, end);
>> +	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MIGRATE);
>>  	tlb_finish_mmu(&tlb, start, end);
>>  }
>> =20
>> @@ -1411,9 +1414,9 @@ static void zap_page_range_single(struct vm_area=
_struct *vma, unsigned long addr
>>  	lru_add_drain();
>>  	tlb_gather_mmu(&tlb, mm, address, end);
>>  	update_hiwater_rss(mm);
>> -	mmu_notifier_invalidate_range_start(mm, address, end);
>> +	mmu_notifier_invalidate_range_start(mm, address, end, MMU_MUNMAP);
>>  	unmap_single_vma(&tlb, vma, address, end, details);
>> -	mmu_notifier_invalidate_range_end(mm, address, end);
>> +	mmu_notifier_invalidate_range_end(mm, address, end, MMU_MUNMAP);
>>  	tlb_finish_mmu(&tlb, address, end);
>>  }
>> =20
>> @@ -2198,7 +2201,8 @@ gotten:
>> =20
>>  	mmun_start  =3D address & PAGE_MASK;
>>  	mmun_end    =3D mmun_start + PAGE_SIZE;
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
>> +					    mmun_end, MMU_MIGRATE);
>> =20
>>  	/*
>>  	 * Re-check the pte - we dropped the lock
>> @@ -2230,7 +2234,7 @@ gotten:
>>  		 * mmu page tables (such as kvm shadow page tables), we want the
>>  		 * new page to be mapped directly into the secondary page table.
>>  		 */
>> -		set_pte_at_notify(mm, address, page_table, entry);
>> +		set_pte_at_notify(mm, address, page_table, entry, MMU_MIGRATE);
>>  		update_mmu_cache(vma, address, page_table);
>>  		if (old_page) {
>>  			/*
>> @@ -2269,7 +2273,8 @@ gotten:
>>  unlock:
>>  	pte_unmap_unlock(page_table, ptl);
>>  	if (mmun_end > mmun_start)
>> -		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +		mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +						  mmun_end, MMU_MIGRATE);
>>  	if (old_page) {
>>  		/*
>>  		 * Don't let another task, with possibly unlocked vma,
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index 344cdf6..254d5bf 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -1801,12 +1801,14 @@ int migrate_misplaced_transhuge_page(struct mm=
_struct *mm,
>>  	WARN_ON(PageLRU(new_page));
>> =20
>>  	/* Recheck the target PMD */
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start,
>> +					    mmun_end, MMU_MIGRATE);
>>  	ptl =3D pmd_lock(mm, pmd);
>>  	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) !=3D 2)) {
>>  fail_putback:
>>  		spin_unlock(ptl);
>> -		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +		mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +						  mmun_end, MMU_MIGRATE);
>> =20
>>  		/* Reverse changes made by migrate_page_copy() */
>>  		if (TestClearPageActive(new_page))
>> @@ -1860,7 +1862,8 @@ fail_putback:
>>  	page_remove_rmap(page);
>> =20
>>  	spin_unlock(ptl);
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start,
>> +					  mmun_end, MMU_MIGRATE);
>> =20
>>  	/* Take an "isolate" reference and put new page on the LRU. */
>>  	get_page(new_page);
>> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
>> index 3b9b3d0..e51ea02 100644
>> --- a/mm/mmu_notifier.c
>> +++ b/mm/mmu_notifier.c
>> @@ -142,8 +142,10 @@ int __mmu_notifier_test_young(struct mm_struct *m=
m,
>>  	return young;
>>  }
>> =20
>> -void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long ad=
dress,
>> -			       pte_t pte)
>> +void __mmu_notifier_change_pte(struct mm_struct *mm,
>> +			       unsigned long address,
>> +			       pte_t pte,
>> +			       enum mmu_event event)
>>  {
>>  	struct mmu_notifier *mn;
>>  	int id;
>> @@ -151,13 +153,14 @@ void __mmu_notifier_change_pte(struct mm_struct =
*mm, unsigned long address,
>>  	id =3D srcu_read_lock(&srcu);
>>  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>>  		if (mn->ops->change_pte)
>> -			mn->ops->change_pte(mn, mm, address, pte);
>> +			mn->ops->change_pte(mn, mm, address, pte, event);
>>  	}
>>  	srcu_read_unlock(&srcu, id);
>>  }
>> =20
>>  void __mmu_notifier_invalidate_page(struct mm_struct *mm,
>> -					  unsigned long address)
>> +				    unsigned long address,
>> +				    enum mmu_event event)
>>  {
>>  	struct mmu_notifier *mn;
>>  	int id;
>> @@ -165,13 +168,16 @@ void __mmu_notifier_invalidate_page(struct mm_st=
ruct *mm,
>>  	id =3D srcu_read_lock(&srcu);
>>  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>>  		if (mn->ops->invalidate_page)
>> -			mn->ops->invalidate_page(mn, mm, address);
>> +			mn->ops->invalidate_page(mn, mm, address, event);
>>  	}
>>  	srcu_read_unlock(&srcu, id);
>>  }
>> =20
>>  void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>> -				  unsigned long start, unsigned long end)
>> +					   unsigned long start,
>> +					   unsigned long end,
>> +					   enum mmu_event event)
>> +
>>  {
>>  	struct mmu_notifier *mn;
>>  	int id;
>> @@ -179,14 +185,17 @@ void __mmu_notifier_invalidate_range_start(struc=
t mm_struct *mm,
>>  	id =3D srcu_read_lock(&srcu);
>>  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>>  		if (mn->ops->invalidate_range_start)
>> -			mn->ops->invalidate_range_start(mn, mm, start, end);
>> +			mn->ops->invalidate_range_start(mn, mm, start,
>> +							end, event);
>>  	}
>>  	srcu_read_unlock(&srcu, id);
>>  }
>>  EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
>> =20
>>  void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>> -				  unsigned long start, unsigned long end)
>> +					 unsigned long start,
>> +					 unsigned long end,
>> +					 enum mmu_event event)
>>  {
>>  	struct mmu_notifier *mn;
>>  	int id;
>> @@ -204,7 +213,8 @@ void __mmu_notifier_invalidate_range_end(struct mm=
_struct *mm,
>>  		if (mn->ops->invalidate_range)
>>  			mn->ops->invalidate_range(mn, mm, start, end);
>>  		if (mn->ops->invalidate_range_end)
>> -			mn->ops->invalidate_range_end(mn, mm, start, end);
>> +			mn->ops->invalidate_range_end(mn, mm, start,
>> +						      end, event);
>>  	}
>>  	srcu_read_unlock(&srcu, id);
>>  }
>> diff --git a/mm/mprotect.c b/mm/mprotect.c
>> index ace9345..0f5dbfe 100644
>> --- a/mm/mprotect.c
>> +++ b/mm/mprotect.c
>> @@ -152,7 +152,8 @@ static inline unsigned long change_pmd_range(struc=
t vm_area_struct *vma,
>>  		/* invoke the mmu notifier if the pmd is populated */
>>  		if (!mni_start) {
>>  			mni_start =3D addr;
>> -			mmu_notifier_invalidate_range_start(mm, mni_start, end);
>> +			mmu_notifier_invalidate_range_start(mm, mni_start,
>> +							    end, MMU_MPROT);
>>  		}
>> =20
>>  		if (pmd_trans_huge(*pmd)) {
>> @@ -180,7 +181,8 @@ static inline unsigned long change_pmd_range(struc=
t vm_area_struct *vma,
>>  	} while (pmd++, addr =3D next, addr !=3D end);
>> =20
>>  	if (mni_start)
>> -		mmu_notifier_invalidate_range_end(mm, mni_start, end);
>> +		mmu_notifier_invalidate_range_end(mm, mni_start, end,
>> +						  MMU_MPROT);
>> =20
>>  	if (nr_huge_updates)
>>  		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
>> diff --git a/mm/mremap.c b/mm/mremap.c
>> index 17fa018..1ede220 100644
>> --- a/mm/mremap.c
>> +++ b/mm/mremap.c
>> @@ -177,7 +177,8 @@ unsigned long move_page_tables(struct vm_area_stru=
ct *vma,
>> =20
>>  	mmun_start =3D old_addr;
>>  	mmun_end   =3D old_end;
>> -	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end=
);
>> +	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start,
>> +					    mmun_end, MMU_MIGRATE);
>> =20
>>  	for (; old_addr < old_end; old_addr +=3D extent, new_addr +=3D exten=
t) {
>>  		cond_resched();
>> @@ -229,7 +230,8 @@ unsigned long move_page_tables(struct vm_area_stru=
ct *vma,
>>  	if (likely(need_flush))
>>  		flush_tlb_range(vma, old_end-len, old_addr);
>> =20
>> -	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start,
>> +					  mmun_end, MMU_MIGRATE);
>> =20
>>  	return len + old_addr - old_end;	/* how much done */
>>  }
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index b404783..1d96644 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -869,7 +869,7 @@ static int page_mkclean_one(struct page *page, str=
uct vm_area_struct *vma,
>>  	pte_unmap_unlock(pte, ptl);
>> =20
>>  	if (ret) {
>> -		mmu_notifier_invalidate_page(mm, address);
>> +		mmu_notifier_invalidate_page(mm, address, MMU_WRITE_BACK);
>>  		(*cleaned)++;
>>  	}
>>  out:
>> @@ -1171,8 +1171,12 @@ static int try_to_unmap_one(struct page *page, =
struct vm_area_struct *vma,
>>  	spinlock_t *ptl;
>>  	int ret =3D SWAP_AGAIN;
>>  	enum ttu_flags flags =3D (enum ttu_flags)arg;
>> +	enum mmu_event event =3D MMU_MIGRATE;
>>  	int dirty =3D 0;
>> =20
>> +	if (flags & TTU_MUNLOCK)
>> +		event =3D MMU_MUNLOCK;
>> +
>>  	pte =3D page_check_address(page, mm, address, &ptl, 0);
>>  	if (!pte)
>>  		goto out;
>> @@ -1292,7 +1296,7 @@ discard:
>>  out_unmap:
>>  	pte_unmap_unlock(pte, ptl);
>>  	if (ret !=3D SWAP_FAIL && !(flags & TTU_MUNLOCK))
>> -		mmu_notifier_invalidate_page(mm, address);
>> +		mmu_notifier_invalidate_page(mm, address, event);
>>  out:
>>  	return ret;
>> =20
>> @@ -1346,7 +1350,9 @@ out_mlock:
>>  #define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
>> =20
>>  static int try_to_unmap_cluster(unsigned long cursor, unsigned int *m=
apcount,
>> -		struct vm_area_struct *vma, struct page *check_page)
>> +				struct vm_area_struct *vma,
>> +				struct page *check_page,
>> +				enum ttu_flags flags)
>>  {
>>  	struct mm_struct *mm =3D vma->vm_mm;
>>  	pmd_t *pmd;
>> @@ -1360,6 +1366,10 @@ static int try_to_unmap_cluster(unsigned long c=
ursor, unsigned int *mapcount,
>>  	unsigned long end;
>>  	int ret =3D SWAP_AGAIN;
>>  	int locked_vma =3D 0;
>> +	enum mmu_event event =3D MMU_MIGRATE;
>> +
>> +	if (flags & TTU_MUNLOCK)
>> +		event =3D MMU_MUNLOCK;
>> =20
>>  	address =3D (vma->vm_start + cursor) & CLUSTER_MASK;
>>  	end =3D address + CLUSTER_SIZE;
>> @@ -1374,7 +1384,7 @@ static int try_to_unmap_cluster(unsigned long cu=
rsor, unsigned int *mapcount,
>> =20
>>  	mmun_start =3D address;
>>  	mmun_end   =3D end;
>> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end, event)=
;
>> =20
>>  	/*
>>  	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
>> @@ -1443,7 +1453,7 @@ static int try_to_unmap_cluster(unsigned long cu=
rsor, unsigned int *mapcount,
>>  		(*mapcount)--;
>>  	}
>>  	pte_unmap_unlock(pte - 1, ptl);
>> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>> +	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end, event);
>>  	if (locked_vma)
>>  		up_read(&vma->vm_mm->mmap_sem);
>>  	return ret;
>> @@ -1499,7 +1509,9 @@ static int try_to_unmap_nonlinear(struct page *p=
age,
>>  			while (cursor < max_nl_cursor &&
>>  				cursor < vma->vm_end - vma->vm_start) {
>>  				if (try_to_unmap_cluster(cursor, &mapcount,
>> -						vma, page) =3D=3D SWAP_MLOCK)
>> +							 vma, page,
>> +							 (enum ttu_flags)arg)
>> +							 =3D=3D SWAP_MLOCK)
>>  					ret =3D SWAP_MLOCK;
>>  				cursor +=3D CLUSTER_SIZE;
>>  				vma->vm_private_data =3D (void *) cursor;
>> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
>> index 1cc6e2e..bee9357 100644
>> --- a/virt/kvm/kvm_main.c
>> +++ b/virt/kvm/kvm_main.c
>> @@ -254,7 +254,8 @@ static inline struct kvm *mmu_notifier_to_kvm(stru=
ct mmu_notifier *mn)
>> =20
>>  static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
>>  					     struct mm_struct *mm,
>> -					     unsigned long address)
>> +					     unsigned long address,
>> +					     enum mmu_event event)
>>  {
>>  	struct kvm *kvm =3D mmu_notifier_to_kvm(mn);
>>  	int need_tlb_flush, idx;
>> @@ -296,7 +297,8 @@ static void kvm_mmu_notifier_invalidate_page(struc=
t mmu_notifier *mn,
>>  static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
>>  					struct mm_struct *mm,
>>  					unsigned long address,
>> -					pte_t pte)
>> +					pte_t pte,
>> +					enum mmu_event event)
>>  {
>>  	struct kvm *kvm =3D mmu_notifier_to_kvm(mn);
>>  	int idx;
>> @@ -312,7 +314,8 @@ static void kvm_mmu_notifier_change_pte(struct mmu=
_notifier *mn,
>>  static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifi=
er *mn,
>>  						    struct mm_struct *mm,
>>  						    unsigned long start,
>> -						    unsigned long end)
>> +						    unsigned long end,
>> +						    enum mmu_event event)
>>  {
>>  	struct kvm *kvm =3D mmu_notifier_to_kvm(mn);
>>  	int need_tlb_flush =3D 0, idx;
>> @@ -338,7 +341,8 @@ static void kvm_mmu_notifier_invalidate_range_star=
t(struct mmu_notifier *mn,
>>  static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier=
 *mn,
>>  						  struct mm_struct *mm,
>>  						  unsigned long start,
>> -						  unsigned long end)
>> +						  unsigned long end,
>> +						  enum mmu_event event)
>>  {
>>  	struct kvm *kvm =3D mmu_notifier_to_kvm(mn);
>> =20
>>
>=20
> Hi Jerome,
>=20
> I have a question:
> Don't you need to add the "enum mmu_event event" to the new
> __mmu_notifier_invalidate_range() and to (*invalidate_range)() as well =
?
>=20
> Those new functions were merged to 3.19.
>=20
> 	Oded
To elaborate, I know the new mmu_notifier_invalidate_range is for non-CPU
TLB flush, so a fine-grained event may not be necessary. However, a
subsystem might still use it instead of start/end (the patch inserts a ca=
ll
to mn->ops->invalidate_range in __mmu_notifier_invalidate_range_end() so
that option will work). In addition, maybe in the future we will want to
distinguish between, let's say, migration and dirty events for non-CPU TL=
B ?

	Oded

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
