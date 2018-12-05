Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B60896B727C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 23:42:46 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id w12so14492054wru.20
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 20:42:46 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id f23si9414193wml.194.2018.12.04.20.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 20:42:45 -0800 (PST)
Subject: Re: [PATCH V3 2/5] mm: update ptep_modify_prot_commit to take old pte
 value as arg
References: <20181205030931.12037-1-aneesh.kumar@linux.ibm.com>
 <20181205030931.12037-3-aneesh.kumar@linux.ibm.com>
 <f446afd3-a77d-cc5a-1ac8-3992090bcd7d@c-s.fr>
 <48f13462-1695-a759-9df8-1ef60fd88196@linux.ibm.com>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <3c1395e0-8a06-e407-80ba-2d634a9e01e9@c-s.fr>
Date: Wed, 5 Dec 2018 05:42:43 +0100
MIME-Version: 1.0
In-Reply-To: <48f13462-1695-a759-9df8-1ef60fd88196@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org



Le 05/12/2018 à 05:06, Aneesh Kumar K.V a écrit :
> On 12/5/18 9:32 AM, Christophe LEROY wrote:
>>
>>
>> Le 05/12/2018 à 04:09, Aneesh Kumar K.V a écrit :
>>> Architectures like ppc64 requires to do a conditional tlb flush based 
>>> on the old
>>> and new value of pte. Enable that by passing old pte value as the arg.
>>>
>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>>> ---
>>>   arch/s390/include/asm/pgtable.h | 3 ++-
>>>   arch/s390/mm/pgtable.c          | 2 +-
>>>   arch/x86/include/asm/paravirt.h | 2 +-
>>>   fs/proc/task_mmu.c              | 8 +++++---
>>>   include/asm-generic/pgtable.h   | 2 +-
>>>   mm/memory.c                     | 8 ++++----
>>>   mm/mprotect.c                   | 6 +++---
>>>   7 files changed, 17 insertions(+), 14 deletions(-)
>>>
>>> diff --git a/arch/s390/include/asm/pgtable.h 
>>> b/arch/s390/include/asm/pgtable.h
>>> index 5d730199e37b..76dc344edb8c 100644
>>> --- a/arch/s390/include/asm/pgtable.h
>>> +++ b/arch/s390/include/asm/pgtable.h
>>> @@ -1070,7 +1070,8 @@ static inline pte_t ptep_get_and_clear(struct 
>>> mm_struct *mm,
>>>   #define __HAVE_ARCH_PTEP_MODIFY_PROT_TRANSACTION
>>>   pte_t ptep_modify_prot_start(struct vm_area_struct *, unsigned 
>>> long, pte_t *);
>>> -void ptep_modify_prot_commit(struct vm_area_struct *, unsigned long, 
>>> pte_t *, pte_t);
>>> +void ptep_modify_prot_commit(struct vm_area_struct *, unsigned long,
>>> +                 pte_t *, pte_t, pte_t);
>>>   #define __HAVE_ARCH_PTEP_CLEAR_FLUSH
>>>   static inline pte_t ptep_clear_flush(struct vm_area_struct *vma,
>>> diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
>>> index 29c0a21cd34a..b283b92722cc 100644
>>> --- a/arch/s390/mm/pgtable.c
>>> +++ b/arch/s390/mm/pgtable.c
>>> @@ -322,7 +322,7 @@ pte_t ptep_modify_prot_start(struct 
>>> vm_area_struct *vma, unsigned long addr,
>>>   EXPORT_SYMBOL(ptep_modify_prot_start);
>>>   void ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned 
>>> long addr,
>>> -                 pte_t *ptep, pte_t pte)
>>> +                 pte_t *ptep, pte_t old_pte, pte_t pte)
>>>   {
>>>       pgste_t pgste;
>>>       struct mm_struct *mm = vma->vm_mm;
>>> diff --git a/arch/x86/include/asm/paravirt.h 
>>> b/arch/x86/include/asm/paravirt.h
>>> index 1154f154025d..0d75a4f60500 100644
>>> --- a/arch/x86/include/asm/paravirt.h
>>> +++ b/arch/x86/include/asm/paravirt.h
>>> @@ -429,7 +429,7 @@ static inline pte_t ptep_modify_prot_start(struct 
>>> vm_area_struct *vma, unsigned
>>>   }
>>>   static inline void ptep_modify_prot_commit(struct vm_area_struct 
>>> *vma, unsigned long addr,
>>> -                       pte_t *ptep, pte_t pte)
>>> +                       pte_t *ptep, pte_t old_pte, pte_t pte)
>>>   {
>>>       struct mm_struct *mm = vma->vm_mm;
>>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>>> index 9952d7185170..8d62891d38a8 100644
>>> --- a/fs/proc/task_mmu.c
>>> +++ b/fs/proc/task_mmu.c
>>> @@ -940,10 +940,12 @@ static inline void clear_soft_dirty(struct 
>>> vm_area_struct *vma,
>>>       pte_t ptent = *pte;
>>>       if (pte_present(ptent)) {
>>> -        ptent = ptep_modify_prot_start(vma, addr, pte);
>>> -        ptent = pte_wrprotect(ptent);
>>> +        pte_t old_pte;
>>> +
>>> +        old_pte = ptep_modify_prot_start(vma, addr, pte);
>>> +        ptent = pte_wrprotect(old_pte);
>>
>> This change doesn't seem to fit with the commit description. Why write 
>> protecting in addition to clearing dirty ?
>>
>>
> 
> The hunk above use a new variable old_pte. There is no functional change 
> in that hunk.
> 

Oops, sorry, I misread the patch, don't know why.

Christophe
