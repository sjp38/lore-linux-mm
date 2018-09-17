Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB5A28E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 05:48:01 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id k96-v6so22851005wrc.3
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 02:48:01 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id t66-v6si6235321wmf.31.2018.09.17.02.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 02:48:00 -0700 (PDT)
Subject: Re: How to handle PTE tables with non contiguous entries ?
References: <ddc3bb56-4da0-c093-256f-185d4a612b5c@c-s.fr>
 <87tvmoh4w9.fsf@linux.ibm.com>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <d1be61a4-8dc7-cfe0-e4e7-82ce5f57ced3@c-s.fr>
Date: Mon, 17 Sep 2018 11:47:53 +0200
MIME-Version: 1.0
In-Reply-To: <87tvmoh4w9.fsf@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com, Nicholas Piggin <npiggin@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org
Cc: LKML <linux-kernel@vger.kernel.org>



Le 17/09/2018 A  11:03, Aneesh Kumar K.V a A(C)critA :
> Christophe Leroy <christophe.leroy@c-s.fr> writes:
> 
>> Hi,
>>
>> I'm having a hard time figuring out the best way to handle the following
>> situation:
>>
>> On the powerpc8xx, handling 16k size pages requires to have page tables
>> with 4 identical entries.
> 
> I assume that hugetlb page size? If so isn't that similar to FSL hugetlb
> page table layout?

No, it is not for 16k hugepage size with a standard page size of 4k.

Here I'm trying to handle the case of CONFIG_PPC_16K_PAGES.
As of today, it is implemented by using the standard Linux page layout, 
ie one PTE entry for each 16k page. This forbids the use the 8xx HW 
assistance.

> 
>>
>> Initially I was thinking about handling this by simply modifying
>> pte_index() which changing pte_t type in order to have one entry every
>> 16 bytes, then replicate the PTE value at *ptep, *ptep+1,*ptep+2 and
>> *ptep+3 both in set_pte_at() and pte_update().
>>
>> However, this doesn't work because many many places in the mm core part
>> of the kernel use loops on ptep with single ptep++ increment.
>>
>> Therefore did it with the following hack:
>>
>>    /* PTE level */
>> +#if defined(CONFIG_PPC_8xx) && defined(CONFIG_PPC_16K_PAGES)
>> +typedef struct { pte_basic_t pte, pte1, pte2, pte3; } pte_t;
>> +#else
>>    typedef struct { pte_basic_t pte; } pte_t;
>> +#endif
>>
>> @@ -181,7 +192,13 @@ static inline unsigned long pte_update(pte_t *p,
>>           : "cc" );
>>    #else /* PTE_ATOMIC_UPDATES */
>>           unsigned long old = pte_val(*p);
>> -       *p = __pte((old & ~clr) | set);
>> +       unsigned long new = (old & ~clr) | set;
>> +
>> +#if defined(CONFIG_PPC_8xx) && defined(CONFIG_PPC_16K_PAGES)
>> +       p->pte = p->pte1 = p->pte2 = p->pte3 = new;
>> +#else
>> +       *p = __pte(new);
>> +#endif
>>    #endif /* !PTE_ATOMIC_UPDATES */
>>
>>    #ifdef CONFIG_44x
>>
>>
>> @@ -161,7 +161,11 @@ static inline void __set_pte_at(struct mm_struct
>> *mm, unsigned long addr,
>>           /* Anything else just stores the PTE normally. That covers all
>> 64-bit
>>            * cases, and 32-bit non-hash with 32-bit PTEs.
>>            */
>> +#if defined(CONFIG_PPC_8xx) && defined(CONFIG_PPC_16K_PAGES)
>> +       ptep->pte = ptep->pte1 = ptep->pte2 = ptep->pte3 = pte_val(pte);
>> +#else
>>           *ptep = pte;
>> +#endif
>>
>>
>>
>> But I'm not too happy with it as it means pte_t is not a single type
>> anymore so passing it from one function to the other is quite heavy.
>>
>>
>> Would someone have an idea of an elegent way to handle that ?
>>
>> Thanks
>> Christophe
> 
> Why would pte_update bother about updating all the 4 entries?. Can you
> help me understand the issue?

Because the 8xx HW assistance expects 4 identical entries for each 16k 
page, so everytime a PTE is updated the 4 entries have to be updated.

Christophe
