Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4033C6B06AC
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:49:50 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id e62-v6so1681072ywf.21
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:49:50 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t6-v6si3926776ybo.152.2018.11.08.22.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 22:49:46 -0800 (PST)
From: Anthony Yznaga <anthony.yznaga@oracle.com>
Subject: [RFC PATCH] mm: thp: implement THP reservations for anonymous memory
Date: Thu,  8 Nov 2018 22:48:58 -0800
Message-Id: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com

When the THP enabled policy is "always", or the mode is "madvise" and a
region is marked as MADV_HUGEPAGE, a hugepage is allocated on a page
fault if the PMD is empty.  This yields the best VA translation
performance but increases memory consumption if a significant part of
the huge page is never accessed.

A while back a former colleague presented a patch to help address this
bloat [1]. Feedback from the community suggested investigating an alternate
approach to allocating THP hugepages using reservations, and since then
I have taken my colleague's work and expanded on it to implement a form
of reservation-based THP for private anonymous memory.  What I hope to
gain from this RFC is whether this approach is viable and what issues
there may be that I had not considered.  Apologies for the monolithic
patch.

The basic idea as outlined by Mel Gorman in [2] is:

1) On first fault in a sufficiently sized range, allocate a huge page
   sized and aligned block of base pages.  Map the base page
   corresponding to the fault address and hold the rest of the pages in
   reserve.
2) On subsequent faults in the range, map the pages from the reservation.
3) When enough pages have been mapped, promote the mapped pages and
   remaining pages in the reservation to a huge page.
4) When there is memory pressure, release the unused pages from their
   reservations.

[1] https://marc.info/?l=linux-mm&m=151631857310828&w=2
[2] https://lkml.org/lkml/2018/1/25/571

To test the idea I wrote a simple test that repeatedly forks children
where each child attempts to allocate a very large chunk of memory and
then touch either 1 page or a random number of pages in each huge page
region of the chunk.  On a machine with 256GB with a test chunk size of
16GB the test ends when the 17th child fails to map its chunk.  With THP
reservations enabled, the test ends when the 118th child fails.

Below are some additional implementation details and known issues.

User-visible files:

/sys/kernel/mm/transparent_hugepage/promotion_threshold

	The number of base pages within a huge page aligned region that
	must be faulted in before the region is eligible for promotion
	to a huge page.

 	1
 	On the first page fault in a huge page sized and aligned
 	region, allocate and map a huge page.

 	> 1
 	On the first page fault in a huge page sized and aligned
 	region, allocate and reserve a huge page sized and aligned
 	block of pages and map a single page from the reservation.
 	Continue to map pages from the reservation on subsequent
 	faults.  Once the number of pages faulted from the reservation
 	is equal to or greater than the promotion_threshold, the
 	reservation is eligible to be promoted to a huge page by
 	khugepaged.

	Currently the default value is HPAGE_PMD_NR / 2.

/sys/kernel/mm/transparent_hugepage/khugepaged/res_pages_collapsed

	The number of THP reservations promoted to huge pages
	by khugepaged.

	This total is also included in the total reported in pages_collapsed.

Counters added to /proc/vmstat:

nr_thp_reserved

	The total number of small pages in existing reservations
	that have not had a page fault since their respective
	reservation were created.  The amount is also included
	in the estimated total memory available as reported
	in MemAvailable in /proc/meminfo.

thp_res_alloc

	Incremented every time the pages for a reservation have been
	successfully allocated to handle a page fault.

thp_res_alloc_failed

	Incremented if pages could not successfully allocated for
	a reservation.

Known Issues:

- COW handling of reservations is insufficient.   While the pages of a
reservation are shared between parent and child after fork, currently
the reservation data structures are not shared and remain with the
parent.  A COW fault by the child allocates a new small page and a new
reservation is not allocated.  A COW fault by the parent allocates a new
small page and releases the reservation if one exists.

- If the pages in a reservation are remapped read-only (e.g. after fork
and child exit), khugepaged will never promote the pages to a huge page
until at least one page is written.

- A reservation is allocated even if the first fault on a pmd range maps
a zero page.  It may be more space efficient to allocate the reservation
on the first write fault.

- To facilitate the shrinker implementation, reservations are kept in a
global struct list_lru.  The list_lru internal implementation puts items
added to a list_lru on to per-node lists based on the node id derived
from the address of the item passed to list_lru_add().  For the current
reservations shrinker implementation this means that reservations will
be placed on the internal per-node list corresponding to the node where
the reservation data structure is located rather than the node where the
reserved pages are located.

- When a partly used reservation is promoted to a huge page, the unused
pages are not charged to a memcg.

- Minor code duplication to support mremap.

Other TBD:
- Performance testing
- shmem support
- Investigate promoting a reservation synchronously during fault handling
  rather than waiting for khugepaged to do the promotion.

Signed-off-by: Anthony Yznaga <anthony.yznaga@oracle.com>
---
 include/linux/huge_mm.h       |   1 +
 include/linux/khugepaged.h    | 119 +++++++
 include/linux/memcontrol.h    |   5 +
 include/linux/mm_types.h      |   3 +
 include/linux/mmzone.h        |   1 +
 include/linux/vm_event_item.h |   2 +
 kernel/fork.c                 |   2 +
 mm/huge_memory.c              |  29 ++
 mm/khugepaged.c               | 739 ++++++++++++++++++++++++++++++++++++++++--
 mm/memcontrol.c               |  33 ++
 mm/memory.c                   |  37 ++-
 mm/mmap.c                     |  14 +
 mm/mremap.c                   |   5 +
 mm/page_alloc.c               |   5 +
 mm/rmap.c                     |   3 +
 mm/util.c                     |   5 +
 mm/vmstat.c                   |   3 +
 17 files changed, 975 insertions(+), 31 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index fdcb45999b26..a2288f134d5d 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -92,6 +92,7 @@ extern ssize_t single_hugepage_flag_show(struct kobject *kobj,
 extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
 extern unsigned long transparent_hugepage_flags;
+extern unsigned int hugepage_promotion_threshold;
 
 static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 {
diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
index 082d1d2a5216..0011eb656ff3 100644
--- a/include/linux/khugepaged.h
+++ b/include/linux/khugepaged.h
@@ -2,6 +2,7 @@
 #ifndef _LINUX_KHUGEPAGED_H
 #define _LINUX_KHUGEPAGED_H
 
+#include <linux/hashtable.h>
 #include <linux/sched/coredump.h> /* MMF_VM_HUGEPAGE */
 
 
@@ -30,6 +31,64 @@ extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 	(transparent_hugepage_flags &				\
 	 (1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG))
 
+struct thp_reservation {
+	spinlock_t *lock;
+	unsigned long haddr;
+	struct page *page;
+	struct vm_area_struct *vma;
+	struct hlist_node node;
+	struct list_head lru;
+	int nr_unused;
+};
+
+struct thp_resvs {
+	atomic_t refcnt;
+	spinlock_t res_hash_lock;
+	DECLARE_HASHTABLE(res_hash, 7);
+};
+
+#define	vma_thp_reservations(vma)	((vma)->thp_reservations)
+
+static inline void thp_resvs_fork(struct vm_area_struct *vma,
+				  struct vm_area_struct *pvma)
+{
+	// XXX Do not share THP reservations for now
+	vma->thp_reservations = NULL;
+}
+
+void thp_resvs_new(struct vm_area_struct *vma);
+
+extern void __thp_resvs_put(struct thp_resvs *r);
+static inline void thp_resvs_put(struct thp_resvs *r)
+{
+	if (r)
+		__thp_resvs_put(r);
+}
+
+void khugepaged_mod_resv_unused(struct vm_area_struct *vma,
+				  unsigned long address, int delta);
+
+struct page *khugepaged_get_reserved_page(
+	struct vm_area_struct *vma,
+	unsigned long address);
+
+void khugepaged_reserve(struct vm_area_struct *vma,
+			unsigned long address);
+
+void khugepaged_release_reservation(struct vm_area_struct *vma,
+				    unsigned long address);
+
+void _khugepaged_reservations_fixup(struct vm_area_struct *src,
+				   struct vm_area_struct *dst);
+
+void _khugepaged_move_reservations_adj(struct vm_area_struct *prev,
+				      struct vm_area_struct *next, long adjust);
+
+void thp_reservations_mremap(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len,
+		bool need_rmap_locks);
+
 static inline int khugepaged_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 {
 	if (test_bit(MMF_VM_HUGEPAGE, &oldmm->flags))
@@ -56,6 +115,66 @@ static inline int khugepaged_enter(struct vm_area_struct *vma,
 	return 0;
 }
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
+
+#define	vma_thp_reservations(vma)	NULL
+
+static inline void thp_resvs_fork(struct vm_area_struct *vma,
+				  struct vm_area_struct *pvma)
+{
+}
+
+static inline void thp_resvs_new(struct vm_area_struct *vma)
+{
+}
+
+static inline void __thp_resvs_put(struct thp_resvs *r)
+{
+}
+
+static inline void thp_resvs_put(struct thp_resvs *r)
+{
+}
+
+static inline void khugepaged_mod_resv_unused(struct vm_area_struct *vma,
+					      unsigned long address, int delta)
+{
+}
+
+static inline struct page *khugepaged_get_reserved_page(
+	struct vm_area_struct *vma,
+	unsigned long address)
+{
+	return NULL;
+}
+
+static inline void khugepaged_reserve(struct vm_area_struct *vma,
+			       unsigned long address)
+{
+}
+
+static inline void khugepaged_release_reservation(struct vm_area_struct *vma,
+				    unsigned long address)
+{
+}
+
+static inline void _khugepaged_reservations_fixup(struct vm_area_struct *src,
+				   struct vm_area_struct *dst)
+{
+}
+
+static inline void _khugepaged_move_reservations_adj(
+				struct vm_area_struct *prev,
+				struct vm_area_struct *next, long adjust)
+{
+}
+
+static inline void thp_reservations_mremap(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len,
+		bool need_rmap_locks)
+{
+}
+
 static inline int khugepaged_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 {
 	return 0;
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 652f602167df..6342d5f67f75 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -787,6 +787,7 @@ static inline void memcg_memory_event_mm(struct mm_struct *mm,
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+void mem_cgroup_collapse_huge_fixup(struct page *head);
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
 
@@ -1087,6 +1088,10 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 	return 0;
 }
 
+static inline void mem_cgroup_collapse_huge_fixup(struct page *head)
+{
+}
+
 static inline void mem_cgroup_split_huge_fixup(struct page *head)
 {
 }
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5ed8f6292a53..72a9f431145e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -322,6 +322,9 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	struct thp_resvs *thp_reservations;
+#endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
 } __randomize_layout;
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d4b0c79d2924..7deac5a1f25d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -181,6 +181,7 @@ enum node_stat_item {
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
 	NR_INDIRECTLY_RECLAIMABLE_BYTES, /* measured in bytes */
+	NR_THP_RESERVED,	/* Unused small pages in THP reservations */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 47a3441cf4c4..f3d34db7e9d5 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -88,6 +88,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 		THP_SWPOUT,
 		THP_SWPOUT_FALLBACK,
+		THP_RES_ALLOC,
+		THP_RES_ALLOC_FAILED,
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 		BALLOON_INFLATE,
diff --git a/kernel/fork.c b/kernel/fork.c
index f0b58479534f..a15d1cda1958 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -527,6 +527,8 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		if (is_vm_hugetlb_page(tmp))
 			reset_vma_resv_huge_pages(tmp);
 
+		thp_resvs_fork(tmp, mpnt);
+
 		/*
 		 * Link in the new vma and copy the page table entries.
 		 */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index deed97fba979..aa80b9c54d1c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -57,6 +57,8 @@
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
 
+unsigned int hugepage_promotion_threshold __read_mostly = HPAGE_PMD_NR / 2;
+
 static struct shrinker deferred_split_shrinker;
 
 static atomic_t huge_zero_refcount;
@@ -288,6 +290,28 @@ static ssize_t use_zero_page_store(struct kobject *kobj,
 static struct kobj_attribute use_zero_page_attr =
 	__ATTR(use_zero_page, 0644, use_zero_page_show, use_zero_page_store);
 
+static ssize_t promotion_threshold_show(struct kobject *kobj,
+		struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", hugepage_promotion_threshold);
+}
+static ssize_t promotion_threshold_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	int err;
+	unsigned long promotion_threshold;
+
+	err = kstrtoul(buf, 10, &promotion_threshold);
+	if (err || promotion_threshold < 1 || promotion_threshold > HPAGE_PMD_NR)
+		return -EINVAL;
+
+	hugepage_promotion_threshold = promotion_threshold;
+
+	return count;
+}
+static struct kobj_attribute promotion_threshold_attr =
+	__ATTR(promotion_threshold, 0644, promotion_threshold_show, promotion_threshold_store);
+
 static ssize_t hpage_pmd_size_show(struct kobject *kobj,
 		struct kobj_attribute *attr, char *buf)
 {
@@ -318,6 +342,7 @@ static ssize_t debug_cow_store(struct kobject *kobj,
 	&enabled_attr.attr,
 	&defrag_attr.attr,
 	&use_zero_page_attr.attr,
+	&promotion_threshold_attr.attr,
 	&hpage_pmd_size_attr.attr,
 #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
 	&shmem_enabled_attr.attr,
@@ -670,6 +695,10 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 	struct page *page;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 
+	if (hugepage_promotion_threshold > 1) {
+		khugepaged_reserve(vma, vmf->address);
+		return VM_FAULT_FALLBACK;
+	}
 	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
 		return VM_FAULT_FALLBACK;
 	if (unlikely(anon_vma_prepare(vma)))
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index a31d740e6cd1..55d380f8ce71 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -8,6 +8,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/rmap.h>
 #include <linux/swap.h>
+#include <linux/shrinker.h>
 #include <linux/mm_inline.h>
 #include <linux/kthread.h>
 #include <linux/khugepaged.h>
@@ -56,6 +57,7 @@ enum scan_result {
 /* default scan 8*512 pte (or vmas) every 30 second */
 static unsigned int khugepaged_pages_to_scan __read_mostly;
 static unsigned int khugepaged_pages_collapsed;
+static unsigned int khugepaged_res_pages_collapsed;
 static unsigned int khugepaged_full_scans;
 static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
 /* during fragmentation poll the hugepage allocator once every minute */
@@ -76,6 +78,445 @@ enum scan_result {
 
 static struct kmem_cache *mm_slot_cache __read_mostly;
 
+struct list_lru thp_reservations_lru;
+
+void thp_resvs_new(struct vm_area_struct *vma)
+{
+	struct thp_resvs *new = NULL;
+
+	if (hugepage_promotion_threshold == 1)
+		goto done;
+
+	new = kzalloc(sizeof(struct thp_resvs), GFP_KERNEL);
+	if (!new)
+		goto done;
+
+	atomic_set(&new->refcnt, 1);
+	spin_lock_init(&new->res_hash_lock);
+	hash_init(new->res_hash);
+
+done:
+	vma->thp_reservations = new;
+}
+
+void __thp_resvs_put(struct thp_resvs *resv)
+{
+	if (!atomic_dec_and_test(&resv->refcnt))
+		return;
+
+	kfree(resv);
+}
+
+static struct thp_reservation *khugepaged_find_reservation(
+	struct vm_area_struct *vma,
+	unsigned long address)
+{
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct thp_reservation *res = NULL;
+
+	if (!vma->thp_reservations)
+		return NULL;
+
+	hash_for_each_possible(vma->thp_reservations->res_hash, res, node, haddr) {
+		if (res->haddr == haddr)
+			break;
+	}
+	return res;
+}
+
+static void khugepaged_free_reservation(struct thp_reservation *res)
+{
+	struct page *page;
+	int unused;
+	int i;
+
+	list_lru_del(&thp_reservations_lru, &res->lru);
+	hash_del(&res->node);
+	page = res->page;
+	unused = res->nr_unused;
+
+	kfree(res);
+
+	if (!PageCompound(page)) {
+		for (i = 0; i < HPAGE_PMD_NR; i++)
+			put_page(page + i);
+
+		if (unused) {
+			mod_node_page_state(page_pgdat(page), NR_THP_RESERVED,
+					    -unused);
+		}
+	}
+}
+
+void khugepaged_reserve(struct vm_area_struct *vma, unsigned long address)
+{
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct thp_reservation *res;
+	struct page *page;
+	gfp_t gfp;
+	int i;
+
+	if (!vma->thp_reservations)
+		return;
+	if (!vma_is_anonymous(vma))
+		return;
+	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
+		return;
+
+	spin_lock(&vma->thp_reservations->res_hash_lock);
+
+	if (khugepaged_find_reservation(vma, address)) {
+		spin_unlock(&vma->thp_reservations->res_hash_lock);
+		return;
+	}
+
+	/*
+	 * Allocate the equivalent of a huge page but not as a compound page
+	 */
+	gfp = GFP_TRANSHUGE_LIGHT & ~__GFP_COMP;
+	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
+	if (unlikely(!page)) {
+		count_vm_event(THP_RES_ALLOC_FAILED);
+		spin_unlock(&vma->thp_reservations->res_hash_lock);
+		return;
+	}
+
+	for (i = 0; i < HPAGE_PMD_NR; i++)
+		set_page_count(page + i, 1);
+
+	res = kzalloc(sizeof(*res), GFP_KERNEL);
+	if (!res) {
+		count_vm_event(THP_RES_ALLOC_FAILED);
+		__free_pages(page, HPAGE_PMD_ORDER);
+		spin_unlock(&vma->thp_reservations->res_hash_lock);
+		return;
+	}
+
+	count_vm_event(THP_RES_ALLOC);
+
+	res->haddr = haddr;
+	res->page = page;
+	res->vma = vma;
+	res->lock = &vma->thp_reservations->res_hash_lock;
+	hash_add(vma->thp_reservations->res_hash, &res->node, haddr);
+
+	INIT_LIST_HEAD(&res->lru);
+	list_lru_add(&thp_reservations_lru, &res->lru);
+
+	res->nr_unused = HPAGE_PMD_NR;
+	mod_node_page_state(page_pgdat(page), NR_THP_RESERVED, HPAGE_PMD_NR);
+
+	spin_unlock(&vma->thp_reservations->res_hash_lock);
+
+	khugepaged_enter(vma, vma->vm_flags);
+}
+
+struct page *khugepaged_get_reserved_page(struct vm_area_struct *vma,
+					  unsigned long address)
+{
+	struct thp_reservation *res;
+	struct page *page;
+
+	if (!transparent_hugepage_enabled(vma))
+		return NULL;
+	if (!vma->thp_reservations)
+		return NULL;
+
+	spin_lock(&vma->thp_reservations->res_hash_lock);
+
+	page = NULL;
+	res = khugepaged_find_reservation(vma, address);
+	if (res) {
+		unsigned long offset = address & ~HPAGE_PMD_MASK;
+
+		page = res->page + (offset >> PAGE_SHIFT);
+		get_page(page);
+
+		list_lru_del(&thp_reservations_lru, &res->lru);
+		list_lru_add(&thp_reservations_lru, &res->lru);
+
+		dec_node_page_state(res->page, NR_THP_RESERVED);
+	}
+
+	spin_unlock(&vma->thp_reservations->res_hash_lock);
+
+	return page;
+}
+
+void khugepaged_release_reservation(struct vm_area_struct *vma,
+				    unsigned long address)
+{
+	struct thp_reservation *res;
+
+	if (!vma->thp_reservations)
+		return;
+
+	spin_lock(&vma->thp_reservations->res_hash_lock);
+
+	res = khugepaged_find_reservation(vma, address);
+	if (!res)
+		goto out;
+
+	khugepaged_free_reservation(res);
+
+out:
+	spin_unlock(&vma->thp_reservations->res_hash_lock);
+}
+
+/*
+ * Release all reservations covering a range in a VMA.
+ */
+void __khugepaged_release_reservations(struct vm_area_struct *vma,
+				       unsigned long addr, unsigned long len)
+{
+	struct thp_reservation *res;
+	struct hlist_node *tmp;
+	unsigned long eaddr;
+	int i;
+
+	if (!vma->thp_reservations)
+		return;
+
+	eaddr = addr + len;
+	addr &= HPAGE_PMD_MASK;
+
+	spin_lock(&vma->thp_reservations->res_hash_lock);
+
+	hash_for_each_safe(vma->thp_reservations->res_hash, i, tmp, res, node) {
+		unsigned long hstart = res->haddr;
+
+		if (hstart >= addr && hstart < eaddr)
+			khugepaged_free_reservation(res);
+	}
+
+	spin_unlock(&vma->thp_reservations->res_hash_lock);
+}
+
+static void __khugepaged_move_reservations(struct vm_area_struct *src,
+					   struct vm_area_struct *dst,
+					   unsigned long split_addr,
+					   bool dst_is_below)
+{
+	struct thp_reservation *res;
+	struct hlist_node *tmp;
+	bool free_res = false;
+	int i;
+
+	if (!src->thp_reservations)
+		return;
+
+	if (!dst->thp_reservations)
+		free_res = true;
+
+	spin_lock(&src->thp_reservations->res_hash_lock);
+	if (!free_res)
+		spin_lock(&dst->thp_reservations->res_hash_lock);
+
+	hash_for_each_safe(src->thp_reservations->res_hash, i, tmp, res, node) {
+		unsigned long hstart = res->haddr;
+
+		/*
+		 * Free the reservation if it straddles a non-aligned
+		 * split address.
+		 */
+		if ((split_addr & ~HPAGE_PMD_MASK) &&
+		    (hstart == (split_addr & HPAGE_PMD_MASK))) {
+			khugepaged_free_reservation(res);
+			continue;
+		} else if (dst_is_below) {
+			if (hstart >= split_addr)
+				continue;
+		} else if (hstart < split_addr) {
+			continue;
+		}
+
+		if (unlikely(free_res)) {
+			khugepaged_free_reservation(res);
+			continue;
+		}
+
+		hash_del(&res->node);
+		res->vma = dst;
+		res->lock = &dst->thp_reservations->res_hash_lock;
+		hash_add(dst->thp_reservations->res_hash, &res->node, res->haddr);
+	}
+
+	if (!free_res)
+		spin_unlock(&dst->thp_reservations->res_hash_lock);
+	spin_unlock(&src->thp_reservations->res_hash_lock);
+}
+
+/*
+ * XXX dup from mm/mremap.c.  Move thp_reservations_mremap() to mm/mremap.c?
+ */
+static void take_rmap_locks(struct vm_area_struct *vma)
+{
+	if (vma->vm_file)
+		i_mmap_lock_write(vma->vm_file->f_mapping);
+	if (vma->anon_vma)
+		anon_vma_lock_write(vma->anon_vma);
+}
+
+/*
+ * XXX dup from mm/mremap.c.  Move thp_reservations_mremap() to mm/mremap.c?
+ */
+static void drop_rmap_locks(struct vm_area_struct *vma)
+{
+	if (vma->anon_vma)
+		anon_vma_unlock_write(vma->anon_vma);
+	if (vma->vm_file)
+		i_mmap_unlock_write(vma->vm_file->f_mapping);
+}
+
+void thp_reservations_mremap(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len,
+		bool need_rmap_locks)
+{
+
+	struct thp_reservation *res;
+	unsigned long eaddr, offset;
+	struct hlist_node *tmp;
+	int i;
+
+	if (!vma->thp_reservations)
+		return;
+
+	if (!new_vma->thp_reservations) {
+		__khugepaged_release_reservations(vma, old_addr, len);
+		return;
+	}
+
+	/*
+	 * Release all reservations if they will no longer be aligned
+	 * in the new address range.
+	 */
+	if ((new_addr & ~HPAGE_PMD_MASK) != (old_addr & ~HPAGE_PMD_MASK)) {
+		__khugepaged_release_reservations(vma, old_addr, len);
+		return;
+	}
+
+	if (need_rmap_locks)
+		take_rmap_locks(vma);
+
+	spin_lock(&vma->thp_reservations->res_hash_lock);
+	spin_lock(&new_vma->thp_reservations->res_hash_lock);
+
+	/*
+	 * If the start or end addresses of the range are not huge page
+	 * aligned, check for overlapping reservations and release them.
+	 */
+	if (old_addr & ~HPAGE_PMD_MASK) {
+		res = khugepaged_find_reservation(vma, old_addr);
+		if (res)
+			khugepaged_free_reservation(res);
+	}
+
+	eaddr = old_addr + len;
+	if (eaddr & ~HPAGE_PMD_MASK) {
+		res = khugepaged_find_reservation(vma, eaddr);
+		if (res)
+			khugepaged_free_reservation(res);
+	}
+
+	offset = new_addr - old_addr;
+
+	hash_for_each_safe(vma->thp_reservations->res_hash, i, tmp, res, node) {
+		unsigned long hstart = res->haddr;
+
+		if (hstart < old_addr || hstart >= eaddr)
+			continue;
+
+		hash_del(&res->node);
+		res->lock = &new_vma->thp_reservations->res_hash_lock;
+		res->vma = new_vma;
+		res->haddr += offset;
+		hash_add(new_vma->thp_reservations->res_hash, &res->node, res->haddr);
+	}
+
+	spin_unlock(&new_vma->thp_reservations->res_hash_lock);
+	spin_unlock(&vma->thp_reservations->res_hash_lock);
+
+	if (need_rmap_locks)
+		drop_rmap_locks(vma);
+
+}
+
+/*
+ * Handle moving reservations for VMA merge cases 1, 6, 7, and 8 (see
+ * comments above vma_merge()) and when splitting a VMA.
+ *
+ * src is expected to be aligned with the start or end of dst
+ * src may be contained by dst or directly adjacent to dst
+ * Move all reservations if src is contained by dst.
+ * Otherwise move reservations no longer in the range of src
+ * to dst.
+ */
+void _khugepaged_reservations_fixup(struct vm_area_struct *src,
+				    struct vm_area_struct *dst)
+{
+	bool dst_is_below = false;
+	unsigned long split_addr;
+
+	if (src->vm_start == dst->vm_start || src->vm_end == dst->vm_end) {
+		split_addr = 0;
+	} else if (src->vm_start == dst->vm_end) {
+		split_addr = src->vm_start;
+		dst_is_below = true;
+	} else if (src->vm_end == dst->vm_start) {
+		split_addr = src->vm_end;
+	} else {
+		WARN_ON(1);
+		return;
+	}
+
+	__khugepaged_move_reservations(src, dst, split_addr, dst_is_below);
+}
+
+/*
+ * Handle moving reservations for VMA merge cases 4 and 5 (see comments
+ * above vma_merge()).
+ */
+void _khugepaged_move_reservations_adj(struct vm_area_struct *prev,
+				       struct vm_area_struct *next, long adjust)
+{
+	unsigned long split_addr = next->vm_start;
+	struct vm_area_struct *src, *dst;
+	bool dst_is_below;
+
+	if (adjust < 0) {
+		src = prev;
+		dst = next;
+		dst_is_below = false;
+	} else {
+		src = next;
+		dst = prev;
+		dst_is_below = true;
+	}
+
+	__khugepaged_move_reservations(src, dst, split_addr, dst_is_below);
+}
+
+void khugepaged_mod_resv_unused(struct vm_area_struct *vma,
+				unsigned long address, int delta)
+{
+	struct thp_reservation *res;
+
+	if (!vma->thp_reservations)
+		return;
+
+	spin_lock(&vma->thp_reservations->res_hash_lock);
+
+	res = khugepaged_find_reservation(vma, address);
+	if (res) {
+		WARN_ON((res->nr_unused == 0) || (res->nr_unused + delta < 0));
+		if (res->nr_unused + delta >= 0)
+			res->nr_unused += delta;
+	}
+
+	spin_unlock(&vma->thp_reservations->res_hash_lock);
+}
+
 /**
  * struct mm_slot - hash lookup from mm to mm_slot
  * @hash: hash collision list
@@ -197,6 +638,15 @@ static ssize_t pages_collapsed_show(struct kobject *kobj,
 static struct kobj_attribute pages_collapsed_attr =
 	__ATTR_RO(pages_collapsed);
 
+static ssize_t res_pages_collapsed_show(struct kobject *kobj,
+				    struct kobj_attribute *attr,
+				    char *buf)
+{
+	return sprintf(buf, "%u\n", khugepaged_res_pages_collapsed);
+}
+static struct kobj_attribute res_pages_collapsed_attr =
+	__ATTR_RO(res_pages_collapsed);
+
 static ssize_t full_scans_show(struct kobject *kobj,
 			       struct kobj_attribute *attr,
 			       char *buf)
@@ -292,6 +742,7 @@ static ssize_t khugepaged_max_ptes_swap_store(struct kobject *kobj,
 	&scan_sleep_millisecs_attr.attr,
 	&alloc_sleep_millisecs_attr.attr,
 	&khugepaged_max_ptes_swap_attr.attr,
+	&res_pages_collapsed_attr.attr,
 	NULL,
 };
 
@@ -342,8 +793,96 @@ int hugepage_madvise(struct vm_area_struct *vma,
 	return 0;
 }
 
+/*
+ * thp_lru_free_reservation() - shrinker callback to release THP reservations
+ * and free unused pages
+ *
+ * Called from list_lru_shrink_walk() in thp_resvs_shrink_scan() to free
+ * up pages when the system is under memory pressure.
+ */
+enum lru_status thp_lru_free_reservation(struct list_head *item,
+					 struct list_lru_one *lru,
+					 spinlock_t *lock,
+					 void *cb_arg)
+{
+	struct mm_struct *mm = NULL;
+	struct thp_reservation *res = container_of(item,
+						   struct thp_reservation,
+						   lru);
+	struct page *page;
+	int unused;
+	int i;
+
+	if (!spin_trylock(res->lock))
+		goto err_get_res_lock_failed;
+
+	mm = res->vma->vm_mm;
+	if (!mmget_not_zero(mm))
+		goto err_mmget;
+	if (!down_write_trylock(&mm->mmap_sem))
+		goto err_down_write_mmap_sem_failed;
+
+	list_lru_isolate(lru, item);
+	spin_unlock(lock);
+
+	hash_del(&res->node);
+
+	up_write(&mm->mmap_sem);
+	mmput(mm);
+
+	spin_unlock(res->lock);
+
+	page = res->page;
+	unused = res->nr_unused;
+
+	kfree(res);
+
+	for (i = 0; i < HPAGE_PMD_NR; i++)
+		put_page(page + i);
+
+	if (unused)
+		mod_node_page_state(page_pgdat(page), NR_THP_RESERVED, -unused);
+
+	spin_lock(lock);
+
+	return LRU_REMOVED_RETRY;
+
+err_down_write_mmap_sem_failed:
+	mmput_async(mm);
+err_mmget:
+	spin_unlock(res->lock);
+err_get_res_lock_failed:
+	return LRU_SKIP;
+}
+
+static unsigned long
+thp_resvs_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
+{
+	unsigned long ret = list_lru_shrink_count(&thp_reservations_lru, sc);
+	return ret;
+}
+
+static unsigned long
+thp_resvs_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
+{
+	unsigned long ret;
+
+	ret = list_lru_shrink_walk(&thp_reservations_lru, sc,
+				   thp_lru_free_reservation, NULL);
+	return ret;
+}
+
+static struct shrinker thp_resvs_shrinker = {
+	.count_objects = thp_resvs_shrink_count,
+	.scan_objects = thp_resvs_shrink_scan,
+	.seeks = DEFAULT_SEEKS,
+	.flags = SHRINKER_NUMA_AWARE,
+};
+
 int __init khugepaged_init(void)
 {
+	int err;
+
 	mm_slot_cache = kmem_cache_create("khugepaged_mm_slot",
 					  sizeof(struct mm_slot),
 					  __alignof__(struct mm_slot), 0, NULL);
@@ -354,6 +893,17 @@ int __init khugepaged_init(void)
 	khugepaged_max_ptes_none = HPAGE_PMD_NR - 1;
 	khugepaged_max_ptes_swap = HPAGE_PMD_NR / 8;
 
+	// XXX should be in hugepage_init() so shrinker can be
+	// unregistered if necessary.
+	err = list_lru_init(&thp_reservations_lru);
+	if (err == 0) {
+		err = register_shrinker(&thp_resvs_shrinker);
+		if (err) {
+			list_lru_destroy(&thp_reservations_lru);
+			return err;
+		}
+	}
+
 	return 0;
 }
 
@@ -519,12 +1069,14 @@ static void release_pte_pages(pte_t *pte, pte_t *_pte)
 
 static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 					unsigned long address,
-					pte_t *pte)
+					pte_t *pte,
+					struct thp_reservation *res)
 {
 	struct page *page = NULL;
 	pte_t *_pte;
 	int none_or_zero = 0, result = 0, referenced = 0;
 	bool writable = false;
+	bool is_reserved = res ? true : false;
 
 	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, address += PAGE_SIZE) {
@@ -573,7 +1125,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		 * The page must only be referenced by the scanned process
 		 * and page swap cache.
 		 */
-		if (page_count(page) != 1 + PageSwapCache(page)) {
+		if (page_count(page) != 1 + PageSwapCache(page) + is_reserved) {
 			unlock_page(page);
 			result = SCAN_PAGE_COUNT;
 			goto out;
@@ -631,6 +1183,68 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 	return 0;
 }
 
+static void __collapse_huge_page_convert(pte_t *pte, struct page *page,
+				      struct vm_area_struct *vma,
+				      unsigned long address,
+				      spinlock_t *ptl)
+{
+	struct page *head = page;
+	pte_t *_pte;
+
+	set_page_count(page, 1);
+
+	for (_pte = pte; _pte < pte + HPAGE_PMD_NR;
+				_pte++, page++, address += PAGE_SIZE) {
+		pte_t pteval = *_pte;
+
+		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
+			clear_user_highpage(page, address);
+			add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
+			if (is_zero_pfn(pte_pfn(pteval))) {
+				/*
+				 * ptl mostly unnecessary.
+				 */
+				spin_lock(ptl);
+				/*
+				 * paravirt calls inside pte_clear here are
+				 * superfluous.
+				 */
+				pte_clear(vma->vm_mm, address, _pte);
+				spin_unlock(ptl);
+			}
+			dec_node_page_state(page, NR_THP_RESERVED);
+		} else {
+			dec_node_page_state(page, NR_ISOLATED_ANON +
+					    page_is_file_cache(page));
+			unlock_page(page);
+			ClearPageActive(page);
+			/*
+			 * ptl mostly unnecessary, but preempt has to
+			 * be disabled to update the per-cpu stats
+			 * inside page_remove_rmap().
+			 */
+			spin_lock(ptl);
+			/*
+			 * paravirt calls inside pte_clear here are
+			 * superfluous.
+			 */
+			pte_clear(vma->vm_mm, address, _pte);
+			page_remove_rmap(page, false);
+			spin_unlock(ptl);
+			/*
+			 * Swapping out a page in a reservation
+			 * causes the reservation to be released
+			 * therefore no pages in a reservation
+			 * should be in swapcache.
+			 */
+			WARN_ON(PageSwapCache(page));
+		}
+	}
+
+	prep_compound_page(head, HPAGE_PMD_ORDER);
+	prep_transhuge_page(head);
+}
+
 static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 				      struct vm_area_struct *vma,
 				      unsigned long address,
@@ -934,7 +1548,8 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 static void collapse_huge_page(struct mm_struct *mm,
 				   unsigned long address,
 				   struct page **hpage,
-				   int node, int referenced)
+				   int node, int referenced,
+				   struct thp_reservation *res)
 {
 	pmd_t *pmd, _pmd;
 	pte_t *pte;
@@ -947,6 +1562,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 	gfp_t gfp;
+	bool is_reserved = false;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
@@ -959,30 +1575,38 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * sync compaction, and we do not need to hold the mmap_sem during
 	 * that. We will recheck the vma after taking it again in write mode.
 	 */
-	up_read(&mm->mmap_sem);
-	new_page = khugepaged_alloc_page(hpage, gfp, node);
-	if (!new_page) {
-		result = SCAN_ALLOC_HUGE_PAGE_FAIL;
-		goto out_nolock;
-	}
+	if (res) {
+		new_page = res->page;
+		vma = res->vma;
+		is_reserved = true;
+	} else {
+		up_read(&mm->mmap_sem);
+		new_page = khugepaged_alloc_page(hpage, gfp, node);
 
-	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp, &memcg, true))) {
-		result = SCAN_CGROUP_CHARGE_FAIL;
-		goto out_nolock;
-	}
+		if (!new_page) {
+			result = SCAN_ALLOC_HUGE_PAGE_FAIL;
+			goto out_nolock;
+		}
 
-	down_read(&mm->mmap_sem);
-	result = hugepage_vma_revalidate(mm, address, &vma);
-	if (result) {
-		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
-		goto out_nolock;
+		if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp, &memcg, true))) {
+			result = SCAN_CGROUP_CHARGE_FAIL;
+			goto out_nolock;
+		}
+
+		down_read(&mm->mmap_sem);
+		result = hugepage_vma_revalidate(mm, address, &vma);
+		if (result) {
+			mem_cgroup_cancel_charge(new_page, memcg, true);
+			up_read(&mm->mmap_sem);
+			goto out_nolock;
+		}
 	}
 
 	pmd = mm_find_pmd(mm, address);
 	if (!pmd) {
 		result = SCAN_PMD_NULL;
-		mem_cgroup_cancel_charge(new_page, memcg, true);
+		if (is_reserved == false)
+			mem_cgroup_cancel_charge(new_page, memcg, true);
 		up_read(&mm->mmap_sem);
 		goto out_nolock;
 	}
@@ -993,7 +1617,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * Continuing to collapse causes inconsistency.
 	 */
 	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced)) {
-		mem_cgroup_cancel_charge(new_page, memcg, true);
+		if (is_reserved == false)
+			mem_cgroup_cancel_charge(new_page, memcg, true);
 		up_read(&mm->mmap_sem);
 		goto out_nolock;
 	}
@@ -1014,6 +1639,42 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	anon_vma_lock_write(vma->anon_vma);
 
+	/*
+	 * Revalidate the reservation now that the locking guarantees it will
+	 * not be released.
+	 */
+	if (is_reserved) {
+		int pgs_inuse;
+
+		res = khugepaged_find_reservation(vma, address);
+		if (!res) {
+			anon_vma_unlock_write(vma->anon_vma);
+			result = SCAN_VMA_CHECK;
+			goto out_up_write;
+		}
+
+		/*
+		 * XXX highly unlikely that the check in khugepage_scan_pmd()
+		 * would pass and this one would fail.
+		 */
+		pgs_inuse = HPAGE_PMD_NR - res->nr_unused;
+		if (pgs_inuse < hugepage_promotion_threshold) {
+			result = SCAN_PAGE_COUNT;
+			goto out_up_write;
+		}
+
+		new_page = res->page;
+
+		/* XXX
+		 * If some pages in the reservation are unused at this point,
+		 * they should be charged to a memcg if applicable.  Need to
+		 * determine the right way to do this when no further faults
+		 * can happen and the reservation will not be released.
+		 * mem_cgroup_try_charge() works by charging one page (or
+		 * huge page) at a time.
+		 */
+	}
+
 	pte = pte_offset_map(pmd, address);
 	pte_ptl = pte_lockptr(mm, pmd);
 
@@ -1032,7 +1693,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 	spin_lock(pte_ptl);
-	isolated = __collapse_huge_page_isolate(vma, address, pte);
+	isolated = __collapse_huge_page_isolate(vma, address, pte, res);
 	spin_unlock(pte_ptl);
 
 	if (unlikely(!isolated)) {
@@ -1057,7 +1718,12 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	anon_vma_unlock_write(vma->anon_vma);
 
-	__collapse_huge_page_copy(pte, new_page, vma, address, pte_ptl);
+	if (is_reserved) {
+		__collapse_huge_page_convert(pte, new_page, vma, address, pte_ptl);
+		khugepaged_free_reservation(res);
+	} else {
+		__collapse_huge_page_copy(pte, new_page, vma, address, pte_ptl);
+	}
 	pte_unmap(pte);
 	__SetPageUptodate(new_page);
 	pgtable = pmd_pgtable(_pmd);
@@ -1075,7 +1741,10 @@ static void collapse_huge_page(struct mm_struct *mm,
 	spin_lock(pmd_ptl);
 	BUG_ON(!pmd_none(*pmd));
 	page_add_new_anon_rmap(new_page, vma, address, true);
-	mem_cgroup_commit_charge(new_page, memcg, false, true);
+	if (is_reserved)
+		mem_cgroup_collapse_huge_fixup(new_page);
+	else
+		mem_cgroup_commit_charge(new_page, memcg, false, true);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, address, pmd, _pmd);
@@ -1085,6 +1754,10 @@ static void collapse_huge_page(struct mm_struct *mm,
 	*hpage = NULL;
 
 	khugepaged_pages_collapsed++;
+
+	if (is_reserved)
+		khugepaged_res_pages_collapsed++;
+
 	result = SCAN_SUCCEED;
 out_up_write:
 	up_write(&mm->mmap_sem);
@@ -1092,7 +1765,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	trace_mm_collapse_huge_page(mm, isolated, result);
 	return;
 out:
-	mem_cgroup_cancel_charge(new_page, memcg, true);
+	if (is_reserved == false)
+		mem_cgroup_cancel_charge(new_page, memcg, true);
 	goto out_up_write;
 }
 
@@ -1109,6 +1783,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	spinlock_t *ptl;
 	int node = NUMA_NO_NODE, unmapped = 0;
 	bool writable = false;
+	struct thp_reservation *res = 0;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
@@ -1184,12 +1859,22 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 			goto out_unmap;
 		}
 
+		res = khugepaged_find_reservation(vma, address);
+		if (res) {
+			int pgs_inuse = HPAGE_PMD_NR - res->nr_unused;
+
+			if (pgs_inuse < hugepage_promotion_threshold) {
+				result = SCAN_PAGE_COUNT;
+				goto out_unmap;
+			}
+		}
+
 		/*
 		 * cannot use mapcount: can't collapse if there's a gup pin.
 		 * The page must only be referenced by the scanned process
 		 * and page swap cache.
 		 */
-		if (page_count(page) != 1 + PageSwapCache(page)) {
+		if (page_count(page) != 1 + PageSwapCache(page) + (res ? 1 : 0)) {
 			result = SCAN_PAGE_COUNT;
 			goto out_unmap;
 		}
@@ -1213,7 +1898,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	if (ret) {
 		node = khugepaged_find_target_node();
 		/* collapse_huge_page will return with the mmap_sem released */
-		collapse_huge_page(mm, address, hpage, node, referenced);
+		collapse_huge_page(mm, address, hpage, node, referenced, res);
 	}
 out:
 	trace_mm_khugepaged_scan_pmd(mm, page, writable, referenced,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e79cb59552d9..9b9e4d3a6205 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2662,6 +2662,39 @@ void memcg_kmem_uncharge(struct page *page, int order)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
 /*
+ * Fix up the mem_cgroup field of the head and tail pages of a compound
+ * page that has been converted from a reservation into a huge page.
+ */
+void mem_cgroup_collapse_huge_fixup(struct page *head)
+{
+	int i;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	/*
+	 * Some pages may already have mem_cgroup == NULL if only some of
+	 * the pages in the reservation were faulted in when it was converted.
+	 */
+	for (i = 0; i < HPAGE_PMD_NR; i++) {
+		if (head[i].mem_cgroup != NULL) {
+			if (i != 0)
+				head->mem_cgroup = head[i].mem_cgroup;
+			else
+				i++;
+			break;
+		}
+	}
+	for (; i < HPAGE_PMD_NR; i++)
+		head[i].mem_cgroup = NULL;
+
+	if (WARN_ON(head->mem_cgroup == NULL))
+		return;
+
+	__mod_memcg_state(head->mem_cgroup, MEMCG_RSS_HUGE, HPAGE_PMD_NR);
+}
+
+/*
  * Because tail pages are not marked as "used", set it. We're under
  * zone_lru_lock and migration entries setup in all page mappings.
  */
diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..91df155c3991 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -51,6 +51,7 @@
 #include <linux/pagemap.h>
 #include <linux/memremap.h>
 #include <linux/ksm.h>
+#include <linux/khugepaged.h>
 #include <linux/rmap.h>
 #include <linux/export.h>
 #include <linux/delayacct.h>
@@ -1438,6 +1439,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			goto next;
 		next = zap_pte_range(tlb, vma, pmd, addr, next, details);
+		khugepaged_release_reservation(vma, addr);
 next:
 		cond_resched();
 	} while (pmd++, addr = next, addr != end);
@@ -2494,16 +2496,29 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 	const unsigned long mmun_start = vmf->address & PAGE_MASK;
 	const unsigned long mmun_end = mmun_start + PAGE_SIZE;
 	struct mem_cgroup *memcg;
+	bool pg_from_reservation = false;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
 
 	if (is_zero_pfn(pte_pfn(vmf->orig_pte))) {
-		new_page = alloc_zeroed_user_highpage_movable(vma,
+		new_page = khugepaged_get_reserved_page(vma, vmf->address);
+		if (!new_page) {
+			new_page = alloc_zeroed_user_highpage_movable(vma,
 							      vmf->address);
+		} else {
+			clear_user_highpage(new_page, vmf->address);
+			pg_from_reservation = true;
+		}
+
 		if (!new_page)
 			goto oom;
 	} else {
+		/*
+		 * XXX If there's a THP reservation, for now just
+		 * release it since they're not shared on fork.
+		 */
+		khugepaged_release_reservation(vma, vmf->address);
 		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
 				vmf->address);
 		if (!new_page)
@@ -2578,6 +2593,9 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 			page_remove_rmap(old_page, false);
 		}
 
+		if (pg_from_reservation)
+			khugepaged_mod_resv_unused(vma, vmf->address, -1);
+
 		/* Free the old page.. */
 		new_page = old_page;
 		page_copied = 1;
@@ -3124,6 +3142,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	struct page *page;
 	vm_fault_t ret = 0;
 	pte_t entry;
+	bool pg_from_reservation = false;
 
 	/* File mapping without ->vm_ops ? */
 	if (vma->vm_flags & VM_SHARED)
@@ -3169,9 +3188,16 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	/* Allocate our own private page. */
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
-	page = alloc_zeroed_user_highpage_movable(vma, vmf->address);
-	if (!page)
-		goto oom;
+
+	page = khugepaged_get_reserved_page(vma, vmf->address);
+	if (!page) {
+		page = alloc_zeroed_user_highpage_movable(vma, vmf->address);
+		if (!page)
+			goto oom;
+	} else {
+		clear_user_highpage(page, vmf->address);
+		pg_from_reservation = true;
+	}
 
 	if (mem_cgroup_try_charge_delay(page, vma->vm_mm, GFP_KERNEL, &memcg,
 					false))
@@ -3205,6 +3231,9 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 		return handle_userfault(vmf, VM_UFFD_MISSING);
 	}
 
+	if (pg_from_reservation)
+		khugepaged_mod_resv_unused(vma, vmf->address, -1);
+
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, vmf->address, false);
 	mem_cgroup_commit_charge(page, memcg, false, false);
diff --git a/mm/mmap.c b/mm/mmap.c
index f7cd9cb966c0..a1979392273b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -182,6 +182,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	if (vma->vm_file)
 		fput(vma->vm_file);
 	mpol_put(vma_policy(vma));
+	thp_resvs_put(vma_thp_reservations(vma));
 	vm_area_free(vma);
 	return next;
 }
@@ -839,6 +840,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	if (adjust_next) {
 		next->vm_start += adjust_next << PAGE_SHIFT;
 		next->vm_pgoff += adjust_next;
+		_khugepaged_move_reservations_adj(vma, next, adjust_next);
 	}
 
 	if (root) {
@@ -849,6 +851,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	}
 
 	if (remove_next) {
+		_khugepaged_reservations_fixup(next, vma);
+
 		/*
 		 * vma_merge has merged next into vma, and needs
 		 * us to remove next before dropping the locks.
@@ -875,6 +879,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 		 * (it may either follow vma or precede it).
 		 */
 		__insert_vm_struct(mm, insert);
+
+		_khugepaged_reservations_fixup(vma, insert);
 	} else {
 		if (start_changed)
 			vma_gap_update(vma);
@@ -1780,6 +1786,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 			goto free_vma;
 	} else {
 		vma_set_anonymous(vma);
+		thp_resvs_new(vma);
 	}
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
@@ -2640,6 +2647,9 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (err)
 		goto out_free_mpol;
 
+	if (vma_thp_reservations(vma))
+		thp_resvs_new(new);
+
 	if (new->vm_file)
 		get_file(new->vm_file);
 
@@ -2657,6 +2667,7 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 		return 0;
 
 	/* Clean everything up if vma_adjust failed. */
+	thp_resvs_put(vma_thp_reservations(new));
 	if (new->vm_ops && new->vm_ops->close)
 		new->vm_ops->close(new);
 	if (new->vm_file)
@@ -2992,6 +3003,7 @@ static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long fla
 	vma->vm_pgoff = pgoff;
 	vma->vm_flags = flags;
 	vma->vm_page_prot = vm_get_page_prot(flags);
+	thp_resvs_new(vma);
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 out:
 	perf_event_mmap(vma);
@@ -3205,6 +3217,8 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			goto out_free_vma;
 		if (anon_vma_clone(new_vma, vma))
 			goto out_free_mempol;
+		if (vma_thp_reservations(vma))
+			thp_resvs_new(new_vma);
 		if (new_vma->vm_file)
 			get_file(new_vma->vm_file);
 		if (new_vma->vm_ops && new_vma->vm_ops->open)
diff --git a/mm/mremap.c b/mm/mremap.c
index a9617e72e6b7..194c20cfce73 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -24,6 +24,7 @@
 #include <linux/uaccess.h>
 #include <linux/mm-arch-hooks.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/khugepaged.h>
 
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
@@ -294,6 +295,8 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	if (!new_vma)
 		return -ENOMEM;
 
+	thp_reservations_mremap(vma, old_addr, new_vma, new_addr, old_len,
+				need_rmap_locks);
 	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len,
 				     need_rmap_locks);
 	if (moved_len < old_len) {
@@ -308,6 +311,8 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		 * which will succeed since page tables still there,
 		 * and then proceed to unmap new area instead of old.
 		 */
+		thp_reservations_mremap(new_vma, new_addr, vma, old_addr,
+					moved_len, true);
 		move_page_tables(new_vma, new_addr, vma, old_addr, moved_len,
 				 true);
 		vma = new_vma;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e2ef1c17942f..0118775ab31a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4740,6 +4740,11 @@ long si_mem_available(void)
 	available += global_node_page_state(NR_INDIRECTLY_RECLAIMABLE_BYTES) >>
 		PAGE_SHIFT;
 
+	/*
+	 * Unused small pages in THP reservations
+	 */
+	available += global_node_page_state(NR_THP_RESERVED);
+
 	if (available < 0)
 		available = 0;
 	return available;
diff --git a/mm/rmap.c b/mm/rmap.c
index 1e79fac3186b..859fa1b1030c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -65,6 +65,7 @@
 #include <linux/page_idle.h>
 #include <linux/memremap.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/khugepaged.h>
 
 #include <asm/tlbflush.h>
 
@@ -1646,6 +1647,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			dec_mm_counter(mm, mm_counter_file(page));
 		}
 discard:
+		khugepaged_release_reservation(vma, address);
+
 		/*
 		 * No need to call mmu_notifier_invalidate_range() it has be
 		 * done above for all cases requiring it to happen under page
diff --git a/mm/util.c b/mm/util.c
index 9e3ebd2ef65f..e5617de04006 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -689,6 +689,11 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 			NR_INDIRECTLY_RECLAIMABLE_BYTES) >> PAGE_SHIFT;
 
 		/*
+		 * Unused small pages in THP reservations
+		 */
+		free += global_node_page_state(NR_THP_RESERVED);
+
+		/*
 		 * Leave reserved pages. The pages are not for anonymous pages.
 		 */
 		if (free <= totalreserve_pages)
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7878da76abf2..49c51c2b03f4 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1162,6 +1162,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 	"nr_dirtied",
 	"nr_written",
 	"", /* nr_indirectly_reclaimable */
+	"nr_thp_reserved",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
@@ -1263,6 +1264,8 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 	"thp_zero_page_alloc_failed",
 	"thp_swpout",
 	"thp_swpout_fallback",
+	"thp_res_alloc",
+	"thp_res_alloc_failed",
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 	"balloon_inflate",
-- 
1.8.3.1
