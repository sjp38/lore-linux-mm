Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5836B025E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 09:08:13 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fg1so28735144pad.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 06:08:13 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id i1si9776741pfj.61.2016.06.15.06.08.11
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 06:08:11 -0700 (PDT)
From: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>
Subject: RE: [PATCH] Linux VM workaround for Knights Landing A/D leak
Date: Wed, 15 Jun 2016 13:06:17 +0000
Message-ID: <C1C2579D7BE026428F81F41198ADB17237A866C6@irsmsx110.ger.corp.intel.com>
References: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com>
 <57603CBE.7090702@linux.intel.com>
In-Reply-To: <57603CBE.7090702@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>
Cc: "Srinivasappa, Harish" <harish.srinivasappa@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>

From: Dave Hansen [mailto:dave.hansen@linux.intel.com]=20
Sent: Tuesday, June 14, 2016 7:20 PM

>> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtab=
le.h
...
>> +extern void fix_pte_leak(struct mm_struct *mm, unsigned long addr,
>> +			 pte_t *ptep);

> Doesn't hugetlb.h somehow #include pgtable.h?  So why double-define
> fix_pte_leak()?

It's other way round - pgtable.h somehow includes hugetlb.h. I've removed
duplicated fix_pte_leak() declaration.

>> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pg=
table_64.h
>> index 2ee7811..6fa4079 100644
>> --- a/arch/x86/include/asm/pgtable_64.h
>> +++ b/arch/x86/include/asm/pgtable_64.h
>> @@ -178,6 +178,12 @@ extern void cleanup_highmap(void);
>>  extern void init_extra_mapping_uc(unsigned long phys, unsigned long siz=
e);
>>  extern void init_extra_mapping_wb(unsigned long phys, unsigned long siz=
e);
>> =20
>> +#define ARCH_HAS_NEEDS_SWAP_PTL 1
>> +static inline bool arch_needs_swap_ptl(void)
>> +{
>> +       return boot_cpu_has_bug(X86_BUG_PTE_LEAK);
>> +}
>> +
>>  #endif /* !__ASSEMBLY__ */

> I think we need a comment on this sucker.  I'm not sure we should lean
> solely on the commit message to record why we need this until the end of
> time.

OK.

>> +	if (c->x86_model =3D=3D 87) {

> Please use the macros in here for the model id:

OK.

> http://git.kernel.org/cgit/linux/kernel/git/tip/tip.git/tree/arch/x86/inc=
lude/asm/intel-family.h

> We also probably want to prefix the pr_info() with something like
> "x86/intel:".

OK

>> +/*
>> + * Workaround for KNL issue:

> Please be specific about what this "KNL issue" *is*.=20

OK

>> + * A thread that is going to page fault due to P=3D0, may still
>> + * non atomically set A or D bits, which could corrupt swap entries.
>> + * Always flush the other CPUs and clear the PTE again to avoid
>> + * this leakage. We are excluded using the pagetable lock.
>> + */
>> +
>> +void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t *ptep=
)
>> +{
>> +	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids) =
{
>> +		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
>> +		flush_tlb_others(mm_cpumask(mm), mm, addr,
>> +				 addr + PAGE_SIZE);
>> +		mb();
>> +		set_pte(ptep, __pte(0));
>> +	}
>> +}
>
> I think the comment here is a bit sparse.  Can we add some more details,
> like:
>
>	Entering here, the current CPU just cleared the PTE.  But,
>	another thread may have raced and set the A or D bits, or be
>	_about_ to set the bits.  Shooting their TLB entry down will
>	ensure they see the cleared PTE and will not set A or D.
>
> and by the set_pte():
>
>	Clear the PTE one more time, in case the other thread set A/D
>	before we sent the TLB flush.

Thanks,
Lukasz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
