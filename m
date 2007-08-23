Subject: Re: [RFC 2/9] Use NOMEMALLOC reclaim to allow reclaim if
	PF_MEMALLOC is set
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070823033826.GE18788@wotan.suse.de>
References: <20070814153021.446917377@sgi.com>
	 <20070814153501.305923060@sgi.com> <20070818071035.GA4667@ucw.cz>
	 <Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com>
	 <1187641056.5337.32.camel@lappy>
	 <Pine.LNX.4.64.0708201323590.30053@schroedinger.engr.sgi.com>
	 <1187644449.5337.48.camel@lappy> <20070821003922.GD8414@wotan.suse.de>
	 <1187705235.6114.247.camel@twins>  <20070823033826.GE18788@wotan.suse.de>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-bgXRuoc8BMLrMxujQ051"
Date: Thu, 23 Aug 2007 11:26:48 +0200
Message-Id: <1187861208.6114.342.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nikita Danilov <nikita@clusterfs.com>
List-ID: <linux-mm.kvack.org>

--=-bgXRuoc8BMLrMxujQ051
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-08-23 at 05:38 +0200, Nick Piggin wrote:
> On Tue, Aug 21, 2007 at 04:07:15PM +0200, Peter Zijlstra wrote:
> > On Tue, 2007-08-21 at 02:39 +0200, Nick Piggin wrote:
> > >=20
> > > Although interestingly, we are not guaranteed to have enough memory t=
o
> > > completely initialise writeout of a single page.
> >=20
> > Yes, that is due to the unbounded nature of direct reclaim, no?
> =20
> Even writing out a single page to a plain old block backed filesystem
> can take a fair chunk of memory. I'm not really sure how problematic
> this is with a "real" filesystem, but even with something pretty simple,
> you might have to do block allocation, which itself might have to do
> indirect block allocation (which itself can be 3 or 4 levels), all of
> which have to actually update block bitmaps (which themselves may be
> many pages big). Then you also may have to even just allocate the
> buffer_head structure itself. And that's just to write out a single
> buffer in the page (on a 64K page system, there might be 64 of these).

Right, nikita once talked me though all that when we talked about
clustered writeout.

IIRC filesystems were supposed to keep mempools big enough to do this
for a single writepage at a time. Not sure its actually done though.

One advantage here is that swap writeout is very simple, so for
swap_writepage() the overhead is minimal, and we can free up space to
make progress with the fs writeout. And if there is little anonymous in
the system it must have a lot clean because of the dirty limit.

But yeah, there are some nasty details left here.

> > I've been meaning to write some patches to address this problem in a wa=
y
> > that does not introduce the hard wall Linus objects to. If only I had
> > this extra day in the week :-/
>=20
> For this problem I think the right way to go is to ensure everything
> is allocated to do writeout at page-dirty-time. This is what fsblock
> does (or at least _allows_ for: filesystems that do journalling or
> delayed allocation etc. themselves will have to ensure they have
> sufficient preallocations to do the manipulations they need at writeout
> time).
>=20
> But again, on the pragmatic side, the best behaviour I think is just
> to have writeouts not allocate from reserves without first trying to
> reclaim some clean memory, and also limit the number of users of the
> reserve. We want this anyway, right, because we don't want regular
> reclaim to start causing things like atomic allocation failures when
> load goes up.

My idea is to extend kswapd, run cpus_per_node instances of kswapd per
node for each of GFP_KERNEL, GFP_NOFS, GFP_NOIO. (basically 3 kswapds
per cpu)

whenever we would hit direct reclaim, add ourselves to a special
waitqueue corresponding to the type of GFP and kick all the
corresponding kswapds.

Now Linus' big objection is that all these processes would hit a wall
and not progress until the watermarks are high again.

Here is were the 'special' part of the waitqueue comes into order.

Instead of freeing pages to the page allocator, these kswapds would hand
out pages to the waiting processes in a round robin fashion. Only if
there are no more waiting processes left, would the page go to the buddy
system.

> > And then there is the deadlock in add_to_swap() that I still have to
> > look into, I hope it can eventually be solved using reserve based
> > allocation.
>=20
> Yes it should have a reserve. It wouldn't be hard, all you need is
> enough memory to be able to swap out a single page I would think (ie.
> one preload's worth).

Yeah, just need to look at the locking an batching, and ensure it has
enough preload to survive one batch, once all the locks are dropped it
can breathe again :-)
=20
> > > The buffer layer doesn't require disk blocks to be allocated at page
> > > dirty-time. Allocating disk blocks can require complex filesystem ope=
rations
> > > and readin of buffer cache pages. The buffer_head structures themselv=
es may
> > > not even be present and must be allocated :P
> > >=20
> > > In _practice_, this isn't such a problem because we have dirty limits=
, and
> > > we're almost guaranteed to have some clean pages to be reclaimed. In =
this
> > > same way, networked filesystems are not a problem in practice. Howeve=
r
> > > network swap, because there is no dirty limits on swap, can actually =
see
> > > the deadlock problems.
> >=20
> > The main problem with networked swap is not so much sending out the
> > pages (this has similar problems like the filesystems but is all bounde=
d
> > in its memory use).
> >=20
> > The biggest issue is receiving the completion notification. Network
> > needs to fall back to a state where it does not blindly consumes memory
> > or drops _all_ packets. An intermediate state is required, one where we
> > can receive and inspect incoming packets but commit to very few.
> =20
> Yes, I understand this is the main problem. But it is not _helped_ by
> the fact that reclaim reserves include the atomic allocation reserves.
> I haven't run this problem for a long time, but I'd venture to guess the
> _main_ reason the deadlock is hit is not because of networking allocating
> a lot of other irrelevant data, but because of reclaim using up most of
> the atomic allocation reserves.

Ah, interesting notion.

> And this observation is not tied to recurisve reclaim: if we somehow had
> a reserve for atomic allocations that was aside from the reclaim reserve,
> I think such a system would be practically free of deadlock for more
> anonymous-intensive workloads too.

One could get quite far, however the scenario of shutting down the
remote swap server while other network traffic is present will surely
still deadlock.

> > In order to create such a network state and for it to be stable, a
> > certain amount of memory needs to be available and an external trigger
> > is needed to enter and leave this state - currently provided by there
> > being more memory available than needed or not.
>=20
> I do appreciate the deadlock and solution.  I'm puzzled by your last line
> though? Currently we do not provide the required reserves in the network
> layer, *at all*, right?

Right, I was speaking of a kernel with my patches applied. Sorry for the
confusion.

--=-bgXRuoc8BMLrMxujQ051
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGzVLYXA2jU0ANEf4RAouCAJ9VTASsbOOBjNidlIezHfTytRzmnwCfRuGa
Ve8o+AN1odZcCy4f0hRZEdI=
=/FVg
-----END PGP SIGNATURE-----

--=-bgXRuoc8BMLrMxujQ051--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
