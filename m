Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 2742B6B004D
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 01:55:26 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3854319bkw.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 22:55:24 -0700 (PDT)
Message-ID: <4F7A90C9.7020602@openvz.org>
Date: Tue, 03 Apr 2012 09:55:21 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [x86 PAT PATCH 2/2] mm, x86, PAT: rework linear pfn-mmap tracking
References: <20120331170947.7773.46399.stgit@zurg> <1333413969-30761-1-git-send-email-suresh.b.siddha@intel.com> <1333413969-30761-3-git-send-email-suresh.b.siddha@intel.com> <4F7A8F2C.6040300@openvz.org>
In-Reply-To: <4F7A8F2C.6040300@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Pallipadi Venkatesh <venki@google.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Nick Piggin <npiggin@suse.de>

Konstantin Khlebnikov wrote:
> Suresh Siddha wrote:
>> From: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>
>> This patch replaces generic vma-flag VM_PFN_AT_MMAP with x86-only VM_PAT.
>>
>> We can toss mapping address from remap_pfn_range() into track_pfn_vma_new(),
>> and collect all PAT-related logic together in arch/x86/.
>>
>> This patch also restores orignal frustration-free is_cow_mapping() check in
>> remap_pfn_range(), as it was before commit v2.6.28-rc8-88-g3c8bb73
>> ("x86: PAT: store vm_pgoff for all linear_over_vma_region mappings - v3")
>>
>> is_linear_pfn_mapping() checks can be removed from mm/huge_memory.c,
>> because it already handled by VM_PFNMAP in VM_NO_THP bit-mask.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>> Signed-off-by: Suresh Siddha<suresh.b.siddha@intel.com>
>> Cc: Venkatesh Pallipadi<venki@google.com>
>> Cc: H. Peter Anvin<hpa@zytor.com>
>> Cc: Nick Piggin<npiggin@suse.de>
>> Cc: Ingo Molnar<mingo@redhat.com>
>> ---
>>    arch/x86/mm/pat.c             |   16 +++++++++++-----
>>    include/asm-generic/pgtable.h |    4 ++--
>>    include/linux/mm.h            |   15 +--------------
>>    mm/huge_memory.c              |    7 +++----
>>    mm/memory.c                   |   15 ++++++++-------
>>    5 files changed, 25 insertions(+), 32 deletions(-)
>>
>> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
>> index 617f42b..cde7e19 100644
>> --- a/arch/x86/mm/pat.c
>> +++ b/arch/x86/mm/pat.c
>> @@ -665,7 +665,7 @@ int track_pfn_vma_copy(struct vm_area_struct *vma)
>>        unsigned long vma_size = vma->vm_end - vma->vm_start;
>>        pgprot_t pgprot;
>>
>> -     if (is_linear_pfn_mapping(vma)) {
>> +     if (vma->vm_flags&   VM_PAT) {
>>                /*
>>                 * reserve the whole chunk covered by vma. We need the
>>                 * starting address and protection from pte.
>> @@ -690,13 +690,19 @@ int track_pfn_vma_copy(struct vm_area_struct *vma)
>>     * single reserve_pfn_range call.
>>     */
>>    int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
>> -                     unsigned long pfn, unsigned long size)
>> +                   unsigned long addr, unsigned long pfn, unsigned long size)
>>    {
>>        unsigned long flags;
>>
>>        /* reserve the whole chunk starting from pfn */
>> -     if (is_linear_pfn_mapping(vma))
>> -             return reserve_pfn_range(pfn, size, prot, 0);
>> +     if (addr == vma->vm_start&&   size == (vma->vm_end - vma->vm_start)) {
>> +             int ret;
>> +
>> +             ret = reserve_pfn_range(pfn, size, prot, 0);
>> +             if (!ret)
>> +                     vma->vm_flags |= VM_PAT;
>> +             return ret;
>> +     }
>>
>>        if (!pat_enabled)
>>                return 0;
>> @@ -720,7 +726,7 @@ void untrack_pfn_vma(struct vm_area_struct *vma, unsigned long pfn,
>>        resource_size_t paddr;
>>        unsigned long prot;
>>
>> -     if (!is_linear_pfn_mapping(vma))
>> +     if (!(vma->vm_flags&   VM_PAT))
>>                return;
>>
>>        /* free the chunk starting from pfn or the whole chunk */
>> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
>> index 125c54e..688a2a5 100644
>> --- a/include/asm-generic/pgtable.h
>> +++ b/include/asm-generic/pgtable.h
>> @@ -389,7 +389,7 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
>>     * for physical range indicated by pfn and size.
>>     */
>>    static inline int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
>> -                                     unsigned long pfn, unsigned long size)
>> +             unsigned long pfn, unsigned long addr, unsigned long size)
>>    {
>>        return 0;
>>    }
>> @@ -420,7 +420,7 @@ static inline void untrack_pfn_vma(struct vm_area_struct *vma,
>>    }
>>    #else
>>    extern int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
>> -                             unsigned long pfn, unsigned long size);
>> +             unsigned long pfn, unsigned long addr, unsigned long size);
>>    extern int track_pfn_vma_copy(struct vm_area_struct *vma);
>>    extern void untrack_pfn_vma(struct vm_area_struct *vma, unsigned long pfn,
>>                                unsigned long size);
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index d8738a4..b8e5fe5 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -117,7 +117,7 @@ extern unsigned int kobjsize(const void *objp);
>>    #define VM_CAN_NONLINEAR 0x08000000 /* Has ->fault&   does nonlinear pages */
>>    #define VM_MIXEDMAP 0x10000000      /* Can contain "struct page" and pure PFN pages */
>>    #define VM_SAO              0x20000000      /* Strong Access Ordering (powerpc) */
>> -#define VM_PFN_AT_MMAP       0x40000000      /* PFNMAP vma that is fully mapped at mmap time */
>> +#define VM_PAT               0x40000000      /* PAT reserves whole VMA at once (x86) */
>>    #define VM_MERGEABLE        0x80000000      /* KSM may merge identical pages */
>>
>>    /* Bits set in the VMA until the stack is in its final location */
>> @@ -158,19 +158,6 @@ extern pgprot_t protection_map[16];
>>    #define FAULT_FLAG_RETRY_NOWAIT     0x10    /* Don't drop mmap_sem and wait when retrying */
>>    #define FAULT_FLAG_KILLABLE 0x20    /* The fault task is in SIGKILL killable region */
>>
>> -/*
>> - * This interface is used by x86 PAT code to identify a pfn mapping that is
>> - * linear over entire vma. This is to optimize PAT code that deals with
>> - * marking the physical region with a particular prot. This is not for generic
>> - * mm use. Note also that this check will not work if the pfn mapping is
>> - * linear for a vma starting at physical address 0. In which case PAT code
>> - * falls back to slow path of reserving physical range page by page.
>> - */
>> -static inline int is_linear_pfn_mapping(struct vm_area_struct *vma)
>> -{
>> -     return !!(vma->vm_flags&   VM_PFN_AT_MMAP);
>> -}
>> -
>>    static inline int is_pfn_mapping(struct vm_area_struct *vma)
>>    {
>>        return !!(vma->vm_flags&   VM_PFNMAP);
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index f0e5306..cf827da 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1650,7 +1650,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
>>         * If is_pfn_mapping() is true is_learn_pfn_mapping() must be
>>         * true too, verify it here.
>>         */
>> -     VM_BUG_ON(is_linear_pfn_mapping(vma) || vma->vm_flags&   VM_NO_THP);
>> +     VM_BUG_ON(vma->vm_flags&   VM_NO_THP);
>>        hstart = (vma->vm_start + ~HPAGE_PMD_MASK)&   HPAGE_PMD_MASK;
>>        hend = vma->vm_end&   HPAGE_PMD_MASK;
>>        if (hstart<   hend)
>> @@ -1908,7 +1908,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>>         * If is_pfn_mapping() is true is_learn_pfn_mapping() must be
>>         * true too, verify it here.
>>         */
>> -     VM_BUG_ON(is_linear_pfn_mapping(vma) || vma->vm_flags&   VM_NO_THP);
>> +     VM_BUG_ON(vma->vm_flags&   VM_NO_THP);
>>
>>        pgd = pgd_offset(mm, address);
>>        if (!pgd_present(*pgd))
>> @@ -2150,8 +2150,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
>>                 * If is_pfn_mapping() is true is_learn_pfn_mapping()
>>                 * must be true too, verify it here.
>>                 */
>> -             VM_BUG_ON(is_linear_pfn_mapping(vma) ||
>> -                       vma->vm_flags&   VM_NO_THP);
>> +             VM_BUG_ON(vma->vm_flags&   VM_NO_THP);
>>
>>                hstart = (vma->vm_start + ~HPAGE_PMD_MASK)&   HPAGE_PMD_MASK;
>>                hend = vma->vm_end&   HPAGE_PMD_MASK;
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 6105f47..e6e4dfd 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2145,7 +2145,7 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>>
>>        if (addr<   vma->vm_start || addr>= vma->vm_end)
>>                return -EFAULT;
>> -     if (track_pfn_vma_new(vma,&pgprot, pfn, PAGE_SIZE))
>> +     if (track_pfn_vma_new(vma,&pgprot, pfn, addr, PAGE_SIZE))
>>                return -EINVAL;
>
> Old code does not uses PAT for vm_insert_pfn, now it can use it for single-page vma.
> And I see glitches on my notebook if kernel do this (see comment in v2 of my patch)
>
> Probably we shouldn't touch this, plus seems like using pat-engine for single page isn't optimal:
> it allocates special control structures for this.

Ignore this, I didn't see comment in 0/2 mail

>
>>
>>        ret = insert_pfn(vma, addr, pfn, pgprot);
>> @@ -2285,23 +2285,24 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
>>         * There's a horrible special case to handle copy-on-write
>>         * behaviour that some programs depend on. We mark the "original"
>>         * un-COW'ed pages by matching them up with "vma->vm_pgoff".
>> +      * See vm_normal_page() for details.
>>         */
>> -     if (addr == vma->vm_start&&   end == vma->vm_end) {
>> +
>> +     if (is_cow_mapping(vma->vm_flags)) {
>> +             if (addr != vma->vm_start || end != vma->vm_end)
>> +                     return -EINVAL;
>>                vma->vm_pgoff = pfn;
>> -             vma->vm_flags |= VM_PFN_AT_MMAP;
>> -     } else if (is_cow_mapping(vma->vm_flags))
>> -             return -EINVAL;
>> +     }
>>
>>        vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
>>
>> -     err = track_pfn_vma_new(vma,&prot, pfn, PAGE_ALIGN(size));
>> +     err = track_pfn_vma_new(vma,&prot, pfn, addr, PAGE_ALIGN(size));
>>        if (err) {
>>                /*
>>                 * To indicate that track_pfn related cleanup is not
>>                 * needed from higher level routine calling unmap_vmas
>>                 */
>>                vma->vm_flags&= ~(VM_IO | VM_RESERVED | VM_PFNMAP);
>> -             vma->vm_flags&= ~VM_PFN_AT_MMAP;
>>                return -EINVAL;
>>        }
>>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
