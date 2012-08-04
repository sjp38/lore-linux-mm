Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 746476B0044
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 18:04:35 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 4 Aug 2012 16:04:34 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id DF56B3E40040
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 22:03:31 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q74M320g050168
	for <linux-mm@kvack.org>; Sat, 4 Aug 2012 16:03:17 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q74M2kPS007394
	for <linux-mm@kvack.org>; Sat, 4 Aug 2012 16:02:47 -0600
Date: Sat, 4 Aug 2012 15:02:45 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] page-table walkers vs memory order
Message-ID: <20120804220245.GB3307@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1343064870.26034.23.camel@twins>
 <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
 <20120804143719.GB10459@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120804143719.GB10459@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Sat, Aug 04, 2012 at 04:37:19PM +0200, Andrea Arcangeli wrote:
> On Tue, Jul 24, 2012 at 02:51:05PM -0700, Hugh Dickins wrote:
> > Since then, I think THP has made the rules more complicated; but I
> > believe Andrea paid a great deal of attention to that kind of issue.
> 
> There were many issues, one unexpected was
> 1a5a9906d4e8d1976b701f889d8f35d54b928f25.

[ . . . ]

> 5) compiler behaving like alpha -> impossible (I may be wrong but I
>    believe so after thinking more on it)
> 
> 6) I was told a decade ago by Honza to never touch any ram that can
>    change under the compiler unless it's declared volatile (could
>    crash over switch/case statement implemented with a table if the
>    switch/case value is re-read by the compiler).  -> depends, we
>    don't always obey to this rule, clearly gup_fast currently disobeys
>    and even the generic pmd_read_atomic still disobeys (MADV_DONTNEED
>    can zero the pmd). If there's no "switch/case" I'm not aware of
>    other troubles.
> 
> 7) barrier in pmd_none_or_trans_huge_or_clear_bad -> possible, same
>    issue as 2, full explanation in git show 1a5a9906d4e8d1976b701f
> 
> Note: here I'm ignoring CPU reordering, this is only about the compiler.
> 
> 5 is impossible because:
> 
> a) the compiler can't read a guessed address or it can crash the
>    kernel
> 
> b) the compiler has no memory to store a "guessed" valid address when
>    the function return and the stack is unwind
> 
> For the compiler to behave like alpha, the compiler should read the
> pteval before the pmdp, that it can't do, because it has no address to
> guess from and it would Oops if it really tries to guess it!
> 
> So far it was said "compiler can guess the address" but there was no
> valid explanation of how it could do it, and I don't see it, so please
> explain if I'm wrong about the a, b above.

OK, I'll bite.  ;-)

The most sane way for this to happen is with feedback-driven techniques
involving profiling, similar to what is done for basic-block reordering
or branch prediction.  The idea is that you compile the kernel in an
as-yet (and thankfully) mythical pointer-profiling mode, which records
the values of pointer loads and also measures the pointer-load latency.
If a situation is found where a given pointer almost always has the
same value but has high load latency (for example, is almost always a
high-latency cache miss), this fact is recorded and fed back into a
subsequent kernel build.  This subsequent kernel build might choose to
speculate the value of the pointer concurrently with the pointer load.

And of course, when interpreting the phrase "most sane way" at the
beginning of the prior paragraph, it would probably be wise to keep
in mind who wrote it.  And that "most sane way" might have little or
no resemblance to anything that typical kernel hackers would consider
anywhere near sanity.  ;-)

> Furthermore the ACCESS_ONCE that Peter's patch added to gup_fast
> pud/pgd can't prevent the compiler to read a guessed pmdp address as a
> volatile variable, before reading the pmdp pointer and compare it with
> the guessed address! So if it's 5 you worry about, when adding
> ACCESS_ONCE in pudp/pgdp/pmdp is useless and won't fix it. You should
> have added a barrier() instead.

Most compiler writers I have discussed this with agreed that a volatile
cast would suppress value speculation.  The "volatile" keyword is not
all that well specified in the C and C++ standards, but as "nix" said
at http://lwn.net/Articles/509731/:

	volatile's meaning as 'minimize optimizations applied to things
	manipulating anything of volatile type, do not duplicate, elide,
	move, fold, spindle or mutilate' is of long standing.

That said, value speculation as a compiler optimization makes me a bit
nervous, so my current feeling is that is should be suppressed entirely.

Hey, you asked, even if only implicitly!  ;-)

							Thanx, Paul

> > I suspect your arch/x86/mm/gup.c ACCESS_ONCE()s are necessary:
> > gup_fast() breaks as many rules as it can, and in particular may
> > be racing with the freeing of page tables; but I'm not so sure
> > about the pagewalk mods - we could say "cannot do any harm",
> > but I don't like adding lines on that basis.
> 
> I agree to add ACCESS_ONCE but because it's case 2, 7 above and it
> could race with free_pgtables of pgd/pud/pmd or MADV_DONTNEED with
> pmd.
> 
> The other part of the patch in pagewalk.c is superflous and should be
> dropped: pud/pgd can't change in walk_page_table, it's required to
> hold the mmap_sem at least in read mode (it's not disabling irqs).
> 
> The pmd side instead can change but only with THP enabled, and only
> because MADV_DONTNEED (never because of free_pgtables) but it's
> already fully handled through pmd_none_or_trans_huge_or_clear_bad. The
> ->pmd_entry callers are required to call pmd_trans_unstable() before
> proceeding as the pmd may have been zeroed out by the time we get
> there. The solution is zero barrier()/ACCESS_ONCE impact for THP=n. If
> there are smp_read_barrier_depends already in alpha pte methods we're
> fine.
> 
> Sorry for the long email but without a list that separates all
> possible cases above, I don't think we can understand what we're
> fixing in that patch and why the gup.c part is good.
> 
> Peter, I suggest to resend the fix with a more detailed explanataion
> of the 2, 7 kind of race for gup.c only and drop the pagewalk.c.
> 
> Thanks,
> Andrea
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
