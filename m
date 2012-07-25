Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 35B9C6B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 17:14:19 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 25 Jul 2012 17:12:50 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 99875C9001C
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 17:12:45 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6PLChqt404708
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 17:12:44 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6PLCIaq022405
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 15:12:20 -0600
Date: Wed, 25 Jul 2012 14:12:17 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] page-table walkers vs memory order
Message-ID: <20120725211217.GR2378@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1343064870.26034.23.camel@twins>
 <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
 <20120725175628.GH2378@linux.vnet.ibm.com>
 <alpine.LSU.2.00.1207251313180.1942@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207251313180.1942@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 25, 2012 at 01:26:43PM -0700, Hugh Dickins wrote:
> On Wed, 25 Jul 2012, Paul E. McKenney wrote:
> > On Tue, Jul 24, 2012 at 02:51:05PM -0700, Hugh Dickins wrote:
> > > 
> > > I'm totally unclear whether the kernel ever gets built with these
> > > 'creative' compilers that you refer to.  Is ACCESS_ONCE() a warning
> > > of where some future compiler would be permitted to mess with our
> > > assumptions?  Or is it actually saving us already today?  Would we
> > > know?  Could there be a boottime test that would tell us?  Is it
> > > likely that a future compiler would have an "--access_once"
> > > option that the kernel build would want to turn on?
> > 
> > The problem is that, unless you tell it otherwise, the compiler is
> > permitted to assume that the code that it is generating is the only thing
> > active in that address space at that time.  So the compiler might know
> > that it already has a perfectly good copy of that value somewhere in
> > its registers, or it might decide to fetch the value twice rather than
> > once due to register pressure, either of which can be fatal in SMP code.
> > And then there are more aggressive optimizations as well.
> > 
> > ACCESS_ONCE() is a way of telling the compiler to access the value
> > once, regardless of what cute single-threaded optimizations that it
> > otherwise might want to apply.
> 
> Right, but you say "might": I have never heard it asserted, that we do
> build the kernel with a compiler which actually makes such optimizations.

The compiler we use today can and has hurt us with double-fetching
and old-value-reuse optimizations.  There have been several that have
"optimized" things like "while (foo)" into "tmp = foo; while (tmp)"
in the Linux kernel, which have been dealt with by recoding.

You might argue that the compiler cannot reasonably apply such an
optimization in some given case, but the compiler does much more detailed
analysis of the code than most people are willing to do (certainly more
than I am usually willing to do!), so I believe that a little paranoia is
quite worthwhile.

> There's a lot of other surprising things which a compiler is permitted
> to do, but we would simply not use such a compiler to build the kernel.

Unless we get the gcc folks to build and boot the Linux kernel as part
of their test suite (maybe they already do, but not that I know of),
how would either they or we know that they had deployed a destructive
optimization?

> Does some version of gcc, under the options which we insist upon,
> make such optimizations on any of the architectures which we support?

Pretty much any production-quality compiler will do double-fetch
and old-value-reuse optimizations, the former especially on 32-bit
x86.  I don't know of any production-quality compilers that do value
speculation, which would make the compiler act like DEC Alpha hardware,
and I would hope that if this does appear, (1) we would have warning
and (2) it could be turned off.  But there has been a lot of work on
this topic, so we would be foolish to rule it out.

But the currently deployed optimizations can already cause enough trouble.

> Or is there some other compiler in use on the kernel, which makes
> such optimizations?  It seems a long time since I heard of building
> the kernel with icc.  clang?
> 
> I don't mind the answer "Yes, you idiot" - preferably with an example
> or two of which compiler and which piece of code it has bitten us on.
> I don't mind the answer "We just don't know" if that's the case.
> 
> But I'd like a better idea of how much to worry: is ACCESS_ONCE
> demonstrably needed today, or rather future-proofing and documentation?

Both.  If you are coding "while (foo)" where "foo" can be changed by an
interrupt handler, you had better instead write "while (ACCESS_ONCE(foo))"
or something similar, because most compilers are happy to optimize your
loop into an infinite loop in that case.  There are places in the Linux
kernel that would have problems if the compiler decided to refetch a
value -- if a pointer was changed in the meantime, part of your code
might be working on the old structure, and part on the new structure.
This really can happen today, and this is why rcu_dereference() contains
an ACCESS_ONCE().

If you are making lockless non-atomic access to a variable, I strongly
suggest ACCESS_ONCE() or something similar even if you cannot see how
the compiler can mess you up, especially in cases involving a lot of
inline functions.  In this case, the compiler can be looking at quite
a bit of code and optimizing across the entire mess.

/me wonders what he stepped into with this email thread.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
