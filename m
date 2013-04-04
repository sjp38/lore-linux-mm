Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 567676B00A2
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 02:02:23 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so1032321pdj.20
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 23:02:22 -0700 (PDT)
Date: Wed, 3 Apr 2013 23:02:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] compiler: clarify ACCESS_ONCE() relies on compiler
 implementation
In-Reply-To: <CA+55aFxUxL-Lt2UUCwvgZxYNSA182TdhxC3RdHss00wOb8_LqA@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1304032127070.32444@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com> <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com> <alpine.LNX.2.00.1304021600420.22412@eggly.anvils> <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403041447.GC4611@cmpxchg.org> <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com> <20130403045814.GD4611@cmpxchg.org> <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com> <20130403143302.GL1953@cmpxchg.org>
 <alpine.DEB.2.02.1304031648170.718@chino.kir.corp.google.com> <alpine.DEB.2.02.1304031659160.718@chino.kir.corp.google.com> <CA+55aFwdJCxnNQMQEAaC-+8pEGpHKgaq5aL4K2n=vRVBUg863A@mail.gmail.com> <alpine.DEB.2.02.1304031812320.4709@chino.kir.corp.google.com>
 <CA+55aFygozny+00y3hKAwkgg-6AWh0JpmqggmGcbraGrEhOkRg@mail.gmail.com> <alpine.DEB.2.02.1304031902370.4709@chino.kir.corp.google.com> <CA+55aFxUxL-Lt2UUCwvgZxYNSA182TdhxC3RdHss00wOb8_LqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>

On Wed, 3 Apr 2013, Linus Torvalds wrote:

> > Would you convert the definition of ACCESS_ONCE() to use the resulting
> > feature from the gcc folks that would actually guarantee it in the
> > compiler-gcc.h files?
> 
> So I wouldn't object for any other reason than the fact that it makes
> me feel like I'm helping somebody screw up "volatile", and then we
> would help cover up that serious compiler quality regression.
> 

I'm surprised you would object to using a new builtin with well-defined 
semantics that would actually specify what ACCESS_ONCE() wants to do.  
Owell, it seems this is becoming philosophical.

> So I do repeat: what kind of messed-up compiler could *possibly* do
> the wrong thing for our current use of accessing a volatile pointer,
> and not consider that a compiler bug? Why should be support such a
> fundamentally broken agenda?
> 

This is tangential to the issue of trying to clarify the ACCESS_ONCE() 
comment, as that discussion was tangential to the patch actually being 
discussed at the time.  You answered it yourself, though, when talking 
about the difference between dereferencing a volatile pointer and 
accessing a volatile object.  You hate the quibbling, but are asking for a 
quibble.

	unsigned long local_foo = ACCESS_ONCE(foo);
	unsigned long local_bar = ACCESS_ONCE(bar);

I believe a "sane" compiler can load bar before foo and not be a bug, and 
this is allowed from the C99 perspective since we're not talking about an 
access of a volatile object, thus no side effect.  This is the quibbling 
neither of us want to get involved in, so why discuss it?

The comment of ACCESS_ONCE() says "the compiler is also forbidden from 
reordering successive instances of ACCESS_ONCE(), but only when the 
compiler is aware of some particular ordering.  One way to make the 
compiler aware of ordering is to put the two invocations of ACCESS_ONCE() 
in different C statements."

That example is successive instances of ACCESS_ONCE() and in different C 
statements, but the compiler is not forbidden to reorder them.  Does 
anyone in the kernel do this and actually think it provides a cheap memory 
barrier?  Doubt it, but it's not a compiler bug to reorder them.

> IOW, I'm not seeing a huge upside, and I *am* seeing downsides.  Why
> should we encourage bad C implementations? If the compiler people
> understand that threading (as well as just IO accesses) do actually
> need the whole "access once" semantics, and have support for that in
> their compiler anyway, why aren't they just turning "volatile" into
> that?
> 

Nobody is encouraging gcc or any other compiler to change the semantics 
and I highly doubt anything ever would, even if we do adopt a gcc builtin.  
But I do believe, if nothing more, that it would clear up this confusion 
around the volatile in ACCESS_ONCE()'s definition.  If you'd like to do 
that with a comment instead, that'd be great.  I proposed such a comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
