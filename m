Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 26A6C6B0035
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 03:42:45 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id z2so215330wiv.0
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 00:42:44 -0800 (PST)
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [2001:4b98:c:538::195])
        by mx.google.com with ESMTPS id tn8si22711151wjc.83.2014.01.03.00.42.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 00:42:44 -0800 (PST)
Date: Fri, 3 Jan 2014 00:42:36 -0800
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: Memory allocator semantics
Message-ID: <20140103084236.GA5992@leaf>
References: <20140102203320.GA27615@linux.vnet.ibm.com>
 <20140103033906.GB2983@leaf>
 <20140103051417.GT19211@linux.vnet.ibm.com>
 <20140103054700.GA4865@leaf>
 <20140103075727.GU19211@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140103075727.GU19211@linux.vnet.ibm.com>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com

On Thu, Jan 02, 2014 at 11:57:27PM -0800, Paul E. McKenney wrote:
> On Thu, Jan 02, 2014 at 09:47:00PM -0800, Josh Triplett wrote:
> > On Thu, Jan 02, 2014 at 09:14:17PM -0800, Paul E. McKenney wrote:
> > > On Thu, Jan 02, 2014 at 07:39:07PM -0800, Josh Triplett wrote:
> > > > On Thu, Jan 02, 2014 at 12:33:20PM -0800, Paul E. McKenney wrote:
> > > > > Hello!
> > > > >=20
> > > > > From what I can see, the Linux-kernel's SLAB, SLOB, and SLUB me=
mory
> > > > > allocators would deal with the following sort of race:
> > > > >=20
> > > > > A.	CPU 0: r1 =3D kmalloc(...); ACCESS_ONCE(gp) =3D r1;
> > > > >=20
> > > > > 	CPU 1: r2 =3D ACCESS_ONCE(gp); if (r2) kfree(r2);
> > > > >=20
> > > > > However, my guess is that this should be considered an accident=
 of the
> > > > > current implementation rather than a feature.  The reason for t=
his is
> > > > > that I cannot see how you would usefully do (A) above without a=
lso allowing
> > > > > (B) and (C) below, both of which look to me to be quite destruc=
tive:
> > > >=20
> > > > (A) only seems OK if "gp" is guaranteed to be NULL beforehand, *a=
nd* if
> > > > no other CPUs can possibly do what CPU 1 is doing in parallel.  E=
ven
> > > > then, it seems questionable how this could ever be used successfu=
lly in
> > > > practice.
> > > >=20
> > > > This seems similar to the TCP simultaneous-SYN case: theoreticall=
y
> > > > possible, absurd in practice.
> > >=20
> > > Heh!
> > >=20
> > > Agreed on the absurdity, but my quick look and slab/slob/slub leads
> > > me to believe that current Linux kernel would actually do something
> > > sensible in this case.  But only because they don't touch the actua=
l
> > > memory.  DYNIX/ptx would have choked on it, IIRC.
> >=20
> > Based on this and the discussion at the bottom of your mail, I think =
I'm
> > starting to understand what you're getting at; this seems like less o=
f a
> > question of "could this usefully happen?" and more "does the allocato=
r
> > know how to protect *itself*?".
>=20
> Or perhaps "What are the rules when a concurrent program interacts with
> a memory allocator?"  Like the set you provided below.  ;-)

:)

> > > > > But I thought I should ask the experts.
> > > > >=20
> > > > > So, am I correct that kernel hackers are required to avoid "dri=
ve-by"
> > > > > kfree()s of kmalloc()ed memory?
> > > >=20
> > > > Don't kfree things that are in use, and synchronize to make sure =
all
> > > > CPUs agree about "in use", yes.
> > >=20
> > > For example, ensure that each kmalloc() happens unambiguously befor=
e the
> > > corresponding kfree().  ;-)
> >=20
> > That too, yes. :)
> >=20
> > > > > PS.  To the question "Why would anyone care about (A)?", then a=
nswer
> > > > >      is "Inquiring programming-language memory-model designers =
want
> > > > >      to know."
> > > >=20
> > > > I find myself wondering about the original form of the question, =
since
> > > > I'd hope that programming-languge memory-model designers would
> > > > understand the need for synchronization around reclaiming memory.
> > >=20
> > > I think that they do now.  The original form of the question was as
> > > follows:
> > >=20
> > > 	But my intuition at the moment is that allowing racing
> > > 	accesses and providing pointer atomicity leads to a much more
> > > 	complicated and harder to explain model.  You have to deal
> > > 	with initialization issues and OOTA problems without atomics.
> > > 	And the implementation has to deal with cross-thread visibility
> > > 	of malloc meta-information, which I suspect will be expensive.
> > > 	You now essentially have to be able to malloc() in one thread,
> > > 	transfer the pointer via a race to another thread, and free()
> > > 	in the second thread.  That=E2=80=99s hard unless malloc() and fre=
e()
> > > 	always lock (as I presume they do in the Linux kernel).
> >=20
> > As mentioned above, this makes much more sense now.  This seems like =
a
> > question of how the allocator protects its *own* internal data
> > structures, rather than whether the allocator can usefully be used fo=
r
> > the cases you mentioned above.  And that's a reasonable question to a=
sk
> > if you're building a language memory model for a language with malloc
> > and free as part of its standard library.
> >=20
> > To roughly sketch out some general rules that might work as a set of
> > scalable design constraints for malloc/free:
> >=20
> > - malloc may always return any unallocated memory; it has no obligati=
on
> >   to avoid returning memory that was just recently freed.  In fact, a=
n
> >   implementation may even be particularly *likely* to return memory t=
hat
> >   was just recently freed, for performance reasons.  Any program whic=
h
> >   assumes a delay or a memory barrier before memory reuse is broken.
>=20
> Agreed.
>=20
> > - Multiple calls to free on the same memory will produce undefined
> >   behavior, and in particular may result in a well-known form of
> >   security hole.  free has no obligation to protect itself against
> >   multiple calls to free on the same memory, unless otherwise specifi=
ed
> >   as part of some debugging mode.  This holds whether the calls to fr=
ee
> >   occur in series or in parallel (e.g. two or more calls racing with
> >   each other).  It is the job of the calling program to avoid calling
> >   free multiple times on the same memory, such as via reference
> >   counting, RCU, or some other mechanism.
>=20
> Yep!
>=20
> > - It is the job of the calling program to avoid calling free on memor=
y
> >   that is currently in use, such as via reference counting, RCU, or s=
ome
> >   other mechanism.  Accessing memory after reclaiming it will produce
> >   undefined behavior.  This includes calling free on memory concurren=
tly
> >   with accesses to that memory (e.g. via a race).
>=20
> Yep!
>=20
> > - malloc and free must work correctly when concurrently called from
> >   multiple threads without synchronization.  Any synchronization or
> >   memory barriers required internally by the implementations must be
> >   provided by the implementation.  However, an implementation is not
> >   required to use any particular form of synchronization, such as
> >   locking or memory barriers, and the caller of malloc or free may no=
t
> >   make any assumptions about the ordering of its own operations
> >   surrounding those calls.  For example, an implementation may use
> >   per-CPU memory pools, and only use synchronization when it cannot
> >   satisfy an allocation request from the current CPU's pool.
>=20
> Yep, though in C/C++11 this comes out something very roughly like:
> "A free() involving a given byte of memory synchronizes-with a later
> alloc() returning a block containing that block of memory."

Gah.  That doesn't seem like a memory-ordering guarantee the allocator
should have to provide for its caller, and I can easily think of
allocator structures that wouldn't guarantee it without the inclusion of
an explicit memory barrier.

(Also, I assume the last use of "block" in that sentence should have
been "byte"?)

> > - An implementation of free must support being called on any memory
> >   allocated by the same implementation of malloc, at any time, from a=
ny
> >   CPU.  In particular, a call to free on memory freshly malloc'd on
> >   another CPU, with no intervening synchronization between the two
> >   calls, must succeed and reclaim the memory.  However, the actual ca=
lls
> >   to malloc and free must not race with each other; in particular, th=
e
> >   pointer value returned by malloc is not valid (for access or for ca=
lls
> >   to free) until malloc itself has returned.  (Such a race would requ=
ire
> >   the caller of free to divine the value returned by malloc before
> >   malloc returns.)  Thus, the implementations of malloc and free may
> >   safely assume a data dependency (via the returned pointer value
> >   itself) between the call to malloc and the call to free; such a
> >   dependency may allow further assumptions about memory ordering base=
d
> >   on the platform's memory model.
>=20
> I would be OK requiring the user to have a happens-before relationship
> between an allocation and a subsequent matching free.

I *think* that's the right formal relationship I'm suggesting, yes.
Mostly I'm suggesting that since the only sensible way for the pointer
value you're passing to free to have come into existence is to have
received it from malloc at some point in the past (as opposed to
magically divining its value), it's not so much "requiring the user to
have a happens-before relationship" as "not allowing the user to
randomly make up pointers and free them, even if they happen to match
the value being returned from a concurrent malloc".  Because that's the
only way I can think of for malloc and free to race on the same pointer.

In any case, let me know if the rules sketched above end up proving
useful as part of the requirements for malloc/free.

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
