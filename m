Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 310DB6B0292
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 17:28:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s64so31855732pfa.1
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 14:28:33 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id b60si2590315plc.594.2017.07.18.14.28.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 14:28:31 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id v190so4319231pgv.1
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 14:28:31 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170715155518.ok2q62efc2vurqk5@suse.de>
Date: Tue, 18 Jul 2017 14:28:27 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
References: <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
 <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
 <20170715155518.ok2q62efc2vurqk5@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Fri, Jul 14, 2017 at 04:16:44PM -0700, Nadav Amit wrote:
>> Mel Gorman <mgorman@suse.de> wrote:
>>=20
>>> On Wed, Jul 12, 2017 at 04:27:23PM -0700, Nadav Amit wrote:
>>>>> If reclaim is first, it'll take the PTL, set batched while a =
racing
>>>>> mprotect/munmap/etc spins. On release, the racing mprotect/munmmap
>>>>> immediately calls flush_tlb_batched_pending() before proceeding as =
normal,
>>>>> finding pte_none with the TLB flushed.
>>>>=20
>>>> This is the scenario I regarded in my example. Notice that when the =
first
>>>> flush_tlb_batched_pending is called, CPU0 and CPU1 hold different =
page-table
>>>> locks - allowing them to run concurrently. As a result
>>>> flush_tlb_batched_pending is executed before the PTE was cleared =
and
>>>> mm->tlb_flush_batched is cleared. Later, after CPU0 runs =
ptep_get_and_clear
>>>> mm->tlb_flush_batched remains clear, and CPU1 can use the stale =
PTE.
>>>=20
>>> If they hold different PTL locks, it means that reclaim and and the =
parallel
>>> munmap/mprotect/madvise/mremap operation are operating on different =
regions
>>> of an mm or separate mm's and the race should not apply or at the =
very
>>> least is equivalent to not batching the flushes. For multiple =
parallel
>>> operations, munmap/mprotect/mremap are serialised by mmap_sem so =
there
>>> is only one risky operation at a time. For multiple madvise, there =
is a
>>> small window when a page is accessible after madvise returns but it =
is an
>>> advisory call so it's primarily a data integrity concern and the TLB =
is
>>> flushed before the page is either freed or IO starts on the reclaim =
side.
>>=20
>> I think there is some miscommunication. Perhaps one detail was =
missing:
>>=20
>> CPU0				CPU1
>> ---- 				----
>> should_defer_flush
>> =3D> mm->tlb_flush_batched=3Dtrue	=09
>> 				flush_tlb_batched_pending (another PT)
>> 				=3D> flush TLB
>> 				=3D> mm->tlb_flush_batched=3Dfalse
>>=20
>> 				Access PTE (and cache in TLB)
>> ptep_get_and_clear(PTE)
>> ...
>>=20
>> 				flush_tlb_batched_pending (batched PT)
>> 				[ no flush since tlb_flush_batched=3Dfalse=
 ]
>> 				use the stale PTE
>> ...
>> try_to_unmap_flush
>>=20
>> There are only 2 CPUs and both regard the same address-space. CPU0 =
reclaim a
>> page from this address-space. Just between setting tlb_flush_batch =
and the
>> actual clearing of the PTE, the process on CPU1 runs munmap and calls
>> flush_tlb_batched_pending. This can happen if CPU1 regards a =
different
>> page-table.
>=20
> If both regard the same address-space then they have the same page =
table so
> there is a disconnect between the first and last sentence in your =
paragraph
> above. On CPU 0, the setting of tlb_flush_batched and =
ptep_get_and_clear
> is also reversed as the sequence is
>=20
>                        pteval =3D ptep_get_and_clear(mm, address, =
pvmw.pte);
>                        set_tlb_ubc_flush_pending(mm, =
pte_dirty(pteval));
>=20
> Additional barriers should not be needed as within the critical =
section
> that can race, it's protected by the lock and with Andy's code, there =
is
> a full barrier before the setting of tlb_flush_batched. With Andy's =
code,
> there may be a need for a compiler barrier but I can rethink about =
that
> and add it during the backport to -stable if necessary.
>=20
> So the setting happens after the clear and if they share the same =
address
> space and collide then they both share the same PTL so are protected =
from
> each other.
>=20
> If there are separate address spaces using a shared mapping then the
> same race does not occur.

I missed the fact you reverted the two operations since the previous =
version
of the patch. This specific scenario should be solved with this patch.

But in general, I think there is a need for a simple locking scheme.
Otherwise, people (like me) would be afraid to make any changes to the =
code,
and additional missing TLB flushes would exist. For example, I suspect =
that
a user may trigger insert_pfn() or insert_page(), and rely on their =
output.
While it makes little sense, the user can try to insert the page on the =
same
address of another page. If the other page was already reclaimed the
operation should succeed and otherwise fail. But it may succeed while =
the
other page is going through reclamation, resulting in:

CPU0					CPU1
----					----			=09
					ptep_clear_flush_notify()
- access memory using a PTE
[ PTE cached in TLB ]
					try_to_unmap_one()
					=3D=3D> ptep_get_and_clear() =3D=3D=
 false
insert_page()
=3D=3D> pte_none() =3D true
    [retval =3D 0]

- access memory using a stale PTE


Additional potential situations can be caused, IIUC, by =
mcopy_atomic_pte(),
mfill_zeropage_pte(), shmem_mcopy_atomic_pte().

Even more importantly, I suspect there is an additional similar but
unrelated problem. clear_refs_write() can be used with =
CLEAR_REFS_SOFT_DIRTY
to write-protect PTEs. However, it batches TLB flushes, while only =
holding
mmap_sem for read, and without any indication in mm that TLB flushes are
pending.

As a result, concurrent operation such as KSM=E2=80=99s =
write_protect_page() or
page_mkclean_one() can consider the page write-protected while in fact =
it is
still accessible - since the TLB flush was deferred. As a result, they =
may
mishandle the PTE without flushing the page. In the case of
page_mkclean_one(), I suspect it may even lead to memory corruption. I =
admit
that in x86 there are some mitigating factors that would make such =
=E2=80=9Cattack=E2=80=9D
complicated, but it still seems wrong to me, no?

Thanks,
Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
