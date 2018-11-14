Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD21D6B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 06:09:22 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id o63-v6so14234085wma.2
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:09:22 -0800 (PST)
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com. [207.82.80.151])
        by mx.google.com with ESMTPS id l13-v6si19127541wrf.109.2018.11.14.03.09.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 03:09:21 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] mm/usercopy: Use memory range to be accessed for
 wraparound check
Date: Wed, 14 Nov 2018 11:09:25 +0000
Message-ID: <5dcd06a0f84a4824bb9bab2b437e190d@AcuMS.aculab.com>
References: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org>
 <FFE931C2-DE41-4AD8-866B-FD37C1493590@oracle.com>
In-Reply-To: <FFE931C2-DE41-4AD8-866B-FD37C1493590@oracle.com>
Content-Language: en-US
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'William Kucharski' <william.kucharski@oracle.com>, "Isaac J. Manjarres" <isaacm@codeaurora.org>
Cc: Kees Cook <keescook@chromium.org>, "crecklin@redhat.com" <crecklin@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "psodagud@codeaurora.org" <psodagud@codeaurora.org>, "tsoni@codeaurora.org" <tsoni@codeaurora.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

From: William Kucharski
> Sent: 14 November 2018 10:35
>=20
> > On Nov 13, 2018, at 5:51 PM, Isaac J. Manjarres <isaacm@codeaurora.org>=
 wrote:
> >
> > diff --git a/mm/usercopy.c b/mm/usercopy.c
> > index 852eb4e..0293645 100644
> > --- a/mm/usercopy.c
> > +++ b/mm/usercopy.c
> > @@ -151,7 +151,7 @@ static inline void check_bogus_address(const unsign=
ed long ptr, unsigned long n,
> > =09=09=09=09       bool to_user)
> > {
> > =09/* Reject if object wraps past end of memory. */
> > -=09if (ptr + n < ptr)
> > +=09if (ptr + (n - 1) < ptr)
> > =09=09usercopy_abort("wrapped address", NULL, to_user, 0, ptr + n);
>=20
> I'm being paranoid, but is it possible this routine could ever be passed =
"n" set to zero?
>=20
> If so, it will erroneously abort indicating a wrapped address as (n - 1) =
wraps to ULONG_MAX.
>=20
> Easily fixed via:
>=20
> =09if ((n !=3D 0) && (ptr + (n - 1) < ptr))

Ugg... you don't want a double test.

I'd guess that a length of zero is likely, but a usercopy that includes
the highest address is going to be invalid because it is a kernel address
(on most archs, and probably illegal on others).
What you really want to do is add 'ptr + len' and check the carry flag.

=09David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1=
PT, UK
Registration No: 1397386 (Wales)
