Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 0CB3A6B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 21:52:06 -0400 (EDT)
Received: by mail-da0-f51.google.com with SMTP id g27so906571dan.38
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 18:52:06 -0700 (PDT)
Date: Wed, 3 Apr 2013 18:52:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] compiler: clarify ACCESS_ONCE() relies on compiler
 implementation
In-Reply-To: <CA+55aFwdJCxnNQMQEAaC-+8pEGpHKgaq5aL4K2n=vRVBUg863A@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1304031812320.4709@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com> <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com> <alpine.LNX.2.00.1304021600420.22412@eggly.anvils> <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403041447.GC4611@cmpxchg.org> <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com> <20130403045814.GD4611@cmpxchg.org> <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com> <20130403143302.GL1953@cmpxchg.org>
 <alpine.DEB.2.02.1304031648170.718@chino.kir.corp.google.com> <alpine.DEB.2.02.1304031659160.718@chino.kir.corp.google.com> <CA+55aFwdJCxnNQMQEAaC-+8pEGpHKgaq5aL4K2n=vRVBUg863A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>

On Wed, 3 Apr 2013, Linus Torvalds wrote:

> Any compiler that thinks it can load something through a "volatile"
> pointer multiple times is SHIT. We don't add these kinds of comments
> to make excuses for crap, we call out such compilers and tell people
> not to use the utter crap they are.
> 

How nice to have reconvened after six years when in February of 2007 you 
slammed me for relying on the implementation of a particular compiler on 
the sign of a bitfield and referred multiple times to the standard and how 
it's implementation defined.  I don't want to go down that road again, 
even though the poster of quotes we had on the wall at work was amusing 
for awhile.

The specification here says an access to this volatile quaified pointer is 
implementation defined.  It also allows for the pointer to be reloaded and 
the local variable optimized out.  Do people need to know that?  
Debatable.  But there are misconceptions of what a volatile-qualified 
pointer can do.

This patch was an attempt to clarify for those who didn't understand that 
we're relying on the implementation of the compiler to not optimize the 
loads from memory out.  The way the comment is currently written, stating 
that it is "preventing the compiler from refetching" can literally mean 
one of two things: it actually does something based on specification that 
causes these objects to not be reloaded, or it is using the way 
volatile-qualified pointers are dereferenced in gcc and other compilers to 
prevent it.  I'm pretty darn sure Paul was referring to the latter when he 
wrote it, which is completely 100% correct, but other readers of the 
comment have taken it to mean the former and it causes misconceptions of 
the keyword.

That said, I'm not interested in arguing with you on the meaning of the 
word "prevent" in the ACCESS_ONCE() comment nor in the changelog of the 
patch that sparked this discussion.  We're talking about English here, not 
C, and the goal was to make it explicit.  If you take offense to that, 
owell.

Ian has suggested that we file a request with the gcc team for the exact 
semantics we're asking for from ACCESS_ONCE() so that we don't need to 
rely on any particular compiler's implementation and can standardize this 
at least for gcc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
