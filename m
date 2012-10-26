Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 952176B0073
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 12:47:49 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id hm4so488516wib.8
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 09:47:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121026141430.GA12158@gmail.com>
References: <20121025121617.617683848@chello.nl> <20121025124834.467791319@chello.nl>
 <CA+55aFwJdn8Kz9UByuRfGNtf9Hkv-=8xB+WRd47uHZU1YMagZw@mail.gmail.com>
 <20121026071532.GC8141@gmail.com> <20121026135024.GA11640@gmail.com>
 <1351260672.16863.81.camel@twins> <20121026141430.GA12158@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 26 Oct 2012 09:47:27 -0700
Message-ID: <CA+55aFw6b7_Wu7q5dACfpxDHQ_ejyK6aesAjNKrtG=o6C0+EyA@mail.gmail.com>
Subject: Re: [PATCH 26/31] sched, numa, mm: Add fault driven placement and
 migration policy
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Oct 26, 2012 at 7:14 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>>
>> Shouldn't the pte_lock serialize all that still? All sites
>> that modify PTE contents should hold the pte_lock (and do
>> afaict).
>
> Hm, indeed.
>
> Is there no code under down_read() (in the page fault path) that
> modifies the pte via just pure atomics?

Well, the ptep_set_access_flags() thing modifies the pte under
down_read(). Not using atomics, though. If it races with itself or
with a hardware page walk, that's fine, but if it races with something
changing other bits than A/D, that would be horribly horribly bad - it
could undo any other bit changes exactly because it's a unlocked
read-do-other-things-write sequence.

But it's always run under the page table lock - as should all other SW
page table modifications - so it *should* be fine. The down_read() is
for protecting other VM data structures (notably the vma lists etc),
not the page table bit-twiddling.

In fact, the whole SW page table modification scheme *depends* on the
page table lock, because the ptep_modify_prot_start/commit thing does
a "atomically clear the page table pointer to protect against hardware
walkers". And if another software walker were to see that cleared
state, it would do bad things (the exception, as usual, is the GUP
code, which does the optimistic unlocked accesses and conceptually
emulates a hardware page table walk)

So I really think that the mmap_sem should be entirely a non-issue for
this kind of code.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
