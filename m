Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 756406B005A
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 06:01:28 -0400 (EDT)
Date: Tue, 14 Jul 2009 13:33:56 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak hexdump proposal
Message-ID: <20090714103356.GA2929@localdomain.by>
References: <20090629201014.GA5414@localdomain.by>
 <1247566033.28240.46.camel@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sdtB3X0nJg68CQEu"
Content-Disposition: inline
In-Reply-To: <1247566033.28240.46.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On (07/14/09 11:07), Catalin Marinas wrote:
> Hi,
>=20
Hello Catalin,

> On Mon, 2009-06-29 at 21:10 +0100, Sergey Senozhatsky wrote:
> > This is actually draft. We'll discuss details during next merge window =
(or earlier).
>=20
> Better earlier (I plan to get some more kmemleak patches into
> linux-next).
>=20
> > hex dump prints not more than HEX_MAX_LINES lines by HEX_ROW_SIZE (16 o=
r 32) bytes.
> > ( min(object->size, HEX_MAX_LINES * HEX_ROW_SIZE) ).
> >=20
> > Example (HEX_ROW_SIZE 16):
> >=20
> > unreferenced object 0xf68b59b8 (size 32):
> >   comm "swapper", pid 1, jiffies 4294877610
> >   hex dump (first 32 bytes):
> >     70 6e 70 20 30 30 3a 30 31 00 5a 5a 5a 5a 5a 5a  pnp 00:01.ZZZZZZ
> >     5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a a5  ZZZZZZZZZZZZZZZ.
>=20
> That's my preferred as I do not want to go beyond column 80.
>=20
Same with me.

> > diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> > index 5063873..65c5d74 100644
> > --- a/mm/kmemleak.c
> > +++ b/mm/kmemleak.c
> > @@ -160,6 +160,15 @@ struct kmemleak_object {
> >  /* flag set to not scan the object */
> >  #define OBJECT_NO_SCAN         (1 << 2)
> >=20
> > +/* number of bytes to print per line; must be 16 or 32 */
> > +#define HEX_ROW_SIZE           32
>=20
> 16 here.
>=20
OK.

[...]
> > @@ -303,6 +343,11 @@ static void print_unreferenced(struct seq_file *se=
q,
> >                    object->pointer, object->size);
> >         seq_printf(seq, "  comm \"%s\", pid %d, jiffies %lu\n",
> >                    object->comm, object->pid, object->jiffies);
> > +
> > +       /* check whether hex dump should be printed */
> > +       if (atomic_read(&kmemleak_hex_dump))
> > +               hex_dump_object(seq, object);
>=20
> No need for this check, just leave it in all cases (as we now only read
> the reports via the debug/kmemleak file.
>
=20
> > @@ -1269,6 +1314,10 @@ static ssize_t kmemleak_write(struct file *file,=
 const char __user *user_buf,
> >                 start_scan_thread();
> >         else if (strncmp(buf, "scan=3Doff", 8) =3D=3D 0)
> >                 stop_scan_thread();
> > +       else if (strncmp(buf, "hexdump=3Don", 10) =3D=3D 0)
> > +               atomic_set(&kmemleak_hex_dump, 1);
> > +       else if (strncmp(buf, "hexdump=3Doff", 11) =3D=3D 0)
> > +               atomic_set(&kmemleak_hex_dump, 0);
>=20
> Same here.
>=20

Am I understand correct that no way for user to on/off hexdump?
/* no need for atomic_t kmemleak_hex_dump */


> Thanks.
>=20
> --=20
> Catalin
>=20

	Sergey
--sdtB3X0nJg68CQEu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iJwEAQECAAYFAkpcXxQACgkQfKHnntdSXjSnbgP/QgKQWeO54QO1z0vZniCMHy+F
vvljrpBvko4oBImeMHbqpEs9YYJ+G6jlArmtJs8X+pXFEfzpg2w14/D+S8G+RiW/
l5m/2GwKpRoMPLAXzgTV0nTAZr0MsiJfPxZwwHcVk7WTroUPwYjrAwRGismBAx3X
Ml47AqcK5IebUzo8GF4=
=rYNT
-----END PGP SIGNATURE-----

--sdtB3X0nJg68CQEu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
