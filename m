Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7F66B025F
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:43:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so232889966pfa.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 11:43:48 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id s25si3130406pfj.297.2016.07.15.11.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 11:43:47 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id t190so6761586pfb.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 11:43:47 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] x86/mm: Change barriers before TLB flushes to smp_mb__after_atomic
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrUVmuXNpmFwe54iHjKsYmJEn4WSJ0RDO44V=mFMBwyuow@mail.gmail.com>
Date: Fri, 15 Jul 2016 11:43:45 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <EE4EBF32-0C5C-4112-B158-FDA6B8801421@gmail.com>
References: <1464405413-7209-1-git-send-email-namit@vmware.com> <CALCETrUVmuXNpmFwe54iHjKsYmJEn4WSJ0RDO44V=mFMBwyuow@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nadav Amit <namit@vmware.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jerome Marchand <jmarchan@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>

Andy Lutomirski <luto@amacapital.net> wrote:

> On Fri, May 27, 2016 at 8:16 PM, Nadav Amit <namit@vmware.com> wrote:
>> When (current->active_mm !=3D mm), flush_tlb_page() does not perform =
a
>> memory barrier. In practice, this memory barrier is not needed since =
in
>> the existing call-sites the PTE is modified using atomic-operations.
>> This patch therefore modifies the existing smp_mb in flush_tlb_page =
to
>> smp_mb__after_atomic and adds the missing one, while documenting the =
new
>> assumption of flush_tlb_page.
>>=20
>> In addition smp_mb__after_atomic is also added to
>> set_tlb_ubc_flush_pending, since it makes a similar implicit =
assumption
>> and omits the memory barrier.
>>=20
>> Signed-off-by: Nadav Amit <namit@vmware.com>
>> ---
>> arch/x86/mm/tlb.c | 9 ++++++++-
>> mm/rmap.c         | 3 +++
>> 2 files changed, 11 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
>> index fe9b9f7..2534333 100644
>> --- a/arch/x86/mm/tlb.c
>> +++ b/arch/x86/mm/tlb.c
>> @@ -242,6 +242,10 @@ out:
>>        preempt_enable();
>> }
>>=20
>> +/*
>> + * Calls to flush_tlb_page must be preceded by atomic PTE change or
>> + * explicit memory-barrier.
>> + */
>> void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
>> {
>>        struct mm_struct *mm =3D vma->vm_mm;
>> @@ -259,8 +263,11 @@ void flush_tlb_page(struct vm_area_struct *vma, =
unsigned long start)
>>                        leave_mm(smp_processor_id());
>>=20
>>                        /* Synchronize with switch_mm. */
>> -                       smp_mb();
>> +                       smp_mb__after_atomic();
>>                }
>> +       } else {
>> +               /* Synchronize with switch_mm. */
>> +               smp_mb__after_atomic();
>>        }
>>=20
>>        if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < =
nr_cpu_ids)
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 307b555..60ab0fe 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -613,6 +613,9 @@ static void set_tlb_ubc_flush_pending(struct =
mm_struct *mm,
>> {
>>        struct tlbflush_unmap_batch *tlb_ubc =3D &current->tlb_ubc;
>>=20
>> +       /* Synchronize with switch_mm. */
>> +       smp_mb__after_atomic();
>> +
>>        cpumask_or(&tlb_ubc->cpumask, &tlb_ubc->cpumask, =
mm_cpumask(mm));
>>        tlb_ubc->flush_required =3D true;
>>=20
>> --
>> 2.7.4
>=20
> This looks fine for x86, but I have no idea whether other
> architectures are okay with it.  akpm?  mm folks?

Ping?

Note that this patch adds two missing barriers.

Thanks,
Nadav




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
