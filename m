Date: Fri, 30 Jan 2004 05:48:29 -0500
From: "Zephaniah E. Hull" <warp@babylon.d2dc.net>
Subject: Re: 2.6.2-rc2-mm1
Message-ID: <20040130104829.GA2505@babylon.d2dc.net>
References: <20040127233402.6f5d3497.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="J2SCkAp4GZ/dPZZf"
Content-Disposition: inline
In-Reply-To: <20040127233402.6f5d3497.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vojtech Pavlik <vojtech@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 27, 2004 at 11:34:02PM -0800, Andrew Morton wrote:
>=20
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.2-rc2/2=
=2E6.2-rc2-mm1/
>=20
> - From now on, -mm kernels will contain the latest contents of:
>=20
> 	Vojtech's tree:		input.patch

This one seems to have a rather problematic patch, which I can't find
any explanation for.

Specificly:
<snip>
diff -Nru a/drivers/usb/input/hid-input.c b/drivers/usb/input/hid-input.c
--- a/drivers/usb/input/hid-input.c	Thu Jan 29 22:57:25 2004
+++ b/drivers/usb/input/hid-input.c	Thu Jan 29 22:57:25 2004
@@ -432,20 +432,21 @@
 	input_regs(input, regs);
=20
 	if ((hid->quirks & HID_QUIRK_2WHEEL_MOUSE_HACK)
-			&& (usage->code =3D=3D BTN_BACK)) {
+			&& (usage->code =3D=3D BTN_BACK || usage->code =3D=3D BTN_EXTRA)) {
 		if (value)
 			hid->quirks |=3D HID_QUIRK_2WHEEL_MOUSE_HACK_ON;
 		else
 			hid->quirks &=3D ~HID_QUIRK_2WHEEL_MOUSE_HACK_ON;
 		return;
 	}
<snip>

This seems to be due to trying to use the same flag for
USB_DEVICE_ID_CYPRESS_MOUSE as well, however this is very wrong.

The original user of HID_QUIRK_2WHEEL_MOUSE_HACK,
USB_DEVICE_ID_A4TECH_WCP32PU, actually /HAS/ a button labeled BTN_EXTRA,
which after this patch can no longer even be used.

The only proper approach is to rename HID_QUIRK_2WHEEL_MOUSE_HACK and
add a new one for the Cypress mouse as well.

If need be I can generate such a patch, however I will need to know what
to generate it against.

Zephaniah E. Hull.
(Original author of the HID_QUIRK_2WHEEL_MOUSE_HACK patch.)

--=20
	1024D/E65A7801 Zephaniah E. Hull <warp@babylon.d2dc.net>
	   92ED 94E4 B1E6 3624 226D  5727 4453 008B E65A 7801
	    CCs of replies from mailing lists are requested.

If I have trouble installing Linux, something is wrong. Very wrong.
  -- Linus Torvalds on l-k.

--J2SCkAp4GZ/dPZZf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAGjZ9RFMAi+ZaeAERAnkCAJ9o9F4DNgXDah7WE8T8/17H6YQNmQCcCWK/
e24EwAE2y7KBGww6iEZUdUM=
=HDH6
-----END PGP SIGNATURE-----

--J2SCkAp4GZ/dPZZf--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
