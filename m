Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id A458E6B0005
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 23:37:20 -0500 (EST)
Received: by mail-qk0-f181.google.com with SMTP id s68so51797923qkh.3
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 20:37:20 -0800 (PST)
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com. [129.33.205.208])
        by mx.google.com with ESMTPS id e66si32265720qgf.125.2016.02.14.20.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 14 Feb 2016 20:37:19 -0800 (PST)
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 14 Feb 2016 23:37:19 -0500
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B1A88C90043
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 23:37:13 -0500 (EST)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1F4bGRd26542230
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 04:37:16 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1F4XlJC009951
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 23:33:48 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V3] powerpc/mm: Fix Multi hit ERAT cause by recent THP update
In-Reply-To: <1455504278.16012.18.camel@gmail.com>
References: <1454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1455504278.16012.18.camel@gmail.com>
Date: Mon, 15 Feb 2016 10:07:08 +0530
Message-ID: <87lh6mfv2j.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Balbir Singh <bsingharora@gmail.com> writes:

> On Tue, 2016-02-09 at 06:50 +0530, Aneesh Kumar K.V wrote:
>>=C2=A0
>> Also make sure we wait for irq disable section in other cpus to finish
>> before flipping a huge pte entry with a regular pmd entry. Code paths
>> like find_linux_pte_or_hugepte depend on irq disable to get
>> a stable pte_t pointer. A parallel thp split need to make sure we
>> don't convert a pmd pte to a regular pmd entry without waiting for the
>> irq disable section to finish.
>>=20
>> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>> =C2=A0arch/powerpc/include/asm/book3s/64/pgtable.h |=C2=A0=C2=A04 ++++
>> =C2=A0arch/powerpc/mm/pgtable_64.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 35
>> +++++++++++++++++++++++++++-
>> =C2=A0include/asm-generic/pgtable.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A08 =
+++++++
>> =C2=A0mm/huge_memory.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A01 +
>> =C2=A04 files changed, 47 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h
>> b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> index 8d1c41d28318..ac07a30a7934 100644
>> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
>> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> @@ -281,6 +281,10 @@ extern pgtable_t pgtable_trans_huge_withdraw(struct
>> mm_struct *mm, pmd_t *pmdp);
>> =C2=A0extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned l=
ong
>> address,
>> =C2=A0			=C2=A0=C2=A0=C2=A0=C2=A0pmd_t *pmdp);
>> =C2=A0
>> +#define __HAVE_ARCH_PMDP_HUGE_SPLIT_PREPARE
>> +extern void pmdp_huge_split_prepare(struct vm_area_struct *vma,
>> +				=C2=A0=C2=A0=C2=A0=C2=A0unsigned long address, pmd_t *pmdp);
>> +
>> =C2=A0#define pmd_move_must_withdraw pmd_move_must_withdraw
>> =C2=A0struct spinlock;
>> =C2=A0static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_=
ptl,
>> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
>> index 3124a20d0fab..c8a00da39969 100644
>> --- a/arch/powerpc/mm/pgtable_64.c
>> +++ b/arch/powerpc/mm/pgtable_64.c
>> @@ -646,6 +646,30 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_str=
uct
>> *mm, pmd_t *pmdp)
>> =C2=A0	return pgtable;
>> =C2=A0}
>> =C2=A0
>> +void pmdp_huge_split_prepare(struct vm_area_struct *vma,
>> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0unsigned long address, pmd_t *pmdp)
>> +{
>> +	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>> +
>> +#ifdef CONFIG_DEBUG_VM
>> +	BUG_ON(REGION_ID(address) !=3D USER_REGION_ID);
>> +#endif
>> +	/*
>> +	=C2=A0* We can't mark the pmd none here, because that will cause a race
>> +	=C2=A0* against exit_mmap. We need to continue mark pmd TRANS HUGE, wh=
ile
>> +	=C2=A0* we spilt, but at the same time we wan't rest of the ppc64 code
>> +	=C2=A0* not to insert hash pte on this, because we will be modifying
>> +	=C2=A0* the deposited pgtable in the caller of this function. Hence
>> +	=C2=A0* clear the _PAGE_USER so that we move the fault handling to
>> +	=C2=A0* higher level function and that will serialize against ptl.
>> +	=C2=A0* We need to flush existing hash pte entries here even though,
>> +	=C2=A0* the translation is still valid, because we will withdraw
>> +	=C2=A0* pgtable_t after this.
>> +	=C2=A0*/
>> +	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_USER, 0);
>
> Can this break any checks for _PAGE_USER? From other paths?


Should not, that is the same condition we use for autonuma.

>
>> +}
>> +
>> +
>> =C2=A0/*
>> =C2=A0 * set a new huge pmd. We should not be called for updating
>> =C2=A0 * an existing pmd entry. That should go via pmd_hugepage_update.
>> @@ -663,10 +687,19 @@ void set_pmd_at(struct mm_struct *mm, unsigned long
>> addr,
>> =C2=A0	return set_pte_at(mm, addr, pmdp_ptep(pmdp), pmd_pte(pmd));
>> =C2=A0}
>> =C2=A0
>> +/*
>> + * We use this to invalidate a pmdp entry before switching from a
>> + * hugepte to regular pmd entry.
>> + */
>> =C2=A0void pmdp_invalidate(struct vm_area_struct *vma, unsigned long add=
ress,
>> =C2=A0		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pmd_t *pmdp)
>> =C2=A0{
>> -	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_PRESENT, 0);
>> +	pmd_hugepage_update(vma->vm_mm, address, pmdp, ~0UL, 0);
>> +	/*
>> +	=C2=A0* This ensures that generic code that rely on IRQ disabling
>> +	=C2=A0* to prevent a parallel THP split work as expected.
>> +	=C2=A0*/
>> +	kick_all_cpus_sync();
>
> Seems expensive, anyway I think the right should do something like or a w=
rapper
> for it
>
> on_each_cpu_mask(mm_cpumask(vma->vm_mm), do_nothing, NULL, 1);
>
> do_nothing is not exported, but that can be fixed :)
>

Now we can't depend for mm_cpumask, a parallel find_linux_pte_hugepte
can happen outside that. Now i had a variant for kick_all_cpus_sync that
ignored idle cpus. But then that needs more verification.

http://article.gmane.org/gmane.linux.ports.ppc.embedded/81105

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
