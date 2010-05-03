Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 13C796B0286
	for <linux-mm@kvack.org>; Mon,  3 May 2010 11:02:11 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d3bbdffe-8cc7-4ab9-8292-1531d13fad8e@default>
Date: Mon, 3 May 2010 07:59:57 -0700 (PDT)
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
 <4BDD3079.5060101@vflare.org> <b09a9cc6-8481-4dd3-8374-68ff6fb714d9@default>
 <4BDDACF5.90601@redhat.com> <b6cfd097-1003-47ce-9f1c-278835ba52d2@default
 4BDE99C8.1090002@redhat.com>
In-Reply-To: <4BDE99C8.1090002@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: ngupta@vflare.org, Jeremy Fitzhardinge <jeremy@goop.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > My analogy only requires some
> > statistical bad luck: Multiple guests with peaks and valleys
> > of memory requirements happen to have their peaks align.
>=20
> Not sure I understand.

Virtualization is all about statistical multiplexing of fixed
resources.  If all guests demand a resource simultaneously,
that is peak alignment =3D=3D "bad luck".

(But, honestly, I don't even remember the point either of us
was trying to make here :-)

> > Or maybe not... when a guest is in the middle of a live migration,
> > I believe (in Xen), the entire guest memory allocation (possibly
> > excluding ballooned-out pages) must be simultaneously in RAM briefly
> > in BOTH the host and target machine.  That is, live migration is
> > not "pipelined".  Is this also true of KVM?
>=20
> No.  The entire guest address space can be swapped out on the source
> and
> target, less the pages being copied to or from the wire, and pages
> actively accessed by the guest.  Of course performance will suck if all
> memory is swapped out.

Will it suck to the point of eventually causing the live migration
to fail?  Or will swap-storms effectively cause denial-of-service
for other guests?

Anyway, if live migration works fine with mostly-swapped-out guests
on KVM, that's great.

> > Choosing the _optimal_ overcommit ratio is impossible without a
> > prescient knowledge of the workload in each guest.  Hoping memory
> > will be available is certainly not a good solution, but if memory
> > is not available guest swapping is much better than host swapping.
>=20
> You cannot rely on guest swapping.

Frontswap only relies on the guest having an existing swap device,
defined in /etc/fstab like any normal Linux swap device.  If this
is "relying on guest swapping", yes frontswap relies on guest swapping.

Or if you are referring to your "host can't force guest to
reclaim pages" argument, see the other thread.

> > And making RAM usage as dynamic as possible and live migration
> > as easy as possible are keys to maximizing the benefits (and
> > limiting the problems) of virtualization.
>=20
> That is why you need overcommit.  You make things dynamic with page
> sharing and ballooning and live migration, but at some point you need a
> failsafe fallback.  The only failsafe fallback I can see (where the
> host doesn't rely on guests) is swapping.

No fallback is required if the overcommitment is done intelligently.

> As far as I can tell, frontswap+tmem increases the problem.  You loan
> the guest some memory without the means to take it back, this increases
> memory pressure on the host.  The result is that if you want to avoid
> swapping (or are unable to) you need to undercommit host resources.
> Instead of sum(guest mem) + reserve < (host mem), you need sum(guest
> mem
> + committed tmem) + reserve < (host mem).  You need more host memory,
> or less guests, or to be prepared to swap if the worst happens.

Your argument might make sense from a KVM perspective but is
not true of frontswap with Xen+tmem.  With KVM, the host's
swap disk(s) can all be used as "slow RAM".  With Xen, there is
no host swap disk.  So, yes, the degree of potential memory
overcommitment is smaller with Xen+tmem than with KVM.  In
order to avoid all the host problems with host-swapping,
frontswap+Xen+tmem intentionally limits the degree of memory
overcommitment... but this is just memory overcommitment done
intelligently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
