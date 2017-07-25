Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DCB996B02B4
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 20:33:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s70so143414978pfs.5
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 17:33:26 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id l15si7288635pfi.299.2017.07.24.17.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 17:33:25 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id y129so13053757pgy.3
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 17:33:25 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] mm: Prevent racy access to tlb_flush_pending
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <1A44338A-C667-4D63-A93F-EBBF6C9226D2@gmail.com>
Date: Mon, 24 Jul 2017 17:33:21 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <CC1008BD-6CE1-48B3-9A8A-CE9891B8E5FF@gmail.com>
References: <20170717180246.62277-1-namit@vmware.com>
 <20170724165449.1a51b34d22ee4a9b54ce2652@linux-foundation.org>
 <1A44338A-C667-4D63-A93F-EBBF6C9226D2@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Nadav Amit <namit@vmware.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>

Nadav Amit <nadav.amit@gmail.com> wrote:

> Andrew Morton <akpm@linux-foundation.org> wrote:
>=20
>> On Mon, 17 Jul 2017 11:02:46 -0700 Nadav Amit <namit@vmware.com> =
wrote:
>>=20
>>> Setting and clearing mm->tlb_flush_pending can be performed by =
multiple
>>> threads, since mmap_sem may only be acquired for read in =
task_numa_work.
>>> If this happens, tlb_flush_pending may be cleared while one of the
>>> threads still changes PTEs and batches TLB flushes.
>>>=20
>>> As a result, TLB flushes can be skipped because the indication of
>>> pending TLB flushes is lost, for instance due to race between
>>> migration and change_protection_range (just as in the scenario that
>>> caused the introduction of tlb_flush_pending).
>>>=20
>>> The feasibility of such a scenario was confirmed by adding assertion =
to
>>> check tlb_flush_pending is not set by two threads, adding artificial
>>> latency in change_protection_range() and using sysctl to reduce
>>> kernel.numa_balancing_scan_delay_ms.
>>>=20
>>> Fixes: 20841405940e ("mm: fix TLB flush race between migration, and
>>> change_protection_range")
>>=20
>> The changelog doesn't describe the user-visible effects of the bug =
(it
>> should always do so, please).  But it is presumably a data-corruption
>> bug so I suggest that a -stable backport is warranted?
>=20
> Yes, although I did not encounter an actual memory corruption.
>=20
>> It has been there for 4 years so I'm thinking we can hold off a
>> mainline (and hence -stable) merge until 4.13-rc1, yes?
>>=20
>>=20
>> One thought:
>>=20
>>> --- a/include/linux/mm_types.h
>>> +++ b/include/linux/mm_types.h
>>>=20
>>> ...
>>>=20
>>> @@ -528,11 +528,11 @@ static inline cpumask_t *mm_cpumask(struct =
mm_struct *mm)
>>> static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
>>> {
>>> 	barrier();
>>> -	return mm->tlb_flush_pending;
>>> +	return atomic_read(&mm->tlb_flush_pending) > 0;
>>> }
>>> static inline void set_tlb_flush_pending(struct mm_struct *mm)
>>> {
>>> -	mm->tlb_flush_pending =3D true;
>>> +	atomic_inc(&mm->tlb_flush_pending);
>>>=20
>>> 	/*
>>> 	 * Guarantee that the tlb_flush_pending store does not leak into =
the
>>> @@ -544,7 +544,7 @@ static inline void set_tlb_flush_pending(struct =
mm_struct *mm)
>>> static inline void clear_tlb_flush_pending(struct mm_struct *mm)
>>> {
>>> 	barrier();
>>> -	mm->tlb_flush_pending =3D false;
>>> +	atomic_dec(&mm->tlb_flush_pending);
>>> }
>>> #else
>>=20
>> Do we still need the barrier()s or is it OK to let the atomic op do
>> that for us (with a suitable code comment).
>=20
> I will submit v2. However, I really don=E2=80=99t understand the =
comment on
> mm_tlb_flush_pending():
>=20
> /*             =20
> * Memory barriers to keep this state in sync are graciously provided =
by
> * the page table locks, outside of which no page table modifications =
happen.
> * The barriers below prevent the compiler from re-ordering the =
instructions
> * around the memory barriers that are already present in the code.
> */
>=20
> But IIUC migrate_misplaced_transhuge_page() does not call
> mm_tlb_flush_pending() while the ptl is taken.
>=20
> Mel, can I bother you again? Should I move the flush in
> migrate_misplaced_transhuge_page() till after the ptl is taken?

Oops: this would be obviously wrong since it would move it after
migrate_page_copy() is run. So I do need your advice whether the comment =
is
wrong or the implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
