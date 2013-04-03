Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 3AFE36B0002
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:33:20 -0400 (EDT)
Date: Wed, 3 Apr 2013 10:33:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <20130403143302.GL1953@cmpxchg.org>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
 <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
 <alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
 <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403041447.GC4611@cmpxchg.org>
 <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
 <20130403045814.GD4611@cmpxchg.org>
 <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Lance Taylor <iant@google.com>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, Apr 03, 2013 at 06:45:51AM -0700, Ian Lance Taylor wrote:
> On Tue, Apr 2, 2013 at 9:58 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Tue, Apr 02, 2013 at 09:25:40PM -0700, David Rientjes wrote:
> >
> >> As stated, it doesn't.  I made the comment "for what it's worth" that
> >> ACCESS_ONCE() doesn't do anything to "prevent the compiler from
> >> re-fetching" as the changelog insists it does.
> >
> > That's exactly what it does:
> >
> > /*
> >  * Prevent the compiler from merging or refetching accesses.
> >
> > This is the guarantee ACCESS_ONCE() gives, users should absolutely be
> > allowed to rely on this literal definition.  The underlying gcc
> > implementation does not matter one bit.  That's the whole point of
> > abstraction!
> 
> If the definition of ACCESS_ONCE is indeed
> 
> #define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))
> 
> then its behaviour is compiler-specific.

Who cares about the implementation, we are discussing a user here.
ACCESS_ONCE() isolates a problem so that the users don't have to think
about it, that's the whole point of abstraction.  ACCESS_ONCE() is an
opaque building block that says it prevents the compiler from merging
and refetching accesses.  That's all we care about right now.

It may rely on compiler-specific behavior to achieve this, and its
implementation may change if the underlying compilers change, but this
will not affect the promise that it makes and so this is off-topic.
This patch uses "ACCESS_ONCE()" and not "<compiler-specific tricks>".

> The C language standard only describes how access to
> volatile-qualified objects behave.  In this case x is (presumably) not
> a volatile-qualifed object.  The standard never defines the behaviour
> of volatile-qualified pointers.  That might seem like an oversight,
> but it is not: using a non-volatile-qualified pointer to access a
> volatile-qualified object is undefined behaviour.
> 
> In short, casting a pointer to a non-volatile-qualified object to a
> volatile-qualified pointer has no specific meaning in C.  It's true
> that most compilers will behave as you wish, but there is no
> guarantee.

I am operating under the assumption that people compile their kernels
with a subset of "most compilers" and not the C standard.

[ Actually, I just tried to imagine how you would compile the kernel
  using the C standard instead of a compiler and that may have popped
  a blood vessel in my eye. ]

> If using a sufficiently recent version of GCC, you can get the
> behaviour that I think you want by using
>     __atomic_load(&x, __ATOMIC_RELAXED)

This is good to know but the implementation details of ACCESS_ONCE()
are irrelevant here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
