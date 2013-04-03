Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 8C7096B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 12:34:11 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 3 Apr 2013 10:34:10 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A319819D8048
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:34:01 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r33GY1KG359020
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 10:34:02 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r33GaZOM016046
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 10:36:36 -0600
Date: Wed, 3 Apr 2013 09:33:48 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <20130403163348.GD28522@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
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
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org

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

That is the implementation of ACCESS_ONCE().  As Johannes noted,
in the unlikely event that this implementation ever fails to provide
the semantics required of ACCESS_ONCE(), something will be changed.
This has already happened at least once.  A recent version of gcc allowed
volatile stores of certain constants to be split, but gcc was changed
to avoid this behavior, while of course preserving this optimization
for non-volatile stores.  If we later need to change the ACCESS_ONCE()
macro, we will make that change.

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

But we are not using a non-volatile-qualified pointer to access a
volatile-qualified object.  We are doing the opposite.  I therefore
don't understand the relevance of your comment about undefined behavior.

> If using a sufficiently recent version of GCC, you can get the
> behaviour that I think you want by using
>     __atomic_load(&x, __ATOMIC_RELAXED)

If this maps to the memory_order_relaxed token defined in earlier versions
of the C11 standard, then this absolutely does -not-, repeat -not-, work
for ACCESS_ONCE().  The relaxed load instead guarantees is that the load
will be atomic with respect to other atomic stores to that same variable,
in other words, it will prevent "load tearing" and "store tearing".  I
also believe that it prevents reloading, in other words, preventing this:

	tmp = __atomic_load(&x, __ATOMIC_RELAXED);
	do_something_with(tmp);
	do_something_else_with(tmp);

from being optimized into something like this:

	do_something_with(__atomic_load(&x, __ATOMIC_RELAXED));
	do_something_else_with(__atomic_load(&x, __ATOMIC_RELAXED));

It says nothing about combining nearby loads from that same variable.
As I understand it, the compiler would be within its rights to do the
reverse optimization from this:

	do_something_with(__atomic_load(&x, __ATOMIC_RELAXED));
	do_something_else_with(__atomic_load(&x, __ATOMIC_RELAXED));

into this:

	tmp = __atomic_load(&x, __ATOMIC_RELAXED);
	do_something_with(tmp);
	do_something_else_with(tmp);

It is only permitted to do finite combining, so that it is prohibited
from turning this:

	while (__atomic_load(&x, __ATOMIC_RELAXED) != 0)
		do_some_other_thing();

into this:

	tmp = __atomic_load(&x, __ATOMIC_RELAXED);
	while (tmp)
		do_some_other_thing();

and thus into this:

	tmp = __atomic_load(&x, __ATOMIC_RELAXED);
	for (;;)
		do_some_other_thing();

But it would be within its rights to unroll the original loop into
something like this:

	while (__atomic_load(&x, __ATOMIC_RELAXED) != 0) {
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
		do_some_other_thing();
	}

This could of course destroy the response-time characteristics of the
resulting program, so we absolutely must have a way to prevent the
compiler from doing this.  One way to prevent it from doing this is in
fact a volatile cast:

	while (__atomic_load((volatile typeof(x) *)&x, __ATOMIC_RELAXED) != 0)
		do_some_other_thing();

The last time I went through this with the C/C++ standards committee
members, they agreed with my interpretation.  Perhaps the standard has
been changed to allow volatile to be dispensed with, but I have not
seen any such change.  So, if you believe differently, please show me
the wording in the standard that supports your view.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
