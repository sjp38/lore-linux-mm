Subject: Re: [PATCH 3/6] cpuset write throttle
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0710032055120.4560@schroedinger.engr.sgi.com>
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
	 <46E7434F.9040506@google.com>
	 <20070914161517.5ea3847f.akpm@linux-foundation.org>
	 <4702E49D.2030206@google.com>
	 <Pine.LNX.4.64.0710031045290.3525@schroedinger.engr.sgi.com>
	 <4703FF89.4000601@google.com>
	 <Pine.LNX.4.64.0710032055120.4560@schroedinger.engr.sgi.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-c6JzNp3KUQxynU3+ywFu"
Date: Thu, 04 Oct 2007 09:37:30 +0200
Message-Id: <1191483450.13204.96.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ethan Solomita <solo@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--=-c6JzNp3KUQxynU3+ywFu
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-03 at 20:56 -0700, Christoph Lameter wrote:
> On Wed, 3 Oct 2007, Ethan Solomita wrote:
>=20
> > >> 	Unfortunately this eliminates one of the main reasons for the
> > >> per-cpuset throttling. If one cpuset is responsible for pushing one
> > >> disk/BDI to its dirty limit, someone in another cpuset can get throt=
tled.
> > >=20
> > > I think that is acceptable. All processes that write to one disk/BDI =
must=20
> > > be affected by congestion on that device. We may have to deal with=20
> > > fairness issues later if it indeed becomes a problem.
> >=20
> > 	We do see a fairness issue. We've seen delays on the order of 100
> > seconds for just a few writes to disk, and latency is important to us.
> > Perhaps we can detect that the bdi already has a long queue of pending
> > writes and not force more writes at this time so long as the per-cpuset
> > dirty threshold is not too high.
>=20
> Arghy.

clameter gone pirate. Its just that you're a few weeks late :-)

Perhaps you can keep a proportion in the cpu-set, and do a similar trick
that the process proportions do.

currently:

  limit =3D total_limit * p_bdi * (1 - p_task/8)

suggestion:

  limit =3D total_limit * p_bdi * (1 - p_task/8) * (1 - p_cpuset/4)

That would give a very busy cpuset a limit 1/4 lower than an idle
cpu-set, thereby the idle cpu-set can do light traffic before getting
throttled.

p_bdi is ratio of writeout completions
p_task is ratio of dirtiers
p_cpuset would also be a ratio of dirtiers

Another option would be:

  limit =3D cpuset_limit * p_bdi * (1 - p_task/8)

Each cpuset gets a pre-proportioned part of the total limit. Overlapping
cpusets would get into some arguments though.

Hmm, maybe combine the two:

  limit =3D cpuset_limit * p_bdi * (1 - p_task/8) * (1 - p_cpuset/4)

> > 	On a side note, get_dirty_limits() now returns two dirty counts, both
> > the dirty and bdi_dirty, yet its callers only ever want one of those
> > results. Could we change get_dirty_limits to only calculate one dirty
> > value based upon whether bdi is non-NULL? This would save calculation o=
f
> > regular dirty when a bdi is passed.
>=20
> Hmmmm.... I think Peter needs to consider this.

we need the total anyway, its where we start calculating the bdi thing
from.

--=-c6JzNp3KUQxynU3+ywFu
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHBJg6XA2jU0ANEf4RAuLtAJ49msdBFZfAZsd53njGbUIQquopiQCgjEw1
jU4g5qzdet3WoePFroACCrE=
=U29x
-----END PGP SIGNATURE-----

--=-c6JzNp3KUQxynU3+ywFu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
