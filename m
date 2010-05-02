Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 57E936006AB
	for <linux-mm@kvack.org>; Sun,  2 May 2010 13:06:27 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f392dc83-f5a3-4048-ab4d-758225d16547@default>
Date: Sun, 2 May 2010 10:06:06 -0700 (PDT)
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
 <4BDB2069.4000507@redhat.com> <3a62a058-7976-48d7-acd2-8c6a8312f10f@default
 4BDD9BD3.2080301@redhat.com>
In-Reply-To: <4BDD9BD3.2080301@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > OK, now I think I see the crux of the disagreement.
>=20
> Alas, I think we're pretty far from that.

Well, to be fair, I meant the disagreement of synchronous vs
asynchronous.
=20
> > NO!  Frontswap on Xen+tmem never *never* _never_ NEVER results
> > in host swapping.
>=20
> That's a bug.  You're giving the guest memory without the means to take
> it back.  The result is that you have to _undercommit_ your memory
> resources.
>=20
> Consider a machine running a guest, with most of its memory free.  You
> give the memory via frontswap to the guest.  The guest happily swaps to
> frontswap, and uses the freed memory for something unswappable, like
> mlock()ed memory or hugetlbfs.
>=20
> Now the second node dies and you need memory to migrate your guests
> into.  But you can't, and the hypervisor is at the mercy of the guest
> for getting its memory back; and the guest can't do it (at least not
> quickly).

Simple policies must exist and must be enforced by the hypervisor to ensure
this doesn't happen.  Xen+tmem provides these policies and enforces them.
And it enforces them very _dynamically_ to constantly optimize
RAM utilization across multiple guests each with dynamically varying RAM
usage.  Frontswap fits nicely into this framework.

> > Host swapping is evil.  Host swapping is
> > the root of most of the bad reputation that memory overcommit
> > has gotten from VMware customers.  Host swapping can't be
> > avoided with some memory overcommit technologies (such as page
> > sharing), but frontswap on Xen+tmem CAN and DOES avoid it.
>=20
> In this case the guest expects that swapped out memory will be slow
> (since was freed via the swap API; it will be slow if the host happened
> to run out of tmem).  So by storing this memory on disk you aren't
> reducing performance beyond what you promised to the guest.
>=20
> Swapping guest RAM will indeed cause a performance hit, but sometimes
> you need to do it.

Huge performance hits that are completely inexplicable to a user
give virtualization a bad reputation.  If the user (i.e. guest,
not host, administrator) can at least see "Hmmm... I'm doing a lot
of swapping, guess I'd better pay for more (virtual) RAM", then
the user objections are greatly reduced.

> > So, to summarize:
> >
> > 1) You agreed that a synchronous interface for frontswap makes
> >     sense for swap-to-in-kernel-compressed-RAM because it is
> >     truly swapping to RAM.
>=20
> Because the interface is internal to the kernel.

Xen+tmem uses the SAME internal kernel interface.  The Xen-specific
code which performs the Xen-specific stuff (hypercalls) is only in
the Xen-specific directory.
=20
> > 2) You have pointed out that an asynchronous interface for
> >     frontswap makes more sense for KVM than a synchronous
> >     interface, because KVM does host swapping.
>=20
> kvm's host swapping is unrelated.  Host swapping swaps guest-owned
> memory; that's not what we want here.  We want to cache guest swap in
> RAM, and that's easily done by having a virtual disk cached in main
> memory.  We're simply presenting a disk with a large write-back cache
> to the guest.

The missing part again is dynamicity.  How large is the virtual
disk?  Or are you proposing that disks can dramatically vary
in size across time?  I suspect that would be a very big patch.
And you're talking about a disk that doesn't have all the
overhead of blockio, right?

> You could just as easily cache a block device in free RAM with Xen.
> Have a tmem domain behave as the backend for your swap device.  Use
> ballooning to force tmem to disk, or to allow more cache when memory is
> free.

A block device of what size?  Again, I don't think this will be
dynamic enough.

> Voila: you no longer depend on guests (you depend on the tmem domain,
> but that's part of the host code), you don't need guest modifications,
> so it works across a wider range of guests.

Ummm... no guest modifications, yet this special disk does everything
you've described above (and, to meet my dynamicity requirements,
varies in size as well)?

> > BUT frontswap on Xen+tmem always truly swaps to RAM.
>=20
> AND that's a problem because it puts the hypervisor at the mercy of the
> guest.

As I described in a separate reply, this is simply not true.

> > So there are two users of frontswap for which the synchronous
> > interface makes sense.
>=20
> I believe there is only one.  See below.
>=20
> The problem is not the complexity of the patch itself.  It's the fact
> that it introduces a new external API.  If we refactor swapping, that
> stands in the way.

Could you please explicitly identify what you are referring
to as a new external API?  The part this is different from
the "only one" internal user?

> Even ignoring the problems above (which are really hypervisor problems
> and the guest, which is what we're discussing here, shouldn't care if
> the hypervisor paints itself into an oom)

which it doesn't.

> a synchronous single-page DMA
> API is a bad idea.  Look at the Xen network and block code, while they
> eventually do a memory copy for every page they see, they try to batch
> multiple pages into an exit, and make the response asynchronous.

As noted VERY early in this thread, if/when it makes sense, frontswap
can do exactly the same thing by adding a buffering layer invisible
to the internal kernel interfaces.

> As an example, with a batched API you could save/restore the fpu
> context
> and use sse for copying the memory, while with a single page API you'd
> probably lost out.  Synchronous DMA, even for emulated hardware, is out
> of place in 2010.

I think we agree that DMA makes sense when there is a lot of data to
copy and makes little sense when there is only a little (e.g. a
single page) to copy.  So I guess we need to understand what the
tradeoff is.  So, do you have any idea what the breakeven point is
for your favorite DMA engine for amount of data copied vs
1) locking the memory pages
2) programming the DMA engine
3) responding to the interrupt from the DMA engine

And the simple act of waiting to collect enough pages to "batch"
means none of those pages can be used until the last page is collected
and the DMA engine is programmed and the DMA is complete.
A page-at-a-time interface synchronously releases the pages
for other (presumably more important) needs and thus, when
memory is under extreme pressure, also reduces the probability
of a (guest) OOM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
