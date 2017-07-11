Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 502E6440846
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 03:30:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c23so137288979pfe.11
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:30:31 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id f2si2955920pgr.380.2017.07.11.00.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 00:30:30 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id d193so15723025pgc.2
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:30:30 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170711064149.bg63nvi54ycynxw4@suse.de>
Date: Tue, 11 Jul 2017 00:30:28 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
References: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
 <20170711064149.bg63nvi54ycynxw4@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Mon, Jul 10, 2017 at 05:52:25PM -0700, Nadav Amit wrote:
>> Something bothers me about the TLB flushes batching mechanism that =
Linux
>> uses on x86 and I would appreciate your opinion regarding it.
>>=20
>> As you know, try_to_unmap_one() can batch TLB invalidations. While =
doing so,
>> however, the page-table lock(s) are not held, and I see no indication =
of the
>> pending flush saved (and regarded) in the relevant mm-structs.
>>=20
>> So, my question: what prevents, at least in theory, the following =
scenario:
>>=20
>> 	CPU0 				CPU1
>> 	----				----
>> 					user accesses memory using RW =
PTE=20
>> 					[PTE now cached in TLB]
>> 	try_to_unmap_one()
>> 	=3D=3D> ptep_get_and_clear()
>> 	=3D=3D> set_tlb_ubc_flush_pending()
>> 					mprotect(addr, PROT_READ)
>> 					=3D=3D> change_pte_range()
>> 					=3D=3D> [ PTE non-present - no =
flush ]
>>=20
>> 					user writes using cached RW PTE
>> 	...
>>=20
>> 	try_to_unmap_flush()
>>=20
>>=20
>> As you see CPU1 write should have failed, but may succeed.=20
>>=20
>> Now I don???t have a PoC since in practice it seems hard to create =
such a
>> scenario: try_to_unmap_one() is likely to find the PTE accessed and =
the PTE
>> would not be reclaimed.
>=20
> That is the same to a race whereby there is no batching mechanism and =
the
> racing operation happens between a pte clear and a flush as =
ptep_clear_flush
> is not atomic. All that differs is that the race window is a different =
size.
> The application on CPU1 is buggy in that it may or may not succeed the =
write
> but it is buggy regardless of whether a batching mechanism is used or =
not.

Thanks for your quick and detailed response, but I fail to see how it =
can
happen without batching. Indeed, the PTE clear and flush are not =
=E2=80=9Catomic=E2=80=9D,
but without batching they are both performed under the page table lock
(which is acquired in page_vma_mapped_walk and released in
page_vma_mapped_walk_done). Since the lock is taken, other cores should =
not
be able to inspect/modify the PTE. Relevant functions, e.g., =
zap_pte_range
and change_pte_range, acquire the lock before accessing the PTEs.

Can you please explain why you consider the application to be buggy? =
AFAIU
an application can wish to trap certain memory accesses using =
userfaultfd or
SIGSEGV. For example, it may do it for garbage collection or sandboxing. =
To
do so, it can use mprotect with PROT_NONE and expect to be able to trap
future accesses to that memory. This use-case is described in usefaultfd
documentation.

> The user accessed the PTE before the mprotect so, at the time of =
mprotect,
> the PTE is either clean or dirty. If it is clean then any subsequent =
write
> would transition the PTE from clean to dirty and an architecture =
enabling
> the batching mechanism must trap a clean->dirty transition for =
unmapped
> entries as commented upon in try_to_unmap_one (and was checked that =
this
> is true for x86 at least). This avoids data corruption due to a lost =
update.
>=20
> If the previous access was a write then the batching flushes the page =
if
> any IO is required to avoid any writes after the IO has been initiated
> using try_to_unmap_flush_dirty so again there is no data corruption. =
There
> is a window where the TLB entry exists after the unmapping but this =
exists
> regardless of whether we batch or not.
>=20
> In either case, before a page is freed and potentially allocated to =
another
> process, the TLB is flushed.

To clarify my concern again - I am not regarding a memory corruption as =
you
do, but situations in which the application wishes to trap certain =
memory
accesses but fails to do so. Having said that, I would add, that even if =
an
application has a bug, it may expect this bug not to affect memory that =
was
previously unmapped (and may be written to permanent storage).

Thanks (again),
Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
