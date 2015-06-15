Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id E55AA6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 16:42:34 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so35983386wic.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:42:34 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id ga17si20232244wic.36.2015.06.15.13.42.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 13:42:33 -0700 (PDT)
Received: by wicnd19 with SMTP id nd19so35982834wic.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:42:33 -0700 (PDT)
From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: Possible broken MM code in dell-laptop.c?
Date: Mon, 15 Jun 2015 22:42:30 +0200
References: <201506141105.07171@pali> <20150615203645.GD83198@vmdeb7>
In-Reply-To: <20150615203645.GD83198@vmdeb7>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2946010.OgYTOazmK5";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201506152242.30732@pali>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Darren Hart <dvhart@infradead.org>
Cc: Hans de Goede <hdegoede@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Stuart Hayes <stuart_hayes@dell.com>, Matthew Garrett <mjg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>

--nextPart2946010.OgYTOazmK5
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 15 June 2015 22:36:45 Darren Hart wrote:
> On Sun, Jun 14, 2015 at 11:05:07AM +0200, Pali Roh=C3=A1r wrote:
> > Hello,
> >=20
> > in drivers/platform/x86/dell-laptop.c is this part of code:
> >=20
> > static int __init dell_init(void)
> > {
> > ...
> >=20
> > 	/*
> > =09
> > 	 * Allocate buffer below 4GB for SMI data--only 32-bit physical
> > 	 addr * is passed to SMI handler.
> > 	 */
> > =09
> > 	bufferpage =3D alloc_page(GFP_KERNEL | GFP_DMA32);
> > 	if (!bufferpage) {
> > =09
> > 		ret =3D -ENOMEM;
> > 		goto fail_buffer;
> > =09
> > 	}
> > 	buffer =3D page_address(bufferpage);
> > =09
> > 	ret =3D dell_setup_rfkill();
> > =09
> > 	if (ret) {
> > =09
> > 		pr_warn("Unable to setup rfkill\n");
> > 		goto fail_rfkill;
> > =09
> > 	}
> >=20
> > ...
> >=20
> > fail_rfkill:
> > 	free_page((unsigned long)bufferpage);
> >=20
> > fail_buffer:
> > ...
> > }
> >=20
> > Then there is another part:
> >=20
> > static void __exit dell_exit(void)
> > {
> > ...
> >=20
> > 	free_page((unsigned long)buffer);
>=20
> I believe you are correct, and this should be bufferpage. Have you
> observed any failures?

Rmmoding dell-laptop.ko works fine. There is no error in dmesg. I think=20
that buffer (and not bufferpage) should be passed to free_page(). So in=20
my opinion problem is at fail_rfkill: label and not in dell_exit().

But somebody from linux-mm should look at it...

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart2946010.OgYTOazmK5
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlV/OLYACgkQi/DJPQPkQ1Jk0ACeIGd6oijZXI+02KCAq3JSNibE
TXQAn2qfELLHG8KWLj2yFeTv/L/aR46T
=FGp/
-----END PGP SIGNATURE-----

--nextPart2946010.OgYTOazmK5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
