Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9ECA26B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 05:05:11 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so50337628wiw.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 02:05:11 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id y11si12437517wiv.114.2015.06.14.02.05.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 02:05:10 -0700 (PDT)
Received: by wiwd19 with SMTP id d19so50337039wiw.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 02:05:09 -0700 (PDT)
From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Possible broken MM code in dell-laptop.c?
Date: Sun, 14 Jun 2015 11:05:07 +0200
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4151917.2Ma5RsCSLe";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201506141105.07171@pali>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans de Goede <hdegoede@redhat.com>, Darren Hart <dvhart@infradead.org>, Ben Skeggs <bskeggs@redhat.com>, Stuart Hayes <stuart_hayes@dell.com>, Matthew Garrett <mjg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>
Cc: platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--nextPart4151917.2Ma5RsCSLe
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hello,

in drivers/platform/x86/dell-laptop.c is this part of code:

static int __init dell_init(void)
{
=2E..
	/*
	 * Allocate buffer below 4GB for SMI data--only 32-bit physical addr
	 * is passed to SMI handler.
	 */
	bufferpage =3D alloc_page(GFP_KERNEL | GFP_DMA32);
	if (!bufferpage) {
		ret =3D -ENOMEM;
		goto fail_buffer;
	}
	buffer =3D page_address(bufferpage);

	ret =3D dell_setup_rfkill();

	if (ret) {
		pr_warn("Unable to setup rfkill\n");
		goto fail_rfkill;
	}
=2E..
fail_rfkill:
	free_page((unsigned long)bufferpage);
fail_buffer:
=2E..
}

Then there is another part:

static void __exit dell_exit(void)
{
=2E..
	free_page((unsigned long)buffer);
}

I suspect that there is some problem with free_page() call. In dell_init=20
is called free_page() on bufferpage and in dell_exit() on buffer.

Matthew and Stuart, you introduced this inconsistency in commit:

=2D------------------------------------------------
commit 116ee77b2858d9c89c0327f3a47c8ba864bf4a96
Author: Stuart Hayes <stuart_hayes@dell.com>
Committer: Matthew Garrett <mjg@redhat.com>
Date:   Wed Feb 10 14:12:13 2010 -0500

    dell-laptop: Use buffer with 32-bit physical address

    Calls to communicate with system firmware via a SMI (using dcdbas)
    need to use a buffer that has a physical address of 4GB or less.
    Currently the dell-laptop driver does not guarantee this, and when=20
the
    buffer address is higher than 4GB, the address is truncated to 32=20
bits
    and the SMI handler writes to the wrong memory address.
   =20
    Signed-off-by: Stuart Hayes <stuart_hayes@dell.com>
    Acked-by: Matthew Garrett <mjg@redhat.com>
=2D------------------------------------------------

Can you or somebody else (CCed linux-mm) look at this page related code?=20
I think it is wrong, but somebody authoritative should provide answer.

Thanks.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart4151917.2Ma5RsCSLe
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlV9Q8MACgkQi/DJPQPkQ1J0UACdHR0APSrYqgL+780YeaHg5762
rN4AoKgqmDBEOE0OFNDra9d8ZG+anJ5z
=cav6
-----END PGP SIGNATURE-----

--nextPart4151917.2Ma5RsCSLe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
