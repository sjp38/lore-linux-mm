Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 8F1BB6B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 22:37:02 -0400 (EDT)
Received: by mail-ve0-f180.google.com with SMTP id c13so2218582vea.25
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 19:37:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1304031902370.4709@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
	<alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
	<alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
	<alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
	<20130403041447.GC4611@cmpxchg.org>
	<alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
	<20130403045814.GD4611@cmpxchg.org>
	<CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com>
	<20130403143302.GL1953@cmpxchg.org>
	<alpine.DEB.2.02.1304031648170.718@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1304031659160.718@chino.kir.corp.google.com>
	<CA+55aFwdJCxnNQMQEAaC-+8pEGpHKgaq5aL4K2n=vRVBUg863A@mail.gmail.com>
	<alpine.DEB.2.02.1304031812320.4709@chino.kir.corp.google.com>
	<CA+55aFygozny+00y3hKAwkgg-6AWh0JpmqggmGcbraGrEhOkRg@mail.gmail.com>
	<alpine.DEB.2.02.1304031902370.4709@chino.kir.corp.google.com>
Date: Wed, 3 Apr 2013 19:37:01 -0700
Message-ID: <CA+55aFxUxL-Lt2UUCwvgZxYNSA182TdhxC3RdHss00wOb8_LqA@mail.gmail.com>
Subject: Re: [patch] compiler: clarify ACCESS_ONCE() relies on compiler implementation
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>

On Wed, Apr 3, 2013 at 7:18 PM, David Rientjes <rientjes@google.com> wrote:
>
> Would you convert the definition of ACCESS_ONCE() to use the resulting
> feature from the gcc folks that would actually guarantee it in the
> compiler-gcc.h files?

So I wouldn't object for any other reason than the fact that it makes
me feel like I'm helping somebody screw up "volatile", and then we
would help cover up that serious compiler quality regression.

So I do repeat: what kind of messed-up compiler could *possibly* do
the wrong thing for our current use of accessing a volatile pointer,
and not consider that a compiler bug? Why should be support such a
fundamentally broken agenda?

Yes, yes, I know all about how compiler people will talk about "access
to volatile pointer" vs "actual volatile *object*", as if that made
things fundamentally different. I personally don't think it makes any
difference what-so-ever, and a quality compiler shouldn't either. Yes,
the compiler can get confused about aliasing, but hey, if it doesn't
keep track of the volatile status of some pointer access, then it's
going to get confused about aliasing elsewhere when it passes down
pointer to an actual volatile object in a union or whatever. So a good
C compiler really wants to get that kind of thing right *anyway*.

IOW, I'm not seeing a huge upside, and I *am* seeing downsides.  Why
should we encourage bad C implementations? If the compiler people
understand that threading (as well as just IO accesses) do actually
need the whole "access once" semantics, and have support for that in
their compiler anyway, why aren't they just turning "volatile" into
that?

IOW, my argument is that a *good* C compiler writer would acknowledge that:

  "Yes, the language specs may allow me to quibble about what the
meaning of the word "object" is, but I also realize that people who do
threading and IO accesses need a way to specify "access once" through
a pointer without any regard to what the "underlying object" -
whatever that is - is, so I might as well interpret the meaning of
"object" to include the known needed semantics of access through a
pointer, and turn it into this internal interface that I have to
expose *anyway*".

So instead of encouraging people to rely on some strange
compiler-dependent crap, why not just admit that the C standard
*could* also be read the way the language was clearly meant to be
read, without any stupid quibbling? And instead of the
compiler-specific thing, say "Our compiler is a *good* compiler, and
we took the C standard language and read it in the most useful way
possible, and made our compiler *better*".

IOW, instead of going down the whole idiotic language-lawyer dead end,
just DTRT. What is the advantage to *anybody* - C compiler writers
included - in making "volatile" less useful, and blathering about bad
specifications.

This is my "quality of implementation" argument. A C compiler
shouldn't try to screw over its users. If there is some undefined
corner-case, try to define it as usefully as possible. And for
"volatile pointer accesses", there really are clear and unambiguous
good and useful interpretations, which just say "we consider the
volatile pointer access to be a volatile object, and we won't be
quibbling and trying to argue about the meaning of "object"".

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
