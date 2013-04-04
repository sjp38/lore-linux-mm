Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 9AA3F6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 15:40:58 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rp8so1617272pbb.19
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 12:40:57 -0700 (PDT)
Date: Thu, 4 Apr 2013 12:40:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] compiler: clarify ACCESS_ONCE() relies on compiler
 implementation
In-Reply-To: <CA+55aFw_krUFFpocLOcvuANODoCJiF=QSUQeED9Xa_fLt3Gv1w@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1304041209330.19501@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com> <20130403041447.GC4611@cmpxchg.org> <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com> <20130403045814.GD4611@cmpxchg.org>
 <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com> <20130403143302.GL1953@cmpxchg.org> <alpine.DEB.2.02.1304031648170.718@chino.kir.corp.google.com> <alpine.DEB.2.02.1304031659160.718@chino.kir.corp.google.com>
 <CA+55aFwdJCxnNQMQEAaC-+8pEGpHKgaq5aL4K2n=vRVBUg863A@mail.gmail.com> <alpine.DEB.2.02.1304031812320.4709@chino.kir.corp.google.com> <CA+55aFygozny+00y3hKAwkgg-6AWh0JpmqggmGcbraGrEhOkRg@mail.gmail.com> <alpine.DEB.2.02.1304031902370.4709@chino.kir.corp.google.com>
 <CA+55aFxUxL-Lt2UUCwvgZxYNSA182TdhxC3RdHss00wOb8_LqA@mail.gmail.com> <alpine.DEB.2.02.1304032127070.32444@chino.kir.corp.google.com> <CA+55aFw_krUFFpocLOcvuANODoCJiF=QSUQeED9Xa_fLt3Gv1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>

On Thu, 4 Apr 2013, Linus Torvalds wrote:

> > I'm surprised you would object to using a new builtin with well-defined
> > semantics that would actually specify what ACCESS_ONCE() wants to do.
> 
> Why? We'd still have to have the volatile for old compilers, so it's
> actually adding unnecessary code. It would be gcc-only, so we'd have
> to protect it for other compilers too.
> 
> And it wouldn't add any advantage, since "volatile" would still work
> for any quality compiler. So why do it?
> 
> If it was some *standard* feature that was specified by a real
> standards body, and likely to become real in a few years, then that in
> itself might be an argument. But as long as it's some random gcc
> built-in that just does the same thing as a volatile access, what's
> the upside? Seriously?
> 

I said in the previous email that you'd do this solely to rely on a 
well-defined semantic rather than reading paragraphs of comments that 
we're developing.  I personally don't care either way, but I would really 
like to avoid this type of "why can't I use volatile? Go read 
volatile-considered-harmful" and "why can ACCESS_ONCE() use volatile, 
then? Go read this email thread" because the current comment is a bit 
confusing in a few different areas.

> >         unsigned long local_foo = ACCESS_ONCE(foo);
> >         unsigned long local_bar = ACCESS_ONCE(bar);
> >
> > I believe a "sane" compiler can load bar before foo and not be a bug,
> 
> That's bullshit. The whole definition of volatile is about being
> visible as an access in the virtual machine, and having externally
> visible side effects. Two volatiles cannot be re-ordered wrt each
> other, and arguably with the traditional explanation for what it's all
> about, you can't even re-order them wrt global memory accesses.
> 
> In fact, one sane semantic for what "volatile" means from a compiler
> standpoint is to say that a volatile access aliases with all other
> accesses (including other accesses to the same thing). That's one of
> the saner approaches for compilers to handle volatile, since a C
> compiler wants to have a notion of aliasing anyway (and C also has the
> notion of type-based aliasing in general).
> 
> So no, a "sane" compiler cannot reorder the two.
> 

This is the quibbling that we both want to avoid, but the quibble you keep 
asking to get and now we've arrived at my definition of a sane compiler vs 
insane compiler.  I don't see this as mattering since you're already 
receptive to changing the comment.  In this case, we're again talking 
about volatile-qualified pointers vs volatile objects, and this is the 
area you hate.  That's why I believe a "slightly less than sane" compiler 
with a conforming implementation can do so without being buggy.  It's not 
what gcc or any other known compiler does, and I don't think it will ever 
change, so I don't see the point in discussing these theoretical 
compilers and whether they conform or not.

That said, I know for sure that the comment can be improved because there 
does exist a misconception about it.  An illustration: there was one 
person on the to: list of the email when I replied to it initially and 
everybody else has either injected themselves or were cc'd by someone else 
(admittedly, I brought you in because we had thought the comment was 
improved but you weren't amused).  This whole long thread started with me 
saying simply "ACCESS_ONCE() does not guarantee that the compiler will not 
refetch mm->mmap_cache whatsoever; there is nothing that prevents this 
in the C standard.  You'll be relying solely on gcc's implementation of 
how it dereferences volatile-qualified pointers."  That statement is 
completely 100% correct yet there was this scary confusion about it and 
referencing of the comment to justify some idea that it's a cheap memory 
barrier.

I know you're now receptive to changing the comment in some ways and I've 
proposed such a comment to you, and I admit there may have been some 
confusion about the intention of the patch that I proposed.  You probably 
also saw compiler people cc'd and thought I was defending their ability to 
change this behavior whenever they wanted.  If you actually read the 
originating thread, though, you'll see the only goal the entire time was 
to increase the understanding.  For someone who mostly wrote 
Documentation/volatile-considered-harmful.txt, I think you'd appreciate 
that clarify for one of its rare appearances in the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
