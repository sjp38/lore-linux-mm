From: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
Date: Tue, 18 Mar 2008 17:44:55 +0100
References: <200803061447.05797.Jens.Osterkamp@gmx.de> <200803121619.45708.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803121630110.10488@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803121630110.10488@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1404917.03rEmWTCFy";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200803181744.58735.Jens.Osterkamp@gmx.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart1404917.03rEmWTCFy
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 13 March 2008, Christoph Lameter wrote:
> On Wed, 12 Mar 2008, Jens Osterkamp wrote:
>=20
> > I added a printk in kmalloc and the size seems to be 0x4000.
>=20
> Hmmmm... So kmalloc_index returns 14. This should all be fine.
>=20
> However, with slub_debug the size of the 16k kmalloc object is=20
> actually a bit larger than 0x4000. The caller must not expect the object=
=20
> to be aligned to a 16kb boundary. Is that the case?

Actually the caller expects exactly that. The kmalloc that I saw was coming
from alloc_thread_info in dup_task_struct. For 4k pages this maps to=20
__get_free_pages whereas for 64k pages it maps to kmalloc.
The result of __get_free_pages seem to be aligned and kmalloc (with slub_de=
bug)
of course not. That explains the 4k/64k difference and the crash I am seein=
g...
but I can't think of a reasonable fix right now as I don't understand the
reason for the difference in the allocation code (yet).

Gru=DF,
	Jens

--nextPart1404917.03rEmWTCFy
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH3/GKP1aZ9bkt7XMRAjoAAJ9omuOwPyIcBYvKB/jHCKpqeFg+TACfVg85
nAgVZo9+q9qa0J/NRsN+3Yc=
=cc1L
-----END PGP SIGNATURE-----

--nextPart1404917.03rEmWTCFy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
