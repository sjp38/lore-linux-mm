Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A75FB6B02C3
	for <linux-mm@kvack.org>; Tue, 23 May 2017 02:42:25 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t26so56842062qtg.12
        for <linux-mm@kvack.org>; Mon, 22 May 2017 23:42:25 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id c187si19763956qkg.107.2017.05.22.23.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 23:42:24 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id y128so21856365qka.3
        for <linux-mm@kvack.org>; Mon, 22 May 2017 23:42:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87efvgqk08.fsf@skywalker.in.ibm.com>
References: <20170523040524.13717-1-oohall@gmail.com> <20170523040524.13717-4-oohall@gmail.com>
 <87efvgqk08.fsf@skywalker.in.ibm.com>
From: "Oliver O'Halloran" <oohall@gmail.com>
Date: Tue, 23 May 2017 16:42:23 +1000
Message-ID: <CAOSf1CEbTVXRq0GZKrAUwrXAdPuOUVDdyZfMAJyGUhH7AOkOOQ@mail.gmail.com>
Subject: Re: [PATCH 4/6] powerpc/mm: Add devmap support for ppc64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux MM <linux-mm@kvack.org>

On Tue, May 23, 2017 at 2:23 PM, Aneesh Kumar K.V
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> Oliver O'Halloran <oohall@gmail.com> writes:
>
>> Add support for the devmap bit on PTEs and PMDs for PPC64 Book3S.  This
>> is used to differentiate device backed memory from transparent huge
>> pages since they are handled in more or less the same manner by the core
>> mm code.
>>
>> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
>> ---
>> v1 -> v2: Properly differentiate THP and PMD Devmap entries. The
>> mm core assumes that pmd_trans_huge() and pmd_devmap() are mutually
>> exclusive and v1 had pmd_trans_huge() being true on a devmap pmd.
>>
>> Aneesh, this has been fleshed out substantially since v1. Can you
>> re-review it? Also no explicit gup support is required in this patch
>> since devmap support was added generic GUP as a part of making x86 use
>> the generic version.
>> ---
>>  arch/powerpc/include/asm/book3s/64/hash-64k.h |  2 +-
>>  arch/powerpc/include/asm/book3s/64/pgtable.h  | 37 ++++++++++++++++++++++++++-
>>  arch/powerpc/include/asm/book3s/64/radix.h    |  2 +-
>>  arch/powerpc/mm/hugetlbpage.c                 |  2 +-
>>  arch/powerpc/mm/pgtable-book3s64.c            |  4 +--
>>  arch/powerpc/mm/pgtable-hash64.c              |  4 ++-
>>  arch/powerpc/mm/pgtable-radix.c               |  3 ++-
>>  arch/powerpc/mm/pgtable_64.c                  |  2 +-
>>  8 files changed, 47 insertions(+), 9 deletions(-)
>>
>> diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
>> index 9732837aaae8..eaaf613c5347 100644
>> --- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
>> +++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
>> @@ -180,7 +180,7 @@ static inline void mark_hpte_slot_valid(unsigned char *hpte_slot_array,
>>   */
>>  static inline int hash__pmd_trans_huge(pmd_t pmd)
>>  {
>> -     return !!((pmd_val(pmd) & (_PAGE_PTE | H_PAGE_THP_HUGE)) ==
>> +     return !!((pmd_val(pmd) & (_PAGE_PTE | H_PAGE_THP_HUGE | _PAGE_DEVMAP)) ==
>>                 (_PAGE_PTE | H_PAGE_THP_HUGE));
>>  }
>
> _PAGE_DEVMAP is not really needed here. We will set H_PAGE_THP_HUGE only
> for thp hugepage w.r.t hash. But putting it here also makes it clear
> that devmap entries are not considered trans huge.

Good point. I'll remove it.

>>
>> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> index 85bc9875c3be..24634e92dd0b 100644
>> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
>> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> @@ -79,6 +79,9 @@
>>
>>  #define _PAGE_SOFT_DIRTY     _RPAGE_SW3 /* software: software dirty tracking */
>>  #define _PAGE_SPECIAL                _RPAGE_SW2 /* software: special page */
>> +#define _PAGE_DEVMAP         _RPAGE_SW1
>> +#define __HAVE_ARCH_PTE_DEVMAP
>> +
>>  /*
>>   * Drivers request for cache inhibited pte mapping using _PAGE_NO_CACHE
>>   * Instead of fixing all of them, add an alternate define which
>> @@ -599,6 +602,16 @@ static inline pte_t pte_mkhuge(pte_t pte)
>>       return pte;
>>  }
>>
>> +static inline pte_t pte_mkdevmap(pte_t pte)
>> +{
>> +     return __pte(pte_val(pte) | _PAGE_SPECIAL|_PAGE_DEVMAP);
>> +}
>> +
>> +static inline int pte_devmap(pte_t pte)
>> +{
>> +     return !!(pte_raw(pte) & cpu_to_be64(_PAGE_DEVMAP));
>> +}
>> +
>>  static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
>>  {
>>       /* FIXME!! check whether this need to be a conditional */
>> @@ -963,6 +976,9 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
>>  #define pmd_mk_savedwrite(pmd)       pte_pmd(pte_mk_savedwrite(pmd_pte(pmd)))
>>  #define pmd_clear_savedwrite(pmd)    pte_pmd(pte_clear_savedwrite(pmd_pte(pmd)))
>>
>> +#define pud_pfn(...) (0)
>> +#define pgd_pfn(...) (0)
>> +
>>  #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
>>  #define pmd_soft_dirty(pmd)    pte_soft_dirty(pmd_pte(pmd))
>>  #define pmd_mksoft_dirty(pmd)  pte_pmd(pte_mksoft_dirty(pmd_pte(pmd)))
>> @@ -1137,7 +1153,6 @@ static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
>>       return true;
>>  }
>>
>> -
>>  #define arch_needs_pgtable_deposit arch_needs_pgtable_deposit
>>  static inline bool arch_needs_pgtable_deposit(void)
>>  {
>> @@ -1146,6 +1161,26 @@ static inline bool arch_needs_pgtable_deposit(void)
>>       return true;
>>  }
>>
>> +static inline pmd_t pmd_mkdevmap(pmd_t pmd)
>> +{
>> +     return pte_pmd(pte_mkdevmap(pmd_pte(pmd)));
>> +}
>
>
> We avoided setting _PAGE_SPECIAL on pmd entries. This will set that, we
> may want to check if it is ok.  IIRC, we overloaded _PAGE_SPECIAL at some point to indicate thp splitting. But good to double check.

I took a cursory look in arch/powerpc/ and mm/ for usages and didn't
see any usages of _PAGE_SPECIAL for pmds. There's no good reason to
set the flag though so I'll remove it.

>> +
>> +static inline int pmd_devmap(pmd_t pmd)
>> +{
>> +     return pte_devmap(pmd_pte(pmd));
>> +}
>> +
>> +static inline int pud_devmap(pud_t pud)
>> +{
>> +     return 0;
>> +}
>> +
>> +static inline int pgd_devmap(pgd_t pgd)
>> +{
>> +     return 0;
>> +}
>> +
>>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>  #endif /* __ASSEMBLY__ */
>>  #endif /* _ASM_POWERPC_BOOK3S_64_PGTABLE_H_ */
>> diff --git a/arch/powerpc/include/asm/book3s/64/radix.h b/arch/powerpc/include/asm/book3s/64/radix.h
>> index ac16d1943022..ba43754e96d2 100644
>> --- a/arch/powerpc/include/asm/book3s/64/radix.h
>> +++ b/arch/powerpc/include/asm/book3s/64/radix.h
>> @@ -252,7 +252,7 @@ static inline int radix__pgd_bad(pgd_t pgd)
>>
>>  static inline int radix__pmd_trans_huge(pmd_t pmd)
>>  {
>> -     return !!(pmd_val(pmd) & _PAGE_PTE);
>> +     return (pmd_val(pmd) & (_PAGE_PTE | _PAGE_DEVMAP)) == _PAGE_PTE;
>>  }
>>
>>  static inline pmd_t radix__pmd_mkhuge(pmd_t pmd)
>> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
>> index a4f33de4008e..d9958af5c98e 100644
>> --- a/arch/powerpc/mm/hugetlbpage.c
>> +++ b/arch/powerpc/mm/hugetlbpage.c
>> @@ -963,7 +963,7 @@ pte_t *__find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
>>                       if (pmd_none(pmd))
>>                               return NULL;
>>
>> -                     if (pmd_trans_huge(pmd)) {
>> +                     if (pmd_trans_huge(pmd) || pmd_devmap(pmd)) {
>>                               if (is_thp)
>>                                       *is_thp = true;
>>                               ret_pte = (pte_t *) pmdp;
>
>
> Is that correct ? Do we want pmd_devmap to have is_thp set ?

I think so, is_thp is used to differentiate between explicit and
transparent hugepages in the hash fault handler. The management and
fault handling of pmd devmap pages and thp is the same (by design)
while hugepages seem to have their own requirements. Most users of
find_linux_pte_or_hugepte() don't look at is_thp either so it should
be safe.

>> diff --git a/arch/powerpc/mm/pgtable-book3s64.c b/arch/powerpc/mm/pgtable-book3s64.c
>> index 5fcb3dd74c13..31eed8fa8e99 100644
>> --- a/arch/powerpc/mm/pgtable-book3s64.c
>> +++ b/arch/powerpc/mm/pgtable-book3s64.c
>> @@ -32,7 +32,7 @@ int pmdp_set_access_flags(struct vm_area_struct *vma, unsigned long address,
>>  {
>>       int changed;
>>  #ifdef CONFIG_DEBUG_VM
>> -     WARN_ON(!pmd_trans_huge(*pmdp));
>> +     WARN_ON(!pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
>>       assert_spin_locked(&vma->vm_mm->page_table_lock);
>>  #endif
>>       changed = !pmd_same(*(pmdp), entry);
>> @@ -59,7 +59,7 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
>>  #ifdef CONFIG_DEBUG_VM
>>       WARN_ON(pte_present(pmd_pte(*pmdp)) && !pte_protnone(pmd_pte(*pmdp)));
>>       assert_spin_locked(&mm->page_table_lock);
>> -     WARN_ON(!pmd_trans_huge(pmd));
>> +     WARN_ON(!(pmd_trans_huge(pmd) || pmd_devmap(pmd)));
>>  #endif
>>       trace_hugepage_set_pmd(addr, pmd_val(pmd));
>>       return set_pte_at(mm, addr, pmdp_ptep(pmdp), pmd_pte(pmd));
>> diff --git a/arch/powerpc/mm/pgtable-hash64.c b/arch/powerpc/mm/pgtable-hash64.c
>> index 8b85a14b08ea..7456cde4dbce 100644
>> --- a/arch/powerpc/mm/pgtable-hash64.c
>> +++ b/arch/powerpc/mm/pgtable-hash64.c
>> @@ -109,7 +109,7 @@ unsigned long hash__pmd_hugepage_update(struct mm_struct *mm, unsigned long addr
>>       unsigned long old;
>>
>>  #ifdef CONFIG_DEBUG_VM
>> -     WARN_ON(!pmd_trans_huge(*pmdp));
>> +     WARN_ON(!hash__pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
>>       assert_spin_locked(&mm->page_table_lock);
>>  #endif
>>
>> @@ -141,6 +141,7 @@ pmd_t hash__pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long addres
>>
>>       VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>>       VM_BUG_ON(pmd_trans_huge(*pmdp));
>> +     VM_BUG_ON(pmd_devmap(*pmdp));
>>
>>       pmd = *pmdp;
>>       pmd_clear(pmdp);
>> @@ -221,6 +222,7 @@ void hash__pmdp_huge_split_prepare(struct vm_area_struct *vma,
>>  {
>>       VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>>       VM_BUG_ON(REGION_ID(address) != USER_REGION_ID);
>> +     VM_BUG_ON(pmd_devmap(*pmdp));
>>
>>       /*
>>        * We can't mark the pmd none here, because that will cause a race
>> diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
>> index c28165d8970b..69e28dda81f2 100644
>> --- a/arch/powerpc/mm/pgtable-radix.c
>> +++ b/arch/powerpc/mm/pgtable-radix.c
>> @@ -683,7 +683,7 @@ unsigned long radix__pmd_hugepage_update(struct mm_struct *mm, unsigned long add
>>       unsigned long old;
>>
>>  #ifdef CONFIG_DEBUG_VM
>> -     WARN_ON(!radix__pmd_trans_huge(*pmdp));
>> +     WARN_ON(!radix__pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
>>       assert_spin_locked(&mm->page_table_lock);
>>  #endif
>>
>> @@ -701,6 +701,7 @@ pmd_t radix__pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long addre
>>
>>       VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>>       VM_BUG_ON(radix__pmd_trans_huge(*pmdp));
>> +     VM_BUG_ON(pmd_devmap(*pmdp));
>>       /*
>>        * khugepaged calls this for normal pmd
>>        */
>> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
>> index db93cf747a03..aefde9bd3110 100644
>> --- a/arch/powerpc/mm/pgtable_64.c
>> +++ b/arch/powerpc/mm/pgtable_64.c
>> @@ -323,7 +323,7 @@ struct page *pud_page(pud_t pud)
>>   */
>>  struct page *pmd_page(pmd_t pmd)
>>  {
>> -     if (pmd_trans_huge(pmd) || pmd_huge(pmd))
>> +     if (pmd_trans_huge(pmd) || pmd_huge(pmd) || pmd_devmap(pmd))
>>               return pte_page(pmd_pte(pmd));
>>       return virt_to_page(pmd_page_vaddr(pmd));
>>  }
>> --
>> 2.9.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
