From: Thomas Schlichter <thomas.schlichter@web.de>
Subject: Re: 2.6.1-mm3
Date: Wed, 14 Jan 2004 20:12:05 +0100
References: <20040114014846.78e1a31b.akpm@osdl.org>
In-Reply-To: <20040114014846.78e1a31b.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-03=_FSZBAvCPf6rKiJ7";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200401142012.05388.thomas.schlichter@web.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Russell King <rmk+lkml@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-03=_FSZBAvCPf6rKiJ7
Content-Type: multipart/mixed;
  boundary="Boundary-01=_FSZBAHx4Gg/L4ik"
Content-Transfer-Encoding: 7bit
Content-Description: signed data
Content-Disposition: inline

--Boundary-01=_FSZBAHx4Gg/L4ik
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Description: body text
Content-Disposition: inline

Hi,

the patch "serial-03-fixups.patch" introduced following compile error:

  CC [M]  drivers/char/riscom8.o
drivers/char/riscom8.c: In function `rc_tiocmget':
drivers/char/riscom8.c:1323: error: `result' undeclared (first use in this=
=20
function)
drivers/char/riscom8.c:1323: error: (Each undeclared identifier is reported=
=20
only once
drivers/char/riscom8.c:1323: error: for each function it appears in.)
drivers/char/riscom8.c: In function `rc_tiocmset':
drivers/char/riscom8.c:1336: Warnung: unused variable `arg'
drivers/char/riscom8.c: At top level:
drivers/char/riscom8.c:1669: error: `rx_tiocmset' undeclared here (not in a=
=20
function)
drivers/char/riscom8.c:1669: error: initializer element is not constant
drivers/char/riscom8.c:1669: error: (near initialization for=20
`riscom_ops.tiocmset')
drivers/char/riscom8.c:1334: Warnung: `rc_tiocmset' defined but not used

The attached patch fixes it...

   Thomas Schlichter

--Boundary-01=_FSZBAHx4Gg/L4ik
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="fix_riscom8.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="fix_riscom8.diff"

=2D-- linux-2.6.1-mm3/drivers/char/riscom8.c.orig	2004-01-14 19:24:19.68477=
4056 +0100
+++ linux-2.6.1-mm3/drivers/char/riscom8.c	2004-01-14 19:31:05.567070568 +0=
100
@@ -1311,6 +1311,7 @@
 	struct riscom_port *port =3D (struct riscom_port *)tty->driver_data;
 	struct riscom_board * bp;
 	unsigned char status;
+	unsigned int result;
 	unsigned long flags;
=20
 	if (rc_paranoia_check(port, tty->name, __FUNCTION__))
@@ -1322,18 +1323,18 @@
 	status =3D rc_in(bp, CD180_MSVR);
 	result =3D rc_in(bp, RC_RI) & (1u << port_No(port)) ? 0 : TIOCM_RNG;
 	restore_flags(flags);
=2D	return    ((status & MSVR_RTS) ? TIOCM_RTS : 0)
+	result |=3D ((status & MSVR_RTS) ? TIOCM_RTS : 0)
 		| ((status & MSVR_DTR) ? TIOCM_DTR : 0)
 		| ((status & MSVR_CD)  ? TIOCM_CAR : 0)
 		| ((status & MSVR_DSR) ? TIOCM_DSR : 0)
 		| ((status & MSVR_CTS) ? TIOCM_CTS : 0);
+	return result;
 }
=20
 static int rc_tiocmset(struct tty_struct *tty, struct file *file,
 		       unsigned int set, unsigned int clear)
 {
 	struct riscom_port *port =3D (struct riscom_port *)tty->driver_data;
=2D	unsigned int arg;
 	unsigned long flags;
 	struct riscom_board *bp;
=20
@@ -1666,7 +1667,7 @@
 	.start =3D rc_start,
 	.hangup =3D rc_hangup,
 	.tiocmget =3D rc_tiocmget,
=2D	.tiocmset =3D rx_tiocmset,
+	.tiocmset =3D rc_tiocmset,
 };
=20
 static inline int rc_init_drivers(void)

--Boundary-01=_FSZBAHx4Gg/L4ik--

--Boundary-03=_FSZBAvCPf6rKiJ7
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQBABZSFYAiN+WRIZzQRArbKAKCGEAiA7xUFvaXjS18xHmnFVhRrsQCeMH0l
MriCMl5WqCqWymvvm+kaqNQ=
=6/nC
-----END PGP SIGNATURE-----

--Boundary-03=_FSZBAvCPf6rKiJ7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
