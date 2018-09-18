Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD8E28E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 07:47:26 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q130-v6so1383498oic.22
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 04:47:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 59-v6si5288407otr.231.2018.09.18.04.47.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 04:47:25 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8IBiVJ5121738
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 07:47:25 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mjxe95ujj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 07:47:24 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 18 Sep 2018 12:47:22 +0100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: How to handle PTE tables with non contiguous entries ?
In-Reply-To: <d1be61a4-8dc7-cfe0-e4e7-82ce5f57ced3@c-s.fr>
References: <ddc3bb56-4da0-c093-256f-185d4a612b5c@c-s.fr> <87tvmoh4w9.fsf@linux.ibm.com> <d1be61a4-8dc7-cfe0-e4e7-82ce5f57ced3@c-s.fr>
Date: Tue, 18 Sep 2018 17:17:16 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Message-Id: <87pnxbgh8b.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe LEROY <christophe.leroy@c-s.fr>, akpm@linux-foundation.org, linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com, Nicholas Piggin <npiggin@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org
Cc: LKML <linux-kernel@vger.kernel.org>

Christophe LEROY <christophe.leroy@c-s.fr> writes:

> Le 17/09/2018 =C3=A0 11:03, Aneesh Kumar K.V a =C3=A9crit=C2=A0:
>> Christophe Leroy <christophe.leroy@c-s.fr> writes:
>>=20
>>> Hi,
>>>
>>> I'm having a hard time figuring out the best way to handle the following
>>> situation:
>>>
>>> On the powerpc8xx, handling 16k size pages requires to have page tables
>>> with 4 identical entries.
>>=20
>> I assume that hugetlb page size? If so isn't that similar to FSL hugetlb
>> page table layout?
>
> No, it is not for 16k hugepage size with a standard page size of 4k.
>
> Here I'm trying to handle the case of CONFIG_PPC_16K_PAGES.
> As of today, it is implemented by using the standard Linux page layout,=20
> ie one PTE entry for each 16k page. This forbids the use the 8xx HW=20
> assistance.
>
>>=20
>>>
>>> Initially I was thinking about handling this by simply modifying
>>> pte_index() which changing pte_t type in order to have one entry every
>>> 16 bytes, then replicate the PTE value at *ptep, *ptep+1,*ptep+2 and
>>> *ptep+3 both in set_pte_at() and pte_update().
>>>
>>> However, this doesn't work because many many places in the mm core part
>>> of the kernel use loops on ptep with single ptep++ increment.
>>>
>>> Therefore did it with the following hack:
>>>
>>>    /* PTE level */
>>> +#if defined(CONFIG_PPC_8xx) && defined(CONFIG_PPC_16K_PAGES)
>>> +typedef struct { pte_basic_t pte, pte1, pte2, pte3; } pte_t;
>>> +#else
>>>    typedef struct { pte_basic_t pte; } pte_t;
>>> +#endif
>>>
>>> @@ -181,7 +192,13 @@ static inline unsigned long pte_update(pte_t *p,
>>>           : "cc" );
>>>    #else /* PTE_ATOMIC_UPDATES */
>>>           unsigned long old =3D pte_val(*p);
>>> -       *p =3D __pte((old & ~clr) | set);
>>> +       unsigned long new =3D (old & ~clr) | set;
>>> +
>>> +#if defined(CONFIG_PPC_8xx) && defined(CONFIG_PPC_16K_PAGES)
>>> +       p->pte =3D p->pte1 =3D p->pte2 =3D p->pte3 =3D new;
>>> +#else
>>> +       *p =3D __pte(new);
>>> +#endif
>>>    #endif /* !PTE_ATOMIC_UPDATES */
>>>
>>>    #ifdef CONFIG_44x
>>>
>>>
>>> @@ -161,7 +161,11 @@ static inline void __set_pte_at(struct mm_struct
>>> *mm, unsigned long addr,
>>>           /* Anything else just stores the PTE normally. That covers all
>>> 64-bit
>>>            * cases, and 32-bit non-hash with 32-bit PTEs.
>>>            */
>>> +#if defined(CONFIG_PPC_8xx) && defined(CONFIG_PPC_16K_PAGES)
>>> +       ptep->pte =3D ptep->pte1 =3D ptep->pte2 =3D ptep->pte3 =3D pte_=
val(pte);
>>> +#else
>>>           *ptep =3D pte;
>>> +#endif
>>>
>>>
>>>
>>> But I'm not too happy with it as it means pte_t is not a single type
>>> anymore so passing it from one function to the other is quite heavy.
>>>
>>>
>>> Would someone have an idea of an elegent way to handle that ?
>>>
>>> Thanks
>>> Christophe
>>=20
>> Why would pte_update bother about updating all the 4 entries?. Can you
>> help me understand the issue?
>
> Because the 8xx HW assistance expects 4 identical entries for each 16k=20
> page, so everytime a PTE is updated the 4 entries have to be updated.
>

What you suggested in the original mail is what matches that best isn't it?
That is a linux pte update involves updating 4 slot. Hence a linux pte
consist of 4 unsigned long?

-aneesh
