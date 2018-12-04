Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F2EC86B6DA8
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 03:18:03 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c3so7993374eda.3
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 00:18:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m2si4161177edr.3.2018.12.04.00.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 00:18:01 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB48DOa0184533
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 03:18:00 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p5ntrgcfm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 03:17:59 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 4 Dec 2018 08:17:57 -0000
Date: Tue, 4 Dec 2018 10:17:48 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 3/3] mm/mmu_notifier: contextual information for event
 triggering invalidation
References: <20181203201817.10759-1-jglisse@redhat.com>
 <20181203201817.10759-4-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181203201817.10759-4-jglisse@redhat.com>
Message-Id: <20181204081746.GJ26700@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christian Koenig <christian.koenig@amd.com>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org, dri-devel@lists.freedesktop.org

On Mon, Dec 03, 2018 at 03:18:17PM -0500, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> CPU page table update can happens for many reasons, not only as a result
> of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
> as a result of kernel activities (memory compression, reclaim, migration,
> ...).
> 
> Users of mmu notifier API track changes to the CPU page table and take
> specific action for them. While current API only provide range of virtual
> address affected by the change, not why the changes is happening.
> 
> This patchset adds event information so that users of mmu notifier can
> differentiate among broad category:
>     - UNMAP: munmap() or mremap()
>     - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
>     - PROTECTION_VMA: change in access protections for the range
>     - PROTECTION_PAGE: change in access protections for page in the range
>     - SOFT_DIRTY: soft dirtyness tracking
> 
> Being able to identify munmap() and mremap() from other reasons why the
> page table is cleared is important to allow user of mmu notifier to
> update their own internal tracking structure accordingly (on munmap or
> mremap it is not longer needed to track range of virtual address as it
> becomes invalid).
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Krčmář <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Christian Koenig <christian.koenig@amd.com>
> Cc: Felix Kuehling <felix.kuehling@amd.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-fsdevel@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> ---
>  fs/dax.c                     |  1 +
>  fs/proc/task_mmu.c           |  1 +
>  include/linux/mmu_notifier.h | 33 +++++++++++++++++++++++++++++++++
>  kernel/events/uprobes.c      |  1 +
>  mm/huge_memory.c             |  4 ++++
>  mm/hugetlb.c                 |  4 ++++
>  mm/khugepaged.c              |  1 +
>  mm/ksm.c                     |  2 ++
>  mm/madvise.c                 |  1 +
>  mm/memory.c                  |  5 +++++
>  mm/migrate.c                 |  2 ++
>  mm/mprotect.c                |  1 +
>  mm/mremap.c                  |  1 +
>  mm/oom_kill.c                |  1 +
>  mm/rmap.c                    |  2 ++
>  15 files changed, 60 insertions(+)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index e22508ee19ec..83092c5ac5f0 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -761,6 +761,7 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
>  		struct mmu_notifier_range range;
>  		unsigned long address;
> 
> +		range.event = MMU_NOTIFY_PROTECTION_PAGE;
>  		range.mm = vma->vm_mm;
> 
>  		cond_resched();
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 53d625925669..4abb1668eeb3 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1144,6 +1144,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  			range.start = 0;
>  			range.end = -1UL;
>  			range.mm = mm;
> +			range.event = MMU_NOTIFY_SOFT_DIRTY;
>  			mmu_notifier_invalidate_range_start(&range);
>  		}
>  		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index cbeece8e47d4..3077d487be8b 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -25,10 +25,43 @@ struct mmu_notifier_mm {
>  	spinlock_t lock;
>  };
> 
> +/*
> + * What event is triggering the invalidation:

Can you please make it kernel-doc comment?

> + *
> + * MMU_NOTIFY_UNMAP
> + *    either munmap() that unmap the range or a mremap() that move the range
> + *
> + * MMU_NOTIFY_CLEAR
> + *    clear page table entry (many reasons for this like madvise() or replacing
> + *    a page by another one, ...).
> + *
> + * MMU_NOTIFY_PROTECTION_VMA
> + *    update is due to protection change for the range ie using the vma access
> + *    permission (vm_page_prot) to update the whole range is enough no need to
> + *    inspect changes to the CPU page table (mprotect() syscall)
> + *
> + * MMU_NOTIFY_PROTECTION_PAGE
> + *    update is due to change in read/write flag for pages in the range so to
> + *    mirror those changes the user must inspect the CPU page table (from the
> + *    end callback).
> + *
> + *
> + * MMU_NOTIFY_SOFT_DIRTY
> + *    soft dirty accounting (still same page and same access flags)
> + */
> +enum mmu_notifier_event {
> +	MMU_NOTIFY_UNMAP = 0,
> +	MMU_NOTIFY_CLEAR,
> +	MMU_NOTIFY_PROTECTION_VMA,
> +	MMU_NOTIFY_PROTECTION_PAGE,
> +	MMU_NOTIFY_SOFT_DIRTY,
> +};
> +
>  struct mmu_notifier_range {
>  	struct mm_struct *mm;
>  	unsigned long start;
>  	unsigned long end;
> +	enum mmu_notifier_event event;
>  	bool blockable;
>  };
> 
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index aa7996ca361e..b6ef3be1c24e 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -174,6 +174,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  	struct mmu_notifier_range range;
>  	struct mem_cgroup *memcg;
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = addr;
>  	range.end = addr + PAGE_SIZE;
>  	range.mm = mm;
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 1a7a059dbf7d..4919be71ffd0 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1182,6 +1182,7 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
>  		cond_resched();
>  	}
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = haddr;
>  	range.end = range.start + HPAGE_PMD_SIZE;
>  	range.mm = vma->vm_mm;
> @@ -1347,6 +1348,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
>  				    vma, HPAGE_PMD_NR);
>  	__SetPageUptodate(new_page);
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = haddr;
>  	range.end = range.start + HPAGE_PMD_SIZE;
>  	range.mm = vma->vm_mm;
> @@ -2029,6 +2031,7 @@ void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
>  	struct mm_struct *mm = vma->vm_mm;
>  	struct mmu_notifier_range range;
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = address & HPAGE_PUD_MASK;
>  	range.end = range.start + HPAGE_PUD_SIZE;
>  	range.mm = mm;
> @@ -2248,6 +2251,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	struct mm_struct *mm = vma->vm_mm;
>  	struct mmu_notifier_range range;
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = address & HPAGE_PMD_MASK;
>  	range.end = range.start + HPAGE_PMD_SIZE;
>  	range.mm = mm;
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 4bfbdab44d51..9ffe34173834 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3244,6 +3244,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
> 
>  	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = vma->vm_start;
>  	range.end = vma->vm_end;
>  	range.mm = src;
> @@ -3344,6 +3345,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  	unsigned long sz = huge_page_size(h);
>  	struct mmu_notifier_range range;
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = start;
>  	range.end = end;
>  	range.mm = mm;
> @@ -3629,6 +3631,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  	__SetPageUptodate(new_page);
>  	set_page_huge_active(new_page);
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = haddr;
>  	range.end = range.start + huge_page_size(h);
>  	range.mm = mm;
> @@ -4346,6 +4349,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  	bool shared_pmd = false;
>  	struct mmu_notifier_range range;
> 
> +	range.event = MMU_NOTIFY_PROTECTION_VMA;
>  	range.start = start;
>  	range.end = end;
>  	range.mm = mm;
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index e9fe0c9a9f56..c5c78ba30b38 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1016,6 +1016,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	pte = pte_offset_map(pmd, address);
>  	pte_ptl = pte_lockptr(mm, pmd);
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = address;
>  	range.end = range.start + HPAGE_PMD_SIZE;
>  	range.mm = mm;
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 262694d0cd4c..f8fbb92ca1bd 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1050,6 +1050,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
> 
>  	BUG_ON(PageTransCompound(page));
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = pvmw.address;
>  	range.end = range.start + PAGE_SIZE;
>  	range.mm = mm;
> @@ -1139,6 +1140,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
>  	if (!pmd)
>  		goto out;
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = addr;
>  	range.end = addr + PAGE_SIZE;
>  	range.mm = mm;
> diff --git a/mm/madvise.c b/mm/madvise.c
> index f20dd80ca21b..c415985d6a04 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -466,6 +466,7 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
>  	if (!vma_is_anonymous(vma))
>  		return -EINVAL;
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = max(vma->vm_start, start_addr);
>  	if (range.start >= vma->vm_end)
>  		return -EINVAL;
> diff --git a/mm/memory.c b/mm/memory.c
> index 36e0b83949fc..4ad63002d770 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1007,6 +1007,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	 * is_cow_mapping() returns true.
>  	 */
>  	is_cow = is_cow_mapping(vma->vm_flags);
> +	range.event = MMU_NOTIFY_PROTECTION_PAGE;
>  	range.start = addr;
>  	range.end = end;
>  	range.mm = src_mm;
> @@ -1334,6 +1335,7 @@ void unmap_vmas(struct mmu_gather *tlb,
>  {
>  	struct mmu_notifier_range range;
> 
> +	range.event = MMU_NOTIFY_UNMAP;
>  	range.start = start_addr;
>  	range.end = end_addr;
>  	range.mm = vma->vm_mm;
> @@ -1358,6 +1360,7 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
>  	struct mmu_notifier_range range;
>  	struct mmu_gather tlb;
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = start;
>  	range.end = range.start + size;
>  	range.mm = vma->vm_mm;
> @@ -1387,6 +1390,7 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
>  	struct mmu_notifier_range range;
>  	struct mmu_gather tlb;
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = address;
>  	range.end = range.start + size;
>  	range.mm = vma->vm_mm;
> @@ -2260,6 +2264,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
>  	struct mem_cgroup *memcg;
>  	struct mmu_notifier_range range;
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = vmf->address & PAGE_MASK;
>  	range.end = range.start + PAGE_SIZE;
>  	range.mm = mm;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 4896dd9d8b28..a2caaabfc5a1 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2306,6 +2306,7 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
>  	struct mmu_notifier_range range;
>  	struct mm_walk mm_walk;
> 
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.start = migrate->start;
>  	range.end = migrate->end;
>  	range.mm = mm_walk.mm;
> @@ -2726,6 +2727,7 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
>  			if (!notified) {
>  				notified = true;
> 
> +				range.event = MMU_NOTIFY_CLEAR;
>  				range.start = addr;
>  				range.end = migrate->end;
>  				range.mm = mm;
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index f466adf31e12..6d41321b2f3e 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -186,6 +186,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
> 
>  		/* invoke the mmu notifier if the pmd is populated */
>  		if (!range.start) {
> +			range.event = MMU_NOTIFY_PROTECTION_VMA;
>  			range.start = addr;
>  			range.end = end;
>  			range.mm = mm;
> diff --git a/mm/mremap.c b/mm/mremap.c
> index db060acb4a8c..856a5e6bb226 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -203,6 +203,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  	old_end = old_addr + len;
>  	flush_cache_range(vma, old_addr, old_end);
> 
> +	range.event = MMU_NOTIFY_UNMAP;
>  	range.start = old_addr;
>  	range.end = old_end;
>  	range.mm = vma->vm_mm;
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index b29ab2624e95..f4bde1c34714 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -519,6 +519,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
>  			struct mmu_notifier_range range;
>  			struct mmu_gather tlb;
> 
> +			range.event = MMU_NOTIFY_CLEAR;
>  			range.start = vma->vm_start;
>  			range.end = vma->vm_end;
>  			range.mm = mm;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 09c5d9e5c766..b1afbbcc236a 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -896,6 +896,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  	 * We have to assume the worse case ie pmd for invalidation. Note that
>  	 * the page can not be free from this function.
>  	 */
> +	range.event = MMU_NOTIFY_PROTECTION_PAGE;
>  	range.mm = vma->vm_mm;
>  	range.start = address;
>  	range.end = min(vma->vm_end, range.start +
> @@ -1372,6 +1373,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	 * Note that the page can not be free in this function as call of
>  	 * try_to_unmap() must hold a reference on the page.
>  	 */
> +	range.event = MMU_NOTIFY_CLEAR;
>  	range.mm = vma->vm_mm;
>  	range.start = vma->vm_start;
>  	range.end = min(vma->vm_end, range.start +
> -- 
> 2.17.2
> 

-- 
Sincerely yours,
Mike.
