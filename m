Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C02F6B0292
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 21:19:27 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y129so12156644pgy.1
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 18:19:27 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id x13si3751428pgq.222.2017.07.21.18.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 18:19:25 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id c23so5889634pfe.5
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 18:19:25 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170720074342.otez35bme5gytnxl@suse.de>
Date: Fri, 21 Jul 2017 18:19:22 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com>
References: <20170715155518.ok2q62efc2vurqk5@suse.de>
 <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
 <20170719074131.75wexoal3fiyoxw5@suse.de>
 <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
 <20170719195820.drtfmweuhdc4eca6@suse.de>
 <4BD983A1-724B-4FD7-B502-55351717BC5F@gmail.com>
 <20170719214708.wuzq3di6rt43txtn@suse.de>
 <3D1386AD-7875-40B9-8C6F-DE02CF8A45A1@gmail.com>
 <20170719225950.wfpfzpc6llwlyxdo@suse.de>
 <4DC97890-9FFA-4BA4-B300-B679BAB2136D@gmail.com>
 <20170720074342.otez35bme5gytnxl@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Jul 19, 2017 at 04:39:07PM -0700, Nadav Amit wrote:
>>> If try_to_unmap returns false on CPU0 then at least one unmap =
attempt
>>> failed and the page is not reclaimed.
>>=20
>> Actually, try_to_unmap() may even return true, and the page would =
still not
>> be reclaimed - for example if page_has_private() and freeing the =
buffers
>> fails. In this case, the page would be unlocked as well.
>=20
> I'm not seeing the relevance from the perspective of a stale TLB being
> used to corrupt memory or access the wrong data.
>=20
>>> For those that were unmapped, they
>>> will get flushed in the near future. When KSM operates on CPU1, =
it'll skip
>>> the unmapped pages under the PTL so stale TLB entries are not =
relevant as
>>> the mapped entries are still pointing to a valid page and ksm misses =
a merge
>>> opportunity.
>>=20
>> This is the case I regarded, but I do not understand your point. The =
whole
>> problem is that CPU1 would skip the unmapped pages under the PTL. As =
it
>> skips them it does not flush them from the TLB. And as a result,
>> replace_page() may happen before the TLB is flushed by CPU0.
>=20
> At the time of the unlock_page on the reclaim side, any unmapping that
> will happen before the flush has taken place. If KSM starts between =
the
> unlock_page and the tlb flush then it'll skip any of the PTEs that =
were
> previously unmapped with stale entries so there is no relevant stale =
TLB
> entry to work with.

I don=E2=80=99t see where this skipping happens, but let=E2=80=99s put =
this scenario aside
for a second. Here is a similar scenario that causes memory corruption. =
I
actually created and tested it (although I needed to hack the kernel to =
add
some artificial latency before the actual flushes and before the actual
dedupliaction of KSM).

We are going to cause KSM to deduplicate a page, and after page =
comparison
but before the page is actually replaced, to use a stale PTE entry to=20
overwrite the page. As a result KSM will lose a write, causing memory
corruption.

For this race we need 4 CPUs:

CPU0: Caches a writable and dirty PTE entry, and uses the stale value =
for
write later.

CPU1: Runs madvise_free on the range that includes the PTE. It would =
clear
the dirty-bit. It batches TLB flushes.

CPU2: Writes 4 to /proc/PID/clear_refs , clearing the PTEs soft-dirty. =
We
care about the fact that it clears the PTE write-bit, and of course, =
batches
TLB flushes.

CPU3: Runs KSM. Our purpose is to pass the following test in
write_protect_page():

	if (pte_write(*pvmw.pte) || pte_dirty(*pvmw.pte) ||
	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte)))

Since it will avoid TLB flush. And we want to do it while the PTE is =
stale.
Later, and before replacing the page, we would be able to change the =
page.

Note that all the operations the CPU1-3 perform canhappen in parallel =
since
they only acquire mmap_sem for read.

We start with two identical pages. Everything below regards the same
page/PTE.

CPU0		CPU1		CPU2		CPU3
----		----		----		----
Write the same
value on page

[cache PTE as
 dirty in TLB]

		MADV_FREE
		pte_mkclean()
						=09
				4 > clear_refs
				pte_wrprotect()

						write_protect_page()
						[ success, no flush ]

						pages_indentical()
						[ ok ]

Write to page
different value

[Ok, using stale
 PTE]

						replace_page()


Later, CPU1, CPU2 and CPU3 would flush the TLB, but that is too late. =
CPU0
already wrote on the page, but KSM ignored this write, and it got lost.

Now to reiterate my point: It is really hard to get TLB batching right
without some clear policy. And it should be important, since such issues =
can
cause memory corruption and have security implications (if somebody =
manages
to get the timing right).

Regards,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
