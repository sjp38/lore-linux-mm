Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D46646B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 10:23:59 -0400 (EDT)
Received: by mail-vb0-f43.google.com with SMTP id q12so1351699vbe.30
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 07:23:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1304032127070.32444@chino.kir.corp.google.com>
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
	<CA+55aFxUxL-Lt2UUCwvgZxYNSA182TdhxC3RdHss00wOb8_LqA@mail.gmail.com>
	<alpine.DEB.2.02.1304032127070.32444@chino.kir.corp.google.com>
Date: Thu, 4 Apr 2013 07:23:58 -0700
Message-ID: <CA+55aFw_krUFFpocLOcvuANODoCJiF=QSUQeED9Xa_fLt3Gv1w@mail.gmail.com>
Subject: Re: [patch] compiler: clarify ACCESS_ONCE() relies on compiler implementation
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>

On Wed, Apr 3, 2013 at 11:02 PM, David Rientjes <rientjes@google.com> wrote:
>
> I'm surprised you would object to using a new builtin with well-defined
> semantics that would actually specify what ACCESS_ONCE() wants to do.

Why? We'd still have to have the volatile for old compilers, so it's
actually adding unnecessary code. It would be gcc-only, so we'd have
to protect it for other compilers too.

And it wouldn't add any advantage, since "volatile" would still work
for any quality compiler. So why do it?

If it was some *standard* feature that was specified by a real
standards body, and likely to become real in a few years, then that in
itself might be an argument. But as long as it's some random gcc
built-in that just does the same thing as a volatile access, what's
the upside? Seriously?

>         unsigned long local_foo = ACCESS_ONCE(foo);
>         unsigned long local_bar = ACCESS_ONCE(bar);
>
> I believe a "sane" compiler can load bar before foo and not be a bug,

That's bullshit. The whole definition of volatile is about being
visible as an access in the virtual machine, and having externally
visible side effects. Two volatiles cannot be re-ordered wrt each
other, and arguably with the traditional explanation for what it's all
about, you can't even re-order them wrt global memory accesses.

In fact, one sane semantic for what "volatile" means from a compiler
standpoint is to say that a volatile access aliases with all other
accesses (including other accesses to the same thing). That's one of
the saner approaches for compilers to handle volatile, since a C
compiler wants to have a notion of aliasing anyway (and C also has the
notion of type-based aliasing in general).

So no, a "sane" compiler cannot reorder the two.

An insane one could, but it is clearly against the spirit of what
"volatile" means. I believe it's against the letter too, but as
mentioned, compiler people love to quibble about what the meaning of
"is" is.

> The comment of ACCESS_ONCE() says "the compiler is also forbidden from
> reordering successive instances of ACCESS_ONCE(), but only when the
> compiler is aware of some particular ordering.  One way to make the
> compiler aware of ordering is to put the two invocations of ACCESS_ONCE()
> in different C statements."

Correct. That's the whole "sequence point thing". If there's a
sequence point in between (and if they are in separate C statements,
there is) a sane compiler cannot re-order them.

The comment is correct, you are just confused.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
