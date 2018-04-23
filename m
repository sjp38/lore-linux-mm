Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF14B6B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 02:43:11 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so9761032pfz.19
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 23:43:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v10-v6sor4131913plz.81.2018.04.22.23.43.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 23:43:10 -0700 (PDT)
Date: Mon, 23 Apr 2018 15:42:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v10 08/25] mm: VMA sequence count
Message-ID: <20180423064259.GC114098@rodete-desktop-imager.corp.google.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-9-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1523975611-15978-9-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, Apr 17, 2018 at 04:33:14PM +0200, Laurent Dufour wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> Wrap the VMA modifications (vma_adjust/unmap_page_range) with sequence
> counts such that we can easily test if a VMA is changed.

So, seqcount is to protect modifying all attributes of vma?

> 
> The unmap_page_range() one allows us to make assumptions about
> page-tables; when we find the seqcount hasn't changed we can assume
> page-tables are still valid.

Hmm, seqcount covers page-table, too.
Please describe what the seqcount want to protect.

> 
> The flip side is that we cannot distinguish between a vma_adjust() and
> the unmap_page_range() -- where with the former we could have
> re-checked the vma bounds against the address.
> 
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> 
> [Port to 4.12 kernel]
> [Build depends on CONFIG_SPECULATIVE_PAGE_FAULT]
> [Introduce vm_write_* inline function depending on
>  CONFIG_SPECULATIVE_PAGE_FAULT]
> [Fix lock dependency between mapping->i_mmap_rwsem and vma->vm_sequence by
>  using vm_raw_write* functions]
> [Fix a lock dependency warning in mmap_region() when entering the error
>  path]
> [move sequence initialisation INIT_VMA()]
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  include/linux/mm.h       | 44 ++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/mm_types.h |  3 +++
>  mm/memory.c              |  2 ++
>  mm/mmap.c                | 31 +++++++++++++++++++++++++++++++
>  4 files changed, 80 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index efc1248b82bd..988daf7030c9 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1264,6 +1264,9 @@ struct zap_details {
>  static inline void INIT_VMA(struct vm_area_struct *vma)
>  {
>  	INIT_LIST_HEAD(&vma->anon_vma_chain);
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	seqcount_init(&vma->vm_sequence);
> +#endif
>  }
>  
>  struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> @@ -1386,6 +1389,47 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
>  	unmap_mapping_range(mapping, holebegin, holelen, 0);
>  }
>  
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +static inline void vm_write_begin(struct vm_area_struct *vma)
> +{
> +	write_seqcount_begin(&vma->vm_sequence);
> +}
> +static inline void vm_write_begin_nested(struct vm_area_struct *vma,
> +					 int subclass)
> +{
> +	write_seqcount_begin_nested(&vma->vm_sequence, subclass);
> +}
> +static inline void vm_write_end(struct vm_area_struct *vma)
> +{
> +	write_seqcount_end(&vma->vm_sequence);
> +}
> +static inline void vm_raw_write_begin(struct vm_area_struct *vma)
> +{
> +	raw_write_seqcount_begin(&vma->vm_sequence);
> +}
> +static inline void vm_raw_write_end(struct vm_area_struct *vma)
> +{
> +	raw_write_seqcount_end(&vma->vm_sequence);
> +}
> +#else
> +static inline void vm_write_begin(struct vm_area_struct *vma)
> +{
> +}
> +static inline void vm_write_begin_nested(struct vm_area_struct *vma,
> +					 int subclass)
> +{
> +}
> +static inline void vm_write_end(struct vm_area_struct *vma)
> +{
> +}
> +static inline void vm_raw_write_begin(struct vm_area_struct *vma)
> +{
> +}
> +static inline void vm_raw_write_end(struct vm_area_struct *vma)
> +{
> +}
> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
> +
>  extern int access_process_vm(struct task_struct *tsk, unsigned long addr,
>  		void *buf, int len, unsigned int gup_flags);
>  extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 21612347d311..db5e9d630e7a 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -335,6 +335,9 @@ struct vm_area_struct {
>  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>  #endif
>  	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	seqcount_t vm_sequence;
> +#endif
>  } __randomize_layout;
>  
>  struct core_thread {
> diff --git a/mm/memory.c b/mm/memory.c
> index f86efcb8e268..f7fed053df80 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1503,6 +1503,7 @@ void unmap_page_range(struct mmu_gather *tlb,
>  	unsigned long next;
>  
>  	BUG_ON(addr >= end);

The comment about saying it aims for page-table stability will help.

> +	vm_write_begin(vma);
>  	tlb_start_vma(tlb, vma);
>  	pgd = pgd_offset(vma->vm_mm, addr);
>  	do {
> @@ -1512,6 +1513,7 @@ void unmap_page_range(struct mmu_gather *tlb,
>  		next = zap_p4d_range(tlb, vma, pgd, addr, next, details);
>  	} while (pgd++, addr = next, addr != end);
>  	tlb_end_vma(tlb, vma);
> +	vm_write_end(vma);
>  }
>  
>  
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 8bd9ae1dfacc..813e49589ea1 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -692,6 +692,30 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  	long adjust_next = 0;
>  	int remove_next = 0;
>  
> +	/*
> +	 * Why using vm_raw_write*() functions here to avoid lockdep's warning ?
> +	 *
> +	 * Locked is complaining about a theoretical lock dependency, involving
> +	 * 3 locks:
> +	 *   mapping->i_mmap_rwsem --> vma->vm_sequence --> fs_reclaim
> +	 *
> +	 * Here are the major path leading to this dependency :
> +	 *  1. __vma_adjust() mmap_sem  -> vm_sequence -> i_mmap_rwsem
> +	 *  2. move_vmap() mmap_sem -> vm_sequence -> fs_reclaim
> +	 *  3. __alloc_pages_nodemask() fs_reclaim -> i_mmap_rwsem
> +	 *  4. unmap_mapping_range() i_mmap_rwsem -> vm_sequence
> +	 *
> +	 * So there is no way to solve this easily, especially because in
> +	 * unmap_mapping_range() the i_mmap_rwsem is grab while the impacted
> +	 * VMAs are not yet known.
> +	 * However, the way the vm_seq is used is guarantying that we will
> +	 * never block on it since we just check for its value and never wait
> +	 * for it to move, see vma_has_changed() and handle_speculative_fault().
> +	 */
> +	vm_raw_write_begin(vma);
> +	if (next)
> +		vm_raw_write_begin(next);
> +
>  	if (next && !insert) {
>  		struct vm_area_struct *exporter = NULL, *importer = NULL;
>  
> @@ -902,6 +926,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  			anon_vma_merge(vma, next);
>  		mm->map_count--;
>  		mpol_put(vma_policy(next));
> +		vm_raw_write_end(next);
>  		kmem_cache_free(vm_area_cachep, next);
>  		/*
>  		 * In mprotect's case 6 (see comments on vma_merge),
> @@ -916,6 +941,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  			 * "vma->vm_next" gap must be updated.
>  			 */
>  			next = vma->vm_next;
> +			if (next)
> +				vm_raw_write_begin(next);
>  		} else {
>  			/*
>  			 * For the scope of the comment "next" and
> @@ -962,6 +989,10 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  	if (insert && file)
>  		uprobe_mmap(insert);
>  
> +	if (next && next != vma)
> +		vm_raw_write_end(next);
> +	vm_raw_write_end(vma);
> +
>  	validate_mm(mm);
>  
>  	return 0;
> -- 
> 2.7.4
> 
