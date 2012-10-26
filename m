Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 1E82C6B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 22:57:10 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id hm4so7593wib.8
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 19:57:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5089F5B5.1050206@redhat.com>
References: <20121025121617.617683848@chello.nl> <20121025124832.840241082@chello.nl>
 <CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com> <5089F5B5.1050206@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 25 Oct 2012 19:56:48 -0700
Message-ID: <CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com>
Subject: Re: [PATCH 05/31] x86/mm: Reduce tlb flushes from ptep_set_access_flags()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 7:30 PM, Rik van Riel <riel@redhat.com> wrote:
>>
>> LOOK at the code, for chrissake. Just look at it. And if you don't see
>> why the above is stupid and retarded, you damn well shouldn't be
>> touching VM code.
>
> I agree it is pretty ugly.  However, the above patch
> did get rid of a gigantic performance regression with
> Peter's code.

Rik, *LOOK* at the code like I asked you to, instead of making excuses for it.

I'm not necessarily arguing with what the code tries to do. I'm
arguing with the fact that the code is pure and utter *garbage*.

It has two major (and I mean *MAJOR*) problems, both of which
individually should make you ashamed for ever posting that piece of
shit:

The obvious-without-even-understanding-semantics problem:

 - it's humongously stupidly written. It calculates that
'flush_remote' flag WHETHER IT GETS USED OR NOT.

   Christ. I can kind of expect stuff like that in driver code etc,
but in VM routines?

   Yes, the compiler may be smart enough to actually fix up the
idiocy. That doesn't make it less stupid.

The more-subtle-but-fundamental-problem:

 - regardless of how stupidly written it is on a very superficial
level, it's even more stupid in a much more fundamental way.

   That whole routine is explicitly written to be opportunistic. It is
*documented* to only set the access flags, so comparing anything else
is stupid, wouldn't you say?

Documented where? It's actually explicitly documented in the
pgtable-generic.c file which has the generic implementation of that
thing. But it's implicitly documented both in the name of the function
(do take another look) *and* in the actual implementation of the
function.

Look at the code: it doesn't even always update the page tables AT ALL
(and no, the return value does *not* reflect whether it updated it or
not!)

Also, notice how we update the pte entry with a simple

    *ptep = entry;

statement, not with the usual expensive page table updates? The only
thing that makes this safe is that we *only* do it with the exact same
page frame number (anything else would be disastrously buggy on 32-bit
PAE, for example). And we only ever do it with the dirty bit always
set, because otherwise we might be silently dropping a concurrent
hardware update of the dirty bit of the previous pte value on another
CPU.

The latter requirement is why the x86 code does

    if (changed && dirty) {

while the generic code checks just "If (changed)" (and then uses the
much more expensive set_pte_at() that has the proper dirty-bit
guarantees, and generates atomic accesses, not to mention various
virtualization crap).

In other words, everything that was added by that patch is PURE AND
UTTER SHIT. And THAT is what I'm objecting to.

Guess what? If you want to optimize the function to not do remote TLB
flushes, then just do that! None of the garbage. Just change the

    flush_tlb_page(vma, address);

line to

    __flush_tlb_one(address);

and it should damn well work. Because everything I see about
"flush_remote" looks just wrong, wrong, wrong.

And if there really is some reason for that whole flush_remote
braindamage, then we have much bigger problems, namely the fact that
we've broken the documented semantics of that function, and we're
doing various other things that are completely and utterly invalid
unless the above semantics hold.

So that patch should be burned, and possibly used as an example of
horribly crappy code for later generations. At no point should it be
applied.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
