Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id C71246B006E
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 19:06:42 -0400 (EDT)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 4 Aug 2012 19:06:40 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 5E080C90042
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 19:06:08 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q74N67jG109038
	for <linux-mm@kvack.org>; Sat, 4 Aug 2012 19:06:07 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q74N677F010235
	for <linux-mm@kvack.org>; Sat, 4 Aug 2012 17:06:07 -0600
Date: Sat, 4 Aug 2012 16:06:05 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] page-table walkers vs memory order
Message-ID: <20120804230605.GJ3307@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1343064870.26034.23.camel@twins>
 <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
 <20120804143719.GB10459@redhat.com>
 <20120804220245.GB3307@linux.vnet.ibm.com>
 <20120804224705.GD10459@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120804224705.GD10459@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Sun, Aug 05, 2012 at 12:47:05AM +0200, Andrea Arcangeli wrote:
> On Sat, Aug 04, 2012 at 03:02:45PM -0700, Paul E. McKenney wrote:
> > OK, I'll bite.  ;-)
> 
> :))
> 
> > The most sane way for this to happen is with feedback-driven techniques
> > involving profiling, similar to what is done for basic-block reordering
> > or branch prediction.  The idea is that you compile the kernel in an
> > as-yet (and thankfully) mythical pointer-profiling mode, which records
> > the values of pointer loads and also measures the pointer-load latency.
> > If a situation is found where a given pointer almost always has the
> > same value but has high load latency (for example, is almost always a
> > high-latency cache miss), this fact is recorded and fed back into a
> > subsequent kernel build.  This subsequent kernel build might choose to
> > speculate the value of the pointer concurrently with the pointer load.
> > 
> > And of course, when interpreting the phrase "most sane way" at the
> > beginning of the prior paragraph, it would probably be wise to keep
> > in mind who wrote it.  And that "most sane way" might have little or
> > no resemblance to anything that typical kernel hackers would consider
> > anywhere near sanity.  ;-)
> 
> I see. The above scenario is sure fair enough assumption. We're
> clearly stretching the constraints to see what is theoretically
> possible and this is a very clear explanation of how gcc could have an
> hardcoded "guessed" address in the .text.
> 
> Next step to clearify now, is how gcc can safely dereference such a
> "guessed" address without the kernel knowing about it.
> 
> If gcc would really dereference a guessed address coming from a
> profiling run without kernel being aware of it, it would eventually
> crash the kernel with an oops. gcc cannot know what another CPU will
> do with the kernel pagetables. It'd be perfectly legitimate to
> temporarily move the data at the "guessed address" to another page and
> to update the pointer through stop_cpu during some weird "cpu
> offlining scenario" or anything you can imagine. I mean gcc must
> behave in all cases so it's not allowed to deference the guessed
> address at any given time.
> 
> The only way gcc could do the alpha thing and dereference the guessed
> address before the real pointer, is with cooperation with the kernel.
> The kernel should provide gcc "safe ranges" that won't crash the
> kernel, and/or gcc could provide a .fixup section similar to the
> current .fixup and the kernel should look it up during the page fault
> handler in case the kernel is ok with temporarily getting faults in
> that range. And in turn it can't happen unless we explicitly decide to
> allow gcc to do it.

And these are indeed some good reasons why I am not a fan of pointer-value
speculation.  ;-)

> > > Furthermore the ACCESS_ONCE that Peter's patch added to gup_fast
> > > pud/pgd can't prevent the compiler to read a guessed pmdp address as a
> > > volatile variable, before reading the pmdp pointer and compare it with
> > > the guessed address! So if it's 5 you worry about, when adding
> > > ACCESS_ONCE in pudp/pgdp/pmdp is useless and won't fix it. You should
> > > have added a barrier() instead.
> > 
> > Most compiler writers I have discussed this with agreed that a volatile
> > cast would suppress value speculation.  The "volatile" keyword is not
> > all that well specified in the C and C++ standards, but as "nix" said
> > at http://lwn.net/Articles/509731/:
> > 
> > 	volatile's meaning as 'minimize optimizations applied to things
> > 	manipulating anything of volatile type, do not duplicate, elide,
> > 	move, fold, spindle or mutilate' is of long standing.
> 
> Ok, so if the above optimization would be possible, volatile would
> stop it too, thanks for the quote and the explanation.
> 
> On a side note I believe there's a few barrier()s that may be worth
> converting to ACCESS_ONCE, that would take care of case 6) too in
> addition to avoid clobbering more CPU registers than strictly
> necessary. Not very important but a possible microoptimization.

Agreed on both points.

> > That said, value speculation as a compiler optimization makes me a bit
> > nervous, so my current feeling is that is should be suppressed entirely.
> > 
> > Hey, you asked, even if only implicitly!  ;-)
> 
> You're reading my mind! :)

Or succesfully carrying out value speculation on it.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
