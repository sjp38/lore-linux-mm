Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F33C6B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 19:39:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u17so14573922pfa.6
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 16:39:10 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id d190si743191pfa.7.2017.07.19.16.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 16:39:09 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id s70so5503197pfs.0
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 16:39:09 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170719225950.wfpfzpc6llwlyxdo@suse.de>
Date: Wed, 19 Jul 2017 16:39:07 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <4DC97890-9FFA-4BA4-B300-B679BAB2136D@gmail.com>
References: <20170713060706.o2cuko5y6irxwnww@suse.de>
 <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
 <20170715155518.ok2q62efc2vurqk5@suse.de>
 <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
 <20170719074131.75wexoal3fiyoxw5@suse.de>
 <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
 <20170719195820.drtfmweuhdc4eca6@suse.de>
 <4BD983A1-724B-4FD7-B502-55351717BC5F@gmail.com>
 <20170719214708.wuzq3di6rt43txtn@suse.de>
 <3D1386AD-7875-40B9-8C6F-DE02CF8A45A1@gmail.com>
 <20170719225950.wfpfzpc6llwlyxdo@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Jul 19, 2017 at 03:19:00PM -0700, Nadav Amit wrote:
>>>> Yes, of course, since KSM does not batch TLB flushes. I regarded =
the other
>>>> direction - first try_to_unmap() removes the PTE (but still does =
not flush),
>>>> unlocks the page, and then KSM acquires the page lock and calls
>>>> write_protect_page(). It finds out the PTE is not present and does =
not flush
>>>> the TLB.
>>>=20
>>> When KSM acquires the page lock, it then acquires the PTL where the
>>> cleared PTE is observed directly and skipped.
>>=20
>> I don???t see why. Let???s try again - CPU0 reclaims while CPU1 =
deduplicates:
>>=20
>> CPU0				CPU1
>> ----				----
>> shrink_page_list()
>>=20
>> =3D> try_to_unmap()
>> =3D=3D> try_to_unmap_one()
>> [ unmaps from some page-tables ]
>>=20
>> [ try_to_unmap returns false;
>>  page not reclaimed ]
>>=20
>> =3D> keep_locked: unlock_page()
>>=20
>> [ TLB flush deferred ]
>> 				try_to_merge_one_page()
>> 				=3D> trylock_page()
>> 				=3D> write_protect_page()
>> 				=3D=3D> acquire ptl
>> 				  [ PTE non-present ???> no PTE change
>> 				    and no flush ]
>> 				=3D=3D> release ptl
>> 				=3D=3D> replace_page()
>>=20
>>=20
>> At this point, while replace_page() is running, CPU0 may still not =
have
>> flushed the TLBs. Another CPU (CPU2) may hold a stale PTE, which is =
not
>> write-protected. It can therefore write to that page while =
replace_page() is
>> running, resulting in memory corruption.
>>=20
>> No?
>=20
> KSM is not my strong point so it's reaching the point where others =
more
> familiar with that code need to be involved.

Do not assume for a second that I really know what is going on over =
there.

> If try_to_unmap returns false on CPU0 then at least one unmap attempt
> failed and the page is not reclaimed.

Actually, try_to_unmap() may even return true, and the page would still =
not
be reclaimed - for example if page_has_private() and freeing the buffers
fails. In this case, the page would be unlocked as well.

> For those that were unmapped, they
> will get flushed in the near future. When KSM operates on CPU1, it'll =
skip
> the unmapped pages under the PTL so stale TLB entries are not relevant =
as
> the mapped entries are still pointing to a valid page and ksm misses a =
merge
> opportunity.

This is the case I regarded, but I do not understand your point. The =
whole
problem is that CPU1 would skip the unmapped pages under the PTL. As it
skips them it does not flush them from the TLB. And as a result,
replace_page() may happen before the TLB is flushed by CPU0.

> If it write protects a page, ksm unconditionally flushes the PTE
> on clearing the PTE so again, there is no stale entry anywhere. For =
CPU2,
> it'll either reference a PTE that was unmapped in which case it'll =
fault
> once CPU0 flushes the TLB and until then it's safe to read and write =
as
> long as the TLB is flushed before the page is freed or IO is initiated =
which
> reclaim already handles.

In my scenario the page is not freed and there is no I/O in the reclaim
path. The TLB flush of CPU0 in my scenario is just deferred while the
page-table lock is not held. As I mentioned before, this time-period can =
be
potentially very long in a virtual machine. CPU2 referenced a PTE that
was unmapped by CPU0 (reclaim path) but not CPU1 (ksm path).

ksm, IIUC, would not expect modifications of the page during =
replace_page.
Eventually it would flush the TLB (after changing the PTE to point to =
the
deduplicated page). But in the meanwhile, another CPU may use stale PTEs =
for
writes, and those writes would be lost after the page is deduplicated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
