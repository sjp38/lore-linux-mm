Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070816032921.GA32197@wotan.suse.de>
References: <20070814142103.204771292@sgi.com>
	 <20070815122253.GA15268@wotan.suse.de> <1187183526.6114.45.camel@twins>
	 <20070816032921.GA32197@wotan.suse.de>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wK7NorbyJxptZCBFsMWC"
Date: Mon, 20 Aug 2007 05:51:34 +0200
Message-Id: <1187581894.6114.169.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

--=-wK7NorbyJxptZCBFsMWC
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-08-16 at 05:29 +0200, Nick Piggin wrote:
> On Wed, Aug 15, 2007 at 03:12:06PM +0200, Peter Zijlstra wrote:
> > On Wed, 2007-08-15 at 14:22 +0200, Nick Piggin wrote:
> > > On Tue, Aug 14, 2007 at 07:21:03AM -0700, Christoph Lameter wrote:
> > > > The following patchset implements recursive reclaim. Recursive recl=
aim
> > > > is necessary if we run out of memory in the writeout patch from rec=
laim.
> > > >=20
> > > > This is f.e. important for stacked filesystems or anything that doe=
s
> > > > complicated processing in the writeout path.
> > >=20
> > > Filesystems (most of them) that require compilcated allocations at
> > > writeout time suck. That said, especially with network ones, it
> > > seems like making them preallocate or reserve required memory isn't
> > > progressing very smoothly.
> >=20
> > Mainly because we seem to go in circles :-(
> >=20
> > >  I think these patchsets are definitely
> > > worth considering as an alternative.=20
> >=20
> > Honestly, I don't. They very much do not solve the problem, they just
> > displace it.
>=20
> Well perhaps it doesn't work for networked swap, because dirty accounting
> doesn't work the same way with anonymous memory... but for _filesystems_,
> right?
>=20
> I mean, it intuitively seems like a good idea to terminate the recursive
> allocation problem with an attempt to reclaim clean pages rather than
> immediately let them have-at our memory reserve that is used for other
> things as well.=20

I'm concerned about the worst case scenarios, and those don't change.
The proposed changes can be seen as an optimisation of various things,
but they do not change the fundamental issues.

> Any and all writepage() via reclaim is allowed to eat
> into all of memory (I hate that writepage() ever has to use any memory,
> and have prototyped how to fix that for simple block based filesystems
> in fsblock, but others will require it).
>=20
>=20
> > Christoph's suggestion to set min_free_kbytes to 20% is ridiculous - no=
r
> > does it solve all deadlocks :-(
>=20
> Well of course it doesn't, but it is a pragmatic way to reduce some
> memory depletion cases. I don't see too much harm in it (although I didn'=
t
> see the 20% suggestion?)

Sure, and on that note I don't object to them, they might be quite
useful at times. It just doesn't help the worst case scenarios.

> > > No substantial comments though.=20
> >=20
> > Please do ponder the problem and its proposed solutions, because I'm
> > going crazy here.
> =20
> Well yeah I think you simply have to reserve a minimum amount of memory i=
n
> order to reclaim a page, and I don't see any other way to do it other tha=
n
> what you describe to be _technically_ deadlock free.

Right, and I guess I have to go at it again, this time ensuring not to
touch the fast-path nor sacrificing anything NUMA for simplicity in the
reclaim path.

(I think its a good thing to be technically deadlock free - and if your
work on the fault path rewrite and buffered write rework shows anything
it is that you seem to agree with this)

> But firstly, you don't _want_ to start dropping packets when you hit a to=
ugh
> patch in reclaim -- even if you are strictly deadlock free. And secondly,
> I think recursive reclaim could reduce the deadlocks in practice which is
> not a bad thing as your patches aren't merged.

Non of the people who have actually used these patches seem to object to
the dropping packets thing. Nor do I see that as a real problem,
networks are assumed lossy - also if you really need that traffic for a
RT app that also runs on the machine you need networked swap on (odd
combination but hey, it should be possible) then I can make that work as
well with a little bit more effort.

Also, I'm a very reluctant to accept a known deadlock, esp. since the
changes needed are not _that_ complex.

> How are your deadlock patches going anyway? AFAIK they are mostly a netwo=
rk
> issue and I haven't been keeping up with them for a while.=20

They really do rely on some VM interaction too, network does not have
enough information to break out of the deadlock on its own.

As for how its going, it seems to work quite reliably in my test setup -
that is, I can shut down the NFS server, swamp the client in network
traffic for hours (yes it will quickly stop userspace) and then restart
the NFS server and the client will reconnect and resume operation.

There are also a few people running various versions of my patches in
production environments. One university is running it on a 500-node
cluster and another on ~500 thin-clients and there is someone using it
in a blade product.

> Do you really need
> networked swap and actually encounter the deadlock, or is it just a quest=
ion of
> wanting to fix the bugs? If the former, what for, may I ask?

Yes (we - not I personally) want networked swap. There is quite the
demand for it in the marked. It allows clusters and blades to be build
without any storage - which not only saves on the initial cost of a hard
drive [1] but also on maintenance but more importantly on energy cost
and heat production.

[1] a single drive is not that expensive, but when you're talking about
a 1000 node cluster things tend to add up.

> > <> What Christoph is proposing is doing recursive reclaim and not
> > initiating writeout. This will only work _IFF_ there are clean pages
> > about. Which in the general case need not be true (memory might be
> > packed with anonymous pages - consider an MPI cluster doing computation
> > stuff). So this gets us a workload dependant solution - which IMHO is
> > bad!
>=20
> Although you will quite likely have at least a couple of MB worth of
> clean program text. The important part of recursive reclaim is that it
> doesn't so easily allow reclaim to blow all memory reserves (including
> interrupt context). Sure you still have theoretical deadlocks, but if
> I understand correctly, they are going to be lessened. I would be
> really interested to see if even just these recursive reclaim patches
> eliminate the problem in practice.

were we much bothered by the buffered write deadlock? - why accept a
known deadlock if a solid solution is quite attainable?


--=-wK7NorbyJxptZCBFsMWC
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGyQ/GXA2jU0ANEf4RAv3zAJ97pfOIXjgC1nFhRpObYvEjMGsX0gCggvQ0
D4VYkov4DUwebv5C3K7bUF0=
=E13T
-----END PGP SIGNATURE-----

--=-wK7NorbyJxptZCBFsMWC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
