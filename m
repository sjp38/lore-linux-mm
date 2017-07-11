Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A05A66810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 18:27:58 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u5so6026579pgq.14
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:27:58 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id h9si419604pln.160.2017.07.11.15.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 15:27:57 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id y129so621953pgy.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:27:57 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170711215240.tdpmwmgwcuerjj3o@suse.de>
Date: Tue, 11 Jul 2017 15:27:55 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
References: <20170711064149.bg63nvi54ycynxw4@suse.de>
 <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Jul 11, 2017 at 09:09:23PM +0100, Mel Gorman wrote:
>> On Tue, Jul 11, 2017 at 08:18:23PM +0100, Mel Gorman wrote:
>>> I don't think we should be particularly clever about this and =
instead just
>>> flush the full mm if there is a risk of a parallel batching of =
flushing is
>>> in progress resulting in a stale TLB entry being used. I think =
tracking mms
>>> that are currently batching would end up being costly in terms of =
memory,
>>> fairly complex, or both. Something like this?
>>=20
>> mremap and madvise(DONTNEED) would also need to flush. Memory =
policies are
>> fine as a move_pages call that hits the race will simply fail to =
migrate
>> a page that is being freed and once migration starts, it'll be =
flushed so
>> a stale access has no further risk. copy_page_range should also be ok =
as
>> the old mm is flushed and the new mm cannot have entries yet.
>=20
> Adding those results in

You are way too fast for me.

> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -637,12 +637,34 @@ static bool should_defer_flush(struct mm_struct =
*mm, enum ttu_flags flags)
> 		return false;
>=20
> 	/* If remote CPUs need to be flushed then defer batch the flush =
*/
> -	if (cpumask_any_but(mm_cpumask(mm), get_cpu()) < nr_cpu_ids)
> +	if (cpumask_any_but(mm_cpumask(mm), get_cpu()) < nr_cpu_ids) {
> 		should_defer =3D true;
> +		mm->tlb_flush_batched =3D true;
> +	}

Since mm->tlb_flush_batched is set before the PTE is actually cleared, =
it
still seems to leave a short window for a race.

CPU0				CPU1
---- 				----
should_defer_flush
=3D> mm->tlb_flush_batched=3Dtrue	=09
				flush_tlb_batched_pending (another PT)
				=3D> flush TLB
				=3D> mm->tlb_flush_batched=3Dfalse
ptep_get_and_clear
...

				flush_tlb_batched_pending (batched PT)
				use the stale PTE
...
try_to_unmap_flush


IOW it seems that mm->flush_flush_batched should be set after the PTE is
cleared (and have some compiler barrier to be on the safe side).

Just to clarify - I don=E2=80=99t try to annoy, but I considered =
building and
submitting a patch based on some artifacts of a study I conducted, and =
this
issue drove me crazy.

One more question, please: how does elevated page count or even locking =
the
page help (as you mention in regard to uprobes and ksm)? Yes, the page =
will
not be reclaimed, but IIUC try_to_unmap is called before the reference =
count
is frozen, and the page lock is dropped on each iteration of the loop in
shrink_page_list. In this case, it seems to me that uprobes or ksm may =
still
not flush the TLB.

Thanks,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
