Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <p731we43muw.fsf@bingen.suse.de>
References: <20070814142103.204771292@sgi.com>
	 <20070815122253.GA15268@wotan.suse.de> <1187183526.6114.45.camel@twins>
	 <p731we43muw.fsf@bingen.suse.de>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zbCJ4M02+eISTRzbDrdW"
Date: Wed, 15 Aug 2007 15:55:20 +0200
Message-Id: <1187186120.6114.56.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

--=-zbCJ4M02+eISTRzbDrdW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-08-15 at 16:15 +0200, Andi Kleen wrote:
> Peter Zijlstra <a.p.zijlstra@chello.nl> writes:
> >=20
> > Christoph's suggestion to set min_free_kbytes to 20% is ridiculous - no=
r
> > does it solve all deadlocks :-(
>=20
> A minimum enforced reclaimable non dirty threshold wouldn't be
> that ridiculous though. So the memory could be used, just not
> for dirty data.

Sure, and note that various patches to such an effect have already been
posted (even one by myself), they introduce a third reclaim list on
which clean pages live. If you add to that a requirement to keep that
list at a certain level, one could replace part (or all) of the reserves
with that.

But that is more an optimisation rather than anything else.

The thing I strongly objected to was the 20%.

Also his approach misses the threshold - the extra condition needed to
break out of the various network deadlocks. There is no point that says
- ok, and now we're in trouble, drop anything non-critical. Without that
you'll always run into a wall.

> His patchkit essentially turns the GFP_ATOMIC requirements=20
> from free to easily reclaimable. I see that as an general improvement.
>=20
> I remember sct talked about this many years ago and it's still
> a good idea.

That is his second patch-set, and I do worry about the irq latency that
that will introduce. It very much has the potential to ruin everything
that cares about interactiveness or latency.

Hence my suggestion to look at threaded interrupts, in which case it
would only ruin the latency of the interrupt that does this, but does
not hold off other interrupts/processes. Granted PI would be nice to
ensure the threaded handler does eventually finish.



--=-zbCJ4M02+eISTRzbDrdW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGwwXIXA2jU0ANEf4RAh06AJ9tDH6os9rYP27C+XjdS0FmxIpo2QCeJRLs
SuGkz9WLmIn91HJ+wnXl3XA=
=JwOq
-----END PGP SIGNATURE-----

--=-zbCJ4M02+eISTRzbDrdW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
