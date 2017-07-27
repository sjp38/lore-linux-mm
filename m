Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D790C6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 20:09:12 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a2so231320526pgn.15
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 17:09:12 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id f33si7612510plf.725.2017.07.26.17.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 17:09:11 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id g69so7629784pfe.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 17:09:11 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170726234025.GA4491@bbox>
Date: Wed, 26 Jul 2017 17:09:09 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <60FF1876-AC4F-49BB-BC36-A144C3B6EA9E@gmail.com>
References: <20170720074342.otez35bme5gytnxl@suse.de>
 <BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com>
 <20170724095832.vgvku6vlxkv75r3k@suse.de> <20170725073748.GB22652@bbox>
 <20170725085132.iysanhtqkgopegob@suse.de> <20170725091115.GA22920@bbox>
 <20170725100722.2dxnmgypmwnrfawp@suse.de> <20170726054306.GA11100@bbox>
 <20170726092228.pyjxamxweslgaemi@suse.de>
 <A300D14C-D7EE-4A26-A7CF-A7643F1A61BA@gmail.com> <20170726234025.GA4491@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Minchan Kim <minchan@kernel.org> wrote:

> Hello Nadav,
>=20
> On Wed, Jul 26, 2017 at 12:18:37PM -0700, Nadav Amit wrote:
>> Mel Gorman <mgorman@suse.de> wrote:
>>=20
>>> On Wed, Jul 26, 2017 at 02:43:06PM +0900, Minchan Kim wrote:
>>>>> I'm relying on the fact you are the madv_free author to determine =
if
>>>>> it's really necessary. The race in question is CPU 0 running =
madv_free
>>>>> and updating some PTEs while CPU 1 is also running madv_free and =
looking
>>>>> at the same PTEs. CPU 1 may have writable TLB entries for a page =
but fail
>>>>> the pte_dirty check (because CPU 0 has updated it already) and =
potentially
>>>>> fail to flush. Hence, when madv_free on CPU 1 returns, there are =
still
>>>>> potentially writable TLB entries and the underlying PTE is still =
present
>>>>> so that a subsequent write does not necessarily propagate the =
dirty bit
>>>>> to the underlying PTE any more. Reclaim at some unknown time at =
the future
>>>>> may then see that the PTE is still clean and discard the page even =
though
>>>>> a write has happened in the meantime. I think this is possible but =
I could
>>>>> have missed some protection in madv_free that prevents it =
happening.
>>>>=20
>>>> Thanks for the detail. You didn't miss anything. It can happen and =
then
>>>> it's really bug. IOW, if application does write something after =
madv_free,
>>>> it must see the written value, not zero.
>>>>=20
>>>> How about adding [set|clear]_tlb_flush_pending in tlb batchin =
interface?
>>>> With it, when tlb_finish_mmu is called, we can know we skip the =
flush
>>>> but there is pending flush, so flush focefully to avoid =
madv_dontneed
>>>> as well as madv_free scenario.
>>>=20
>>> I *think* this is ok as it's simply more expensive on the KSM side =
in
>>> the event of a race but no other harmful change is made assuming =
that
>>> KSM is the only race-prone. The check for mm_tlb_flush_pending also
>>> happens under the PTL so there should be sufficient protection from =
the
>>> mm struct update being visible at teh right time.
>>>=20
>>> Check using the test program from "mm: Always flush VMA ranges =
affected
>>> by zap_page_range v2" if it handles the madvise case as well as that
>>> would give some degree of safety. Make sure it's tested against =
4.13-rc2
>>> instead of mmotm which already includes the madv_dontneed fix. If =
yours
>>> works for both then it supersedes the mmotm patch.
>>>=20
>>> It would also be interesting if Nadav would use his slowdown hack to =
see
>>> if he can still force the corruption.
>>=20
>> The proposed fix for the KSM side is likely to work (I will try =
later), but
>> on the tlb_finish_mmu() side, I think there is a problem, since if =
any TLB
>> flush is performed by tlb_flush_mmu(), flush_tlb_mm_range() will not =
be
>> executed. This means that tlb_finish_mmu() may flush one TLB entry, =
leave
>> another one stale and not flush it.
>=20
> Okay, I will change that part like this to avoid partial flush =
problem.
>=20
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 1c42d69490e4..87d0ebac6605 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -529,10 +529,13 @@ static inline cpumask_t *mm_cpumask(struct =
mm_struct *mm)
>  * The barriers below prevent the compiler from re-ordering the =
instructions
>  * around the memory barriers that are already present in the code.
>  */
> -static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
> +static inline int mm_tlb_flush_pending(struct mm_struct *mm)
> {
> +	int nr_pending;
> +
> 	barrier();
> -	return atomic_read(&mm->tlb_flush_pending) > 0;
> +	nr_pending =3D atomic_read(&mm->tlb_flush_pending);
> +	return nr_pending;
> }
> static inline void set_tlb_flush_pending(struct mm_struct *mm)
> {
> diff --git a/mm/memory.c b/mm/memory.c
> index d5c5e6497c70..b5320e96ec51 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -286,11 +286,15 @@ bool tlb_flush_mmu(struct mmu_gather *tlb)
> void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, =
unsigned long end)
> {
> 	struct mmu_gather_batch *batch, *next;
> -	bool flushed =3D tlb_flush_mmu(tlb);
>=20
> +	if (!tlb->fullmm && !tlb->need_flush_all &&
> +			mm_tlb_flush_pending(tlb->mm) > 1) {

I saw you noticed my comment about the access of the flag without a =
lock. I
must say it feels strange that a memory barrier would be needed here, =
but
that what I understood from the documentation.

> +		tlb->start =3D min(start, tlb->start);
> +		tlb->end =3D max(end, tlb->end);

Err=E2=80=A6 You open-code mmu_gather which is arch-specific. It appears =
that all of
them have start and end members, but not need_flush_all. Besides, I am =
not
sure whether they regard start and end the same way.

> +	}
> +
> +	tlb_flush_mmu(tlb);
> 	clear_tlb_flush_pending(tlb->mm);
> -	if (!flushed && mm_tlb_flush_pending(tlb->mm))
> -		flush_tlb_mm_range(tlb->mm, start, end, 0UL);
>=20
> 	/* keep the page table cache within bounds */
> 	check_pgt_cache();
>> Note also that the use of set/clear_tlb_flush_pending() is only =
applicable
>> following my pending fix that changes the pending indication from =
bool to
>> atomic_t.
>=20
> Sure, I saw it in current mmots. Without your good job, my patch never =
work. :)
> Thanks for the head up.

Thanks, I really appreciate it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
