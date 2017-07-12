Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E730440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 19:27:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q87so37826551pfk.15
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 16:27:27 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 3si2987329plz.629.2017.07.12.16.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 16:27:26 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id e199so4892257pfh.0
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 16:27:26 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170712082733.ouf7yx2bnvwwcfms@suse.de>
Date: Wed, 12 Jul 2017 16:27:23 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
References: <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Jul 11, 2017 at 03:27:55PM -0700, Nadav Amit wrote:
>> Mel Gorman <mgorman@suse.de> wrote:
>>=20
>>> On Tue, Jul 11, 2017 at 09:09:23PM +0100, Mel Gorman wrote:
>>>> On Tue, Jul 11, 2017 at 08:18:23PM +0100, Mel Gorman wrote:
>>>>> I don't think we should be particularly clever about this and =
instead just
>>>>> flush the full mm if there is a risk of a parallel batching of =
flushing is
>>>>> in progress resulting in a stale TLB entry being used. I think =
tracking mms
>>>>> that are currently batching would end up being costly in terms of =
memory,
>>>>> fairly complex, or both. Something like this?
>>>>=20
>>>> mremap and madvise(DONTNEED) would also need to flush. Memory =
policies are
>>>> fine as a move_pages call that hits the race will simply fail to =
migrate
>>>> a page that is being freed and once migration starts, it'll be =
flushed so
>>>> a stale access has no further risk. copy_page_range should also be =
ok as
>>>> the old mm is flushed and the new mm cannot have entries yet.
>>>=20
>>> Adding those results in
>>=20
>> You are way too fast for me.
>>=20
>>> --- a/mm/rmap.c
>>> +++ b/mm/rmap.c
>>> @@ -637,12 +637,34 @@ static bool should_defer_flush(struct =
mm_struct *mm, enum ttu_flags flags)
>>> 		return false;
>>>=20
>>> 	/* If remote CPUs need to be flushed then defer batch the flush =
*/
>>> -	if (cpumask_any_but(mm_cpumask(mm), get_cpu()) < nr_cpu_ids)
>>> +	if (cpumask_any_but(mm_cpumask(mm), get_cpu()) < nr_cpu_ids) {
>>> 		should_defer =3D true;
>>> +		mm->tlb_flush_batched =3D true;
>>> +	}
>>=20
>> Since mm->tlb_flush_batched is set before the PTE is actually =
cleared, it
>> still seems to leave a short window for a race.
>>=20
>> CPU0				CPU1
>> ---- 				----
>> should_defer_flush
>> =3D> mm->tlb_flush_batched=3Dtrue	=09
>> 				flush_tlb_batched_pending (another PT)
>> 				=3D> flush TLB
>> 				=3D> mm->tlb_flush_batched=3Dfalse
>> ptep_get_and_clear
>> ...
>>=20
>> 				flush_tlb_batched_pending (batched PT)
>> 				use the stale PTE
>> ...
>> try_to_unmap_flush
>>=20
>> IOW it seems that mm->flush_flush_batched should be set after the PTE =
is
>> cleared (and have some compiler barrier to be on the safe side).
>=20
> I'm relying on setting and clearing of tlb_flush_batched is under a =
PTL
> that is contended if the race is active.
>=20
> If reclaim is first, it'll take the PTL, set batched while a racing
> mprotect/munmap/etc spins. On release, the racing mprotect/munmmap
> immediately calls flush_tlb_batched_pending() before proceeding as =
normal,
> finding pte_none with the TLB flushed.

This is the scenario I regarded in my example. Notice that when the =
first
flush_tlb_batched_pending is called, CPU0 and CPU1 hold different =
page-table
locks - allowing them to run concurrently. As a result
flush_tlb_batched_pending is executed before the PTE was cleared and
mm->tlb_flush_batched is cleared. Later, after CPU0 runs =
ptep_get_and_clear
mm->tlb_flush_batched remains clear, and CPU1 can use the stale PTE.

> If the mprotect/munmap/etc is first, it'll take the PTL, observe that
> pte_present and handle the flushing itself while reclaim potentially
> spins. When reclaim acquires the lock, it'll still set set =
tlb_flush_batched.
>=20
> As it's PTL that is taken for that field, it is possible for the =
accesses
> to be re-ordered but only in the case where a race is not occurring.
> I'll think some more about whether barriers are necessary but =
concluded
> they weren't needed in this instance. Doing the setting/clear+flush =
under
> the PTL, the protection is similar to normal page table operations =
that
> do not batch the flush.
>=20
>> One more question, please: how does elevated page count or even =
locking the
>> page help (as you mention in regard to uprobes and ksm)? Yes, the =
page will
>> not be reclaimed, but IIUC try_to_unmap is called before the =
reference count
>> is frozen, and the page lock is dropped on each iteration of the loop =
in
>> shrink_page_list. In this case, it seems to me that uprobes or ksm =
may still
>> not flush the TLB.
>=20
> If page lock is held then reclaim skips the page entirely and uprobe,
> ksm and cow holds the page lock for pages that potentially be observed
> by reclaim.  That is the primary protection for those paths.

It is really hard, at least for me, to track this synchronization =
scheme, as
each path is protected in different means. I still don=E2=80=99t =
understand why it
is true, since the loop in shrink_page_list calls =
__ClearPageLocked(page) on
each iteration, before the actual flush takes place.

Actually, I think that based on Andy=E2=80=99s patches there is a =
relatively
reasonable solution. For each mm we will hold both a =
=E2=80=9Cpending_tlb_gen=E2=80=9D
(increased under the PT-lock) and an =E2=80=9Cexecuted_tlb_gen=E2=80=9D. =
Once
flush_tlb_mm_range finishes flushing it will use cmpxchg to update the
executed_tlb_gen to the pending_tlb_gen that was prior the flush (the
cmpxchg will ensure the TLB gen only goes forward). Then, whenever
pending_tlb_gen is different than executed_tlb_gen - a flush is needed.

Nadav=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
