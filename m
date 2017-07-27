Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DCF0C6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 20:49:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g9so13565995pfk.13
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 17:49:01 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id m4si10485198pgs.108.2017.07.26.17.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 17:49:00 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id v190so18806417pgv.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 17:49:00 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170727003434.GA537@bbox>
Date: Wed, 26 Jul 2017 17:48:58 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <77AFE0A4-FE3D-4E05-B248-30ADE2F184EF@gmail.com>
References: <20170724095832.vgvku6vlxkv75r3k@suse.de>
 <20170725073748.GB22652@bbox> <20170725085132.iysanhtqkgopegob@suse.de>
 <20170725091115.GA22920@bbox> <20170725100722.2dxnmgypmwnrfawp@suse.de>
 <20170726054306.GA11100@bbox> <20170726092228.pyjxamxweslgaemi@suse.de>
 <A300D14C-D7EE-4A26-A7CF-A7643F1A61BA@gmail.com> <20170726234025.GA4491@bbox>
 <60FF1876-AC4F-49BB-BC36-A144C3B6EA9E@gmail.com> <20170727003434.GA537@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Minchan Kim <minchan@kernel.org> wrote:

> On Wed, Jul 26, 2017 at 05:09:09PM -0700, Nadav Amit wrote:
>> Minchan Kim <minchan@kernel.org> wrote:
>>=20
>>> Hello Nadav,
>>>=20
>>> On Wed, Jul 26, 2017 at 12:18:37PM -0700, Nadav Amit wrote:
>>>> Mel Gorman <mgorman@suse.de> wrote:
>>>>=20
>>>>> On Wed, Jul 26, 2017 at 02:43:06PM +0900, Minchan Kim wrote:
>>>>>>> I'm relying on the fact you are the madv_free author to =
determine if
>>>>>>> it's really necessary. The race in question is CPU 0 running =
madv_free
>>>>>>> and updating some PTEs while CPU 1 is also running madv_free and =
looking
>>>>>>> at the same PTEs. CPU 1 may have writable TLB entries for a page =
but fail
>>>>>>> the pte_dirty check (because CPU 0 has updated it already) and =
potentially
>>>>>>> fail to flush. Hence, when madv_free on CPU 1 returns, there are =
still
>>>>>>> potentially writable TLB entries and the underlying PTE is still =
present
>>>>>>> so that a subsequent write does not necessarily propagate the =
dirty bit
>>>>>>> to the underlying PTE any more. Reclaim at some unknown time at =
the future
>>>>>>> may then see that the PTE is still clean and discard the page =
even though
>>>>>>> a write has happened in the meantime. I think this is possible =
but I could
>>>>>>> have missed some protection in madv_free that prevents it =
happening.
>>>>>>=20
>>>>>> Thanks for the detail. You didn't miss anything. It can happen =
and then
>>>>>> it's really bug. IOW, if application does write something after =
madv_free,
>>>>>> it must see the written value, not zero.
>>>>>>=20
>>>>>> How about adding [set|clear]_tlb_flush_pending in tlb batchin =
interface?
>>>>>> With it, when tlb_finish_mmu is called, we can know we skip the =
flush
>>>>>> but there is pending flush, so flush focefully to avoid =
madv_dontneed
>>>>>> as well as madv_free scenario.
>>>>>=20
>>>>> I *think* this is ok as it's simply more expensive on the KSM side =
in
>>>>> the event of a race but no other harmful change is made assuming =
that
>>>>> KSM is the only race-prone. The check for mm_tlb_flush_pending =
also
>>>>> happens under the PTL so there should be sufficient protection =
from the
>>>>> mm struct update being visible at teh right time.
>>>>>=20
>>>>> Check using the test program from "mm: Always flush VMA ranges =
affected
>>>>> by zap_page_range v2" if it handles the madvise case as well as =
that
>>>>> would give some degree of safety. Make sure it's tested against =
4.13-rc2
>>>>> instead of mmotm which already includes the madv_dontneed fix. If =
yours
>>>>> works for both then it supersedes the mmotm patch.
>>>>>=20
>>>>> It would also be interesting if Nadav would use his slowdown hack =
to see
>>>>> if he can still force the corruption.
>>>>=20
>>>> The proposed fix for the KSM side is likely to work (I will try =
later), but
>>>> on the tlb_finish_mmu() side, I think there is a problem, since if =
any TLB
>>>> flush is performed by tlb_flush_mmu(), flush_tlb_mm_range() will =
not be
>>>> executed. This means that tlb_finish_mmu() may flush one TLB entry, =
leave
>>>> another one stale and not flush it.
>>>=20
>>> Okay, I will change that part like this to avoid partial flush =
problem.
>>>=20
>>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>>> index 1c42d69490e4..87d0ebac6605 100644
>>> --- a/include/linux/mm_types.h
>>> +++ b/include/linux/mm_types.h
>>> @@ -529,10 +529,13 @@ static inline cpumask_t *mm_cpumask(struct =
mm_struct *mm)
>>> * The barriers below prevent the compiler from re-ordering the =
instructions
>>> * around the memory barriers that are already present in the code.
>>> */
>>> -static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
>>> +static inline int mm_tlb_flush_pending(struct mm_struct *mm)
>>> {
>>> +	int nr_pending;
>>> +
>>> 	barrier();
>>> -	return atomic_read(&mm->tlb_flush_pending) > 0;
>>> +	nr_pending =3D atomic_read(&mm->tlb_flush_pending);
>>> +	return nr_pending;
>>> }
>>> static inline void set_tlb_flush_pending(struct mm_struct *mm)
>>> {
>>> diff --git a/mm/memory.c b/mm/memory.c
>>> index d5c5e6497c70..b5320e96ec51 100644
>>> --- a/mm/memory.c
>>> +++ b/mm/memory.c
>>> @@ -286,11 +286,15 @@ bool tlb_flush_mmu(struct mmu_gather *tlb)
>>> void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, =
unsigned long end)
>>> {
>>> 	struct mmu_gather_batch *batch, *next;
>>> -	bool flushed =3D tlb_flush_mmu(tlb);
>>>=20
>>> +	if (!tlb->fullmm && !tlb->need_flush_all &&
>>> +			mm_tlb_flush_pending(tlb->mm) > 1) {
>>=20
>> I saw you noticed my comment about the access of the flag without a =
lock. I
>> must say it feels strange that a memory barrier would be needed here, =
but
>> that what I understood from the documentation.
>=20
> I saw your recent barriers fix patch, too.
> [PATCH v2 2/2] mm: migrate: fix barriers around tlb_flush_pending
>=20
> As I commented out in there, I hope to use below here without being
> aware of complex barrier stuff. Instead, mm_tlb_flush_pending should
> call the right barrier inside.
>=20
>        mm_tlb_flush_pending(tlb->mm, false:no-pte-locked) > 1

I will address it in v3.


>=20
>>> +		tlb->start =3D min(start, tlb->start);
>>> +		tlb->end =3D max(end, tlb->end);
>>=20
>> Err=E2=80=A6 You open-code mmu_gather which is arch-specific. It =
appears that all of
>> them have start and end members, but not need_flush_all. Besides, I =
am not
>=20
> When I see tlb_gather_mmu which is not arch-specific, it intializes
> need_flush_all to zero so it would be no harmful although some of
> architecture doesn't set the flag.
> Please correct me if I miss something.

Oh.. my bad. I missed the fact that this code is under =E2=80=9C#ifdef
HAVE_GENERIC_MMU_GATHER=E2=80=9D. But that means that arch-specific =
tlb_finish_mmu()
implementations (s390, arm) may need to be modified as well.

>> sure whether they regard start and end the same way.
>=20
> I understand your worry but my patch takes longer range by min/max
> so I cannot imagine how it breaks. During looking the code, I found
> __tlb_adjust_range so better to use it rather than open-code.
>=20
>=20
> diff --git a/mm/memory.c b/mm/memory.c
> index b5320e96ec51..b23188daa396 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -288,10 +288,8 @@ void tlb_finish_mmu(struct mmu_gather *tlb, =
unsigned long start, unsigned long e
> 	struct mmu_gather_batch *batch, *next;
>=20
> 	if (!tlb->fullmm && !tlb->need_flush_all &&
> -			mm_tlb_flush_pending(tlb->mm) > 1) {
> -		tlb->start =3D min(start, tlb->start);
> -		tlb->end =3D max(end, tlb->end);
> -	}
> +			mm_tlb_flush_pending(tlb->mm) > 1)
> +		__tlb_adjust_range(tlb->mm, start, end - start);
>=20
> 	tlb_flush_mmu(tlb);
> 	clear_tlb_flush_pending(tlb->mm);

This one is better, especially as I now understand it is only for the
generic MMU gather (which I missed before).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
