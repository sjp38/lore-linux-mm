Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 781E28D0039
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 23:00:41 -0400 (EDT)
From: Ben Hutchings <ben@decadent.org.uk>
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-O+qF2uxBCW/A31lX6g0r"
Date: Mon, 21 Mar 2011 03:00:31 +0000
Message-ID: <1300676431.26693.317.camel@localhost>
Mime-Version: 1.0
Subject: sysfs interface to transparent hugepages
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org


--=-O+qF2uxBCW/A31lX6g0r
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This kind of cute format:

       if (test_bit(enabled, &transparent_hugepage_flags)) {
               VM_BUG_ON(test_bit(req_madv, &transparent_hugepage_flags));
               return sprintf(buf, "[always] madvise never\n");
       } else if (test_bit(req_madv, &transparent_hugepage_flags))
               return sprintf(buf, "always [madvise] never\n");
       else
               return sprintf(buf, "always madvise [never]\n");

is probably nice for a kernel developer or experimental user poking
around in sysfs.  But sysfs is mostly meant for programs to read and
write, and this format is unnecessarily complex for a program to parse.

Please use separate attributes for the current value and available
values, like cpufreq does.  I know there are other examples of the above
format, but not everything already in sysfs is a *good* example!

This, on the other hand, is totally ridiculous:

       if (test_bit(flag, &transparent_hugepage_flags))
               return sprintf(buf, "[yes] no\n");
       else
               return sprintf(buf, "yes [no]\n");

Why show the possible values of a boolean?  I can't even find any
examples of 'yes' and 'no' rather than '1' and '0'.

And really, why add boolean flags for a tristate at all?

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-O+qF2uxBCW/A31lX6g0r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATYa/See/yOyVhhEJAQq32BAAkIexI4kzTTknyOeu8LQ1dRiqIHBC7IPL
o0DHLG/HF+ytw/s/x5y0PAYj/SbzXoZrkLC/AWjQOCCej1D7JYke4t9u0ge7GnHG
QR2WoVKR+8SLw8ypCKbz0yFpZUWAPXTgsnj7dTUDXl4OgCejztnansBOXO/0gUpt
gWmkOUy/ONGZUVmzyGawXMHHM2CBAwPuPA1qRH/nu8Jpthrb6useaaaF0OnAeMcS
gxT82qJfVj9I8jmhcZ6tTHovUKw3zUPPm8Ls05kETzETZfsX+XT20Sfz9OG7+AG7
1N6uKdycMtyHYuAuOa2CtYfhV9yyVf7Oe5I6iEdVuX3uq/8qL2roITOQ83JrrTBw
gqxgkFWs5749WSE3fiCcBch7LKNuNSxlJYGteS/m6B5KGyTTyvIVxdlCSg8ZpYAd
OeLwPf4qijWbWfpWzRhIRB/xiQqfekOAqFqeh7MxGPZkU+feNiPD4I7qc845EBB0
ErF+4knYoTQLzI3BH5pQdQ/8x5yR1yMw5iScO29wMLHQi+lb9GtjdHK7pvJqf0mt
Cpks+Unh6RhcnCfAz+2dEgcGS4SJeBTLaO3SIRJQ0mb7MT8q5nKDQtjWkPqhgWzS
NinYY6Wpq2vwet40nlnNC9f4+Fe2KNVWuWqax+iY6mNlnenkb5nB9Ze4HOJ/k/vo
WlR+r0vVfAY=
=Tz/2
-----END PGP SIGNATURE-----

--=-O+qF2uxBCW/A31lX6g0r--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
