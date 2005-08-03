Subject: Re: [RFC] Net vm deadlock fix (preliminary)
From: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <200508040336.25761.phillips@istop.com>
References: <200508031657.34948.phillips@istop.com>
	 <Pine.LNX.4.58.0508030826230.23501@tux.rsn.bth.se>
	 <200508040336.25761.phillips@istop.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-xaqxaSQCaD+3ipXjL+Yk"
Date: Wed, 03 Aug 2005 20:21:45 +0200
Message-Id: <1123093305.11483.21.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@istop.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-xaqxaSQCaD+3ipXjL+Yk
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2005-08-04 at 03:36 +1000, Daniel Phillips wrote:

> I can think of two ways to deal with this:
>=20
>   1) Mindlessly include the entire maximum memory usage of the rx-ring in
>      the reserve requirement (e.g., (maxskbs * (MTU + k)) / PAGE_SIZE).

Would be dependent on the numberof interfaces as well.

>   2) Never refill the rx-ring from the reserve.  Instead, if the skbs eve=
r
>      run out (because e1000_alloc_rx_buffers had too many GFP_ATOMIC allo=
c
>      failures) then use __GFP_MEMALLOC instead of just giving up at that
>      point.

This is how e1000 currently works (suggestions have been made to change
this to work like the tg3 driver does which has copybreak support etc)

1. Allocate skbs filling the rx-ring as much as possible
2. tell hardware there's new skbs to DMA packets into
3. note that an skb has been filled with data (interrupt or polling)
4. remove that skb from the rx-ring
5. pass the skb up the stack
6. goto 3 if quota hasn't been filled
7. goto 1 if quota has been filled

The skbs allocated to fill the rx-ring are the _same_ skbs that are
passed up the stack. So you won't see __GFP_MEMALLOC allocated skbs
until RX_RINGSIZE packets after we got low on memory (fifo ring). I
can't really say I see how #2 above solves that since we _have_ to
allocate skbs to fill the rx-ring, otherwise the NIC won't have anywhere
to put the received packets and will thus drop them in hardware.

Or are you suggesting to let the rx-ring deplete until completely empty
(or nearly empty) if we are low on memory, and only then start falling
back to allocating with __GFP_MEMALLOC if GFP_ATOMIC fails?
That could and probably would cause hardware to drop packets because it
can run out of fresh rx-descriptors before we manage to start allocating
with __GFP_MEMALLOC if the packetrate is high, at least it makes it much
more likely to happen.

--=20
/Martin

--=-xaqxaSQCaD+3ipXjL+Yk
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBC8Qs5Wm2vlfa207ERAvvgAJ0YUhV68n1hnqwsDf85YqH5bdEnwQCfTpUk
6Z4NMtqv8i4WWs/mQ63ij0Q=
=Fre2
-----END PGP SIGNATURE-----

--=-xaqxaSQCaD+3ipXjL+Yk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
