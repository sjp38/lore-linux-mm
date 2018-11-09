Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3266B073A
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 18:37:48 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id i13-v6so3617074ybg.2
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 15:37:48 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o5-v6si5287690ywf.320.2018.11.09.15.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 15:37:45 -0800 (PST)
Subject: Re: [RFC PATCH] mm: thp: implement THP reservations for anonymous
 memory
References: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
 <20181109110705.GD23260@techsingularity.net>
From: anthony.yznaga@oracle.com
Message-ID: <c206674f-a29c-9c20-35ea-595c49ce7632@oracle.com>
Date: Fri, 9 Nov 2018 15:37:10 -0800
MIME-Version: 1.0
In-Reply-To: <20181109110705.GD23260@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com



On 11/09/2018 03:07 AM, Mel Gorman wrote:
> On Thu, Nov 08, 2018 at 10:48:58PM -0800, Anthony Yznaga wrote:
>> The basic idea as outlined by Mel Gorman in [2] is:
>>
>> 1) On first fault in a sufficiently sized range, allocate a huge page
>>    sized and aligned block of base pages.  Map the base page
>>    corresponding to the fault address and hold the rest of the pages in
>>    reserve.
>> 2) On subsequent faults in the range, map the pages from the reservation.
>> 3) When enough pages have been mapped, promote the mapped pages and
>>    remaining pages in the reservation to a huge page.
>> 4) When there is memory pressure, release the unused pages from their
>>    reservations.
>>
>> [1] https://marc.info/?l=linux-mm&m=151631857310828&w=2
>> [2] https://lkml.org/lkml/2018/1/25/571
>>
> I'm delighted to see someone try tackle this issue.
>
>> To test the idea I wrote a simple test that repeatedly forks children
>> where each child attempts to allocate a very large chunk of memory and
>> then touch either 1 page or a random number of pages in each huge page
>> region of the chunk.  On a machine with 256GB with a test chunk size of
>> 16GB the test ends when the 17th child fails to map its chunk.  With THP
>> reservations enabled, the test ends when the 118th child fails.
>>
> That's a solid test case. I would suggest that primary metrics be fault
> latency, memory consumption and successful promotions (as opposed to
> successful allocations that we'd use with the existing THP setup).
Okay.

>
>> Below are some additional implementation details and known issues.
>>
>> User-visible files:
>>
> These all need to go into Documentation/ although I have no problems
> with the fields themselves.
I'll add a Documentation patch.

>
>> /sys/kernel/mm/transparent_hugepage/promotion_threshold
>>
>> 	The number of base pages within a huge page aligned region that
>> 	must be faulted in before the region is eligible for promotion
>> 	to a huge page.
>>
> Initially, I would suggest making the default 1 and then set a higher
> threshold in a subsequent patch. In the patch that introduces it,
> show in the changelog that the performance of your code is identical
> or close to identical as the existing approach. i.e. Show that the
> worst-case scenario is performance-neutral.  Then reduce the threshold
> so it can be demonstrated what the performance tradeoff is versus memory
> consumption. There is going to be some loss due to the additional code
> and the fact that THP is not used immediately for *some* workloads.
Okay, I'll do that.
>
>> /sys/kernel/mm/transparent_hugepage/khugepaged/res_pages_collapsed
>>
>> 	The number of THP reservations promoted to huge pages
>> 	by khugepaged.
>>
>> 	This total is also included in the total reported in pages_collapsed.
>>
> What is that not a vmstat like collapsed?
I'm not sure I understand.  There isn't a collapsed vmstat, and pages_collapsed is a sysfs file. 
>
>> Counters added to /proc/vmstat:
>>
>> nr_thp_reserved
>>
>> 	The total number of small pages in existing reservations
>> 	that have not had a page fault since their respective
>> 	reservation were created.  The amount is also included
>> 	in the estimated total memory available as reported
>> 	in MemAvailable in /proc/meminfo.
>>
>> thp_res_alloc
>>
>> 	Incremented every time the pages for a reservation have been
>> 	successfully allocated to handle a page fault.
>>
>> thp_res_alloc_failed
>>
>> 	Incremented if pages could not successfully allocated for
>> 	a reservation.
>>
> Seems fair. It might need tracepoints for further debugging in the
> future but lets wait until there is an actual problem that can be solved
> by a tracepoint first.
>
>> Known Issues:
>>
>> - COW handling of reservations is insufficient.   While the pages of a
>> reservation are shared between parent and child after fork, currently
>> the reservation data structures are not shared and remain with the
>> parent.  A COW fault by the child allocates a new small page and a new
>> reservation is not allocated.  A COW fault by the parent allocates a new
>> small page and releases the reservation if one exists.
>>
> Maybe keep the reservations in the parent. I'm thinking specifically
> about workloads like redis that fork to take a snapshot that don't
> particularly care about THP but do care about the memory overhead due to
> sparse addressing of memory.

Okay.

>
>> - If the pages in a reservation are remapped read-only (e.g. after fork
>> and child exit), khugepaged will never promote the pages to a huge page
>> until at least one page is written.
>>
> I don't consider that a major limitation and I don't think it must be solved
> in the first generation of the series. If this is a common occurance,
> then it can be dealt with or else workaround by setting the threshold to
> 1 until it's resolved.
I agree that it's not a major problem.  One side-effect of this that I observed
was that a fully populated reservation could sit around for essentially forever
on the LRU list and potentially impede real progress by the shrinker, but I
think this could easily be addressed by removing a reservation from the LRU
list when it becomes fully populated.

>
>> - A reservation is allocated even if the first fault on a pmd range maps
>> a zero page.  It may be more space efficient to allocate the reservation
>> on the first write fault.
>>
> Agreed but it doesn't kill the idea either. Reserving based on a zero-page
> fault works counter to your goal of reducing overall memory consumption
> so this should be fixed.
Okay.

>
>> - To facilitate the shrinker implementation, reservations are kept in a
>> global struct list_lru.  The list_lru internal implementation puts items
>> added to a list_lru on to per-node lists based on the node id derived
>> from the address of the item passed to list_lru_add().  For the current
>> reservations shrinker implementation this means that reservations will
>> be placed on the internal per-node list corresponding to the node where
>> the reservation data structure is located rather than the node where the
>> reserved pages are located.
>>
> Hmm, not super keen on a shrinker for this given that we probably want
> to dump all reservations in the event of memory pressure and doing that
> via a shrinker can be "fun".

I'll implement a simple release of all reservations for comparison.

>> Other TBD:
>> - Performance testing
>> - shmem support
>> - Investigate promoting a reservation synchronously during fault handling
>>   rather than waiting for khugepaged to do the promotion.
>>
> Kirill might disagree but I do not think that shmem support for this is
> necessarily critical. THP was anonymous-only for a long time.
Okay.  At minimum it sounds like I should prove a benefit with anonymous
THP first.

>
>> Signed-off-by: Anthony Yznaga <anthony.yznaga@oracle.com>
>> ---
>>  include/linux/huge_mm.h       |   1 +
>>  include/linux/khugepaged.h    | 119 +++++++
>>  include/linux/memcontrol.h    |   5 +
>>  include/linux/mm_types.h      |   3 +
>>  include/linux/mmzone.h        |   1 +
>>  include/linux/vm_event_item.h |   2 +
>>  kernel/fork.c                 |   2 +
>>  mm/huge_memory.c              |  29 ++
>>  mm/khugepaged.c               | 739 ++++++++++++++++++++++++++++++++++++++++--
>>  mm/memcontrol.c               |  33 ++
>>  mm/memory.c                   |  37 ++-
>>  mm/mmap.c                     |  14 +
>>  mm/mremap.c                   |   5 +
>>  mm/page_alloc.c               |   5 +
>>  mm/rmap.c                     |   3 +
>>  mm/util.c                     |   5 +
>>  mm/vmstat.c                   |   3 +
>>  17 files changed, 975 insertions(+), 31 deletions(-)
>>
> This is somewhat intimidating though as a diffstat. Hopefully this can
> be broken up. The rest of this is a drive-by review only as I'm about to
> travel. Note that there will be others that may not even attempt to read
> a patch of that magnitude unless *heavily* motivated by the potential of
> the feature.
Understood.  I'll break things up before I submit anything further.

>
>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> index fdcb45999b26..a2288f134d5d 100644
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -92,6 +92,7 @@ extern ssize_t single_hugepage_flag_show(struct kobject *kobj,
>>  extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
>>  
>>  extern unsigned long transparent_hugepage_flags;
>> +extern unsigned int hugepage_promotion_threshold;
>>  
>>  static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
>>  {
>> diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
>> index 082d1d2a5216..0011eb656ff3 100644
>> --- a/include/linux/khugepaged.h
>> +++ b/include/linux/khugepaged.h
>> @@ -2,6 +2,7 @@
>>  #ifndef _LINUX_KHUGEPAGED_H
>>  #define _LINUX_KHUGEPAGED_H
>>  
>> +#include <linux/hashtable.h>
>>  #include <linux/sched/coredump.h> /* MMF_VM_HUGEPAGE */
>>  
>>  
>> @@ -30,6 +31,64 @@ extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
>>  	(transparent_hugepage_flags &				\
>>  	 (1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG))
>>  
>> +struct thp_reservation {
>> +	spinlock_t *lock;
>> +	unsigned long haddr;
>> +	struct page *page;
>> +	struct vm_area_struct *vma;
>> +	struct hlist_node node;
>> +	struct list_head lru;
>> +	int nr_unused;
>> +};
>> +
> Document these fields, particularly page. Is page the first fault or the
> base index of a reserved huge page for example. You also track VMA which
> in the THP-specific case *might* be ok because we are not rmapping it
> but you might be designing yourself into a corner there.
I can get rid of the VMA pointer.  It's only used to simplify acquiring the VMA
pointer in collapse_huge_page() and by the shrinker code to get the mm pointer.

>
>> +struct thp_resvs {
>> +	atomic_t refcnt;
>> +	spinlock_t res_hash_lock;
>> +	DECLARE_HASHTABLE(res_hash, 7);
>> +};
>> +
> Also needs documentation. It isn't clear what the relationship between
> thp_resvs and thp_reservation is. Is this per-mm, per-VMA etc. As I
> write this, I haven't looked at the rest of the patch and thp_resvs
> tells me nothing about what this is for. It parses to me as THP Reserve
> Versus...... Versus what? So obviously it has some other sensible
> meaning.
Yeah, resvs isn't great.  It's supposed to be the plural of resv.  I'll come up
with something else.  A thp_resvs encompasses the per-VMA hashtable
that the per-reservation thp_reservation structures are hashed into.
>
>> +#define	vma_thp_reservations(vma)	((vma)->thp_reservations)
>> +
>> +static inline void thp_resvs_fork(struct vm_area_struct *vma,
>> +				  struct vm_area_struct *pvma)
>> +{
>> +	// XXX Do not share THP reservations for now
>> +	vma->thp_reservations = NULL;
>> +}
>> +
> Consider not sharing THP reservations between parent and child
> full-stop. I think fundamentally it breaks if a child can use the
> reservation because it means that neither child nor parent can promote
> in-place.
khugepaged already skips over pages while they are shared by child
and parent.  What I was envisioning as a more complete behavior
was to allocate a new reservation for the process that does the first
COW with the existing reservation then remaining with the other
process.  Additional COWs then populate the now separate
reservations.

>
>> +void thp_resvs_new(struct vm_area_struct *vma);
>> +
>> +extern void __thp_resvs_put(struct thp_resvs *r);
>> +static inline void thp_resvs_put(struct thp_resvs *r)
>> +{
>> +	if (r)
>> +		__thp_resvs_put(r);
>> +}
>> +
> Curious that this could be called with NULL

It's called when a VMA is freed.  vma->thp_reservations is passed
in as the argument and the value will be NULL for VMAs that don't
support THP reservations or VMAs that were created when
promotion_threshold==1.  Maybe it would be clearer to pass a
VMA pointer instead.

>
>> +void khugepaged_mod_resv_unused(struct vm_area_struct *vma,
>> +				  unsigned long address, int delta);
>> +
>> +struct page *khugepaged_get_reserved_page(
>> +	struct vm_area_struct *vma,
>> +	unsigned long address);
>> +
>> +void khugepaged_reserve(struct vm_area_struct *vma,
>> +			unsigned long address);
>> +
>> +void khugepaged_release_reservation(struct vm_area_struct *vma,
>> +				    unsigned long address);
>> +
>> +void _khugepaged_reservations_fixup(struct vm_area_struct *src,
>> +				   struct vm_area_struct *dst);
>> +
>> +void _khugepaged_move_reservations_adj(struct vm_area_struct *prev,
>> +				      struct vm_area_struct *next, long adjust);
>> +
>> +void thp_reservations_mremap(struct vm_area_struct *vma,
>> +		unsigned long old_addr, struct vm_area_struct *new_vma,
>> +		unsigned long new_addr, unsigned long len,
>> +		bool need_rmap_locks);
>> +
>>  static inline int khugepaged_fork(struct mm_struct *mm, struct mm_struct *oldmm)
>>  {
>>  	if (test_bit(MMF_VM_HUGEPAGE, &oldmm->flags))
>> @@ -56,6 +115,66 @@ static inline int khugepaged_enter(struct vm_area_struct *vma,
>>  	return 0;
>>  }
>>  #else /* CONFIG_TRANSPARENT_HUGEPAGE */
>> +
>> +#define	vma_thp_reservations(vma)	NULLo
>> +
> static inline for type safety check.
Okay.

>
>> +static inline void thp_resvs_fork(struct vm_area_struct *vma,
>> +				  struct vm_area_struct *pvma)
>> +{
>> +}
>> +
>> +static inline void thp_resvs_new(struct vm_area_struct *vma)
>> +{
>> +}
>> +
>> +static inline void __thp_resvs_put(struct thp_resvs *r)
>> +{
>> +}
>> +
>> +static inline void thp_resvs_put(struct thp_resvs *r)
>> +{
>> +}
>> +
>> +static inline void khugepaged_mod_resv_unused(struct vm_area_struct *vma,
>> +					      unsigned long address, int delta)
>> +{
>> +}
>> +
>> +static inline struct page *khugepaged_get_reserved_page(
>> +	struct vm_area_struct *vma,
>> +	unsigned long address)
>> +{
>> +	return NULL;
>> +}
>> +
>> +static inline void khugepaged_reserve(struct vm_area_struct *vma,
>> +			       unsigned long address)
>> +{
>> +}
>> +
>> +static inline void khugepaged_release_reservation(struct vm_area_struct *vma,
>> +				    unsigned long address)
>> +{
>> +}
>> +
>> +static inline void _khugepaged_reservations_fixup(struct vm_area_struct *src,
>> +				   struct vm_area_struct *dst)
>> +{
>> +}
>> +
>> +static inline void _khugepaged_move_reservations_adj(
>> +				struct vm_area_struct *prev,
>> +				struct vm_area_struct *next, long adjust)
>> +{
>> +}
>> +
>> +static inline void thp_reservations_mremap(struct vm_area_struct *vma,
>> +		unsigned long old_addr, struct vm_area_struct *new_vma,
>> +		unsigned long new_addr, unsigned long len,
>> +		bool need_rmap_locks)
>> +{
>> +}
>> +
>>  static inline int khugepaged_fork(struct mm_struct *mm, struct mm_struct *oldmm)
>>  {
>>  	return 0;
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 652f602167df..6342d5f67f75 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -787,6 +787,7 @@ static inline void memcg_memory_event_mm(struct mm_struct *mm,
>>  }
>>  
>>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +void mem_cgroup_collapse_huge_fixup(struct page *head);
>>  void mem_cgroup_split_huge_fixup(struct page *head);
>>  #endif
>>  
>> @@ -1087,6 +1088,10 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
>>  	return 0;
>>  }
>>  
>> +static inline void mem_cgroup_collapse_huge_fixup(struct page *head)
>> +{
>> +}
>> +
>>  static inline void mem_cgroup_split_huge_fixup(struct page *head)
>>  {
>>  }
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 5ed8f6292a53..72a9f431145e 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -322,6 +322,9 @@ struct vm_area_struct {
>>  #ifdef CONFIG_NUMA
>>  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>>  #endif
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	struct thp_resvs *thp_reservations;
>> +#endif
>>  	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
>>  } __randomize_layout;
>>  
> Why is this per-vma and not per address space? I'm not saying that's
> good or bad but it makes sense to me that all in-place THP reservations
> would inherently be about the address space. Per-vma seems unnecessarily
> fine-grained and per-task would be insanity (because threads share an
> address space).
One concern I had with per address space was the potential for
for increased lock contention when looking up and adding reservations
while handling faults in different VMAs.
A per-VMA reservations pointer also makes it straightforward to avoid
checking for reservations in VMAs that don't support them though the
check could be done in other ways.  I'll take another look at a per-MM
implementation.

>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index d4b0c79d2924..7deac5a1f25d 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -181,6 +181,7 @@ enum node_stat_item {
>>  	NR_DIRTIED,		/* page dirtyings since bootup */
>>  	NR_WRITTEN,		/* page writings since bootup */
>>  	NR_INDIRECTLY_RECLAIMABLE_BYTES, /* measured in bytes */
>> +	NR_THP_RESERVED,	/* Unused small pages in THP reservations */
>>  	NR_VM_NODE_STAT_ITEMS
>>  };
>>  
>> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
>> index 47a3441cf4c4..f3d34db7e9d5 100644
>> --- a/include/linux/vm_event_item.h
>> +++ b/include/linux/vm_event_item.h
>> @@ -88,6 +88,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>>  		THP_ZERO_PAGE_ALLOC_FAILED,
>>  		THP_SWPOUT,
>>  		THP_SWPOUT_FALLBACK,
>> +		THP_RES_ALLOC,
>> +		THP_RES_ALLOC_FAILED,
>>  #endif
>>  #ifdef CONFIG_MEMORY_BALLOON
>>  		BALLOON_INFLATE,
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index f0b58479534f..a15d1cda1958 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -527,6 +527,8 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
>>  		if (is_vm_hugetlb_page(tmp))
>>  			reset_vma_resv_huge_pages(tmp);
>>  
>> +		thp_resvs_fork(tmp, mpnt);
>> +
>>  		/*
>>  		 * Link in the new vma and copy the page table entries.
>>  		 */
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index deed97fba979..aa80b9c54d1c 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -57,6 +57,8 @@
>>  	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
>>  	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
>>  
>> +unsigned int hugepage_promotion_threshold __read_mostly = HPAGE_PMD_NR / 2;
>> +
>>  static struct shrinker deferred_split_shrinker;
>>  
> Mentioned already, default this to 1 initially and then
> reduce it.
>
>>  static atomic_t huge_zero_refcount;
>> @@ -288,6 +290,28 @@ static ssize_t use_zero_page_store(struct kobject *kobj,
>>  static struct kobj_attribute use_zero_page_attr =
>>  	__ATTR(use_zero_page, 0644, use_zero_page_show, use_zero_page_store);
>>  
>> +static ssize_t promotion_threshold_show(struct kobject *kobj,
>> +		struct kobj_attribute *attr, char *buf)
>> +{
>> +	return sprintf(buf, "%u\n", hugepage_promotion_threshold);
>> +}
>> +static ssize_t promotion_threshold_store(struct kobject *kobj,
>> +		struct kobj_attribute *attr, const char *buf, size_t count)
>> +{
>> +	int err;
>> +	unsigned long promotion_threshold;
>> +
>> +	err = kstrtoul(buf, 10, &promotion_threshold);
>> +	if (err || promotion_threshold < 1 || promotion_threshold > HPAGE_PMD_NR)
>> +		return -EINVAL;
>> +
>> +	hugepage_promotion_threshold = promotion_threshold;
>> +
>> +	return count;
>> +}
> Look at sysctl.c and see how extra1 and extra2 can be used to set a
> range of permitted values without hard-coding like this. You might need
> to add a special local variable like "one" and "zero" in that file to
> cover HPAGE_PMD_NR. It'll save you a few lines.
That seems to apply to /proc files, but this is a sysfs file which I modeled
after others in khugepaged.c.

>
>> +static struct kobj_attribute promotion_threshold_attr =
>> +	__ATTR(promotion_threshold, 0644, promotion_threshold_show, promotion_threshold_store);
>> +
>>  static ssize_t hpage_pmd_size_show(struct kobject *kobj,
>>  		struct kobj_attribute *attr, char *buf)
>>  {
>> @@ -318,6 +342,7 @@ static ssize_t debug_cow_store(struct kobject *kobj,
>>  	&enabled_attr.attr,
>>  	&defrag_attr.attr,
>>  	&use_zero_page_attr.attr,
>> +	&promotion_threshold_attr.attr,
>>  	&hpage_pmd_size_attr.attr,
>>  #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
>>  	&shmem_enabled_attr.attr,
> I suggest splitting out any debugging code into a separate patch.
Okay.

>
>> @@ -670,6 +695,10 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
>>  	struct page *page;
>>  	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
>>  
>> +	if (hugepage_promotion_threshold > 1) {
>> +		khugepaged_reserve(vma, vmf->address);
>> +		return VM_FAULT_FALLBACK;
>> +	}
>>  	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
>>  		return VM_FAULT_FALLBACK;
>>  	if (unlikely(anon_vma_prepare(vma)))
> Add a comment on why exactly it's falling back. It's also not clear at a
> glance what happens if this is the fault that reaches the threshold.
I'll add a comment.  do_huge_pmd_anonymous_page() is only called
for the first fault in a PMD range so the check here is whether to immediately
allocate a huge page or to allocate a reservation and fallback to fault
in a small page from the reservation.

If promotion was done at fault time, do_anonymous_page() would probably
be the place to check whether the threshold had been reached.

>
>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>> index a31d740e6cd1..55d380f8ce71 100644
>> --- a/mm/khugepaged.c
>> +++ b/mm/khugepaged.c
>> @@ -8,6 +8,7 @@
>>  #include <linux/mmu_notifier.h>
>>  #include <linux/rmap.h>
>>  #include <linux/swap.h>
>> +#include <linux/shrinker.h>
>>  #include <linux/mm_inline.h>
>>  #include <linux/kthread.h>
>>  #include <linux/khugepaged.h>
>> @@ -56,6 +57,7 @@ enum scan_result {
>>  /* default scan 8*512 pte (or vmas) every 30 second */
>>  static unsigned int khugepaged_pages_to_scan __read_mostly;
>>  static unsigned int khugepaged_pages_collapsed;
>> +static unsigned int khugepaged_res_pages_collapsed;
>>  static unsigned int khugepaged_full_scans;
>>  static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
>>  /* during fragmentation poll the hugepage allocator once every minute */
>> @@ -76,6 +78,445 @@ enum scan_result {
>>  
>>  static struct kmem_cache *mm_slot_cache __read_mostly;
>>  
>> +struct list_lru thp_reservations_lru;
>> +
>> +void thp_resvs_new(struct vm_area_struct *vma)
>> +{
>> +	struct thp_resvs *new = NULL;
>> +
>> +	if (hugepage_promotion_threshold == 1)
>> +		goto done;
>> +
>> +	new = kzalloc(sizeof(struct thp_resvs), GFP_KERNEL);
>> +	if (!new)
>> +		goto done;
>> +
>> +	atomic_set(&new->refcnt, 1);
>> +	spin_lock_init(&new->res_hash_lock);
>> +	hash_init(new->res_hash);
>> +
>> +done:
>> +	vma->thp_reservations = new;
>> +}
>> +
> Odd flow. Init the VMA to have this as NULL and then just return if it's
> unused instead of initialising it here. Not a biggie but I'm already
> hung-up on thinking the reservations should be per-mm.
Okay.

>
>> +void __thp_resvs_put(struct thp_resvs *resv)
>> +{
>> +	if (!atomic_dec_and_test(&resv->refcnt))
>> +		return;
>> +
>> +	kfree(resv);
>> +}
>> +
> kfree without clearing the pointer to it looks like a recipe for use-after
> free entertainments.
It's only called right before freeing the vm_area_struct that points to it.

>
>> +static struct thp_reservation *khugepaged_find_reservation(
>> +	struct vm_area_struct *vma,
>> +	unsigned long address)
>> +{
>> +	unsigned long haddr = address & HPAGE_PMD_MASK;
>> +	struct thp_reservation *res = NULL;
>> +
>> +	if (!vma->thp_reservations)
>> +		return NULL;
>> +
>> +	hash_for_each_possible(vma->thp_reservations->res_hash, res, node, haddr) {
>> +		if (res->haddr == haddr)
>> +			break;
>> +	}
>> +	return res;
>> +}
>> +
>> +static void khugepaged_free_reservation(struct thp_reservation *res)
>> +{
>> +	struct page *page;
>> +	int unused;
>> +	int i;
>> +
>> +	list_lru_del(&thp_reservations_lru, &res->lru);
>> +	hash_del(&res->node);
>> +	page = res->page;
>> +	unused = res->nr_unused;
>> +
>> +	kfree(res);
>> +
>> +	if (!PageCompound(page)) {
>> +		for (i = 0; i < HPAGE_PMD_NR; i++)
>> +			put_page(page + i);
>> +
>> +		if (unused) {
>> +			mod_node_page_state(page_pgdat(page), NR_THP_RESERVED,
>> +					    -unused);
>> +		}
>> +	}
>> +}
>> +
>> +void khugepaged_reserve(struct vm_area_struct *vma, unsigned long address)
>> +{
>> +	unsigned long haddr = address & HPAGE_PMD_MASK;
>> +	struct thp_reservation *res;
>> +	struct page *page;
>> +	gfp_t gfp;
>> +	int i;
>> +
>> +	if (!vma->thp_reservations)
>> +		return;
>> +	if (!vma_is_anonymous(vma))
>> +		return;
>> +	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
>> +		return;
>> +
>> +	spin_lock(&vma->thp_reservations->res_hash_lock);
>> +
>> +	if (khugepaged_find_reservation(vma, address)) {
>> +		spin_unlock(&vma->thp_reservations->res_hash_lock);
>> +		return;
>> +	}
>> +
>> +	/*
>> +	 * Allocate the equivalent of a huge page but not as a compound page
>> +	 */
>> +	gfp = GFP_TRANSHUGE_LIGHT & ~__GFP_COMP;
>> +	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
>> +	if (unlikely(!page)) {
>> +		count_vm_event(THP_RES_ALLOC_FAILED);
>> +		spin_unlock(&vma->thp_reservations->res_hash_lock);
>> +		return;
>> +	}
>> +
> Put the cleanup at the end of the function and use gotos to pick what
> point you unwind the work at. This will reduce duplicated code and make
> it harder to introduce bugs in the cleanup if there are modifications to
> this function.
Okay.

>
>> +	for (i = 0; i < HPAGE_PMD_NR; i++)
>> +		set_page_count(page + i, 1);
>> +
> split_page()?
I didn't know about split_page().  It definitely looks appropriate.  I'll
change it.

>
>> +	res = kzalloc(sizeof(*res), GFP_KERNEL);
>> +	if (!res) {
>> +		count_vm_event(THP_RES_ALLOC_FAILED);
>> +		__free_pages(page, HPAGE_PMD_ORDER);
>> +		spin_unlock(&vma->thp_reservations->res_hash_lock);
>> +		return;
>> +	}
>> +
>> +	count_vm_event(THP_RES_ALLOC);
>> +
>> +	res->haddr = haddr;
>> +	res->page = page;
>> +	res->vma = vma;
>> +	res->lock = &vma->thp_reservations->res_hash_lock;
>> +	hash_add(vma->thp_reservations->res_hash, &res->node, haddr);
>> +
>> +	INIT_LIST_HEAD(&res->lru);
>> +	list_lru_add(&thp_reservations_lru, &res->lru);
>> +
>> +	res->nr_unused = HPAGE_PMD_NR;
>> +	mod_node_page_state(page_pgdat(page), NR_THP_RESERVED, HPAGE_PMD_NR);
>> +
>> +	spin_unlock(&vma->thp_reservations->res_hash_lock);
>> +
>> +	khugepaged_enter(vma, vma->vm_flags);
>> +}
>> +
> I'm undecided on the use of the LRU. I'm not sure it's worthwhile in the
> initial phase to shrink reservations in LRU order. I think in the first
> generation just blast all reservations if there is memory pressure and
> add the shrinker as a separate patch. This has a worse-case scenario on
> being no better than what we have today.
>
> I'm partially saying this because shrinkers have historically being
> a bit painful and difficult to analyse. Initially you want this to be
> performance-neutral at worst and the use of shrinkers means we could
> have corner cases where reservations cause page cache or mapped anonymous
> pages to be prematurely discarded.
I'm not sure how something could get prematurely discarded, but I'm fine
with separating these changes and starting with simpler functionality
that just releases all reservations.

>
>> +struct page *khugepaged_get_reserved_page(struct vm_area_struct *vma,
>> +					  unsigned long address)
>> +{
>> +	struct thp_reservation *res;
>> +	struct page *page;
>> +
>> +	if (!transparent_hugepage_enabled(vma))
>> +		return NULL;
>> +	if (!vma->thp_reservations)
>> +		return NULL;
>> +
>> +	spin_lock(&vma->thp_reservations->res_hash_lock);
>> +
>> +	page = NULL;
>> +	res = khugepaged_find_reservation(vma, address);
>> +	if (res) {
>> +		unsigned long offset = address & ~HPAGE_PMD_MASK;
>> +
>> +		page = res->page + (offset >> PAGE_SHIFT);
>> +		get_page(page);
>> +
>> +		list_lru_del(&thp_reservations_lru, &res->lru);
>> +		list_lru_add(&thp_reservations_lru, &res->lru);
>> +
>> +		dec_node_page_state(res->page, NR_THP_RESERVED);
>> +	}
>> +
>> +	spin_unlock(&vma->thp_reservations->res_hash_lock);
>> +
>> +	return page;
>> +}
>> +
>> +void khugepaged_release_reservation(struct vm_area_struct *vma,
>> +				    unsigned long address)
>> +{
>> +	struct thp_reservation *res;
>> +
>> +	if (!vma->thp_reservations)
>> +		return;
>> +
>> +	spin_lock(&vma->thp_reservations->res_hash_lock);
>> +
>> +	res = khugepaged_find_reservation(vma, address);
>> +	if (!res)
>> +		goto out;
>> +
>> +	khugepaged_free_reservation(res);
>> +
>> +out:
>> +	spin_unlock(&vma->thp_reservations->res_hash_lock);
>> +}
>> +
>> +/*
>> + * Release all reservations covering a range in a VMA.
>> + */
>> +void __khugepaged_release_reservations(struct vm_area_struct *vma,
>> +				       unsigned long addr, unsigned long len)
>> +{
>> +	struct thp_reservation *res;
>> +	struct hlist_node *tmp;
>> +	unsigned long eaddr;
>> +	int i;
>> +
>> +	if (!vma->thp_reservations)
>> +		return;
>> +
>> +	eaddr = addr + len;
>> +	addr &= HPAGE_PMD_MASK;
>> +
>> +	spin_lock(&vma->thp_reservations->res_hash_lock);
>> +
>> +	hash_for_each_safe(vma->thp_reservations->res_hash, i, tmp, res, node) {
>> +		unsigned long hstart = res->haddr;
>> +
>> +		if (hstart >= addr && hstart < eaddr)
>> +			khugepaged_free_reservation(res);
>> +	}
>> +
>> +	spin_unlock(&vma->thp_reservations->res_hash_lock);
>> +}
>> +
>> +static void __khugepaged_move_reservations(struct vm_area_struct *src,
>> +					   struct vm_area_struct *dst,
>> +					   unsigned long split_addr,
>> +					   bool dst_is_below)
>> +{
>> +	struct thp_reservation *res;
>> +	struct hlist_node *tmp;
>> +	bool free_res = false;
>> +	int i;
>> +
>> +	if (!src->thp_reservations)
>> +		return;
>> +
>> +	if (!dst->thp_reservations)
>> +		free_res = true;
>> +
>> +	spin_lock(&src->thp_reservations->res_hash_lock);
>> +	if (!free_res)
>> +		spin_lock(&dst->thp_reservations->res_hash_lock);
>> +
>> +	hash_for_each_safe(src->thp_reservations->res_hash, i, tmp, res, node) {
>> +		unsigned long hstart = res->haddr;
>> +
>> +		/*
>> +		 * Free the reservation if it straddles a non-aligned
>> +		 * split address.
>> +		 */
>> +		if ((split_addr & ~HPAGE_PMD_MASK) &&
>> +		    (hstart == (split_addr & HPAGE_PMD_MASK))) {
>> +			khugepaged_free_reservation(res);
>> +			continue;
>> +		} else if (dst_is_below) {
>> +			if (hstart >= split_addr)
>> +				continue;
>> +		} else if (hstart < split_addr) {
>> +			continue;
>> +		}
>> +
>> +		if (unlikely(free_res)) {
>> +			khugepaged_free_reservation(res);
>> +			continue;
>> +		}
>> +
>> +		hash_del(&res->node);
>> +		res->vma = dst;
>> +		res->lock = &dst->thp_reservations->res_hash_lock;
>> +		hash_add(dst->thp_reservations->res_hash, &res->node, res->haddr);
>> +	}
>> +
>> +	if (!free_res)
>> +		spin_unlock(&dst->thp_reservations->res_hash_lock);
>> +	spin_unlock(&src->thp_reservations->res_hash_lock);
>> +}
>> +
> Nothing jumped out here but I'm not reading as closely as I should.
> Fundamentally any major issue here will result in memory corruption
> of a type that will trigger quickly. Performance testing can be driven
> by profiles.
>
>> +/*
>> + * XXX dup from mm/mremap.c.  Move thp_reservations_mremap() to mm/mremap.c?
>> + */
>> +static void take_rmap_locks(struct vm_area_struct *vma)
>> +{
>> +	if (vma->vm_file)
>> +		i_mmap_lock_write(vma->vm_file->f_mapping);
>> +	if (vma->anon_vma)
>> +		anon_vma_lock_write(vma->anon_vma);
>> +}
>> +
>> +/*
>> + * XXX dup from mm/mremap.c.  Move thp_reservations_mremap() to mm/mremap.c?
>> + */
>> +static void drop_rmap_locks(struct vm_area_struct *vma)
>> +{
>> +	if (vma->anon_vma)
>> +		anon_vma_unlock_write(vma->anon_vma);
>> +	if (vma->vm_file)
>> +		i_mmap_unlock_write(vma->vm_file->f_mapping);
>> +}
>> +
>> +void thp_reservations_mremap(struct vm_area_struct *vma,
>> +		unsigned long old_addr, struct vm_area_struct *new_vma,
>> +		unsigned long new_addr, unsigned long len,
>> +		bool need_rmap_locks)
>> +{
> Is mremap really worth optimising at this point? Would it be possible
> instead to dump all reservations for a range (either VMA or mm) being
> mremapped and just move it as normal? If so, do that and make mremap
> handling a separate patch. Minimally, it would be nice to know if there
> are mremap-intensive workloads that care deeply about preserving THP
> reservations.
I can't say if mremap support is worth it.  I was just trying to be complete. :-)
I'll move the support into a separate patch.

>
>> +
>> +	struct thp_reservation *res;
>> +	unsigned long eaddr, offset;
>> +	struct hlist_node *tmp;
>> +	int i;
>> +
>> +	if (!vma->thp_reservations)
>> +		return;
>> +
>> +	if (!new_vma->thp_reservations) {
>> +		__khugepaged_release_reservations(vma, old_addr, len);
>> +		return;
>> +	}
>> +
>> +	/*
>> +	 * Release all reservations if they will no longer be aligned
>> +	 * in the new address range.
>> +	 */
>> +	if ((new_addr & ~HPAGE_PMD_MASK) != (old_addr & ~HPAGE_PMD_MASK)) {
>> +		__khugepaged_release_reservations(vma, old_addr, len);
>> +		return;
>> +	}
>> +
>> +	if (need_rmap_locks)
>> +		take_rmap_locks(vma);
>> +
>> +	spin_lock(&vma->thp_reservations->res_hash_lock);
>> +	spin_lock(&new_vma->thp_reservations->res_hash_lock);
>> +
>> +	/*
>> +	 * If the start or end addresses of the range are not huge page
>> +	 * aligned, check for overlapping reservations and release them.
>> +	 */
>> +	if (old_addr & ~HPAGE_PMD_MASK) {
>> +		res = khugepaged_find_reservation(vma, old_addr);
>> +		if (res)
>> +			khugepaged_free_reservation(res);
>> +	}
>> +
>> +	eaddr = old_addr + len;
>> +	if (eaddr & ~HPAGE_PMD_MASK) {
>> +		res = khugepaged_find_reservation(vma, eaddr);
>> +		if (res)
>> +			khugepaged_free_reservation(res);
>> +	}
>> +
>> +	offset = new_addr - old_addr;
>> +
>> +	hash_for_each_safe(vma->thp_reservations->res_hash, i, tmp, res, node) {
>> +		unsigned long hstart = res->haddr;
>> +
>> +		if (hstart < old_addr || hstart >= eaddr)
>> +			continue;
>> +
>> +		hash_del(&res->node);
>> +		res->lock = &new_vma->thp_reservations->res_hash_lock;
>> +		res->vma = new_vma;
>> +		res->haddr += offset;
>> +		hash_add(new_vma->thp_reservations->res_hash, &res->node, res->haddr);
>> +	}
>> +
>> +	spin_unlock(&new_vma->thp_reservations->res_hash_lock);
>> +	spin_unlock(&vma->thp_reservations->res_hash_lock);
>> +
>> +	if (need_rmap_locks)
>> +		drop_rmap_locks(vma);
>> +
>> +}
>> +
>> +/*
>> + * Handle moving reservations for VMA merge cases 1, 6, 7, and 8 (see
>> + * comments above vma_merge()) and when splitting a VMA.
>> + *
>> + * src is expected to be aligned with the start or end of dst
>> + * src may be contained by dst or directly adjacent to dst
>> + * Move all reservations if src is contained by dst.
>> + * Otherwise move reservations no longer in the range of src
>> + * to dst.
>> + */
>> +void _khugepaged_reservations_fixup(struct vm_area_struct *src,
>> +				    struct vm_area_struct *dst)
>> +{
>> +	bool dst_is_below = false;
>> +	unsigned long split_addr;
>> +
>> +	if (src->vm_start == dst->vm_start || src->vm_end == dst->vm_end) {
>> +		split_addr = 0;
>> +	} else if (src->vm_start == dst->vm_end) {
>> +		split_addr = src->vm_start;
>> +		dst_is_below = true;
>> +	} else if (src->vm_end == dst->vm_start) {
>> +		split_addr = src->vm_end;
>> +	} else {
>> +		WARN_ON(1);
>> +		return;
>> +	}
>> +
>> +	__khugepaged_move_reservations(src, dst, split_addr, dst_is_below);
>> +}
>> +
>> +/*
>> + * Handle moving reservations for VMA merge cases 4 and 5 (see comments
>> + * above vma_merge()).
>> + */
>> +void _khugepaged_move_reservations_adj(struct vm_area_struct *prev,
>> +				       struct vm_area_struct *next, long adjust)
>> +{
>> +	unsigned long split_addr = next->vm_start;
>> +	struct vm_area_struct *src, *dst;
>> +	bool dst_is_below;
>> +
>> +	if (adjust < 0) {
>> +		src = prev;
>> +		dst = next;
>> +		dst_is_below = false;
>> +	} else {
>> +		src = next;
>> +		dst = prev;
>> +		dst_is_below = true;
>> +	}
>> +
>> +	__khugepaged_move_reservations(src, dst, split_addr, dst_is_below);
>> +}
>> +
>> +void khugepaged_mod_resv_unused(struct vm_area_struct *vma,
>> +				unsigned long address, int delta)
>> +{
>> +	struct thp_reservation *res;
>> +
>> +	if (!vma->thp_reservations)
>> +		return;
>> +
>> +	spin_lock(&vma->thp_reservations->res_hash_lock);
>> +
>> +	res = khugepaged_find_reservation(vma, address);
>> +	if (res) {
>> +		WARN_ON((res->nr_unused == 0) || (res->nr_unused + delta < 0));
>> +		if (res->nr_unused + delta >= 0)
>> +			res->nr_unused += delta;
>> +	}
>> +
>> +	spin_unlock(&vma->thp_reservations->res_hash_lock);
>> +}
>> +
>>  /**
>>   * struct mm_slot - hash lookup from mm to mm_slot
>>   * @hash: hash collision list
>> @@ -197,6 +638,15 @@ static ssize_t pages_collapsed_show(struct kobject *kobj,
>>  static struct kobj_attribute pages_collapsed_attr =
>>  	__ATTR_RO(pages_collapsed);
>>  
>> +static ssize_t res_pages_collapsed_show(struct kobject *kobj,
>> +				    struct kobj_attribute *attr,
>> +				    char *buf)
>> +{
>> +	return sprintf(buf, "%u\n", khugepaged_res_pages_collapsed);
>> +}
>> +static struct kobj_attribute res_pages_collapsed_attr =
>> +	__ATTR_RO(res_pages_collapsed);
>> +
>>  static ssize_t full_scans_show(struct kobject *kobj,
>>  			       struct kobj_attribute *attr,
>>  			       char *buf)
>> @@ -292,6 +742,7 @@ static ssize_t khugepaged_max_ptes_swap_store(struct kobject *kobj,
>>  	&scan_sleep_millisecs_attr.attr,
>>  	&alloc_sleep_millisecs_attr.attr,
>>  	&khugepaged_max_ptes_swap_attr.attr,
>> +	&res_pages_collapsed_attr.attr,
>>  	NULL,
>>  };
>>  
>> @@ -342,8 +793,96 @@ int hugepage_madvise(struct vm_area_struct *vma,
>>  	return 0;
>>  }
>>  
>> +/*
>> + * thp_lru_free_reservation() - shrinker callback to release THP reservations
>> + * and free unused pages
>> + *
>> + * Called from list_lru_shrink_walk() in thp_resvs_shrink_scan() to free
>> + * up pages when the system is under memory pressure.
>> + */
>> +enum lru_status thp_lru_free_reservation(struct list_head *item,
>> +					 struct list_lru_one *lru,
>> +					 spinlock_t *lock,
>> +					 void *cb_arg)
>> +{
>> +	struct mm_struct *mm = NULL;
>> +	struct thp_reservation *res = container_of(item,
>> +						   struct thp_reservation,
>> +						   lru);
>> +	struct page *page;
>> +	int unused;
>> +	int i;
>> +
>> +	if (!spin_trylock(res->lock))
>> +		goto err_get_res_lock_failed;
>> +
>> +	mm = res->vma->vm_mm;
>> +	if (!mmget_not_zero(mm))
>> +		goto err_mmget;
>> +	if (!down_write_trylock(&mm->mmap_sem))
>> +		goto err_down_write_mmap_sem_failed;
>> +
>> +	list_lru_isolate(lru, item);
>> +	spin_unlock(lock);
>> +
>> +	hash_del(&res->node);
>> +
>> +	up_write(&mm->mmap_sem);
>> +	mmput(mm);
>> +
>> +	spin_unlock(res->lock);
>> +
>> +	page = res->page;
>> +	unused = res->nr_unused;
>> +
>> +	kfree(res);
>> +
>> +	for (i = 0; i < HPAGE_PMD_NR; i++)
>> +		put_page(page + i);
>> +
>> +	if (unused)
>> +		mod_node_page_state(page_pgdat(page), NR_THP_RESERVED, -unused);
>> +
>> +	spin_lock(lock);
>> +
>> +	return LRU_REMOVED_RETRY;
>> +
>> +err_down_write_mmap_sem_failed:
>> +	mmput_async(mm);
>> +err_mmget:
>> +	spin_unlock(res->lock);
>> +err_get_res_lock_failed:
>> +	return LRU_SKIP;
>> +}
>> +
>> +static unsigned long
>> +thp_resvs_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
>> +{
>> +	unsigned long ret = list_lru_shrink_count(&thp_reservations_lru, sc);
>> +	return ret;
>> +}
>> +
>> +static unsigned long
>> +thp_resvs_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>> +{
>> +	unsigned long ret;
>> +
>> +	ret = list_lru_shrink_walk(&thp_reservations_lru, sc,
>> +				   thp_lru_free_reservation, NULL);
>> +	return ret;
>> +}
>> +
>> +static struct shrinker thp_resvs_shrinker = {
>> +	.count_objects = thp_resvs_shrink_count,
>> +	.scan_objects = thp_resvs_shrink_scan,
>> +	.seeks = DEFAULT_SEEKS,
>> +	.flags = SHRINKER_NUMA_AWARE,
>> +};
>> +
> As before, I think the shrinker stuff should be in separate patches. Get
> the core approach working first and then add bits on top. If nothing
> else, it means that a mistake in the shrinker behaviour will not kill
> the overall idea just because it's a monolithic patch.
>
>>  int __init khugepaged_init(void)
>>  {
>> +	int err;
>> +
>>  	mm_slot_cache = kmem_cache_create("khugepaged_mm_slot",
>>  					  sizeof(struct mm_slot),
>>  					  __alignof__(struct mm_slot), 0, NULL);
>> @@ -354,6 +893,17 @@ int __init khugepaged_init(void)
>>  	khugepaged_max_ptes_none = HPAGE_PMD_NR - 1;
>>  	khugepaged_max_ptes_swap = HPAGE_PMD_NR / 8;
>>  
>> +	// XXX should be in hugepage_init() so shrinker can be
>> +	// unregistered if necessary.
>> +	err = list_lru_init(&thp_reservations_lru);
>> +	if (err == 0) {
>> +		err = register_shrinker(&thp_resvs_shrinker);
>> +		if (err) {
>> +			list_lru_destroy(&thp_reservations_lru);
>> +			return err;
>> +		}
>> +	}
>> +
>>  	return 0;
>>  }
>>  
>> @@ -519,12 +1069,14 @@ static void release_pte_pages(pte_t *pte, pte_t *_pte)
>>  
>>  static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>>  					unsigned long address,
>> -					pte_t *pte)
>> +					pte_t *pte,
>> +					struct thp_reservation *res)
>>  {
>>  	struct page *page = NULL;
>>  	pte_t *_pte;
>>  	int none_or_zero = 0, result = 0, referenced = 0;
>>  	bool writable = false;
>> +	bool is_reserved = res ? true : false;
>>  
>>  	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
>>  	     _pte++, address += PAGE_SIZE) {
>> @@ -573,7 +1125,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>>  		 * The page must only be referenced by the scanned process
>>  		 * and page swap cache.
>>  		 */
>> -		if (page_count(page) != 1 + PageSwapCache(page)) {
>> +		if (page_count(page) != 1 + PageSwapCache(page) + is_reserved) {
>>  			unlock_page(page);
>>  			result = SCAN_PAGE_COUNT;
>>  			goto out;
>> @@ -631,6 +1183,68 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>>  	return 0;
>>  }
>>  
>> +static void __collapse_huge_page_convert(pte_t *pte, struct page *page,
>> +				      struct vm_area_struct *vma,
>> +				      unsigned long address,
>> +				      spinlock_t *ptl)
>> +{
>> +	struct page *head = page;
>> +	pte_t *_pte;
>> +
>> +	set_page_count(page, 1);
>> +
>> +	for (_pte = pte; _pte < pte + HPAGE_PMD_NR;
>> +				_pte++, page++, address += PAGE_SIZE) {
>> +		pte_t pteval = *_pte;
>> +
>> +		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
>> +			clear_user_highpage(page, address);
> Needs commenting. At a glance it's not clear what happens if the entire
> range was zero pfns. Does that convert into one large allocated huge
> page? If so, it goes counter to the goal of reducing memory usage.
By default khugepaged skips page ranges that are entirely zero pfns
(khugepaged_max_ptes_none = HPAGE_PMD_NR - 1).
>
>> +			add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
>> +			if (is_zero_pfn(pte_pfn(pteval))) {
>> +				/*
>> +				 * ptl mostly unnecessary.
>> +				 */
>> +				spin_lock(ptl);
>> +				/*
>> +				 * paravirt calls inside pte_clear here are
>> +				 * superfluous.
>> +				 */
>> +				pte_clear(vma->vm_mm, address, _pte);
>> +				spin_unlock(ptl);
>> +			}
>> +			dec_node_page_state(page, NR_THP_RESERVED);
>> +		} else {
>> +			dec_node_page_state(page, NR_ISOLATED_ANON +
>> +					    page_is_file_cache(page));
>> +			unlock_page(page);
>> +			ClearPageActive(page);
>> +			/*
>> +			 * ptl mostly unnecessary, but preempt has to
>> +			 * be disabled to update the per-cpu stats
>> +			 * inside page_remove_rmap().
>> +			 */
>> +			spin_lock(ptl);
>> +			/*
>> +			 * paravirt calls inside pte_clear here are
>> +			 * superfluous.
>> +			 */
>> +			pte_clear(vma->vm_mm, address, _pte);
>> +			page_remove_rmap(page, false);
>> +			spin_unlock(ptl);
>> +			/*
>> +			 * Swapping out a page in a reservation
>> +			 * causes the reservation to be released
>> +			 * therefore no pages in a reservation
>> +			 * should be in swapcache.
>> +			 */
>> +			WARN_ON(PageSwapCache(page));
>> +		}
>> +	}
>> +
> The page table handling needs more careful review than I'm giving at the
> moment. It's another reason why the core approach should be as simple as
> possible as the patch has too much in it right now to keep it all in
> mind.
>
> I ran out of time at this point. Overall I don't see anything in there that
> fundamentally kills the idea and I think it's workable. It does need to
> be broken up though as reviewing a monolthic patch is going to be harder
> to review and a single mistake at the edges (like shrinkers or mremap)
> takes everything else with it. Focus on getting the reservation part right,
> the zero page handling and the collapse. For any corner case, dump all the
> reservations for a VMA or address space and let kcompactd clean it up later.
> It can then be evaluated that it's performance-neutral relative to the
> existing code and identify what workloads are helped by being clever.
>
> Thanks!
>
Thank you for the feedback!

Anthony
