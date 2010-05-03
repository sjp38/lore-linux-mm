Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6684E6B022F
	for <linux-mm@kvack.org>; Mon,  3 May 2010 12:02:54 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <74c69226-4678-4b9b-bfeb-1490c8f5636d@default>
Date: Mon, 3 May 2010 09:01:15 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>>
 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>>
 <4BD1A74A.2050003@redhat.com>>
 <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>> <4BD1B427.9010905@redhat.com>
 <4BD1B626.7020702@redhat.com>>
 <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>>
 <4BD3377E.6010303@redhat.com>>
 <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>>
 <ce808441-fae6-4a33-8335-f7702740097a@default>>
 <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz>
 <4BDA8324.7090409@redhat.com> <084f72bf-21fd-4721-8844-9d10cccef316@default>
 <4BDB026E.1030605@redhat.com> <4BDB18CE.2090608@goop.org>
 <4BDB2069.4000507@redhat.com> <3a62a058-7976-48d7-acd2-8c6a8312f10f@default>
 <4BDD9BD3.2080301@redhat.com> <f392dc83-f5a3-4048-ab4d-758225d16547@default
 4BDE8D76.3000703@redhat.com>
In-Reply-To: <4BDE8D76.3000703@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > Simple policies must exist and must be enforced by the hypervisor to
> ensure
> > this doesn't happen.  Xen+tmem provides these policies and enforces
> them.
> > And it enforces them very _dynamically_ to constantly optimize
> > RAM utilization across multiple guests each with dynamically varying
> RAM
> > usage.  Frontswap fits nicely into this framework.
>
> Can you explain what "enforcing" means in this context?  You loaned the
> guest some pages, can you enforce their return?

We're getting into hypervisor policy issues, but given that probably
nobody else is listening by now, I guess that's OK. ;-)

The enforcement is on the "put" side.  The page is not loaned,
it is freely given, but only if the guest is within its
contractual limitations (e.g. within its predefined "maxmem").
If the guest chooses to never remove the pages from frontswap,
that's the guest's option, but that part of the guests
memory allocation can never be used for anything else so
it is in the guest's self-interest to "get" or "flush" the
pages from frontswap.

> > Huge performance hits that are completely inexplicable to a user
> > give virtualization a bad reputation.  If the user (i.e. guest,
> > not host, administrator) can at least see "Hmmm... I'm doing a lot
> > of swapping, guess I'd better pay for more (virtual) RAM", then
> > the user objections are greatly reduced.
>=20
> What you're saying is "don't overcommit".

Not at all.  I am saying "overcommit, but do it intelligently".

> That's a good policy for some
> scenarios but not for others.  Note it applies equally well for cpu as
> well as memory.

Perhaps, but CPU overcommit has been a well-understood
part of computing for a very long time and users, admins,
and hosting providers all know how to recognize it and
deal with it.  Not so with overcommitment of memory;
the only exposure to memory limitations is "my disk light
is flashing a lot, I'd better buy more RAM".  Obviously,
this doesn't translate to virtualization very well.

And, as for your interrupt latency analogy, let's
revisit that if/when Xen or KVM support CPU overcommitment
for real-time-sensitive guests.  Until then, your analogy
is misleading.

> frontswap+tmem is not overcommit, it's undercommit.   You have spare
> memory, and you give it away.  It isn't a replacement.  However,
> without
> the means to reclaim this spare memory, it can result in overcommit.

But you are missing part of the magic:  Once the memory
page is no longer directly addressable (AND this implies not
directly writable) by the guest, the hypervisor can do interesting
things with it, such as compression and deduplication.

As a result, the sum of pages used by all the guests exceeds
the total pages of RAM in the system.  Thus overcommitment.
I agree that the degree of overcommitment is less than possible
with host-swapping, but none of the evil issues of host-swapping
happen. Again, this is "intelligent overcommitment".  Other
existing forms are "overcommit and cross your fingers that bad
things don't happen."

> > Xen+tmem uses the SAME internal kernel interface.  The Xen-specific
> > code which performs the Xen-specific stuff (hypercalls) is only in
> > the Xen-specific directory.
>=20
> This makes it an external interface.
>  :
> Something completely internal to the guest can be replaced by something
> completely different.  Something that talks to a hypervisor will need
> those hooks forever to avoid regressions.

Uh, no.  As I've said, everything about frontswap is entirely
optional, both at compile-time and run-time.  A frontswap-enabled
guest is fully compatible with a hypervisor with no frontswap;
a frontswap-enabled hypervisor is fully compatible with a guest
with no frontswap.  The only thing that is reserved forever is
a hypervisor-specific "hypercall number" which is not exposed in
the Linux kernel except in Xen-specific code.  And, for Xen,
frontswap shares the same hypercall number with cleancache.

So, IMHO, you are being alarmist.  This is not an "API
maintenance" problem for Linux.

> Exactly as large as the swap space which the guest would have in the
> frontswap+tmem case.
>  :
> Not needed, though I expect it is already supported (SAN volumes do
> grow).
>  :
> If block layer overhead is a problem, go ahead and optimize it instead
> of adding new interfaces to bypass it.  Though I expect it wouldn't be
> needed, and if any optimization needs to be done it is in the swap
> layer.
> Optimizing swap has the additional benefit of improving performance on
> flash-backed swap.
>  :
> What happens when no tmem is available?  you swap to a volume.  That's
> the disk size needed.
>  :
> You're dynamic swap is limited too.  And no, no guest modifications.

You keep saying you are going to implement all of the dynamic features
of frontswap with no changes to the guest and no copying and no
host-swapping.  You are being disingenuous.  VMware has had a lot
of people working on virtualization a lot longer than you or I have.
Don't you think they would have done this by now?

Frontswap exists today and is even shipping in real released products.
If you can work your magic (in Xen... I am not trying to claim
frontswap should work with KVM), please show us the code.

> So, you take a synchronous copyful interface, add another copy to make
> it into an asynchronous interface, instead of using the original
> asynchronous copyless interface.

"Add another copy" is not required any more than it is with the
other examples you cited.

The "original asynchronous copyless interface" works because DMA
for devices has been around for >40 years and has been greatly
refined.  We're not talking about DMA to a device here, we're
talking about DMA from one place in RAM to another (i.e. from
guest RAM to hypervisor RAM).  Do you have examples of DMA engines
that do page-size-ish RAM-to-RAM more efficiently than copying?

> The networking stack seems to think 4096 bytes is a good size for dma
> (see net/core/user_dma.c, NET_DMA_DEFAULT_COPYBREAK).

Networking is a device-to-RAM, not RAM-to-RAM.

> When swapping out, Linux already batches pages in the block device's
> request queue.  Swapping out is inherently asynchronous and batched,
> you're swapping out those pages _because_ you don't need them, and
> you're never interested in swapping out a single page.  Linux already
> reserves memory for use during swapout.  There's no need to re-solve
> solved problems.

Swapping out is inherently asynchronous and batches because it was
designed for swapping to a device, while you are claiming that the
same _unchanged_ interface is suitable for swap-to-hypervisor-RAM
and at the same time saying that the block layer might need
to be "optimized" (apparently without code changes).

I'm not trying to re-solve a solved problem; frontswap solves a NEW
problem, with very little impact to existing code.

> Swapping in is less simple, it is mostly synchronous (in some cases it
> isn't: with many threads, or with the preswap patches (IIRC unmerged)).
> You can always choose to copy if you don't have enough to justify dma.

Do you have a pointer to these preswap patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
