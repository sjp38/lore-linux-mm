Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 699796B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 16:02:11 -0400 (EDT)
Received: by mail-da0-f54.google.com with SMTP id p1so1263817dad.41
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 13:02:10 -0700 (PDT)
Date: Thu, 4 Apr 2013 13:02:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] compiler: clarify ACCESS_ONCE() relies on compiler
 implementation
In-Reply-To: <CA+55aFwVbnh1W6OGhVEi-OtM4OnGvk6+bAr8MGjCpvFuE3FLoA@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1304041254570.19501@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com> <20130403045814.GD4611@cmpxchg.org> <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com> <20130403143302.GL1953@cmpxchg.org>
 <alpine.DEB.2.02.1304031648170.718@chino.kir.corp.google.com> <alpine.DEB.2.02.1304031659160.718@chino.kir.corp.google.com> <CA+55aFwdJCxnNQMQEAaC-+8pEGpHKgaq5aL4K2n=vRVBUg863A@mail.gmail.com> <alpine.DEB.2.02.1304031812320.4709@chino.kir.corp.google.com>
 <CA+55aFygozny+00y3hKAwkgg-6AWh0JpmqggmGcbraGrEhOkRg@mail.gmail.com> <alpine.DEB.2.02.1304031902370.4709@chino.kir.corp.google.com> <CA+55aFxUxL-Lt2UUCwvgZxYNSA182TdhxC3RdHss00wOb8_LqA@mail.gmail.com> <alpine.DEB.2.02.1304032127070.32444@chino.kir.corp.google.com>
 <CA+55aFw_krUFFpocLOcvuANODoCJiF=QSUQeED9Xa_fLt3Gv1w@mail.gmail.com> <alpine.DEB.2.02.1304041209330.19501@chino.kir.corp.google.com> <CA+55aFwVbnh1W6OGhVEi-OtM4OnGvk6+bAr8MGjCpvFuE3FLoA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>

On Thu, 4 Apr 2013, Linus Torvalds wrote:

> > I said in the previous email that you'd do this solely to rely on a
> > well-defined semantic rather than reading paragraphs of comments that
> > we're developing.
> 
> What's "well-defined" about it? It's implementation-defined in both cases.
> 
> IOW, why do you think "__builtin_access_once(x)" is fundamentally
> different from "(*(volatile type *)&(x))"? Both would be equally
> dependent on the compiler implementation, and I'd argue that it would
> be much nicer if gcc just automatically turned the existing volatile
> code internally into the builtin version (and then didn't even bother
> to expose that builtin), since if they are willing to do the built-in,
> they clearly acknowledge the need for this kind of behavior in the
> first place.
> 

Agreed, and the gcc community can do that if they choose, and even better 
if they explicitly state that they are doing this for the traditional 
meaning (yet not standard defined) of volatile.  For nothing else, it 
would give me something to cite in the comment I proposed to you.

> See what I'm arguing? If a compiler writer is acknowledging that this
> kind of "access once with good semantics through a pointer" is needed
> and useful (and in the presense of IO and threading, a compiler writer
> that doesn't acknowledge that is a moron), then _why_ would that same
> compiler writer then argue against just doing that for volatile
> pointers?
> 

Absolutely, it would be great.

This is why I wanted to clarify the comment of ACCESS_ONCE(), however, 
that states it's "preventing the compiler" and "forbidding the compiler" 
from doing certain things, because it doesn't.  That's the whole 
discussion.  For someone interested in C, one of the natural places they 
are going to look in the source is compiler.h, and especially when they 
see this magical ACCESS_ONCE() floating around which is seemingly a cheap 
memory barrier with other ACCESS_ONCE() references and I think we can do 
better, as I did in my initial reply which started this thread, to say 
this isn't in the standard and we're relying on gcc's implementation for 
this behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
